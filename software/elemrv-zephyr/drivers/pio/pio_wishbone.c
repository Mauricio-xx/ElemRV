/*
 * SPDX-License-Identifier: Apache-2.0
 *
 * Zephyr driver for the AESC WishbonePio programmable I/O controller.
 *
 * Register map (from PioCtrl.scala RTL):
 *   0x00  IP Header     (RO)  0x00080001
 *   0x04  IP Version    (RO)  0x01000000
 *   0x08  Config Info   (RO)  readBufDepth[31:24] | clkDivW[23:16] | dataW[15:8] | ioW[7:0]
 *   0x0C  FIFO Config   (RO)  readFifoDepth[15:8] | cmdFifoDepth[7:0]
 *   0x10  Permissions   (RO)  bit[0] = busCanWriteClkDiv
 *   0x14  Cmd/Result    (W: commandFifo, R: valid[16] | result[0])
 *   0x18  FIFO Status   (RO)  occupancy[31:24] | vacancy[23:16]
 *   0x1C  Clock Divider (RW)  20-bit
 *   0x20  Read Delay    (RW)  8-bit
 *
 * Command encoding (3 pins → 2-bit pin field):
 *   [1:0]  = command type (HIGH=0, LOW=1, WAIT=2, READ=3)
 *   [3:2]  = pin number
 *   [27:4] = data (24-bit)
 */

#define DT_DRV_COMPAT aesc_wishbone_pio

#include <zephyr/device.h>
#include <zephyr/sys/util.h>
#include <errno.h>
#include <elemrv/drivers/pio.h>

/* Register offsets */
#define REG_CMD_RESULT      0x14
#define REG_FIFO_STATUS     0x18
#define REG_CLOCK_DIVIDER   0x1C
#define REG_READ_DELAY      0x20

/* Limits */
#define CLOCK_DIV_MAX       0xFFFFF  /* 20-bit */
#define DATA_MAX            0xFFFFFF /* 24-bit */

/* Result register bits */
#define RESULT_VALID_BIT    BIT(16)
#define RESULT_VALUE_MASK   0x1

/* FIFO status field positions */
#define FIFO_VACANCY_SHIFT  16
#define FIFO_VACANCY_MASK   0xFF
#define FIFO_OCCUPANCY_SHIFT 24
#define FIFO_OCCUPANCY_MASK  0xFF

struct pio_wishbone_config {
	DEVICE_MMIO_ROM;
	uint8_t num_pins;
};

struct pio_wishbone_data {
	DEVICE_MMIO_RAM;
};

static inline void pio_reg_write(mm_reg_t base, uint32_t offset, uint32_t val)
{
	*(volatile uint32_t *)(base + offset) = val;
}

static inline uint32_t pio_reg_read(mm_reg_t base, uint32_t offset)
{
	return *(volatile uint32_t *)(base + offset);
}

static uint32_t pio_encode_cmd(uint8_t num_pins, enum pio_cmd_type cmd,
			       uint8_t pin, uint32_t data)
{
	unsigned int pin_bits = LOG2CEIL(num_pins);
	uint32_t word = 0;

	word |= (uint32_t)cmd & 0x3;
	word |= ((uint32_t)pin & ((1u << pin_bits) - 1)) << 2;
	word |= (data & DATA_MAX) << (2 + pin_bits);

	return word;
}

int pio_send_cmd(const struct device *dev, enum pio_cmd_type cmd,
		 uint8_t pin, uint32_t data)
{
	const struct pio_wishbone_config *config = dev->config;
	mm_reg_t base = DEVICE_MMIO_GET(dev);

	if (cmd > PIO_CMD_READ) {
		return -EINVAL;
	}
	if (pin >= config->num_pins) {
		return -EINVAL;
	}
	if (data > DATA_MAX) {
		return -EINVAL;
	}

	uint32_t word = pio_encode_cmd(config->num_pins, cmd, pin, data);

	pio_reg_write(base, REG_CMD_RESULT, word);
	return 0;
}

int pio_read_result(const struct device *dev, struct pio_read_result *result)
{
	mm_reg_t base = DEVICE_MMIO_GET(dev);
	uint32_t val = pio_reg_read(base, REG_CMD_RESULT);

	result->valid = (val & RESULT_VALID_BIT) != 0;
	result->value = val & RESULT_VALUE_MASK;
	return 0;
}

int pio_get_fifo_status(const struct device *dev, struct pio_fifo_status *status)
{
	mm_reg_t base = DEVICE_MMIO_GET(dev);
	uint32_t val = pio_reg_read(base, REG_FIFO_STATUS);

	status->cmd_vacancy = (val >> FIFO_VACANCY_SHIFT) & FIFO_VACANCY_MASK;
	status->read_occupancy = (val >> FIFO_OCCUPANCY_SHIFT) & FIFO_OCCUPANCY_MASK;
	return 0;
}

int pio_set_clock_divider(const struct device *dev, uint32_t divider)
{
	mm_reg_t base = DEVICE_MMIO_GET(dev);

	if (divider > CLOCK_DIV_MAX) {
		return -EINVAL;
	}

	pio_reg_write(base, REG_CLOCK_DIVIDER, divider);
	return 0;
}

int pio_set_read_delay(const struct device *dev, uint8_t delay)
{
	mm_reg_t base = DEVICE_MMIO_GET(dev);

	pio_reg_write(base, REG_READ_DELAY, (uint32_t)delay);
	return 0;
}

static int pio_wishbone_init(const struct device *dev)
{
	DEVICE_MMIO_MAP(dev, K_MEM_CACHE_NONE);
	return 0;
}

#define PIO_WISHBONE_INIT(n)                                                \
	static struct pio_wishbone_data pio_wishbone_data_##n;              \
	static const struct pio_wishbone_config pio_wishbone_config_##n = { \
		DEVICE_MMIO_ROM_INIT(DT_DRV_INST(n)),                      \
		.num_pins = DT_INST_PROP(n, num_pins),                     \
	};                                                                  \
	DEVICE_DT_INST_DEFINE(n, pio_wishbone_init, NULL,                   \
			      &pio_wishbone_data_##n,                       \
			      &pio_wishbone_config_##n,                     \
			      POST_KERNEL, CONFIG_KERNEL_INIT_PRIORITY_DEVICE, \
			      NULL);

DT_INST_FOREACH_STATUS_OKAY(PIO_WISHBONE_INIT)
