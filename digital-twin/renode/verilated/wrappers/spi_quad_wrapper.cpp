// SPDX-FileCopyrightText: 2025 aesc silicon
//
// SPDX-License-Identifier: CERN-OHL-W-2.0

// Quad-I/O SPI Controller co-simulation wrapper.
// Binds a behavioral MT25Q-style Quad I/O flash slave (shared
// SpiQioFlashSlave library) to the 4-bit TriStateArray pins of the
// WishboneSpiControllerQuad Verilator model.
//
// Backing ROM: 4 KiB, synthetic pattern rom[i] = i & 0xFF (byte N has
// value N). Software can validate by reading a known offset and
// comparing against the pattern.

#include <cstdio>
#include <cstdint>
#include <cstring>
#include "src/buses/wishbone.h"
#include "src/renode_bus.h"
#include "verilated.h"
#include "VWishboneSpiControllerQuad.h"

#include "../../wrappers/spi_qio_flash_slave.h"

#define DEBUG_ENABLE 0

#if DEBUG_ENABLE
  #define DEBUG_PRINT(fmt, ...) do { printf("[SPIQUAD] " fmt "\n", ##__VA_ARGS__); fflush(stdout); } while(0)
#else
  #define DEBUG_PRINT(fmt, ...)
#endif

static VWishboneSpiControllerQuad* g_top = nullptr;

static uint64_t g_bridge_addr   = 0;
static uint64_t g_bridge_rd_dat = 0;
static uint64_t g_bridge_wr_dat = 0;

static uint8_t g_dummy_sel   = 0xF;
static uint8_t g_dummy_stall = 0;

static SpiQioFlashSlave g_flash;
static bool g_flash_initialised = false;
static uint8_t g_flash_rom[4096];

static void initFlashRom() {
  for (size_t i = 0; i < sizeof(g_flash_rom); ++i) {
    g_flash_rom[i] = (uint8_t)(i & 0xFF);
  }
}

// Compute the 4-bit value to present on io_spi_dq_read given the
// master's and slave's current drives. When the master drives a line
// (writeEnable=1), its own write value is echoed on the read side.
// When only the slave drives, slave's value appears. Otherwise, idle
// high.
static uint8_t combineDq(uint8_t master_write, uint8_t master_oe,
                         uint8_t slave_io, uint8_t slave_oe) {
  uint8_t out = 0;
  for (int n = 0; n < 4; ++n) {
    uint8_t bit = 1u << n;
    if (master_oe & bit) {
      out |= (master_write & bit);
    } else if (slave_oe & bit) {
      out |= (slave_io & bit);
    } else {
      out |= bit;  // idle high
    }
  }
  return out & 0xF;
}

static void copyBridgeAndEval() {
  g_top->io_bus_ADR      = (uint16_t)((g_bridge_addr >> 2) & 0x3FF);
  g_top->io_bus_DAT_MOSI = (uint32_t)(g_bridge_wr_dat);

  if (g_flash_initialised) {
    uint8_t cs           = g_top->io_spi_cs & 1;
    uint8_t sclk         = g_top->io_spi_sclk & 1;
    uint8_t master_write = g_top->io_spi_dq_write & 0xF;
    uint8_t master_oe    = g_top->io_spi_dq_writeEnable & 0xF;
    uint8_t slave_io = 0, slave_oe = 0;
    g_flash.tick(cs, sclk, master_write, master_oe, slave_io, slave_oe);
    g_top->io_spi_dq_read = combineDq(master_write, master_oe, slave_io, slave_oe);
  } else {
    g_top->io_spi_dq_read = 0xF;
  }

  g_top->eval();

  g_bridge_rd_dat = (uint64_t)g_top->io_bus_DAT_MISO;
}

void evalModel() {
  if (!g_top) return;

  copyBridgeAndEval();

  // Read-latch for SPI response FIFO at 0x014 (word addr).
  if (!g_top->io_bus_WE && g_top->io_bus_ACK &&
      g_top->io_bus_CYC && g_top->io_bus_STB &&
      g_top->io_bus_ADR == 0x014) {
    uint32_t rsp = (uint32_t)g_bridge_rd_dat;
    if (rsp & 0x80000000) {
      uint64_t saved_rd_dat = g_bridge_rd_dat;
      g_top->clk = 1; copyBridgeAndEval();
      g_top->clk = 0; copyBridgeAndEval();
      g_bridge_rd_dat = saved_rd_dat;
    }
  }

  // Write-latch: extra cycle so RTL latches during ACK+WE.
  if (g_top->io_bus_WE && g_top->io_bus_ACK &&
      g_top->io_bus_CYC && g_top->io_bus_STB) {
    g_top->clk = 1; copyBridgeAndEval();
    g_top->clk = 0; copyBridgeAndEval();
  }
}

class SpiQuadPeripheral : public RenodeAgent {
 public:
  SpiQuadPeripheral() : RenodeAgent(), top(nullptr), bus(nullptr), tickCounter(0) {}

  void initialize() {
    DEBUG_PRINT("=== INIT START ===");

    top = new VWishboneSpiControllerQuad();
    g_top = top;

    bus = new Wishbone();
    bus->wb_clk = (uint8_t*)&top->clk;
    bus->wb_rst = (uint8_t*)&top->resetn;
    bus->wb_addr   = &g_bridge_addr;
    bus->wb_rd_dat = &g_bridge_rd_dat;
    bus->wb_wr_dat = &g_bridge_wr_dat;
    bus->wb_we    = (uint8_t*)&top->io_bus_WE;
    bus->wb_sel   = &g_dummy_sel;
    bus->wb_stb   = (uint8_t*)&top->io_bus_STB;
    bus->wb_cyc   = (uint8_t*)&top->io_bus_CYC;
    bus->wb_ack   = (uint8_t*)&top->io_bus_ACK;
    bus->wb_stall = &g_dummy_stall;
    bus->granularity = 1;
    bus->addr_lines = 32;
    bus->evaluateModel = evalModel;
    addBus(bus);

    initFlashRom();
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

  ~SpiQuadPeripheral() {
    if (top) { top->final(); delete top; }
    if (bus) { delete bus; }
    g_top = nullptr;
  }

  void tick(bool countEnable, uint64_t steps) override {
    if (!top || steps == 0) return;

    for (uint64_t i = 0; i < steps; ++i) {
      *bus->wb_clk = 1;
      top->eval();

      if (g_flash_initialised) {
        uint8_t cs           = top->io_spi_cs & 1;
        uint8_t sclk         = top->io_spi_sclk & 1;
        uint8_t master_write = top->io_spi_dq_write & 0xF;
        uint8_t master_oe    = top->io_spi_dq_writeEnable & 0xF;
        uint8_t s_io = 0, s_oe = 0;
        g_flash.tick(cs, sclk, master_write, master_oe, s_io, s_oe);
        top->io_spi_dq_read = combineDq(master_write, master_oe, s_io, s_oe);
      }

      *bus->wb_clk = 0;
      top->eval();

      if (g_flash_initialised) {
        uint8_t cs           = top->io_spi_cs & 1;
        uint8_t sclk         = top->io_spi_sclk & 1;
        uint8_t master_write = top->io_spi_dq_write & 0xF;
        uint8_t master_oe    = top->io_spi_dq_writeEnable & 0xF;
        uint8_t s_io = 0, s_oe = 0;
        g_flash.tick(cs, sclk, master_write, master_oe, s_io, s_oe);
        top->io_spi_dq_read = combineDq(master_write, master_oe, s_io, s_oe);
      }

      if (countEnable) tickCounter++;
    }
  }

  void reset() {
    if (!top) return;
    tickCounter = 0;

    *bus->wb_rst = 0;
    for (int i = 0; i < 10; ++i) bus->tick(true, 1);
    *bus->wb_rst = 1;
    bus->tick(true, 1);
  }

 private:
  VWishboneSpiControllerQuad* top;
  Wishbone* bus;
  uint64_t tickCounter;
};

static SpiQuadPeripheral* g_peripheral = nullptr;

RenodeAgent* Init() {
  if (!g_peripheral) {
    g_peripheral = new SpiQuadPeripheral();
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
