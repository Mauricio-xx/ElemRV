# Architecture Overview

The ElemRV Digital Twin combines multiple technologies to create a hardware-software co-simulation environment. This document explains how the components work together.

## System Architecture

```
Complete Digital Twin Stack
============================

Application Layer
-----------------
  Zephyr Applications  (RTOS + drivers + apps)
  Bare-metal Firmware  (Direct hardware access)

Firmware Layer
--------------
  Zephyr HAL          (Hardware abstraction)
  nafarr Drivers      (ElemRV peripheral drivers)

System Simulation Layer
-----------------------
  +-------------------------------------------+
  | Renode System Simulator                   |
  |                                           |
  |  +-----------------+  +----------------+ |
  |  | VexRiscv CPU    |  | LiteX Models   | |
  |  | - RV32IC/IMC    |  | - UART         | |
  |  | - 50/20 MHz     |  | - Timer        | |
  |  | - Memory mgmt   |  | - Interrupts   | |
  |  +-----------------+  +----------------+ |
  |                                           |
  |  +-------------------------------------+  |
  |  | IntegrationLibrary Bridge           |  |
  |  | - Socket communication              |  |
  |  | - Wishbone protocol                 |  |
  |  | - Clock synchronization             |  |
  |  +-------------------------------------+  |
  |                                           |
  +-------------------------------------------+

RTL Simulation Layer
--------------------
  +-------------------------------------------+
  | Verilator + Co-simulation Wrappers        |
  |                                           |
  |  +-----------------+  +----------------+ |
  |  | Verilated RTL   |  | C++ Wrapper    | |
  |  | - Cycle-accurate|  | - Signal intf  | |
  |  | - Real registers|  | - Bus bridge   | |
  |  | - Timing exact  |  | - Library .so  | |
  |  +-----------------+  +----------------+ |
  |                                           |
  +-------------------------------------------+

Hardware Description Layer
--------------------------
  SpinalHDL Scala Sources
  - Type-safe RTL generation
  - Parameterized peripherals
  - Verilog output
```

## Key Components

### 1. Renode System Simulator

Renode provides full-system simulation:

- **VexRiscv CPU**: RISC-V core with exact instruction timing
- **Memory Models**: RAM, Flash, and peripheral memory regions
- **Interrupt System**: Platform-Level Interrupt Controller (PLIC)
- **LiteX Models**: High-level peripheral models for UART, Timer
- **Execution Control**: GDB server, breakpoints, step-through

**Role**: Executes firmware instructions and routes peripheral accesses.

### 2. IntegrationLibrary

The bridge between Renode and RTL:

```
Transaction Flow:
-----------------

Firmware:  lw x1, 0xF0003000 (read PWM enable register)
              |
              v
Renode:   Detects sysbus access to co-sim region
              |
              v
IntegrationLibrary:  Packages as Wishbone transaction
              |
              v
Socket:    Sends to Verilator process
              |
              v
Wrapper:   Applies to RTL signals
              |
              v
Verilator: Evaluates one clock cycle
              |
              v
Wrapper:   Captures response
              |
              v
Socket:    Returns data to Renode
              |
              v
Renode:    Provides value to CPU
```

**Key Features**:
- Socket-based inter-process communication
- Wishbone bus protocol translation
- Clock cycle synchronization
- Reset sequence management

### 3. Verilated RTL

Cycle-accurate hardware models:

**Generation Process**:
1. SpinalHDL describes peripheral in Scala
2. Generates synthesizable Verilog
3. Verilator compiles to C++ simulation model
4. Linked with wrapper into shared library (.so)

**Advantages**:
- Register reads return actual RTL values
- Timing violations visible at cycle level
- Internal signals available for debugging
- Deterministic, repeatable execution

### 4. SpinalHDL

Hardware description with software-like abstraction:

```scala
// Example: PWM peripheral in SpinalHDL
case class WishbonePwm() extends Component {
  val io = new Bundle {
    val bus = slave(Wishbone(WishboneConfig(32, 32)))
    val pwm = out Bits(2 bits)
  }
  
  val prescaler = Reg(UInt(20 bits)) init(0)
  val period = Reg(UInt(20 bits)) init(0)
  val duty = Reg(UInt(20 bits)) init(0)
  val enable = Reg(Bool()) init(False)
  
  // PWM logic
  val counter = Reg(UInt(20 bits)) init(0)
  when(enable) {
    counter := counter + 1
    when(counter >= period) {
      counter := 0
    }
  }
  
  io.pwm(0) := enable && (counter < duty)
}
```

## Communication Protocol

### Wishbone Bus Interface

All co-simulated peripherals use the Wishbone bus:

```
Wishbone Signal Mapping:
------------------------

Signal      Direction   Description
------      ---------   -----------
CYC         CPU->Periph Bus cycle in progress
STB         CPU->Periph Strobe (valid transfer)
WE          CPU->Periph Write enable (1=write, 0=read)
ADR[31:0]   CPU->Periph Address
DAT_MOSI    CPU->Periph Write data (Master Out, Slave In)
DAT_MISO    Periph->CPU Read data (Master In, Slave Out)
ACK         Periph->CPU Acknowledge (transfer complete)
ERR         Periph->CPU Error (optional)
```

### Transaction Timing

Each bus transaction takes multiple simulation steps:

```
Clock Cycles per Transaction:
-----------------------------

Cycle 0:  CYC=1, STB=1, WE=1, ADR=addr, DAT_MOSI=data
          (CPU initiates write)
          
Cycle 1:  Peripheral latches address and data
          RTL evaluates combinational logic
          
Cycle 2:  ACK=1 (peripheral ready)
          DAT_MISO valid (for reads)
          
Cycle 3:  CYC=0, STB=0 (transaction complete)
```

## Platform Configurations

### Base Platform

Minimal configuration for CPU debugging:

```
Components:
- VexRiscv CPU @ 50MHz (H) or 20MHz (N)
- 8KB RAM (H) or 4KB RAM (N)
- 64KB Flash
- LiteX UART (for console output)
- LiteX Timer
```

### Zephyr Platform

Full RTOS support:

```
Components:
- Base platform elements
- Machine Timer (mtime/mtimecmp)
- Correct 32-bit CSR widths
- Interrupt controller
```

### Co-simulation Platform

RTL-accurate peripherals:

```
Components (ElemRV-H):
- Base platform
- GPIO (20 pins, RTL)
- I2C Controller (RTL)
- PIO (3 pins, RTL)
- PWM (2 channels, RTL)
- UART (RTL)
- Pinmux (RTL)

Components (ElemRV-N):
- H peripherals
- SPI Controller (RTL)
- I2C Lite (lightweight, RTL)
- UART Lite (lightweight, RTL)
- HyperRAM controller
```

## Execution Modes

### 1. Pure Renode (Fast)

Uses C# models for peripherals:

```
Speed: ~100 MIPS (million instructions/second)
Use:   Firmware development, algorithm testing
Limit: Models may differ from RTL behavior
```

### 2. Co-simulation (Accurate)

Uses Verilator for peripherals:

```
Speed: ~1-10 KIPS (thousand instructions/second)
Use:   Driver validation, RTL verification
Limit: Slower due to cycle-accurate simulation
```

### 3. Hybrid (Balanced)

Mix of both approaches:

```
Speed: ~50 MIPS average
Use:   System integration testing
Config: Critical peripherals in co-sim,
        standard peripherals in LiteX models
```

## Signal Visibility

One major advantage of co-simulation is full visibility:

### Internal Signal Access

In wrapper code:
```cpp
// Access internal RTL signals
void evalModel() {
    g_top->eval();
    
    // Debug output
    if (g_top->io_pwm_pwm != last_pwm) {
        printf("PWM changed: 0x%X at time %lu\n",
               g_top->io_pwm_pwm, 
               g_top->clk_count);
    }
}
```

### GDB Integration

During debugging:
```bash
(gdb) x/1xw 0xF0003000    # Read PWM register via bus
(gdb) mon pwm0_cosim LogLevel 3  # Enable RTL logging
```

## Troubleshooting

### Library Loading Issues

```bash
# Verify library exists and is valid
ls -la renode/verilated/libs/
file renode/verilated/libs/libpwm.so

# Check library dependencies
ldd renode/verilated/libs/libpwm.so
```

### Communication Timeout

**Symptom**: Test hangs indefinitely

**Causes**:
1. Wrapper not linking Verilator root files
2. Renode waiting for ACK that never comes
3. Clock domain mismatch

**Solutions**:
```bash
# Rebuild with clean
make -f Makefile.pwm clean all

# Check wrapper main function exists
nm -C libpwm.so | grep main

# Verify socket communication
strace -f renode --disable-xwt test.resc 2>&1 | grep socket
```

### Signal Connection Errors

**Symptom**: Bus transactions return wrong values

**Check**:
1. Address width matches (32-bit)
2. Data width matches (32-bit)
3. Byte enable signals connected
4. Reset polarity correct (active-low)

### Performance Issues

**Slow simulation**:
```bash
# Use release build
make BUILD_MODE=release

# Disable debug prints in wrapper
#undef DEBUG_ENABLE

# Reduce simulation duration
task dt-test-quick
```

## Future Enhancements

Potential improvements to the platform:

1. **Native Renode Thread Awareness**: When Renode issue #637 is resolved
2. **SystemView Support**: If RTT emulation is added to Renode
3. **Multiple CPU Cores**: Extend to multi-core RISC-V
4. **Custom Peripherals**: Template for adding new RTL blocks
5. **Performance Profiling**: Instruction-level execution traces

---

**Previous**: [Getting Started](getting-started.md)  
**Next**: Platform Documentation
