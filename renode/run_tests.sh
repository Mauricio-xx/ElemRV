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
    # - "Zicsr instruction set is not enabled" — Renode 1.16.0 logs this
    #   for rv32ic CPUs but executes CSR instructions correctly
    local filtered_errors
    filtered_errors=$(grep -i "error" "$logfile" \
        | grep -vi "Could not tokenize" \
        | grep -vi "Couldn't find" \
        | grep -vi "error_count" \
        | grep -vi "Zicsr instruction set is not enabled" \
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

# Test 3: Zephyr Hello World (UART console boot)
# Only run if the Zephyr ELF was built
if [ -f "$SCRIPT_DIR/../software/elemrv-zephyr/build/zephyr/zephyr.elf" ]; then
    run_test "Zephyr Hello World" "run_zephyr_hello.resc" "Zephyr Hello World Test PASSED"
else
    echo ""
    echo "=== TEST (skipped): Zephyr Hello World ==="
    echo "  Zephyr ELF not found. Build with: west build -b elemrv_h app/hello_world"
fi

# Test 4: Zephyr Blinky (GPIO output + Timer k_sleep)
if [ -f "$SCRIPT_DIR/../software/elemrv-zephyr/build-blinky/zephyr/zephyr.elf" ]; then
    run_test "Zephyr Blinky (GPIO+Timer)" "run_zephyr_blinky.resc" "Zephyr Blinky Test PASSED"
else
    echo ""
    echo "=== TEST (skipped): Zephyr Blinky ==="
    echo "  Blinky ELF not found. Build with: west build -b elemrv_h app/blinky -d build-blinky"
fi

# Test 5: Zephyr I2C Bus Scan (LiteX I2C driver)
if [ -f "$SCRIPT_DIR/../software/elemrv-zephyr/build-i2c-scan/zephyr/zephyr.elf" ]; then
    run_test "Zephyr I2C Scan" "run_zephyr_i2c_scan.resc" "Zephyr I2C Scan Test PASSED"
else
    echo ""
    echo "=== TEST (skipped): Zephyr I2C Scan ==="
    echo "  I2C scan ELF not found. Build with: west build -b elemrv_h app/i2c_scan -d build-i2c-scan"
fi

# Test 6: Zephyr PWM Driver (custom WishbonePwm)
if [ -f "$SCRIPT_DIR/../software/elemrv-zephyr/build-pwm-test/zephyr/zephyr.elf" ]; then
    run_test "Zephyr PWM Driver" "run_zephyr_pwm.resc" "Zephyr PWM Driver Test PASSED"
else
    echo ""
    echo "=== TEST (skipped): Zephyr PWM Driver ==="
    echo "  PWM test ELF not found. Build with: west build -b elemrv_h app/pwm_test -d build-pwm-test"
fi

# Test 7: Zephyr PIO Driver (custom WishbonePio)
if [ -f "$SCRIPT_DIR/../software/elemrv-zephyr/build-pio-test/zephyr/zephyr.elf" ]; then
    run_test "Zephyr PIO Driver" "run_zephyr_pio.resc" "Zephyr PIO Driver Test PASSED"
else
    echo ""
    echo "=== TEST (skipped): Zephyr PIO Driver ==="
    echo "  PIO test ELF not found. Build with: west build -b elemrv_h app/pio_test -d build-pio-test"
fi

# Test 8: Zephyr Pinmux Driver (custom WishbonePinmux)
if [ -f "$SCRIPT_DIR/../software/elemrv-zephyr/build-pinmux-test/zephyr/zephyr.elf" ]; then
    run_test "Zephyr Pinmux Driver" "run_zephyr_pinmux.resc" "Zephyr Pinmux Driver Test PASSED"
else
    echo ""
    echo "=== TEST (skipped): Zephyr Pinmux Driver ==="
    echo "  Pinmux test ELF not found. Build with: west build -b elemrv_h app/pinmux_test -d build-pinmux-test"
fi

# Test 9: PIO Co-simulation (Verilator RTL, register verification)
if [ -f "$SCRIPT_DIR/../renode/verilated/libs/libpio.so" ] || [ -f "/workspace/elemrv/renode/verilated/libs/libpio.so" ]; then
    run_test "PIO Co-simulation" "run_cosim_pio_test.resc" "PIO Co-simulation Test PASSED"
else
    echo ""
    echo "=== TEST (skipped): PIO Co-simulation ==="
    echo "  libpio.so not found. Build with: make -f Makefile.pio BUILD_MODE=release"
fi

# Test 10: Pinmux Co-simulation
if [ -f "$SCRIPT_DIR/../renode/verilated/libs/libpinmux.so" ] || [ -f "/workspace/elemrv/renode/verilated/libs/libpinmux.so" ]; then
    run_test "Pinmux Co-simulation" "run_cosim_pinmux_test.resc" "Pinmux Co-simulation Test PASSED"
else
    echo ""
    echo "=== TEST (skipped): Pinmux Co-simulation ==="
    echo "  libpinmux.so not found. Build with: make -f Makefile.pinmux BUILD_MODE=release"
fi

# Test 11: GPIO Co-simulation
if [ -f "$SCRIPT_DIR/../renode/verilated/libs/libgpio.so" ] || [ -f "/workspace/elemrv/renode/verilated/libs/libgpio.so" ]; then
    run_test "GPIO Co-simulation" "run_cosim_gpio_test.resc" "GPIO Co-simulation Test PASSED"
else
    echo ""
    echo "=== TEST (skipped): GPIO Co-simulation ==="
    echo "  libgpio.so not found. Build with: make -f Makefile.gpio BUILD_MODE=release"
fi

# Test 12: MachineTimer Co-simulation
if [ -f "$SCRIPT_DIR/../renode/verilated/libs/libmtimer.so" ] || [ -f "/workspace/elemrv/renode/verilated/libs/libmtimer.so" ]; then
    run_test "MachineTimer Co-simulation" "run_cosim_mtimer_test.resc" "MachineTimer Co-simulation Test PASSED"
else
    echo ""
    echo "=== TEST (skipped): MachineTimer Co-simulation ==="
    echo "  libmtimer.so not found. Build with: make -f Makefile.mtimer BUILD_MODE=release"
fi

# Test 13: I2C Co-simulation
if [ -f "$SCRIPT_DIR/../renode/verilated/libs/libi2c.so" ] || [ -f "/workspace/elemrv/renode/verilated/libs/libi2c.so" ]; then
    run_test "I2C Co-simulation" "run_cosim_i2c_test.resc" "I2C Co-simulation Test PASSED"
else
    echo ""
    echo "=== TEST (skipped): I2C Co-simulation ==="
    echo "  libi2c.so not found. Build with: make -f Makefile.i2c BUILD_MODE=release"
fi

# Test 14: UART Co-simulation
if [ -f "$SCRIPT_DIR/../renode/verilated/libs/libuart.so" ] || [ -f "/workspace/elemrv/renode/verilated/libs/libuart.so" ]; then
    run_test "UART Co-simulation" "run_cosim_uart_test.resc" "UART Co-simulation Test PASSED"
else
    echo ""
    echo "=== TEST (skipped): UART Co-simulation ==="
    echo "  libuart.so not found. Build with: make -f Makefile.uart BUILD_MODE=release"
fi

# Test 15: Full Co-simulation Integration (all 7 peripherals)
if [ -f "$SCRIPT_DIR/../renode/verilated/libs/libgpio.so" ] || [ -f "/workspace/elemrv/renode/verilated/libs/libgpio.so" ]; then
    run_test "Full Co-simulation Integration" "run_cosim_full_test.resc" "Full Co-simulation Integration Test PASSED"
else
    echo ""
    echo "=== TEST (skipped): Full Co-simulation Integration ==="
    echo "  Co-sim libraries not found. Build with: bash build_all_cosim.sh"
fi

# --- Cross-Peripheral Integration Tests ---

# Test 16: Multi-Peripheral Register Sequence (all 7 co-sim)
if [ -f "$SCRIPT_DIR/../renode/verilated/libs/libgpio.so" ] || [ -f "/workspace/elemrv/renode/verilated/libs/libgpio.so" ]; then
    run_test "Multi-Peripheral Register Sequence" "run_cosim_multi_reg_test.resc" "Multi-Peripheral Register Sequence Test PASSED"
else
    echo ""
    echo "=== TEST (skipped): Multi-Peripheral Register Sequence ==="
    echo "  Co-sim libraries not found. Build with: bash build_all_cosim.sh"
fi

# Test 17: Pinmux+PWM Register Sequence (all 7 co-sim)
if [ -f "$SCRIPT_DIR/../renode/verilated/libs/libgpio.so" ] || [ -f "/workspace/elemrv/renode/verilated/libs/libgpio.so" ]; then
    run_test "Pinmux+PWM Register Sequence" "run_cosim_pinmux_pwm_seq_test.resc" "Pinmux+PWM Register Sequence Test PASSED"
else
    echo ""
    echo "=== TEST (skipped): Pinmux+PWM Register Sequence ==="
    echo "  Co-sim libraries not found. Build with: bash build_all_cosim.sh"
fi

# Test 18: Zephyr Timer-UART Integration (interrupt-driven flow)
if [ -f "$SCRIPT_DIR/../software/elemrv-zephyr/build-timer-uart-test/zephyr/zephyr.elf" ]; then
    run_test "Zephyr Timer-UART Integration" "run_zephyr_timer_uart.resc" "Zephyr Timer-UART Integration Test PASSED"
else
    echo ""
    echo "=== TEST (skipped): Zephyr Timer-UART Integration ==="
    echo "  ELF not found. Build with: west build -b elemrv_h app/timer_uart_test -d build-timer-uart-test"
fi

# Test 19: Hybrid Pinmux+PWM (co-sim PWM/Pinmux + LiteX UART/Timer)
HYBRID_LIBS_OK=false
if { [ -f "$SCRIPT_DIR/../renode/verilated/libs/libpwm.so" ] || [ -f "/workspace/elemrv/renode/verilated/libs/libpwm.so" ]; } && \
   { [ -f "$SCRIPT_DIR/../renode/verilated/libs/libpinmux.so" ] || [ -f "/workspace/elemrv/renode/verilated/libs/libpinmux.so" ]; } && \
   { [ -f "$SCRIPT_DIR/../renode/verilated/libs/libpio.so" ] || [ -f "/workspace/elemrv/renode/verilated/libs/libpio.so" ]; }; then
    HYBRID_LIBS_OK=true
fi

if [ "$HYBRID_LIBS_OK" = true ] && [ -f "$SCRIPT_DIR/../software/elemrv-zephyr/build-hybrid-pinmux-pwm/zephyr/zephyr.elf" ]; then
    run_test "Hybrid Pinmux+PWM" "run_hybrid_pinmux_pwm.resc" "Hybrid Pinmux-PWM Integration Test PASSED"
else
    echo ""
    echo "=== TEST (skipped): Hybrid Pinmux+PWM ==="
    echo "  ELF or co-sim libraries not found."
fi

# Test 20: Hybrid PIO+UART (co-sim PIO + LiteX UART/Timer)
if [ "$HYBRID_LIBS_OK" = true ] && [ -f "$SCRIPT_DIR/../software/elemrv-zephyr/build-hybrid-pio-uart/zephyr/zephyr.elf" ]; then
    run_test "Hybrid PIO+UART" "run_hybrid_pio_uart.resc" "Hybrid PIO-UART Integration Test PASSED"
else
    echo ""
    echo "=== TEST (skipped): Hybrid PIO+UART ==="
    echo "  ELF or co-sim libraries not found."
fi

# Test 21: Hybrid Multi-Cosim (all 3 co-sim + LiteX UART/Timer)
if [ "$HYBRID_LIBS_OK" = true ] && [ -f "$SCRIPT_DIR/../software/elemrv-zephyr/build-hybrid-multi-cosim/zephyr/zephyr.elf" ]; then
    run_test "Hybrid Multi-Cosim" "run_hybrid_multi_cosim.resc" "Hybrid Multi-Cosim Integration Test PASSED"
else
    echo ""
    echo "=== TEST (skipped): Hybrid Multi-Cosim ==="
    echo "  ELF or co-sim libraries not found."
fi

# --- Pure Verilator Testbenches ---

# Test 22: Pure Verilator Testbenches (no Renode)
if [ -f "$SCRIPT_DIR/verilated/testbenches/Makefile" ]; then
    TOTAL=$((TOTAL + 1))
    echo ""
    echo "=== TEST $TOTAL: Pure Verilator Testbenches ==="
    local_logfile="/tmp/dt_test_${TOTAL}.log"

    if make -C "$SCRIPT_DIR/verilated/testbenches" run > "$local_logfile" 2>&1; then
        echo "  --- output tail ---"
        tail -10 "$local_logfile" | sed 's/^/  | /'
        echo "  ---"
        if grep -q "All testbenches PASSED" "$local_logfile"; then
            echo -e "  RESULT: ${GREEN}PASS${NC}"
            PASS=$((PASS + 1))
        else
            echo -e "  RESULT: ${RED}FAIL${NC}"
            FAIL=$((FAIL + 1))
        fi
    else
        echo "  --- output tail ---"
        tail -10 "$local_logfile" | sed 's/^/  | /'
        echo "  ---"
        echo -e "  RESULT: ${RED}FAIL${NC}"
        FAIL=$((FAIL + 1))
    fi
else
    echo ""
    echo "=== TEST (skipped): Pure Verilator Testbenches ==="
    echo "  Makefile not found at verilated/testbenches/Makefile"
fi

# --- GDB Server Validation ---

# Test 23: GDB Server Validation
if [ -f "$SCRIPT_DIR/test_gdb_server.sh" ]; then
    TOTAL=$((TOTAL + 1))
    echo ""
    echo "=== TEST $TOTAL: GDB Server Validation ==="
    local_logfile="/tmp/dt_test_${TOTAL}.log"

    if bash "$SCRIPT_DIR/test_gdb_server.sh" > "$local_logfile" 2>&1; then
        echo "  --- output tail ---"
        tail -10 "$local_logfile" | sed 's/^/  | /'
        echo "  ---"
        if grep -q "GDB_SERVER_TEST PASSED" "$local_logfile"; then
            echo -e "  RESULT: ${GREEN}PASS${NC}"
            PASS=$((PASS + 1))
        else
            echo -e "  RESULT: ${RED}FAIL${NC}"
            FAIL=$((FAIL + 1))
        fi
    else
        echo "  --- output tail ---"
        tail -10 "$local_logfile" | sed 's/^/  | /'
        echo "  ---"
        echo -e "  RESULT: ${RED}FAIL${NC}"
        FAIL=$((FAIL + 1))
    fi
else
    echo ""
    echo "=== TEST (skipped): GDB Server Validation ==="
    echo "  test_gdb_server.sh not found"
fi

# --- Fault Injection Tests ---

# Test 24: PWM Register Corruption
if [ -f "$SCRIPT_DIR/../renode/verilated/libs/libgpio.so" ] || [ -f "/workspace/elemrv/renode/verilated/libs/libgpio.so" ]; then
    run_test "Fault: PWM Register Corruption" "run_fault_pwm_corruption.resc" "PWM Fault Injection Test PASSED"
else
    echo ""
    echo "=== TEST (skipped): Fault: PWM Register Corruption ==="
    echo "  Co-sim libraries not found. Build with: bash build_all_cosim.sh"
fi

# Test 25: GPIO Register Corruption
if [ -f "$SCRIPT_DIR/../renode/verilated/libs/libgpio.so" ] || [ -f "/workspace/elemrv/renode/verilated/libs/libgpio.so" ]; then
    run_test "Fault: GPIO Register Corruption" "run_fault_gpio_corruption.resc" "GPIO Fault Injection Test PASSED"
else
    echo ""
    echo "=== TEST (skipped): Fault: GPIO Register Corruption ==="
    echo "  Co-sim libraries not found. Build with: bash build_all_cosim.sh"
fi

# Test 26: Timer Perturbation
if [ -f "$SCRIPT_DIR/../software/elemrv-zephyr/build-timer-uart-test/zephyr/zephyr.elf" ]; then
    run_test "Fault: Timer Perturbation" "run_fault_timer_perturb.resc" "Timer Perturbation Fault Test PASSED"
else
    echo ""
    echo "=== TEST (skipped): Fault: Timer Perturbation ==="
    echo "  ELF not found. Build with: west build -b elemrv_h app/timer_uart_test -d build-timer-uart-test"
fi

# Test 27: UART Injection
if [ -f "$SCRIPT_DIR/../software/elemrv-zephyr/build/zephyr/zephyr.elf" ]; then
    run_test "Fault: UART Injection" "run_fault_uart_injection.resc" "UART Fault Injection Test PASSED"
else
    echo ""
    echo "=== TEST (skipped): Fault: UART Injection ==="
    echo "  Zephyr hello_world ELF not found. Build with: west build -b elemrv_h app/hello_world"
fi

# Test 28: Missing Peripheral
run_test "Fault: Missing Peripheral" "run_fault_missing_peripheral.resc" "Missing Peripheral Fault Test PASSED"

# --- I2C Sensor Tests ---

# Test 29: I2C Sensor Detection
if [ -f "$SCRIPT_DIR/../software/elemrv-zephyr/build-i2c-scan/zephyr/zephyr.elf" ]; then
    run_test "I2C Sensor Detection" "run_sensor_detect.resc" "I2C Sensor Detection Test PASSED"
else
    echo ""
    echo "=== TEST (skipped): I2C Sensor Detection ==="
    echo "  I2C scan ELF not found. Build with: west build -b elemrv_h app/i2c_scan -d build-i2c-scan"
fi

# Test 30: Sensor Capture
if [ -f "$SCRIPT_DIR/../software/elemrv-zephyr/build-sensor-capture/zephyr/zephyr.elf" ]; then
    run_test "Sensor Capture" "run_sensor_capture.resc" "Sensor Capture Integration Test PASSED"
else
    echo ""
    echo "=== TEST (skipped): Sensor Capture ==="
    echo "  Sensor capture ELF not found. Build with: west build -b elemrv_h app/sensor_capture -d build-sensor-capture"
fi

# --- ElemRV-N Tests ---

# Test 31: N Base Platform
run_test "N Base Platform" "run_n_base_test.resc" "ElemRV-N Base Platform Test PASSED"

# Test 32: N GPIO Co-simulation
if [ -f "$SCRIPT_DIR/../renode/verilated/libs/libgpio_n.so" ] || [ -f "/workspace/elemrv/renode/verilated/libs/libgpio_n.so" ]; then
    run_test "N GPIO Co-simulation" "run_n_cosim_gpio_test.resc" "N GPIO Co-simulation Test PASSED"
else
    echo ""
    echo "=== TEST (skipped): N GPIO Co-simulation ==="
    echo "  libgpio_n.so not found. Build with: bash build_n_cosim.sh release"
fi

# Test 33: N SPI Co-simulation
if [ -f "$SCRIPT_DIR/../renode/verilated/libs/libspi.so" ] || [ -f "/workspace/elemrv/renode/verilated/libs/libspi.so" ]; then
    run_test "N SPI Co-simulation" "run_n_cosim_spi_test.resc" "N SPI Co-simulation Test PASSED"
else
    echo ""
    echo "=== TEST (skipped): N SPI Co-simulation ==="
    echo "  libspi.so not found. Build with: bash build_n_cosim.sh release"
fi

# Test 34: N I2C Lite Co-simulation
if [ -f "$SCRIPT_DIR/../renode/verilated/libs/libi2c_lite.so" ] || [ -f "/workspace/elemrv/renode/verilated/libs/libi2c_lite.so" ]; then
    run_test "N I2C Lite Co-simulation" "run_n_cosim_i2c_lite_test.resc" "N I2C Lite Co-simulation Test PASSED"
else
    echo ""
    echo "=== TEST (skipped): N I2C Lite Co-simulation ==="
    echo "  libi2c_lite.so not found. Build with: bash build_n_cosim.sh release"
fi

# Test 35: N UART Lite Co-simulation
if [ -f "$SCRIPT_DIR/../renode/verilated/libs/libuart_lite.so" ] || [ -f "/workspace/elemrv/renode/verilated/libs/libuart_lite.so" ]; then
    run_test "N UART Lite Co-simulation" "run_n_cosim_uart_lite_test.resc" "N UART Lite Co-simulation Test PASSED"
else
    echo ""
    echo "=== TEST (skipped): N UART Lite Co-simulation ==="
    echo "  libuart_lite.so not found. Build with: bash build_n_cosim.sh release"
fi

# Test 36: N Pinmux Co-simulation
if [ -f "$SCRIPT_DIR/../renode/verilated/libs/libpinmux_n.so" ] || [ -f "/workspace/elemrv/renode/verilated/libs/libpinmux_n.so" ]; then
    run_test "N Pinmux Co-simulation" "run_n_cosim_pinmux_test.resc" "N Pinmux Co-simulation Test PASSED"
else
    echo ""
    echo "=== TEST (skipped): N Pinmux Co-simulation ==="
    echo "  libpinmux_n.so not found. Build with: bash build_n_cosim.sh release"
fi

# Test 37: N Full Co-simulation Integration (all 10 peripherals)
if [ -f "$SCRIPT_DIR/../renode/verilated/libs/libgpio_n.so" ] || [ -f "/workspace/elemrv/renode/verilated/libs/libgpio_n.so" ]; then
    run_test "N Full Co-simulation Integration" "run_n_cosim_full_test.resc" "N Full Co-simulation Test PASSED"
else
    echo ""
    echo "=== TEST (skipped): N Full Co-simulation Integration ==="
    echo "  N co-sim libraries not found. Build with: bash build_n_cosim.sh release"
fi

# Test 38: N Pure Verilator Testbenches
if [ -f "$SCRIPT_DIR/verilated/testbenches/Makefile.nitrogen" ]; then
    TOTAL=$((TOTAL + 1))
    echo ""
    echo "=== TEST $TOTAL: N Pure Verilator Testbenches ==="
    local_logfile="/tmp/dt_test_${TOTAL}.log"

    if make -C "$SCRIPT_DIR/verilated/testbenches" -f Makefile.nitrogen run > "$local_logfile" 2>&1; then
        echo "  --- output tail ---"
        tail -10 "$local_logfile" | sed 's/^/  | /'
        echo "  ---"
        if grep -q "All N testbenches PASSED" "$local_logfile"; then
            echo -e "  RESULT: ${GREEN}PASS${NC}"
            PASS=$((PASS + 1))
        else
            echo -e "  RESULT: ${RED}FAIL${NC}"
            FAIL=$((FAIL + 1))
        fi
    else
        echo "  --- output tail ---"
        tail -10 "$local_logfile" | sed 's/^/  | /'
        echo "  ---"
        echo -e "  RESULT: ${RED}FAIL${NC}"
        FAIL=$((FAIL + 1))
    fi
else
    echo ""
    echo "=== TEST (skipped): N Pure Verilator Testbenches ==="
    echo "  Makefile.nitrogen not found at verilated/testbenches/Makefile.nitrogen"
fi

# Test 39: N Zephyr Hello World
if [ -f "$SCRIPT_DIR/../software/elemrv-zephyr/build-n-hello/zephyr/zephyr.elf" ]; then
    run_test "N Zephyr Hello World" "run_n_zephyr_hello.resc" "N Zephyr Hello World Test PASSED"
else
    echo ""
    echo "=== TEST (skipped): N Zephyr Hello World ==="
    echo "  N hello ELF not found. Build with: west build -b elemrv_n app/hello_world -d build-n-hello"
fi

# Test 40: N Zephyr Blinky
if [ -f "$SCRIPT_DIR/../software/elemrv-zephyr/build-n-blinky/zephyr/zephyr.elf" ]; then
    run_test "N Zephyr Blinky (GPIO+Timer)" "run_n_zephyr_blinky.resc" "N Zephyr Blinky Test PASSED"
else
    echo ""
    echo "=== TEST (skipped): N Zephyr Blinky ==="
    echo "  N blinky ELF not found. Build with: west build -b elemrv_n app/blinky -d build-n-blinky"
fi

# --- RTOS Debug Tests ---

# Test 41: RTOS Debug Demo (multi-thread + thread analyzer)
if [ -f "$SCRIPT_DIR/../software/elemrv-zephyr/build-rtos-debug-demo/zephyr/zephyr.elf" ]; then
    run_test "RTOS Debug Demo" "run_rtos_debug_demo_test.resc" "RTOS Debug Demo Test PASSED"
else
    echo ""
    echo "=== TEST (skipped): RTOS Debug Demo ==="
    echo "  ELF not found. Build with: west build -b elemrv_h app/rtos_debug_demo -d build-rtos-debug-demo"
fi

# Test 42: RTOS Diagnostics (auto thread analyzer + logging)
if [ -f "$SCRIPT_DIR/../software/elemrv-zephyr/build-rtos-diagnostics/zephyr/zephyr.elf" ]; then
    run_test "RTOS Diagnostics" "run_rtos_diagnostics_test.resc" "RTOS Diagnostics Test PASSED"
else
    echo ""
    echo "=== TEST (skipped): RTOS Diagnostics ==="
    echo "  ELF not found. Build with: west build -b elemrv_h app/rtos_diagnostics -d build-rtos-diagnostics"
fi

# Test 43: RTOS GDB Threads (validates debug symbols + thread metadata)
if [ -f "$SCRIPT_DIR/../software/elemrv-zephyr/build-rtos-debug-demo/zephyr/zephyr.elf" ]; then
    run_test "RTOS GDB Threads" "run_rtos_gdb_threads_test.resc" "RTOS GDB Threads Test PASSED"
else
    echo ""
    echo "=== TEST (skipped): RTOS GDB Threads ==="
    echo "  ELF not found. Build with: west build -b elemrv_h app/rtos_debug_demo -d build-rtos-debug-demo"
fi

# Test 44: N RTOS Debug Demo
if [ -f "$SCRIPT_DIR/../software/elemrv-zephyr/build-n-rtos-debug-demo/zephyr/zephyr.elf" ]; then
    run_test "N RTOS Debug Demo" "run_n_rtos_debug_demo_test.resc" "N RTOS Debug Demo Test PASSED"
else
    echo ""
    echo "=== TEST (skipped): N RTOS Debug Demo ==="
    echo "  ELF not found. Build with: west build -b elemrv_n app/rtos_debug_demo -d build-n-rtos-debug-demo"
fi

# Test 45: N RTOS Diagnostics
if [ -f "$SCRIPT_DIR/../software/elemrv-zephyr/build-n-rtos-diagnostics/zephyr/zephyr.elf" ]; then
    run_test "N RTOS Diagnostics" "run_n_rtos_diagnostics_test.resc" "N RTOS Diagnostics Test PASSED"
else
    echo ""
    echo "=== TEST (skipped): N RTOS Diagnostics ==="
    echo "  ELF not found. Build with: west build -b elemrv_n app/rtos_diagnostics -d build-n-rtos-diagnostics"
fi

# Test 46: N RTOS GDB Threads
if [ -f "$SCRIPT_DIR/../software/elemrv-zephyr/build-n-rtos-debug-demo/zephyr/zephyr.elf" ]; then
    run_test "N RTOS GDB Threads" "run_n_rtos_gdb_threads_test.resc" "N RTOS GDB Threads Test PASSED"
else
    echo ""
    echo "=== TEST (skipped): N RTOS GDB Threads ==="
    echo "  ELF not found. Build with: west build -b elemrv_n app/rtos_debug_demo -d build-n-rtos-debug-demo"
fi

# --- I2C Sensor Tests (Generic) ---

# Test 47: H I2C Sensor Capture (generic sensor @ 0x48)
if [ -f "$SCRIPT_DIR/../software/elemrv-zephyr/build-sensor-i2c-capture/zephyr/zephyr.elf" ]; then
    run_test "H I2C Sensor Capture" "run_sensor_i2c_h_test.resc" "Sensor I2C H Test PASSED"
else
    echo ""
    echo "=== TEST (skipped): H I2C Sensor Capture ==="
    echo "  ELF not found. Build with: west build -b elemrv_h app/sensor_i2c_capture -d build-sensor-i2c-capture"
fi

# Test 48: N I2C Sensor Capture (same firmware, different board)
if [ -f "$SCRIPT_DIR/../software/elemrv-zephyr/build-n-sensor-i2c-capture/zephyr/zephyr.elf" ]; then
    run_test "N I2C Sensor Capture" "run_sensor_i2c_n_test.resc" "Sensor I2C N Test PASSED"
else
    echo ""
    echo "=== TEST (skipped): N I2C Sensor Capture ==="
    echo "  ELF not found. Build with: west build -b elemrv_n app/sensor_i2c_capture -d build-n-sensor-i2c-capture"
fi

# --- SPI Sensor Tests ---

# Test 49: N SPI Sensor Capture (co-sim SPI + embedded sensor slave)
if { [ -f "$SCRIPT_DIR/../renode/verilated/libs/libspi.so" ] || [ -f "/workspace/elemrv/renode/verilated/libs/libspi.so" ]; } && \
   [ -f "$SCRIPT_DIR/../software/elemrv-zephyr/build-n-sensor-spi-capture/zephyr/zephyr.elf" ]; then
    run_test "N SPI Sensor Capture" "run_sensor_spi_n_test.resc" "Sensor SPI N Test PASSED"
else
    echo ""
    echo "=== TEST (skipped): N SPI Sensor Capture ==="
    echo "  ELF or libspi.so not found. Build with: make -f Makefile.spi BUILD_MODE=release && west build -b elemrv_n app/sensor_spi_capture -d build-n-sensor-spi-capture"
fi

echo ""
echo "============================================"
if [ $FAIL -eq 0 ]; then
    echo -e "  SUMMARY: ${GREEN}$PASS/$TOTAL passed${NC}"
else
    echo -e "  SUMMARY: ${RED}$PASS/$TOTAL passed, $FAIL failed${NC}"
fi
echo "============================================"

[ $FAIL -eq 0 ] && exit 0 || exit 1
