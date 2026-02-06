# Session 024 — C4: Custom WishbonePwm Zephyr Driver

**Date**: 2026-02-06
**Phase**: C4 (Stage 024)
**Status**: Complete

## Goal

Write a Zephyr PWM driver for the AESC WishbonePwm controller and validate it
on the Renode digital twin.

## Deliverables

| File | Action |
|------|--------|
| `dts/bindings/pwm/aesc,wishbone-pwm.yaml` | Created — DT binding |
| `drivers/pwm/pwm_wishbone.c` | Created — Zephyr PWM API driver |
| `drivers/pwm/Kconfig` | Created |
| `drivers/pwm/CMakeLists.txt` | Created |
| `dts/riscv/riscv32-elemrv-vexriscv.dtsi` | Modified — added pwm0 node |
| `boards/aesc/elemrv_h/elemrv_h.dts` | Modified — enabled pwm0 |
| `boards/aesc/elemrv_h/elemrv_h_defconfig` | Modified — CONFIG_PWM=y |
| `Kconfig` (module root) | Modified — rsource drivers/pwm/Kconfig |
| `CMakeLists.txt` (module root) | Modified — add_subdirectory drivers/pwm |
| `app/pwm_test/` | Created — test app (CH0/CH1, disable, invert, error cases) |
| `renode/run_zephyr_pwm.resc` | Created — Renode test script |
| `renode/run_tests.sh` | Modified — added Test 6 |

## Key Design Decisions

1. **Volatile pointer MMIO** instead of `sys_write32` — the latter doesn't resolve
   when compiled as a Zephyr module library. Used `pwm_reg_write()` inline helper
   with direct `*(volatile uint32_t *)` access.

2. **`#pwm-cells = <2>`** — channel + flags, standard Zephyr PWM binding pattern.

3. **DEVICE_MMIO_ROM/RAM** pattern for base address from DT.

## Test Results

```
PWM clock: 50000000 Hz
CH0: period=50000 pulse=25000 (1 kHz, 50%)
CH1: period=5000 pulse=1250 (10 kHz, 25%)
CH0 disabled OK
CH0 inverted polarity OK
Invalid channel rejected OK
Overflow rejected OK
PWM Driver Test PASSED
```

Full suite: 6/6 passed (base, PWM co-sim, hello_world, blinky, i2c_scan, pwm_test).
