# Session 025 — C5: Custom WishbonePio Zephyr Driver

**Date**: 2026-02-06
**Phase**: C5 (Stage 025)
**Status**: Complete

## Goal

Write a Zephyr driver for the AESC WishbonePio programmable I/O controller.
Since PIO has no standard Zephyr subsystem, expose a custom API.

## Register Map (from PioCtrl.scala RTL)

| Offset | Field | Access | Description |
|--------|-------|--------|-------------|
| 0x00 | IP Header | RO | 0x00080001 |
| 0x04 | IP Version | RO | 0x01000000 |
| 0x08 | Config Info | RO | readBufDepth[31:24] clkDivW[23:16] dataW[15:8] ioW[7:0] |
| 0x0C | FIFO Config | RO | readFifoDepth[15:8] cmdFifoDepth[7:0] |
| 0x10 | Permissions | RO | bit[0] = busCanWriteClkDiv |
| 0x14 | Cmd/Result | W: cmdFIFO, R: valid[16] result[0] |
| 0x18 | FIFO Status | RO | occupancy[31:24] vacancy[23:16] |
| 0x1C | Clock Divider | RW | 20-bit |
| 0x20 | Read Delay | RW | 8-bit |

Command encoding: `[1:0]=type [3:2]=pin [27:4]=data`

## Deliverables

| File | Action |
|------|--------|
| `dts/bindings/misc/aesc,wishbone-pio.yaml` | Created — DT binding |
| `include/elemrv/drivers/pio.h` | Created — custom API header |
| `drivers/pio/pio_wishbone.c` | Created — driver implementation |
| `drivers/pio/Kconfig` | Created |
| `drivers/pio/CMakeLists.txt` | Created |
| `dts/riscv/riscv32-elemrv-vexriscv.dtsi` | Modified — added pio0 node |
| `boards/aesc/elemrv_h/elemrv_h.dts` | Modified — enabled pio0 |
| `Kconfig` (module root) | Modified — rsource drivers/pio/Kconfig |
| `CMakeLists.txt` (module root) | Modified — zephyr_include_directories + add_subdirectory |
| `app/pio_test/` | Created — test app |
| `renode/run_zephyr_pio.resc` | Created — Renode test script |
| `renode/run_tests.sh` | Modified — added Test 7 |

## Key Design Decisions

1. **Custom API** (`elemrv/drivers/pio.h`) since no Zephyr PIO subsystem exists.
   Functions: `pio_send_cmd()`, `pio_read_result()`, `pio_get_fifo_status()`,
   `pio_set_clock_divider()`, `pio_set_read_delay()`.

2. **Module-wide include dir** via `zephyr_include_directories(include)` in root
   CMakeLists.txt — makes `elemrv/drivers/pio.h` available to both driver and apps.

3. **No DEVICE_API** — PIO doesn't fit a standard Zephyr subsystem, so the device
   is registered with `NULL` API pointer. API functions take `const struct device *`.

4. **Renode Tag caveat**: PIO0 is a tagged region in Renode (no RTL model), so writes
   are silently absorbed and reads return 0. Test validates API paths and error checking.

## Build Fix

- Missing `#include <errno.h>` in driver — EINVAL not declared. Added include.

## Test Results

```
Clock divider set to 100 OK
Read delay set to 4 OK
CMD HIGH pin 0 OK
CMD LOW pin 1 OK
CMD WAIT 100 cycles OK
CMD READ pin 2 OK
Read result: valid=0 value=0 OK
FIFO: vacancy=0 occupancy=0 OK
Invalid pin rejected OK
Clock divider overflow rejected OK
PIO Driver Test PASSED
```

Full suite: 7/7 passed.
