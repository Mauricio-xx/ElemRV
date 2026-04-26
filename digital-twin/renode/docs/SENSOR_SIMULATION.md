# Sensor Simulation in ElemRV Digital Twin

This document describes the simulated sensor infrastructure for both
ElemRV-H (Hydrogen) and ElemRV-N (Nitrogen) digital twin platforms.

## I2C Sensor (H + N) — Tests 47-48

Both boards share `i2c0` at `0xF0001000` (LiteX I2C controller). A
Renode `Sensors.SI70xx` model is attached at I2C address **0x48**,
providing temperature and humidity readings via the SI7021 protocol.

### Platform Files

| File | Board | Description |
|------|-------|-------------|
| `elemrv_h_i2c_sensor.repl` | H | H Zephyr base + SI70xx @ i2c0 0x48 |
| `elemrv_n_i2c_sensor.repl` | N | N Zephyr base + SI70xx @ i2c0 0x48 |

### Renode Interaction

The H and N I2C sensor platform files are still present (for ad-hoc debugging or follow-up work); the v1.4 slim removed the dedicated I2C sensor capture tests, but the sensor models can still be exercised manually:
```
i2c0.sensor Temperature 28.0
i2c0.sensor Humidity 60.0
```

## SPI Sensor (N only) — Test 49

ElemRV-N has a nafarr `WishboneSpiController` at `0xF0005000`. The SPI
data lines are connected to an **embedded sensor slave** inside the
Verilator co-simulation wrapper (`spi_wrapper.cpp`).

### Architecture

```
Zephyr SPI API
    → spi_nafarr.c (custom driver)
    → nafarr SPI register writes (CMD FIFO at 0x050)
    → Renode co-sim bridge
    → Verilator RTL (WishboneSpiController.v)
    → SPI bus signals (CS, SCLK, MOSI/MISO)
    → Embedded sensor state machine (in spi_wrapper.cpp)
```

### Sensor Register Map

| Register | Address | R/W | Value |
|----------|---------|-----|-------|
| Device ID | 0x00 | R | 0xCD |
| Temperature | 0x01 | R | Cycling: 20,21,22,23,24,23,22,21,20,19 |
| Pressure | 0x02 | R | Cycling: 45,47,50,52,55,53,50,48,45,43 |

### SPI Protocol

1. Assert CS (active-low)
2. Send register address (1 byte, MOSI)
3. Read data bytes (MISO, auto-increment register)
4. Deassert CS (advances sample index)

### Custom Zephyr SPI Driver

`drivers/spi/spi_nafarr.c` implements the Zephyr `spi_driver_api` for
the nafarr WishboneSpiController command-FIFO interface:

- **Command format**: 32-bit writes to register 0x050
  - `[29:28]` = mode (00=DATA, 01=CS, 10=DUMMY)
  - DATA: `[24]`=read_flag, `[7:0]`=data byte
  - CS: `[24]`=enable, `[3:0]`=cs_index
- **Response**: Read from 0x050, `[31]`=valid bit, `[7:0]`=data

### Platform File

`elemrv_n_spi_sensor.repl` — N Zephyr base with co-simulated SPI controller.

### Building

```bash
# Rebuild libspi.so with embedded sensor
cd renode/verilated/wrappers
make -f Makefile.spi BUILD_MODE=release

# Build Zephyr app
cd software/elemrv-zephyr
west build -b elemrv_n app/sensor_spi_capture -d build-n-sensor-spi-capture
```

## Portable Data Logger (H + N) — Tests 50-51

A single multi-threaded Zephyr application running on both boards with
zero `#ifdef`, proving BSP abstraction.

### Threads

| Thread | Stack | Priority | Function |
|--------|-------|----------|----------|
| main | default | 0 | Init I2C sensor, start threads, wait |
| sensor_thread | 384B | 5 | Read temp+hum every 200ms |
| reporter_thread | 384B | 6 | Print data with timestamps every 500ms |

### Features

- I2C sensor reads (generic sensor @ i2c0 0x48)
- GPIO LED heartbeat toggle (`DT_ALIAS(led0)`)
- UART output with `k_uptime_get()` timestamps
- Thread analyzer report every 5th cycle

### Platform Files

Uses `elemrv_{h,n}_i2c_sensor.repl` from Phase 7.
