# Session 004: UART Peripheral Support

**Date**: 2025-02-04  
**Branch**: dev-mont/digital-twin

## Summary

Added UART peripheral support to the ElemRV-H platform. Created a "Hello World" firmware that uses UART0 for serial communication, demonstrating output and input echo functionality.

## Files Changed

### Platform
- `renode/platforms/elemrv_h.repl` - Added UART0 peripheral:
  - Address: 0xF0004000
  - Size: 4 KB (0x1000)
  - Type: Antmicro.Renode.Peripherals.UART.LiteX_UART
  - Compatible with LiteX UART controller

### Test Firmware
- `renode/firmware/samples/hello_world/hello_world.c` - Hello World application:
  - Prints "Hello World from ElemRV-H!"
  - Echoes back received characters
  - Simple UART driver with TX/RX functions
- `renode/firmware/samples/hello_world/link.ld` - Linker script (RAM @ 0x80000000)
- `renode/firmware/samples/hello_world/Makefile` - Build system for RISC-V GCC

### Test Script
- `renode/scripts/tests/test_uart.sh` - Automated UART test:
  - Loads platform with UART in Renode
  - Connects UART to PTY terminal
  - Optionally loads and runs Hello World firmware

## UART Register Map

Based on LiteX UART specification (used by nafarr WishboneUart):

| Register | Offset | Description |
|----------|--------|-------------|
| UART_RXTX | 0x00 | TX data (write) / RX data (read) |
| UART_TXFULL | 0x04 | TX FIFO full flag (read-only) |
| UART_RXEMPTY | 0x08 | RX FIFO empty flag (read-only) |
| UART_EV_PENDING | 0x10 | Event pending status |
| UART_EV_ENABLE | 0x14 | Event enable |

## Platform Usage

### Test UART from Renode Monitor
```renode
mach create "elemrv-h"
machine LoadPlatformDescription @platforms/elemrv_h.repl

# Write a character (e.g., 'H' = 0x48)
sysbus WriteDoubleWord 0xF0004000 0x48

# Read UART status
sysbus ReadDoubleWord 0xF0004004  # TX full
sysbus ReadDoubleWord 0xF0004008  # RX empty

# Show UART state
uart0
```

### Run Test Script
```bash
cd renode/scripts/tests
./test_uart.sh
```

### Build and Run Hello World (in Docker container)
```bash
# Build firmware
cd renode/firmware/samples/hello_world
make

# Run in Renode
renode scripts/elemrv_h.resc

# In Renode console:
sysbus LoadBinary @hello_world.bin 0x80000000
cpu PC 0x80000000
emulation CreateUartPtyTerminal "uart0" "/tmp/uart0" True
connector Connect uart0 uart0
start

# In another terminal:
cat /tmp/uart0
```

## Commit

```
004: Add UART peripheral and hello_world sample
```

## Testing

- [ ] Platform loads with UART
- [ ] UART register read/write works
- [ ] Hello World firmware compiles
- [ ] Firmware outputs text to UART
- [ ] UART input echo works

## Next Stage

**Stage 005**: I2C controller support.

## Technical Notes

### UART Model

Using Renode's `Antmicro.Renode.Peripherals.UART.LiteX_UART` which provides:
- LiteX-compatible UART interface
- TX/RX FIFOs
- Status registers (TXFULL, RXEMPTY)
- PTY terminal connection for host I/O

### Register Layout

The firmware assumes LiteX-style UART registers:
- 0x00: TX/RX data
- 0x04: TX full status
- 0x08: RX empty status

This matches the nafarr `WishboneUart` peripheral which implements a LiteX-compatible interface.

### Baud Rate

Default baud rate is 115200. This is configured in the Renode UART model automatically.

### Host Connection

The test script connects UART to a PTY (pseudo-terminal) at `/tmp/uart0`:
- Firmware output appears on the PTY
- Input to the PTY is received by firmware
- Allows interaction with the simulated firmware

### UART vs GPIO

UART is more complex than GPIO because:
- Requires FIFO management
- Has flow control (TXFULL, RXEMPTY)
- Needs host connection for I/O
- Supports interrupts (when interrupt controller added)

### Build Requirements

Same as GPIO test - requires RISC-V toolchain:
```bash
riscv-none-elf-gcc --version
```

### Future Improvements

1. **Interrupt support** - Connect UART interrupts to PLIC when available
2. **Flow control** - Add CTS/RTS signal support
3. **Multiple UARTs** - ElemRV-N has UART1 which could be added later
4. **Automated testing** - Verify output strings in CI/CD

### Related Files

- `hardware/scala/elemrv_h/ElemRV.scala` - UART0 configuration
- `software/elemrv_h/demo/kernel.c` - Uses UART in existing firmware
- `modules/elements/nafarr/peripherals/com/uart/` - WishboneUart RTL

### Progress Summary

| Component | Status |
|-----------|--------|
| CPU (VexRiscv) | ✓ Stage 002 |
| RAM (8 KB) | ✓ Stage 002 |
| FLASH (64 KB) | ✓ Stage 002 |
| GPIO (12 pins) | ✓ Stage 003 |
| UART | ✓ Stage 004 |
| I2C | Pending Stage 005 |
| PWM | Pending Stage 006 |
| PIO | Pending Stage 007 |
| Pinmux | Pending Stage 008 |
