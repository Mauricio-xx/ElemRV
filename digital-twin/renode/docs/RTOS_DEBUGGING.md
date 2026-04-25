# RTOS-Level Debugging for ElemRV Digital Twin

This guide covers Zephyr RTOS debugging within the ElemRV digital twin,
from GDB thread inspection to on-target diagnostics and tracing.

## Quick Start

### ElemRV-H (RV32IC @ 50 MHz, 8KB RAM)

```bash
# Build the RTOS debug demo
cd software/elemrv-zephyr
west build -b elemrv_h app/rtos_debug_demo -d build-rtos-debug-demo

# Terminal 1: Start Renode with GDB server
cd renode
renode --disable-xwt --console -e "include @debug_zephyr_rtos.resc"

# Terminal 2: Connect GDB with thread-aware commands
riscv-none-elf-gdb -x gdb/elemrv.gdb \
    software/elemrv-zephyr/build-rtos-debug-demo/zephyr/zephyr.elf
```

### ElemRV-N (RV32IMC @ 20 MHz, 4KB RAM)

```bash
# Build the RTOS debug demo for N
cd software/elemrv-zephyr
west build -b elemrv_n app/rtos_debug_demo -d build-n-rtos-debug-demo

# Terminal 1: Start Renode with GDB server
cd renode
renode --disable-xwt --console -e "include @debug_zephyr_rtos_n.resc"

# Terminal 2: Connect GDB with thread-aware commands
riscv-none-elf-gdb -x gdb/elemrv.gdb \
    software/elemrv-zephyr/build-n-rtos-debug-demo/zephyr/zephyr.elf
```

### GDB Commands

```
(gdb) continue
# Let firmware run for ~3 seconds, then Ctrl-C
(gdb) zephyr-threads
(gdb) zephyr-stacks
```

## Level 1: Thread-Aware GDB

### Background

Renode 1.16.0's GDB server does not support native RTOS thread awareness
(tracked in Renode issue #637). The standard `info threads` command only
shows CPU cores, not Zephyr threads.

To work around this, the `renode/gdb/zephyr_threads.py` script reads
Zephyr's kernel data structures directly from memory using GDB's Python
API.

### How It Works

When `CONFIG_DEBUG_THREAD_INFO=y` is enabled, Zephyr exports a
`_kernel_openocd_offsets` array containing field offsets for thread
structures. The script:

1. Reads `_kernel_openocd_offsets` to learn struct layouts
2. Walks the `_kernel.threads` linked list via `next_thread` pointers
3. For each thread: reads name, state, priority, stack pointer
4. For stack measurement: scans for the `0xAAAAAAAA` sentinel pattern

### Commands

| Command | Description |
|---------|-------------|
| `zephyr-threads` | List all threads with name, state, priority, SP |
| `zephyr-stacks` | Show stack usage watermark for all threads |
| `zephyr-info` | Print available RTOS debug commands |

### Example Session

```
(gdb) zephyr-threads

=== Zephyr Threads (5 total) ===
Cur  Name                 State          Prio  SP           Address
------------------------------------------------------------------------
     sensor_thread        SLEEPING       5     0x80001234   0x80000a00
     uart_thread          SLEEPING       6     0x80001334   0x80000b00
     gpio_thread          SLEEPING       7     0x80001434   0x80000c00
  *  main                 QUEUED         0     0x80001534   0x80000d00
     idle                 QUEUED         15    0x80001634   0x80000e00

(gdb) zephyr-stacks

=== Zephyr Thread Stacks ===
Name                 Stack Base   Size     Used     Usage
----------------------------------------------------------------
sensor_thread        0x80000a00   256      112       43% [########............]
uart_thread          0x80000b00   256      96        37% [#######.............]
gpio_thread          0x80000c00   256      88        34% [######..............]
main                 0x80000d00   512      224       43% [########............]
idle                 0x80000e00   256      64        25% [#####...............]
```

### Required Kconfig

```ini
CONFIG_DEBUG_THREAD_INFO=y    # Exports _kernel_openocd_offsets
CONFIG_THREAD_MONITOR=y       # Enables _kernel.threads linked list
CONFIG_THREAD_NAME=y          # Thread names (default max 32 chars)
CONFIG_THREAD_STACK_INFO=y    # Stack base/size in thread struct
CONFIG_INIT_STACKS=y          # 0xAA sentinel for stack measurement
```

### Limitations

- Thread inspection is a snapshot at the point GDB interrupts execution.
  The firmware must be paused (Ctrl-C or breakpoint) before running
  `zephyr-threads`.
- Stack measurement via sentinel scanning may slightly overcount usage
  if a thread writes 0xAAAAAAAA to its stack.
- When Renode eventually adds native `info threads` support (issue #637),
  the Python script will still work but become redundant.

## Level 2: On-Target Diagnostics via UART

### Thread Analyzer

Zephyr's built-in thread analyzer reports thread names, states, and stack
usage via printk/UART.

**On-demand** (fits both H and N):
```ini
CONFIG_THREAD_ANALYZER=y
CONFIG_THREAD_ANALYZER_USE_PRINTK=y
```
```c
#include <zephyr/debug/thread_analyzer.h>
thread_analyzer_print();  // Call from any thread
```

**Auto mode** (H only — needs ~768B stack for analyzer thread):
```ini
CONFIG_THREAD_ANALYZER_AUTO=y
CONFIG_THREAD_ANALYZER_AUTO_INTERVAL=5     # Seconds between reports
CONFIG_THREAD_ANALYZER_AUTO_STACK_SIZE=768
```

### Logging

Minimal logging adds structured log output with minimal RAM overhead:
```ini
CONFIG_LOG=y
CONFIG_LOG_MODE_MINIMAL=y
```
```c
LOG_MODULE_REGISTER(my_module, LOG_LEVEL_INF);
LOG_INF("count=%d", value);
```

### Shell (ElemRV-H Only)

The Zephyr shell provides interactive kernel inspection via UART.
Requires ~1.5-2KB RAM — only fits on H (8KB).

```ini
CONFIG_SHELL=y
CONFIG_SHELL_MINIMAL=y
CONFIG_SHELL_STACK_SIZE=1024
CONFIG_SHELL_BACKEND_SERIAL=y
CONFIG_KERNEL_SHELL=y
```

**Useful shell commands:**
```
uart:~$ kernel threads     # List all threads
uart:~$ kernel stacks      # Show stack usage
uart:~$ kernel uptime      # Kernel uptime in ms
```

### Demo Apps

| App | Features | Board |
|-----|----------|-------|
| `rtos_debug_demo` | 3 named threads + on-demand analyzer | H + N |
| `rtos_diagnostics` | Auto thread analyzer + logging | H (auto), N (on-demand) |

## Level 3: Tracing

### Renode Execution Profiler

Renode provides an instruction-level execution profiler that requires
zero target RAM. Use it to trace every PC value executed:

```
# In Renode monitor (before starting simulation):
cpu EnableProfiler "trace.log"

# After simulation:
# trace.log contains PC values with timestamps
```

The profiler output can identify context switches by tracking when the
PC jumps between thread entry functions. This gives coarse thread
scheduling visibility without any firmware changes.

### CTF Tracing

Zephyr supports Common Trace Format (CTF) for kernel event tracing.

**Viability on ElemRV:**

| Feature | ElemRV-H (8KB) | ElemRV-N (4KB) |
|---------|----------------|----------------|
| CTF buffer (1-2KB) | Marginal | Not feasible |
| CTF over UART | Possible (shares console) | Not feasible |
| CTF over RAM dump | Possible (small buffer) | Not feasible |

CTF over UART interleaves binary trace data with console output, requiring
post-processing to separate. CTF over RAM dump captures a small ring buffer
that can be extracted via GDB after stopping execution.

**Configuration (if attempting):**
```ini
CONFIG_TRACING=y
CONFIG_TRACING_CTF=y
CONFIG_TRACING_BACKEND_UART=y
CONFIG_TRACING_BUFFER_SIZE=1024
```

### SystemView (SEGGER)

SystemView requires SEGGER RTT (Real-Time Transfer), which uses a
dedicated debug probe interface. Renode does not emulate RTT, so
SystemView is **not viable** in the digital twin.

### Future: Native Thread Awareness

When Renode adds native GDB RTOS thread awareness (issue #637), the
standard `info threads` GDB command will show Zephyr threads directly.
The `zephyr_threads.py` script will remain functional as a fallback.

## RAM Budget

| Feature | RAM Cost | ElemRV-H (8KB) | ElemRV-N (4KB) |
|---------|----------|----------------|----------------|
| Zephyr baseline (XIP) | ~2.0 KB | OK | OK |
| Thread (256B stack) | ~0.3 KB | OK | OK |
| Thread name (32 chars) | ~0.04 KB | OK | OK |
| Thread analyzer (on-demand) | ~0 | OK | OK |
| Thread analyzer (auto) | ~0.5 KB | OK | Tight |
| Shell (minimal) | ~1.5 KB | OK | No |
| Logging (minimal) | ~0.2 KB | OK | OK |
| CTF buffer | ~1-2 KB | Marginal | No |

**Example budgets:**

- `rtos_debug_demo`: baseline + 3 threads = ~2.9 KB (fits both)
- `rtos_diagnostics` on H: baseline + 2 threads + auto analyzer = ~4.7 KB
- `rtos_diagnostics` on N: baseline + 2 threads = ~3.7 KB

## Kconfig Quick Reference

| Option | Purpose | RAM Impact |
|--------|---------|------------|
| `CONFIG_DEBUG_THREAD_INFO` | Export offsets for GDB | Minimal |
| `CONFIG_THREAD_MONITOR` | Thread linked list | Minimal |
| `CONFIG_THREAD_NAME` | Thread name strings | ~32B/thread |
| `CONFIG_THREAD_STACK_INFO` | Stack base/size in struct | ~8B/thread |
| `CONFIG_INIT_STACKS` | 0xAA sentinel for measurement | 0 (init only) |
| `CONFIG_THREAD_ANALYZER` | Thread analyzer subsystem | ~0.2 KB |
| `CONFIG_THREAD_ANALYZER_AUTO` | Periodic auto-reporting | ~0.5 KB |
| `CONFIG_SHELL` | Interactive shell | ~1.5 KB |
| `CONFIG_KERNEL_SHELL` | Kernel debug shell commands | ~0.3 KB |
| `CONFIG_LOG` | Logging subsystem | ~0.2 KB |
| `CONFIG_LOG_MODE_MINIMAL` | Minimal log mode | Least overhead |
| `CONFIG_TRACING` | Kernel event tracing | ~1-2 KB |

## Taskfile Commands

```bash
task dt-rtos-debug        # Start Renode + GDB server for H RTOS debugging
task dt-n-rtos-debug      # Start Renode + GDB server for N RTOS debugging
task dt-rtos-test         # Run RTOS debug tests (Tests 41-46)
task dt-debug-connect ELF=software/elemrv-zephyr/build-rtos-debug-demo/zephyr/zephyr.elf
```

## Test Coverage

| Test | Name | Validates |
|------|------|-----------|
| 41 | RTOS Debug Demo | Multi-thread creation, thread analyzer output (H) |
| 42 | RTOS Diagnostics | Auto analyzer, logging (H) |
| 43 | RTOS GDB Threads | Debug symbols present, thread metadata in output (H) |
| 44 | N RTOS Debug Demo | Multi-thread creation, thread analyzer output (N) |
| 45 | N RTOS Diagnostics | On-demand analyzer, no shell (N) |
| 46 | N RTOS GDB Threads | Debug symbols present, thread metadata in output (N) |
