/*
 * SPDX-License-Identifier: Apache-2.0
 *
 * Hybrid Multi-Cosim Integration Test
 *
 * Exercises all 3 co-simulated peripherals (Pinmux, PWM, PIO) in a single
 * firmware sequence on the hybrid platform. Validates that all co-sim
 * peripherals respond with correct RTL register values when accessed together.
 *
 * Test sequence:
 * 1. Configure Pinmux: pin 0->PWM, pin 1->PIO, pin 8->PWM CH1
 * 2. Configure PWM: both channels, read back all registers
 * 3. Configure PIO: clock divider + command, read back
 * 4. Print all values — all should be non-zero RTL values
 */

#include <zephyr/kernel.h>
#include <zephyr/drivers/pwm.h>
#include <elemrv/drivers/pinmux.h>
#include <elemrv/drivers/pio.h>

/* Direct register access for validation */
#define PWM_BASE       0xF0003000
#define PWM_IP_HEADER  (PWM_BASE + 0x00)
#define PWM_CLK_DIV    (PWM_BASE + 0x10)
#define PWM_CH0_CTRL   (PWM_BASE + 0x14)
#define PWM_CH0_PERIOD (PWM_BASE + 0x18)
#define PWM_CH0_PULSE  (PWM_BASE + 0x1C)
#define PWM_CH1_CTRL   (PWM_BASE + 0x20)
#define PWM_CH1_PERIOD (PWM_BASE + 0x24)
#define PWM_CH1_PULSE  (PWM_BASE + 0x28)

#define PIO_BASE       0xF0002000
#define PIO_IP_HEADER  (PIO_BASE + 0x00)
#define PIO_CLK_DIV    (PIO_BASE + 0x1C)

#define PWM_NODE    DT_NODELABEL(pwm0)
#define PINMUX_NODE DT_NODELABEL(pinmux)
#define PIO_NODE    DT_NODELABEL(pio0)

int main(void)
{
	const struct device *pwm_dev = DEVICE_DT_GET(PWM_NODE);
	const struct device *mux_dev = DEVICE_DT_GET(PINMUX_NODE);
	const struct device *pio_dev = DEVICE_DT_GET(PIO_NODE);
	uint8_t option;
	int ret;
	int errors = 0;

	printk("ElemRV-H Hybrid Multi-Cosim Integration Test\n");

	if (!device_is_ready(pwm_dev)) {
		printk("ERROR: PWM device not ready\n");
		return -1;
	}
	if (!device_is_ready(mux_dev)) {
		printk("ERROR: Pinmux device not ready\n");
		return -1;
	}
	if (!device_is_ready(pio_dev)) {
		printk("ERROR: PIO device not ready\n");
		return -1;
	}

	/* Step 1: Configure Pinmux */
	printk("Step 1: Configure Pinmux routing\n");

	ret = pinmux_set_option(mux_dev, 0, 1);  /* pin 0 -> PWM CH0 */
	if (ret) {
		printk("  ERROR: pin 0 set failed: %d\n", ret);
		return -1;
	}
	pinmux_get_option(mux_dev, 0, &option);
	printk("  Pin 0 -> PWM CH0: readback=%u\n", option);
	if (option != 1) {
		errors++;
	}

	ret = pinmux_set_option(mux_dev, 1, 1);  /* pin 1 -> PIO0_0 */
	if (ret) {
		printk("  ERROR: pin 1 set failed: %d\n", ret);
		return -1;
	}
	pinmux_get_option(mux_dev, 1, &option);
	printk("  Pin 1 -> PIO0_0: readback=%u\n", option);
	if (option != 1) {
		errors++;
	}

	ret = pinmux_set_option(mux_dev, 8, 1);  /* pin 8 -> PWM CH1 */
	if (ret) {
		printk("  ERROR: pin 8 set failed: %d\n", ret);
		return -1;
	}
	pinmux_get_option(mux_dev, 8, &option);
	printk("  Pin 8 -> PWM CH1: readback=%u\n", option);
	if (option != 1) {
		errors++;
	}

	/* Step 2: Configure PWM both channels */
	printk("Step 2: Configure PWM (CH0: period=1000 pulse=500, CH1: period=2000 pulse=1000)\n");

	ret = pwm_set_cycles(pwm_dev, 0, 1000, 500, 0);
	if (ret) {
		printk("  ERROR: CH0 set failed: %d\n", ret);
		return -1;
	}

	ret = pwm_set_cycles(pwm_dev, 1, 2000, 1000, 0);
	if (ret) {
		printk("  ERROR: CH1 set failed: %d\n", ret);
		return -1;
	}

	printk("  PWM IP Header: 0x%08x\n", sys_read32(PWM_IP_HEADER));
	printk("  PWM clk_div:   %u\n", sys_read32(PWM_CLK_DIV));
	printk("  PWM CH0 ctrl:  0x%08x\n", sys_read32(PWM_CH0_CTRL));
	printk("  PWM CH0 period: %u\n", sys_read32(PWM_CH0_PERIOD));
	printk("  PWM CH0 pulse:  %u\n", sys_read32(PWM_CH0_PULSE));
	printk("  PWM CH1 ctrl:  0x%08x\n", sys_read32(PWM_CH1_CTRL));
	printk("  PWM CH1 period: %u\n", sys_read32(PWM_CH1_PERIOD));
	printk("  PWM CH1 pulse:  %u\n", sys_read32(PWM_CH1_PULSE));

	if (sys_read32(PWM_CH0_PERIOD) != 1000) {
		printk("  WARN: CH0 period mismatch\n");
		errors++;
	}
	if (sys_read32(PWM_CH1_PERIOD) != 2000) {
		printk("  WARN: CH1 period mismatch\n");
		errors++;
	}

	/* Step 3: Configure PIO */
	printk("Step 3: Configure PIO (clk_div=200, send HIGH cmd)\n");

	ret = pio_set_clock_divider(pio_dev, 200);
	if (ret) {
		printk("  ERROR: PIO set clk_div failed: %d\n", ret);
		return -1;
	}

	uint32_t pio_clk = sys_read32(PIO_CLK_DIV);
	printk("  PIO clk_div readback: %u\n", pio_clk);
	if (pio_clk != 200) {
		printk("  WARN: expected 200, got %u\n", pio_clk);
		errors++;
	}

	printk("  PIO IP Header: 0x%08x\n", sys_read32(PIO_IP_HEADER));

	ret = pio_send_cmd(pio_dev, PIO_CMD_HIGH, 0, 0);
	if (ret) {
		printk("  ERROR: PIO HIGH cmd failed: %d\n", ret);
		return -1;
	}
	printk("  PIO CMD HIGH pin 0 OK\n");

	/* Step 4: Summary */
	printk("Step 4: Summary (%d errors)\n", errors);

	if (errors == 0) {
		printk("Hybrid Multi-Cosim Integration Test PASSED\n");
	} else {
		printk("Hybrid Multi-Cosim Integration Test FAILED (%d errors)\n",
		       errors);
	}

	return 0;
}
