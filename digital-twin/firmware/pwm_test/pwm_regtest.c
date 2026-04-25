/*
 * SPDX-FileCopyrightText: 2025 aesc silicon
 *
 * SPDX-License-Identifier: Apache-2.0
 */

/*
 * PWM Register Test - validates register read/write against RTL.
 * Uses correct register map from WishbonePwm.v.
 */

#include "pwm.h"

extern void hang(void);

void _kernel(void)
{
    struct pwm_driver pwm;

    pwm_init(&pwm, PWM_BASE);

    /* Test 1: Read IP Header */
    volatile uint32_t header = pwm_read_header(&pwm);

    /* Test 2: Read IP Version */
    volatile uint32_t version = pwm_read_version(&pwm);

    /* Test 3: Read Feature Register */
    volatile uint32_t features = pwm_read_features(&pwm);

    /* Test 4: Write/read Clock Divider */
    pwm_set_clk_div(&pwm, 0x00063);
    volatile uint32_t clk_div = pwm_read_clk_div(&pwm);

    /* Test 5: Write/read CH0 Period */
    pwm_ch0_set_period(&pwm, 0x003E8);
    volatile uint32_t ch0_period = pwm_ch0_read_period(&pwm);

    /* Test 6: Write/read CH0 Pulse */
    pwm_ch0_set_pulse(&pwm, 0x001F4);
    volatile uint32_t ch0_pulse = pwm_ch0_read_pulse(&pwm);

    /* Test 7: Write/read CH1 Period */
    pwm_ch1_set_period(&pwm, 0x007D0);
    volatile uint32_t ch1_period = pwm_ch1_read_period(&pwm);

    /* Test 8: Write/read CH1 Pulse */
    pwm_ch1_set_pulse(&pwm, 0x002EE);
    volatile uint32_t ch1_pulse = pwm_ch1_read_pulse(&pwm);

    /* Test 9: Enable CH0, read back control */
    pwm_ch0_enable(&pwm);
    volatile uint32_t ch0_ctrl = pwm_ch0_read_ctrl(&pwm);

    /* Infinite loop to keep CPU running */
    while (1) {
        header    = pwm_read_header(&pwm);
        features  = pwm_read_features(&pwm);
        clk_div   = pwm_read_clk_div(&pwm);
        ch0_period = pwm_ch0_read_period(&pwm);
        ch0_pulse  = pwm_ch0_read_pulse(&pwm);
    }

    hang();
}
