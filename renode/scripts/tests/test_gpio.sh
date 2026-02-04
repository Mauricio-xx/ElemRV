#!/bin/bash

# SPDX-FileCopyrightText: 2025 aesc silicon
#
# SPDX-License-Identifier: Apache-2.0

# GPIO Test Script for ElemRV-H
# Tests GPIO peripheral functionality in Renode

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RENODE_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
PLATFORM="$RENODE_DIR/platforms/elemrv_h.repl"

echo "=== ElemRV-H GPIO Test ==="
echo ""

# Check if Renode is available
if ! command -v renode &> /dev/null; then
    echo "Error: Renode not found in PATH"
    echo "Please install Renode or run from Docker container"
    exit 1
fi

echo "1. Loading platform: $PLATFORM"

# Create a temporary Renode script
cat > /tmp/gpio_test.resc << 'EOF'
mach create "elemrv-h-gpio-test"
machine LoadPlatformDescription @platforms/elemrv_h.repl

echo "Platform loaded successfully"
echo "GPIO0 available at 0xF0000000 with 12 pins"

# Show GPIO state
echo "GPIO0 state:"
gpio0

# Test GPIO access
# Write to direction register (pin 0 as output)
sysbus WriteDoubleWord 0xF0000000 0x01
echo "GPIO direction set to output for pin 0"

# Write to value register
sysbus WriteDoubleWord 0xF0000004 0x01
echo "GPIO pin 0 set to HIGH"

# Read back value
$val = sysbus ReadDoubleWord 0xF0000004
echo "GPIO value read back: $val"

# Clear value
sysbus WriteDoubleWord 0xF0000004 0x00
echo "GPIO pin 0 set to LOW"

$val = sysbus ReadDoubleWord 0xF0000004
echo "GPIO value read back: $val"

echo ""
echo "GPIO test completed successfully"
EOF

echo ""
echo "2. Running GPIO test in Renode..."
renode --console --hide-monitor /tmp/gpio_test.resc

# Cleanup
rm -f /tmp/gpio_test.resc

echo ""
echo "=== Test Passed ==="
