/*
 * SPDX-License-Identifier: Apache-2.0
 *
 * Zephyr driver for the AESC WishbonePinmux pin multiplexer.
 *
 * Register map (from PinmuxCtrl.scala RTL):
 *   One register per pin, at offset (pin * 4).
 *   Each register holds log2(options) bits selecting the mux option.
 *   For ElemRV-H: 12 pins, 2 options → 1 bit per register.
 *   Default on reset: 0 (option 0 selected).
 */

#define DT_DRV_COMPAT aesc_wishbone_pinmux

#include <zephyr/device.h>
#include <zephyr/sys/util.h>
#include <errno.h>
#include <elemrv/drivers/pinmux.h>

struct pinmux_wishbone_config {
	DEVICE_MMIO_ROM;
	uint8_t num_pins;
	uint8_t num_options;
};

struct pinmux_wishbone_data {
	DEVICE_MMIO_RAM;
};

static inline void pinmux_reg_write(mm_reg_t base, uint32_t offset, uint32_t val)
{
	*(volatile uint32_t *)(base + offset) = val;
}

static inline uint32_t pinmux_reg_read(mm_reg_t base, uint32_t offset)
{
	return *(volatile uint32_t *)(base + offset);
}

int pinmux_set_option(const struct device *dev, uint8_t pin, uint8_t option)
{
	const struct pinmux_wishbone_config *config = dev->config;
	mm_reg_t base = DEVICE_MMIO_GET(dev);

	if (pin >= config->num_pins) {
		return -EINVAL;
	}
	if (option >= config->num_options) {
		return -EINVAL;
	}

	pinmux_reg_write(base, (uint32_t)pin * 4, (uint32_t)option);
	return 0;
}

int pinmux_get_option(const struct device *dev, uint8_t pin, uint8_t *option)
{
	const struct pinmux_wishbone_config *config = dev->config;
	mm_reg_t base = DEVICE_MMIO_GET(dev);

	if (pin >= config->num_pins) {
		return -EINVAL;
	}

	*option = (uint8_t)(pinmux_reg_read(base, (uint32_t)pin * 4) &
			    (config->num_options - 1));
	return 0;
}

uint8_t pinmux_get_num_pins(const struct device *dev)
{
	const struct pinmux_wishbone_config *config = dev->config;

	return config->num_pins;
}

uint8_t pinmux_get_num_options(const struct device *dev)
{
	const struct pinmux_wishbone_config *config = dev->config;

	return config->num_options;
}

static int pinmux_wishbone_init(const struct device *dev)
{
	DEVICE_MMIO_MAP(dev, K_MEM_CACHE_NONE);
	return 0;
}

#define PINMUX_WISHBONE_INIT(n)                                                \
	static struct pinmux_wishbone_data pinmux_wishbone_data_##n;           \
	static const struct pinmux_wishbone_config pinmux_wishbone_config_##n = { \
		DEVICE_MMIO_ROM_INIT(DT_DRV_INST(n)),                         \
		.num_pins = DT_INST_PROP(n, num_pins),                        \
		.num_options = DT_INST_PROP(n, num_options),                   \
	};                                                                     \
	DEVICE_DT_INST_DEFINE(n, pinmux_wishbone_init, NULL,                   \
			      &pinmux_wishbone_data_##n,                       \
			      &pinmux_wishbone_config_##n,                     \
			      PRE_KERNEL_1, CONFIG_KERNEL_INIT_PRIORITY_DEFAULT, \
			      NULL);

DT_INST_FOREACH_STATUS_OKAY(PINMUX_WISHBONE_INIT)
