/*
 * SPDX-License-Identifier: Apache-2.0
 *
 * ElemRV-H I2C Sensor Capture: Reads SI7021 temperature sensor
 * periodically and reports samples via UART.
 *
 * SI7021 temperature formula: T = (175.72 * raw / 65536) - 46.85
 * Integer version: temp_x100 = (17572 * raw / 65536) - 4685
 */

#include <zephyr/kernel.h>
#include <zephyr/drivers/i2c.h>

#define I2C_NODE           DT_NODELABEL(i2c0)
#define SENSOR_ADDR        0x40
#define CMD_MEASURE_TEMP   0xE3
#define NUM_SAMPLES        10
#define SAMPLE_INTERVAL_MS 200

int main(void)
{
	const struct device *i2c_dev = DEVICE_DT_GET(I2C_NODE);
	int success = 0;

	printk("Sensor Capture Test\n");
	printk("Sensor: SI7021 @ I2C 0x%02x\n", SENSOR_ADDR);
	printk("Samples: %d, interval: %d ms\n", NUM_SAMPLES, SAMPLE_INTERVAL_MS);

	if (!device_is_ready(i2c_dev)) {
		printk("ERROR: I2C device not ready\n");
		printk("Sensor Capture Test FAILED\n");
		return -1;
	}

	for (int i = 1; i <= NUM_SAMPLES; i++) {
		uint8_t cmd = CMD_MEASURE_TEMP;
		uint8_t data[2] = {0};

		int ret = i2c_write_read(i2c_dev, SENSOR_ADDR, &cmd, 1, data, 2);

		if (ret == 0) {
			uint16_t raw = (data[0] << 8) | data[1];
			int32_t temp_x100 = ((int32_t)17572 * raw) / 65536 - 4685;
			int32_t abs_frac = (temp_x100 < 0 ? -temp_x100 : temp_x100) % 100;

			printk("Sample %d: raw=0x%04x temp=%d.%02d C\n",
			       i, raw, temp_x100 / 100, abs_frac);
			success++;
		} else {
			printk("Sample %d: ERROR (ret=%d)\n", i, ret);
		}

		k_sleep(K_MSEC(SAMPLE_INTERVAL_MS));
	}

	printk("Capture complete: %d/%d samples OK\n", success, NUM_SAMPLES);

	if (success == NUM_SAMPLES) {
		printk("Sensor Capture Test PASSED\n");
	} else {
		printk("Sensor Capture Test FAILED\n");
	}

	return 0;
}
