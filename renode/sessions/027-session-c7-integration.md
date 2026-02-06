# Session 027 — C7: Integration Tests + CI

**Date**: 2026-02-06
**Phase**: C7 (Stage 027)
**Status**: Complete

## Goal

Integrate all Zephyr apps into CI pipeline with automated build and test.

## Deliverables

| File | Action |
|------|--------|
| `software/elemrv-zephyr/build_all_apps.sh` | Created — builds all 6 Zephyr apps |
| `.github/workflows/digital-twin-tests.yaml` | Updated — Zephyr init/build/test steps |
| `Taskfile.yml` | Updated — dt-zephyr-init, dt-zephyr-build, dt-zephyr-test |
| `renode/docs/DEVLOG.md` | Updated — C7 complete, Phase C summary |

## CI Pipeline (Updated)

```
1. Build simulation container (Dockerfile.simulation)
2. Start container with workspace mount
3. Configure git safe directories (for west in volumes)
4. Build bare-metal firmware (pwm_test, pwm_regtest)
5. Build verilated PWM library (libpwm.so)
6. Initialize Zephyr workspace (west init + west update)
7. Build all Zephyr apps (build_all_apps.sh → 6 apps)
8. Run digital twin tests (run_tests.sh → 8 tests)
9. Collect and upload test logs (8 log files)
```

## Taskfile Tasks

| Task | Description |
|------|-------------|
| `dt-build-firmware` | Build bare-metal firmware |
| `dt-build-verilated` | Build Verilator co-sim libraries |
| `dt-zephyr-init` | Initialize west workspace + fetch Zephyr |
| `dt-zephyr-build` | Build all 6 Zephyr apps |
| `dt-zephyr-test` | Build everything + run full 8-test suite |
| `dt-test` | Build bare-metal + verilated + run tests |
| `dt-test-quick` | Run tests without rebuilding |

## Test Suite (8/8 passing)

| # | Test | Type | App |
|---|------|------|-----|
| 1 | Base Platform | bare-metal | test_base.resc |
| 2 | PWM Co-simulation | bare-metal + co-sim | run_pwm_test.resc |
| 3 | Zephyr Hello World | Zephyr UART | hello_world |
| 4 | Zephyr Blinky | Zephyr GPIO+Timer | blinky |
| 5 | Zephyr I2C Scan | Zephyr I2C | i2c_scan |
| 6 | Zephyr PWM Driver | Zephyr custom | pwm_test |
| 7 | Zephyr PIO Driver | Zephyr custom | pio_test |
| 8 | Zephyr Pinmux Driver | Zephyr custom | pinmux_test |

## Phase C Complete

All 7 sub-phases (C1–C7) delivered. ElemRV-H digital twin now has:
- Full Zephyr RTOS support (out-of-tree module, custom SoC, XIP)
- All peripherals: UART, GPIO, Timer, I2C, PWM, PIO, Pinmux
- 3 custom Zephyr drivers with DT bindings and test apps
- Automated CI pipeline: build → test → artifact collection
