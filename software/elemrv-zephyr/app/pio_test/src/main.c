/*
 * SPDX-License-Identifier: Apache-2.0
 *
 * ElemRV-H PIO Driver Test: Validates the custom WishbonePio Zephyr driver.
 * Exercises command encoding, FIFO status, clock divider, and read delay APIs.
 *
 * Note: In Renode, PIO is a tagged region (no RTL model), so writes are
 * silently absorbed and reads return 0. The test validates driver API paths
 * and parameter checking.
 */

#include <zephyr/kernel.h>
#include <elemrv/drivers/pio.h>

#define PIO_NODE DT_NODELABEL(pio0)

int main(void)
{
	const struct device *pio_dev = DEVICE_DT_GET(PIO_NODE);
	struct pio_read_result result;
	struct pio_fifo_status fifo;
	int ret;

	printk("ElemRV-H PIO Driver Test\n");

	if (!device_is_ready(pio_dev)) {
		printk("ERROR: PIO device not ready\n");
		return -1;
	}

	/* Set clock divider */
	ret = pio_set_clock_divider(pio_dev, 100);
	if (ret) {
		printk("ERROR: set clock divider failed: %d\n", ret);
		return -1;
	}
	printk("Clock divider set to 100 OK\n");

	/* Set read delay */
	ret = pio_set_read_delay(pio_dev, 4);
	if (ret) {
		printk("ERROR: set read delay failed: %d\n", ret);
		return -1;
	}
	printk("Read delay set to 4 OK\n");

	/* Send HIGH command on pin 0 */
	ret = pio_send_cmd(pio_dev, PIO_CMD_HIGH, 0, 0);
	if (ret) {
		printk("ERROR: HIGH pin 0 failed: %d\n", ret);
		return -1;
	}
	printk("CMD HIGH pin 0 OK\n");

	/* Send LOW command on pin 1 */
	ret = pio_send_cmd(pio_dev, PIO_CMD_LOW, 1, 0);
	if (ret) {
		printk("ERROR: LOW pin 1 failed: %d\n", ret);
		return -1;
	}
	printk("CMD LOW pin 1 OK\n");

	/* Send WAIT command (100 cycles) */
	ret = pio_send_cmd(pio_dev, PIO_CMD_WAIT, 0, 100);
	if (ret) {
		printk("ERROR: WAIT failed: %d\n", ret);
		return -1;
	}
	printk("CMD WAIT 100 cycles OK\n");

	/* Send READ command on pin 2 */
	ret = pio_send_cmd(pio_dev, PIO_CMD_READ, 2, 0);
	if (ret) {
		printk("ERROR: READ pin 2 failed: %d\n", ret);
		return -1;
	}
	printk("CMD READ pin 2 OK\n");

	/* Read result (in Renode: valid=0, value=0 since PIO is a tag) */
	ret = pio_read_result(pio_dev, &result);
	if (ret) {
		printk("ERROR: read result failed: %d\n", ret);
		return -1;
	}
	printk("Read result: valid=%d value=%d OK\n", result.valid, result.value);

	/* Check FIFO status */
	ret = pio_get_fifo_status(pio_dev, &fifo);
	if (ret) {
		printk("ERROR: get FIFO status failed: %d\n", ret);
		return -1;
	}
	printk("FIFO: vacancy=%u occupancy=%u OK\n",
	       fifo.cmd_vacancy, fifo.read_occupancy);

	/* Error case: invalid pin (expect -EINVAL) */
	ret = pio_send_cmd(pio_dev, PIO_CMD_HIGH, 3, 0);
	if (ret != -EINVAL) {
		printk("ERROR: invalid pin not rejected (ret=%d)\n", ret);
		return -1;
	}
	printk("Invalid pin rejected OK\n");

	/* Error case: clock divider overflow (expect -EINVAL) */
	ret = pio_set_clock_divider(pio_dev, 0x200000);
	if (ret != -EINVAL) {
		printk("ERROR: clock divider overflow not rejected (ret=%d)\n", ret);
		return -1;
	}
	printk("Clock divider overflow rejected OK\n");

	printk("PIO Driver Test PASSED\n");
	return 0;
}
