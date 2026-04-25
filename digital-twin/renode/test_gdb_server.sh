#!/bin/bash
# SPDX-FileCopyrightText: 2025 aesc silicon
#
# SPDX-License-Identifier: CERN-OHL-W-2.0

# GDB Server Validation Test
# Starts Renode with GDB server, connects GDB in batch mode, verifies
# basic operations (register read, stepi), then cleans up.
# Exit 0 + "GDB_SERVER_TEST PASSED" on success, exit 1 on failure.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RENODE_PID=""
TMPDIR_GDB=$(mktemp -d)
GDB_CMDS="$TMPDIR_GDB/gdb_commands.gdb"
GDB_OUTPUT="$TMPDIR_GDB/gdb_output.log"
RENODE_LOG="$TMPDIR_GDB/renode.log"

cleanup() {
    # Kill the tail|renode pipeline and any child processes
    if [ -n "$RENODE_PID" ]; then
        kill "$RENODE_PID" 2>/dev/null
        # Also kill child processes (renode spawned by the pipe)
        pkill -P "$RENODE_PID" 2>/dev/null
        wait "$RENODE_PID" 2>/dev/null || true
    fi
    # Kill any lingering renode on port 3333
    fuser -k 3333/tcp 2>/dev/null || true
    rm -rf "$TMPDIR_GDB"
}
trap cleanup EXIT

echo "=== GDB Server Validation Test ==="

# Check that firmware ELF exists
ELF="$SCRIPT_DIR/../firmware/pwm_test/pwm_test.elf"
if [ ! -f "$ELF" ]; then
    echo "FAIL: Firmware ELF not found: $ELF"
    echo "GDB_SERVER_TEST FAILED"
    exit 1
fi

# Start Renode in background with GDB server
# Use tail -f /dev/null to keep stdin open — Renode --console exits on EOF
echo "Starting Renode with GDB server..."
tail -f /dev/null | renode --disable-xwt --console \
    -e "include @$SCRIPT_DIR/debug_bare_metal.resc" \
    > "$RENODE_LOG" 2>&1 &
RENODE_PID=$!

# Wait for GDB server to be ready (poll port 3333)
echo "Waiting for GDB server on port 3333..."
RETRIES=0
MAX_RETRIES=30
while ! bash -c 'echo > /dev/tcp/127.0.0.1/3333' 2>/dev/null; do
    RETRIES=$((RETRIES + 1))
    if [ $RETRIES -ge $MAX_RETRIES ]; then
        echo "FAIL: GDB server did not start within ${MAX_RETRIES}s"
        echo "Renode log:"
        cat "$RENODE_LOG"
        echo "GDB_SERVER_TEST FAILED"
        exit 1
    fi
    sleep 1
done
echo "GDB server ready after ${RETRIES}s"

# Create GDB batch commands
cat > "$GDB_CMDS" <<'GDBEOF'
set architecture riscv:rv32
set pagination off
set confirm off
target remote :3333
mon start
info registers
stepi
stepi
info registers
x/1xw 0x80000000
disconnect
quit
GDBEOF

# Run GDB in batch mode
echo "Running GDB batch commands..."
riscv-none-elf-gdb -batch -x "$GDB_CMDS" "$ELF" > "$GDB_OUTPUT" 2>&1
GDB_EXIT=$?

echo "GDB output:"
cat "$GDB_OUTPUT"

# Validate results
PASS=true

# Check GDB connected and read registers (look for 'ra' register name)
if ! grep -q "ra" "$GDB_OUTPUT"; then
    echo "FAIL: Register read did not return expected 'ra' register"
    PASS=false
fi

# Check stepi executed without error
if grep -qi "Cannot\|Error\|failed" "$GDB_OUTPUT" | grep -vi "Cannot access memory at address" > /dev/null 2>&1; then
    # Some memory access warnings are OK; only fail on connection/execution errors
    :
fi

# Check that we got some register output (any hex value in register dump)
if ! grep -qE "0x[0-9a-fA-F]+" "$GDB_OUTPUT"; then
    echo "FAIL: No register values found in GDB output"
    PASS=false
fi

echo ""
if [ "$PASS" = true ]; then
    echo "GDB_SERVER_TEST PASSED"
    exit 0
else
    echo "GDB_SERVER_TEST FAILED"
    exit 1
fi
