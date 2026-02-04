# Firmware Test Guide

**Date**: 2025-02-04

## Available Test Firmware

### 1. Hello World (UART Test)

**Location**: `renode/firmware/samples/hello_world/`

**Function**: Sends "Hello World from ElemRV-H!" via UART and echoes received characters

**Build**:
```bash
cd renode/firmware/samples/hello_world
make
```

**Run in Renode**:
```bash
# From project root
docker run -it -v $(pwd)/renode:/workspace/renode elemrv-renode:test bash

# Inside container
cd /workspace/renode
renode scripts/elemrv_h.resc

# In Renode console:
sysbus LoadBinary @firmware/samples/hello_world/hello_world.bin 0x80000000
cpu PC 0x80000000
emulation CreateUartPtyTerminal "uart0" "/tmp/uart0" True
connector Connect uart0 uart0
start

# In another terminal:
cat /tmp/uart0
```

### 2. GPIO Blink

**Location**: `renode/firmware/samples/gpio_blink/`

**Function**: Toggles GPIO pin 0 on/off with delay

**Build**:
```bash
cd renode/firmware/samples/gpio_blink
make
```

**Run in Renode**:
```bash
# From project root
docker run -it -v $(pwd)/renode:/workspace/renode elemrv-renode:test bash

# Inside container
cd /workspace/renode
renode scripts/elemrv_h.resc

# In Renode console:
sysbus LoadBinary @firmware/samples/gpio_blink/gpio_blink.bin 0x80000000
cpu PC 0x80000000
start

# Monitor GPIO
gpio0
```

## Quick Test Script

```bash
# Test platform only
./renode/scripts/tests/test_all.sh

# Test with firmware (interactive)
./renode/scripts/tests/test_firmware.sh
```

## Firmware Memory Layout

All firmware runs from RAM (0x80000000):

```
0x80000000 - 0x80001FFF  RAM (8 KB)
  └─ Firmware loaded here
  └─ Stack grows down from end of RAM
```

## Memory Map for Peripherals

```
0xF0000000 - 0xF0000FFF  GPIO0 (12 pins)
0xF0001000 - 0xF0001FFF  I2C0
0xF0002000 - 0xF0002FFF  PIO0 (Tagged)
0xF0003000 - 0xF0003FFF  PWM0 (Tagged)
0xF0004000 - 0xF0004FFF  UART0
0xF0005000 - 0xF0005FFF  Timer0
0xF0010000 - 0xF0010FFF  Pinmux (Tagged)
```

## Expected Output

### Hello World
```
Hello World from ElemRV-H!
> 
```

### GPIO Blink
- GPIO pin 0 toggles between HIGH and LOW
- Can be monitored with `gpio0` command in Renode

## Troubleshooting

### Firmware won't load
- Check binary exists: `ls -la renode/firmware/samples/*/`
- Verify platform loads: `./renode/scripts/tests/test_all.sh`

### UART not working
- Check UART connection: `connector Connect uart0 uart0`
- Verify terminal: `ls -la /tmp/uart0`

### GPIO not toggling
- Check GPIO address in firmware matches platform (0xF0000000)
- Verify with: `sysbus ReadDoubleWord 0xF0000000`
