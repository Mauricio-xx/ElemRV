/*
 * SPDX-License-Identifier: Apache-2.0
 *
 * ElemRV-H Pinmux Driver Test: Validates the custom WishbonePinmux driver.
 * Exercises pin option set/get, metadata queries, and error cases.
 *
 * ElemRV-H pin mapping (12 pins, 2 options each):
 *   Pin 0:  gpio0_0  | pwm0_0       Pin 6:  uart0_cts| gpio0_6
 *   Pin 1:  gpio0_1  | pio0_0       Pin 7:  uart0_rts| gpio0_7
 *   Pin 2:  gpio0_2  | pio0_1       Pin 8:  gpio0_8  | pwm0_1
 *   Pin 3:  gpio0_3  | pio0_2       Pin 9:  gpio0_9  | i2c0_scl
 *   Pin 4:  uart0_tx | gpio0_4      Pin 10: gpio0_10 | i2c0_sda
 *   Pin 5:  uart0_rx | gpio0_5      Pin 11: gpio0_11 | i2c0_int
 *
 * Note: In Renode, Pinmux is a tagged region — writes are silently absorbed
 * and reads return 0. The test validates API paths and error checking.
 */

#include <zephyr/kernel.h>
#include <elemrv/drivers/pinmux.h>

#define PINMUX_NODE DT_NODELABEL(pinmux)

int main(void)
{
	const struct device *mux_dev = DEVICE_DT_GET(PINMUX_NODE);
	uint8_t option;
	int ret;

	printk("ElemRV-H Pinmux Driver Test\n");

	if (!device_is_ready(mux_dev)) {
		printk("ERROR: Pinmux device not ready\n");
		return -1;
	}

	/* Query metadata */
	uint8_t num_pins = pinmux_get_num_pins(mux_dev);
	uint8_t num_opts = pinmux_get_num_options(mux_dev);
	printk("Pinmux: %u pins, %u options each\n", num_pins, num_opts);

	if (num_pins != 12 || num_opts != 2) {
		printk("ERROR: unexpected config (expected 12 pins, 2 options)\n");
		return -1;
	}
	printk("Config check OK\n");

	/* Set pin 0 to option 1 (pwm0_0 instead of gpio0_0) */
	ret = pinmux_set_option(mux_dev, 0, 1);
	if (ret) {
		printk("ERROR: set pin 0 option 1 failed: %d\n", ret);
		return -1;
	}
	printk("Pin 0 -> option 1 (pwm0_0) OK\n");

	/* Read back pin 0 (in Renode: returns 0 since tag, but API path works) */
	ret = pinmux_get_option(mux_dev, 0, &option);
	if (ret) {
		printk("ERROR: get pin 0 option failed: %d\n", ret);
		return -1;
	}
	printk("Pin 0 readback: option=%u OK\n", option);

	/* Set pin 9 to option 1 (i2c0_scl instead of gpio0_9) */
	ret = pinmux_set_option(mux_dev, 9, 1);
	if (ret) {
		printk("ERROR: set pin 9 option 1 failed: %d\n", ret);
		return -1;
	}
	printk("Pin 9 -> option 1 (i2c0_scl) OK\n");

	/* Set pin 10 to option 1 (i2c0_sda instead of gpio0_10) */
	ret = pinmux_set_option(mux_dev, 10, 1);
	if (ret) {
		printk("ERROR: set pin 10 option 1 failed: %d\n", ret);
		return -1;
	}
	printk("Pin 10 -> option 1 (i2c0_sda) OK\n");

	/* Set pin 4 to option 0 (uart0_tx — default) */
	ret = pinmux_set_option(mux_dev, 4, 0);
	if (ret) {
		printk("ERROR: set pin 4 option 0 failed: %d\n", ret);
		return -1;
	}
	printk("Pin 4 -> option 0 (uart0_tx) OK\n");

	/* Configure all PIO pins (1, 2, 3 -> option 1) */
	for (uint8_t p = 1; p <= 3; p++) {
		ret = pinmux_set_option(mux_dev, p, 1);
		if (ret) {
			printk("ERROR: set pin %u option 1 failed: %d\n", p, ret);
			return -1;
		}
	}
	printk("Pins 1-3 -> option 1 (pio0_0..2) OK\n");

	/* Error case: invalid pin (expect -EINVAL) */
	ret = pinmux_set_option(mux_dev, 12, 0);
	if (ret != -EINVAL) {
		printk("ERROR: invalid pin not rejected (ret=%d)\n", ret);
		return -1;
	}
	printk("Invalid pin rejected OK\n");

	/* Error case: invalid option (expect -EINVAL) */
	ret = pinmux_set_option(mux_dev, 0, 2);
	if (ret != -EINVAL) {
		printk("ERROR: invalid option not rejected (ret=%d)\n", ret);
		return -1;
	}
	printk("Invalid option rejected OK\n");

	printk("Pinmux Driver Test PASSED\n");
	return 0;
}
