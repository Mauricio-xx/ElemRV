# Taskfile Commands Reference

Complete reference for all Taskfile commands available in the ElemRV Digital Twin project.

## Installation and Setup

### Project Installation

```bash
task install
```

**Description**: Initial project setup.  
**Actions**:
- Creates Python virtual environment
- Installs podman-compose
- Downloads repo tool
- Initializes manifest
- Synchronizes submodules  
**Run once**: Yes

### Container Build

```bash
task build-container
```

**Description**: Builds the development Docker container.  
**Includes**:
- Renode 1.16.0
- Verilator 5.x
- SBT (Scala build tool)
- RISC-V GCC toolchain
- Zephyr SDK  
**Run once**: Yes, or when Dockerfile changes

### Repository Sync

```bash
task repo-sync
```

**Description**: Synchronizes all Git submodules.  
**Updates**:
- nafarr hardware library
- zibal platform framework
- Other dependencies

## Digital Twin - General

### Build Firmware

```bash
task dt-build-firmware
```

**Description**: Compiles all bare-metal firmware.  
**Outputs**:
- `digital-twin/firmware/pwm_test/pwm_test.bin`
- `digital-twin/firmware/pwm_test/pwm_test.elf`
- `digital-twin/firmware/pwm_test/pwm_regtest.bin`
- Other test firmware

### Build Verilated Libraries

```bash
task dt-build-verilated
```

**Description**: Builds PWM co-simulation library only.  
**Output**: `digital-twin/renode/verilated/libs/libpwm.so`

## Digital Twin - ElemRV-H

### Generate RTL (H)

```bash
task dt-cosim-generate
```

**Description**: Generates all H peripheral Verilog from SpinalHDL.  
**Generates**:
- `digital-twin/gen/WishboneGpio.v`
- `digital-twin/gen/WishboneI2cController.v`
- `digital-twin/gen/WishboneUart.v`
- `digital-twin/gen/WishboneMachineTimer.v`
- `digital-twin/gen/WishbonePio.v`
- `digital-twin/gen/WishbonePinmux.v`  
**Requires**: SBT in Docker container

### Build Co-simulation Libraries (H)

```bash
task dt-cosim-build
```

**Description**: Builds all 7 H co-simulation shared libraries.  
**Outputs**:
- `libpwm.so`
- `libgpio.so`
- `libi2c.so`
- `libuart.so`
- `libmtimer.so`
- `libpio.so`
- `libpinmux.so`  
**Options**:
```bash
# Release build (default, optimized)
cd digital-twin/renode/verilated/wrappers && bash build_all_cosim.sh release

# Debug build (verbose logging)
cd digital-twin/renode/verilated/wrappers && bash build_all_cosim.sh debug
```

### Run Tests (H)

```bash
task dt-test
```

**Description**: Full test with rebuild.  
**Dependencies**:
- dt-build-firmware
- dt-build-verilated
**Runs**: Tests 1-30

```bash
task dt-test-quick
```

**Description**: Run tests without rebuilding (faster).  
**Requires**: Artifacts already exist

### Zephyr Integration (H)

```bash
task dt-zephyr-init
```

**Description**: Initializes Zephyr west workspace.  
**Actions**:
- `west init`
- `west update`  
**Run once**: Yes

```bash
task dt-zephyr-build
```

**Description**: Builds all H Zephyr applications.  
**Apps**:
- hello_world
- blinky
- i2c_scan
- pwm_test
- pio_test
- pinmux_test
- timer_uart_test
- hybrid_pinmux_pwm_test
- hybrid_pio_uart_test
- hybrid_multi_cosim_test
- sensor_capture
- rtos_debug_demo
- rtos_diagnostics
- sensor_i2c_capture
- portable_data_logger

```bash
task dt-zephyr-test
```

**Description**: Builds Zephyr apps and runs full test suite.  
**Dependencies**:
- dt-build-firmware
- dt-cosim-build
- dt-zephyr-build

### Full Integration Test

```bash
task dt-integration-test
```

**Description**: Complete build and test of all 63 tests.  
**Dependencies**:
- dt-build-firmware
- dt-cosim-build
- dt-zephyr-build  
**Duration**: 5-10 minutes  
**Outputs**: Test results to console and logs

### Verilator Validation

```bash
task dt-verilator-test
```

**Description**: Runs pure Verilator testbenches (no Renode).  
**Location**: `digital-twin/renode/verilated/testbenches/`  
**Validates**: RTL correctness independently

```bash
task dt-validate-cosim
```

**Description**: Cross-validates Verilator vs co-simulation results.  
**Dependencies**: dt-cosim-build  
**Validates**: Consistency between simulation methods

## Digital Twin - ElemRV-N

### Generate RTL (N)

```bash
task dt-n-cosim-generate
```

**Description**: Generates all N-specific peripheral Verilog.  
**Generates**:
- `digital-twin/gen_n/WishboneGpio.v` (20 pins)
- `digital-twin/gen_n/WishbonePinmux.v` (20 pins)
- `digital-twin/gen_n/WishboneSpiController.v`
- `digital-twin/gen_n/WishboneI2cController.v`
- `digital-twin/gen_n/WishboneUart.v`

### Build Co-simulation Libraries (N)

```bash
task dt-n-cosim-build
```

**Description**: Builds all 5 N-specific co-simulation libraries.  
**Outputs**:
- `libgpio_n.so`
- `libpinmux_n.so`
- `libspi.so`
- `libi2c_lite.so`
- `libuart_lite.so`  
**Note**: Also uses H libraries for shared peripherals

### Build Zephyr Apps (N)

```bash
task dt-n-zephyr-build
```

**Description**: Builds all N Zephyr applications.  
**Apps**:
- hello_world
- blinky
- rtos_debug_demo
- rtos_diagnostics
- sensor_i2c_capture
- sensor_spi_capture
- portable_data_logger

### Run Tests (N)

```bash
task dt-n-test
```

**Description**: Full N test suite with rebuild.  
**Dependencies**:
- dt-n-cosim-build
- dt-n-zephyr-build  
**Runs**: Tests 31-40

```bash
task dt-n-test-quick
```

**Description**: Run N tests without rebuild.  
**Requires**: Artifacts already exist

## Debugging Commands

### GDB Server

```bash
# Bare-metal debugging
task dt-debug-bare-metal

# Zephyr debugging
task dt-debug-zephyr

# Full co-simulation debugging
task dt-debug-cosim

# RTOS debugging (H)
task dt-rtos-debug

# RTOS debugging (N)
task dt-n-rtos-debug
```

**Description**: Starts Renode with GDB server on port 3333.  
**Output**: GDB server waiting for connection

### Connect GDB

```bash
# Default ELF
task dt-debug-connect

# Custom ELF
task dt-debug-connect ELF=path/to/firmware.elf
```

**Description**: Connects GDB to running Renode debug session.  
**Requires**: GDB server already running  
**Loads**: `digital-twin/digital-twin/renode/gdb/elemrv.gdb` (convenience commands)

## Sensor and Fault Testing

### Sensor Tests

```bash
task dt-sensor-test
```

**Description**: Runs the full test suite (includes sensor tests 29-30, 47-51).
**Validates**: SI7021 temperature/humidity sensor simulation

```bash
task dt-portable-test
```

**Description**: Runs the full test suite (includes portable data logger tests 50-51).
**Validates**: Same app runs on both H and N

### Multi-Node IoT

```bash
task dt-multi-node
```

**Description**: Runs the multi-node IoT simulation (H edge + N gateway via UART hub).
**Validates**: Cross-machine UART communication, sensor data aggregation

```bash
task dt-multi-node-test
```

**Description**: Builds edge + gateway apps and runs multi-node IoT test (Test 52).
**Dependencies**:
- dt-zephyr-build
- dt-n-zephyr-build

### Fault Injection

```bash
task dt-fault-test
```

**Description**: Runs fault injection tests.  
**Tests**:
- PWM register corruption
- GPIO register corruption
- Timer perturbation
- UART injection
- Missing peripheral

## FPGA and ASIC Commands

### FPGA

```bash
# Generate Verilog for FPGA
task fpga-prepare

# Synthesize
task fpga-synthesize

# Flash FPGA
task fpga-flash

# Simulate
task fpga-simulate duration=10
```

### ASIC

```bash
# Generate for SG13G2
task prepare

# Run simulation
task simulate duration=10

# Create layout
task layout

# Add fillers
task filler

# Run DRC
task run-drc

# Full flow
task
```

## Command Quick Reference

### Essential Commands

| Command | Purpose | Frequency |
|---------|---------|-----------|
| `task install` | Initial setup | Once |
| `task dt-integration-test` | Full test | Daily/CI |
| `task dt-test-quick` | Quick validation | Per change |
| `task dt-debug-cosim` | Debug session | As needed |

### Build Commands

| Command | Target | Output |
|---------|--------|--------|
| `task dt-cosim-build` | H RTL libs | 7 .so files |
| `task dt-n-cosim-build` | N RTL libs | 5 .so files |
| `task dt-zephyr-build` | H apps | Multiple .bin |
| `task dt-n-zephyr-build` | N apps | Multiple .bin |

### Test Commands

| Command | Tests | Duration |
|---------|-------|----------|
| `task dt-test` | 1-30 (H) | 2-3 min |
| `task dt-n-test` | 31-40 (N) | 2-3 min |
| `task dt-integration-test` | 1-52 + 33b-33i (All 60) | 6-12 min |
| `task dt-test-quick` | Cached | 30 sec |

### Debug Commands

| Command | Use Case |
|---------|----------|
| `task dt-debug-bare-metal` | Simple firmware debug |
| `task dt-debug-zephyr` | RTOS app debug |
| `task dt-debug-cosim` | RTL driver debug |
| `task dt-rtos-debug` | Thread debugging |
| `task dt-debug-connect` | GDB connection |

## Environment Variables

### Docker Settings

```bash
# Container name (default: elemrv_container)
export CONTAINER_NAME=my_container

# Run headless (no GUI)
export IS_HEADLESS=true
```

### Build Settings

```bash
# Build mode: debug or release
export BUILD_MODE=release

# SOC variant: ElemRV-H or ElemRV-N
export SOC=ElemRV-H
```

### Zephyr Settings

```bash
# Zephyr base directory
export ZEPHYR_BASE=/workspace/elemrv/software/zephyr

# Zephyr SDK
export ZEPHYR_SDK_INSTALL_DIR=/opt/zephyr-sdk-0.17.0
```

## Common Workflows

### Initial Setup

```bash
task install
task build-container
task repo-sync
task dt-zephyr-init
```

### Daily Development

```bash
# Make changes to RTL/firmware

# Quick test
task dt-test-quick

# If failures, debug
task dt-debug-cosim
# ... debug session ...

# Full validation
task dt-integration-test
```

### Adding New Peripheral

```bash
# 1. Generate RTL
docker exec -w /workspace/elemrv elemrv-test sbt \
  "runMain elemrv_h.test.MyPeripheralVerilog"

# 2. Create wrapper
cd digital-twin/renode/verilated/wrappers
# ... create my_wrapper.cpp ...

# 3. Build library
make -f Makefile.my clean all

# 4. Test
cd renode
renode --disable-xwt -e "include @test_my_peripheral.resc"
```

### Continuous Integration

```bash
# CI pipeline
task install
task dt-integration-test

# Check results
if [ $? -eq 0 ]; then
  echo "All tests passed"
else
  echo "Tests failed"
  exit 1
fi
```

## Troubleshooting

### Command Not Found

```bash
# Install task runner
sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d -b ~/.local/bin

# Or use go
go install github.com/go-task/task/v3/cmd/task@latest
```

### Docker Issues

```bash
# Container not running
docker-compose up -d elemrv-test

# Or with podman
venv/bin/podman-compose up -d elemrv-test

# Rebuild container
task build-container
```

### Build Failures

```bash
# Clean and rebuild
rm -rf build/
task dt-cosim-build

# Verbose output
cd digital-twin/renode/verilated/wrappers
make -f Makefile.pwm BUILD_MODE=debug VERBOSE=1
```

---

**Previous**: [Test Suite](test-suite.md)  
**Next**: [Memory Maps](memory-maps.md)
