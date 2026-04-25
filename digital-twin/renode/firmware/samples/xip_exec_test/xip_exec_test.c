/*
 * SPDX-FileCopyrightText: 2025 aesc silicon
 *
 * SPDX-License-Identifier: Apache-2.0
 */

/*
 * Minimal XIP exec test: proves the CPU fetched and executed instructions
 * from the BmbSpiXipController data bank without relying on UART (which
 * would add ~6 instructions-per-wall-second worth of wait loops).
 *
 * Writes a magic word to 0x80000100 and spins. A Renode test reads the
 * word after a few seconds of virtual time and compares against the
 * expected value.
 */

#include <stdint.h>

#define MARKER_ADDR  0x80000100u
#define MARKER_VALUE 0xCAFEBEEFu

__attribute__((naked, section(".text.init")))
void _start(void)
{
    __asm__ volatile(
        "li   sp, 0x80000400\n"
        "li   t0, 0x80000100\n"
        "li   t1, 0xCAFEBEEF\n"
        "sw   t1, 0(t0)\n"
        "1: j 1b\n"
    );
}
