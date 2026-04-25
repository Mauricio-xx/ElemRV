#!/bin/bash
# SPDX-FileCopyrightText: 2025 aesc silicon
#
# SPDX-License-Identifier: CERN-OHL-W-2.0

# Cross-Validation Script
# Compares pure Verilator testbench results against Renode co-simulation results.
#
# 1. Runs pure Verilator testbenches → captures VERIFY lines
# 2. Runs Renode co-sim tests → captures ReadDoubleWord output values
# 3. Compares overlapping register reads between the two
#
# Run inside Docker at /workspace/elemrv/digital-twin/renode/

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TB_DIR="$SCRIPT_DIR/verilated/testbenches"
MATCH=0
MISMATCH=0
TOTAL=0

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

echo "============================================"
echo "  ElemRV Co-simulation Cross-Validation"
echo "============================================"
echo ""

# --- Step 1: Build and run pure Verilator testbenches ---
echo "--- Step 1: Pure Verilator Testbenches ---"
echo ""

TB_LOG="/tmp/dt_verilator_tb.log"

if ! make -C "$TB_DIR" all 2>&1 | tail -5; then
    echo -e "${RED}ERROR: Verilator testbench build failed${NC}"
    exit 1
fi

# Run all testbenches, capturing output
> "$TB_LOG"
TB_FAIL=0
for p in pwm gpio pio pinmux i2c uart mtimer; do
    if [ -f "$TB_DIR/tb_$p" ]; then
        echo "  Running tb_$p..."
        "$TB_DIR/tb_$p" >> "$TB_LOG" 2>&1 || TB_FAIL=$((TB_FAIL + 1))
    else
        echo -e "  ${YELLOW}SKIP: tb_$p not found${NC}"
    fi
done

if [ $TB_FAIL -gt 0 ]; then
    echo -e "  ${RED}$TB_FAIL testbench(es) failed${NC}"
fi
echo ""

# --- Step 2: Run Renode co-sim tests ---
echo "--- Step 2: Renode Co-simulation Tests ---"
echo ""

# Map of co-sim tests to run (using individual peripheral tests with "@ 0x" log patterns)
declare -A COSIM_TESTS=(
    [pwm]="run_pwm_test.resc"
    [gpio]="run_cosim_gpio_test.resc"
    [pio]="run_cosim_pio_test.resc"
    [pinmux]="run_cosim_pinmux_test.resc"
    [i2c]="run_cosim_i2c_test.resc"
    [uart]="run_cosim_uart_test.resc"
    [mtimer]="run_cosim_mtimer_test.resc"
)

RENODE_LOGS_DIR="/tmp/dt_crossval"
mkdir -p "$RENODE_LOGS_DIR"

for p in pwm gpio pio pinmux i2c uart mtimer; do
    resc="${COSIM_TESTS[$p]}"
    lib_name="lib${p}.so"
    log_file="$RENODE_LOGS_DIR/${p}.log"

    # Check library exists
    if [ ! -f "$SCRIPT_DIR/verilated/libs/$lib_name" ] && \
       [ ! -f "/workspace/elemrv/digital-twin/renode/verilated/libs/$lib_name" ]; then
        echo -e "  ${YELLOW}SKIP: $lib_name not found${NC}"
        continue
    fi

    if [ ! -f "$SCRIPT_DIR/$resc" ]; then
        echo -e "  ${YELLOW}SKIP: $resc not found${NC}"
        continue
    fi

    echo "  Running $resc..."
    if renode --disable-xwt --console \
        -e "include @$SCRIPT_DIR/$resc" \
        > "$log_file" 2>&1; then
        :
    fi
done
echo ""

# --- Step 3: Cross-validate ---
echo "--- Step 3: Cross-Validation Results ---"
echo ""

# Extract Verilator VERIFY lines with exact values
# Format: VERIFY <peripheral> <reg_name> <byte_addr> <got> <expected> PASS|FAIL
declare -A TB_VALUES
while IFS=' ' read -r _ periph reg addr got expected status; do
    key="${periph}:${addr}"
    # Keep first value per address (matches Renode's single-read pattern)
    if [[ -z "${TB_VALUES[$key]+x}" ]]; then
        TB_VALUES[$key]="$got"
    fi
done < <(grep "^VERIFY" "$TB_LOG" | grep -v "non-zero" || true)

# Extract Renode register read values
# Renode log format: a line containing "@ 0xFxxxxxxx" followed by a bare "0x..." value
declare -A RENODE_VALUES
for p in pwm gpio pio pinmux i2c uart mtimer; do
    log_file="$RENODE_LOGS_DIR/${p}.log"
    [ ! -f "$log_file" ] && continue

    periph_upper=$(echo "$p" | tr '[:lower:]' '[:upper:]')
    prev_addr=""
    while IFS= read -r line; do
        # Strip carriage returns (Renode console output has \r\r\n)
        line="${line//$'\r'/}"
        # Match lines like: "Script: IP Header    @ 0xF0003000:"
        if [[ "$line" =~ @\ (0x[0-9A-Fa-f]+) ]]; then
            prev_addr="${BASH_REMATCH[1]}"
        elif [[ -n "$prev_addr" && "$line" =~ ^(0x[0-9A-Fa-f]+)$ ]]; then
            renode_val="${BASH_REMATCH[1]}"
            # Convert absolute address to peripheral-relative offset (low 12 bits)
            addr_dec=$((prev_addr))
            offset=$((addr_dec & 0xFFF))
            offset_hex=$(printf "0x%08X" $offset)
            key="${periph_upper}:${offset_hex}"
            RENODE_VALUES[$key]="$renode_val"
            prev_addr=""
        else
            # Reset if the next line wasn't a value
            prev_addr=""
        fi
    done < "$log_file"
done

# Compare overlapping registers
printf "  %-8s %-14s %-12s %-12s %s\n" "PERIPH" "REG_OFFSET" "VERILATOR" "RENODE" "RESULT"
printf "  %-8s %-14s %-12s %-12s %s\n" "------" "----------" "---------" "------" "------"

for key in $(echo "${!TB_VALUES[@]}" | tr ' ' '\n' | sort); do
    tb_val="${TB_VALUES[$key]}"
    periph="${key%%:*}"
    addr="${key##*:}"

    if [[ -n "${RENODE_VALUES[$key]+x}" ]]; then
        renode_val="${RENODE_VALUES[$key]}"
        TOTAL=$((TOTAL + 1))

        # Normalize hex values for comparison (both to lowercase, remove leading zeros)
        tb_norm=$(printf "0x%08x" "$((tb_val))")
        renode_norm=$(printf "0x%08x" "$((renode_val))")

        if [ "$tb_norm" = "$renode_norm" ]; then
            printf "  %-8s %-14s %-12s %-12s ${GREEN}MATCH${NC}\n" \
                "$periph" "$addr" "$tb_val" "$renode_val"
            MATCH=$((MATCH + 1))
        else
            printf "  %-8s %-14s %-12s %-12s ${RED}MISMATCH${NC}\n" \
                "$periph" "$addr" "$tb_val" "$renode_val"
            MISMATCH=$((MISMATCH + 1))
        fi
    fi
done

# Also report Verilator-only results (not in Renode)
echo ""
echo "  Verilator-only results (no Renode equivalent):"
for key in $(echo "${!TB_VALUES[@]}" | tr ' ' '\n' | sort); do
    if [[ -z "${RENODE_VALUES[$key]+x}" ]]; then
        periph="${key%%:*}"
        addr="${key##*:}"
        printf "    %-8s %-14s = %s\n" "$periph" "$addr" "${TB_VALUES[$key]}"
    fi
done

echo ""
echo "============================================"
if [ $TOTAL -eq 0 ]; then
    echo -e "  ${YELLOW}No overlapping registers to compare${NC}"
    echo "  (Renode co-sim libraries may not be built)"
    echo "============================================"
    exit 0
elif [ $MISMATCH -eq 0 ]; then
    echo -e "  Cross-Validation: ${GREEN}$MATCH/$TOTAL MATCH${NC}"
else
    echo -e "  Cross-Validation: ${RED}$MATCH/$TOTAL MATCH, $MISMATCH MISMATCH${NC}"
fi
echo "============================================"

[ $MISMATCH -eq 0 ] && exit 0 || exit 1
