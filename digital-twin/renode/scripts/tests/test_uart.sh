#!/bin/bash

# SPDX-FileCopyrightText: 2025 aesc silicon
#
# SPDX-License-Identifier: Apache-2.0

# UART Test Script for ElemRV-H
# Tests UART peripheral with Hello World firmware

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RENODE_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
PLATFORM="$RENODE_DIR/platforms/elemrv_h.repl"
FIRMWARE="$RENODE_DIR/firmware/samples/hello_world/hello_world.bin"

echo "=== ElemRV-H UART Test ==="
echo ""

# Check if Renode is available
if ! command -v renode &> /dev/null; then
    echo "Error: Renode not found in PATH"
    echo "Please install Renode or run from Docker container"
    exit 1
fi

echo "1. Loading platform: $PLATFORM"

# Create a temporary Renode script
cat > /tmp/uart_test.resc << 'EOF'
mach create "elemrv-h-uart-test"
machine LoadPlatformDescription @platforms/elemrv_h.repl

echo "Platform loaded successfully"
echo "UART0 available at 0xF0004000"

# Show UART state
uart0

# Create UART analyzer to see output
emulation CreateUartPtyTerminal "uart0" "/tmp/uart0" True
connector Connect uart0 uart0

echo ""
echo "UART0 connected to PTY: /tmp/uart0"
EOF

# Add firmware loading if it exists
if [ -f "$FIRMWARE" ]; then
    echo "2. Loading firmware: $FIRMWARE"
    cat >> /tmp/uart_test.resc << EOF

# Load Hello World firmware
sysbus LoadBinary @$FIRMWARE 0x80000000
cpu PC 0x80000000

echo "Firmware loaded at 0x80000000"
EOF
else
    echo "2. Firmware not found, skipping (build with: cd firmware/samples/hello_world && make)"
    cat >> /tmp/uart_test.resc << 'EOF'

echo "No firmware loaded - UART can be tested manually"
echo "Example:"
echo "  sysbus WriteDoubleWord 0xF0004000 0x48  # Write 'H'"
EOF
fi

cat >> /tmp/uart_test.resc << 'EOF'

# Show final state
echo ""
echo "UART registers:"
echo "  TX/RX:       $(sysbus ReadDoubleWord 0xF0004000)"
echo "  TX Full:     $(sysbus ReadDoubleWord 0xF0004004)"
echo "  RX Empty:    $(sysbus ReadDoubleWord 0xF0004008)"

echo ""
echo "UART test completed"
echo "To start simulation: start"
echo "To view UART output: cat /tmp/uart0 (in another terminal)"
EOF

echo ""
echo "3. Running UART test in Renode..."
echo ""
renode --console --hide-monitor /tmp/uart_test.resc

# Cleanup
rm -f /tmp/uart_test.resc

echo ""
echo "=== Test Completed ==="
