#!/bin/bash
# SPDX-FileCopyrightText: 2025 aesc silicon
#
# SPDX-License-Identifier: CERN-OHL-W-2.0

# Digital Twin Test Runner
# Runs inside the Docker container at /workspace/elemrv/renode/
# Callers (Taskfile, CI) invoke via: docker exec <container> bash -c 'cd /workspace/elemrv/renode && bash run_tests.sh'

set -euo pipefail

PASS=0
FAIL=0
TOTAL=0
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors (disabled if not a terminal)
if [ -t 1 ]; then
    GREEN='\033[0;32m'
    RED='\033[0;31m'
    YELLOW='\033[0;33m'
    NC='\033[0m'
else
    GREEN=''
    RED=''
    YELLOW=''
    NC=''
fi

run_test() {
    local name="$1"
    local script="$2"
    local pass_marker="${3:-PASSED}"
    TOTAL=$((TOTAL + 1))
    local logfile="/tmp/dt_test_${TOTAL}.log"

    echo ""
    echo "=== TEST $TOTAL: $name ==="

    # Check that the script exists
    if [ ! -f "$SCRIPT_DIR/$script" ]; then
        echo -e "  ${RED}FAIL${NC}: Script not found: $script"
        FAIL=$((FAIL + 1))
        return
    fi

    # Run Renode headless. Capture all output to log.
    # --disable-xwt: no GUI; --console: use text console
    # Renode always exits 0 on `quit`, so we must grep the log.
    if renode --disable-xwt --console \
        -e "include @$SCRIPT_DIR/$script" \
        > "$logfile" 2>&1; then
        :
    fi

    # Show last few lines for context
    echo "  --- output tail ---"
    tail -10 "$logfile" | sed 's/^/  | /'
    echo "  ---"

    # Check for pass marker, ignoring known benign warnings:
    # - "Could not tokenize" from Tag syntax in .repl files
    # - "Couldn't" from peripheral warnings
    local filtered_errors
    filtered_errors=$(grep -i "error" "$logfile" \
        | grep -vi "Could not tokenize" \
        | grep -vi "Couldn't find" \
        | grep -vi "error_count" \
        || true)

    if grep -q "$pass_marker" "$logfile" && [ -z "$filtered_errors" ]; then
        echo -e "  RESULT: ${GREEN}PASS${NC}"
        PASS=$((PASS + 1))
    else
        echo -e "  RESULT: ${RED}FAIL${NC}"
        if [ -n "$filtered_errors" ]; then
            echo "  Errors found:"
            echo "$filtered_errors" | sed 's/^/    /'
        fi
        if ! grep -q "$pass_marker" "$logfile"; then
            echo "  Missing pass marker: '$pass_marker'"
        fi
        FAIL=$((FAIL + 1))
    fi
}

echo "============================================"
echo "  ElemRV Digital Twin Test Suite"
echo "============================================"
echo "  Working dir: $SCRIPT_DIR"
echo "  Date: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"

# Test 1: Base platform + firmware (CPU, RAM, RunFor timing)
run_test "Base Platform" "test_base.resc" "Base Platform Test PASSED"

# Test 2: PWM co-simulation (Verilator RTL, register verification)
run_test "PWM Co-simulation" "run_pwm_test.resc" "PWM Co-simulation Test PASSED"

echo ""
echo "============================================"
if [ $FAIL -eq 0 ]; then
    echo -e "  SUMMARY: ${GREEN}$PASS/$TOTAL passed${NC}"
else
    echo -e "  SUMMARY: ${RED}$PASS/$TOTAL passed, $FAIL failed${NC}"
fi
echo "============================================"

[ $FAIL -eq 0 ] && exit 0 || exit 1
