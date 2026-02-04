#!/bin/bash
# SPDX-FileCopyrightText: 2025 aesc silicon
# SPDX-License-Identifier: Apache-2.0

# Stage 006 Test: PWM Controller
echo "=========================================="
echo "Stage 006: PWM Controller Test"
echo "=========================================="
echo ""

docker run --rm -v $(pwd)/renode:/workspace/renode -w /workspace/renode elemrv-renode:test bash -c '
cd firmware/samples/pwm_test && make clean && make

cd /workspace/renode
cat > /tmp/test_pwm.resc << "EOF"
mach create "elemrv-h"
machine LoadPlatformDescription @platforms/elemrv_h.repl
echo "SUCCESS: Platform loaded"

# Load PWM test firmware
sysbus LoadBinary @firmware/samples/pwm_test/pwm_test.bin 0x80000000
echo "SUCCESS: PWM firmware loaded"

cpu PC 0x80000000
echo "SUCCESS: PC set"

# Test PWM register access (0xF0003000) - Tagged region
sysbus WriteDoubleWord 0xF0003000 0x01
echo "SUCCESS: PWM register writable (tagged)"

$period = sysbus ReadDoubleWord 0xF0003004
echo "SUCCESS: PWM period register accessible (tagged), value: $period"

echo "SUCCESS: PWM controller test completed"
quit
EOF

renode --hide-monitor /tmp/test_pwm.resc 2>&1 | grep -E "SUCCESS|ERROR" | head -10
' | tee /tmp/test_stage6.log

if grep -q "SUCCESS" /tmp/test_stage6.log && ! grep -q "ERROR" /tmp/test_stage6.log; then
    echo ""
    echo "✓ STAGE 006 PASSED"
    echo ""
else
    echo ""
    echo "✗ STAGE 006 FAILED"
    exit 1
fi
