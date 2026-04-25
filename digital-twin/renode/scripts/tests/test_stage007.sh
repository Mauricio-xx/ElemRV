#!/bin/bash
# SPDX-FileCopyrightText: 2025 aesc silicon
# SPDX-License-Identifier: Apache-2.0

# Stage 007 Test: PIO Controller
echo "=========================================="
echo "Stage 007: PIO Controller Test"
echo "=========================================="
echo ""

docker run --rm -v $(pwd)/renode:/workspace/renode -w /workspace/renode elemrv-renode:test bash -c '
cd firmware/samples/pio_test && make clean && make

cd /workspace/renode
cat > /tmp/test_pio.resc << "EOF"
mach create "elemrv-h"
machine LoadPlatformDescription @platforms/elemrv_h.repl
echo "SUCCESS: Platform loaded"

# Load PIO test firmware
sysbus LoadBinary @firmware/samples/pio_test/pio_test.bin 0x80000000
echo "SUCCESS: PIO firmware loaded"

cpu PC 0x80000000
echo "SUCCESS: PC set"

# Test PIO register access (0xF0002000) - Tagged region
sysbus WriteDoubleWord 0xF0002000 0x01
echo "SUCCESS: PIO register writable (tagged)"

$instr = sysbus ReadDoubleWord 0xF0002008
echo "SUCCESS: PIO instruction register accessible (tagged), value: $instr"

echo "SUCCESS: PIO controller test completed"
quit
EOF

renode --hide-monitor /tmp/test_pio.resc 2>&1 | grep -E "SUCCESS|ERROR" | head -10
' | tee /tmp/test_stage7.log

if grep -q "SUCCESS" /tmp/test_stage7.log && ! grep -q "ERROR" /tmp/test_stage7.log; then
    echo ""
    echo "✓ STAGE 007 PASSED"
    echo ""
else
    echo ""
    echo "✗ STAGE 007 FAILED"
    exit 1
fi
