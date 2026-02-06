# ElemRV Digital Twin - Project Plan

> Master plan for Renode-based digital twin of ElemRV-H (Hydrogen platform)
> PDK Focus: IHP SG13G2

---

## Architecture Overview

**Platform**: Hydrogen (simpler than Nitrogen)  
**CPU**: VexRiscv RV32IC @ 50 MHz  
**Bus**: Wishbone  
**Total Peripherals**: 6

### Memory Map

| Region | Address | Size | Notes |
|--------|---------|------|-------|
| OCRAM (RAM) | 0x80000000 | 8 KB | Main memory |
| FLASH | 0xA0000000 | 64 KB | Program storage |
| GPIO0 | 0xF0000000 | 4 KB | 12 GPIO pins |
| I2C0 | 0xF0001000 | 4 KB | I2C controller |
| PIO0 | 0xF0002000 | 4 KB | Programmable IO (3 pins) |
| PWM0 | 0xF0003000 | 4 KB | 2 PWM channels |
| UART0 | 0xF0004000 | 4 KB | Full UART |
| (Reserved) | 0xF0005000-0xF000F000 | - | - |
| Pinmux | 0xF0010000 | 4 KB | Pin multiplexing (12 pins, 24 options) |

### Peripherals Detail

| Peripheral | Pins/Channels | Interrupts | Notes |
|------------|---------------|------------|-------|
| GPIO0 | 12 pins | Yes | Basic digital IO |
| I2C0 | SCL, SDA | 1 | I2C controller |
| PIO0 | 3 pins | No | Programmable state machine |
| PWM0 | 2 channels | No | Pulse width modulation |
| UART0 | TX, RX, CTS, RTS | Yes | Full UART with flow control |
| Pinmux | 12 physical pins | No | Maps 24 internal signals |

### Interrupts

Total: 3 interrupts
- GPIO0
- I2C0
- UART0

### Pin Mapping (Pinmux Options)

| Pin | Option 0 | Option 1 | Option 2 |
|-----|----------|----------|----------|
| 0 | gpio0_0 | pwm0_0 | - |
| 1 | gpio0_1 | pio0_0 | - |
| 2 | gpio0_2 | pio0_1 | - |
| 3 | gpio0_3 | pio0_2 | - |
| 4 | uart0_tx | gpio0_4 | - |
| 5 | uart0_rx | gpio0_5 | - |
| 6 | uart0_cts | gpio0_6 | - |
| 7 | uart0_rts | gpio0_7 | - |
| 8 | gpio0_8 | pwm0_1 | - |
| 9 | gpio0_9 | i2c0_scl | - |
| 10 | gpio0_10 | i2c0_sda | - |
| 11 | gpio0_11 | i2c0_interrupt_0 | - |

---

## Stage-Based Implementation

### Phase 1: Functional Simulation

| Stage | Name | Deliverable | Description |
|-------|------|-------------|-------------|
| 001 | Infrastructure | Docker + Renode 1.16.0 + toolchain | Base simulation environment |
| 002 | Platform Base | `elemrv_h.repl` (CPU + RAM + FLASH) | Minimal bootable platform |
| 003 | GPIO | GPIO peripheral + blink test | Basic digital IO |
| 004 | UART | UART + hello_world firmware | Serial communication |
| 005 | I2C | I2C controller model | I2C bus support |
| 006 | PWM | PWM peripheral | Pulse width modulation |
| 007 | PIO | PIO peripheral | Programmable IO |
| 008 | Pinmux | Pinmux model | Pin multiplexing |
| 009 | Test Suite | Complete bash tests | Automated testing |

### Phase 2: RTL Co-simulation

| Stage | Name | Deliverable | Description |
|-------|------|-------------|-------------|
| 010 | Verilator Setup | RTL co-sim infrastructure | Build system for Verilator |
| 011 | GPIO RTL | Verilated GPIO | GPIO in RTL |
| 012 | UART RTL | Verilated UART | UART in RTL |
| 013 | I2C RTL | Verilated I2C | I2C in RTL |
| 014 | PWM RTL | Verilated PWM | PWM in RTL |
| 015 | PIO RTL | Verilated PIO | PIO in RTL |
| 016 | Pinmux RTL | Verilated Pinmux | Pinmux in RTL |
| 017 | Full RTL | Complete RTL co-simulation | All peripherals verilated |

### Phase 3: IHP Integration

| Stage | Name | Deliverable | Description |
|-------|------|-------------|-------------|
| 018 | IHP SG13G2 | PDK-specific models | SG13G2 integration |
| 019 | Mixed-Signal | Ngspice bridge (optional) | Analog co-simulation |
| 020 | CI/CD | GitHub Actions | Automated testing |

### Phase 4: Zephyr RTOS Integration

| Stage | Name | Deliverable | Description |
|-------|------|-------------|-------------|
| 021 | C1: West + BSP | West workspace, board def, UART boot | Zephyr boots hello_world on Renode |
| 022 | C2: GPIO + Timer | LiteX GPIO/Timer drivers enabled | Blinky + k_sleep validated |
| 023 | C3: I2C | LiteX I2C driver enabled | I2C scan app on Renode |
| 024 | C4: PWM Driver | Custom WishbonePwm Zephyr driver | PWM via Zephyr API, co-sim validated |
| 025 | C5: PIO Driver | Custom WishbonePio Zephyr driver | PIO register access on Renode |
| 026 | C6: Pinctrl | Custom WishbonePinmux pinctrl driver | Pin routing via Zephyr pinctrl API |
| 027 | C7: Integration | Full test suite + CI | Twister tests, CI pipeline green |

---

## Directory Structure

```
renode/
├── platforms/          # .repl hardware definitions
├── scripts/            # .resc startup scripts
│   └── tests/          # Bash test scripts
├── firmware/           # Test firmware
│   └── samples/
├── verilated/          # RTL co-simulation (Stage 011+)
├── sessions/           # Session logs
└── docs/               # Documentation
    ├── plan.md         # This file
    ├── memory-map.md   # Detailed memory map
    └── peripherals.md  # Peripheral documentation
```

---

## Commit Convention

Format: `<stage>: <imperative action>`

Examples:
- `001: Add Renode simulation infrastructure`
- `002: Add ElemRV-H base platform`
- `003: Add GPIO peripheral support`

---

## Session Logs

Each session creates: `renode/sessions/XXX-description.md`

Template:
```markdown
# Session XXX: [Title]
**Date**: YYYY-MM-DD

## Summary
Brief description

## Files Changed
- `file` - Description

## Commit
`XXX: [message]`
Hash: `abc123`

## Testing
- Test: Status

## Next Stage
Description

## Technical Notes
Context for future sessions
```

---

## References

- [ElemRV Repository](https://github.com/aesc-silicon/ElemRV)
- [Renode Documentation](https://renode.readthedocs.io/)
- [IHP Open PDK](https://github.com/IHP-GmbH/IHP-Open-PDK)
- [Hydrogen Platform](hardware/scala/elemrv_h/ElemRV.scala)
- [Firmware Samples](software/elemrv_h/)

---

**Current Stage**: 021 - Zephyr West + BSP
**Branch**: dev-mont/digital-twin
**Last Updated**: 2026-02-05
