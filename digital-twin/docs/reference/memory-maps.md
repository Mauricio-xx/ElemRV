# Memory Maps Reference

Complete memory maps for ElemRV-H and ElemRV-N platforms.

## ElemRV-H Memory Map

### System Memory

| Address Range | Size | Type | Description |
|--------------|------|------|-------------|
| 0x80000000 | 8 KB | RAM | Internal SRAM (OCRAM) |
| 0xA0000000 | 64 KB | Flash | External Flash (XIP) |

### Peripheral Memory

| Address Range | Size | Peripheral |
|--------------|------|-----------|
| 0xF0000000 | 4 KB | GPIO0 (12 pins) |
| 0xF0001000 | 4 KB | I2C0 |
| 0xF0002000 | 4 KB | PIO0 (3 pins) |
| 0xF0003000 | 4 KB | PWM0 (2 channels) |
| 0xF0004000 | 4 KB | UART0 |
| 0xF0005000 | 4 KB | Timer0 (Machine Timer) |
| 0xF0010000 | 4 KB | Pinmux (12 pins) |

## ElemRV-N Memory Map

### System Memory

| Address Range | Size | Type | Description |
|--------------|------|------|-------------|
| 0x80000000 | 4 KB | RAM | Internal SRAM |
| 0x90000000 | 64 MB | HyperRAM | External memory |
| 0xA0000000 | 64 KB | Flash | External Flash (XIP) |

### Peripheral Memory

| Address Range | Size | Peripheral |
|--------------|------|-----------|
| 0xF0000000 | 4 KB | GPIO0 (20 pins) |
| 0xF0001000 | 4 KB | I2C0 (full) |
| 0xF0002000 | 4 KB | I2C1 (lightweight) |
| 0xF0003000 | 4 KB | PIO0 |
| 0xF0004000 | 4 KB | PWM0 |
| 0xF0005000 | 4 KB | SPI0 |
| 0xF0006000 | 4 KB | UART0 (full) |
| 0xF0007000 | 4 KB | UART1 (lightweight) |
| 0xF0010000 | 4 KB | Pinmux (20 pins) |
| 0xF0020000 | 4 KB | Timer0 |
| 0xF0023000 | 4 KB | HyperBus Config (Tag only) |
| 0xF000A000 | 1 KB | BmbSpiXip cfgSpi bank (IP header, SPI cmd/resp FIFO) |
| 0xF000A400 | 1 KB | BmbSpiXip cfgXip bank (readCommand + trigger; writes invalidate the fetch cache) |
| 0xF000B000 | 4 KB | BmbSpiXip XIP data bank (executable-IO — CPU fetch via `cpu RegisterAccessFlags`) |

## Peripheral Register Details

### GPIO (GPIO0)

**Base**: 0xF0000000 (H: 12 pins, N: 20 pins)

Source: `digital-twin/gen/WishboneGpio.v`

| Offset | Register | Access | Description |
|--------|----------|--------|-------------|
| 0x000 | IP Header | RO | Peripheral ID (H: 0x00080000) |
| 0x004 | IP Version | RO | Version (0x01000000) |
| 0x008 | Features | RO | Pin count info (H: 0x0001000C = 1 bank, 12 pins) |
| 0x00C | Value | RO | Synchronized pin input readings |
| 0x010 | Write | R/W | Output data register |
| 0x014 | Direction | RO | Direction (hardcoded to output in H) |
| 0x018 | IRQ High Pending | R/W | High-level interrupt pending (write to clear) |
| 0x01C | IRQ High Mask | R/W | High-level interrupt mask |
| 0x020 | IRQ Low Pending | R/W | Low-level interrupt pending (write to clear) |
| 0x024 | IRQ Low Mask | R/W | Low-level interrupt mask |
| 0x028 | IRQ Rise Pending | R/W | Rising-edge interrupt pending (write to clear) |
| 0x02C | IRQ Rise Mask | R/W | Rising-edge interrupt mask |
| 0x030 | IRQ Fall Pending | R/W | Falling-edge interrupt pending (write to clear) |
| 0x034 | IRQ Fall Mask | R/W | Falling-edge interrupt mask |

**Example**:
```c
#define GPIO_BASE 0xF0000000

// Set output value on pin 0
*(volatile uint32_t*)(GPIO_BASE + 0x10) |= 0x1;

// Read all pin values
uint32_t values = *(volatile uint32_t*)(GPIO_BASE + 0x0C);
```

### I2C0 (Full Controller)

**Base**: 0xF0001000

Source: `digital-twin/gen/WishboneI2cController.v` (simplified — consult Verilog for exact layout)

| Offset | Register | Access | Description |
|--------|----------|--------|-------------|
| 0x000 | IP Header | RO | Peripheral ID |
| 0x004 | IP Version | RO | Version |
| 0x008 | Features | RO | Feature flags |
| ... | ... | ... | Additional registers — see Verilog source |

> **Note**: The I2C controller has a complex register map. Consult `digital-twin/gen/WishboneI2cController.v` for the exact register layout and offsets.

### I2C1 Lite (N only)

**Base**: 0xF0002000

Same controller RTL as I2C0 but configured as lightweight variant:
- No interrupt support
- Polling only
- Reduced gate count

### PIO (Programmable I/O)

**Base**: 0xF0002000 (H) / 0xF0003000 (N)

Source: `digital-twin/gen/WishbonePio.v`

| Offset | Register | Access | Description |
|--------|----------|--------|-------------|
| 0x000 | IP Header | RO | Peripheral ID (0x00080001) |
| 0x004 | IP Version | RO | Version (0x01000000) |
| 0x008 | Features | RO | ClkDiv=20bit, ReadDelay=24bit, 3 pins |
| 0x00C | Status | RO | TX FIFO depth, RX FIFO depth |
| 0x010 | Config | RO | Enabled flag |
| 0x014 | TX/RX Data | R/W | Write: push command to TX FIFO. Read: pop from RX FIFO |
| 0x018 | FIFO Status | RO | TX vacancy, RX occupancy |
| 0x01C | Clock Divider | R/W | 20-bit clock divider |
| 0x020 | Read Delay | R/W | 8-bit read delay |

**Command Encoding** (TX write at offset 0x014):
```
bits[1:0] = command: HIGH=0, LOW=1, WAIT=2, READ=3
bits[3:2] = pin index
bits[27:4] = data (e.g., wait cycles)
```

### PWM (PWM0)

**Base**: 0xF0003000 (H) / 0xF0004000 (N)

Source: `digital-twin/gen/WishbonePwm.v`, `digital-twin/firmware/pwm_test/pwm.h`

| Offset | Register | Access | Width | Description |
|--------|----------|--------|-------|-------------|
| 0x000 | IP Header | RO | 32 | Peripheral ID (0x00080002) |
| 0x004 | IP Version | RO | 32 | Version (0x01000000) |
| 0x008 | IP Features | RO | 32 | Feature register (0x14141402) |
| 0x00C | IP Status | RO | 32 | Status register |
| 0x010 | Clock Divider | R/W | 20 | Clock divider value |
| 0x014 | CH0 Control | R/W | 2 | [0]=enable, [1]=invert |
| 0x018 | CH0 Period | R/W | 20 | Channel 0 period counter |
| 0x01C | CH0 Pulse | R/W | 20 | Channel 0 pulse/duty width |
| 0x020 | CH1 Control | R/W | 2 | [0]=enable, [1]=invert |
| 0x024 | CH1 Period | R/W | 20 | Channel 1 period counter |
| 0x028 | CH1 Pulse | R/W | 20 | Channel 1 pulse/duty width |

**Example** (1kHz, 50% duty on CH0 at 50MHz clock):
```c
#define PWM_BASE 0xF0003000

*(volatile uint32_t*)(PWM_BASE + 0x010) = 49;    // Clock divider: 50MHz/50 = 1MHz
*(volatile uint32_t*)(PWM_BASE + 0x018) = 999;   // CH0 period: 1MHz/1000 = 1kHz
*(volatile uint32_t*)(PWM_BASE + 0x01C) = 499;   // CH0 pulse: 50% duty
*(volatile uint32_t*)(PWM_BASE + 0x014) = 0x1;   // CH0 enable
```

### SPI0 (N only)

**Base**: 0xF0005000

Source: `digital-twin/gen_n/WishboneSpiController.v` (simplified — consult Verilog for exact layout)

| Offset | Register | Access | Description |
|--------|----------|--------|-------------|
| 0x000 | IP Header | RO | Peripheral ID |
| ... | ... | ... | Additional registers — see Verilog source |
| 0x050 | CMD FIFO | R/W | Command FIFO interface |

**Command FIFO Format** (32-bit writes to offset 0x050):
```
[29:28] = Mode (00=DATA, 01=CS, 10=DUMMY)
DATA: [24]=read_flag, [7:0]=data
CS:   [24]=enable, [3:0]=cs_index
```

### UART0 (Full)

**Base**: 0xF0004000 (H) / 0xF0006000 (N)

Source: `digital-twin/gen/WishboneUart.v` (simplified — consult Verilog for exact layout)

| Offset | Register | Access | Description |
|--------|----------|--------|-------------|
| 0x000 | IP Header | RO | Peripheral ID |
| 0x004 | IP Version | RO | Version |
| 0x008 | Features | RO | Feature flags |
| ... | ... | ... | Additional registers — see Verilog source |

> **Note**: The UART controller has a complex register map with clock divider, frame config, status, TX/RX data, and FIFO registers. Consult `digital-twin/gen/WishboneUart.v` for the exact layout.

**Baud Rate Calculation**:
```
CLK_DIV = (Clock Frequency / Baud Rate) - 1

Example (50MHz, 115200):
CLK_DIV = (50000000 / 115200) - 1 = 433
```

### UART1 Lite (N only)

**Base**: 0xF0007000

Same controller RTL as UART0 but:
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

Source: `digital-twin/gen/WishbonePinmux.v`

> **Note**: Pinmux has no IP Header register. Registers start directly at offset 0x000.

| Offset | Register | Access | Description |
|--------|----------|--------|-------------|
| 0x000 | Pin 0 Option | R/W | 1-bit mux select for pin 0 |
| 0x004 | Pin 1 Option | R/W | 1-bit mux select for pin 1 |
| 0x008 | Pin 2 Option | R/W | 1-bit mux select for pin 2 |
| ... | ... | ... | ... |
| 0x02C | Pin 11 Option | R/W | 1-bit mux (H: last pin) |
| ... | ... | ... | ... |
| 0x04C | Pin 19 Option | R/W | 1-bit mux (N: last pin) |

Each pin has a 1-bit mux: option=0 selects the first function, option=1 selects the alternate function. The pin-to-peripheral mapping is defined in the SoC configuration (see `hardware/scala/elemrv_h/ElemRV.scala`).

### BmbSpiXip Banks (N only, co-simulated)

**Base**: 0xF000A000 (cfgSpi) / 0xF000A400 (cfgXip) / 0xF000B000 (XIP data)

Source: `digital-twin/scala/elemrv_n/WishboneBmbSpiXipControllerVerilog.scala` + `digital-twin/renode/verilated/wrappers/bmb_spi_xip_wrapper.cpp`.

Single `CoSimulatedPeripheral` muxing three internal buses via `ADR[10..11]` bank selection in the Scala wrapper. 4 KiB total = 1024 words per bank.

| Bank | Address Range | Access | Description |
|------|---------------|--------|-------------|
| 0 — cfgSpi | 0xF000A000 – 0xF000A3FF | R/W | SPI controller registers: IP header at +0x00 (id=6), cmd stream at +0x50 (write), response FIFO at +0x50 (read; bit 31 = valid, bits 7:0 = byte). See Phase G learnings in `MEMORY.md` for the cmd-stream encoding. |
| 1 — cfgXip | 0xF000A400 – 0xF000A7FF | R/W | XIP controller registers: readCommand `mode`/`dummyCycles`/`evcr` at +0x00, trigger at +0x08 (write starts a WREN + WRITE_REGISTER configure transaction; writes to this bank also invalidate the wrapper's fetch cache). |
| 2 — XIP data | 0xF000B000 – 0xF000BFFF | RO, executable-IO | Byte-addressable XIP mapping of the external flash. Reads go through the XIP state machine (cmd=0x03 by default; cmd=0xE7 after QPI handshake). CPU instruction fetch requires `cpu RegisterAccessFlags 0xF000B000 0x1000 true` in the `.resc` to set `IO_MEM_EXECUTABLE_IO` on the page. |

See [architecture.md](../architecture.md#wrapper-level-patterns-phase-g--phase-i--gap-32) for the sub-word shift, write-latch, fetch-cache invalidation, and QPI handshake patterns used by this wrapper.

## Platform Variants

### Base Platform (Minimal)

```
0x80000000 - 0x80001FFF: RAM (8KB)
0xA0000000 - 0xA000FFFF: Flash (64KB)
0xF0004000 - 0xF0004FFF: UART0 (LiteX model)
0xF0005000 - 0xF0005FFF: Timer0 (LiteX model)
```

### Zephyr Platform

Same as base plus full peripheral set with LiteX models:
```
0xF0000000 - 0xF0000FFF: GPIO0 (LiteX model)
0xF0001000 - 0xF0001FFF: I2C0 (LiteX model)
0xF0005000 - 0xF0005FFF: Timer0 (LiteX_Timer_CSR32)
```

### Full Co-simulation

All peripheral regions mapped to co-simulated RTL via Verilator.

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
// Returns 0x00080002 for PWM

// Write - RTL will ignore
*(volatile uint32_t*)0xF0003000 = 0x12345678;  // Ignored
```

### Write-Only Registers

Some registers (like UART TX) are write-only:
```c
// Write - OK
*(volatile uint32_t*)(0xF0004000 + TX_OFFSET) = 'A';
```

## GDB Memory Access

### Reading Registers

```gdb
# Read PWM IP Header (returns 0x00080002)
(gdb) x/1xw 0xF0003000

# Read GPIO pin values
(gdb) x/1xw 0xF000000C

# Dump PWM register region
(gdb) x/12xw 0xF0003000
```

### Writing Registers

```gdb
# Write PWM CH0 period
(gdb) set *(uint32_t*)0xF0003018 = 1000

# Or via Renode monitor
(gdb) mon sysbus WriteDoubleWord 0xF0003018 1000
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
