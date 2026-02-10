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
- **51 Automated Tests**: Full regression test suite via Taskfile

## Platform Variants

| Feature | ElemRV-H | ElemRV-N |
|---------|----------|----------|
| ISA | RV32IC | RV32IMC |
| Clock | 50 MHz | 20 MHz |
| SRAM | 8 KB | 4 KB |
| HyperRAM | - | 64 MB |
| Peripherals | 7 co-sim | 10 co-sim |
| Target | ASIC prototyping | FPGA (ECPIX5) |

## Quick Start

```bash
# Install dependencies (run once)
task install

# Run full integration test suite (51 tests)
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
- [Fault Injection](features/fault-injection.md) - Robustness testing

### Firmware Development
- [Zephyr Setup](firmware/zephyr-setup.md) - Zephyr RTOS configuration
- [Bare-metal Firmware](firmware/bare-metal.md) - Bare-metal development

### Reference
- [Test Suite](reference/test-suite.md) - All 51 tests documented
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

The platform includes 51 automated tests covering:

- **Tests 1-10**: Base platform and single peripheral co-simulation
- **Tests 11-20**: Integration and pure Verilator validation
- **Tests 21-30**: Zephyr RTOS applications
- **Tests 31-40**: ElemRV-N platform and co-simulation
- **Tests 41-46**: RTOS debugging features
- **Tests 47-51**: Sensor simulation and data logging

Run all tests:
```bash
task dt-integration-test
```

## Prerequisites

- Docker with `elemrv-renode:gui` image
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
│   └── tests/              # Test scripts (.resc)
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

**Version**: 1.0  
**Last Updated**: February 2026
