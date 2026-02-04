# Session 002: Base Platform

**Date**: 2025-02-04  
**Branch**: dev-mont/digital-twin

## Summary

Created the base platform description for ElemRV-H in Renode. This minimal configuration includes the CPU, RAM, and FLASH memory regions, providing a bootable foundation for future peripheral additions.

## Files Changed

- `renode/platforms/elemrv_h.repl` - Platform description file defining:
  - VexRiscv CPU (RV32IC @ 50 MHz)
  - 8 KB RAM at 0x80000000
  - 64 KB FLASH at 0xA0000000
- `renode/scripts/elemrv_h.resc` - Startup script for loading the platform

## Platform Details

### CPU
- Type: VexRiscv
- ISA: RV32IC (32-bit RISC-V with Integer and Compressed extensions)
- Frequency: 50 MHz

### Memory Map
| Region | Address | Size |
|--------|---------|------|
| RAM (OCRAM) | 0x80000000 | 8 KB |
| FLASH | 0xA0000000 | 64 KB |

### Peripherals
None yet - will be added in subsequent stages:
- Stage 003: GPIO
- Stage 004: UART
- Stage 005: I2C
- Stage 006: PWM
- Stage 007: PIO
- Stage 008: Pinmux

## Usage

### Load the platform in Renode:
```bash
renode scripts/elemrv_h.resc
```

### Or manually:
```renode
mach create "elemrv-h"
machine LoadPlatformDescription @platforms/elemrv_h.repl
```

### Load firmware (when available):
```renode
sysbus LoadBinary @firmware.bin 0xA0000000
cpu PC 0xA0000000
start
```

## Commit

```
002: Add ElemRV-H base platform
```

## Testing

- [ ] Platform loads without errors in Renode
- [ ] Machine creates successfully
- [ ] Memory regions accessible

## Next Stage

**Stage 003**: Add GPIO peripheral support with basic blink test.

## Technical Notes

### Memory Layout Matches Firmware

The memory layout matches the linker script in `software/elemrv_h/demo/kernel.ld`:
```ld
MEMORY
{
    OCRAM (xrw): ORIGIN = 0x80000000, LENGTH = 8k
    FLASH (xr ): ORIGIN = 0xA0000000, LENGTH = 64k
}
```

### CPU Configuration

VexRiscv is configured for RV32IC (no M, A, F, D extensions):
- RV32I: Base 32-bit integer ISA
- C: Compressed instructions (16-bit)

This matches the SpinalHDL configuration in `ElemRV.scala` where no specific ISA extensions are enabled beyond the base.

### Future Enhancements

1. **Peripheral Bus**: Currently direct sysbus mapping. May use Wishbone bridge later.
2. **Reset Vector**: PC initialization at FLASH start (0xA0000000)
3. **Stack**: Software initializes stack at end of RAM (0x80000000 + 8KB)

### Known Limitations

- No peripherals implemented yet
- Cannot run existing firmware (requires GPIO, UART, etc.)
- No interrupt controller (PLIC/CLINT) yet

### Related Documentation

- [Renode Platform Description](https://renode.readthedocs.io/en/latest/basic/describing-platforms.html)
- [VexRiscv CPU Model](https://renode.readthedocs.io/en/latest/basic/configuring-a-risc-v-cpu.html)
