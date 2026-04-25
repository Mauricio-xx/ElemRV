#!/bin/bash
# SPDX-FileCopyrightText: 2025 aesc silicon
#
# SPDX-License-Identifier: CERN-OHL-W-2.0

# Build all 5 N-specific co-simulation libraries
# Run inside Docker at /workspace/elemrv/digital-twin/renode/verilated/wrappers/

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_MODE="${1:-release}"

PERIPHERALS="gpio_n pinmux_n spi spi_quad i2c_lite uart_lite bmb_bridge bmb_spi_xip"

echo "Building all N-specific co-simulation libraries (${BUILD_MODE} mode)..."
echo ""

FAIL=0
for p in $PERIPHERALS; do
    echo "=== Building ${p} ==="
    if make -f "${SCRIPT_DIR}/Makefile.${p}" -C "${SCRIPT_DIR}" clean 2>/dev/null && \
       make -f "${SCRIPT_DIR}/Makefile.${p}" -C "${SCRIPT_DIR}" BUILD_MODE="${BUILD_MODE}"; then
        echo "  OK: lib${p}.so"
    else
        echo "  FAILED: lib${p}.so"
        FAIL=$((FAIL + 1))
    fi
    echo ""
done

echo "============================================"
if [ $FAIL -eq 0 ]; then
    echo "All 8 N-specific libraries built successfully."
else
    echo "${FAIL} library build(s) failed!"
    exit 1
fi
