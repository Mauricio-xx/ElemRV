# Test Suite Reference

Complete documentation of all 51 tests in the ElemRV Digital Twin test suite.

## Test Organization

| Range | Category | Count |
|-------|----------|-------|
| 1-10 | Base platform and peripherals | 10 |
| 11-20 | Integration and validation | 10 |
| 21-30 | Zephyr RTOS (ElemRV-H) | 10 |
| 31-40 | ElemRV-N platform | 10 |
| 41-46 | RTOS debugging | 6 |
| 47-51 | Sensor simulation | 5 |

## Phase 1: Platform Foundation (Tests 1-10)

### Test 1: Base Platform
**Platform**: `elemrv_h.repl`  
**Purpose**: Verify CPU and RAM functionality  
**Pass Marker**: `Base Platform Test PASSED`  
**Validates**:
- VexRiscv CPU executes instructions
- RAM read/write operations
- Basic system bus operation

### Test 2: PWM Co-simulation
**Platform**: `elemrv_h_cosim_pwm.repl`  
**Purpose**: PWM RTL integration  
**Pass Marker**: `PWM Co-simulation Test PASSED`  
**Validates**:
- PWM library loads correctly
- Register read/write through RTL
- PWM output generation

### Test 3: GPIO Co-simulation
**Platform**: `elemrv_h_cosim_gpio.repl`  
**Purpose**: GPIO RTL integration  
**Pass Marker**: `GPIO Co-simulation Test PASSED`  
**Validates**:
- GPIO direction control
- Pin read/write
- 12-pin configuration

### Test 4: UART Co-simulation
**Platform**: `elemrv_h_cosim_uart.repl`  
**Purpose**: UART RTL integration  
**Pass Marker**: `UART Co-simulation Test PASSED`  
**Validates**:
- UART transmission
- Baud rate configuration
- TX/RX data path

### Test 5: I2C Co-simulation
**Platform**: `elemrv_h_cosim_i2c.repl`  
**Purpose**: I2C controller RTL integration  
**Pass Marker**: `I2C Co-simulation Test PASSED`  
**Validates**:
- I2C master operation
- Start/stop conditions
- Data transfer

### Test 6: Timer Co-simulation
**Platform**: `elemrv_h_cosim_mtimer.repl`  
**Purpose**: Machine timer RTL integration  
**Pass Marker**: `Timer Co-simulation Test PASSED`  
**Validates**:
- mtime counter increments
- mtimecmp comparison
- Interrupt generation

### Test 7: PIO Co-simulation
**Platform**: `elemrv_h_cosim_pio.repl`  
**Purpose**: Programmable I/O RTL integration  
**Pass Marker**: `PIO Co-simulation Test PASSED`  
**Validates**:
- PIO state machine execution
- 3-pin operation
- Program loading

### Test 8: Pinmux Co-simulation
**Platform**: `elemrv_h_cosim_pinmux.repl`  
**Purpose**: Pinmux RTL integration  
**Pass Marker**: `Pinmux Co-simulation Test PASSED`  
**Validates**:
- Pin routing configuration
- 12-pin support
- Peripheral mapping

### Test 9: Full Co-simulation (H)
**Platform**: `elemrv_h_full_cosim.repl`  
**Purpose**: All 7 peripherals simultaneously  
**Pass Marker**: `Full Co-simulation Test PASSED`  
**Validates**:
- Multiple co-sim libraries loaded
- No conflicts between peripherals
- Concurrent bus access

### Test 10: Pure Verilator Testbenches
**Platform**: N/A (standalone)  
**Purpose**: RTL validation without Renode  
**Pass Marker**: `All Verilator testbenches PASSED`  
**Validates**:
- RTL correctness
- Standalone test coverage
- Baseline for co-sim validation

## Phase 2: Integration and Validation (Tests 11-20)

### Test 11: GPIO Multi-Register Test
**Purpose**: Multiple GPIO operations  
**Pass Marker**: `GPIO Multi-Register Test PASSED`  
**Validates**:
- Sequential register access
- Pin state persistence

### Test 12: UART Loopback Test
**Purpose**: UART TX->RX loopback  
**Pass Marker**: `UART Loopback Test PASSED`  
**Validates**:
- Full-duplex operation
- Data integrity

### Test 13: I2C Bus Scan
**Purpose**: I2C device detection  
**Pass Marker**: `I2C Scan Test PASSED`  
**Validates**:
- Address probing
- ACK/NACK handling

### Test 14: PWM Frequency Sweep
**Purpose**: PWM at various frequencies  
**Pass Marker**: `PWM Frequency Test PASSED`  
**Validates**:
- Prescaler configuration
- Period accuracy

### Test 15: Timer Interrupt Test
**Purpose**: Timer-based interrupts  
**Pass Marker**: `Timer Interrupt Test PASSED`  
**Validates**:
- IRQ generation
- Handler execution

### Test 16: PIO Waveform Generation
**Purpose**: Custom PIO programs  
**Pass Marker**: `PIO Waveform Test PASSED`  
**Validates**:
- Custom instruction sequences
- Pin waveforms

### Test 17: Pinmux Peripheral Routing
**Purpose**: Peripheral to pin mapping  
**Pass Marker**: `Pinmux Routing Test PASSED`  
**Validates**:
- Multi-peripheral routing
- Pin conflicts

### Test 18: Co-sim Cross-Validation
**Purpose**: Compare co-sim vs Verilator  
**Pass Marker**: `Cross-Validation Test PASSED`  
**Validates**:
- Consistency between methods
- Result matching

### Test 19: Library Reload Test
**Purpose**: Dynamic library loading  
**Pass Marker**: `Library Reload Test PASSED`  
**Validates**:
- Multiple load/unload cycles
- No memory leaks

### Test 20: Concurrent Access Test
**Purpose**: Simultaneous peripheral access  
**Pass Marker**: `Concurrent Access Test PASSED`  
**Validates**:
- Bus arbitration
- No data corruption

## Phase 3: Zephyr RTOS - H (Tests 21-30)

### Test 21: Zephyr Hello World
**Purpose**: Basic Zephyr boot  
**Pass Marker**: `Zephyr Hello World Test PASSED`  
**Validates**:
- Zephyr kernel initialization
- UART console output
- XIP boot from Flash

### Test 22: Zephyr Blinky
**Purpose**: GPIO via Zephyr API  
**Pass Marker**: `Zephyr Blinky Test PASSED`  
**Validates**:
- GPIO driver
- LED toggle
- Kernel timers

### Test 23: Zephyr Button IRQ
**Purpose**: GPIO interrupts  
**Pass Marker**: `Zephyr Button IRQ Test PASSED`  
**Validates**:
- Interrupt handling
- Callback execution

### Test 24: Zephyr PWM Fade
**Purpose**: PWM via Zephyr API  
**Pass Marker**: `Zephyr PWM Fade Test PASSED`  
**Validates**:
- PWM driver
- Duty cycle control

### Test 25: Zephyr UART Console
**Purpose**: UART driver  
**Pass Marker**: `Zephyr UART Test PASSED`  
**Validates**:
- printk output
- Console integration

### Test 26: Zephyr Timer
**Purpose**: Kernel timer API  
**Pass Marker**: `Zephyr Timer Test PASSED`  
**Validates**:
- k_timer API
- Callbacks

### Test 27: Zephyr I2C
**Purpose**: I2C driver  
**Pass Marker**: `Zephyr I2C Test PASSED`  
**Validates**:
- I2C API
- Device communication

### Test 28: Zephyr Multi-threading
**Purpose**: Thread creation  
**Pass Marker**: `Zephyr Thread Test PASSED`  
**Validates**:
- k_thread_create
- Context switching

### Test 29: Sensor Detection (I2C)
**Purpose**: I2C sensor scan  
**Pass Marker**: `Sensor Detection Test PASSED`  
**Validates**:
- SI7021 presence
- Address detection

### Test 30: Sensor Capture (I2C)
**Purpose**: Dynamic sensor reading  
**Pass Marker**: `Sensor Capture Test PASSED`  
**Validates**:
- Temperature reads
- Dynamic value changes
- Data conversion

## Phase 4: ElemRV-N Platform (Tests 31-40)

### Test 31: N Base Platform
**Platform**: `elemrv_n.repl`  
**Purpose**: N CPU + RAM  
**Pass Marker**: `N Base Platform Test PASSED`  
**Validates**:
- RV32IMC execution
- 4KB RAM operation
- 20MHz clock

### Test 32: N GPIO Co-simulation
**Purpose**: 20-pin GPIO RTL  
**Pass Marker**: `N GPIO Co-simulation Test PASSED`  
**Validates**:
- Extended GPIO (20 pins)
- Same interface as H

### Test 33: N SPI Co-simulation
**Purpose**: SPI controller RTL  
**Pass Marker**: `N SPI Co-simulation Test PASSED`  
**Validates**:
- SPI master operation
- Command FIFO interface

### Test 34: N I2C Lite Co-simulation
**Purpose**: Lite I2C RTL  
**Pass Marker**: `N I2C Lite Co-simulation Test PASSED`  
**Validates**:
- Reduced feature set
- Polling operation

### Test 35: N UART Lite Co-simulation
**Purpose**: Lite UART RTL  
**Pass Marker**: `N UART Lite Co-simulation Test PASSED`  
**Validates**:
- Basic TX/RX
- No flow control

### Test 36: N Pinmux Co-simulation
**Purpose**: 20-pin pinmux RTL  
**Pass Marker**: `N Pinmux Co-simulation Test PASSED`  
**Validates**:
- Extended pinmux
- Multi-peripheral routing

### Test 37: N Full Co-simulation
**Purpose**: All 10 peripherals  
**Pass Marker**: `N Full Co-simulation Test PASSED`  
**Validates**:
- 10 co-sim libraries
- Shared H libraries work
- N-specific libraries

### Test 38: N Pure Verilator
**Purpose**: RTL validation  
**Pass Marker**: `All N testbenches PASSED`  
**Validates**:
- N-specific RTL
- SPI, I2C lite, UART lite

### Test 39: N Zephyr Hello
**Purpose**: Basic N Zephyr boot  
**Pass Marker**: `N Zephyr Hello World Test PASSED`  
**Validates**:
- N Zephyr BSP
- RV32IMC support

### Test 40: N Zephyr Blinky
**Purpose**: N GPIO via Zephyr  
**Pass Marker**: `N Zephyr Blinky Test PASSED`  
**Validates**:
- 20-pin GPIO driver
- LED on N board

## Phase 5: RTOS Debugging (Tests 41-46)

### Test 41: RTOS Debug Demo (H)
**Firmware**: `rtos_debug_demo`  
**Pass Marker**: `RTOS Debug Demo Test PASSED`  
**Validates**:
- Multi-thread creation
- Thread analyzer output
- Thread naming

### Test 42: RTOS Diagnostics (H)
**Firmware**: `rtos_diagnostics`  
**Pass Marker**: `RTOS Diagnostics Test PASSED`  
**Validates**:
- Auto thread analyzer
- Logging subsystem
- Shell (if enabled)

### Test 43: RTOS GDB Threads (H)
**Purpose**: GDB thread-aware debugging  
**Pass Marker**: `RTOS GDB Thread Test PASSED`  
**Validates**:
- Debug symbols present
- Thread metadata accessible
- zephyr-threads command

### Test 44: N RTOS Debug Demo
**Firmware**: `rtos_debug_demo` (N)  
**Pass Marker**: `N RTOS Debug Demo Test PASSED`  
**Validates**:
- Multi-thread on 4KB RAM
- Thread analyzer (on-demand)

### Test 45: N RTOS Diagnostics
**Firmware**: `rtos_diagnostics` (N)  
**Pass Marker**: `N RTOS Diagnostics Test PASSED`  
**Validates**:
- On-demand analyzer
- No shell (RAM constraints)
- Logging works

### Test 46: N RTOS GDB Threads
**Purpose**: GDB debugging on N  
**Pass Marker**: `N RTOS GDB Thread Test PASSED`  
**Validates**:
- N debug symbols
- Thread inspection

## Phase 6: Sensor Simulation (Tests 47-51)

### Test 47: I2C Sensor (H)
**Platform**: `elemrv_h_i2c_sensor.repl`  
**Pass Marker**: `I2C Sensor Test (H) PASSED`  
**Validates**:
- SI7021 model
- Temperature reads
- Humidity reads

### Test 48: I2C Sensor (N)
**Platform**: `elemrv_n_i2c_sensor.repl`  
**Pass Marker**: `I2C Sensor Test (N) PASSED`  
**Validates**:
- Same sensor on N
- I2C driver compatibility

### Test 49: SPI Sensor (N)
**Platform**: `elemrv_n_spi_sensor.repl`  
**Pass Marker**: `SPI Sensor Test PASSED`  
**Validates**:
- Embedded SPI sensor
- Custom nafarr driver
- Register reads

### Test 50: Portable Data Logger (H)
**Firmware**: `portable_data_logger`  
**Pass Marker**: `Portable Logger Test (H) PASSED`  
**Validates**:
- Multi-thread app
- Sensor + GPIO + UART
- Portable (no #ifdef)

### Test 51: Portable Data Logger (N)
**Firmware**: `portable_data_logger` (N)  
**Pass Marker**: `Portable Logger Test (N) PASSED`  
**Validates**:
- Same app on N
- BSP abstraction
- 4KB RAM operation

## Running Tests

### Full Suite

```bash
# All 51 tests
task dt-integration-test

# Expected time: 5-10 minutes
```

### Quick Run

```bash
# Run without rebuilding
task dt-test-quick
```

### Platform-Specific

```bash
# ElemRV-H only
task dt-test

# ElemRV-N only
task dt-n-test
```

### Individual Tests

```bash
# Run single test
docker exec elemrv-gui bash -c 'cd /workspace/elemrv/renode && \
  renode --disable-xwt --console -e "include @run_test_XX.resc"'
```

## Test Reports

Test results are logged to:
- `renode/logs/test_results.txt`
- `renode/logs/test_failures.txt` (if any)

### Exit Codes

| Code | Meaning |
|------|---------|
| 0 | All tests passed |
| 1 | One or more tests failed |
| 2 | Setup error |

## Adding New Tests

### Test Script Template

```renode
// run_test_XX.resc
using sysbus

mach create "test_XX"
machine LoadPlatformDescription @platforms/platform.repl

# Load co-sim libraries if needed
$lib?="/path/to/lib.so"
peripheral_cosim SimulationFilePathLinux $lib

# Load firmware
sysbus LoadBinary @firmware.bin 0xA0000000
cpu PC 0xA0000000

# Run
echo "Starting Test XX: Description"
emulation RunFor "00:00:05.000000"

# Verify result
$result=sysbus ReadDoubleWord 0x80001000
if $result == 0x1 {
    echo "Test XX: PASSED"
} else {
    echo "Test XX: FAILED"
}

quit
```

### Test Registration

Add to `renode/run_tests.sh`:

```bash
echo "Test XX: Description"
run_test "run_test_XX.resc" "Test XX PASSED"
```

---

**Previous**: [Bare-metal Firmware](../firmware/bare-metal.md)  
**Next**: [Taskfile Commands](taskfile-commands.md)
