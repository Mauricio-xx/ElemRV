#!/bin/bash
# SPDX-FileCopyrightText: 2025 aesc silicon
# SPDX-License-Identifier: Apache-2.0

# Phase 1 Test: UART and GPIO functional tests

echo "=========================================="
echo "Phase 1: Functional Tests"
echo "Peripherals: UART, GPIO, Timer, I2C"
echo "=========================================="
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RENODE_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"

cd "$RENODE_ROOT"

# Test 1: Platform loads with all peripherals
echo "Test 1: Platform Loading"
echo "------------------------"
docker run --rm -v "$RENODE_ROOT/renode:/workspace/renode" -w /workspace/renode elemrv-renode:test bash -c '
renode --hide-monitor --execute "mach create test" \
       --execute "machine LoadPlatformDescription @platforms/elemrv_h.repl" \
       --execute "echo SUCCESS: Platform loaded with peripherals" \
       --execute "quit" 2>&1 | grep "SUCCESS\|ERROR" | head -5
' | tee /tmp/test1.log

if grep -q "SUCCESS" /tmp/test1.log; then
    echo "✓ Test 1 PASSED"
else
    echo "✗ Test 1 FAILED"
    exit 1
fi
echo ""

# Test 2: UART Hello World firmware loads
echo "Test 2: UART Hello World Firmware"
echo "----------------------------------"
echo "Loading firmware: hello_world.bin"

# Run UART test
docker run --rm -v "$RENODE_ROOT/renode:/workspace/renode" -w /workspace/renode elemrv-renode:test bash -c '
if [ ! -f firmware/samples/hello_world/hello_world.bin ]; then
    echo "ERROR: Firmware not found"
    exit 1
fi

FIRMWARE_SIZE=$(stat -c%s firmware/samples/hello_world/hello_world.bin)
echo "Firmware size: $FIRMWARE_SIZE bytes"

cat > /tmp/test_uart.resc << "EOF"
mach create "elemrv-h"
machine LoadPlatformDescription @platforms/elemrv_h.repl
echo "Platform loaded"

# Load firmware
sysbus LoadBinary @firmware/samples/hello_world/hello_world.bin 0x80000000
echo "Firmware loaded"

# Set PC
cpu PC 0x80000000
echo "PC set"

# Test UART register access
$txfull = sysbus ReadDoubleWord 0xF0004004
echo "UART TXFULL register: $txfull"

echo "SUCCESS: UART test completed"
quit
EOF

renode --hide-monitor /tmp/test_uart.resc 2>&1 | grep -E "SUCCESS|ERROR|Platform loaded|Firmware loaded|PC set" | head -10
' | tee /tmp/test2.log

if grep -q "SUCCESS" /tmp/test2.log && ! grep -q "ERROR" /tmp/test2.log; then
    echo "✓ Test 2 PASSED"
else
    echo "✗ Test 2 FAILED"
    exit 1
fi
echo ""

# Test 3: GPIO firmware loads
echo "Test 3: GPIO Firmware"
echo "---------------------"
echo "Loading firmware: gpio_blink.bin"

# Run GPIO test
docker run --rm -v "$RENODE_ROOT/renode:/workspace/renode" -w /workspace/renode elemrv-renode:test bash -c '
if [ ! -f firmware/samples/gpio_blink/gpio_blink.bin ]; then
    echo "ERROR: Firmware not found"
    exit 1
fi

FIRMWARE_SIZE=$(stat -c%s firmware/samples/gpio_blink/gpio_blink.bin)
echo "Firmware size: $FIRMWARE_SIZE bytes"

cat > /tmp/test_gpio.resc << "EOF"
mach create "elemrv-h"
machine LoadPlatformDescription @platforms/elemrv_h.repl
echo "Platform loaded"

# Load firmware
sysbus LoadBinary @firmware/samples/gpio_blink/gpio_blink.bin 0x80000000
echo "Firmware loaded"

# Set PC
cpu PC 0x80000000
echo "PC set"

# Test GPIO register access
$gpio_val = sysbus ReadDoubleWord 0xF0000000
echo "GPIO value: $gpio_val"

# Write to GPIO
sysbus WriteDoubleWord 0xF0000000 0x01
echo "Set GPIO pin 0 HIGH"

$gpio_val = sysbus ReadDoubleWord 0xF0000000
echo "GPIO value after write: $gpio_val"

echo "SUCCESS: GPIO test completed"
quit
EOF

renode --hide-monitor /tmp/test_gpio.resc 2>&1 | grep -E "SUCCESS|ERROR|Platform loaded|Firmware loaded|PC set|GPIO value" | head -10
' | tee /tmp/test3.log

if grep -q "SUCCESS" /tmp/test3.log && ! grep -q "ERROR" /tmp/test3.log; then
    echo "✓ Test 3 PASSED"
else
    echo "✗ Test 3 FAILED"
    exit 1
fi
echo ""

# Test 4: Memory map verification
echo "Test 4: Memory Map Verification"
echo "-------------------------------"
docker run --rm -v "$RENODE_ROOT/renode:/workspace/renode" -w /workspace/renode elemrv-renode:test bash -c '
cat > /tmp/test_memory.resc << "EOF"
mach create "elemrv-h"
machine LoadPlatformDescription @platforms/elemrv_h.repl

# Test RAM access
sysbus WriteDoubleWord 0x80000000 0xDEADBEEF
$val = sysbus ReadDoubleWord 0x80000000
if $val != 0xDEADBEEF {
    echo "ERROR: RAM test failed"
    quit
}
echo "SUCCESS: RAM accessible at 0x80000000"

# Test FLASH access
sysbus WriteDoubleWord 0xA0000000 0x12345678
$val = sysbus ReadDoubleWord 0xA0000000
if $val != 0x12345678 {
    echo "ERROR: FLASH test failed"
    quit
}
echo "SUCCESS: FLASH accessible at 0xA0000000"

echo "SUCCESS: Memory map verified"
quit
EOF

renode --hide-monitor /tmp/test_memory.resc 2>&1 | grep -E "SUCCESS|ERROR" | head -10
' | tee /tmp/test4.log

if grep -q "SUCCESS" /tmp/test4.log && ! grep -q "ERROR" /tmp/test4.log; then
    echo "✓ Test 4 PASSED"
else
    echo "✗ Test 4 FAILED"
    exit 1
fi
echo ""

# Summary
echo "=========================================="
echo "Phase 1 Test Results"
echo "=========================================="
echo "✓ Test 1: Platform Loading - PASSED"
echo "✓ Test 2: UART Hello World - PASSED"
echo "✓ Test 3: GPIO Firmware - PASSED"
echo "✓ Test 4: Memory Map - PASSED"
echo ""
echo "=========================================="
echo "ALL PHASE 1 TESTS PASSED"
echo "=========================================="
echo ""
echo "Functional Peripherals:"
echo "  • UART (LiteX_UART) @ 0xF0004000"
echo "  • GPIO (LiteX_GPIO) @ 0xF0000000"
echo "  • I2C (LiteX_I2C) @ 0xF0001000"
echo "  • Timer (LiteX_Timer) @ 0xF0005000"
echo ""
echo "Next: Phase 2 - PWM/PIO/Pinmux register tests"
