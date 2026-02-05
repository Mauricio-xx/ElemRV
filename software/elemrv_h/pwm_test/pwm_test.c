/*
 * SPDX-FileCopyrightText: 2025 aesc silicon
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#include "pwm.h"

extern void hang(void);

/* GPIO for pass/fail indication */
#define GPIO_BASE    0xF0000000
#define GPIO_OUT     (GPIO_BASE + 0x10)
#define GPIO_OE      (GPIO_BASE + 0x14)

static void gpio_set(uint32_t val)
{
    REG32(GPIO_OE) = val;
    REG32(GPIO_OUT) = val;
}

/* Result codes written to GPIO for external observation */
#define RESULT_TESTING  0x001
#define RESULT_PASS     0xAA1
#define RESULT_FAIL     0xF00

/* Simple delay loop */
static void delay_ms(uint32_t ms)
{
    volatile uint32_t count;
    for (; ms > 0; ms--) {
        for (count = 5000; count > 0; count--);
    }
}

/* Test read-only identification registers */
static int test_id_registers(struct pwm_driver *pwm)
{
    int errors = 0;

    if (pwm_read_header(pwm) != PWM_EXPECTED_HEADER)
        errors++;

    if (pwm_read_version(pwm) != PWM_EXPECTED_VERSION)
        errors++;

    if (pwm_read_features(pwm) != PWM_EXPECTED_FEATURES)
        errors++;

    return errors;
}

/* Test R/W registers: write a value, read it back */
static int test_rw_registers(struct pwm_driver *pwm)
{
    int errors = 0;

    /* Clock divider: write 99, read back */
    pwm_set_clk_div(pwm, 99);
    if (pwm_read_clk_div(pwm) != 99)
        errors++;

    /* CH0 period: write 1000, read back */
    pwm_ch0_set_period(pwm, 1000);
    if (pwm_ch0_read_period(pwm) != 1000)
        errors++;

    /* CH0 pulse: write 500, read back */
    pwm_ch0_set_pulse(pwm, 500);
    if (pwm_ch0_read_pulse(pwm) != 500)
        errors++;

    /* CH1 period: write 2000, read back */
    pwm_ch1_set_period(pwm, 2000);
    if (pwm_ch1_read_period(pwm) != 2000)
        errors++;

    /* CH1 pulse: write 750, read back */
    pwm_ch1_set_pulse(pwm, 750);
    if (pwm_ch1_read_pulse(pwm) != 750)
        errors++;

    /* CH0 enable, read back control */
    pwm_ch0_enable(pwm);
    if ((pwm_ch0_read_ctrl(pwm) & PWM_CTRL_ENABLE) == 0)
        errors++;

    /* CH0 disable, read back control */
    pwm_ch0_disable(pwm);
    if ((pwm_ch0_read_ctrl(pwm) & PWM_CTRL_ENABLE) != 0)
        errors++;

    return errors;
}

void _kernel(void)
{
    struct pwm_driver pwm;
    int errors = 0;

    gpio_set(RESULT_TESTING);
    pwm_init(&pwm, PWM_BASE);

    errors += test_id_registers(&pwm);
    errors += test_rw_registers(&pwm);

    if (errors == 0) {
        gpio_set(RESULT_PASS);
    } else {
        gpio_set(RESULT_FAIL);
    }

    /* Demo: fade CH0 duty cycle */
    pwm_set_clk_div(&pwm, 49);
    pwm_ch0_set_period(&pwm, 1000);
    pwm_ch0_enable(&pwm);

    while (1) {
        for (uint32_t d = 0; d <= 1000; d += 50) {
            pwm_ch0_set_pulse(&pwm, d);
            delay_ms(50);
        }
        for (uint32_t d = 1000; d > 0; d -= 50) {
            pwm_ch0_set_pulse(&pwm, d);
            delay_ms(50);
        }
    }

    hang();
}
