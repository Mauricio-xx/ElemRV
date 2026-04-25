// SPDX-FileCopyrightText: 2025 aesc silicon
//
// SPDX-License-Identifier: CERN-OHL-W-2.0

// Simple Wishbone Test Wrapper with Printf Debugging

#include <cstdio>
#include <cstdint>
#include <cstdarg>
#include "src/buses/wishbone.h"
#include "src/renode_bus.h"
#include "verilated.h"
#include "VSimpleWishboneReg.h"

// Debug configuration
#define DEBUG_ENABLE 1

#if DEBUG_ENABLE
  #define DEBUG_PRINT(fmt, ...) do { printf("[SIMPLE_WB] " fmt "\n", ##__VA_ARGS__); fflush(stdout); } while(0)
#else
  #define DEBUG_PRINT(fmt, ...)
#endif

// Global verilated model instance
static VSimpleWishboneReg* g_top = nullptr;

// Dummy signals for SEL and STALL (not present in RTL)
static uint8_t g_dummy_sel = 0xF;
static uint8_t g_dummy_stall = 0;

// Evaluation function for bus
void evalModel() {
  if (g_top) {
    g_top->eval();
    
    // Debug: print signal state when transaction is active
    static bool in_transaction = false;
    static int transaction_evals = 0;
    
    if (g_top->io_bus_CYC) {
      if (!in_transaction) {
        in_transaction = true;
        transaction_evals = 0;
        DEBUG_PRINT("[TRANSACTION START]");
      }
      transaction_evals++;
      if (transaction_evals <= 10 || transaction_evals % 100 == 0) {
        DEBUG_PRINT("[EVAL %d] cyc=%d stb=%d we=%d addr=0x%X wdata=0x%X rdata=0x%X ack=%d", 
                    transaction_evals,
                    g_top->io_bus_CYC, 
                    g_top->io_bus_STB, 
                    g_top->io_bus_WE,
                    g_top->io_bus_ADR,
                    g_top->io_bus_DAT_MOSI,
                    g_top->io_bus_DAT_MISO,
                    g_top->io_bus_ACK);
      }
    } else {
      if (in_transaction) {
        in_transaction = false;
        DEBUG_PRINT("[TRANSACTION END] Total evals: %d", transaction_evals);
      }
      // Debug: print when waiting for ACK to go low
      static int wait_low_count = 0;
      if (g_top->io_bus_ACK && wait_low_count < 10) {
        wait_low_count++;
        DEBUG_PRINT("[WAIT ACK LOW %d] cyc=%d stb=%d ack=%d", 
                    wait_low_count, g_top->io_bus_CYC, g_top->io_bus_STB, g_top->io_bus_ACK);
      }
    }
  }
}

// Simple WB Peripheral class
class SimpleWbPeripheral : public RenodeAgent {
public:
  SimpleWbPeripheral() : RenodeAgent(), top(nullptr), bus(nullptr) {
    DEBUG_PRINT("Constructor called");
  }
  
  void initialize() {
    DEBUG_PRINT("=== INITIALIZATION START ===");
    
    // Create verilated model
    top = new VSimpleWishboneReg();
    g_top = top;
    DEBUG_PRINT("Verilated model created");
    
    // Create and configure Wishbone bus
    bus = new Wishbone();
    DEBUG_PRINT("Wishbone bus created");
    
    // Connect Wishbone signals
    bus->wb_clk = (uint8_t*)&top->clk;
    bus->wb_rst = (uint8_t*)&top->resetn;
    bus->wb_addr = (uint64_t*)&top->io_bus_ADR;
    bus->wb_rd_dat = (uint64_t*)&top->io_bus_DAT_MISO;
    bus->wb_wr_dat = (uint64_t*)&top->io_bus_DAT_MOSI;
    bus->wb_we = (uint8_t*)&top->io_bus_WE;
    bus->wb_sel = &g_dummy_sel;
    bus->wb_stb = (uint8_t*)&top->io_bus_STB;
    bus->wb_cyc = (uint8_t*)&top->io_bus_CYC;
    bus->wb_ack = (uint8_t*)&top->io_bus_ACK;
    bus->wb_stall = &g_dummy_stall;
    
    DEBUG_PRINT("Signals mapped");
    
    // Verify all signals are connected
    if (!bus->areSignalsConnected()) {
      DEBUG_PRINT("ERROR: Not all signals are connected!");
    } else {
      DEBUG_PRINT("All signals connected successfully");
    }
    
    // Set bus parameters
    bus->granularity = 1;
    bus->addr_lines = 32;
    DEBUG_PRINT("Bus parameters: granularity=%d addr_lines=%d", 
                bus->granularity, bus->addr_lines);
    
    // Connect evaluation function
    bus->evaluateModel = evalModel;
    DEBUG_PRINT("Evaluation function connected");
    
    // Add bus to agent
    addBus(bus);
    DEBUG_PRINT("Bus added to agent");
    
    // Perform initial reset (active-low)
    top->resetn = 0;
    top->clk = 0;
    top->eval();
    
    // Run a few clock cycles
    for (int i = 0; i < 10; i++) {
      top->clk = 1; top->eval();
      top->clk = 0; top->eval();
    }
    
    // Release reset
    top->resetn = 1;
    top->clk = 1; top->eval();
    top->clk = 0; top->eval();
    
    DEBUG_PRINT("Initial reset complete");
    DEBUG_PRINT("=== INITIALIZATION COMPLETE ===");
  }
  
  ~SimpleWbPeripheral() {
    DEBUG_PRINT("Destructor called");
    if (top) {
      top->final();
      delete top;
    }
    if (bus) {
      delete bus;
    }
    g_top = nullptr;
  }
  
  // Override reset to handle active-low reset correctly
  void reset() {
    DEBUG_PRINT("=== RESET START (wrapper) ===");
    
    // The RTL has active-low reset (resetn), but IntegrationLibrary expects active-high
    // So we handle the reset sequence manually here
    
    // Assert reset (set resetn=0 for active-low)
    *bus->wb_rst = 0;
    
    // Run clock cycles
    for (int i = 0; i < 10; i++) {
      *bus->wb_clk = 1;
      evalModel();
      *bus->wb_clk = 0;
      evalModel();
    }
    
    // Release reset (set resetn=1 for active-low)
    *bus->wb_rst = 1;
    *bus->wb_clk = 1;
    evalModel();
    *bus->wb_clk = 0;
    evalModel();
    
    DEBUG_PRINT("=== RESET COMPLETE (wrapper) ===");
    
    // Don't call parent reset() - it would try to toggle wb_rst as active-high
    // RenodeAgent::reset();
  }
  
private:
  VSimpleWishboneReg* top;
  Wishbone* bus;
};

// Global instance
static SimpleWbPeripheral* peripheral = nullptr;

// Required by Renode
RenodeAgent* Init() {
  DEBUG_PRINT("Init() called");
  if (!peripheral) {
    peripheral = new SimpleWbPeripheral();
    peripheral->connectNative();
    peripheral->initialize();
  }
  return peripheral;
}

// Main function
int main(int argc, char** argv) {
  DEBUG_PRINT("Main started");
  Verilated::commandArgs(argc, argv);
  RenodeAgent* agent = Init();
  agent->simulate();
  return 0;
}
