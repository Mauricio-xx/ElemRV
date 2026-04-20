/*
 * SPDX-FileCopyrightText: 2025 aesc silicon
 *
 * SPDX-License-Identifier: Apache-2.0
 */

MEMORY
{
    RAM (rwx): ORIGIN = 0x80000000, LENGTH = 4k
}

ENTRY(_start)

SECTIONS {
    .text : {
        KEEP(*(.text.init))
        *(.text .text.*)
        *(.rodata .rodata.*)
    } > RAM

    .data : { *(.data) } > RAM
    .bss (NOLOAD) : { *(.bss .bss.*) *(COMMON) } > RAM
}
