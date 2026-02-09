/*
 * SPDX-License-Identifier: Apache-2.0
 *
 * SPI Sensor Capture: Reads temperature and pressure from an embedded
 * SPI sensor slave in the co-simulation wrapper.
 *
 * Protocol: write 1 byte (register address), read 1 byte (value).
 *   Reg 0x00 = Device ID (expect 0xCD)
 *   Reg 0x01 = Temperature (cycling 20..19)
 *   Reg 0x02 = Pressure (cycling 45..43)
 *
 * N-only (ElemRV-H has no SPI controller).
 */

#include <zephyr/kernel.h>
#include <zephyr/drivers/spi.h>

#define SPI_NODE       DT_NODELABEL(spi0)
#define NUM_SAMPLES    10
#define SAMPLE_INTERVAL_MS 100

/* SPI configuration: CPOL=0, CPHA=0, MSB first, 8-bit */
static const struct spi_config spi_cfg = {
	.frequency = 1000000,
	.operation = SPI_WORD_SET(8) | SPI_TRANSFER_MSB,
	.slave = 0,
};

static int spi_read_reg(const struct device *spi_dev, uint8_t reg, uint8_t *val)
{
	uint8_t tx_buf[1] = {reg};
	uint8_t rx_buf[1] = {0};

	struct spi_buf tx = {.buf = tx_buf, .len = 1};
	struct spi_buf_set tx_set = {.buffers = &tx, .count = 1};

	struct spi_buf rx = {.buf = rx_buf, .len = 1};
	struct spi_buf_set rx_set = {.buffers = &rx, .count = 1};

	int ret = spi_transceive(spi_dev, &spi_cfg, &tx_set, &rx_set);

	if (ret == 0) {
		*val = rx_buf[0];
	}
	return ret;
}

int main(void)
{
	const struct device *spi_dev = DEVICE_DT_GET(SPI_NODE);
	int success = 0;

	printk("SPI Sensor Capture\n");
	printk("Bus: SPI0, CS=0\n");
	printk("Samples: %d, interval: %d ms\n", NUM_SAMPLES, SAMPLE_INTERVAL_MS);

	if (!device_is_ready(spi_dev)) {
		printk("ERROR: SPI device not ready\n");
		printk("SPI Sensor Capture FAILED\n");
		return -1;
	}

	printk("SPI device ready\n");

	/* Read Device ID */
	uint8_t dev_id = 0;
	int ret = spi_read_reg(spi_dev, 0x00, &dev_id);

	if (ret != 0) {
		printk("ERROR: DevID read failed (ret=%d)\n", ret);
		printk("SPI Sensor Capture FAILED\n");
		return -1;
	}

	printk("DevID: 0x%02X (expect 0xCD)\n", dev_id);
	if (dev_id != 0xCD) {
		printk("WARNING: unexpected DevID\n");
	}

	/* Read sensor samples */
	for (int i = 1; i <= NUM_SAMPLES; i++) {
		uint8_t temp = 0, pressure = 0;

		ret = spi_read_reg(spi_dev, 0x01, &temp);
		if (ret != 0) {
			printk("Sample %d: temp ERROR (ret=%d)\n", i, ret);
			continue;
		}

		ret = spi_read_reg(spi_dev, 0x02, &pressure);
		if (ret != 0) {
			printk("Sample %d: pressure ERROR (ret=%d)\n", i, ret);
			continue;
		}

		printk("Sample %d: temp=%d pressure=%d\n", i, temp, pressure);
		success++;

		k_sleep(K_MSEC(SAMPLE_INTERVAL_MS));
	}

	printk("Capture complete: %d/%d samples OK\n", success, NUM_SAMPLES);

	if (success == NUM_SAMPLES) {
		printk("SPI Sensor Capture PASSED\n");
	} else {
		printk("SPI Sensor Capture FAILED\n");
	}

	return 0;
}
