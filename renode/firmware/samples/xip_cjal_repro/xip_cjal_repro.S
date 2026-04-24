/*
 * SPDX-FileCopyrightText: 2025 aesc silicon
 *
 * SPDX-License-Identifier: Apache-2.0
 */

/*
 * Parameterized regression harness for the BmbSpiXip wrapper's sub-word
 * read fix (bmb_spi_xip_wrapper.cpp lines 192-208, Gap 1).
 *
 * Exercises the (addr & 3) shift path across a matrix of fetch
 * alignments and data-load sizes. Each scenario writes a distinct
 * marker word in RAM on success; run_xip_cjal_repro.resc checks every
 * slot and emits PASSED only if all of them match.
 *
 * Marker layout (LE word at each address):
 *
 *   0x80000100 S1 OVERALL  firmware reached end of _start:   0xCAFEBEEF
 *   0x80000104 S2          c.jal to word-aligned sub:        0x5C110002
 *   0x80000108 S3          c.jal to word+2 sub:              0x5C110003
 *   0x8000010C S4          uncompressed jal at word+2 PC:    0x5C110004
 *   0x80000110 S5          mixed C+uncompressed arithmetic:  0x5C110005
 *   0x80000114 S6          lw  from XIP rodata word+0:       0x5C110006
 *   0x80000118 S7          lhu from XIP rodata word+2:       0x5C110007
 *   0x8000011C S8          lbu from XIP rodata word+1:       0x5C110008
 *   0x80000120 S9          lbu from XIP rodata word+3:       0x5C110009
 *
 * _xip_bytes blob: DE AD BE EF CA FE BA BE
 *   lw  at +0 -> 0xEFBEADDE (little-endian word)
 *   lhu at +2 -> 0x0000EFBE
 *   lbu at +1 -> 0x000000AD
 *   lbu at +3 -> 0x000000EF
 */

.equ MARKER_BASE,   0x80000100
.equ OK_OVERALL,    0xCAFEBEEF
.equ OK_S2,         0x5C110002
.equ OK_S3,         0x5C110003
.equ OK_S4,         0x5C110004
.equ OK_S5,         0x5C110005
.equ OK_S6,         0x5C110006
.equ OK_S7,         0x5C110007
.equ OK_S8,         0x5C110008
.equ OK_S9,         0x5C110009

.equ EXPECT_WORD,   0xEFBEADDE
.equ EXPECT_HALF,   0x0000EFBE
.equ EXPECT_BYTE1,  0x000000AD
.equ EXPECT_BYTE3,  0x000000EF

.section .text.init
.global _start
_start:
    li    sp, 0x80000400
    li    s0, MARKER_BASE

    # Zero marker slots so stale bytes from a previous run can't give a
    # false PASS. RAM backing is a fresh ArrayMemory per test, but belt
    # and suspenders: explicit.
    sw    zero, 0(s0)
    sw    zero, 4(s0)
    sw    zero, 8(s0)
    sw    zero, 12(s0)
    sw    zero, 16(s0)
    sw    zero, 20(s0)
    sw    zero, 24(s0)
    sw    zero, 28(s0)
    sw    zero, 32(s0)

    # --- S2: c.jal (or jal) to word-aligned sub, sub writes marker ---
    jal   _s2_sub

    # --- S3: jal to word+2 sub (label offset shifted by 2) ---
    jal   _s3_sub

    # --- S4: uncompressed jal at word+2 PC ---
    # Shim a c.nop before the norvc block so the 4-byte jal lands at
    # word+2. Fetching this jal crosses a word boundary.
.balign 4
.half   0x0001
.option push
.option norvc
    jal   _s4_sub
.option pop

    # --- S5: mixed C+uncompressed arithmetic ---
    jal   _s5_sub

    # --- S6: lw from XIP rodata at word+0 ---
    la    t0, _xip_bytes
    lw    t1, 0(t0)
    li    t2, EXPECT_WORD
    bne   t1, t2, _after_s6
    li    t3, OK_S6
    sw    t3, 20(s0)
_after_s6:

    # --- S7: lhu from XIP rodata at word+2 ---
    la    t0, _xip_bytes
    lhu   t1, 2(t0)
    li    t2, EXPECT_HALF
    bne   t1, t2, _after_s7
    li    t3, OK_S7
    sw    t3, 24(s0)
_after_s7:

    # --- S8: lbu from XIP rodata at word+1 ---
    la    t0, _xip_bytes
    lbu   t1, 1(t0)
    li    t2, EXPECT_BYTE1
    bne   t1, t2, _after_s8
    li    t3, OK_S8
    sw    t3, 28(s0)
_after_s8:

    # --- S9: lbu from XIP rodata at word+3 ---
    la    t0, _xip_bytes
    lbu   t1, 3(t0)
    li    t2, EXPECT_BYTE3
    bne   t1, t2, _after_s9
    li    t3, OK_S9
    sw    t3, 32(s0)
_after_s9:

    # --- S1: end-of-firmware marker ---
    li    t0, OK_OVERALL
    sw    t0, 0(s0)

1:  j     1b


# ----------------------------------------------------------------------
# Subroutines
# ----------------------------------------------------------------------

.balign 4
_s2_sub:
    li    t0, OK_S2
    sw    t0, 4(s0)
    ret

# Shim a c.nop so _s3_sub lands at word+2. The ensuing fetches of this
# subroutine's body all come from byte_off != 0 addresses.
.balign 4
.half   0x0001
_s3_sub:
    li    t0, OK_S3
    sw    t0, 8(s0)
    ret

.balign 4
_s4_sub:
    li    t0, OK_S4
    sw    t0, 12(s0)
    ret

.balign 4
_s5_sub:
    # 1 + 2 + 4 + 8 + 16 = 31
    li    t0, 0
    addi  t0, t0, 1
    addi  t0, t0, 2
    addi  t0, t0, 4
    addi  t0, t0, 8
    addi  t0, t0, 16
    li    t1, 31
    bne   t0, t1, _s5_done
    li    t2, OK_S5
    sw    t2, 16(s0)
_s5_done:
    ret

.balign 4
_xip_bytes:
    .byte 0xDE, 0xAD, 0xBE, 0xEF, 0xCA, 0xFE, 0xBA, 0xBE
