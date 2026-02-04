# Session 003: GPIO Peripheral Support

**Date**: 2025-02-04  
**Branch**: dev-mont/digital-twin

## Summary

Added GPIO peripheral support to the ElemRV-H platform. Created a basic GPIO controller at address 0xF0000000 with 12 pins, along with test firmware and a test script for validation.

## Files Changed

### Platform
- `renode/platforms/elemrv_h.repl` - Added GPIO0 peripheral:
  - Address: 0xF0000000
  - Size: 4 KB (0x1000)
  - Pins: 12 (indices 0-11)
  - Type: Antmicro.Renode.Peripherals.GPIOPort

### Test Firmware
- `renode/firmware/samples/gpio_blink/gpio_blink.c` - Simple GPIO blink test:
  - Toggles GPIO pin 0
  - Direct register access to GPIO controller
  - Software delay loop
- `renode/firmware/samples/gpio_blink/link.ld` - Linker script (RAM @ 0x80000000)
- `renode/firmware/samples/gpio_blink/Makefile` - Build system for RISC-V GCC

### Test Script
- `renode/scripts/tests/test_gpio.sh` - Automated GPIO test:
  - Loads platform in Renode
  - Tests GPIO register read/write
  - Validates pin toggle functionality

## GPIO Register Map

Based on WishboneGpio from nafarr library and firmware analysis:

| Register | Offset | Description |
|----------|--------|-------------|
| GPIO_DIR | 0x00 | Direction: 1=output, 0=input |
| GPIO_VAL | 0x04 | Value register |
| GPIO_EN  | 0x08 | Output enable (optional) |

**Note**: The actual register offsets are inferred from the firmware code. The exact offsets may need adjustment when comparing with the actual RTL.

## Platform Usage

### Test GPIO from Renode Monitor
```renode
mach create "elemrv-h"
machine LoadPlatformDescription @platforms/elemrv_h.repl

# Set pin 0 as output
sysbus WriteDoubleWord 0xF0000000 0x01

# Set pin 0 HIGH
sysbus WriteDoubleWord 0xF0000004 0x01

# Read GPIO state
gpio0
```

### Run Test Script
```bash
cd renode/scripts/tests
./test_gpio.sh
```

### Build Firmware (in Docker container)
```bash
cd renode/firmware/samples/gpio_blink
make
# Produces: gpio_blink.bin
```

### Load and Run Firmware
```renode
mach create "elemrv-h"
machine LoadPlatformDescription @platforms/elemrv_h.repl
sysbus LoadBinary @gpio_blink.bin 0x80000000
cpu PC 0x80000000
start

# Monitor GPIO
gpio0
```

## Commit

```
003: Add GPIO peripheral support
```

## Testing

- [ ] Platform loads with GPIO
- [ ] GPIO register read/write works
- [ ] Firmware compiles
- [ ] Firmware runs and toggles GPIO

## Next Stage

**Stage 004**: UART peripheral support with "Hello World" firmware.

## Technical Notes

### GPIO Model

Using Renode's built-in `Antmicro.Renode.Peripherals.GPIOPort` which provides:
- Generic GPIO port with configurable number of pins
- Direction and value registers
- Interrupt support (if needed)

### Register Layout Assumptions

The firmware assumes GPIO registers at offsets:
- 0x00: Direction
- 0x04: Value

This is a common pattern for simple GPIO controllers. The actual RTL (WishboneGpio from nafarr) may have different offsets. Testing will confirm.

### Memory Layout for Firmware

The test firmware runs from RAM (0x80000000) instead of FLASH (0xA0000000) for simplicity:
- No need to initialize FLASH
- Direct execution from RAM
- Faster iteration for testing

Production firmware should run from FLASH as configured in the original ElemRV-H design.

### Build Requirements

To build the firmware, the RISC-V toolchain must be available:
```bash
riscv-none-elf-gcc --version
```

The toolchain is included in the Docker container from Stage 001.

### Future Improvements

1. **Verify register offsets** - Compare with actual WishboneGpio RTL
2. **Add interrupts** - GPIO interrupt support when interrupt controller is added
3. **Pinmux integration** - Connect GPIO pins to pinmux when implemented
4. **Automated testing** - Add to CI/CD pipeline

### Related Files

- `hardware/scala/elemrv_h/ElemRV.scala` - GPIO0 configuration
- `software/elemrv_h/demo/kernel.c` - Uses GPIO in existing firmware
- `modules/elements/nafarr/peripherals/io/gpio/` - WishboneGpio RTL
