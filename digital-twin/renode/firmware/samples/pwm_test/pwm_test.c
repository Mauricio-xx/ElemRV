/*
 * SPDX-FileCopyrightText: 2025 aesc silicon
 *
 * SPDX-License-Identifier: Apache-2.0
 */

/*
 * Stage 006: PWM Test
 * Tests PWM register access (2 channels)
 */

#define PWM0_BASE       0xF0003000

/* PWM register offsets */
#define PWM_ENABLE      0x00    /* Enable register */
#define PWM_PERIOD      0x04    /* Period register */
#define PWM_DUTY        0x08    /* Duty cycle register */
#define PWM_CHANNEL0    0x0C    /* Channel 0 control */
#define PWM_CHANNEL1    0x10    /* Channel 1 control */

static volatile unsigned int *pwm_enable = (unsigned int *)(PWM0_BASE + PWM_ENABLE);
static volatile unsigned int *pwm_period = (unsigned int *)(PWM0_BASE + PWM_PERIOD);
static volatile unsigned int *pwm_duty = (unsigned int *)(PWM0_BASE + PWM_DUTY);
static volatile unsigned int *pwm_ch0 = (unsigned int *)(PWM0_BASE + PWM_CHANNEL0);
static volatile unsigned int *pwm_ch1 = (unsigned int *)(PWM0_BASE + PWM_CHANNEL1);

void _start(void)
{
    unsigned int val;
    
    /* Configure PWM */
    *pwm_period = 1000;         /* Set period */
    *pwm_duty = 500;            /* Set 50% duty cycle */
    *pwm_ch0 = 0x01;            /* Enable channel 0 */
    *pwm_ch1 = 0x01;            /* Enable channel 1 */
    *pwm_enable = 0x01;         /* Enable PWM */
    
    /* Read back registers */
    val = *pwm_period;
    val = *pwm_duty;
    val = *pwm_ch0;
    val = *pwm_ch1;
    val = *pwm_enable;
    
    /* Infinite loop */
    while (1) {
        __asm__ volatile("nop");
    }
}
