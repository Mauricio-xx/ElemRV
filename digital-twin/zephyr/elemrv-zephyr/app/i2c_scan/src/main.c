/*
 * SPDX-License-Identifier: Apache-2.0
 *
 * ElemRV-H I2C Bus Scan: Validates LiteX I2C driver initialization
 * and bus operations. Scans addresses 0x08–0x77.
 */

#include <zephyr/kernel.h>
#include <zephyr/drivers/i2c.h>

#define I2C_NODE DT_NODELABEL(i2c0)

int main(void)
{
	const struct device *i2c_dev = DEVICE_DT_GET(I2C_NODE);
	uint8_t dummy;
	int found = 0;

	printk("ElemRV-H I2C Bus Scan\n");

	if (!device_is_ready(i2c_dev)) {
		printk("ERROR: I2C device not ready\n");
		return -1;
	}

	printk("I2C device ready, scanning addresses 0x08-0x77...\n");

	for (uint8_t addr = 0x08; addr < 0x78; addr++) {
		struct i2c_msg msg = {
			.buf = &dummy,
			.len = 1,
			.flags = I2C_MSG_READ | I2C_MSG_STOP,
		};

		if (i2c_transfer(i2c_dev, &msg, 1, addr) == 0) {
			printk("  Device found at 0x%02x\n", addr);
			found++;
		}
	}

	printk("Scan complete: %d device(s) found\n", found);
	printk("I2C Bus Scan Test PASSED\n");
	return 0;
}
