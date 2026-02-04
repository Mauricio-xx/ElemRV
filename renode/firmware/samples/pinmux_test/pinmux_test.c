/*
 * SPDX-FileCopyrightText: 2025 aesc silicon
 *
 * SPDX-License-Identifier: Apache-2.0
 */

/*
 * Stage 008: Pinmux Test
 * Tests Pinmux register access (12 pins, 24 options)
 */

#define PINMUX_BASE     0xF0010000

/* Pinmux register offsets */
#define PINMUX_CTRL     0x00    /* Control register */
#define PINMUX_SEL0     0x04    /* Pin 0 selection */
#define PINMUX_SEL1     0x08    /* Pin 1 selection */
#define PINMUX_SEL2     0x0C    /* Pin 2 selection */
#define PINMUX_SEL3     0x10    /* Pin 3 selection */

static volatile unsigned int *pinmux_ctrl = (unsigned int *)(PINMUX_BASE + PINMUX_CTRL);
static volatile unsigned int *pinmux_sel0 = (unsigned int *)(PINMUX_BASE + PINMUX_SEL0);
static volatile unsigned int *pinmux_sel1 = (unsigned int *)(PINMUX_BASE + PINMUX_SEL1);
static volatile unsigned int *pinmux_sel2 = (unsigned int *)(PINMUX_BASE + PINMUX_SEL2);
static volatile unsigned int *pinmux_sel3 = (unsigned int *)(PINMUX_BASE + PINMUX_SEL3);

void _start(void)
{
    unsigned int val;
    
    /* Configure Pinmux */
    *pinmux_sel0 = 0x00;        /* Pin 0: Select option 0 (GPIO) */
    *pinmux_sel1 = 0x01;        /* Pin 1: Select option 1 (PIO) */
    *pinmux_sel2 = 0x00;        /* Pin 2: Select option 0 (GPIO) */
    *pinmux_sel3 = 0x01;        /* Pin 3: Select option 1 (PIO) */
    *pinmux_ctrl = 0x01;        /* Enable pinmux */
    
    /* Read back registers */
    val = *pinmux_sel0;
    val = *pinmux_sel1;
    val = *pinmux_sel2;
    val = *pinmux_sel3;
    val = *pinmux_ctrl;
    
    /* Infinite loop */
    while (1) {
        __asm__ volatile("nop");
    }
}
