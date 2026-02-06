# Session 023: C3 — I2C Driver

**Date**: 2026-02-06
**Phase**: C3

## Summary

Enabled LiteX I2C bit-bang driver. Fixed critical `soc.h` bug where
`litex_read8`/`litex_write8` used byte bus access regardless of CSR width.

## Changes

- `elemrv_h.dts`: Enabled i2c0
- `elemrv_h_defconfig`: Added `CONFIG_I2C=y`
- `soc.h`: Fixed `litex_read8`/`write8`/`read16`/`write16` to use 32-bit
  bus access when `LITEX_CSR_DATA_WIDTH >= 32`
- New app: `app/i2c_scan/` — scans I2C bus addresses 0x08–0x77
- `run_tests.sh`: Added I2C scan test (Test 5)

## Key Finding: soc.h CSR Bus Width Bug

The `litex_read8`/`litex_write8` functions always used `sys_read8`/`sys_write8`
(byte bus access), even with `LITEX_CSR_DATA_WIDTH = 32`. The Renode LiteX_I2C
model requires 32-bit word access — byte access triggers "Attempted Byte
read/write isn't supported" warnings and garbles I2C transactions.

**Fix**: Gate `litex_read8`/`write8`/`read16`/`write16` on CSR width:
- CSR width >= 32: use `sys_read32`/`sys_write32` with masking
- CSR width == 8: use `sys_read8`/`sys_write8` (original behavior)

This also fixes potential issues with the UART driver (which uses litex_write8
for TX data) — previously worked by coincidence.

## Memory Usage (i2c_scan)

```
ROM: 11960 B (18.25% of 64 KB Flash)
RAM:  2492 B (30.42% of 8 KB SRAM)
```

## Verification

- I2C driver initializes, scan completes (0 devices found — no slaves connected)
- No byte-access warnings in Renode log
- Test suite: 5/5 passed

## Next Stage

024 (C4): Custom WishbonePwm Zephyr driver.
