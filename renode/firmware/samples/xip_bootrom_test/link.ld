/*
 * SPDX-FileCopyrightText: 2025 aesc silicon
 *
 * SPDX-License-Identifier: Apache-2.0
 */

MEMORY
{
    FLASH (rx): ORIGIN = 0xF000B000, LENGTH = 4k
    RAM   (rw): ORIGIN = 0x80000000, LENGTH = 4k
}

ENTRY(_start)

SECTIONS {
    .text : {
        KEEP(*(.text.init))
        *(.text .text.*)
        *(.rodata .rodata.*)
    } > FLASH

    .data : { *(.data) } > RAM
    .bss (NOLOAD) : { *(.bss .bss.*) *(COMMON) } > RAM
}
