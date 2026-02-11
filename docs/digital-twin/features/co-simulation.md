# Co-simulation Guide

This guide explains how RTL co-simulation works in the ElemRV Digital Twin platform and how to use it effectively.

## Overview

Co-simulation combines Renode's fast CPU simulation with Verilator's cycle-accurate RTL simulation, allowing firmware to interact with actual Verilog implementations of peripherals.

## How It Works

### Data Flow

```
Firmware Access to Peripheral
==============================

1. Firmware executes:
   *(volatile uint32_t*)0xF0003000 = 0x01;
   
2. Renode detects bus access to co-sim region (0xF0000000-0xF001FFFF)

3. IntegrationLibrary packages transaction:
   - Address: 0xF0003000
   - Data: 0x01
   - Write: true
   
4. Socket communication to Verilator process

5. Wrapper applies to RTL signals:
   - io_bus_CYC = 1
   - io_bus_STB = 1
   - io_bus_WE = 1
   - io_bus_ADR = 0x3000
   - io_bus_DAT_MOSI = 0x01

6. Verilator evaluates clock cycles

7. RTL responds:
   - io_bus_ACK = 1
   - io_bus_DAT_MISO = register_value

8. Response returns to Renode

9. CPU continues execution
```

### Timing Model

Each bus transaction takes multiple simulation cycles:

```
Cycle 0:  CPU initiates transaction
          Renode pauses CPU
          IntegrationLibrary sends request
          
Cycle 1:  Wrapper applies signals
          Verilator evaluates
          
Cycle 2:  RTL generates ACK
          Response captured
          
Cycle 3:  Response returned
          CPU resumes
```

This provides cycle-accurate timing at the cost of simulation speed.

## Co-simulation vs Pure Renode

| Aspect | Pure Renode | Co-simulation |
|--------|-------------|---------------|
| Speed | ~100 MIPS | ~1-10 KIPS |
| Accuracy | Model-based | Cycle-accurate |
| Use Case | Firmware dev | Driver/RTL validation |
| Debugging | Limited | Full signal visibility |
| CI/CD | Fast feedback | Thorough validation |

## Platform Modes

### 1. Base Platform

No co-simulation - uses LiteX models:

```
File: elemrv_h.repl

Components:
- VexRiscv CPU
- LiteX UART
- LiteX Timer
- Tags for memory regions
```

**Use**: Fast CPU debugging, algorithm development

### 2. Zephyr Platform

Adds RTOS support:

```
File: elemrv_h_zephyr.repl

Additional:
- MachineTimer (mtime)
- Correct CSR widths
```

**Use**: Zephyr RTOS development

### 3. Co-simulation Platform

Full RTL peripherals:

```
File: elemrv_h_full_cosim.repl

Components:
- GPIO0: CoSimulated @ 0xF0000000
- I2C0: CoSimulated @ 0xF0001000
- PIO0: CoSimulated @ 0xF0002000
- PWM0: CoSimulated @ 0xF0003000
- UART0: CoSimulated @ 0xF0004000
- Timer0: CoSimulated @ 0xF0005000
- Pinmux: CoSimulated @ 0xF0010000
```

**Use**: Driver validation, RTL verification

### 4. Hybrid Platform

Mix of both approaches:

```
File: elemrv_h_hybrid.repl

Configuration:
- PWM: Co-sim (critical timing)
- Pinmux: Co-sim (hardware routing)
- PIO: Co-sim (programmable I/O)
- GPIO: LiteX (sufficient for LED toggle)
- UART: LiteX (standard I/O)
- Timer: LiteX (sufficient for RTOS)
```

**Use**: Balanced performance and accuracy

## Creating a Co-simulation Platform

### Step 1: Define Peripheral in .repl

```renode
gpio0_cosim: CoSimulated.CoSimulatedPeripheral @ sysbus <0xF0000000, +0x1000>
    frequency: 50000000
    limitBuffer: 10000

pwm0_cosim: CoSimulated.CoSimulatedPeripheral @ sysbus <0xF0003000, +0x1000>
    frequency: 50000000
    limitBuffer: 10000
```

### Step 2: Load Co-simulation Library

```renode
$lib?="/workspace/elemrv/renode/verilated/libs/libpwm.so"
pwm0_cosim SimulationFilePathLinux $lib
```

### Step 3: Complete Script

```renode
using sysbus

mach create "cosim_test"
machine LoadPlatformDescription @platforms/elemrv_h_full_cosim.repl

# Load co-sim libraries
$gpio_lib?="/workspace/elemrv/renode/verilated/libs/libgpio.so"
gpio0_cosim SimulationFilePathLinux $gpio_lib

$pwm_lib?="/workspace/elemrv/renode/verilated/libs/libpwm.so"
pwm0_cosim SimulationFilePathLinux $pwm_lib

# Load firmware
sysbus LoadBinary @firmware.bin 0xA0000000
cpu PC 0xA0000000

# Run
emulation RunFor "00:00:05.000000"

quit
```

## Debugging Co-simulation

### Enable Verbose Logging

In wrapper code:
```cpp
#define DEBUG_ENABLE 1

void evalModel() {
    g_top->eval();
    
    if (DEBUG_ENABLE) {
        printf("[DEBUG] Time=%lu CYC=%d STB=%d WE=%d ADR=0x%X\n",
               g_top->clk_count,
               g_top->io_bus_CYC,
               g_top->io_bus_STB,
               g_top->io_bus_WE,
               g_top->io_bus_ADR);
    }
}
```

### Monitor Transactions

From Renode monitor:
```
(monitor) logLevel 3 sysbus
(monitor) sysbus LogPeripheralAccess true
```

### GDB Debugging

```bash
# Start with co-sim
task dt-debug-cosim

# Connect GDB
task dt-debug-connect

# In GDB:
(gdb) break main
(gdb) continue
(gdb) x/1xw 0xF0003000  # Read PWM register (goes to RTL)
```

### Signal Inspection

Add signal dumping to wrapper:
```cpp
// Dump internal signals periodically
if (g_top->clk_count % 100000 == 0) {
    printf("[SIGNAL] PWM=%X, Counter=%u, Period=%u\n",
           g_top->io_pwm_pwm,
           g_top->Pwm_output_counter,
           g_top->Pwm_output_period);
}
```

## Performance Optimization

### Build Modes

**Debug** (slow, verbose):
```bash
make -f Makefile.pwm BUILD_MODE=debug
```

**Release** (fast, minimal):
```bash
make -f Makefile.pwm BUILD_MODE=release
```

### Reduce Peripherals

Only enable peripherals you're testing:
```renode
# Instead of full co-sim, test just PWM
mach create "pwm_only"
machine LoadPlatformDescription @elemrv_h_minimal.repl

pwm0: CoSimulated.CoSimulatedPeripheral @ sysbus <0xF0003000, +0x1000>
    frequency: 50000000

$pwm_lib?="/workspace/elemrv/renode/verilated/libs/libpwm.so"
pwm0_cosim SimulationFilePathLinux $pwm_lib
```

Note: The `//` comment syntax is not valid in `.resc` scripts. Use `#` for comments.

### Limit Simulation Duration

```renode
# Short test runs
emulation RunFor "00:00:01.000000"  # 1 second virtual time
```

## Common Issues

### Library Not Found

**Error**: `Library not found: libpwm.so`

**Solution**:
```bash
# Check path
ls -la renode/verilated/libs/

# Verify architecture
file renode/verilated/libs/libpwm.so
# Should show: ELF 64-bit LSB shared object, x86-64

# Rebuild
cd renode/verilated/wrappers
make -f Makefile.pwm clean all
```

### Operation Timeout

**Error**: `Operation timeout`

**Causes**:
1. Missing `main` function in wrapper
2. Incorrect Verilator root linking
3. Infinite loop in RTL

**Solution**:
```bash
# Check symbols
nm -C libpwm.so | grep main

# Rebuild with all object files
make -f Makefile.pwm clean all
```

### Hang on Variable Assignment

**Issue**: Script hangs when using:
```renode
$value=sysbus ReadDoubleWord 0xF0003000
```

**Solution**: Do not assign read results to variables:
```renode
# Wrong - hangs
$value=sysbus ReadDoubleWord 0xF0003000

# Correct
sysbus ReadDoubleWord 0xF0003000
```

This is a Renode limitation with CoSimulatedPeripheral.

### Bus Transaction Errors

**Symptom**: Wrong data returned

**Check**:
1. Address alignment (32-bit word aligned)
2. Byte enable signals connected
3. Reset polarity (active-low)
4. Clock frequency matches platform

## Advanced Topics

### Multi-Peripheral Synchronization

All co-simulated peripherals share the same clock domain:
```renode
# All at 50MHz
gpio0: ... frequency: 50000000
pwm0: ... frequency: 50000000
uart0: ... frequency: 50000000
```

### Custom Peripherals

To add a new RTL peripheral:

1. **Create RTL** in SpinalHDL
2. **Generate Verilog**
3. **Create wrapper** (see `pwm_wrapper.cpp` as template)
4. **Build library**
5. **Add to platform**

### Pure Verilator Validation

Validate RTL before integration:
```bash
cd renode/verilated/testbenches
make run  # Runs standalone testbenches
```

## Test Integration

### Test Script Template

```bash
#!/bin/bash
# test_peripheral.sh

RENODE_ARGS="--disable-xwt --console"
SCRIPT="test_peripheral.resc"
TIMEOUT=30

# Run test
timeout $TIMEOUT docker exec elemrv-test \
    renode $RENODE_ARGS -e "include @$SCRIPT"

# Check result
if [ $? -eq 0 ]; then
    echo "TEST PASSED"
    exit 0
else
    echo "TEST FAILED"
    exit 1
fi
```

---

**Previous**: [Platforms](../platforms/elemrv-n.md)  
**Next**: [Sensor Simulation](sensors.md)
