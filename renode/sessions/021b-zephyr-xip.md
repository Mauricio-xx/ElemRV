# Session 021b: Enable XIP — Match Real Hardware Memory

**Date**: 2026-02-05
**Phase**: C1b

## Summary

Enabled Execute-In-Place (XIP) so code runs from Flash (64 KB) and only
data lives in SRAM (8 KB), matching the real ElemRV-H hardware constraints.

## Changes

- `elemrv_h.dts`: Added `flash0` node at 0xA0000000, set `zephyr,flash`,
  restored RAM to 8 KB (0x2000)
- `elemrv_h_defconfig`: `CONFIG_XIP=y`
- `elemrv_h.yaml`: ram back to 8
- `elemrv_h_zephyr.repl`: RAM restored to 8 KB

## Memory Layout (XIP)

```
Flash (64 KB) @ 0xA0000000       RAM (8 KB) @ 0x80000000
┌────────────────────────┐       ┌────────────────────────┐
│ .text    9612 B (15%)  │       │ .data+.bss  2456 B     │
│ .rodata                │       │ .stack                 │
│                        │       │ .heap                  │
└────────────────────────┘       └────────────────────────┘
     CPU executes here                 30% used
```

## Verification

- PC addresses now in 0xA0001xxx (Flash), not 0x80001xxx (RAM)
- UART output: `*** Booting Zephyr OS build v4.1.0 ***` + `Hello World!`
- Test suite: 3/3 passed

## Next Stage

022 (C2): Enable GPIO + Timer drivers using upstream LiteX drivers.
