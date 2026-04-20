/*
 * SPDX-FileCopyrightText: 2025 aesc silicon
 *
 * SPDX-License-Identifier: Apache-2.0
 */

/*
 * Bootrom-adapted XIP test firmware.
 *
 * Derived from software/elemrv_n/bootrom/start.s, trimmed to the parts
 * the minimal BmbSpiXip test platform can actually honour:
 *
 *   - _init_regs: partial register fill (proves jal/ret control flow
 *                 and multi-instruction sequences fetched from XIP)
 *   - _init_xip:  writes the same 0x007f0702 config word upstream uses,
 *                 retargeted to the cfgXip bank of the BmbSpiXip DT
 *                 (0xF000A000 instead of 0xF0025000). Writes are
 *                 observable through the Wishbone slave on bank 1.
 *
 * GPIO, HyperRAM memc init and 0xA0010000 relocate are omitted because
 * the test platform does not expose those peripherals or memory ranges.
 *
 * Success marker (0xBEADFACE) is written to RAM[0x100]; the resc test
 * reads it back after ~10-20 s of wall time and asserts equality.
 */

.equ CFGXIP_BASE,   0xF000A000
.equ CFGXIP_OFF_0C, 0x0C
.equ CFGXIP_OFF_08, 0x08
# Upstream bootrom writes 0x007f0702 here (mode=2 quad, dummyCycles=7,
# evcr=0x7f) to enable Quad I/O XIP. Our DT's slave + controller pair
# does not yet fully implement the quad-mode fetch protocol (pending
# Gap 3.2 #2 investigation), so we write 0x00000000 instead. The
# configure pulse still runs WREN+WRITE_REGISTER on the flash, so the
# bus-write path and configure state machine are still exercised;
# subsequent XIP fetches continue to use cmd=0x03 single-IO reads that
# the slave fully supports. Once Gap 3.2 #2 closes the quad path, this
# value can be restored to match upstream.
.equ CFGXIP_VALUE,  0x00000000

.equ MARKER_ADDR,   0x80000100
.equ MARKER_VALUE,  0xBEADFACE

.section .text.init
.global _start
_start:
    li    sp, 0x80000400
    jal   _init_regs
    jal   _init_xip
    li    t0, MARKER_ADDR
    li    t1, MARKER_VALUE
    sw    t1, 0(t0)
1:  j     1b

.balign 4
_init_regs:
    li    x5,  0xA5A5A5A5
    li    x6,  0xA6A6A6A6
    li    x7,  0xA7A7A7A7
    li    x8,  0xA8A8A8A8
    li    x9,  0xA9A9A9A9
    li    x18, 0xB8B8B8B8
    li    x19, 0xB9B9B9B9
    li    x20, 0xC0C0C0C0
    ret

.balign 4
_init_xip:
    li    t0, CFGXIP_BASE
    li    t1, CFGXIP_VALUE
    sw    t1, CFGXIP_OFF_0C(t0)
    sw    zero, CFGXIP_OFF_08(t0)
    ret
