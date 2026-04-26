# Test Suite Reference

Complete documentation of the ElemRV Digital Twin test suite. The suite was trimmed in v1.4 from 63 to 36 tests before the upstream PR; the cuts removed redundant variants (multi-board sensor copies, peripheral-driver Zephyr apps subsumed by per-peripheral co-sim, exploratory XIP tests folded into 33g/33i/33j, multi-node IoT demo, hybrid platform variants beyond `Hybrid Multi-Cosim`). Original sequential test numbering is preserved for traceability against `digital-twin/renode/run_tests.sh`. Per-test detail for the Phase G/I additions also lives in [platforms/elemrv-n.md](../platforms/elemrv-n.md#individual-tests).

## Test Organization

| Range | Category | Count |
|-------|----------|-------|
| 1-2 | Base platform + PWM bare-metal co-sim | 2 |
| 3, 4, 6, 18 | Zephyr H apps (hello, blinky, PWM, timer-UART) | 4 |
| 9, 10, 12, 13, 14 | Per-peripheral H co-sim | 5 |
| 15, 16 | Full H integration + multi-peripheral register sequence | 2 |
| 21 | Hybrid Multi-Cosim (LiteX UART/Timer + co-sim periph) | 1 |
| 22-23 | Pure Verilator H + GDB server validation | 2 |
| 24, 28 | Fault injection: PWM corruption + missing peripheral | 2 |
| 30 | I2C sensor capture (H) | 1 |
| 31-33, 34-37 | N base + per-peripheral co-sim + full integration | 8 |
| 33b, 33g, 33i, 33j | Phase G + Phase I XIP path | 4 |
| 38, 39 | Pure Verilator N + N Zephyr hello world | 2 |
| 41, 43 | RTOS debug demo + GDB threads (H) | 2 |
| 49 | N SPI sensor capture | 1 |
| 50 | H portable data logger | 1 |
| **Total** | | **36** |

## Tests 1-2: Base Platform + PWM Co-sim

### Test 1: Base Platform
**Script**: `test_base.resc`
**Pass Marker**: `Base Platform Test PASSED`
**Validates**:
- VexRiscv CPU executes instructions
- RAM read/write operations
- `emulation RunFor` timing

### Test 2: PWM Co-simulation
**Script**: `run_pwm_test.resc`
**Pass Marker**: `PWM Co-simulation Test PASSED`
**Validates**:
- PWM Verilator library loads correctly
- Register read/write through RTL
- IP Header verification (0x00080002)

## Zephyr H Apps

### Test 3: Zephyr Hello World
**Script**: `run_zephyr_hello.resc`
**Pass Marker**: `Zephyr Hello World Test PASSED`
**Validates**: Zephyr kernel boot, UART console output, XIP from Flash

### Test 4: Zephyr Blinky (GPIO+Timer)
**Script**: `run_zephyr_blinky.resc`
**Pass Marker**: `Zephyr Blinky Test PASSED`
**Validates**: GPIO output, Timer k_sleep, LED toggle

### Test 6: Zephyr PWM Driver
**Script**: `run_zephyr_pwm.resc`
**Pass Marker**: `Zephyr PWM Driver Test PASSED`
**Validates**: Custom WishbonePwm Zephyr driver

### Test 18: Zephyr Timer-UART Integration
**Script**: `run_zephyr_timer_uart.resc`
**Pass Marker**: `Zephyr Timer-UART Integration Test PASSED`
**Validates**: Interrupt-driven flow, k_timer callback chain, UART log emission

## Per-Peripheral Co-sim (H)

### Test 9: PIO Co-simulation
**Script**: `run_cosim_pio_test.resc`
**Pass Marker**: `PIO Co-simulation Test PASSED`
**Validates**: PIO RTL register access through co-sim wrapper, ConstPool loading

### Test 10: Pinmux Co-simulation
**Script**: `run_cosim_pinmux_test.resc`
**Pass Marker**: `Pinmux Co-simulation Test PASSED`
**Validates**: Pinmux RTL register access, pin-routing config

### Test 12: MachineTimer Co-simulation
**Script**: `run_cosim_mtimer_test.resc`
**Pass Marker**: `MachineTimer Co-simulation Test PASSED`
**Validates**: MachineTimer RTL access, LiteX_Timer_CSR32 (32-bit CSR width)

### Test 13: I2C Co-simulation
**Script**: `run_cosim_i2c_test.resc`
**Pass Marker**: `I2C Co-simulation Test PASSED`
**Validates**: WishboneI2cController RTL register access

### Test 14: UART Co-simulation
**Script**: `run_cosim_uart_test.resc`
**Pass Marker**: `UART Co-simulation Test PASSED`
**Validates**: WishboneUart RTL register access

## Full Integration + Cross-Peripheral (H)

### Test 15: Full Co-simulation Integration
**Script**: `run_cosim_full_test.resc`
**Pass Marker**: `Full Co-simulation Integration Test PASSED`
**Validates**: All 7 H peripherals co-simulated simultaneously, no bus conflicts

### Test 16: Multi-Peripheral Register Sequence
**Script**: `run_cosim_multi_reg_test.resc`
**Pass Marker**: `Multi-Peripheral Register Sequence Test PASSED`
**Validates**: Programming Pinmux/PWM/PIO/GPIO in sequence on full co-sim platform without cross-corruption

## Hybrid

### Test 21: Hybrid Multi-Cosim
**Script**: `run_hybrid_multi_cosim.resc`
**Pass Marker**: `Hybrid Multi-Cosim Integration Test PASSED`
**Validates**: LiteX (behavioral) UART/Timer co-existing with co-sim PWM/PIO/Pinmux on the same bus, Zephyr firmware reads back actual RTL register values

## Pure Verilator + GDB

### Test 22: Pure Verilator Testbenches
**Runner**: `make -C verilated/testbenches run`
**Pass Marker**: `All testbenches PASSED`
**Validates**: Each peripheral's RTL exercised standalone via Verilator (no Renode), independent fidelity check

### Test 23: GDB Server Validation
**Runner**: `bash test_gdb_server.sh`
**Pass Marker**: `GDB_SERVER_TEST PASSED`
**Validates**: Renode `machine StartGdbServer` works, riscv32-elf-gdb attaches, basic commands succeed

## Fault Injection

### Test 24: Fault: PWM Register Corruption
**Script**: `run_fault_pwm_corruption.resc`
**Pass Marker**: `PWM Fault Injection Test PASSED`
**Validates**: Co-sim wrapper does not propagate corrupted register writes; firmware detects expected mismatch

### Test 28: Fault: Missing Peripheral
**Script**: `run_fault_missing_peripheral.resc`
**Pass Marker**: `Missing Peripheral Fault Test PASSED`
**Validates**: Renode reports unmapped-region access cleanly; CPU exception flow recoverable

## Sensor (H)

### Test 30: Sensor Capture
**Script**: `run_sensor_capture.resc`
**Pass Marker**: `Sensor Capture Integration Test PASSED`
**Validates**: I2C sensor model (multiple addresses), Zephyr firmware reads sensor values, log output captured

## ElemRV-N Platform

### Test 31: N Base Platform
**Script**: `run_n_base_test.resc`
**Pass Marker**: `ElemRV-N Base Platform Test PASSED`
**Validates**: N CPU + memory map (RAM 4 KB, HyperRAM 64 MB)

### Test 32: N GPIO Co-simulation
**Script**: `run_n_cosim_gpio_test.resc`
**Pass Marker**: `N GPIO Co-simulation Test PASSED`
**Validates**: WishboneGpio (N variant) RTL access

### Test 33: N SPI Co-simulation
**Script**: `run_n_cosim_spi_test.resc`
**Pass Marker**: `N SPI Co-simulation Test PASSED`
**Validates**: WishboneSpiController RTL access (single-mode SPI)

### Test 33b: N SPI Quad Flash Co-simulation (Phase G.1b)
**Script**: `run_n_cosim_spi_quad_flash_test.resc`
**Pass Marker**: `N SPI Quad Flash Co-simulation Test PASSED`
**Validates**: WishboneSpiControllerQuad + MT25Q-style behavioral flash slave; RDID, Fast Read single, Quad I/O Fast Read; response-FIFO bytes asserted

### Test 33g: N BMB SpiXip Image-Container Boot (Phase G.2)
**Script**: `run_n_bmb_spi_xip_boot_test.resc`
**Pass Marker**: `N BMB SpiXip Image-Container Boot Flow Test PASSED`
**Validates**: `gen_dt_image_container.sh`-padded boot image loaded into flash backing via `BMBXIP_IMAGE_PATH`; XIP reads through `BmbSpiXipController` return image bytes

### Test 33i: N CPU-Driven XIP Bootrom-Adapted (Phase I)
**Script**: `run_n_cpu_xip_bootrom_test.resc`
**Pass Marker**: `CPU-Driven XIP Bootrom-Adapted Test PASSED`
**Validates**: Trimmed `software/elemrv_n/bootrom/start.s` runs from XIP via `cpu RegisterAccessFlags ... true`; jal/ret + cfgXip-bank writes; x20 register state and RAM marker. `BMBXIP_FAST=1` enabled (idle-tick shortcut + fetch cache, both correctness-preserving).

### Test 33j: N XIP c.jal Sub-Word Regression Harness (Gap 3.2 #3)
**Script**: `run_xip_cjal_repro.resc`
**Pass Marker**: `XIP c.jal Sub-Word Regression Test PASSED`
**Validates**: 9-scenario harness: `byte_off` ∈ {0,1,2,3} via instruction fetch (c.jal/c.nop-shim/uncompressed jal at word+2) and data loads (lw/lhu/lbu at word+0/+1/+2/+3). Mutation-verified: wrapping the wrapper's sub-word shift in `if (false && ...)` crashes the CPU and kills the marker.

### Test 34: N I2C Lite Co-simulation
**Script**: `run_n_cosim_i2c_lite_test.resc`
**Pass Marker**: `N I2C Lite Co-simulation Test PASSED`
**Validates**: WishboneI2cLite (N variant) register access

### Test 35: N UART Lite Co-simulation
**Script**: `run_n_cosim_uart_lite_test.resc`
**Pass Marker**: `N UART Lite Co-simulation Test PASSED`
**Validates**: WishboneUartLite (N variant) register access

### Test 36: N Pinmux Co-simulation
**Script**: `run_n_cosim_pinmux_test.resc`
**Pass Marker**: `N Pinmux Co-simulation Test PASSED`
**Validates**: WishbonePinmux (N variant) register access

### Test 37: N Full Co-simulation Integration
**Script**: `run_n_cosim_full_test.resc`
**Pass Marker**: `N Full Co-simulation Test PASSED`
**Validates**: All 5 N peripherals co-simulated simultaneously

### Test 38: N Pure Verilator Testbenches
**Runner**: `make -C verilated/testbenches -f Makefile.nitrogen run`
**Pass Marker**: `All N testbenches PASSED`
**Validates**: Each N peripheral's RTL exercised standalone via Verilator

### Test 39: N Zephyr Hello World
**Script**: `run_n_zephyr_hello.resc`
**Pass Marker**: `N Zephyr Hello World Test PASSED`
**Validates**: Zephyr boots on `elemrv_n` board, UART console output

## RTOS Debugging

### Test 41: RTOS Debug Demo (H)
**Script**: `run_rtos_debug_demo_test.resc`
**Pass Marker**: `RTOS Debug Demo Test PASSED`
**Validates**: Multi-thread Zephyr app runs, Renode thread analyzer captures kernel state

### Test 43: RTOS GDB Threads (H)
**Script**: `run_rtos_gdb_threads_test.resc`
**Pass Marker**: `RTOS GDB Threads Test PASSED`
**Validates**: Debug symbols present, thread metadata visible to GDB

## Sensor Simulation

### Test 49: N SPI Sensor Capture
**Script**: `run_sensor_spi_n_test.resc`
**Pass Marker**: `Sensor SPI N Test PASSED`
**Validates**: Co-sim SPI controller + embedded SPI sensor slave; firmware reads telemetry over SPI

### Test 50: H Portable Data Logger
**Script**: `run_portable_h_test.resc`
**Pass Marker**: `Portable H Test PASSED`
**Validates**: Multi-thread Zephyr app reads I2C sensor and toggles LED; portability harness for cross-platform sensor code

## Running Tests

### Full Suite

```bash
# All 36 tests (build + test)
task dt-integration-test

# All 36 tests (no rebuild)
task dt-test-quick
```

### Platform-Specific

```bash
# ElemRV-N only
task dt-n-test
```

### Individual Tests

```bash
# Run a single test script
docker exec elemrv-test bash -c 'cd /workspace/elemrv/digital-twin/renode && \
  renode --disable-xwt --console -e "include @run_pwm_test.resc"'
```

## Test Reports

Test results are logged per-test to `/tmp/dt_test_N.log` (inside the Docker container), where N is the runtime test sequence number printed in the header.

The `run_tests.sh` script prints a summary at the end:
```
============================================
  SUMMARY: 36/36 passed
============================================
```

### Exit Codes

| Code | Meaning |
|------|---------|
| 0 | All tests passed |
| 1 | One or more tests failed |

## Adding New Tests

### Test Script Template

```renode
# run_my_test.resc
using sysbus

mach create "my_test"
machine LoadPlatformDescription @platforms/elemrv_h_full_cosim.repl

# Load co-sim libraries if needed
$lib?="/workspace/elemrv/digital-twin/renode/verilated/libs/libpwm.so"
pwm0_cosim SimulationFilePathLinux $lib

# Load firmware
sysbus LoadBinary @firmware.bin 0xA0000000
cpu PC 0xA0000000

# Run
echo "Starting my test"
emulation RunFor "00:00:05.000000"

# Verify result
sysbus ReadDoubleWord 0xF0003000

echo "My Test PASSED"
quit
```

> **Note**: Do not assign `sysbus ReadDoubleWord` results to variables (e.g., `$result=sysbus ReadDoubleWord ...`); this hangs with CoSimulatedPeripheral.

### Test Registration

Add to `digital-twin/renode/run_tests.sh`:

```bash
# Test N: My Test
run_test "My Test Name" "run_my_test.resc" "My Test PASSED"
```

The `run_test` function takes 3 arguments: test name, script path, and pass marker string.

---

**Previous**: [Bare-metal Firmware](../firmware/bare-metal.md)
**Next**: [Taskfile Commands](taskfile-commands.md)
