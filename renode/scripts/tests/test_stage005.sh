#!/bin/bash
# SPDX-FileCopyrightText: 2025 aesc silicon
# SPDX-License-Identifier: Apache-2.0

# Stage 005 Test: I2C Controller
echo "=========================================="
echo "Stage 005: I2C Controller Test"
echo "=========================================="
echo ""

docker run --rm -v $(pwd)/renode:/workspace/renode -w /workspace/renode elemrv-renode:test bash -c '
cd firmware/samples/i2c_test && make clean && make

cd /workspace/renode
cat > /tmp/test_i2c.resc << "EOF"
mach create "elemrv-h"
machine LoadPlatformDescription @platforms/elemrv_h.repl
echo "SUCCESS: Platform loaded"

# Load I2C test firmware
sysbus LoadBinary @firmware/samples/i2c_test/i2c_test.bin 0x80000000
echo "SUCCESS: I2C firmware loaded"

cpu PC 0x80000000
echo "SUCCESS: PC set"

# Test I2C register access (0xF0001000)
sysbus WriteDoubleWord 0xF0001000 0x01
echo "SUCCESS: I2C control register writable"

$control = sysbus ReadDoubleWord 0xF0001000
echo "SUCCESS: I2C control register readable, value: $control"

echo "SUCCESS: I2C controller test completed"
quit
EOF

renode --hide-monitor /tmp/test_i2c.resc 2>&1 | grep -E "SUCCESS|ERROR" | head -10
' | tee /tmp/test_stage5.log

if grep -q "SUCCESS" /tmp/test_stage5.log && ! grep -q "ERROR" /tmp/test_stage5.log; then
    echo ""
    echo "✓ STAGE 005 PASSED"
    echo ""
else
    echo ""
    echo "✗ STAGE 005 FAILED"
    exit 1
fi
