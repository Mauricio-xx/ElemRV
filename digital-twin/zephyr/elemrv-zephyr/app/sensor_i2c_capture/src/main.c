/*
 * SPDX-License-Identifier: Apache-2.0
 *
 * Generic I2C Sensor Capture: Reads temperature and humidity from an
 * SI70xx-compatible sensor at I2C address 0x48 on both ElemRV-H and N.
 *
 * Protocol: SI7021 (write command byte, read 2-byte response)
 *   0xE3 = Measure Temperature (Hold Master)
 *   0xE5 = Measure Humidity (Hold Master)
 *
 * Temperature: T = (175.72 * raw / 65536) - 46.85
 * Humidity:    H = (125.0 * raw / 65536) - 6.0
 *
 * Zero #ifdef — identical code runs on H and N.
 */

#include <zephyr/kernel.h>
#include <zephyr/drivers/i2c.h>

#define I2C_NODE           DT_NODELABEL(i2c0)
#define SENSOR_ADDR        0x48
#define CMD_MEASURE_TEMP   0xE3
#define CMD_MEASURE_HUM    0xE5
#define NUM_SAMPLES        10
#define SAMPLE_INTERVAL_MS 100

int main(void)
{
	const struct device *i2c_dev = DEVICE_DT_GET(I2C_NODE);
	int success = 0;

	printk("Generic I2C Sensor Capture\n");
	printk("Sensor: I2C 0x%02x (SI70xx compatible)\n", SENSOR_ADDR);
	printk("Samples: %d, interval: %d ms\n", NUM_SAMPLES, SAMPLE_INTERVAL_MS);

	if (!device_is_ready(i2c_dev)) {
		printk("ERROR: I2C device not ready\n");
		printk("Sensor I2C Capture FAILED\n");
		return -1;
	}

	printk("I2C device ready\n");

	for (int i = 1; i <= NUM_SAMPLES; i++) {
		uint8_t cmd;
		uint8_t data[2] = {0};
		int ret;

		/* Read temperature */
		cmd = CMD_MEASURE_TEMP;
		ret = i2c_write_read(i2c_dev, SENSOR_ADDR, &cmd, 1, data, 2);
		if (ret != 0) {
			printk("Sample %d: temp ERROR (ret=%d)\n", i, ret);
			continue;
		}
		uint16_t raw_temp = (data[0] << 8) | data[1];
		int32_t temp_x100 = ((int32_t)17572 * raw_temp) / 65536 - 4685;

		/* Read humidity */
		cmd = CMD_MEASURE_HUM;
		ret = i2c_write_read(i2c_dev, SENSOR_ADDR, &cmd, 1, data, 2);
		if (ret != 0) {
			printk("Sample %d: hum ERROR (ret=%d)\n", i, ret);
			continue;
		}
		uint16_t raw_hum = (data[0] << 8) | data[1];
		int32_t hum_x100 = ((int32_t)12500 * raw_hum) / 65536 - 600;

		int32_t t_abs = (temp_x100 < 0 ? -temp_x100 : temp_x100);
		int32_t h_abs = (hum_x100 < 0 ? -hum_x100 : hum_x100);

		printk("Sample %d: temp=%d.%02d C hum=%d.%02d %%\n",
		       i,
		       temp_x100 / 100, t_abs % 100,
		       hum_x100 / 100, h_abs % 100);
		success++;

		k_sleep(K_MSEC(SAMPLE_INTERVAL_MS));
	}

	printk("Capture complete: %d/%d samples OK\n", success, NUM_SAMPLES);

	if (success == NUM_SAMPLES) {
		printk("Sensor I2C Capture PASSED\n");
	} else {
		printk("Sensor I2C Capture FAILED\n");
	}

	return 0;
}
