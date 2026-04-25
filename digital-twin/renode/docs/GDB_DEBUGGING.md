# GDB Interactive Debugging Guide

Debug firmware on the ElemRV-H digital twin using GDB with full peripheral visibility.
Renode exposes a GDB server — GDB controls execution while co-simulated peripherals respond with real RTL behavior.

## Quick Start

```bash
# Terminal 1: Start Renode with GDB server
task dt-debug-bare-metal

# Terminal 2: Connect GDB
task dt-debug-connect
```

GDB connects, loads symbols, and halts at the entry point. Use standard GDB commands:

```gdb
(gdb) break main
(gdb) continue
(gdb) pwm-regs          # custom: dump PWM registers
(gdb) periph-scan       # custom: read IP headers from all peripherals
```

## Debug Workflows

### Bare-metal Firmware

Simplest setup — base platform with LiteX models (no co-sim). Good for CPU/memory debugging.

```bash
# Start Renode
task dt-debug-bare-metal

# Connect with custom ELF
task dt-debug-connect ELF=software/elemrv_h/pwm_test/pwm_test.elf
```

### Zephyr RTOS

Uses `elemrv_h_zephyr.repl` platform with `LiteX_Timer_CSR32` for correct 32-bit CSR width. UART analyzer captures printk output in the Renode console.

```bash
# Start Renode
task dt-debug-zephyr

# Connect (default: build/zephyr/zephyr.elf)
task dt-debug-connect ELF=software/elemrv-zephyr/build/zephyr/zephyr.elf
```

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

## GDB Convenience Commands

The `renode/gdb/elemrv.gdb` script is loaded automatically and provides:

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

## Docker Access

### Inside the container

```bash
# Terminal 1
docker exec -it elemrv-gui bash -c \
  'cd /workspace/elemrv/renode && renode --disable-xwt --console -e "include @debug_bare_metal.resc"'

# Terminal 2
docker exec -it elemrv-gui bash -c \
  'cd /workspace/elemrv && riscv-none-elf-gdb -x renode/gdb/elemrv.gdb software/elemrv_h/pwm_test/pwm_test.elf'
```

### From host via port 3333

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

## Tips

### Reading peripheral registers during debug

With co-sim mode, GDB memory reads (`x/1xw 0xF0003000`) go through the Wishbone bus to the actual Verilator model. The value you see is the real RTL output — not a software model approximation.

### Renode stepping vs GDB stepping

- **GDB `stepi`**: Steps one RISC-V instruction. Virtual time advances by the instruction's execution time.
- **GDB `continue`**: Runs until a breakpoint. Virtual time advances continuously.
- **Renode `emulation RunFor`**: Don't use this with GDB — let GDB control execution.

### Co-sim timing behavior

Virtual time freezes when GDB halts the CPU. Peripheral state is frozen too — no spurious timer increments or UART shifts while you inspect registers. This makes debugging fully deterministic.

### Overriding the firmware ELF

All debug scripts use `$elf ?=` (Renode's default-if-unset syntax). Override from the Renode command line:

```bash
renode --disable-xwt --console \
  -e '$elf = @../software/elemrv_h/pwm_test/pwm_regtest.elf' \
  -e 'include @debug_bare_metal.resc'
```
