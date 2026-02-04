/*
 * SPDX-FileCopyrightText: 2025 aesc silicon
 *
 * SPDX-License-Identifier: Apache-2.0
 */

/* Simple linker script for GPIO test - runs from RAM */

MEMORY
{
    RAM (xrw): ORIGIN = 0x80000000, LENGTH = 8k
}

stack_size = 1k;

__stack_start = ORIGIN(RAM) + LENGTH(RAM);

ENTRY(_start)

SECTIONS {
    .text : {
        *(.text .text.*)
    } > RAM

    .rodata : {
        *(.rodata)
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
