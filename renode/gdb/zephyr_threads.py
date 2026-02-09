# SPDX-FileCopyrightText: 2025 aesc silicon
#
# SPDX-License-Identifier: CERN-OHL-W-2.0

"""
Zephyr RTOS thread-aware GDB commands for ElemRV digital twin.

Reads kernel data structures directly from memory to list threads,
their state, priority, and stack usage. Works around Renode 1.16.0's
lack of native GDB RTOS thread awareness (issue #637).

Requires CONFIG_DEBUG_THREAD_INFO=y and CONFIG_THREAD_MONITOR=y in
the Zephyr firmware.

Usage (from GDB connected to Renode):
    source gdb/zephyr_threads.py
    zephyr-threads
    zephyr-stacks
"""

import gdb
import struct

# Offset indices into _kernel_openocd_offsets (a.k.a. _kernel_thread_info_offsets).
# See zephyr/subsys/debug/thread_info.c for definitions.
OFFSET_VERSION = 0
OFFSET_K_CURR_THREAD = 1
OFFSET_K_THREADS = 2
OFFSET_T_ENTRY = 3
OFFSET_T_NEXT_THREAD = 4
OFFSET_T_STATE = 5
OFFSET_T_USER_OPTIONS = 6
OFFSET_T_PRIO = 7
OFFSET_T_STACK_PTR = 8
OFFSET_T_NAME = 9

UNIMPLEMENTED = 0xFFFFFFFF

# Thread state bitmask (zephyr/include/zephyr/kernel_structs.h)
_THREAD_DUMMY = 0x01
_THREAD_PENDING = 0x02
_THREAD_SLEEPING = 0x04
_THREAD_DEAD = 0x08
_THREAD_SUSPENDED = 0x10
_THREAD_ABORTING = 0x20
_THREAD_SUSPENDING = 0x40
_THREAD_QUEUED = 0x80

# Stack sentinel for CONFIG_INIT_STACKS
STACK_SENTINEL = 0xAAAAAAAA


def _read_u32(addr):
    """Read a 32-bit unsigned integer from target memory."""
    inferior = gdb.selected_inferior()
    data = inferior.read_memory(addr, 4)
    return struct.unpack("<I", bytes(data))[0]


def _read_u8(addr):
    """Read an 8-bit unsigned integer from target memory."""
    inferior = gdb.selected_inferior()
    data = inferior.read_memory(addr, 1)
    return struct.unpack("<B", bytes(data))[0]


def _read_i8(addr):
    """Read an 8-bit signed integer from target memory."""
    inferior = gdb.selected_inferior()
    data = inferior.read_memory(addr, 1)
    return struct.unpack("<b", bytes(data))[0]


def _read_string(addr, max_len=32):
    """Read a null-terminated string from target memory."""
    inferior = gdb.selected_inferior()
    data = inferior.read_memory(addr, max_len)
    raw = bytes(data)
    end = raw.find(b'\x00')
    if end >= 0:
        raw = raw[:end]
    try:
        return raw.decode("ascii")
    except UnicodeDecodeError:
        return "<invalid>"


def _load_offsets():
    """Load the _kernel_openocd_offsets array from the ELF symbol table."""
    try:
        sym = gdb.lookup_symbol("_kernel_openocd_offsets")[0]
        if sym is None:
            # Try alternate name
            sym = gdb.lookup_symbol("_kernel_thread_info_offsets")[0]
        if sym is None:
            raise RuntimeError(
                "Symbol _kernel_openocd_offsets not found. "
                "Is CONFIG_DEBUG_THREAD_INFO=y enabled?"
            )
        base = int(sym.value().address)
    except gdb.error as e:
        raise RuntimeError(
            "Cannot read _kernel_openocd_offsets: {}. "
            "Load the ELF with symbols first.".format(e)
        )

    # Read the number of offsets
    try:
        num_sym = gdb.lookup_symbol("_kernel_thread_info_num_offsets")[0]
        if num_sym is not None:
            num = int(num_sym.value())
        else:
            num = 15  # Default for Zephyr 4.x
    except gdb.error:
        num = 15

    offsets = []
    for i in range(num):
        offsets.append(_read_u32(base + i * 4))

    version = offsets[OFFSET_VERSION] if len(offsets) > 0 else 0
    if version != 1:
        gdb.write("WARNING: Unexpected offset version {} (expected 1)\n".format(version))

    return offsets


def _get_kernel_base():
    """Get the address of the _kernel global variable."""
    try:
        sym = gdb.lookup_symbol("_kernel")[0]
        if sym is None:
            raise RuntimeError("Symbol _kernel not found")
        return int(sym.value().address)
    except gdb.error as e:
        raise RuntimeError("Cannot find _kernel symbol: {}".format(e))


def _state_to_str(state):
    """Convert thread state bitmask to human-readable string."""
    if state == 0:
        return "RUNNING"
    flags = []
    if state & _THREAD_DUMMY:
        flags.append("DUMMY")
    if state & _THREAD_PENDING:
        flags.append("PENDING")
    if state & _THREAD_SLEEPING:
        flags.append("SLEEPING")
    if state & _THREAD_DEAD:
        flags.append("DEAD")
    if state & _THREAD_SUSPENDED:
        flags.append("SUSPENDED")
    if state & _THREAD_ABORTING:
        flags.append("ABORTING")
    if state & _THREAD_SUSPENDING:
        flags.append("SUSPENDING")
    if state & _THREAD_QUEUED:
        flags.append("QUEUED")
    return "|".join(flags) if flags else "UNKNOWN(0x{:02x})".format(state)


def _walk_threads(offsets, kernel_base):
    """Walk the thread linked list and return a list of thread info dicts."""
    k_threads_off = offsets[OFFSET_K_THREADS]
    t_next_off = offsets[OFFSET_T_NEXT_THREAD]
    t_state_off = offsets[OFFSET_T_STATE]
    t_prio_off = offsets[OFFSET_T_PRIO]
    t_name_off = offsets[OFFSET_T_NAME]
    t_stack_ptr_off = offsets[OFFSET_T_STACK_PTR]
    t_entry_off = offsets[OFFSET_T_ENTRY]

    # Get current thread pointer
    k_curr_off = offsets[OFFSET_K_CURR_THREAD]
    curr_thread = _read_u32(kernel_base + k_curr_off)

    # Get head of thread list
    thread_ptr = _read_u32(kernel_base + k_threads_off)

    threads = []
    visited = set()
    max_threads = 32  # Safety limit

    while thread_ptr != 0 and len(threads) < max_threads:
        if thread_ptr in visited:
            gdb.write("WARNING: Circular thread list detected at 0x{:08x}\n".format(
                thread_ptr))
            break
        visited.add(thread_ptr)

        info = {"addr": thread_ptr}

        # Thread name
        if t_name_off != UNIMPLEMENTED:
            name_ptr = _read_u32(thread_ptr + t_name_off)
            if name_ptr != 0:
                info["name"] = _read_string(name_ptr)
            else:
                info["name"] = "<unnamed>"
        else:
            info["name"] = "<no CONFIG_THREAD_NAME>"

        # State
        info["state_raw"] = _read_u8(thread_ptr + t_state_off)
        info["state"] = _state_to_str(info["state_raw"])

        # Priority (signed byte)
        info["prio"] = _read_i8(thread_ptr + t_prio_off)

        # Stack pointer
        if t_stack_ptr_off != UNIMPLEMENTED:
            info["sp"] = _read_u32(thread_ptr + t_stack_ptr_off)
        else:
            info["sp"] = 0

        # Entry point
        if t_entry_off != UNIMPLEMENTED:
            info["entry"] = _read_u32(thread_ptr + t_entry_off)
        else:
            info["entry"] = 0

        # Is current?
        info["current"] = (thread_ptr == curr_thread)

        threads.append(info)

        # Next thread
        thread_ptr = _read_u32(thread_ptr + t_next_off)

    return threads


def _get_stack_info(thread_ptr):
    """Read stack_info.start and stack_info.size from a k_thread.

    These live in k_thread.stack_info which is enabled by
    CONFIG_THREAD_STACK_INFO=y. The offsets are obtained from
    the struct layout. We use GDB's type system to read them.
    """
    try:
        thread_type = gdb.lookup_type("struct k_thread")
        thread_val = gdb.Value(thread_ptr).cast(thread_type.pointer()).dereference()
        stack_start = int(thread_val["stack_info"]["start"])
        stack_size = int(thread_val["stack_info"]["size"])
        return stack_start, stack_size
    except (gdb.error, KeyError):
        return 0, 0


def _measure_stack_usage(stack_start, stack_size):
    """Measure stack usage by scanning for the 0xAAAAAAAA sentinel.

    Requires CONFIG_INIT_STACKS=y. Stacks grow downward on RISC-V,
    so unused space at the bottom is filled with 0xAA bytes.
    Returns (used_bytes, total_bytes) or (0, total_bytes) on failure.
    """
    if stack_start == 0 or stack_size == 0:
        return 0, stack_size

    try:
        inferior = gdb.selected_inferior()
        # Read stack in 4-byte chunks from bottom (low address)
        unused = 0
        for offset in range(0, stack_size, 4):
            word = _read_u32(stack_start + offset)
            if word == STACK_SENTINEL:
                unused += 4
            else:
                break
        used = stack_size - unused
        return used, stack_size
    except gdb.MemoryError:
        return 0, stack_size


class ZephyrThreadsCommand(gdb.Command):
    """List all Zephyr threads with name, state, and priority."""

    def __init__(self):
        super().__init__("zephyr-threads", gdb.COMMAND_STATUS)

    def invoke(self, arg, from_tty):
        try:
            offsets = _load_offsets()
            kernel_base = _get_kernel_base()
            threads = _walk_threads(offsets, kernel_base)
        except RuntimeError as e:
            gdb.write("ERROR: {}\n".format(e))
            return

        if not threads:
            gdb.write("No threads found (is the kernel running?)\n")
            return

        gdb.write("\n")
        gdb.write("=== Zephyr Threads ({} total) ===\n".format(len(threads)))
        gdb.write("{:<4} {:<20} {:<14} {:<5} {:<12} {}\n".format(
            "Cur", "Name", "State", "Prio", "SP", "Address"))
        gdb.write("{}\n".format("-" * 72))

        for t in threads:
            cur = " *" if t["current"] else "  "
            gdb.write("{:<4} {:<20} {:<14} {:<5} 0x{:08x}   0x{:08x}\n".format(
                cur, t["name"][:20], t["state"][:14],
                t["prio"], t["sp"], t["addr"]))

        gdb.write("\n")


class ZephyrStacksCommand(gdb.Command):
    """Show stack usage for all Zephyr threads."""

    def __init__(self):
        super().__init__("zephyr-stacks", gdb.COMMAND_STATUS)

    def invoke(self, arg, from_tty):
        try:
            offsets = _load_offsets()
            kernel_base = _get_kernel_base()
            threads = _walk_threads(offsets, kernel_base)
        except RuntimeError as e:
            gdb.write("ERROR: {}\n".format(e))
            return

        if not threads:
            gdb.write("No threads found (is the kernel running?)\n")
            return

        gdb.write("\n")
        gdb.write("=== Zephyr Thread Stacks ===\n")
        gdb.write("{:<20} {:<12} {:<8} {:<8} {}\n".format(
            "Name", "Stack Base", "Size", "Used", "Usage"))
        gdb.write("{}\n".format("-" * 64))

        for t in threads:
            stack_start, stack_size = _get_stack_info(t["addr"])
            if stack_size > 0:
                used, total = _measure_stack_usage(stack_start, stack_size)
                if total > 0:
                    pct = (used * 100) // total
                    bar_len = 20
                    filled = (pct * bar_len) // 100
                    bar = "#" * filled + "." * (bar_len - filled)
                    gdb.write("{:<20} 0x{:08x}   {:<8} {:<8} {:3}% [{}]\n".format(
                        t["name"][:20], stack_start, total, used, pct, bar))
                else:
                    gdb.write("{:<20} 0x{:08x}   {:<8} {:<8} N/A\n".format(
                        t["name"][:20], stack_start, total, used))
            else:
                gdb.write("{:<20} {:<12} (stack info unavailable)\n".format(
                    t["name"][:20], ""))

        gdb.write("\n")
        gdb.write("Note: Stack measurement requires CONFIG_INIT_STACKS=y.\n")
        gdb.write("      0xAAAAAAAA sentinel pattern marks unused stack space.\n")
        gdb.write("\n")


# Register commands when sourced
ZephyrThreadsCommand()
ZephyrStacksCommand()

gdb.write("Zephyr RTOS debug commands loaded: zephyr-threads, zephyr-stacks\n")
