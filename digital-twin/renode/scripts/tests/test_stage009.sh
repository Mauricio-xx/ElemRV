#!/bin/bash
# SPDX-FileCopyrightText: 2025 aesc silicon
# SPDX-License-Identifier: Apache-2.0

# Stage 009: Complete Test Suite
# Runs all tests from Stages 001-008

echo "================================================================"
echo "STAGE 009: Complete Test Suite"
echo "Integration of Stages 001-008"
echo "================================================================"
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

PASSED=0
FAILED=0

# Function to run a test
run_test() {
    local test_name=$1
    local test_script=$2
    
    echo "Running: $test_name"
    echo "----------------------------------------"
    
    if bash "$test_script" > /tmp/${test_name}.log 2>&1; then
        echo "✓ PASSED"
        ((PASSED++))
    else
        echo "✗ FAILED"
        echo "See /tmp/${test_name}.log for details"
        ((FAILED++))
    fi
    echo ""
}

# Run all stage tests
echo "Starting comprehensive test suite..."
echo ""

run_test "test_all" "test_all.sh"
run_test "test_phase1" "test_phase1.sh"
run_test "test_phase2" "test_phase2.sh"
run_test "stage_005_i2c" "test_stage005.sh"
run_test "stage_006_pwm" "test_stage006.sh"
run_test "stage_007_pio" "test_stage007.sh"
run_test "stage_008_pinmux" "test_stage008.sh"

# Summary
echo "================================================================"
echo "TEST SUITE SUMMARY"
echo "================================================================"
echo "Total Tests: $((PASSED + FAILED))"
echo "Passed: $PASSED"
echo "Failed: $FAILED"
echo ""

if [ $FAILED -eq 0 ]; then
    echo "================================================================"
    echo "✓ ALL TESTS PASSED - STAGE 009 COMPLETE"
    echo "================================================================"
    echo ""
    echo "Functional Peripherals:"
    echo "  ✓ UART (LiteX_UART) @ 0xF0004000"
    echo "  ✓ GPIO (LiteX_GPIO) @ 0xF0000000"
    echo "  ✓ I2C (LiteX_I2C) @ 0xF0001000"
    echo "  ✓ Timer (LiteX_Timer) @ 0xF0005000"
    echo ""
    echo "Tagged Peripherals (Accessible):"
    echo "  ⚠ PWM @ 0xF0003000"
    echo "  ⚠ PIO @ 0xF0002000"
    echo "  ⚠ Pinmux @ 0xF0010000"
    echo ""
    echo "Ready for Stage 010: RTL Co-simulation"
    exit 0
else
    echo "================================================================"
    echo "✗ SOME TESTS FAILED"
    echo "================================================================"
    exit 1
fi
