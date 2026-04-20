// SPDX-FileCopyrightText: 2025 aesc silicon
//
// SPDX-License-Identifier: CERN-OHL-W-2.0

// G.1c: BmbSpiXipController co-simulation wrapper with embedded Quad
// I/O flash slave. Exposes a single 14-bit Wishbone slave to Renode
// with three internal banks:
//   0x0000-0x0FFF cfgSpiBus  (SPI master config)
//   0x1000-0x1FFF cfgXipBus  (XIP engine config: mode, dummyCycles, evcr)
//   0x2000-0x2FFF XIP data   (BMB reads bridged from Wishbone)
//
// Backing ROM pattern: rom[i] = i & 0xFF.

#include <cstdio>
#include <cstdint>
#include <cstring>
#include "src/buses/wishbone.h"
#include "src/renode_bus.h"
#include "verilated.h"
#include "VWishboneBmbSpiXipController.h"

#include "../../wrappers/spi_qio_flash_slave.h"

#define DEBUG_ENABLE 0

#if DEBUG_ENABLE
  #define DEBUG_PRINT(fmt, ...) do { printf("[BMBXIP] " fmt "\n", ##__VA_ARGS__); fflush(stdout); } while(0)
#else
  #define DEBUG_PRINT(fmt, ...)
#endif

static VWishboneBmbSpiXipController* g_top = nullptr;

static uint64_t g_bridge_addr   = 0;
static uint64_t g_bridge_rd_dat = 0;
static uint64_t g_bridge_wr_dat = 0;

static uint8_t g_dummy_sel   = 0xF;
static uint8_t g_dummy_stall = 0;

static SpiQioFlashSlave g_flash;
static bool g_flash_initialised = false;
static uint8_t g_flash_rom[4096];

// Opt-in "fast mode" for firmware that spin-loops on XIP (e.g. the
// 33i CPU-driven bootrom test). Gated by BMBXIP_FAST=1 — default off
// so CI keeps full-fidelity SPI Quad I/O pipeline coverage. Two
// independent mechanisms, both correctness-preserving:
//
//   1. tick() idle shortcut: when no WB transaction is active and
//      SPI CS is deasserted, skip the per-cycle Verilator eval. The
//      RTL has no observable state in progress, so advancing virtual
//      time without ticking is indistinguishable. This is where
//      ~99% of the wall time goes (30 MHz x 5 s virtual = 150M
//      ticks, each = 2 eval() calls).
//
//   2. evalModel() fetch cache for the XIP data bank (bank 2, byte
//      0x2000-0x2FFF). First read of each 32-bit word runs the full
//      pipeline and captures; subsequent reads short-circuit by
//      poking DAT_MISO + ACK directly. Invalidated on any bank-1
//      (cfgXip) write to stay correct across XIP mode changes.
static bool     g_fast_mode = false;
static uint32_t g_fetch_cache[1024];
static bool     g_fetch_cache_valid[1024];

static inline void invalidateFetchCache() {
  for (size_t i = 0; i < 1024; ++i) g_fetch_cache_valid[i] = false;
}

static void initFlashRom() {
  // If BMBXIP_IMAGE_PATH is set, load the image container from disk;
  // otherwise fall back to the synthetic pattern rom[i] = i & 0xFF.
  const char* path = getenv("BMBXIP_IMAGE_PATH");
  if (path && *path) {
    FILE* f = fopen(path, "rb");
    if (f) {
      memset(g_flash_rom, 0xFF, sizeof(g_flash_rom));
      size_t n = fread(g_flash_rom, 1, sizeof(g_flash_rom), f);
      fclose(f);
      fprintf(stderr, "[BMBXIP] loaded %zu bytes from %s\n", n, path);
      return;
    }
    fprintf(stderr, "[BMBXIP] WARN: BMBXIP_IMAGE_PATH set but fopen failed: %s\n", path);
  }
  for (size_t i = 0; i < sizeof(g_flash_rom); ++i) {
    g_flash_rom[i] = (uint8_t)(i & 0xFF);
  }
}

static uint8_t combineDq(uint8_t mw, uint8_t moe, uint8_t so, uint8_t soe) {
  uint8_t out = 0;
  for (int n = 0; n < 4; ++n) {
    uint8_t bit = 1u << n;
    if (moe & bit)       out |= (mw & bit);
    else if (soe & bit)  out |= (so & bit);
    else                 out |= bit;
  }
  return out & 0xF;
}

static void copyBridgeAndEval() {
  // 14-bit address = word-addressed up to 16 KiB range.
  g_top->io_wb_ADR      = (uint16_t)((g_bridge_addr >> 2) & 0x3FFF);
  g_top->io_wb_DAT_MOSI = (uint32_t)(g_bridge_wr_dat);

  if (g_flash_initialised) {
    uint8_t cs   = g_top->io_spi_cs & 1;
    uint8_t sclk = g_top->io_spi_sclk & 1;
    uint8_t mw   = g_top->io_spi_dq_write & 0xF;
    uint8_t moe  = g_top->io_spi_dq_writeEnable & 0xF;
    uint8_t so = 0, soe = 0;
    g_flash.tick(cs, sclk, mw, moe, so, soe);
    g_top->io_spi_dq_read = combineDq(mw, moe, so, soe);
  } else {
    g_top->io_spi_dq_read = 0xF;
  }

  g_top->eval();
  g_bridge_rd_dat = (uint64_t)g_top->io_wb_DAT_MISO;
}

void evalModel() {
  if (!g_top) return;

  // Bank and word index derived from byte offset in the wrapper's
  // 16 KiB range (banks: 0 cfgSpi, 1 cfgXip, 2 XIP data).
  const uint32_t addr_byte = (uint32_t)(g_bridge_addr & 0x3FFF);
  const uint32_t bank      = (addr_byte >> 12) & 0x3;
  const uint32_t word_idx  = (addr_byte & 0xFFF) >> 2;

  // Fast path: cache hit on a bank-2 read. Short-circuit without
  // touching the RTL. The cache stores the UNSHIFTED 32-bit word so
  // the sub-word shift below still applies uniformly.
  bool cache_hit = false;
  if (g_fast_mode &&
      g_top->io_wb_CYC && g_top->io_wb_STB && !g_top->io_wb_WE &&
      bank == 2 && g_fetch_cache_valid[word_idx]) {
    const uint32_t v = g_fetch_cache[word_idx];
    g_bridge_rd_dat       = (uint64_t)v;
    g_top->io_wb_DAT_MISO = v;
    g_top->io_wb_ACK      = 1;
    cache_hit = true;
  }

  if (!cache_hit) {
    copyBridgeAndEval();

    // Pump extra cycles while a Wishbone transaction is outstanding.
    // XIP reads go: Wishbone -> WishboneToBmbMaster FSM -> BMB cmd ->
    // SpiXipController (drives SPI, waits for flash) -> BMB rsp ->
    // bridge ACK. That requires many bus clocks (on the order of 100+
    // for a 32-bit quad read with dummy cycles).
    if (g_top->io_wb_CYC && g_top->io_wb_STB && !g_top->io_wb_ACK) {
      for (int i = 0; i < 5000 && !g_top->io_wb_ACK; ++i) {
        g_top->clk = 1; copyBridgeAndEval();
        g_top->clk = 0; copyBridgeAndEval();
      }
    }

    // Write-latch fix: WishboneSlaveFactory's doWrite condition is
    // CYC && STB && WE && ACK simultaneously, but ACK is registered
    // (rises one posedge after CYC+STB). On the posedge where ACK
    // first rises, the sync-write always block evaluated with the
    // pre-edge (old) ACK=0 and skipped the register update. Renode
    // drops CYC/STB immediately after seeing ACK=1, so without an
    // extra posedge here the write never latches.
    //
    // Symptom without this fix: writes to cfgSpi/cfgXip registers
    // silently no-op. Reads still work because doRead takes its data
    // from the combinational read mux on the same posedge. Caught by
    // Gap 3.2 #1 (xip_cache_invalidate test); same pattern is already
    // in pwm_wrapper.cpp and pio_wrapper.cpp.
    if (g_top->io_wb_CYC && g_top->io_wb_STB && g_top->io_wb_WE &&
        g_top->io_wb_ACK) {
      g_top->clk = 1; copyBridgeAndEval();
      g_top->clk = 0; copyBridgeAndEval();
    }

    if (g_fast_mode &&
        g_top->io_wb_CYC && g_top->io_wb_STB && g_top->io_wb_ACK) {
      if (!g_top->io_wb_WE && bank == 2) {
        g_fetch_cache[word_idx]       = (uint32_t)g_bridge_rd_dat;
        g_fetch_cache_valid[word_idx] = true;
      } else if (g_top->io_wb_WE && bank == 1) {
        // cfgXip mode/dummyCycles/evcr write — invalidate to avoid
        // serving stale bytes if XIP mode changed.
        invalidateFetchCache();
      }
    }
  }

  // Sub-word read fix: the Wishbone slave only speaks 32-bit words
  // (ADR is word-addressed, DAT_MISO is 32-bit). Renode issues byte,
  // half-word, and word reads at any byte alignment and takes the LOW
  // N bits of whatever we return. If we hand back the full 32-bit word
  // for every request, a byte read at offset +1 returns the byte at
  // offset 0, half-word read at +2 returns the low half, etc.
  // Mismatched bytes then compose into garbled instructions when the
  // CPU fetches compressed code from XIP. Shift the word so low bits
  // correspond to the actual requested slice. Applied uniformly for
  // both cache-hit and miss paths, so g_fetch_cache can stay storing
  // the raw 32-bit word.
  if (g_top->io_wb_CYC && g_top->io_wb_STB && g_top->io_wb_ACK && !g_top->io_wb_WE) {
    const int byte_off = (int)(g_bridge_addr & 3);
    if (byte_off != 0) {
      g_bridge_rd_dat = (g_bridge_rd_dat >> (byte_off * 8));
    }
  }

  if (getenv("BMBXIP_TRACE") && g_top->io_wb_CYC && g_top->io_wb_STB && g_top->io_wb_ACK) {
    fprintf(stderr, "[BMBXIP-TRC2] byte=0x%llx bank=%u we=%d sel=0x%x rd=0x%08x\n",
            (unsigned long long)g_bridge_addr, bank, (int)g_top->io_wb_WE,
            (unsigned)g_dummy_sel, (unsigned)g_bridge_rd_dat);
  }
}

class BmbSpiXipPeripheral : public RenodeAgent {
 public:
  BmbSpiXipPeripheral() : RenodeAgent(), top(nullptr), bus(nullptr), tickCounter(0) {}

  void initialize() {
    DEBUG_PRINT("=== INIT START ===");

    top = new VWishboneBmbSpiXipController();
    g_top = top;

    bus = new Wishbone();
    bus->wb_clk = (uint8_t*)&top->clk;
    bus->wb_rst = (uint8_t*)&top->resetn;
    bus->wb_addr   = &g_bridge_addr;
    bus->wb_rd_dat = &g_bridge_rd_dat;
    bus->wb_wr_dat = &g_bridge_wr_dat;
    bus->wb_we    = (uint8_t*)&top->io_wb_WE;
    bus->wb_sel   = &g_dummy_sel;
    bus->wb_stb   = (uint8_t*)&top->io_wb_STB;
    bus->wb_cyc   = (uint8_t*)&top->io_wb_CYC;
    bus->wb_ack   = (uint8_t*)&top->io_wb_ACK;
    bus->wb_stall = &g_dummy_stall;
    bus->granularity = 1;
    bus->addr_lines = 32;
    bus->evaluateModel = evalModel;
    addBus(bus);

    initFlashRom();
    {
      const char* c = getenv("BMBXIP_FAST");
      g_fast_mode = (c && *c && c[0] != '0');
      invalidateFetchCache();
      if (g_fast_mode) {
        fprintf(stderr, "[BMBXIP] BMBXIP_FAST enabled (idle-skip + fetch cache)\n");
      }
    }
    g_flash.reset();
    g_flash.setBacking(g_flash_rom, sizeof(g_flash_rom));
    g_flash.setDummyCycles(8);
    g_flash.setDeviceId(0x20, 0xBA, 0x18);
#if DEBUG_ENABLE
    g_flash.setDebug(true);
#endif
    g_flash_initialised = true;

    top->io_spi_dq_read = 0xF;
    top->resetn = 0;
    top->clk = 0;
    top->eval();

    for (int i = 0; i < 10; ++i) {
      top->clk = 1; top->eval();
      top->clk = 0; top->eval();
    }

    top->resetn = 1;
    top->clk = 1; top->eval();
    top->clk = 0; top->eval();

    DEBUG_PRINT("=== INIT COMPLETE ===");
  }

  ~BmbSpiXipPeripheral() {
    if (top) { top->final(); delete top; }
    if (bus) { delete bus; }
    g_top = nullptr;
  }

  void tick(bool countEnable, uint64_t steps) override {
    if (!top || steps == 0) return;
    // Idle shortcut (BMBXIP_FAST): see top-of-file comment. Safe when
    // no WB transaction is active and SPI CS is deasserted.
    if (g_fast_mode &&
        !top->io_wb_CYC &&
        (top->io_spi_cs & 1)) {
      if (countEnable) tickCounter += steps;
      return;
    }
    for (uint64_t i = 0; i < steps; ++i) {
      *bus->wb_clk = 1;
      top->eval();
      if (g_flash_initialised) {
        uint8_t cs   = top->io_spi_cs & 1;
        uint8_t sclk = top->io_spi_sclk & 1;
        uint8_t mw   = top->io_spi_dq_write & 0xF;
        uint8_t moe  = top->io_spi_dq_writeEnable & 0xF;
        uint8_t so = 0, soe = 0;
        g_flash.tick(cs, sclk, mw, moe, so, soe);
        top->io_spi_dq_read = combineDq(mw, moe, so, soe);
      }
      *bus->wb_clk = 0;
      top->eval();
      if (g_flash_initialised) {
        uint8_t cs   = top->io_spi_cs & 1;
        uint8_t sclk = top->io_spi_sclk & 1;
        uint8_t mw   = top->io_spi_dq_write & 0xF;
        uint8_t moe  = top->io_spi_dq_writeEnable & 0xF;
        uint8_t so = 0, soe = 0;
        g_flash.tick(cs, sclk, mw, moe, so, soe);
        top->io_spi_dq_read = combineDq(mw, moe, so, soe);
      }
      if (countEnable) tickCounter++;
    }
  }

  void reset() {
    if (!top) return;
    tickCounter = 0;
    invalidateFetchCache();
    *bus->wb_rst = 0;
    for (int i = 0; i < 10; ++i) bus->tick(true, 1);
    *bus->wb_rst = 1;
    bus->tick(true, 1);
  }

 private:
  VWishboneBmbSpiXipController* top;
  Wishbone* bus;
  uint64_t tickCounter;
};

static BmbSpiXipPeripheral* g_peripheral = nullptr;

RenodeAgent* Init() {
  if (!g_peripheral) {
    g_peripheral = new BmbSpiXipPeripheral();
    g_peripheral->connectNative();
    g_peripheral->initialize();
  }
  return g_peripheral;
}

int main(int argc, char** argv) {
  Verilated::commandArgs(argc, argv);
  RenodeAgent* agent = Init();
  agent->simulate();
  return 0;
}
