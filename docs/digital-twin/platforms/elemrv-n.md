# ElemRV-N (Nitrogen) Platform

ElemRV-N is the FPGA-focused platform variant targeting the Lattice ECP5 (ECPIX5 board) with 64MB HyperRAM and extended peripheral set.

## Specifications

| Feature | Specification |
|---------|--------------|
| ISA | RV32IMC (Integer + Compressed + Multiply) |
| Clock | 30 MHz peripheral / 60 MHz input (post tapeout-2026-03 rework) |
| SRAM | 4 KB |
| Flash | 64 KB |
| HyperRAM | 64 MB |
| GPIO | 20 pins |
| Pinmux | 20 pins |

## Architecture Comparison

| Feature | ElemRV-H | ElemRV-N |
|---------|----------|----------|
| ISA | RV32IC | RV32IMC |
| Clock | 50 MHz | 30 MHz peripheral (60 MHz input; new `hyperbus`, `spiXip` clock domains) |
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
| 0xF000A000 | 1 KB | BmbSpiXip cfgSpi bank (IP header, SPI cmd/resp FIFO) |
| 0xF000A400 | 1 KB | BmbSpiXip cfgXip bank (readCommand + trigger; writes here invalidate the fetch cache) |
| 0xF000B000 | 4 KB | BmbSpiXip XIP data bank (executable-IO; CPU fetches through `cpu RegisterAccessFlags ... true`) |

The BmbSpiXip banks are exposed through a single `CoSimulatedPeripheral` that muxes the three internal buses via `ADR[10]` bank selection in the Scala wrapper. The data bank carries CPU instruction fetches once `tlib`'s `IO_MEM_EXECUTABLE_IO` flag is set on the range (Phase I, tests 33h-33i).

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
docker exec -w /workspace/elemrv elemrv-test sbt "runMain elemrv_n.test.WishboneGpioNVerilog"
docker exec -w /workspace/elemrv elemrv-test sbt "runMain elemrv_n.test.WishboneSpiControllerVerilog"
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

Phase G additions (built separately from the core N set):
- `libspi_quad.so` — `WishboneSpiControllerQuad` + behavioral MT25Q flash slave (shared `spi_qio_flash_slave.{h,cpp}` embedded)
- `libbmb_bridge.so` — `WishboneToBmbMaster` + `SimpleBmbRam` round-trip bridge
- `libbmb_spi_xip.so` — Full `BmbSpiXipController`: three-bank wrapper (cfgSpi / cfgXip / data) muxed onto one Wishbone slave; embeds the same flash slave with QPI (`m_qpi_enabled`) support

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

Tests 31-40 cover the original ElemRV-N peripherals:

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

Phase G added six tests for the Quad I/O SPI / XIP / BMB digital twins
(also counted as the N-specific 33b..33g):

| Test | Name | Description |
|------|------|-------------|
| 33b | N SPI Quad Flash Co-simulation | `WishboneSpiControllerQuad` + MT25Q-style flash slave; RDID + FastRead single + Quad I/O FastRead via register pokes |
| 33c | N SPI Quad Flash Bare-Metal | Same DT driven by a C firmware (`renode/firmware/samples/spi_quad_flash_test/`); UART logs RDID + QIO results |
| 33d | N SPI Quad Flash Zephyr | Zephyr app `app/spi_quad_flash` uses `spi_transceive` for RDID and `sys_write32` pokes for QIO |
| 33e | N BMB Bridge Co-simulation | `WishboneToBmbMaster` + `SimpleBmbRam` round-trip validates the BMB transaction path |
| 33f | N BMB SpiXip Co-simulation | Full `BmbSpiXipController` wrap; reads route WB -> BMB -> SPI -> flash -> back |
| 33g | N BMB SpiXip Image Container Boot | `gen_dt_image_container.sh` + `xip_boot_test` image; wrapper env var `BMBXIP_IMAGE_PATH` pre-loads the flash backing; test validates image words via XIP reads |

Phase I added two CPU-fetch-from-XIP tests that lift the 33g caveat (Renode's default refusal to fetch instructions from `CoSimulatedPeripheral` ranges). They enable the executable-IO flag via `cpu RegisterAccessFlags <start> <size> true` — no Renode patch needed.

| Test | Name | Description |
|------|------|-------------|
| 33h | N CPU-Driven XIP Execution | Minimal 30-byte kernel at 0xF000B000 writes 0xCAFEBEEF to RAM@0x80000100; proves CPU fetch + execute from the BmbSpiXip data bank (~0.3 s wall) |
| 33i | N CPU-Driven XIP Bootrom-Adapted | Trimmed `software/elemrv_n/bootrom/start.s` (partial `_init_regs` + `_init_xip` with `CFGXIP_VALUE=0x007F0702` upstream value + marker 0xBEADFACE); exercises `jal`/`ret` control flow through QPI fetches end-to-end (~5-7 s wall with `BMBXIP_FAST=1`) |

Gap 3.2 added three more tests. Together with Gap 3.1's mutation audit, they close the XIP DT coverage holes surfaced after Phase I:

| Test | Name | Description |
|------|------|-------------|
| 33j | N XIP c.jal Sub-Word Regression | 9-scenario harness exercising `bmb_spi_xip_wrapper.cpp`'s sub-word shift across `byte_off` ∈ {0,1,2,3}. Instruction fetch paths (c.jal to word-aligned + word+2 subs, uncompressed jal at word+2 PC, mixed C+uncompressed arithmetic) plus data loads (`lw`/`lhu`/`lbu` at offsets 0/2/1/3). Python block asserts all 9 marker slots. |
| 33k | XIP Cache Invalidate Coverage | Reads the same XIP word before and after a cfgXip bank-1 write. Post-write read must reflect the new protocol settings, which requires `invalidateFetchCache()` to fire on the cfgXip write. Also surfaced (and fixed) a missing write-latch extra-posedge in the wrapper. |
| 33l | N BMB SpiXip Quad I/O Fetch | End-to-end QPI handshake. Writes `cfgXip=0x007F0702` (upstream bootrom value), lets WREN + WRITE_REGISTER + EVCR latch, then asserts subsequent XIP reads return the wrapper's built-in rom pattern through cmd=0xE7 quad fetches. Requires the flash slave's `m_qpi_enabled` handshake. |

## Platform Files

| File | Purpose |
|------|---------|
| `elemrv_n.repl` | Base platform |
| `elemrv_n_zephyr.repl` | Zephyr support |
| `elemrv_n_cosim_*.repl` | Individual co-sim platforms |
| `elemrv_n_full_cosim.repl` | All 10 peripherals |
| `elemrv_n_spi_sensor.repl` | With SPI sensor |
| `elemrv_n_i2c_sensor.repl` | With I2C sensor |
| `elemrv_n_cosim_spi_quad_flash.repl` | Quad I/O SPI + MT25Q flash slave DT (G.1b, tests 33b-33d) |
| `elemrv_n_cosim_bmb_bridge.repl` | Wishbone <-> BMB bridge round-trip DT (G.3, test 33e) |
| `elemrv_n_cosim_bmb_spi_xip.repl` | Full `BmbSpiXipController` DT (G.1c, tests 33f / 33h / 33j / 33k / 33l) |
| `elemrv_n_bmb_spi_xip_boot.repl` | Image-container boot-flow DT (G.2, tests 33g / 33i) |

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
