/*
 * SPDX-FileCopyrightText: 2025 aesc silicon
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#ifndef PWM_H
#define PWM_H

#include <stdint.h>

/*
 * PWM register map - matches WishbonePwm RTL (gen/WishbonePwm.v)
 *
 * Base address: 0xF0003000
 *
 * Offset  Name              Access  Width   Description
 * ------  ----------------  ------  -----   -----------
 * 0x000   IP_HEADER         RO      32      IP identification header
 * 0x004   IP_VERSION         RO      32      IP version
 * 0x008   IP_FEATURES        RO      32      Feature register (0x14141402)
 * 0x00C   IP_STATUS          RO      32      Status register
 * 0x010   CLOCK_DIVIDER      R/W     20      Clock divider value
 * 0x014   CH0_CTRL           R/W     2       CH0 control [0]=enable [1]=invert
 * 0x018   CH0_PERIOD         R/W     20      CH0 period counter
 * 0x01C   CH0_PULSE          R/W     20      CH0 pulse/duty width
 * 0x020   CH1_CTRL           R/W     2       CH1 control [0]=enable [1]=invert
 * 0x024   CH1_PERIOD         R/W     20      CH1 period counter
 * 0x028   CH1_PULSE          R/W     20      CH1 pulse/duty width
 */

#define PWM_BASE                0xF0003000

/* Register offsets */
#define PWM_IP_HEADER_OFFSET    0x000
#define PWM_IP_VERSION_OFFSET   0x004
#define PWM_IP_FEATURES_OFFSET  0x008
#define PWM_IP_STATUS_OFFSET    0x00C
#define PWM_CLK_DIV_OFFSET      0x010
#define PWM_CH0_CTRL_OFFSET     0x014
#define PWM_CH0_PERIOD_OFFSET   0x018
#define PWM_CH0_PULSE_OFFSET    0x01C
#define PWM_CH1_CTRL_OFFSET     0x020
#define PWM_CH1_PERIOD_OFFSET   0x024
#define PWM_CH1_PULSE_OFFSET    0x028

/* Expected read-only register values (from RTL) */
#define PWM_EXPECTED_HEADER     0x00080002  /* {0x00, 0x08, Ids_Pwm=2} */
#define PWM_EXPECTED_VERSION    0x01000000  /* {0x01, 0x00, 0x0000} */
#define PWM_EXPECTED_FEATURES   0x14141402  /* {0x14, 0x14, 0x14, 0x02} */

/* Channel control bits */
#define PWM_CTRL_ENABLE         (1 << 0)
#define PWM_CTRL_INVERT         (1 << 1)

/* Register width masks */
#define PWM_20BIT_MASK          0x000FFFFF

/* Helper macro for register access */
#define REG32(addr) (*(volatile uint32_t *)(addr))

/* PWM driver structure */
struct pwm_driver {
    uint32_t base;
};

static inline void pwm_init(struct pwm_driver *pwm, uint32_t base)
{
    pwm->base = base;
}

/* Read-only registers */
static inline uint32_t pwm_read_header(struct pwm_driver *pwm)
{
    return REG32(pwm->base + PWM_IP_HEADER_OFFSET);
}

static inline uint32_t pwm_read_version(struct pwm_driver *pwm)
{
    return REG32(pwm->base + PWM_IP_VERSION_OFFSET);
}

static inline uint32_t pwm_read_features(struct pwm_driver *pwm)
{
    return REG32(pwm->base + PWM_IP_FEATURES_OFFSET);
}

static inline uint32_t pwm_read_status(struct pwm_driver *pwm)
{
    return REG32(pwm->base + PWM_IP_STATUS_OFFSET);
}

/* Clock divider (20-bit) */
static inline void pwm_set_clk_div(struct pwm_driver *pwm, uint32_t div)
{
    REG32(pwm->base + PWM_CLK_DIV_OFFSET) = div & PWM_20BIT_MASK;
}

static inline uint32_t pwm_read_clk_div(struct pwm_driver *pwm)
{
    return REG32(pwm->base + PWM_CLK_DIV_OFFSET) & PWM_20BIT_MASK;
}

/* Channel 0 */
static inline void pwm_ch0_enable(struct pwm_driver *pwm)
{
    REG32(pwm->base + PWM_CH0_CTRL_OFFSET) = PWM_CTRL_ENABLE;
}

static inline void pwm_ch0_disable(struct pwm_driver *pwm)
{
    REG32(pwm->base + PWM_CH0_CTRL_OFFSET) = 0;
}

static inline uint32_t pwm_ch0_read_ctrl(struct pwm_driver *pwm)
{
    return REG32(pwm->base + PWM_CH0_CTRL_OFFSET);
}

static inline void pwm_ch0_set_period(struct pwm_driver *pwm, uint32_t period)
{
    REG32(pwm->base + PWM_CH0_PERIOD_OFFSET) = period & PWM_20BIT_MASK;
}

static inline uint32_t pwm_ch0_read_period(struct pwm_driver *pwm)
{
    return REG32(pwm->base + PWM_CH0_PERIOD_OFFSET) & PWM_20BIT_MASK;
}

static inline void pwm_ch0_set_pulse(struct pwm_driver *pwm, uint32_t pulse)
{
    REG32(pwm->base + PWM_CH0_PULSE_OFFSET) = pulse & PWM_20BIT_MASK;
}

static inline uint32_t pwm_ch0_read_pulse(struct pwm_driver *pwm)
{
    return REG32(pwm->base + PWM_CH0_PULSE_OFFSET) & PWM_20BIT_MASK;
}

/* Channel 1 */
static inline void pwm_ch1_enable(struct pwm_driver *pwm)
{
    REG32(pwm->base + PWM_CH1_CTRL_OFFSET) = PWM_CTRL_ENABLE;
}

static inline void pwm_ch1_disable(struct pwm_driver *pwm)
{
    REG32(pwm->base + PWM_CH1_CTRL_OFFSET) = 0;
}

static inline uint32_t pwm_ch1_read_ctrl(struct pwm_driver *pwm)
{
    return REG32(pwm->base + PWM_CH1_CTRL_OFFSET);
}

static inline void pwm_ch1_set_period(struct pwm_driver *pwm, uint32_t period)
{
    REG32(pwm->base + PWM_CH1_PERIOD_OFFSET) = period & PWM_20BIT_MASK;
}

static inline uint32_t pwm_ch1_read_period(struct pwm_driver *pwm)
{
    return REG32(pwm->base + PWM_CH1_PERIOD_OFFSET) & PWM_20BIT_MASK;
}

static inline void pwm_ch1_set_pulse(struct pwm_driver *pwm, uint32_t pulse)
{
    REG32(pwm->base + PWM_CH1_PULSE_OFFSET) = pulse & PWM_20BIT_MASK;
}

static inline uint32_t pwm_ch1_read_pulse(struct pwm_driver *pwm)
{
    return REG32(pwm->base + PWM_CH1_PULSE_OFFSET) & PWM_20BIT_MASK;
}

#endif /* PWM_H */
