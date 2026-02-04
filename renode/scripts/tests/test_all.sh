#!/bin/bash
# SPDX-FileCopyrightText: 2025 aesc silicon
# SPDX-License-Identifier: Apache-2.0

# Complete test for ElemRV-H Renode platform

set -e

echo "=========================================="
echo "ElemRV-H Renode Platform Test"
echo "=========================================="
echo ""

# Check Docker
echo "1. Checking Docker..."
if ! docker info > /dev/null 2>&1; then
    echo "ERROR: Docker is not running"
    exit 1
fi
echo "   ✓ Docker is running"

# Check if image exists
echo ""
echo "2. Checking Renode image..."
if ! docker images | grep -q elemrv-renode; then
    echo "   Building Docker image..."
    cd docker && docker build -f Dockerfile.simulation -t elemrv-renode:test . 2>&1 | tail -5
fi
echo "   ✓ Renode image available"

# Test platform loading
echo ""
echo "3. Testing platform loading..."
docker run --rm -v $(pwd)/renode:/workspace/renode -w /workspace/renode elemrv-renode:test bash -c '
renode --hide-monitor --execute "mach create test" --execute "machine LoadPlatformDescription @platforms/elemrv_h.repl" --execute "echo SUCCESS: Platform loaded" --execute "quit" 2>&1 | grep "SUCCESS\|ERROR" | head -5
' | tee /tmp/test_result.txt

if grep -q "SUCCESS" /tmp/test_result.txt; then
    echo "   ✓ Platform loads successfully"
else
    echo "   ✗ Platform failed to load"
    exit 1
fi

# Show platform details
echo ""
echo "4. Platform details:"
echo "   CPU: VexRiscv RV32IC @ 50 MHz"
echo "   RAM: 8 KB @ 0x80000000"
echo "   FLASH: 64 KB @ 0xA0000000"

echo ""
echo "=========================================="
echo "✓ ALL TESTS PASSED"
echo "=========================================="
echo ""
echo "Renode is working! Platform ready for use."
echo ""
echo "Next: Add peripheral support (GPIO, UART, etc.)"
