/*
 * SPDX-FileCopyrightText: 2025 aesc silicon
 *
 * SPDX-License-Identifier: Apache-2.0
 */

/*
 * Minimal repro for the c.jal MMIO unaligned-fetch bug (Gap 1).
 *
 * Same layout as xip_bootrom_test but with .option norvc removed so
 * the assembler is free to emit c.jal for short-range jal x1 calls.
 * Expected symptom: after c.jal to a 4-byte-aligned _sub target on
 * the BmbSpiXip IO_MEM_EXECUTABLE_IO range, the next fetch lands at
 * _sub+2 with garbled bytes -> "Illegal instruction" abort.
 */

.equ MARKER_ADDR,   0x80000100
.equ MARKER_VALUE,  0xCAFEBEEF

.section .text.init
.global _start
_start:
    li    sp, 0x80000400
    jal   _sub
    li    t0, MARKER_ADDR
    li    t1, MARKER_VALUE
    sw    t1, 0(t0)
1:  j     1b

.balign 4
_sub:
    li    x5,  0xA5A5A5A5
    li    x6,  0xA6A6A6A6
    ret
