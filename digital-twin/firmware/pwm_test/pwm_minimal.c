/*
 * SPDX-FileCopyrightText: 2025 aesc silicon
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#include "pwm.h"

/*
 * Minimal PWM register test for digital twin validation.
 * Exercises all R/W registers with the correct RTL register map.
 */

void _kernel(void)
{
    struct pwm_driver pwm;

    pwm_init(&pwm, PWM_BASE);

    /* Read identification registers (RO) */
    volatile uint32_t header   = pwm_read_header(&pwm);
    volatile uint32_t version  = pwm_read_version(&pwm);
    volatile uint32_t features = pwm_read_features(&pwm);

    /* Configure clock divider */
    pwm_set_clk_div(&pwm, 99);

    /* Configure channel 0 */
    pwm_ch0_set_period(&pwm, 1000);
    pwm_ch0_set_pulse(&pwm, 500);
    pwm_ch0_enable(&pwm);

    /* Configure channel 1 */
    pwm_ch1_set_period(&pwm, 2000);
    pwm_ch1_set_pulse(&pwm, 750);
    pwm_ch1_enable(&pwm);

    /* Infinite loop toggling CH0 pulse */
    while (1) {
        pwm_ch0_set_pulse(&pwm, 250);
        pwm_ch0_set_pulse(&pwm, 750);
    }
}
