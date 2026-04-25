// SPDX-FileCopyrightText: 2025 aesc silicon
//
// SPDX-License-Identifier: CERN-OHL-W-2.0

// PWM Co-simulation wrapper for Renode
// Uses Renode's IntegrationLibrary with Wishbone bus
//
// Design notes:
// 1. Type bridge: Renode Wishbone uses uint64_t* for addr/data, but Verilator
//    model has uint16_t (ADR) and uint32_t (DAT). Bridge variables handle this.
// 2. Write timing: The RTL write condition (_zz_1) requires ACK to be high
//    simultaneously with CYC/STB/WE. ACK is registered (1-cycle delay), so
//    the write actually commits on the cycle AFTER ACK rises. We add an extra
//    posedge eval during writes to ensure the data latches before the Renode
//    Wishbone class drops the control signals.

#include <cstdio>
#include <cstdint>
#include "src/buses/wishbone.h"
#include "src/renode_bus.h"
#include "verilated.h"
#include "VWishbonePwm.h"

#define DEBUG_ENABLE 0

#if DEBUG_ENABLE
  #define DEBUG_PRINT(fmt, ...) do { printf("[PWM] " fmt "\n", ##__VA_ARGS__); fflush(stdout); } while(0)
#else
  #define DEBUG_PRINT(fmt, ...)
#endif

// Global verilated model instance
static VWishbonePwm* g_top = nullptr;

// Bridge variables: uint64_t for Renode <-> native width for Verilator
static uint64_t g_bridge_addr    = 0;
static uint64_t g_bridge_rd_dat  = 0;
static uint64_t g_bridge_wr_dat  = 0;

// Dummy signals for SEL and STALL (not present in RTL)
static uint8_t g_dummy_sel = 0xF;
static uint8_t g_dummy_stall = 0;

// Copy bridge values into Verilator model and evaluate
static void copyBridgeAndEval() {
  // Renode passes byte addresses; RTL expects word address (byte_addr / 4).
  // The RTL does: _zz_2 = {2'd0, io_bus_ADR} <<< 2 to get byte offsets.
  g_top->io_bus_ADR      = (uint16_t)((g_bridge_addr >> 2) & 0x3FF);
  g_top->io_bus_DAT_MOSI = (uint32_t)(g_bridge_wr_dat);

  g_top->eval();

  // Copy read data back to bridge
  g_bridge_rd_dat = (uint64_t)g_top->io_bus_DAT_MISO;
}

// Evaluation function called by Wishbone bus on each clock edge
void evalModel() {
  if (!g_top) return;

  copyBridgeAndEval();

  // Write timing fix: The RTL write condition (_zz_1) requires
  // CYC && STB && ACK && WE all high simultaneously. ACK is registered
  // (rises 1 cycle after CYC&&STB), so on the posedge where ACK first
  // rises, the sequential write block in Verilator has already evaluated
  // with the OLD ACK=0. We need one more posedge to actually latch data.
  //
  // When we detect WE && ACK both high (write acknowledged), inject an
  // extra clock cycle so the write commits before Renode drops the signals.
  if (g_top->io_bus_WE && g_top->io_bus_ACK &&
      g_top->io_bus_CYC && g_top->io_bus_STB) {
    // Extra posedge: data latches into registers
    g_top->clk = 1;
    copyBridgeAndEval();
    g_top->clk = 0;
    copyBridgeAndEval();
    DEBUG_PRINT("[WRITE-LATCH] addr=0x%03X wdata=0x%08X",
                g_top->io_bus_ADR, g_top->io_bus_DAT_MOSI);
  }

  DEBUG_PRINT("[EVAL] addr=0x%03X we=%d wdata=0x%08X rdata=0x%08X ack=%d",
              g_top->io_bus_ADR, g_top->io_bus_WE,
              g_top->io_bus_DAT_MOSI, g_top->io_bus_DAT_MISO,
              g_top->io_bus_ACK);
}

// PWM Peripheral class
class PwmPeripheral : public RenodeAgent {
public:
  PwmPeripheral() : RenodeAgent(), top(nullptr), bus(nullptr), tickCounter(0) {}

  void initialize() {
    DEBUG_PRINT("=== INITIALIZATION START ===");

    top = new VWishbonePwm();
    g_top = top;

    bus = new Wishbone();

    // Clock/reset: uint8_t matches directly
    bus->wb_clk = (uint8_t*)&top->clk;
    bus->wb_rst = (uint8_t*)&top->resetn;

    // Address/data: routed through uint64_t bridge variables
    bus->wb_addr   = &g_bridge_addr;
    bus->wb_rd_dat = &g_bridge_rd_dat;
    bus->wb_wr_dat = &g_bridge_wr_dat;

    // Control signals: uint8_t matches directly
    bus->wb_we    = (uint8_t*)&top->io_bus_WE;
    bus->wb_sel   = &g_dummy_sel;
    bus->wb_stb   = (uint8_t*)&top->io_bus_STB;
    bus->wb_cyc   = (uint8_t*)&top->io_bus_CYC;
    bus->wb_ack   = (uint8_t*)&top->io_bus_ACK;
    bus->wb_stall = &g_dummy_stall;

    if (!bus->areSignalsConnected()) {
      DEBUG_PRINT("ERROR: Not all signals are connected!");
    }

    // addr_lines=32: Renode passes full byte address unchanged.
    // evalModel() converts to word address for the RTL.
    bus->granularity = 1;
    bus->addr_lines = 32;

    bus->evaluateModel = evalModel;
    addBus(bus);

    // Initial reset (active-low in RTL)
    top->resetn = 0;
    top->clk = 0;
    top->eval();

    for (int i = 0; i < 10; i++) {
      top->clk = 1; top->eval();
      top->clk = 0; top->eval();
    }

    top->resetn = 1;
    top->clk = 1; top->eval();
    top->clk = 0; top->eval();

    DEBUG_PRINT("=== INITIALIZATION COMPLETE ===");
  }

  ~PwmPeripheral() {
    if (top) { top->final(); delete top; }
    if (bus) { delete bus; }
    g_top = nullptr;
  }

  void tick(bool countEnable, uint64_t steps) override {
    if (!top || steps == 0) return;

    for (uint64_t i = 0; i < steps; i++) {
      *bus->wb_clk = 1;
      top->eval();
      *bus->wb_clk = 0;
      top->eval();

      if (countEnable) tickCounter++;
    }
  }

  void reset() {
    if (!top) return;
    tickCounter = 0;

    *bus->wb_rst = 0;
    for (int i = 0; i < 10; i++) bus->tick(true, 1);
    *bus->wb_rst = 1;
    bus->tick(true, 1);
  }

private:
  VWishbonePwm* top;
  Wishbone* bus;
  uint64_t tickCounter;
};

static PwmPeripheral* pwmPeripheral = nullptr;

RenodeAgent* Init() {
  if (!pwmPeripheral) {
    pwmPeripheral = new PwmPeripheral();
    pwmPeripheral->connectNative();
    pwmPeripheral->initialize();
  }
  return pwmPeripheral;
}

int main(int argc, char** argv) {
  Verilated::commandArgs(argc, argv);
  RenodeAgent* agent = Init();
  agent->simulate();
  return 0;
}
