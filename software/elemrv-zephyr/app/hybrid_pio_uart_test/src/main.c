/*
 * SPDX-License-Identifier: Apache-2.0
 *
 * Hybrid PIO-UART Integration Test
 *
 * Runs on the hybrid platform (LiteX UART/Timer + co-sim PIO).
 * Exercises PIO co-sim registers and reports results via LiteX UART console.
 *
 * Key validation: PIO register readback returns *real RTL values* (not 0).
 */

#include <zephyr/kernel.h>
#include <elemrv/drivers/pio.h>

/* Direct register access for validation */
#define PIO_BASE       0xF0002000
#define PIO_CLK_DIV    (PIO_BASE + 0x1C)
#define PIO_READ_DELAY (PIO_BASE + 0x20)

#define PIO_NODE DT_NODELABEL(pio0)

int main(void)
{
	const struct device *pio_dev = DEVICE_DT_GET(PIO_NODE);
	struct pio_fifo_status fifo;
	uint32_t reg_val;
	int ret;
	int errors = 0;

	printk("ElemRV-H Hybrid PIO-UART Integration Test\n");

	if (!device_is_ready(pio_dev)) {
		printk("ERROR: PIO device not ready\n");
		return -1;
	}

	/* Step 1: Set clock divider and read back via direct register access */
	printk("Step 1: Set PIO clock divider = 100\n");
	ret = pio_set_clock_divider(pio_dev, 100);
	if (ret) {
		printk("  ERROR: set clock divider failed: %d\n", ret);
		return -1;
	}

	reg_val = sys_read32(PIO_CLK_DIV);
	printk("  PIO clk_div readback: %u\n", reg_val);
	if (reg_val != 100) {
		printk("  WARN: expected 100, got %u (co-sim should return 100)\n",
		       reg_val);
		errors++;
	}

	/* Step 2: Set read delay and verify */
	printk("Step 2: Set PIO read delay = 8\n");
	ret = pio_set_read_delay(pio_dev, 8);
	if (ret) {
		printk("  ERROR: set read delay failed: %d\n", ret);
		return -1;
	}

	reg_val = sys_read32(PIO_READ_DELAY);
	printk("  PIO read_delay readback: %u\n", reg_val);
	if (reg_val != 8) {
		printk("  WARN: expected 8, got %u\n", reg_val);
		errors++;
	}

	/* Step 3: Send commands to co-sim PIO FIFO */
	printk("Step 3: Send PIO commands (HIGH pin 0, LOW pin 1)\n");
	ret = pio_send_cmd(pio_dev, PIO_CMD_HIGH, 0, 0);
	if (ret) {
		printk("  ERROR: HIGH pin 0 failed: %d\n", ret);
		return -1;
	}
	printk("  CMD HIGH pin 0 OK\n");

	ret = pio_send_cmd(pio_dev, PIO_CMD_LOW, 1, 0);
	if (ret) {
		printk("  ERROR: LOW pin 1 failed: %d\n", ret);
		return -1;
	}
	printk("  CMD LOW pin 1 OK\n");

	/* Step 4: Check FIFO status (co-sim should reflect real queue depth) */
	printk("Step 4: Check FIFO status\n");
	ret = pio_get_fifo_status(pio_dev, &fifo);
	if (ret) {
		printk("  ERROR: get FIFO status failed: %d\n", ret);
		return -1;
	}
	printk("  FIFO: cmd_vacancy=%u read_occupancy=%u\n",
	       fifo.cmd_vacancy, fifo.read_occupancy);

	if (errors == 0) {
		printk("Hybrid PIO-UART Integration Test PASSED\n");
	} else {
		printk("Hybrid PIO-UART Integration Test FAILED (%d errors)\n",
		       errors);
	}

	return 0;
}
