# Session 021: Zephyr West Workspace + Board BSP + UART Console

**Date**: 2026-02-05
**Phase**: C1

## Summary

Set up Zephyr RTOS out-of-tree module for ElemRV-H. Created west workspace,
custom SoC definition (elemrv_vexriscv), board BSP, and hello_world app.
Zephyr boots on Renode and prints via UART console.

## Key Decisions

- **Custom SoC** (`elemrv_vexriscv`): ElemRV-H is RV32IC (no M extension),
  so upstream `litex_vexriscv` (RV32IM) can't be reused. Custom SoC selects
  correct ISA extensions and provides LiteX CSR access helpers in `soc.h`.
- **32 KB RAM in DTS**: Real hardware has 8 KB, but Zephyr minimal kernel
  needs ~12 KB. Using 32 KB in Renode simulation. Separate `.repl` file
  (`elemrv_h_zephyr.repl`) to not break existing bare-metal tests.
- **Module at `software/elemrv-zephyr/`**: Avoids name conflict with upstream
  `software/zephyr/` cloned by west. Workspace root is `software/`.
- **Zicsr warnings**: Renode 1.16.0 logs "Zicsr not enabled" for `rv32ic`
  CPUs but executes CSR instructions correctly. Added to test runner filter.

## Files Created

- `renode/docs/DEVLOG.md` — Master development log
- `software/elemrv-zephyr/west.yml` — West manifest (Zephyr v4.1.0)
- `software/elemrv-zephyr/zephyr/module.yml` — Module declaration
- `software/elemrv-zephyr/Kconfig` — Module Kconfig
- `software/elemrv-zephyr/CMakeLists.txt` — Module CMake
- `software/elemrv-zephyr/soc/aesc/elemrv_vexriscv/` — Custom SoC (6 files)
- `software/elemrv-zephyr/dts/riscv/riscv32-elemrv-vexriscv.dtsi` — SoC DTS
- `software/elemrv-zephyr/boards/aesc/elemrv_h/` — Board definition (6 files)
- `software/elemrv-zephyr/app/hello_world/` — Hello world app (3 files)
- `renode/platforms/elemrv_h_zephyr.repl` — Renode platform (32 KB RAM)
- `renode/run_zephyr_hello.resc` — Renode test script

## Files Modified

- `docker/Dockerfile.simulation` — Added Zephyr SDK, west, CMake, dtc, ninja
- `renode/docs/plan.md` — Added Phase C stages (021-027)
- `renode/run_tests.sh` — Added Zephyr test + Zicsr warning filter
- `.gitignore` — Added west workspace / build exclusions

## Testing

- Base Platform: PASS
- PWM Co-simulation: PASS
- Zephyr Hello World: PASS (3/3)

## UART Output

```
*** Booting Zephyr OS build v4.1.0 ***
Hello World! ElemRV-H on Zephyr
```

## Binary Size

- text: 9408, data: 152, bss: 2392 = 11952 bytes total
- RAM usage: 11960 B / 32 KB (36.5%)

## Next Stage

022 (C2): Enable GPIO + Timer drivers using upstream LiteX drivers.
