# GDB Interactive Debugging Guide

Debug firmware on the ElemRV Digital Twin using GDB with full peripheral visibility.

## Overview

Renode exposes a GDB server, allowing GDB to control execution while co-simulated peripherals respond with real RTL behavior. This guide covers setup, commands, and workflows.

## Quick Start

```bash
# Terminal 1: Start Renode with GDB server
task dt-debug-bare-metal

# Terminal 2: Connect GDB
task dt-debug-connect
```

GDB connects, loads symbols, and halts at the entry point.

## Debug Workflows

### Bare-metal Firmware

Simplest setup - base platform with LiteX models (no co-sim). Good for CPU/memory debugging.

```bash
# Start Renode
task dt-debug-bare-metal

# Connect with custom ELF
task dt-debug-connect ELF=software/elemrv_h/pwm_test/pwm_test.elf
```

**Use cases**:
- Algorithm debugging
- Memory corruption analysis
- CPU instruction tracing

### Zephyr RTOS

Uses `elemrv_h_zephyr.repl` platform with `LiteX_Timer_CSR32` for correct 32-bit CSR width. UART analyzer captures printk output in the Renode console.

```bash
# Start Renode
task dt-debug-zephyr

# Connect (default: build/zephyr/zephyr.elf)
task dt-debug-connect ELF=software/elemrv-zephyr/build/zephyr/zephyr.elf
```

**Use cases**:
- RTOS thread debugging
- Driver development
- System call tracing

### Full RTL Co-simulation

All 7 peripherals (GPIO, I2C, PIO, PWM, UART, Timer, Pinmux) respond with cycle-accurate Verilog via Verilator. Register reads return real RTL values.

```bash
# Build co-sim libraries first
task dt-cosim-build

# Start Renode with all 7 co-sim peripherals
task dt-debug-cosim

# Connect GDB
task dt-debug-connect
```

**Use cases**:
- Driver validation
- RTL verification
- Timing analysis

## GDB Convenience Commands

The `renode/gdb/elemrv.gdb` script is loaded automatically and provides peripheral register inspection commands.

### Peripheral Register Commands

| Command | Description |
|---------|-------------|
| `pwm-regs` | Dump PWM0 registers (header, clock div, CH0/CH1 control/period/duty) |
| `gpio-regs` | Dump GPIO0 registers (header, read/write/write-enable) |
| `pio-regs` | Dump PIO0 registers (header, config, IO status) |
| `i2c-regs` | Dump I2C0 registers (header, config, TX/RX data, command) |
| `uart-regs` | Dump UART0 registers (header, clock div, frame, TX/RX data) |
| `timer-regs` | Dump Timer0 registers (mtime, mtimecmp) |
| `pinmux-regs` | Dump Pinmux registers (pin 0-7 mux selection) |
| `periph-scan` | Read IP Header from all 7 peripherals |
| `memmap` | Print memory map summary |

### Example Output

```
(gdb) pwm-regs

=== PWM0 Registers (0xF0003000) ===
0x000 (IP Header):   0x00080002
0x004 (IP Version):  0x01000000
0x008 (IP Features): 0x14141402
0x00C (IP Status):   0x00000000
0x010 (Clk Div):     0x00000063  (99)
0x014 (CH0 Ctrl):    0x00000001  (Enabled)
0x018 (CH0 Period):  0x000003E8  (1000)
0x01C (CH0 Pulse):   0x000001F4  (500)
0x020 (CH1 Ctrl):    0x00000001  (Enabled)
0x024 (CH1 Period):  0x000000C8  (200)
0x028 (CH1 Pulse):   0x00000064  (100)
```

## Docker Access

### Inside the Container

```bash
# Terminal 1
docker exec -it elemrv-gui bash -c \
  'cd /workspace/elemrv/renode && renode --disable-xwt --console -e "include @debug_bare_metal.resc"'

# Terminal 2
docker exec -it elemrv-gui bash -c \
  'cd /workspace/elemrv && riscv-none-elf-gdb -x renode/gdb/elemrv.gdb software/elemrv_h/pwm_test/pwm_test.elf'
```

### From Host via Port 3333

The `docker-compose.yml` maps port 3333. If using the `elemrv-gui` container started via Taskfile, add `-p 3333:3333` to the docker run command.

```bash
# From host (requires riscv-none-elf-gdb installed locally)
riscv-none-elf-gdb -x renode/gdb/elemrv.gdb software/elemrv_h/pwm_test/pwm_test.elf
```

## Renode Monitor from GDB

The `mon` command sends any command to the Renode monitor:

```gdb
(gdb) mon start                              # start emulation
(gdb) mon sysbus ReadDoubleWord 0xF0003000   # read PWM IP Header
(gdb) mon machine GetTimeSourceInfo           # check virtual time
(gdb) mon logLevel 1 sysbus                  # increase log verbosity
```

## Memory Map Reference

| Address Range | Peripheral |
|---------------|------------|
| `0x80000000 - 0x80001FFF` | RAM (8 KB) |
| `0xA0000000 - 0xA000FFFF` | Flash (64 KB) |
| `0xF0000000 - 0xF0000FFF` | GPIO0 |
| `0xF0001000 - 0xF0001FFF` | I2C0 |
| `0xF0002000 - 0xF0002FFF` | PIO0 |
| `0xF0003000 - 0xF0003FFF` | PWM0 |
| `0xF0004000 - 0xF0004FFF` | UART0 |
| `0xF0005000 - 0xF0005FFF` | Timer0 |
| `0xF0010000 - 0xF0010FFF` | Pinmux |

## Debugging Tips

### Reading Peripheral Registers During Debug

With co-sim mode, GDB memory reads (`x/1xw 0xF0003000`) go through the Wishbone bus to the actual Verilator model. The value you see is the real RTL output - not a software model approximation.

```gdb
# Read PWM IP Header through RTL
(gdb) x/1xw 0xF0003000
0xf0003000: 0x00080002  # IP Header (read-only)
```

### Renode Stepping vs GDB Stepping

| Command | Behavior |
|---------|----------|
| **GDB `stepi`** | Steps one RISC-V instruction. Virtual time advances by the instruction's execution time. |
| **GDB `continue`** | Runs until a breakpoint. Virtual time advances continuously. |
| **Renode `emulation RunFor`** | Do not use this with GDB - let GDB control execution. |

### Co-sim Timing Behavior

Virtual time freezes when GDB halts the CPU. Peripheral state is frozen too - no spurious timer increments or UART shifts while you inspect registers. This makes debugging fully deterministic.

```
Before halt:
  Virtual time: 0.123456s
  PWM counter: 500

(gdb) Ctrl-C (halt)

During inspection:
  Virtual time: 0.123456s (frozen)
  PWM counter: 500 (frozen)

(gdb) continue

After continue:
  Virtual time resumes
  PWM counter increments normally
```

### Overriding the Firmware ELF

All debug scripts use `$elf ?=` (Renode's default-if-unset syntax). Override from the Renode command line:

```bash
renode --disable-xwt --console \
  -e '$elf = @../software/elemrv_h/pwm_test/pwm_regtest.elf' \
  -e 'include @debug_bare_metal.resc'
```

Or set environment variable:
```bash
export ELF=software/elemrv_h/pwm_test/pwm_test.elf
task dt-debug-connect
```

## Advanced GDB Usage

### Watchpoints

Monitor memory locations:
```gdb
# Break when PWM enable register changes
(gdb) watch *(uint32_t*)0xF0003000

# Break when GPIO input changes
(gdb) watch *(uint32_t*)0xF0000004
```

### Conditional Breakpoints

```gdb
# Break only when PWM CH0 period is set to specific value
(gdb) break main.c:45 if *(uint32_t*)0xF0003018 == 1000
```

### Backtraces

```gdb
# Show call stack
(gdb) bt

# Show all thread backtraces (when RTOS support available)
(gdb) thread apply all bt
```

### Memory Inspection

```gdb
# Examine memory
(gdb) x/10xw 0x80000000  # 10 words from RAM start
(gdb) x/100b 0xA0000000  # 100 bytes from Flash

# Disassemble
(gdb) disassemble 0xA0000000,+0x100
```

### Register Inspection

```gdb
# Show CPU registers
(gdb) info registers

# Show specific register
(gdb) print $pc
(gdb) print $x1
```

## Debugging Specific Scenarios

### Stack Overflow Detection

```gdb
# Check stack pointer
(gdb) print $sp

# Compare with stack base
(gdb) x/1xw _main_stack

# Look for stack corruption
(gdb) x/64xw $sp
```

### Memory Corruption

```gdb
# Set watchpoint on variable
(gdb) watch corrupted_var

# Or on memory region
(gdb) watch *(uint32_t*)0x80001000

# Continue and see who writes
(gdb) continue
```

### Peripheral Access Debugging

```gdb
# Verify peripheral is responding
(gdb) x/1xw 0xF0003000  # Should return non-zero (IP header)

# Check if IP header matches expected
(gdb) print/x *(uint32_t*)0xF0003000
$1 = 0x00080002  # PWM IP Header
```

## Troubleshooting

### GDB Connection Refused

```bash
# Check Renode is listening
lsof -i :3333

# Check port forwarding (Docker)
docker ps | grep 3333
```

### Symbols Not Loaded

```gdb
# Load symbols manually
(gdb) file software/elemrv_h/pwm_test/pwm_test.elf

# Or specify at connection
$ riscv-none-elf-gdb -x renode/gdb/elemrv.gdb firmware.elf
```

### Wrong Architecture

```gdb
# Verify target
(gdb) show architecture
# Should show: riscv:rv32

# Set manually if needed
(gdb) set architecture riscv:rv32
```

---

**Previous**: [RTOS Debugging](rtos-debugging.md)  
**Next**: [Fault Injection](fault-injection.md)
