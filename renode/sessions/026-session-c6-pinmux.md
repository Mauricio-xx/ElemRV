# Session 026 — C6: Custom WishbonePinmux Zephyr Driver

**Date**: 2026-02-06
**Phase**: C6 (Stage 026)
**Status**: Complete

## Goal

Write a Zephyr driver for the AESC WishbonePinmux pin multiplexer controller.
Routes internal peripheral signals to physical pins.

## Register Map (from PinmuxCtrl.scala RTL)

One R/W register per pin at offset `pin * 4`. Each register holds
`log2Up(options)` bits selecting the mux option. For ElemRV-H: 12 pins,
2 options each = 1 bit per register. Default on reset: 0 (option 0).

### ElemRV-H Pin Mapping

| Pin | Option 0 | Option 1 |
|-----|----------|----------|
| 0 | gpio0_0 | pwm0_0 |
| 1 | gpio0_1 | pio0_0 |
| 2 | gpio0_2 | pio0_1 |
| 3 | gpio0_3 | pio0_2 |
| 4 | uart0_tx | gpio0_4 |
| 5 | uart0_rx | gpio0_5 |
| 6 | uart0_cts | gpio0_6 |
| 7 | uart0_rts | gpio0_7 |
| 8 | gpio0_8 | pwm0_1 |
| 9 | gpio0_9 | i2c0_scl |
| 10 | gpio0_10 | i2c0_sda |
| 11 | gpio0_11 | i2c0_int |

## Deliverables

| File | Action |
|------|--------|
| `dts/bindings/pinctrl/aesc,wishbone-pinmux.yaml` | Created — DT binding |
| `include/elemrv/drivers/pinmux.h` | Created — custom API header |
| `drivers/pinctrl/pinmux_wishbone.c` | Created — driver implementation |
| `drivers/pinctrl/Kconfig` | Created |
| `drivers/pinctrl/CMakeLists.txt` | Created |
| `dts/riscv/riscv32-elemrv-vexriscv.dtsi` | Modified — added pinmux node |
| `boards/aesc/elemrv_h/elemrv_h.dts` | Modified — enabled pinmux |
| `Kconfig` (module root) | Modified — rsource drivers/pinctrl/Kconfig |
| `CMakeLists.txt` (module root) | Modified — add_subdirectory drivers/pinctrl |
| `app/pinmux_test/` | Created — test app |
| `renode/run_zephyr_pinmux.resc` | Created — Renode test script |
| `renode/run_tests.sh` | Modified — added Test 8 |

## Key Design Decisions

1. **Custom API** (`elemrv/drivers/pinmux.h`) with `pinmux_set_option()`,
   `pinmux_get_option()`, `pinmux_get_num_pins()`, `pinmux_get_num_options()`.

2. **PRE_KERNEL_1 init priority** — pinmux should be configured before peripheral
   drivers initialize so pin routing is in place when peripherals start.

3. **DT properties** `num-pins` and `num-options` make the driver generic for both
   ElemRV-H (12 pins, 2 options) and ElemRV-N (20 pins, 2 options).

## Test Results

```
Pinmux: 12 pins, 2 options each
Config check OK
Pin 0 -> option 1 (pwm0_0) OK
Pin 0 readback: option=0 OK
Pin 9 -> option 1 (i2c0_scl) OK
Pin 10 -> option 1 (i2c0_sda) OK
Pin 4 -> option 0 (uart0_tx) OK
Pins 1-3 -> option 1 (pio0_0..2) OK
Invalid pin rejected OK
Invalid option rejected OK
Pinmux Driver Test PASSED
```

Full suite: 8/8 passed.
