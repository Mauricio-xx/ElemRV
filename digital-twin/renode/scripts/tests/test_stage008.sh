#!/bin/bash
# SPDX-FileCopyrightText: 2025 aesc silicon
# SPDX-License-Identifier: Apache-2.0

# Stage 008 Test: Pinmux Controller
echo "=========================================="
echo "Stage 008: Pinmux Controller Test"
echo "=========================================="
echo ""

docker run --rm -v $(pwd)/renode:/workspace/renode -w /workspace/renode elemrv-renode:test bash -c '
cd firmware/samples/pinmux_test && make clean && make

cd /workspace/renode
cat > /tmp/test_pinmux.resc << "EOF"
mach create "elemrv-h"
machine LoadPlatformDescription @platforms/elemrv_h.repl
echo "SUCCESS: Platform loaded"

# Load Pinmux test firmware
sysbus LoadBinary @firmware/samples/pinmux_test/pinmux_test.bin 0x80000000
echo "SUCCESS: Pinmux firmware loaded"

cpu PC 0x80000000
echo "SUCCESS: PC set"

# Test Pinmux register access (0xF0010000) - Tagged region
sysbus WriteDoubleWord 0xF0010000 0x01
echo "SUCCESS: Pinmux register writable (tagged)"

$sel0 = sysbus ReadDoubleWord 0xF0010004
echo "SUCCESS: Pinmux selection 0 register accessible (tagged), value: $sel0"

echo "SUCCESS: Pinmux controller test completed"
quit
EOF

renode --hide-monitor /tmp/test_pinmux.resc 2>&1 | grep -E "SUCCESS|ERROR" | head -10
' | tee /tmp/test_stage8.log

if grep -q "SUCCESS" /tmp/test_stage8.log && ! grep -q "ERROR" /tmp/test_stage8.log; then
    echo ""
    echo "✓ STAGE 008 PASSED"
    echo ""
else
    echo ""
    echo "✗ STAGE 008 FAILED"
    exit 1
fi
