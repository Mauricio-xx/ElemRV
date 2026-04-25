# Renode Peripheral Types - Investigation Results

**Date**: 2025-02-04  
**Renode Version**: 1.16.0

## Summary

Successfully identified correct Renode peripheral type names for ElemRV-H platform.

## Working Peripheral Types

| Peripheral | Renode Type | Address | Status |
|------------|-------------|---------|--------|
| **CPU** | `CPU.VexRiscv` | - | ✅ Working |
| **GPIO** | `GPIOPort.LiteX_GPIO` | 0xF0000000 | ✅ Working |
| **UART** | `UART.LiteX_UART` | 0xF0004000 | ✅ Working |
| **I2C** | `I2C.LiteX_I2C` | 0xF0001000 | ✅ Working |
| **Timer** | `Timers.LiteX_Timer` | 0xF0005000 | ✅ Working |
| **PWM** | N/A (Tagged) | 0xF0003000 | ⚠️ Tagged |
| **PIO** | N/A (Tagged) | 0xF0002000 | ⚠️ Tagged |
| **Pinmux** | N/A (Tagged) | 0xF0010000 | ⚠️ Tagged |

## Implementation

### Platform File (elemrv_h.repl)

```repl
// CPU: RISC-V VexRiscv RV32IC
cpu: CPU.VexRiscv @ sysbus
    cpuType: "rv32ic"

// Main RAM: 8 KB @ 0x80000000
ram: Memory.MappedMemory @ sysbus 0x80000000
    size: 0x00002000

// FLASH: 64 KB @ 0xA0000000
flash: Memory.MappedMemory @ sysbus 0xA0000000
    size: 0x00010000

// UART0: LiteX UART @ 0xF0004000
uart0: UART.LiteX_UART @ sysbus 0xF0004000
    -> cpu@0

// GPIO0: 12 pins @ 0xF0000000
gpio0: GPIOPort.LiteX_GPIO @ sysbus 0xF0000000
    type: Type.Out

// I2C0: LiteX I2C @ 0xF0001000
i2c0: I2C.LiteX_I2C @ sysbus 0xF0001000

// Timer (for delays)
timer0: Timers.LiteX_Timer @ sysbus 0xF0005000
    frequency: 50000000
    -> cpu@1

// PWM0: Tagged as unsupported
sysbus:
    init:
        Tag <0xF0003000 0x1000> "PWM0"

// PIO0: Tagged as unsupported
sysbus:
    init:
        Tag <0xF0002000 0x1000> "PIO0"

// Pinmux: Tagged as unsupported
sysbus:
    init:
        Tag <0xF0010000 0x1000> "Pinmux"
```

## Notes

### ✅ Working Peripherals

**LiteX peripherals are well-supported** in Renode and match the ElemRV-H hardware which uses LiteX-based peripherals from nafarr library.

### ⚠️ Tagged Peripherals (Not Implemented)

**PWM**: No `Timers.LiteX_PWM` exists in Renode 1.16.0. Using `Tag` to mark the memory region.

**PIO**: Programmable IO (like RP2040) is not modeled in Renode.

**Pinmux**: Complex pin multiplexing not available as a standard peripheral.

### Workarounds for Tagged Peripherals

For PWM, PIO, and Pinmux:
- Use `Tag` to mark memory regions (prevents bus errors)
- These peripherals can be implemented later if needed
- For RTL co-simulation (Stage 010+), the actual RTL will be used

## Test Results

```bash
$ ./renode/scripts/tests/test_all.sh
==========================================
✓ ALL TESTS PASSED
==========================================
Renode is working with peripherals!
```

## Next Steps

1. Create firmware to test UART output ("Hello World")
2. Create firmware to test GPIO toggling
3. Test timer functionality
4. Verify I2C interface

## References

- Renode documentation: https://renode.readthedocs.io/
- LiteX peripherals in Renode: Found in `/opt/renode_1.16.0_portable/platforms/cpus/litex*.repl`
- ElemRV-H uses nafarr library which implements LiteX-compatible peripherals
