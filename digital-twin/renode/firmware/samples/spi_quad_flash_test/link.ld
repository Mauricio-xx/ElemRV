/*
 * SPDX-FileCopyrightText: 2025 aesc silicon
 *
 * SPDX-License-Identifier: Apache-2.0
 */

/* Linker script for ElemRV-N bare-metal SPI Quad Flash test.
 * N platform has 4 KiB of RAM; _start uses .text.init placed first
 * so it lives at ORIGIN(RAM) where Renode sets PC.
 */

MEMORY
{
    RAM (xrw): ORIGIN = 0x80000000, LENGTH = 4k
}

__stack_start = ORIGIN(RAM) + LENGTH(RAM);

ENTRY(_start)

SECTIONS {
    .text : {
        KEEP(*(.text.init))
        *(.text .text.*)
    } > RAM

    .rodata : {
        *(.rodata .rodata.*)
    } > RAM

    .data : {
        *(.data)
    } > RAM

    .bss (NOLOAD) : {
        __bss_start = .;
        *(.bss .bss.*)
        *(COMMON)
        __bss_end = .;
    } > RAM
}
