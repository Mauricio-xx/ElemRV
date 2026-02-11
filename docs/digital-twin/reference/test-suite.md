# Test Suite Reference

Complete documentation of all 52 tests in the ElemRV Digital Twin test suite.

## Test Organization

Tests are numbered sequentially in `renode/run_tests.sh`. The ordering reflects the actual script:

| Range | Category | Count |
|-------|----------|-------|
| 1-2 | Base platform + PWM co-sim | 2 |
| 3-8 | Zephyr apps (H) | 6 |
| 9-15 | Co-sim per-peripheral + full integration (H) | 7 |
| 16-21 | Cross-peripheral + hybrid tests | 6 |
| 22-23 | Verilator + GDB validation | 2 |
| 24-28 | Fault injection | 5 |
| 29-30 | Sensor detection + capture (H) | 2 |
| 31-40 | ElemRV-N platform | 10 |
| 41-46 | RTOS debugging (H + N) | 6 |
| 47-51 | Sensor simulation (I2C + SPI + portable) | 5 |
| 52 | Multi-node IoT | 1 |

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

## Tests 3-8: Zephyr Apps (H)

### Test 3: Zephyr Hello World
**Script**: `run_zephyr_hello.resc`
**Pass Marker**: `Zephyr Hello World Test PASSED`
**Validates**: Zephyr kernel boot, UART console output, XIP from Flash

### Test 4: Zephyr Blinky (GPIO+Timer)
**Script**: `run_zephyr_blinky.resc`
**Pass Marker**: `Zephyr Blinky Test PASSED`
**Validates**: GPIO output, Timer k_sleep, LED toggle

### Test 5: Zephyr I2C Scan
**Script**: `run_zephyr_i2c_scan.resc`
**Pass Marker**: `Zephyr I2C Scan Test PASSED`
**Validates**: LiteX I2C driver, address probing

### Test 6: Zephyr PWM Driver
**Script**: `run_zephyr_pwm.resc`
**Pass Marker**: `Zephyr PWM Driver Test PASSED`
**Validates**: Custom WishbonePwm Zephyr driver

### Test 7: Zephyr PIO Driver
**Script**: `run_zephyr_pio.resc`
**Pass Marker**: `Zephyr PIO Driver Test PASSED`
**Validates**: Custom WishbonePio Zephyr driver

### Test 8: Zephyr Pinmux Driver
**Script**: `run_zephyr_pinmux.resc`
**Pass Marker**: `Zephyr Pinmux Driver Test PASSED`
**Validates**: Custom WishbonePinmux Zephyr driver

## Tests 9-15: Co-sim Per-Peripheral (H)

### Test 9: PIO Co-simulation
**Script**: `run_cosim_pio_test.resc`
**Pass Marker**: `PIO Co-simulation Test PASSED`
**Validates**: PIO RTL register verification, 3-pin operation

### Test 10: Pinmux Co-simulation
**Script**: `run_cosim_pinmux_test.resc`
**Pass Marker**: `Pinmux Co-simulation Test PASSED`
**Validates**: Pinmux RTL, 12-pin routing

### Test 11: GPIO Co-simulation
**Script**: `run_cosim_gpio_test.resc`
**Pass Marker**: `GPIO Co-simulation Test PASSED`
**Validates**: GPIO RTL, direction control, pin read/write

### Test 12: MachineTimer Co-simulation
**Script**: `run_cosim_mtimer_test.resc`
**Pass Marker**: `MachineTimer Co-simulation Test PASSED`
**Validates**: mtime counter, mtimecmp comparison

### Test 13: I2C Co-simulation
**Script**: `run_cosim_i2c_test.resc`
**Pass Marker**: `I2C Co-simulation Test PASSED`
**Validates**: I2C master RTL, start/stop conditions

### Test 14: UART Co-simulation
**Script**: `run_cosim_uart_test.resc`
**Pass Marker**: `UART Co-simulation Test PASSED`
**Validates**: UART RTL, baud rate config, TX/RX

### Test 15: Full Co-simulation Integration
**Script**: `run_cosim_full_test.resc`
**Pass Marker**: `Full Co-simulation Integration Test PASSED`
**Validates**: All 7 co-sim libraries loaded simultaneously, no conflicts

## Tests 16-21: Cross-Peripheral + Hybrid

### Test 16: Multi-Peripheral Register Sequence
**Script**: `run_cosim_multi_reg_test.resc`
**Pass Marker**: `Multi-Peripheral Register Sequence Test PASSED`
**Validates**: Sequential register access across all 7 co-sim peripherals

### Test 17: Pinmux+PWM Register Sequence
**Script**: `run_cosim_pinmux_pwm_seq_test.resc`
**Pass Marker**: `Pinmux+PWM Register Sequence Test PASSED`
**Validates**: Pinmux and PWM register interaction

### Test 18: Zephyr Timer-UART Integration
**Script**: `run_zephyr_timer_uart.resc`
**Pass Marker**: `Zephyr Timer-UART Integration Test PASSED`
**Validates**: Interrupt-driven timer + UART output flow

### Test 19: Hybrid Pinmux+PWM
**Script**: `run_hybrid_pinmux_pwm.resc`
**Pass Marker**: `Hybrid Pinmux-PWM Integration Test PASSED`
**Validates**: Co-sim PWM/Pinmux + LiteX UART/Timer

### Test 20: Hybrid PIO+UART
**Script**: `run_hybrid_pio_uart.resc`
**Pass Marker**: `Hybrid PIO-UART Integration Test PASSED`
**Validates**: Co-sim PIO + LiteX UART/Timer

### Test 21: Hybrid Multi-Cosim
**Script**: `run_hybrid_multi_cosim.resc`
**Pass Marker**: `Hybrid Multi-Cosim Integration Test PASSED`
**Validates**: Multiple co-sim peripherals + LiteX UART/Timer

## Tests 22-23: Verilator + GDB

### Test 22: Pure Verilator Testbenches
**Script**: N/A (runs `make -C verilated/testbenches run`)
**Pass Marker**: `All testbenches PASSED`
**Validates**: RTL correctness without Renode, standalone test coverage

### Test 23: GDB Server Validation
**Script**: `test_gdb_server.sh`
**Pass Marker**: `GDB_SERVER_TEST PASSED`
**Validates**: GDB server starts, accepts connections, responds to commands

## Tests 24-28: Fault Injection

### Test 24: Fault: PWM Register Corruption
**Script**: `run_fault_pwm_corruption.resc`
**Pass Marker**: `PWM Fault Injection Test PASSED`
**Validates**: Firmware behavior when PWM period register is corrupted

### Test 25: Fault: GPIO Register Corruption
**Script**: `run_fault_gpio_corruption.resc`
**Pass Marker**: `GPIO Fault Injection Test PASSED`
**Validates**: Firmware behavior when GPIO direction is corrupted

### Test 26: Fault: Timer Perturbation
**Script**: `run_fault_timer_perturb.resc`
**Pass Marker**: `Timer Perturbation Fault Test PASSED`
**Validates**: Firmware behavior when timer interrupt is perturbed

### Test 27: Fault: UART Injection
**Script**: `run_fault_uart_injection.resc`
**Pass Marker**: `UART Fault Injection Test PASSED`
**Validates**: Firmware behavior with injected UART byte

### Test 28: Fault: Missing Peripheral
**Script**: `run_fault_missing_peripheral.resc`
**Pass Marker**: `Missing Peripheral Fault Test PASSED`
**Validates**: Firmware behavior when peripheral is absent (Tag region)

## Tests 29-30: Sensor (H)

### Test 29: I2C Sensor Detection
**Script**: `run_sensor_detect.resc`
**Pass Marker**: `I2C Sensor Detection Test PASSED`
**Validates**: SI7021 presence at I2C address, scan detection

### Test 30: Sensor Capture
**Script**: `run_sensor_capture.resc`
**Pass Marker**: `Sensor Capture Integration Test PASSED`
**Validates**: Dynamic temperature reads, value changes

## Tests 31-40: ElemRV-N Platform

### Test 31: N Base Platform
**Script**: `run_n_base_test.resc`
**Pass Marker**: `ElemRV-N Base Platform Test PASSED`
**Validates**: RV32IMC execution, 4KB RAM

### Test 32: N GPIO Co-simulation
**Script**: `run_n_cosim_gpio_test.resc`
**Pass Marker**: `N GPIO Co-simulation Test PASSED`
**Validates**: 20-pin GPIO RTL

### Test 33: N SPI Co-simulation
**Script**: `run_n_cosim_spi_test.resc`
**Pass Marker**: `N SPI Co-simulation Test PASSED`
**Validates**: SPI controller RTL, command FIFO

### Test 34: N I2C Lite Co-simulation
**Script**: `run_n_cosim_i2c_lite_test.resc`
**Pass Marker**: `N I2C Lite Co-simulation Test PASSED`
**Validates**: Lightweight I2C RTL, polling operation

### Test 35: N UART Lite Co-simulation
**Script**: `run_n_cosim_uart_lite_test.resc`
**Pass Marker**: `N UART Lite Co-simulation Test PASSED`
**Validates**: Lightweight UART RTL, basic TX/RX

### Test 36: N Pinmux Co-simulation
**Script**: `run_n_cosim_pinmux_test.resc`
**Pass Marker**: `N Pinmux Co-simulation Test PASSED`
**Validates**: 20-pin pinmux RTL

### Test 37: N Full Co-simulation Integration
**Script**: `run_n_cosim_full_test.resc`
**Pass Marker**: `N Full Co-simulation Test PASSED`
**Validates**: All 10 co-sim peripherals simultaneously

### Test 38: N Pure Verilator Testbenches
**Script**: N/A (runs `make -C verilated/testbenches -f Makefile.nitrogen run`)
**Pass Marker**: `All N testbenches PASSED`
**Validates**: N-specific RTL correctness

### Test 39: N Zephyr Hello World
**Script**: `run_n_zephyr_hello.resc`
**Pass Marker**: `N Zephyr Hello World Test PASSED`
**Validates**: N Zephyr BSP, RV32IMC support

### Test 40: N Zephyr Blinky
**Script**: `run_n_zephyr_blinky.resc`
**Pass Marker**: `N Zephyr Blinky Test PASSED`
**Validates**: 20-pin GPIO driver on N

## Tests 41-46: RTOS Debugging

### Test 41: RTOS Debug Demo (H)
**Script**: `run_rtos_debug_demo_test.resc`
**Pass Marker**: `RTOS Debug Demo Test PASSED`
**Validates**: Multi-thread creation, thread analyzer output

### Test 42: RTOS Diagnostics (H)
**Script**: `run_rtos_diagnostics_test.resc`
**Pass Marker**: `RTOS Diagnostics Test PASSED`
**Validates**: Auto thread analyzer, logging subsystem

### Test 43: RTOS GDB Threads (H)
**Script**: `run_rtos_gdb_threads_test.resc`
**Pass Marker**: `RTOS GDB Threads Test PASSED`
**Validates**: Debug symbols, thread metadata accessible

### Test 44: N RTOS Debug Demo
**Script**: `run_n_rtos_debug_demo_test.resc`
**Pass Marker**: `N RTOS Debug Demo Test PASSED`
**Validates**: Multi-thread on 4KB RAM

### Test 45: N RTOS Diagnostics
**Script**: `run_n_rtos_diagnostics_test.resc`
**Pass Marker**: `N RTOS Diagnostics Test PASSED`
**Validates**: On-demand analyzer, no shell (RAM constraints)

### Test 46: N RTOS GDB Threads
**Script**: `run_n_rtos_gdb_threads_test.resc`
**Pass Marker**: `N RTOS GDB Threads Test PASSED`
**Validates**: N debug symbols, thread inspection

## Tests 47-51: Sensor Simulation

### Test 47: H I2C Sensor Capture
**Script**: `run_sensor_i2c_h_test.resc`
**Pass Marker**: `Sensor I2C H Test PASSED`
**Validates**: Generic I2C sensor simulation (SI70xx @ 0x48)

### Test 48: N I2C Sensor Capture
**Script**: `run_sensor_i2c_n_test.resc`
**Pass Marker**: `Sensor I2C N Test PASSED`
**Validates**: Same firmware on N board

### Test 49: N SPI Sensor Capture
**Script**: `run_sensor_spi_n_test.resc`
**Pass Marker**: `Sensor SPI N Test PASSED`
**Validates**: Co-sim SPI + embedded sensor slave, custom nafarr driver

### Test 50: H Portable Data Logger
**Script**: `run_portable_h_test.resc`
**Pass Marker**: `Portable H Test PASSED`
**Validates**: Multi-thread I2C sensor + LED + UART on H

### Test 51: N Portable Data Logger
**Script**: `run_portable_n_test.resc`
**Pass Marker**: `Portable N Test PASSED`
**Validates**: Same app on N, 4KB RAM operation

## Test 52: Multi-Node IoT

### Test 52: Multi-Node IoT (H edge + N gateway via UART hub)
**Script**: `run_multi_node.resc`
**Pass Marker**: `Multi-Node IoT Test PASSED`
**Validates**:
- Renode multi-machine simulation (two SoC variants)
- UARTHub cross-machine communication
- I2C sensor reading on edge (H)
- Text protocol parsing (DATA/ACK) on both machines
- Data aggregation and reporting on gateway (N)

## Running Tests

### Full Suite

```bash
# All 52 tests (build + test)
task dt-integration-test

# All 52 tests (no rebuild)
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
docker exec elemrv-test bash -c 'cd /workspace/elemrv/renode && \
  renode --disable-xwt --console -e "include @run_pwm_test.resc"'
```

## Test Reports

Test results are logged per-test to `/tmp/dt_test_N.log` (inside the Docker container), where N is the test number.

The `run_tests.sh` script prints a summary at the end:
```
============================================
  SUMMARY: 52/52 passed
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
$lib?="/workspace/elemrv/renode/verilated/libs/libpwm.so"
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

> **Note**: Do not assign `sysbus ReadDoubleWord` results to variables (e.g., `$result=sysbus ReadDoubleWord ...`) — this hangs with CoSimulatedPeripheral.

### Test Registration

Add to `renode/run_tests.sh`:

```bash
# Test N: My Test
run_test "My Test Name" "run_my_test.resc" "My Test PASSED"
```

The `run_test` function takes 3 arguments: test name, script path, and pass marker string.

---

**Previous**: [Bare-metal Firmware](../firmware/bare-metal.md)
**Next**: [Taskfile Commands](taskfile-commands.md)
