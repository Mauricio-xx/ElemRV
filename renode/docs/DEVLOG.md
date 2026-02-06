# ElemRV Digital Twin - Development Log

> Concise tracker for all phases/sub-phases. Updated each session.

**Branch**: `dev-mont/digital-twin`
**Platform**: Hydrogen (ElemRV-H) — VexRiscv RV32IC @ 50 MHz, Wishbone bus

---

## Phase A: Debug & Validation
- [x] Fix PWM register map + co-sim wrapper — `0f46015`
- [x] Clean debug artifacts — `0f46015`

## Phase B: CI / Test Automation
- [x] Test runner script (`run_tests.sh`) — `00e1ab0`
- [x] Taskfile `dt-*` tasks — `00e1ab0`
- [x] docker-compose `gen/` mount — `00e1ab0`
- [x] GitHub Actions workflow — `00e1ab0`

## Phase C: Zephyr RTOS Integration
- [x] C1: West workspace + board BSP + UART console boot — `c70b265`
- [ ] C1b: Enable XIP — .text in Flash, restore 8 KB RAM to match real HW
- [ ] C2: GPIO + Timer drivers (LiteX)
- [ ] C3: I2C driver (LiteX)
- [ ] C4: Custom PWM Zephyr driver
- [ ] C5: Custom PIO Zephyr driver
- [ ] C6: Custom Pinmux/Pinctrl driver
- [ ] C7: Integration tests + CI
