#!/bin/bash
# SPDX-FileCopyrightText: 2025 aesc silicon
#
# SPDX-License-Identifier: Apache-2.0

# Digital-twin variant of gen_image_container.sh. The upstream script
# targets the real N SoC (HyperRAM + bootrom + demo image + 32 MB flash
# container). Our BmbSpiXipController DT only has a 4 KiB flash slave
# backing ROM, so this variant just pads a single firmware image to
# 4 KiB so it can be dropped directly into the DT's backing array.
#
# Usage: gen_dt_image_container.sh <firmware.bin> <output.img>

set -euo pipefail

if [ $# -ne 2 ]; then
    echo "Usage: $0 <firmware.bin> <output.img>" >&2
    exit 1
fi

FW_BIN="$1"
OUT_IMG="$2"
PAD_SIZE=4096

[ -f "$FW_BIN" ] || { echo "missing firmware: $FW_BIN" >&2; exit 1; }

dd if=/dev/zero of="$OUT_IMG" bs=$PAD_SIZE count=1 status=none
dd if="$FW_BIN" of="$OUT_IMG" conv=notrunc status=none

echo "Wrote $OUT_IMG ($(stat -c %s "$OUT_IMG") bytes, fw=$(stat -c %s "$FW_BIN") bytes)"
