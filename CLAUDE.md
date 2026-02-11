# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

ElemRV is an open-source RISC-V MCU (VexRiscv RV32IC) written in SpinalHDL, targeting both FPGA (Lattice ECP5 ECPIX5) and ASIC (IHP Open SG13G2 PDK). It includes a **digital twin** layer: cycle-accurate Verilator co-simulation of individual peripherals within Renode system simulation, validated by a 51-test suite running real firmware (bare-metal and Zephyr RTOS).

Two platform variants exist:
- **Hydrogen (H)**: 5 peripherals (GPIO, I2C, PIO, PWM, UART) + Pinmux, 12 I/O pins
- **Nitrogen (N)**: 8 peripherals (GPIO, 2×I2C, PIO, PWM, SPI, 2×UART) + Pinmux, 20 I/O pins

## Build Commands

### SpinalHDL / RTL (host or container)

```bash
sbt compile                                           # Compile Scala/SpinalHDL
sbt "runMain elemrv_h.test.WishbonePwmVerilog"        # Generate single peripheral Verilog into gen/
sbt "runMain elemrv_h.ECPIX5.ECPIX5Generate"          # Generate full SoC Verilog
sbt scalafmt                                          # Format code
sbt scalafmtCheck                                     # Check formatting (CI uses this)
```

### FPGA / ASIC flows (via Taskfile)

```bash
task fpga-prepare                    # Generate Verilog for FPGA
task fpga-synthesize                 # Synthesize bitstream
task                                 # Full ASIC RTL-to-GDSII flow (prepare → layout → filler → DRC)
```

Default SOC is ElemRV-N. Override with `SOC=ElemRV-H task <target>`.

### Digital Twin (all run inside Docker container `elemrv-test`)

```bash
# Setup
task dt-zephyr-init                  # Initialize west workspace + fetch Zephyr

# Build steps
task dt-build-firmware               # Bare-metal PWM test firmware
task dt-cosim-generate               # Generate all H peripheral Verilog via SpinalHDL
task dt-cosim-build                  # Build all 7 H co-sim .so libs
task dt-zephyr-build                 # Build all 15 H Zephyr apps

# Testing
task dt-test-quick                   # Run full 51-test suite (assumes artifacts exist)
task dt-integration-test             # Build everything + run full test suite
task dt-verilator-test               # Pure Verilator testbenches (no Renode)
task dt-validate-cosim               # Cross-validate Verilator vs Renode results

# Nitrogen variant
task dt-n-cosim-generate             # Generate N-specific Verilog
task dt-n-cosim-build                # Build 5 N co-sim libs
task dt-n-zephyr-build               # Build N Zephyr apps
task dt-n-test                       # Full N test suite

# Debugging
task dt-debug-bare-metal             # Renode + GDB server (port 3333)
task dt-debug-zephyr                 # Renode + GDB server for Zephyr
task dt-debug-cosim                  # Renode + GDB server with full RTL co-sim
```

### Building individual co-sim libraries

Inside Docker at `renode/verilated/wrappers/`:
```bash
make -f Makefile.pwm BUILD_MODE=release               # Single peripheral
bash build_all_cosim.sh release                        # All 7 H libs
bash build_n_cosim.sh release                          # All 5 N libs
```

### Building Zephyr apps

Inside Docker at `software/elemrv-zephyr/`:
```bash
bash build_all_apps.sh                                 # All 15 H apps
bash build_n_apps.sh                                   # N apps
west build -b elemrv_h app/hello_world -d build-hello_world   # Single app
```

### Building bare-metal firmware

Inside Docker at `renode/firmware/samples/<name>/`:
```bash
make                                                   # Builds .bin and .elf
```

Or at `software/elemrv_h/pwm_test/`:
```bash
make all         # pwm_test.bin
make regtest     # pwm_regtest.bin
```

## Architecture

### Layer Stack

```
Zephyr RTOS / Bare-metal firmware
        ↓
Renode system simulation (CPU + memory + LiteX peripherals)
        ↓  co-sim bridge (IntegrationLibrary)
Verilator RTL models (.so shared libraries)
        ↑
SpinalHDL → Verilog (gen/*.v)
```

### Hardware RTL (`hardware/scala/`)

- `elemrv_h/ElemRV.scala` / `elemrv_n/ElemRV.scala` — SoC definitions extending `zibal.platform.{Hydrogen,Nitrogen}`. Declare peripherals from `nafarr` library and configure pinmux.
- `*/ECPIX5/` — FPGA board wrapper (50 MHz, 8 KB SRAM, 8 MB HyperRAM, SPI Flash XIP)
- `*/SG13G2/` — ASIC wrapper (IHP SG13G2 PDK, OpenROAD config)
- `*/test/` — Standalone Verilog generators for each peripheral (used by Verilator co-sim)

Key submodules (`modules/elements/`): `nafarr` (peripheral IP library), `zibal` (platform framework + Taskfile), `vexriscv` (CPU core)

### Co-simulation Wrappers (`renode/verilated/wrappers/`)

C++ files bridging Renode's `IntegrationLibrary` Wishbone interface to Verilator models. Each wrapper handles:
- Type bridging: Renode uses `uint64_t*` for addr/data; Verilator uses native widths
- Address conversion: byte addresses → word addresses (`>> 2`)
- Write timing: extra posedge injection when ACK+CYC+STB+WE are all high

### Renode Platform Files (`renode/platforms/`)

`.repl` files defining memory maps and peripheral configurations. Naming convention:
- `elemrv_{h,n}.repl` — base (LiteX models only)
- `elemrv_{h,n}_zephyr.repl` — base for Zephyr (same peripherals, Zephyr firmware paths)
- `elemrv_{h,n}_cosim_<periph>.repl` — single peripheral co-simulated
- `elemrv_{h,n}_full_cosim.repl` — all peripherals co-simulated

Memory map: RAM @ `0x80000000` (8 KB), Flash @ `0xA0000000` (64 KB XIP), Peripherals @ `0xF0000000`

### Zephyr Module (`software/elemrv-zephyr/`)

Out-of-tree Zephyr module (v4.1.0) with custom board, SoC, drivers, and DTS bindings:
- Boards: `boards/aesc/elemrv_{h,n}/`
- SoCs: `soc/aesc/elemrv_vexriscv/` and `elemrv_n_vexriscv/`
- Custom drivers: `drivers/{pwm,pio,pinctrl}/` with DTS bindings in `dts/bindings/`
- Apps: `app/` (hello_world, blinky, i2c_scan, pwm_test, pio_test, pinmux_test, hybrids, etc.)

### Test Runner (`renode/run_tests.sh`)

51-test suite covering: base platform, co-sim per-peripheral, Zephyr apps, cross-peripheral integration, Verilator standalone, GDB server, fault injection, sensor detection/capture, N-variant tests, RTOS debugging, and sensor simulation (I2C + SPI + portable).

## Code Style

- **Scala**: scalafmt 3.2.1, Scala 2.12 dialect, 100-char max, 2-space indent, no alignment
- **SPDX headers required** on every source file:
  ```
  // SPDX-FileCopyrightText: 2025 aesc silicon
  //
  // SPDX-License-Identifier: CERN-OHL-W-2.0
  ```
- **Imports**: group by library (`spinal` → `nafarr` → `zibal` → `elements`), blank line between groups, alphabetical within groups
- **Naming**: packages `lowercase_underscore`, classes/objects `PascalCase`, methods/vals `camelCase`

## Critical Gotchas

### Renode (v1.16.0, headless)
- `cpu Execute` hangs → use `emulation RunFor "HH:MM:SS.ffffff"` (TimeSpan string, not integer)
- `SimulationFilePath` hangs on Linux → use `SimulationFilePathLinux`
- Don't mix `cpu Step` with `emulation RunFor` (corrupts machine state)
- `start` then `emulation RunFor` hangs → RunFor handles start automatically

### Co-sim Wrappers
- Complex peripherals generate `V*__ConstPool_0.cpp` — must compile+link or dlopen fails
- MachineTimer, I2C, UART generators need `defaultClockDomainFrequency = FixedFrequency(50 MHz)` in SpinalConfig
- Pinmux import path: `nafarr.peripherals.pinmux` (not `nafarr.peripherals.io.pinmux`)

### Renode .repl Files
- Multiple `sysbus: init:` blocks → only last one takes effect; merge them into one block
- `CoSimulatedPeripheral` needs `frequency` and `limitBuffer` params

### LiteX CSR Width
- ElemRV uses 32-bit CSR data width → must use `LiteX_Timer_CSR32` (not default `LiteX_Timer` which is 8-bit)
- Wrong model → timer writes garbled → `k_sleep` hangs in Zephyr

### Zephyr
- ElemRV-H is RV32IC (no M extension) → can't reuse upstream `litex_vexriscv` SoC
- 8 KB RAM works only with XIP enabled (code runs from Flash)
- `NUM_IRQS` must be ≥ 12 (VexRiscv interrupt controller uses IRQ numbers up to 11)
- Docker needs `git config --global --add safe.directory "*"` for west in mounted volumes

## CI/CD

- **GitHub Actions `format.yaml`**: Checks `scalafmt` on push/PR to main
- **GitHub Actions `license-check.yaml`**: Runs `reuse lint` on push/PR to main
- **GitHub Actions `digital-twin-tests.yaml`**: Manual dispatch — builds everything in Docker, runs full 51-test suite
- **Travis CI**: ASIC flow (RTL → GDSII → DRC) on PRs and nightly cron
