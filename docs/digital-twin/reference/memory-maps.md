# Memory Maps Reference

Complete memory maps for ElemRV-H and ElemRV-N platforms.

## ElemRV-H Memory Map

### System Memory

| Address Range | Size | Type | Description |
|--------------|------|------|-------------|
| 0x80000000 | 8 KB | RAM | Internal SRAM |
| 0xA0000000 | 64 KB | Flash | External Flash (XIP) |

### Peripheral Memory

| Address Range | Size | Peripheral | Type |
|--------------|------|-----------|------|
| 0xF0000000 | 4 KB | GPIO0 | Co-simulation RTL |
| 0xF0001000 | 4 KB | I2C0 | Co-simulation RTL |
| 0xF0002000 | 4 KB | PIO0 | Co-simulation RTL |
| 0xF0003000 | 4 KB | PWM0 | Co-simulation RTL |
| 0xF0004000 | 4 KB | UART0 | Co-simulation RTL |
| 0xF0005000 | 4 KB | Timer0 | Co-simulation RTL |
| 0xF0010000 | 4 KB | Pinmux | Co-simulation RTL |

## ElemRV-N Memory Map

### System Memory

| Address Range | Size | Type | Description |
|--------------|------|------|-------------|
| 0x80000000 | 4 KB | RAM | Internal SRAM |
| 0x90000000 | 64 MB | HyperRAM | External memory |
| 0xA0000000 | 64 KB | Flash | External Flash (XIP) |

### Peripheral Memory

| Address Range | Size | Peripheral | Type |
|--------------|------|-----------|------|
| 0xF0000000 | 4 KB | GPIO0 (20 pins) | Co-simulation RTL |
| 0xF0001000 | 4 KB | I2C0 (full) | Co-simulation RTL |
| 0xF0002000 | 4 KB | I2C1 (lightweight) | Co-simulation RTL |
| 0xF0003000 | 4 KB | PIO0 | Co-simulation RTL |
| 0xF0004000 | 4 KB | PWM0 | Co-simulation RTL |
| 0xF0005000 | 4 KB | SPI0 | Co-simulation RTL |
| 0xF0006000 | 4 KB | UART0 (full) | Co-simulation RTL |
| 0xF0007000 | 4 KB | UART1 (lightweight) | Co-simulation RTL |
| 0xF0010000 | 4 KB | Pinmux (20 pins) | Co-simulation RTL |
| 0xF0020000 | 4 KB | Timer0 | Co-simulation RTL |
| 0xF0023000 | 4 KB | HyperBus Config | Tag only |

## Peripheral Register Details

### GPIO (GPIO0)

**Base**: 0xF0000000 (H: 12 pins, N: 20 pins)

| Offset | Register | Access | Description |
|--------|----------|--------|-------------|
| 0x00 | IP Header | RO | Peripheral ID (0x00000001) |
| 0x04 | READ | RO | Pin input values |
| 0x08 | WRITE | RW | Pin output values |
| 0x0C | DIRECTION | RW | Direction: 1=output, 0=input |

**Example**:
```c
// Set pin 0 as output
*(volatile uint32_t*)(0xF0000000 + 0x0C) |= 0x1;

// Set pin 0 high
*(volatile uint32_t*)(0xF0000000 + 0x08) |= 0x1;

// Read all pins
uint32_t values = *(volatile uint32_t*)(0xF0000000 + 0x04);
```

### I2C0 (Full Controller)

**Base**: 0xF0001000

| Offset | Register | Access | Description |
|--------|----------|--------|-------------|
| 0x00 | IP Header | RO | Peripheral ID |
| 0x04 | PRESCALER | RW | Clock prescaler |
| 0x08 | CTRL | RW | Control: start, stop, ack |
| 0x0C | TX | WO | Transmit data |
| 0x10 | RX | RO | Receive data |
| 0x14 | STATUS | RO | Status flags |
| 0x18 | CMD | RW | Command register |

### I2C1 Lite (N only)

**Base**: 0xF0002000

Same register map as I2C0 but:
- No interrupt support
- Polling only
- Reduced gate count

### PIO (Programmable I/O)

**Base**: 0xF0002000 (H) / 0xF0003000 (N)

| Offset | Register | Access | Description |
|--------|----------|--------|-------------|
| 0x00 | IP Header | RO | Peripheral ID |
| 0x04 | CONFIG | RW | Configuration |
| 0x08 | INSTR | RW | Instruction memory |
| 0x0C | TX_FIFO | WO | TX FIFO |
| 0x10 | RX_FIFO | RO | RX FIFO |
| 0x14 | STATUS | RO | Status |

### PWM (PWM0)

**Base**: 0xF0003000 (H) / 0xF0004000 (N)

| Offset | Register | Access | Description |
|--------|----------|--------|-------------|
| 0x00 | ENABLE | RW | Global enable (bits 0-1: CH0/CH1) |
| 0x04 | PRESCALER | RW | Clock prescaler (20-bit) |
| 0x08 | PERIOD | RW | PWM period (20-bit) |
| 0x0C | DUTY_CH0 | RW | Channel 0 duty (20-bit) |
| 0x10 | DUTY_CH1 | RW | Channel 1 duty (20-bit) |
| 0x14 | CTRL_CH0 | RW | Channel 0 control |
| 0x18 | CTRL_CH1 | RW | Channel 1 control |

**Example** (1kHz, 50% duty):
```c
#define PWM_BASE 0xF0003000
*(volatile uint32_t*)(PWM_BASE + 0x04) = 49;   // Prescaler
*(volatile uint32_t*)(PWM_BASE + 0x08) = 999;  // Period
*(volatile uint32_t*)(PWM_BASE + 0x0C) = 499;  // Duty CH0
*(volatile uint32_t*)(PWM_BASE + 0x14) = 1;    // Enable CH0
*(volatile uint32_t*)(PWM_BASE + 0x00) = 1;    // Global enable
```

### SPI0 (N only)

**Base**: 0xF0005000

| Offset | Register | Access | Description |
|--------|----------|--------|-------------|
| 0x00 | IP Header | RO | Peripheral ID |
| 0x04 | PRESCALER | RW | Clock prescaler |
| 0x08 | CTRL | RW | Control |
| 0x0C | STATUS | RO | Status |
| 0x10 | TX | WO | TX data |
| 0x14 | RX | RO | RX data |
| 0x50 | CMD_FIFO | RW | Command FIFO (custom) |

**Command FIFO Format**:
```
[29:28] = Mode (00=DATA, 01=CS, 10=DUMMY)
DATA: [24]=read_flag, [7:0]=data
CS:   [24]=enable, [3:0]=cs_index
```

### UART0 (Full)

**Base**: 0xF0004000 (H) / 0xF0006000 (N)

| Offset | Register | Access | Description |
|--------|----------|--------|-------------|
| 0x00 | IP Header | RO | Peripheral ID |
| 0x04 | CLK_DIV | RW | Clock divider for baud rate |
| 0x08 | FRAME | RW | Frame config (data bits, parity, stop) |
| 0x0C | STATUS | RO | TX ready, RX valid flags |
| 0x10 | TX | WO | Transmit data |
| 0x14 | RX | RO | Receive data |

**Baud Rate Calculation**:
```
CLK_DIV = (Clock Frequency / Baud Rate) - 1

Example (50MHz, 115200):
CLK_DIV = (50000000 / 115200) - 1 = 433
```

### UART1 Lite (N only)

**Base**: 0xF0007000

Same register map but:
- No CTS/RTS flow control
- Basic TX/RX only
- Reduced gate count

### Timer (Machine Timer)

**Base**: 0xF0005000 (H) / 0xF0020000 (N)

| Offset | Register | Access | Description |
|--------|----------|--------|-------------|
| 0x00 | MTIME_LO | RW | Timer low 32 bits |
| 0x04 | MTIME_HI | RW | Timer high 32 bits |
| 0x08 | MTIMECMP_LO | RW | Compare low 32 bits |
| 0x0C | MTIMECMP_HI | RW | Compare high 32 bits |

**RISC-V Standard**: MTIME is a 64-bit counter that increments at constant frequency. When MTIME >= MTIMECMP, timer interrupt fires.

### Pinmux

**Base**: 0xF0010000

| Offset | Register | Access | Description |
|--------|----------|--------|-------------|
| 0x00 | IP Header | RO | Peripheral ID |
| 0x04 | PIN0 | RW | Pin 0 mux select |
| 0x08 | PIN1 | RW | Pin 1 mux select |
| ... | ... | ... | ... |
| 0x## | PIN11/19 | RW | Last pin mux (H:11, N:19) |

**Mux Values**:
```
0x0 = GPIO
0x1 = UART0_TX/RX
0x2 = I2C0_SDA/SCL
0x3 = PWM0_CH0/CH1
0x4 = SPI0 (N only)
...
```

## Platform Variants

### Minimal Platform

```
0x80000000 - 0x80001FFF: RAM (8KB)
0xA0000000 - 0xA000FFFF: Flash (64KB)
0xF0040000 - 0xF0040FFF: UART0 (LiteX model)
0xF0050000 - 0xF0050FFF: Timer0 (LiteX model)
```

### Zephyr Platform

Same as minimal plus:
```
0xF0020000 - 0xF0020FFF: MachineTimer (mtime)
```

### Full Co-simulation

All peripheral regions mapped to co-simulated RTL.

## Access Patterns

### 32-bit Access

All registers are 32-bit aligned:
```c
// Correct - 32-bit access
uint32_t val = *(volatile uint32_t*)0xF0003000;

// Incorrect - unaligned access may fault
uint16_t val = *(volatile uint16_t*)0xF0003001;
```

### Read-Only Registers

IP Header registers are read-only:
```c
// Read - OK
uint32_t header = *(volatile uint32_t*)0xF0003000;

// Write - RTL will ignore
*(volatile uint32_t*)0xF0003000 = 0x12345678;  // Ignored
```

### Write-Only Registers

Some registers (like UART TX) are write-only:
```c
// Write - OK
*(volatile uint32_t*)0xF0004010 = 'A';

// Read - undefined behavior
uint32_t val = *(volatile uint32_t*)0xF0004010;
```

## GDB Memory Access

### Reading Registers

```gdb
# Read PWM enable
(gdb) x/1xw 0xF0003000

# Read GPIO values
(gdb) x/1xw 0xF0000004

# Dump peripheral region
(gdb) x/16xw 0xF0003000
```

### Writing Registers

```gdb
# Write PWM period
(gdb) set *(uint32_t*)0xF0003008 = 1000

# Or via monitor
(gdb) mon sysbus WriteDoubleWord 0xF0003008 1000
```

## Memory Protection

### Valid Access Ranges

**RAM**: Read/Write
**Flash**: Read (XIP), Write ignored
**Peripherals**: Device-specific
**Unmapped**: Bus error

### Alignment Requirements

- 32-bit access: 4-byte aligned
- 16-bit access: 2-byte aligned
- 8-bit access: 1-byte aligned

Accessing unaligned addresses may cause:
- Bus fault (trap)
- Unpredictable results
- Performance penalty

## Address Translation

### Physical Address Map

All addresses in this document are physical addresses as seen by the CPU. No MMU translation is performed.

### Region Attributes

| Region | Cacheable | Bufferable | Execute |
|--------|-----------|------------|---------|
| RAM | No | No | Yes |
| Flash | No | No | Yes (XIP) |
| Peripherals | No | No | No |

---

**Previous**: [Taskfile Commands](taskfile-commands.md)  
**Back to**: [README](../README.md)
