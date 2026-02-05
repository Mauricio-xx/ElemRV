/*
 * SPDX-FileCopyrightText: 2025 aesc silicon
 *
 * SPDX-License-Identifier: Apache-2.0
 */

/* Minimal startup for digital twin testing */
/* Just sets up stack and jumps to kernel */

.equ REGBYTES, 0x4

.section .text
.global _head
_head:
	/* Set up stack pointer */
	la	sp, __stack_start
	
	/* Jump to kernel */
	j	_kernel

/* Infinite loop in case kernel returns */
hang:
	nop
	beqz	zero, hang
