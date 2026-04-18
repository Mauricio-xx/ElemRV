// SPDX-FileCopyrightText: 2025 aesc silicon
//
// SPDX-License-Identifier: CERN-OHL-W-2.0

// Co-simulation wrapper for the Wishbone -> BMB bridge DT
// (WishboneBmbBridge = WishboneToBmbMaster + SimpleBmbRam).
// Renode drives Wishbone; reads/writes should round-trip through BMB
// to the internal 256x32b memory and back.

#include <cstdio>
#include <cstdint>
#include <cstring>
#include "src/buses/wishbone.h"
#include "src/renode_bus.h"
#include "verilated.h"
#include "VWishboneBmbBridge.h"

#define DEBUG_ENABLE 0

#if DEBUG_ENABLE
  #define DEBUG_PRINT(fmt, ...) do { printf("[BMBBRIDGE] " fmt "\n", ##__VA_ARGS__); fflush(stdout); } while(0)
#else
  #define DEBUG_PRINT(fmt, ...)
#endif

static VWishboneBmbBridge* g_top = nullptr;

static uint64_t g_bridge_addr   = 0;
static uint64_t g_bridge_rd_dat = 0;
static uint64_t g_bridge_wr_dat = 0;

static uint8_t g_dummy_sel   = 0xF;
static uint8_t g_dummy_stall = 0;

static void copyBridgeAndEval() {
  // 10-bit word address (256 words = 2^8 words = 0x400 bytes).
  g_top->io_wb_ADR      = (uint16_t)((g_bridge_addr >> 2) & 0x3FF);
  g_top->io_wb_DAT_MOSI = (uint32_t)(g_bridge_wr_dat);

  g_top->eval();
  g_bridge_rd_dat = (uint64_t)g_top->io_wb_DAT_MISO;
}

void evalModel() {
  if (!g_top) return;

  copyBridgeAndEval();

  // The WB->BMB state machine needs multiple bus-clock cycles to issue
  // a BMB command and collect its response. Pump extra cycles while a
  // transaction is outstanding so the ACK can be observed in the same
  // Renode bus cycle.
  if (g_top->io_wb_CYC && g_top->io_wb_STB && !g_top->io_wb_ACK) {
    for (int i = 0; i < 20 && !g_top->io_wb_ACK; ++i) {
      g_top->clk = 1; copyBridgeAndEval();
      g_top->clk = 0; copyBridgeAndEval();
    }
  }
}

class BmbBridgePeripheral : public RenodeAgent {
 public:
  BmbBridgePeripheral() : RenodeAgent(), top(nullptr), bus(nullptr), tickCounter(0) {}

  void initialize() {
    DEBUG_PRINT("=== INIT START ===");

    top = new VWishboneBmbBridge();
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

  ~BmbBridgePeripheral() {
    if (top) { top->final(); delete top; }
    if (bus) { delete bus; }
    g_top = nullptr;
  }

  void tick(bool countEnable, uint64_t steps) override {
    if (!top || steps == 0) return;
    for (uint64_t i = 0; i < steps; ++i) {
      *bus->wb_clk = 1; top->eval();
      *bus->wb_clk = 0; top->eval();
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
  VWishboneBmbBridge* top;
  Wishbone* bus;
  uint64_t tickCounter;
};

static BmbBridgePeripheral* g_peripheral = nullptr;

RenodeAgent* Init() {
  if (!g_peripheral) {
    g_peripheral = new BmbBridgePeripheral();
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
