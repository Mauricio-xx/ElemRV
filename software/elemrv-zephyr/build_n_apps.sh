#!/bin/bash
# SPDX-License-Identifier: Apache-2.0
#
# Builds ElemRV-N Zephyr apps (hello_world, blinky).
# Run from the elemrv-zephyr directory (west workspace must be initialized).
#
# Usage: bash build_n_apps.sh
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

    if west build -b elemrv_n "$app_path" -d "$build_dir" 2>&1; then
        echo "  BUILD OK: $app_name"
        PASS=$((PASS + 1))
    else
        echo "  BUILD FAILED: $app_name"
        FAIL=$((FAIL + 1))
    fi
}

echo "============================================"
echo "  ElemRV-N Zephyr App Builder"
echo "============================================"
echo "  ZEPHYR_BASE: ${ZEPHYR_BASE:-<not set>}"
echo "  ZEPHYR_SDK:  ${ZEPHYR_SDK_INSTALL_DIR:-<not set>}"
echo "  Date: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"

build_app app/hello_world    build-n-hello
build_app app/blinky         build-n-blinky

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
