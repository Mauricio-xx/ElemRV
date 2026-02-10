# ElemRV-N (Nitrogen) Platform

ElemRV-N is the FPGA-focused platform variant targeting the Lattice ECP5 (ECPIX5 board) with 64MB HyperRAM and extended peripheral set.

## Specifications

| Feature | Specification |
|---------|--------------|
| ISA | RV32IMC (Integer + Compressed + Multiply) |
| Clock | 20 MHz |
| SRAM | 4 KB |
| Flash | 64 KB |
| HyperRAM | 64 MB |
| GPIO | 20 pins |
| Pinmux | 20 pins |

## Architecture Comparison

| Feature | ElemRV-H | ElemRV-N |
|---------|----------|----------|
| ISA | RV32IC | RV32IMC |
| Clock | 50 MHz | 20 MHz |
| SRAM | 8 KB | 4 KB |
| HyperRAM | - | 64 MB |
| GPIO pins | 12 | 20 |
| Pinmux pins | 12 | 20 |
| SPI Controllers | - | 1 |
| I2C Controllers | 1 | 2 (1 full + 1 lite) |
| UARTs | 1 | 2 (1 full + 1 lite) |

## Memory Map

| Address Range | Size | Peripheral |
|--------------|------|-----------|
| 0x80000000 | 4 KB | SRAM |
| 0x90000000 | 64 MB | HyperRAM |
| 0xA0000000 | 64 KB | Flash |
| 0xF0000000 | 4 KB | GPIO0 |
| 0xF0001000 | 4 KB | I2C0 (full) |
| 0xF0002000 | 4 KB | I2C1 (lite) |
| 0xF0003000 | 4 KB | PIO0 |
| 0xF0004000 | 4 KB | PWM0 |
| 0xF0005000 | 4 KB | SPI0 |
| 0xF0006000 | 4 KB | UART0 (full) |
| 0xF0007000 | 4 KB | UART1 (lite) |
| 0xF0010000 | 4 KB | Pinmux |
| 0xF0020000 | 4 KB | Timer0 |
| 0xF0023000 | 4 KB | HyperBus Config |

## Peripherals

### Shared with ElemRV-H

The following peripherals reuse ElemRV-H RTL:

- **PWM0** - Same 2-channel PWM
- **PIO0** - Same 3-pin programmable I/O
- **I2C0** - Same full-featured I2C
- **UART0** - Same full-featured UART
- **Timer0** - Same machine timer

Libraries: `libpwm.so`, `libpio.so`, `libi2c.so`, `libuart.so`, `libmtimer.so`

### N-Specific Peripherals

#### GPIO0 (20 pins)

Extended GPIO with 20 pins.

**Library**: `libgpio_n.so`

Differences from H:
- 20 pins instead of 12
- Same register interface

#### Pinmux (20 pins)

Extended pinmux for 20-pin package.

**Library**: `libpinmux_n.so`

#### SPI0 Controller

New SPI master controller.

**Features**:
- Master mode operation
- Configurable clock polarity/phase
- Chip select control
- Full-duplex operation

**Library**: `libspi.so`

**Register Map**:
```
0x00 - IP Header
0x04 - Clock prescaler
0x08 - Control
0x0C - Status
0x10 - TX FIFO
0x14 - RX FIFO
0x50 - Command FIFO (custom interface)
```

#### I2C1 (Lite)

Lightweight I2C controller without interrupts.

**Features**:
- Master mode
- Polling-based operation
- Reduced gate count
- No interrupt support

**Library**: `libi2c_lite.so`

#### UART1 (Lite)

Lightweight UART without flow control.

**Features**:
- Basic TX/RX
- No CTS/RTS
- Reduced complexity

**Library**: `libuart_lite.so`

### HyperRAM

64MB external memory via HyperBus interface.

**Note**: In the digital twin, HyperRAM is modeled as simple mapped memory in Renode. No HyperBus protocol simulation.

**Memory Region**: 0x90000000 - 0x93FFFFFF

## Building for ElemRV-N

### Generate RTL

```bash
# Generate all N-specific Verilog
task dt-n-cosim-generate

# Or individually:
docker exec -w /workspace/elemrv elemrv-gui sbt "runMain elemrv_n.test.WishboneGpioNVerilog"
docker exec -w /workspace/elemrv elemrv-gui sbt "runMain elemrv_n.test.WishboneSpiControllerVerilog"
# ... etc
```

Generators produce files in `gen_n/`:
- `gen_n/WishboneGpio.v` - 20-pin GPIO
- `gen_n/WishbonePinmux.v` - 20-pin pinmux
- `gen_n/WishboneSpiController.v` - SPI controller
- `gen_n/WishboneI2cController.v` - Lightweight I2C
- `gen_n/WishboneUart.v` - Lightweight UART

### Build Co-simulation Libraries

```bash
# Build all co-simulation libraries
task dt-n-cosim-build

# Or manually:
cd renode/verilated/wrappers
bash build_n_cosim.sh release
```

Output libraries:
- `libgpio_n.so` - 20-pin GPIO
- `libpinmux_n.so` - 20-pin pinmux
- `libspi.so` - SPI controller
- `libi2c_lite.so` - Lite I2C
- `libuart_lite.so` - Lite UART

Plus shared libraries from H: `libpwm.so`, `libpio.so`, `libi2c.so`, `libuart.so`, `libmtimer.so`

### Build Zephyr Applications

```bash
# Build all N Zephyr apps
task dt-n-zephyr-build
```

## Testing

### Run N Test Suite

```bash
# Full test (generates, builds, tests)
task dt-n-test

# Quick run (assumes artifacts exist)
task dt-n-test-quick
```

### Individual Tests

Tests 31-40 cover ElemRV-N:

| Test | Name | Description |
|------|------|-------------|
| 31 | N Base Platform | N CPU + RAM |
| 32 | N GPIO Co-simulation | 20-pin GPIO RTL |
| 33 | N SPI Co-simulation | SPI controller RTL |
| 34 | N I2C Lite Co-simulation | Lite I2C RTL |
| 35 | N UART Lite Co-simulation | Lite UART RTL |
| 36 | N Pinmux Co-simulation | 20-pin pinmux RTL |
| 37 | N Full Co-simulation | All 10 peripherals |
| 38 | N Pure Verilator | RTL validation |
| 39 | N Zephyr Hello | Basic console |
| 40 | N Zephyr Blinky | LED toggle |

## Platform Files

| File | Purpose |
|------|---------|
| `elemrv_n.repl` | Base platform |
| `elemrv_n_zephyr.repl` | Zephyr support |
| `elemrv_n_cosim_*.repl` | Individual co-sim platforms |
| `elemrv_n_full_cosim.repl` | All 10 peripherals |
| `elemrv_n_spi_sensor.repl` | With SPI sensor |
| `elemrv_n_i2c_sensor.repl` | With I2C sensor |

## Zephyr Board Support Package

### SoC Definition

**SoC**: `elemrv_n_vexriscv`

Adds `RISCV_ISA_EXT_M` compared to ElemRV-H's SoC (enables multiply instructions).

### Board Files

- **Board**: `elemrv_n`
- **DTS**: `riscv32-elemrv-n-vexriscv.dtsi`

### Boot Configuration

XIP (Execute In Place) from Flash:
- Code executes from 64KB Flash (0xA0000000)
- Data stored in 4KB SRAM (0x80000000)
- Tight RAM budget requires small stacks

**Stack Sizes** (reduced for 4KB RAM):
```
main:   512 bytes
idle:   256 bytes
ISR:    512 bytes
```

### Build Commands

```bash
# Build for ElemRV-N
cd software/elemrv-zephyr
west build -b elemrv_n app/hello_world -d build-n-hello

# Multi-thread app
west build -b elemrv_n app/rtos_debug_demo -d build-n-rtos
```

## Sensor Simulation

### I2C Sensor

Uses same SI7021 model as ElemRV-H:

```bash
# Platform with I2C sensor
elemrv_n_i2c_sensor.repl
```

### SPI Sensor

Embedded sensor slave in SPI wrapper:

```
Sensor Register Map:
0x00 - Device ID (0xCD)
0x01 - Temperature (cycling values)
0x02 - Pressure (cycling values)
```

**Custom Zephyr Driver**:

`drivers/spi/spi_nafarr.c` implements Zephyr SPI driver API for nafarr WishboneSpiController.

**Usage**:
```bash
# Platform with SPI sensor
elemrv_n_spi_sensor.repl

# Build firmware
west build -b elemrv_n app/sensor_spi_capture
```

## Debug Configuration

### GDB Debugging

```bash
# Start GDB server
task dt-n-rtos-debug

# Connect GDB
task dt-debug-connect \
    ELF=software/elemrv-zephyr/build-n-rtos-debug-demo/zephyr/zephyr.elf
```

### Limitations vs ElemRV-H

Due to 4KB RAM:

| Feature | ElemRV-H | ElemRV-N |
|---------|----------|----------|
| Auto thread analyzer | Yes | Tight (0.5KB) |
| Zephyr shell | Yes | No (1.5KB) |
| CTF tracing | Marginal | No |
| Multi-thread apps | Yes | Limited |

## Use Cases

ElemRV-N is ideal for:

- **FPGA Prototyping**: ECPIX5 board validation
- **Memory-intensive Apps**: 64MB HyperRAM for data
- **Multi-protocol**: SPI + dual I2C + dual UART
- **Sensor Fusion**: Multiple sensor interfaces
- **IoT Development**: Sensor-to-cloud pipelines

## Known Limitations

1. **4KB RAM**: Very tight for Zephyr
2. **No HyperBus Simulation**: Memory mapped but not protocol-accurate
3. **SPI Pin Names**: Verify `io_spi_dq_0_read`/`io_spi_dq_1_read` after generation
4. **I2C Lite Interrupts**: Omitted in lightweight variant
5. **UART Lite Flow Control**: No CTS/RTS pins

---

**Previous**: [ElemRV-H Platform](elemrv-h.md)  
**Next**: [Co-simulation Guide](../features/co-simulation.md)
