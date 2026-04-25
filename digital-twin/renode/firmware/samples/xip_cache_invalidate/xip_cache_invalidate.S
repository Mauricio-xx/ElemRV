/*
 * SPDX-FileCopyrightText: 2025 aesc silicon
 *
 * SPDX-License-Identifier: Apache-2.0
 */

/*
 * Gap 3.2 #1 — XIP fetch-cache invalidation coverage test.
 *
 * Runs from RAM (not XIP) so that a miscalibrated XIP protocol after
 * the cfgXip write does not crash instruction fetch. Reads the same
 * XIP word three times with a bank-1 write sandwiched between read 2
 * and read 3. Read 3 must differ from reads 1/2 when the wrapper's
 * fetch cache is correctly invalidated on bank-1 writes (BMBXIP_FAST
 * enabled), because the cfgXip write flips dummyCycles 0 -> 15
 * (half-cycles; dataCounter is 4-bit so 15 is the max usable) and
 * the slave's output bit stream shifts by 7 bits relative to the
 * controller's DATA phase.
 *
 * With mutation M8 (invalidateFetchCache() call removed), read 3
 * hits the cached mode-0 value from read 1 and the test FAILs.
 *
 * Marker layout at 0x80000100:
 *   +0x00  verdict (0xCA5E0001 PASS / 0xCA5EFAE1 FAIL)
 *   +0x04  s0 (read 1)
 *   +0x08  s1 (read 2)
 *   +0x0C  s2 (read 3)
 */

.equ XIP_BASE,    0xF000B000
.equ CFGXIP_BASE, 0xF000A000
.equ CFGXIP_REG,  0x0C
.equ CFGXIP_TRIG, 0x08
.equ CFG_VALUE,   0x00000F00

.equ MARKER_ADDR, 0x80000100
.equ MARKER_PASS, 0xCA5E0001
.equ MARKER_FAIL, 0xCA5EFAE1

.section .text.init
.global _start
_start:
    li    sp, 0x80000F00

    # Read 1: populate fetch cache (word_idx 0 of bank 2)
    li    t0, XIP_BASE
    lw    s0, 0(t0)

    # Read 2: cache hit
    lw    s1, 0(t0)

    # Bank-1 write (cfgXip data register) — invalidates cache.
    # Value: mode=0, dummyCycles=16 (half-cycles), evcr=0.
    li    t1, CFGXIP_BASE
    li    t2, CFG_VALUE
    sw    t2, CFGXIP_REG(t1)

    # Trigger configure pulse so the controller latches mode/dummyCycles.
    # Also a bank-1 write (invalidates again, no-op if already invalid).
    sw    zero, CFGXIP_TRIG(t1)

    # Read 3: must refetch through RTL. With dummyCycles=15 on cmd 0x03,
    # the slave's bit stream offsets by 7 bits during the controller's
    # DUMMYCYCLES phase.
    lw    s2, 0(t0)

    # Diagnostic: read back cfgXip reg to confirm write landed.
    lw    s3, CFGXIP_REG(t1)

    # Verdict
    li    t3, MARKER_FAIL
    beq   s0, s2, _store
    li    t3, MARKER_PASS

_store:
    li    t0, MARKER_ADDR
    sw    t3, 0(t0)
    sw    s0, 4(t0)
    sw    s1, 8(t0)
    sw    s2, 12(t0)
    sw    s3, 16(t0)

1:  j     1b
