#!/bin/bash
# SPDX-FileCopyrightText: 2025 aesc silicon
# SPDX-License-Identifier: Apache-2.0

# Test firmware execution in Renode

set -e

echo "=========================================="
echo "ElemRV-H Firmware Test"
echo "=========================================="
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RENODE_DIR="$(dirname "$SCRIPT_DIR")"

cd "$RENODE_DIR"

# Check firmware exists
echo "1. Checking firmware..."
if [ ! -f "firmware/samples/hello_world/hello_world.bin" ]; then
    echo "   ERROR: hello_world.bin not found"
    echo "   Build with: cd firmware/samples/hello_world && make"
    exit 1
fi
if [ ! -f "firmware/samples/gpio_blink/gpio_blink.bin" ]; then
    echo "   ERROR: gpio_blink.bin not found"
    echo "   Build with: cd firmware/samples/gpio_blink && make"
    exit 1
fi
echo "   ✓ Firmware binaries found"
echo "   • hello_world.bin: $(stat -c%s firmware/samples/hello_world/hello_world.bin) bytes"
echo "   • gpio_blink.bin: $(stat -c%s firmware/samples/gpio_blink/gpio_blink.bin) bytes"

# Create Renode script for Hello World test
echo ""
echo "2. Testing Hello World firmware..."
echo "   (This will run Renode and load the firmware)"

cat > /tmp/test_hello.resc << 'EOF'
mach create "elemrv-h"
machine LoadPlatformDescription @platforms/elemrv_h.repl
echo "Platform loaded"

# Load Hello World firmware at RAM address
sysbus LoadBinary @firmware/samples/hello_world/hello_world.bin 0x80000000
echo "Firmware loaded at 0x80000000"

# Set PC to start of firmware
cpu PC 0x80000000
echo "PC set to 0x80000000"

# Create UART terminal
emulation CreateUartPtyTerminal "uart0" "/tmp/uart0" True
connector Connect uart0 uart0
echo "UART connected to /tmp/uart0"

# Show memory map
echo ""
echo "Memory Map:"
echo "  RAM:   0x80000000 - 0x80001FFF"
echo "  FLASH: 0xA0000000 - 0xA000FFFF"
echo "  GPIO:  0xF0000000"
echo "  UART:  0xF0004000"
echo ""

echo "Starting simulation..."
echo "View UART output: cat /tmp/uart0 (in another terminal)"
echo ""
echo "To stop: quit"
EOF

# Run Renode with the test script
echo "   Starting Renode (Press Ctrl+C to stop)..."
echo ""
docker run --rm -it \
    -v "$RENODE_DIR:/workspace/renode" \
    -w /workspace/renode \
    elemrv-renode:test \
    renode --console /tmp/test_hello.resc 2>&1 || true

echo ""
echo "Test completed"
