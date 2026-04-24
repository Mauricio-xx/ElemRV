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
- **CPU-Driven XIP Execution**: VexRiscv executes directly from the co-sim XIP DT via tlib's executable-IO flag (Phase I)
- **Sub-word MMIO Read Correctness**: Byte/half-word fetches from a 32-bit word-addressed wrapper validated end-to-end (Gap 1, regression-guarded by test 33j)
- **QPI Handshake Coverage**: Flash slave tracks `EVCR` bit 7 and toggles CMD sampling width; end-to-end cmd=0xE7 quad fetch through `BmbSpiXipController` (Gap 3.2 #2, test 33l)
- **Fetch-Cache Invalidation on cfgXip Writes**: Data-bank cache invalidated whenever the firmware reconfigures the XIP protocol (Gap 3.2 #1, test 33k)
- **63 Automated Tests**: Full regression test suite via Taskfile

## Platform Variants

| Feature | ElemRV-H | ElemRV-N |
|---------|----------|----------|
| ISA | RV32IC | RV32IMC |
| Clock | 50 MHz | 30 MHz peripheral / 60 MHz input |
| SRAM | 8 KB | 4 KB |
| HyperRAM | - | 64 MB |
| Peripherals | 7 co-sim | 10 core co-sim + 3 Phase-G DTs (Quad I/O SPI flash, BMB bridge, BmbSpiXipController) |
| Target | ASIC prototyping | FPGA (ECPIX5) |

## Quick Start

```bash
# Install dependencies (run once)
task install

# Run full integration test suite (63 tests)
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
- [Digital Twin Gap Journey](retrospective/gaps.md) - Post-Phase-I maturation: sub-word fix, mutation audit, QPI, pre-PR hygiene

### Firmware Development
- [Zephyr Setup](firmware/zephyr-setup.md) - Zephyr RTOS configuration
- [Bare-metal Firmware](firmware/bare-metal.md) - Bare-metal development

### Reference
- [Test Suite](reference/test-suite.md) - All 63 tests documented
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
  | Kernel  |              | @ 50/30 MHz      |               |
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

The platform includes 63 automated tests covering:

- **Tests 1-2**: Base platform + PWM co-simulation
- **Tests 3-8**: Zephyr apps (H)
- **Tests 9-15**: Co-sim per-peripheral + full integration (H)
- **Tests 16-21**: Cross-peripheral + hybrid tests
- **Tests 22-23**: Verilator + GDB validation
- **Tests 24-28**: Fault injection
- **Tests 29-30**: Sensor detection + capture (H)
- **Tests 31-40**: ElemRV-N platform
  - **33b-33g** (Phase G): Quad I/O SPI flash + BMB bridge + BmbSpiXipController + image-container boot
  - **33h-33i** (Phase I): CPU-driven XIP execution (tlib executable-IO flag)
  - **33j-33l** (Gap 3.2): sub-word regression harness, fetch-cache invalidate coverage, QPI handshake end-to-end
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

**Version**: 1.3  
**Last Updated**: April 2026

## Changelog

### 1.3 (April 2026) — Gap 3.2 + Gap 4: DT hardening & pre-PR hygiene

Digital-twin maturation pass after Phase I. Fixes one load-bearing wrapper bug, adds end-to-end QPI coverage, and cleans the tree so any future upstream PR passes the CI lint jobs without surprises. No new hardware path; all changes are in wrappers, firmware, tests, and docs.

- **Gap 1 — sub-word MMIO reads** (`bmb_spi_xip_wrapper.cpp`). Our Wishbone slave is 32-bit word-addressed, but Renode's bus framework issues byte and half-word reads at any byte alignment within the peripheral window. The wrapper now shifts `g_bridge_rd_dat` by `(byte_off * 8)` on read ACKs so the low bits always hold the requested slice. Previously mis-attributed to VexRiscv; the fix removes the `.option norvc` workaround from 33i, which now runs with compressed instructions.
- **Gap 2 — `BMBXIP_FAST=1`** (opt-in, default off) cuts 33i wall time from 23.5 s to 10.4 s by shortcutting `tick()` when both the Wishbone bus is idle and SPI CS is deasserted. Full-fidelity path stays the default for CI coverage.
- **Gap 3.1 — Mutation audit**: 8 seeded bugs across `bmb_spi_xip_wrapper.cpp` and `spi_qio_flash_slave.cpp`, scored against 8 tests, surfaced 3 coverage holes (33b unchecked response bytes, XIP DT never issued 0xEB, `invalidateFetchCache()` never reached).
- **Gap 3.2 #1 — Test 33k** (`xip_cache_invalidate`): firmware reads the same XIP word before and after a cfgXip write, asserts the post-write read reflects the new protocol settings. Exposed a missing write-latch extra-posedge in the wrapper (same pattern used by `pwm_wrapper.cpp` and `pio_wrapper.cpp`).
- **Gap 3.2 #4 — Test 33b strengthened**: the Quad I/O flash register-poke test now asserts all 7 response-FIFO bytes in a triple-quoted python block and emits PASS/FAIL accordingly.
- **Gap 3.2 #2 — Test 33l + QPI handshake**: flash slave now tracks `m_qpi_enabled`, captures `EVCR` from `0x61 WRITE_REGISTER`, and switches CMD sampling width on the next transaction. 33l exercises the upstream bootrom's `cfgXip=0x007F0702` end-to-end (cmd=0xE7 quad fetch through the data bank). 33i restored to upstream parity.
- **Gap 3.2 #3 — Test 33j parameterized**: replaces the previous one-shot repro with a 9-scenario harness covering `byte_off` ∈ {0,1,2,3} via instruction fetch (c.jal/c.nop-shim/uncompressed jal at word+2) and data loads (lw/lhu/lbu at word+0/+1/+2/+3). Mutation-verified: wrapping the sub-word shift in `if (false && ...)` crashes the CPU and kills the pass marker.
- **Gap 4 — `reuse lint` + `scalafmt --check hardware/` both clean**. `REUSE.toml` grew 103 lines of path annotations covering the DT tree buckets (Zephyr module, docs, platforms, .resc drivers, firmware build artefacts, generated Verilog, `.gitignore` files). Four DT-added Scala generators reformatted (whitespace only).
- Suite: **60 → 63 tests**. All green.

### 1.2 (April 2026) — Phase I: CPU-driven XIP fetch

- Lifts the "Renode refuses CPU fetch from `CoSimulatedPeripheral`"
  caveat noted in v1.1 by calling
  `cpu RegisterAccessFlags <start> <size> true` in the `.resc` before
  setting `PC`. This flips tlib's `IO_MEM_EXECUTABLE_IO` page flag
  (already used internally for `ArrayMemory`) on the XIP range, so
  VexRiscv can actually fetch and execute instructions arriving
  through the BmbSpiXip RTL. No Renode patch required.
- Two new tests (58 -> 60):
  - Test 33h (`xip_exec_test`): 30-byte straight-line kernel proves
    CPU fetch + execute from XIP (writes 0xCAFEBEEF to RAM). ~0.3 s
    wall time.
  - Test 33i (`xip_bootrom_test`): trimmed variant of
    `software/elemrv_n/bootrom/start.s` running from XIP; validates
    `jal`/`ret` + cfgXip-bank register writes. Requires `.option
    norvc` to sidestep a VexRiscv-IBus + MMIO-fetch interaction that
    misaligns PC after a compressed `c.jal`. ~60 s wall time (~30
    instructions through Verilator).
- Performance ceiling: ~30 instructions-per-wall-second for straight-
  line XIP code, ~0.5 instructions-per-wall-second for branch-heavy
  XIP code. Feasible for short boot kernels; full RTOS boot from XIP
  is still impractical and should stage via RAM.

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
