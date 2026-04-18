# ElemRV Digital Twin Documentation

Hardware-Software Co-simulation Platform for RISC-V Embedded Systems

## Overview

The ElemRV Digital Twin Platform enables firmware development and hardware verification before physical hardware is available. It combines Renode system simulation with cycle-accurate RTL co-simulation using Verilator, allowing developers to test Zephyr RTOS applications against actual Verilog implementations of peripherals.

## Key Features

- **Hardware-Software Co-simulation**: Run Zephyr RTOS against cycle-accurate RTL peripherals
- **Two Platform Variants**: ElemRV-H (Hydrogen) and ElemRV-N (Nitrogen)
- **Sensor Simulation**: I2C and SPI sensor models for IoT application testing
- **RTOS Debugging**: Thread-aware GDB debugging with stack analysis
- **Fault Injection**: Verify firmware robustness through register corruption
- **Multi-Node IoT Simulation**: Two SoC variants communicating over UART
- **Quad I/O SPI Flash + BMB XIP**: Behavioral MT25Q flash slave, `BmbSpiXipController` DT, and image-container boot path (Phase G)
- **58 Automated Tests**: Full regression test suite via Taskfile

## Platform Variants

| Feature | ElemRV-H | ElemRV-N |
|---------|----------|----------|
| ISA | RV32IC | RV32IMC |
| Clock | 50 MHz | 30 MHz peripheral / 60 MHz input |
| SRAM | 8 KB | 4 KB |
| HyperRAM | - | 64 MB |
| Peripherals | 7 co-sim | 10 co-sim + Quad I/O SPI XIP |
| Target | ASIC prototyping | FPGA (ECPIX5) |

## Quick Start

```bash
# Install dependencies (run once)
task install

# Run full integration test suite (58 tests)
task dt-integration-test

# Or step by step:
task dt-cosim-build          # Build co-simulation libraries
task dt-zephyr-build         # Build Zephyr applications
task dt-integration-test     # Run all tests
```

## Documentation Structure

### Getting Started
- [Getting Started Guide](getting-started.md) - First steps and prerequisites
- [Architecture Overview](architecture.md) - How the platform works

### Platform Documentation
- [ElemRV-H (Hydrogen)](platforms/elemrv-h.md) - ASIC-focused platform
- [ElemRV-N (Nitrogen)](platforms/elemrv-n.md) - FPGA-focused platform

### Feature Guides
- [Co-simulation](features/co-simulation.md) - RTL co-simulation explained
- [Sensor Simulation](features/sensors.md) - I2C and SPI sensor testing
- [RTOS Debugging](features/rtos-debugging.md) - Thread-aware debugging
- [GDB Debugging](features/gdb-debugging.md) - Interactive debugging guide
- [Multi-Node IoT](features/multi-node-iot.md) - Multi-machine IoT simulation
- [Fault Injection](features/fault-injection.md) - Robustness testing

### Firmware Development
- [Zephyr Setup](firmware/zephyr-setup.md) - Zephyr RTOS configuration
- [Bare-metal Firmware](firmware/bare-metal.md) - Bare-metal development

### Reference
- [Test Suite](reference/test-suite.md) - All 58 tests documented
- [Taskfile Commands](reference/taskfile-commands.md) - Build and test commands
- [Memory Maps](reference/memory-maps.md) - Peripheral addresses

## Architecture

```
Digital Twin Platform
---------------------

  Firmware (Zephyr)          Renode Simulator         Verilated RTL
  -----------------          ----------------         -------------
       |                            |                         |
       |  System calls              |                         |
       |  (UART, GPIO, etc.)        |                         |
       v                            v                         |
  +---------+              +------------------+               |
  | Zephyr  |              | VexRiscv CPU     |               |
  | Kernel  |              | @ 50/20 MHz      |               |
  +---------+              +------------------+               |
       |                            |                         |
       | Bus transactions           | IntegrationLibrary      |
       v                            v                         v
  +---------+              +------------------+      +---------------+
  | Drivers |------------->| Co-simulation    |<---->| Cycle-accurate|
  | (nafarr)|              | Bridge           |      | Peripheral    |
  +---------+              +------------------+      | RTL           |
                                                     +---------------+
```

## Use Cases

### Firmware Development
Develop and test drivers before hardware is fabricated. The digital twin provides real RTL behavior for register-level driver validation.

### Hardware Verification
Validate peripheral RTL implementations against actual firmware usage patterns. Catch hardware-software interface bugs early.

### Continuous Integration
Automated testing of RTL changes against reference firmware. Regression testing for peripheral modifications via CI/CD.

### Education
Learn embedded systems development with full visibility into both software execution and hardware state.

## Test Coverage

The platform includes 52 automated tests covering:

- **Tests 1-2**: Base platform + PWM co-simulation
- **Tests 3-8**: Zephyr apps (H)
- **Tests 9-15**: Co-sim per-peripheral + full integration (H)
- **Tests 16-21**: Cross-peripheral + hybrid tests
- **Tests 22-23**: Verilator + GDB validation
- **Tests 24-28**: Fault injection
- **Tests 29-30**: Sensor detection + capture (H)
- **Tests 31-40**: ElemRV-N platform
- **Tests 41-46**: RTOS debugging (H + N)
- **Tests 47-51**: Sensor simulation (I2C + SPI + portable)
- **Test 52**: Multi-node IoT (H edge + N gateway)

Run all tests:
```bash
task dt-integration-test
```

## Prerequisites

- Docker with `elemrv-test` image
- 8GB+ RAM recommended for co-simulation
- Linux environment (tested on Ubuntu 22.04)

## Project Structure

```
ElemRV/
├── hardware/scala/          # SpinalHDL RTL sources
│   ├── elemrv_h/           # Hydrogen platform
│   └── elemrv_n/           # Nitrogen platform
├── renode/
│   ├── platforms/          # Platform definition files (.repl)
│   ├── verilated/          # Co-simulation wrappers and libraries
│   ├── run_tests.sh        # Test runner
│   └── *.resc              # Test scripts
├── software/
│   ├── elemrv_h/           # Bare-metal firmware
│   └── elemrv-zephyr/      # Zephyr applications
└── docs/digital-twin/      # This documentation
```

## License

- **RTL**: CERN-OHL-W-2.0
- **Software**: MIT License
- **Documentation**: CC-BY-SA-4.0

## Acknowledgments

- Renode by Antmicro (system simulation framework)
- Verilator by Wilson Snyder (cycle-accurate RTL simulation)
- SpinalHDL (hardware description language)
- Zephyr Project (RTOS)

---

**Version**: 1.1  
**Last Updated**: April 2026

## Changelog

### 1.1 (April 2026) — upstream sync + Phase G

- Merged `aesc-silicon/ElemRV` upstream into the `dev-mont/digital-twin`
  fork. Picks up SpinalHDL 1.13.0, nafarr `1ed0ca2`, zibal `93757cd`,
  VexRiscv `6814d54a`, and the `aesc-silicon` forks of OpenROAD-flow-
  scripts (`ede8b54b`) and IHP-Open-PDK (`64239e24`).
- ElemRV-N peripheral clock moved 20 MHz -> 30 MHz (input 60 MHz),
  with new `hyperbus` and `spiXip` clock domains in the platform.
- Phase G Digital Twin additions (53 -> 58 tests):
  - G.1a: reusable MT25Q-style Quad I/O flash slave C++ library.
  - G.1b.1: `WishboneSpiControllerQuad` generator + Renode register
    test for RDID + Fast Read single + Quad I/O Fast Read.
  - G.1b.2: bare-metal and Zephyr firmware that drive the same DT.
  - G.3: Wishbone <-> BMB bridge DT (`WishboneToBmbMaster` +
    `SimpleBmbRam`) with round-trip verification.
  - G.1c: full `BmbSpiXipController` DT. WB -> BMB bridge -> XIP
    state machine -> SPI master -> behavioral flash.
  - G.2: image-container boot-flow DT. `gen_dt_image_container.sh`
    pads a firmware.bin; `BMBXIP_IMAGE_PATH` loads it into the flash
    slave backing; test validates XIP reads return the image bytes.

### 1.0 (February 2026)

Initial digital-twin release: 52-test suite covering H and N peripheral
co-simulation, Zephyr integration, RTOS debugging, sensor models, and
multi-node IoT simulation.
