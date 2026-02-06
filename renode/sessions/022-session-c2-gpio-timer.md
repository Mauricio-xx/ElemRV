# Session 022: C2 — GPIO + Timer Drivers

**Date**: 2026-02-06
**Phase**: C2

## Summary

Enabled GPIO output and Timer-based `k_sleep` using upstream LiteX Zephyr drivers.
Fixed critical Renode timer model mismatch (8-bit vs 32-bit CSR width).

## Changes

- `elemrv_h.dts`: Enabled gpio0, added `leds` node + `led0` alias (pin 0)
- `elemrv_h_defconfig`: Added `CONFIG_GPIO=y`
- `elemrv_h_zephyr.repl`: Changed `LiteX_Timer` → `LiteX_Timer_CSR32`
  (matches ElemRV-H 32-bit CSR data width)
- New app: `app/blinky/` — toggles LED0 via GPIO + k_sleep(250ms)
- `run_tests.sh`: Added blinky test (Test 4)
- `.gitignore`: Updated pattern for multiple build dirs

## Key Finding: Timer CSR Width Mismatch

The Zephyr SoC uses `LITEX_CSR_DATA_WIDTH = 32` (matching real ElemRV-H hardware).
Renode's `Timers.LiteX_Timer` model expects 8-bit CSR layout (4 sub-registers per
32-bit value). Writing 32-bit values to an 8-bit model produces "Unhandled bits"
warnings and the timer fails to generate interrupts — `k_sleep()` hangs.

**Fix**: Renode provides `Timers.LiteX_Timer_CSR32` specifically for 32-bit CSR width.
Switching the model in `elemrv_h_zephyr.repl` fixed the issue immediately.

## Memory Usage (blinky)

```
ROM: 11396 B (17.39% of 64 KB Flash)
RAM:  2476 B (30.22% of 8 KB SRAM)
```

## Verification

- 8 GPIO toggles at ~260ms intervals (250ms k_sleep + overhead)
- Timer interrupts fire correctly (verified by consistent toggle timing)
- Test suite: 4/4 passed

## Next Stage

023 (C3): Enable I2C driver using upstream LiteX I2C driver.
