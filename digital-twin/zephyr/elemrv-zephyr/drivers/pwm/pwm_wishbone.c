/*
 * SPDX-License-Identifier: Apache-2.0
 *
 * Zephyr PWM driver for the AESC WishbonePwm controller.
 *
 * Register map (from WishbonePwm.v RTL):
 *   0x00  IP Header  (RO)  0x00080002
 *   0x04  IP Version (RO)  0x01000000
 *   0x08  Features   (RO)  0x14141402
 *   0x0C  Status     (RO)
 *   0x10  Clock Div  (R/W) 20-bit
 *   0x14  CH0 Ctrl   (R/W) [0]=enable [1]=invert
 *   0x18  CH0 Period (R/W) 20-bit
 *   0x1C  CH0 Pulse  (R/W) 20-bit
 *   0x20  CH1 Ctrl   (R/W)
 *   0x24  CH1 Period (R/W) 20-bit
 *   0x28  CH1 Pulse  (R/W) 20-bit
 */

#define DT_DRV_COMPAT aesc_wishbone_pwm

#include <zephyr/device.h>
#include <zephyr/drivers/pwm.h>
#include <zephyr/sys/util.h>

/* Register offsets */
#define REG_CLKDIV          0x10
#define REG_CH_CTRL(ch)     (0x14 + (ch) * 0x0C)
#define REG_CH_PERIOD(ch)   (0x18 + (ch) * 0x0C)
#define REG_CH_PULSE(ch)    (0x1C + (ch) * 0x0C)

/* Limits */
#define NUM_CHANNELS        2
#define PERIOD_MAX          0xFFFFF  /* 20-bit */

/* Control register bits */
#define CTRL_ENABLE         BIT(0)
#define CTRL_INVERT         BIT(1)

struct pwm_wishbone_config {
	DEVICE_MMIO_ROM;
	uint32_t clock_freq;
};

struct pwm_wishbone_data {
	DEVICE_MMIO_RAM;
};

static inline void pwm_reg_write(mm_reg_t base, uint32_t offset, uint32_t val)
{
	*(volatile uint32_t *)(base + offset) = val;
}

static int pwm_wishbone_set_cycles(const struct device *dev,
				   uint32_t channel,
				   uint32_t period_cycles,
				   uint32_t pulse_cycles,
				   pwm_flags_t flags)
{
	mm_reg_t base = DEVICE_MMIO_GET(dev);
	uint32_t ctrl;

	if (channel >= NUM_CHANNELS) {
		return -EINVAL;
	}

	/* period == 0 means disable */
	if (period_cycles == 0) {
		pwm_reg_write(base, REG_CH_CTRL(channel), 0);
		return 0;
	}

	if (period_cycles > PERIOD_MAX || pulse_cycles > PERIOD_MAX) {
		return -EINVAL;
	}

	if (pulse_cycles > period_cycles) {
		return -EINVAL;
	}

	pwm_reg_write(base, REG_CH_PERIOD(channel), period_cycles);
	pwm_reg_write(base, REG_CH_PULSE(channel), pulse_cycles);

	ctrl = CTRL_ENABLE;
	if (flags & PWM_POLARITY_INVERTED) {
		ctrl |= CTRL_INVERT;
	}
	pwm_reg_write(base, REG_CH_CTRL(channel), ctrl);

	return 0;
}

static int pwm_wishbone_get_cycles_per_sec(const struct device *dev,
					   uint32_t channel,
					   uint64_t *cycles)
{
	const struct pwm_wishbone_config *config = dev->config;

	if (channel >= NUM_CHANNELS) {
		return -EINVAL;
	}

	*cycles = (uint64_t)config->clock_freq;
	return 0;
}

static int pwm_wishbone_init(const struct device *dev)
{
	DEVICE_MMIO_MAP(dev, K_MEM_CACHE_NONE);
	return 0;
}

static DEVICE_API(pwm, pwm_wishbone_api) = {
	.set_cycles = pwm_wishbone_set_cycles,
	.get_cycles_per_sec = pwm_wishbone_get_cycles_per_sec,
};

#define PWM_WISHBONE_INIT(n)                                            \
	static struct pwm_wishbone_data pwm_wishbone_data_##n;          \
	static const struct pwm_wishbone_config pwm_wishbone_config_##n = { \
		DEVICE_MMIO_ROM_INIT(DT_DRV_INST(n)),                  \
		.clock_freq = DT_INST_PROP(n, clock_frequency),         \
	};                                                              \
	DEVICE_DT_INST_DEFINE(n, pwm_wishbone_init, NULL,               \
			      &pwm_wishbone_data_##n,                   \
			      &pwm_wishbone_config_##n,                 \
			      POST_KERNEL, CONFIG_PWM_INIT_PRIORITY,    \
			      &pwm_wishbone_api);

DT_INST_FOREACH_STATUS_OKAY(PWM_WISHBONE_INIT)
