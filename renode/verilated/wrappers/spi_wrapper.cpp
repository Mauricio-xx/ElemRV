// SPDX-FileCopyrightText: 2025 aesc silicon
//
// SPDX-License-Identifier: CERN-OHL-W-2.0

// SPI Controller Co-simulation wrapper for Renode
// Includes embedded SPI sensor slave for end-to-end SPI validation.
// Sensor registers: 0x00=DevID(0xCD), 0x01=temp(cycling), 0x02=pressure(cycling)
// io_interrupt output: ignored (not connected to CPU in co-sim test).

#include <cstdio>
#include <cstdint>
#include <cstring>
#include "src/buses/wishbone.h"
#include "src/renode_bus.h"
#include "verilated.h"
#include "VWishboneSpiController.h"

#define DEBUG_ENABLE 0

#if DEBUG_ENABLE
  #define DEBUG_PRINT(fmt, ...) do { printf("[SPI] " fmt "\n", ##__VA_ARGS__); fflush(stdout); } while(0)
#else
  #define DEBUG_PRINT(fmt, ...)
#endif

static VWishboneSpiController* g_top = nullptr;

static uint64_t g_bridge_addr    = 0;
static uint64_t g_bridge_rd_dat  = 0;
static uint64_t g_bridge_wr_dat  = 0;

static uint8_t g_dummy_sel = 0xF;
static uint8_t g_dummy_stall = 0;

// --- Embedded SPI Sensor Slave ---
// Simulates a register-addressed SPI sensor on MOSI/MISO lines.
// Sensor activates only when CS[0] is asserted (active-low).
// Protocol: first byte = register address, subsequent bytes = data.
// Register map: 0x00=DevID(0xCD), 0x01=temp(cycling), 0x02=pressure(cycling)

static const uint8_t SENSOR_DEV_ID = 0xCD;
static const int8_t  SENSOR_TEMP_TABLE[] = {20, 21, 22, 23, 24, 23, 22, 21, 20, 19};
static const int8_t  SENSOR_PRES_TABLE[] = {45, 47, 50, 52, 55, 53, 50, 48, 45, 43};
static const int     SENSOR_TABLE_LEN = 10;

struct SpiSensorSlave {
  bool     cs_active;      // true when CS is asserted (low)
  uint8_t  prev_cs;        // previous CS state for edge detection
  uint8_t  prev_sclk;      // previous SCLK state for edge detection
  int      bit_count;      // bits received in current byte
  uint8_t  rx_shift;       // shift register for MOSI → slave
  uint8_t  tx_shift;       // shift register for slave → MISO
  int      byte_count;     // bytes received since CS assert
  uint8_t  reg_addr;       // selected register address
  int      sample_index;   // cycling index into sensor tables

  void reset() {
    cs_active = false;
    prev_cs = 1;
    prev_sclk = 0;
    bit_count = 0;
    rx_shift = 0;
    tx_shift = 0xFF;
    byte_count = 0;
    reg_addr = 0;
    sample_index = 0;
  }

  uint8_t getRegValue(uint8_t addr) {
    switch (addr) {
      case 0x00: return SENSOR_DEV_ID;
      case 0x01: return (uint8_t)SENSOR_TEMP_TABLE[sample_index % SENSOR_TABLE_LEN];
      case 0x02: return (uint8_t)SENSOR_PRES_TABLE[sample_index % SENSOR_TABLE_LEN];
      default:   return 0xFF;
    }
  }

  // Called each clock tick with current SPI pin state.
  // Returns the MISO bit to drive (0 or 1). Uses bit 0 of dq_read[1:0].
  uint8_t tick(uint8_t cs, uint8_t sclk, uint8_t mosi_bit) {
    uint8_t miso_bit = (tx_shift >> 7) & 1;

    // CS edge detection (active-low: falling = assert, rising = deassert)
    if (prev_cs == 1 && cs == 0) {
      // CS asserted
      cs_active = true;
      bit_count = 0;
      byte_count = 0;
      rx_shift = 0;
      tx_shift = 0xFF;
      DEBUG_PRINT("[SENSOR] CS asserted");
    } else if (prev_cs == 0 && cs == 1) {
      // CS deasserted
      if (cs_active) {
        sample_index = (sample_index + 1) % SENSOR_TABLE_LEN;
        DEBUG_PRINT("[SENSOR] CS deasserted, next_sample=%d", sample_index);
      }
      cs_active = false;
    }
    prev_cs = cs;

    if (!cs_active) {
      prev_sclk = sclk;
      return 1; // MISO high when idle
    }

    // SCLK rising edge: sample MOSI, shift out MISO
    if (prev_sclk == 0 && sclk == 1) {
      // Shift in MOSI bit
      rx_shift = (rx_shift << 1) | (mosi_bit & 1);
      bit_count++;

      if (bit_count == 8) {
        // Complete byte received
        if (byte_count == 0) {
          // First byte = register address
          reg_addr = rx_shift;
          tx_shift = getRegValue(reg_addr);
          DEBUG_PRINT("[SENSOR] reg_addr=0x%02X, data=0x%02X", reg_addr, tx_shift);
        } else {
          // Subsequent bytes: auto-increment register
          reg_addr++;
          tx_shift = getRegValue(reg_addr);
          DEBUG_PRINT("[SENSOR] auto-inc reg=0x%02X, data=0x%02X", reg_addr, tx_shift);
        }
        byte_count++;
        bit_count = 0;
        rx_shift = 0;
      }
    }

    // SCLK falling edge: shift out next MISO bit
    if (prev_sclk == 1 && sclk == 0) {
      miso_bit = (tx_shift >> 7) & 1;
      tx_shift <<= 1;
    }

    prev_sclk = sclk;
    return miso_bit;
  }
};

static SpiSensorSlave g_sensor;
static bool g_sensor_initialized = false;

static void copyBridgeAndEval() {
  g_top->io_bus_ADR      = (uint16_t)((g_bridge_addr >> 2) & 0x3FF);
  g_top->io_bus_DAT_MOSI = (uint32_t)(g_bridge_wr_dat);

  // Drive SPI data lines from embedded sensor slave
  if (g_sensor_initialized) {
    uint8_t cs = g_top->io_spi_cs & 1;
    uint8_t sclk = g_top->io_spi_sclk & 1;
    uint8_t mosi = g_top->io_spi_dq_write & 1;  // dq[0] = MOSI
    uint8_t miso = g_sensor.tick(cs, sclk, mosi);
    g_top->io_spi_dq_read = (miso & 1) << 1;    // dq[1] = MISO
  } else {
    g_top->io_spi_dq_read = 0;
  }

  g_top->eval();

  g_bridge_rd_dat = (uint64_t)g_top->io_bus_DAT_MISO;
}

void evalModel() {
  if (!g_top) return;

  copyBridgeAndEval();

  if (g_top->io_bus_WE && g_top->io_bus_ACK &&
      g_top->io_bus_CYC && g_top->io_bus_STB) {
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

class SpiPeripheral : public RenodeAgent {
public:
  SpiPeripheral() : RenodeAgent(), top(nullptr), bus(nullptr), tickCounter(0) {}

  void initialize() {
    DEBUG_PRINT("=== INITIALIZATION START ===");

    top = new VWishboneSpiController();
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

    // Initialize embedded SPI sensor slave
    g_sensor.reset();
    g_sensor_initialized = true;
    top->io_spi_dq_read = 0;

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

  ~SpiPeripheral() {
    if (top) { top->final(); delete top; }
    if (bus) { delete bus; }
    g_top = nullptr;
  }

  void tick(bool countEnable, uint64_t steps) override {
    if (!top || steps == 0) return;

    for (uint64_t i = 0; i < steps; i++) {
      // Drive SPI sensor on clock edges
      if (g_sensor_initialized) {
        uint8_t cs = top->io_spi_cs & 1;
        uint8_t sclk = top->io_spi_sclk & 1;
        uint8_t mosi = top->io_spi_dq_write & 1;
        uint8_t miso = g_sensor.tick(cs, sclk, mosi);
        top->io_spi_dq_read = (miso & 1) << 1;
      } else {
        top->io_spi_dq_read = 0;
      }

      *bus->wb_clk = 1;
      top->eval();

      // Update sensor after rising edge (SPI signals may have changed)
      if (g_sensor_initialized) {
        uint8_t cs = top->io_spi_cs & 1;
        uint8_t sclk = top->io_spi_sclk & 1;
        uint8_t mosi = top->io_spi_dq_write & 1;
        uint8_t miso = g_sensor.tick(cs, sclk, mosi);
        top->io_spi_dq_read = (miso & 1) << 1;
      }

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
  VWishboneSpiController* top;
  Wishbone* bus;
  uint64_t tickCounter;
};

static SpiPeripheral* spiPeripheral = nullptr;

RenodeAgent* Init() {
  if (!spiPeripheral) {
    spiPeripheral = new SpiPeripheral();
    spiPeripheral->connectNative();
    spiPeripheral->initialize();
  }
  return spiPeripheral;
}

int main(int argc, char** argv) {
  Verilated::commandArgs(argc, argv);
  RenodeAgent* agent = Init();
  agent->simulate();
  return 0;
}
