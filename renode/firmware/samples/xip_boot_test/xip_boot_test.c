/*
 * SPDX-FileCopyrightText: 2025 aesc silicon
 *
 * SPDX-License-Identifier: Apache-2.0
 */

/*
 * XIP boot test firmware for G.2.
 * Runs from the BmbSpiXipController DT's data bank (0xF000B000).
 * Each instruction fetch is served by a BMB read into the co-sim
 * flash slave, exercising the full image-container boot path.
 */

#include <stdint.h>

#define UART_RXTX   (*(volatile uint32_t *)0xF0006000)
#define UART_TXFULL (*(volatile uint32_t *)0xF0006004)

static void uart_putc(char c)
{
    while (UART_TXFULL & 1) {
    }
    UART_RXTX = (uint32_t)(unsigned char)c;
}

static void uart_print(const char *s)
{
    while (*s) {
        uart_putc(*s++);
    }
}

int main(void)
{
    uart_print("XIP BOOT OK\n");
    for (;;) {
        __asm__ volatile("nop");
    }
    return 0;
}

__attribute__((naked, section(".text.init")))
void _start(void)
{
    /* Stack at top of the small stack we carved out of RAM (0x80000000).
     * Renode pre-populates RAM with zeros, so a 1 KB stack is fine.
     */
    __asm__ volatile(
        "li sp, 0x80000400\n"
        "call main\n"
        "1: j 1b\n"
    );
}
