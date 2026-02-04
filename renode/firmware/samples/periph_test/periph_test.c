/*
 * SPDX-FileCopyrightText: 2025 aesc silicon
 *
 * SPDX-License-Identifier: Apache-2.0
 */

/*
 * Phase 2 Test: PWM/PIO/Pinmux Register Access
 * 
 * Tests register read/write for peripherals that are tagged
 * but not fully implemented in Renode.
 */

#define PWM0_BASE   0xF0003000
#define PIO0_BASE   0xF0002000
#define PINMUX_BASE 0xF0010000

static volatile unsigned int *pwm_reg = (unsigned int *)PWM0_BASE;
static volatile unsigned int *pio_reg = (unsigned int *)PIO0_BASE;
static volatile unsigned int *pinmux_reg = (unsigned int *)PINMUX_BASE;

void _start(void)
{
    unsigned int val;
    
    /* Test PWM register access */
    *pwm_reg = 0x12345678;
    val = *pwm_reg;
    /* In Renode with Tag, write is ignored and read returns 0 */
    
    /* Test PIO register access */
    *pio_reg = 0xDEADBEEF;
    val = *pio_reg;
    
    /* Test Pinmux register access */
    *pinmux_reg = 0xAABBCCDD;
    val = *pinmux_reg;
    
    /* Infinite loop - test complete */
    while (1) {
        __asm__ volatile("nop");
    }
}
