/*
 * SPDX-License-Identifier: Apache-2.0
 *
 * Zephyr SPI driver for the nafarr WishboneSpiController.
 *
 * Register map (from WishboneSpiController.v RTL):
 *   0x000  IP Header     (RO)
 *   0x004  IP Version    (RO)
 *   0x008  Features      (RO)
 *   0x028  Clock Divider (R/W)
 *   0x02C  CS Setup      (R/W)
 *   0x030  CS Hold       (R/W)
 *   0x034  CS Disable    (R/W)
 *   0x038  CS Active Hi  (R/W)
 *   0x03C  CPOL          (R/W)
 *   0x040  CPHA          (R/W)
 *   0x050  CMD/RSP FIFO  (R/W) write=cmd, read=response (bit31=valid)
 *   0x054  FIFO Status   (RO)  [20:16]=cmd_avail, [4:0]=rsp_occupancy
 *   0x058  IRQ Status    (R/W)
 *   0x05C  IRQ Mask      (R/W)
 *
 * Command format (32-bit write to 0x050):
 *   bits[29:28] = mode: 00=DATA, 01=CS, 10=DUMMY
 *   DATA mode:  bit[24]=read_flag, [7:0]=tx_data
 *   CS mode:    bit[24]=enable(1)/disable(0), [3:0]=cs_index
 */

#define DT_DRV_COMPAT aesc_nafarr_spi

#include <zephyr/device.h>
#include <zephyr/drivers/spi.h>
#include <zephyr/sys/util.h>

/* Register offsets */
#define REG_CLK_DIV       0x028
#define REG_CS_SETUP      0x02C
#define REG_CS_HOLD       0x030
#define REG_CS_DISABLE    0x034
#define REG_CS_ACTIVE_HI  0x038
#define REG_CPOL          0x03C
#define REG_CPHA          0x040
#define REG_CMD_RSP       0x050
#define REG_FIFO_STATUS   0x054

/* Command modes */
#define CMD_MODE_DATA     (0x0 << 28)
#define CMD_MODE_CS       (0x1 << 28)
#define CMD_DATA_READ     BIT(24)
#define CMD_CS_ENABLE     BIT(24)

/* FIFO status fields */
#define FIFO_CMD_AVAIL_MASK   (0x1F << 16)
#define FIFO_CMD_AVAIL_SHIFT  16
#define FIFO_RSP_OCC_MASK     0x1F

/* Response valid bit */
#define RSP_VALID         BIT(31)

struct spi_nafarr_config {
	DEVICE_MMIO_ROM;
	uint32_t clock_freq;
};

struct spi_nafarr_data {
	DEVICE_MMIO_RAM;
};

static inline void spi_reg_write(mm_reg_t base, uint32_t offset, uint32_t val)
{
	*(volatile uint32_t *)(base + offset) = val;
}

static inline uint32_t spi_reg_read(mm_reg_t base, uint32_t offset)
{
	return *(volatile uint32_t *)(base + offset);
}

static int spi_nafarr_wait_cmd_space(mm_reg_t base)
{
	int timeout = 10000;

	while (timeout-- > 0) {
		uint32_t status = spi_reg_read(base, REG_FIFO_STATUS);
		uint32_t avail = (status & FIFO_CMD_AVAIL_MASK) >> FIFO_CMD_AVAIL_SHIFT;

		if (avail > 0) {
			return 0;
		}
	}
	return -ETIMEDOUT;
}

static int spi_nafarr_read_rsp(mm_reg_t base, uint8_t *data)
{
	int timeout = 10000;

	while (timeout-- > 0) {
		uint32_t rsp = spi_reg_read(base, REG_CMD_RSP);

		if (rsp & RSP_VALID) {
			*data = (uint8_t)(rsp & 0xFF);
			return 0;
		}
	}
	return -ETIMEDOUT;
}

static int spi_nafarr_configure(mm_reg_t base,
				const struct spi_nafarr_config *cfg,
				const struct spi_config *spi_cfg)
{
	uint32_t freq = spi_cfg->frequency;
	uint32_t divider;

	if (freq == 0) {
		freq = 1000000; /* Default 1 MHz */
	}

	/* SPI_CLK = SYS_CLK / (2 * divider) */
	divider = cfg->clock_freq / (2 * freq);
	if (divider < 1) {
		divider = 1;
	}
	spi_reg_write(base, REG_CLK_DIV, divider);

	/* CS timing defaults */
	spi_reg_write(base, REG_CS_SETUP, 2);
	spi_reg_write(base, REG_CS_HOLD, 2);
	spi_reg_write(base, REG_CS_DISABLE, 2);
	spi_reg_write(base, REG_CS_ACTIVE_HI, 0);

	/* CPOL / CPHA */
	spi_reg_write(base, REG_CPOL,
		      (spi_cfg->operation & SPI_MODE_CPOL) ? 1 : 0);
	spi_reg_write(base, REG_CPHA,
		      (spi_cfg->operation & SPI_MODE_CPHA) ? 1 : 0);

	return 0;
}

static int spi_nafarr_transceive(const struct device *dev,
				 const struct spi_config *spi_cfg,
				 const struct spi_buf_set *tx_bufs,
				 const struct spi_buf_set *rx_bufs)
{
	const struct spi_nafarr_config *cfg = dev->config;
	mm_reg_t base = DEVICE_MMIO_GET(dev);
	uint16_t cs_index = 0;
	int ret;

	/* Configure SPI parameters */
	spi_nafarr_configure(base, cfg, spi_cfg);

	/* Determine CS index */
	if (spi_cfg->cs.gpio.port != NULL) {
		/* GPIO CS managed externally — use index 0 */
		cs_index = 0;
	}

	/* Assert CS */
	ret = spi_nafarr_wait_cmd_space(base);
	if (ret) {
		return ret;
	}
	spi_reg_write(base, REG_CMD_RSP,
		      CMD_MODE_CS | CMD_CS_ENABLE | cs_index);

	/* Transmit phase */
	if (tx_bufs) {
		for (size_t i = 0; i < tx_bufs->count; i++) {
			const uint8_t *buf = tx_bufs->buffers[i].buf;
			size_t len = tx_bufs->buffers[i].len;

			for (size_t j = 0; j < len; j++) {
				ret = spi_nafarr_wait_cmd_space(base);
				if (ret) {
					goto deassert;
				}
				spi_reg_write(base, REG_CMD_RSP,
					      CMD_MODE_DATA | buf[j]);
			}
		}
	}

	/* Receive phase */
	if (rx_bufs) {
		for (size_t i = 0; i < rx_bufs->count; i++) {
			uint8_t *buf = rx_bufs->buffers[i].buf;
			size_t len = rx_bufs->buffers[i].len;

			for (size_t j = 0; j < len; j++) {
				ret = spi_nafarr_wait_cmd_space(base);
				if (ret) {
					goto deassert;
				}
				/* Send read command with dummy TX byte */
				spi_reg_write(base, REG_CMD_RSP,
					      CMD_MODE_DATA | CMD_DATA_READ | 0x00);

				ret = spi_nafarr_read_rsp(base, &buf[j]);
				if (ret) {
					goto deassert;
				}
			}
		}
	}

	ret = 0;

deassert:
	/* Deassert CS */
	spi_nafarr_wait_cmd_space(base);
	spi_reg_write(base, REG_CMD_RSP, CMD_MODE_CS | cs_index);

	return ret;
}

static int spi_nafarr_release(const struct device *dev,
			      const struct spi_config *spi_cfg)
{
	ARG_UNUSED(dev);
	ARG_UNUSED(spi_cfg);
	return 0;
}

static int spi_nafarr_init(const struct device *dev)
{
	DEVICE_MMIO_MAP(dev, K_MEM_CACHE_NONE);
	return 0;
}

static DEVICE_API(spi, spi_nafarr_api) = {
	.transceive = spi_nafarr_transceive,
	.release = spi_nafarr_release,
};

#define SPI_NAFARR_INIT(n)                                             \
	static struct spi_nafarr_data spi_nafarr_data_##n;             \
	static const struct spi_nafarr_config spi_nafarr_config_##n = {\
		DEVICE_MMIO_ROM_INIT(DT_DRV_INST(n)),                 \
		.clock_freq = DT_INST_PROP(n, clock_frequency),        \
	};                                                             \
	DEVICE_DT_INST_DEFINE(n, spi_nafarr_init, NULL,                \
			      &spi_nafarr_data_##n,                    \
			      &spi_nafarr_config_##n,                  \
			      POST_KERNEL, CONFIG_SPI_INIT_PRIORITY,   \
			      &spi_nafarr_api);

DT_INST_FOREACH_STATUS_OKAY(SPI_NAFARR_INIT)
