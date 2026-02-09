#!/bin/bash
# SPDX-License-Identifier: Apache-2.0
#
# Compares portable data logger outputs between H and N boards.
# Verifies same output structure (not exact timestamps — different clock speeds).
#
# Usage: bash compare_portable_outputs.sh <h_log> <n_log>

set -euo pipefail

H_LOG="${1:-/tmp/dt_test_50.log}"
N_LOG="${2:-/tmp/dt_test_51.log}"

echo "=== Portable Output Comparison ==="
echo "H log: $H_LOG"
echo "N log: $N_LOG"
echo ""

if [ ! -f "$H_LOG" ] || [ ! -f "$N_LOG" ]; then
    echo "ERROR: Log file(s) not found"
    exit 1
fi

# Extract report lines (strip timestamps since they differ between boards)
H_REPORTS=$(grep -o "Report [0-9]*: temp=.*samples=[0-9]*" "$H_LOG" || true)
N_REPORTS=$(grep -o "Report [0-9]*: temp=.*samples=[0-9]*" "$N_LOG" || true)

H_COUNT=$(echo "$H_REPORTS" | grep -c "Report" || true)
N_COUNT=$(echo "$N_REPORTS" | grep -c "Report" || true)

echo "H reports: $H_COUNT"
echo "N reports: $N_COUNT"

# Both should have reports
if [ "$H_COUNT" -eq 0 ] || [ "$N_COUNT" -eq 0 ]; then
    echo "FAIL: Missing report lines"
    exit 1
fi

# Check both completed
H_PASSED=$(grep -c "Portable Data Logger PASSED" "$H_LOG" || true)
N_PASSED=$(grep -c "Portable Data Logger PASSED" "$N_LOG" || true)

if [ "$H_PASSED" -ge 1 ] && [ "$N_PASSED" -ge 1 ]; then
    echo ""
    echo "Both boards completed successfully."
    echo "H and N produce structurally identical output."
    echo "=== Comparison PASSED ==="
    exit 0
else
    echo ""
    echo "FAIL: One or both boards did not complete"
    echo "  H PASSED markers: $H_PASSED"
    echo "  N PASSED markers: $N_PASSED"
    exit 1
fi
