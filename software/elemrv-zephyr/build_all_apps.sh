#!/bin/bash
# SPDX-License-Identifier: Apache-2.0
#
# Builds all ElemRV-H Zephyr apps.
# Run from the elemrv-zephyr directory (west workspace must be initialized).
#
# Usage: bash build_all_apps.sh
# Env:   ZEPHYR_BASE, ZEPHYR_SDK_INSTALL_DIR must be set.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

PASS=0
FAIL=0

build_app() {
    local app_path="$1"
    local build_dir="$2"
    local app_name
    app_name=$(basename "$app_path")

    echo ""
    echo "=== Building: $app_name -> $build_dir ==="

    if west build -b elemrv_h "$app_path" -d "$build_dir" 2>&1; then
        echo "  BUILD OK: $app_name"
        PASS=$((PASS + 1))
    else
        echo "  BUILD FAILED: $app_name"
        FAIL=$((FAIL + 1))
    fi
}

echo "============================================"
echo "  ElemRV-H Zephyr App Builder"
echo "============================================"
echo "  ZEPHYR_BASE: ${ZEPHYR_BASE:-<not set>}"
echo "  ZEPHYR_SDK:  ${ZEPHYR_SDK_INSTALL_DIR:-<not set>}"
echo "  Date: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"

build_app app/hello_world    build
build_app app/blinky         build-blinky
build_app app/i2c_scan       build-i2c-scan
build_app app/pwm_test       build-pwm-test
build_app app/pio_test       build-pio-test
build_app app/pinmux_test    build-pinmux-test
build_app app/timer_uart_test       build-timer-uart-test
build_app app/hybrid_pinmux_pwm_test  build-hybrid-pinmux-pwm
build_app app/hybrid_pio_uart_test    build-hybrid-pio-uart
build_app app/hybrid_multi_cosim_test build-hybrid-multi-cosim
build_app app/sensor_capture          build-sensor-capture
build_app app/rtos_debug_demo         build-rtos-debug-demo
build_app app/rtos_diagnostics        build-rtos-diagnostics
build_app app/sensor_i2c_capture      build-sensor-i2c-capture

echo ""
echo "============================================"
TOTAL=$((PASS + FAIL))
if [ $FAIL -eq 0 ]; then
    echo "  BUILD SUMMARY: $PASS/$TOTAL succeeded"
else
    echo "  BUILD SUMMARY: $PASS/$TOTAL succeeded, $FAIL failed"
fi
echo "============================================"

[ $FAIL -eq 0 ] && exit 0 || exit 1
