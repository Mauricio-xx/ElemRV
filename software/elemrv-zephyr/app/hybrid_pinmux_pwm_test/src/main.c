/*
 * SPDX-License-Identifier: Apache-2.0
 *
 * Hybrid Pinmux+PWM Integration Test
 *
 * Runs on the hybrid platform (LiteX UART/Timer + co-sim PWM/Pinmux).
 * This is the first test where Pinmux and PWM readback returns *real RTL
 * values* instead of 0 (which is what the Tag-based Zephyr platform returns).
 *
 * Test sequence:
 * 1. Route pin 0 to PWM CH0 via Pinmux, read back (expect 1, not 0!)
 * 2. Configure PWM CH0, read back period via sys_read32
 * 3. Route pin 8 to PWM CH1, configure CH1
 * 4. Read back all register values and validate
 */

#include <zephyr/kernel.h>
#include <zephyr/drivers/pwm.h>
#include <zephyr/sys/util.h>
#include <elemrv/drivers/pinmux.h>

/* Direct register access for validation */
#define PWM_BASE      0xF0003000
#define PWM_CLK_DIV   (PWM_BASE + 0x10)
#define PWM_CH0_CTRL  (PWM_BASE + 0x14)
#define PWM_CH0_PERIOD (PWM_BASE + 0x18)
#define PWM_CH0_PULSE (PWM_BASE + 0x1C)
#define PWM_CH1_CTRL  (PWM_BASE + 0x20)
#define PWM_CH1_PERIOD (PWM_BASE + 0x24)
#define PWM_CH1_PULSE (PWM_BASE + 0x28)

#define PWM_NODE    DT_NODELABEL(pwm0)
#define PINMUX_NODE DT_NODELABEL(pinmux)

int main(void)
{
	const struct device *pwm_dev = DEVICE_DT_GET(PWM_NODE);
	const struct device *mux_dev = DEVICE_DT_GET(PINMUX_NODE);
	uint8_t option;
	uint32_t reg_val;
	int ret;
	int errors = 0;

	printk("ElemRV-H Hybrid Pinmux+PWM Integration Test\n");

	if (!device_is_ready(pwm_dev)) {
		printk("ERROR: PWM device not ready\n");
		return -1;
	}
	if (!device_is_ready(mux_dev)) {
		printk("ERROR: Pinmux device not ready\n");
		return -1;
	}

	/* Step 1: Route pin 0 to PWM CH0 (option 1) */
	printk("Step 1: Pinmux pin 0 -> option 1 (PWM CH0)\n");
	ret = pinmux_set_option(mux_dev, 0, 1);
	if (ret) {
		printk("  ERROR: set failed: %d\n", ret);
		return -1;
	}

	ret = pinmux_get_option(mux_dev, 0, &option);
	if (ret) {
		printk("  ERROR: get failed: %d\n", ret);
		return -1;
	}
	printk("  Pinmux pin 0 readback: %u\n", option);
	if (option != 1) {
		printk("  WARN: expected 1, got %u (co-sim should return 1)\n",
		       option);
		errors++;
	}

	/* Step 2: Configure PWM CH0 — 1 kHz 50% duty */
	printk("Step 2: Configure PWM CH0 (period=1000, pulse=500)\n");
	ret = pwm_set_cycles(pwm_dev, 0, 1000, 500, 0);
	if (ret) {
		printk("  ERROR: pwm_set_cycles CH0 failed: %d\n", ret);
		return -1;
	}

	/* Read back PWM period via direct register access */
	reg_val = sys_read32(PWM_CH0_PERIOD);
	printk("  PWM CH0 period readback: %u\n", reg_val);
	if (reg_val != 1000) {
		printk("  WARN: expected 1000, got %u\n", reg_val);
		errors++;
	}

	reg_val = sys_read32(PWM_CH0_PULSE);
	printk("  PWM CH0 pulse readback: %u\n", reg_val);
	if (reg_val != 500) {
		printk("  WARN: expected 500, got %u\n", reg_val);
		errors++;
	}

	/* Step 3: Route pin 8 to PWM CH1 (option 1), configure CH1 */
	printk("Step 3: Pinmux pin 8 -> option 1 (PWM CH1)\n");
	ret = pinmux_set_option(mux_dev, 8, 1);
	if (ret) {
		printk("  ERROR: set failed: %d\n", ret);
		return -1;
	}

	ret = pinmux_get_option(mux_dev, 8, &option);
	if (ret) {
		printk("  ERROR: get failed: %d\n", ret);
		return -1;
	}
	printk("  Pinmux pin 8 readback: %u\n", option);

	ret = pwm_set_cycles(pwm_dev, 1, 2000, 1000, 0);
	if (ret) {
		printk("  ERROR: pwm_set_cycles CH1 failed: %d\n", ret);
		return -1;
	}

	/* Step 4: Final readback of all register values */
	printk("Step 4: Final register readback\n");

	pinmux_get_option(mux_dev, 0, &option);
	printk("  Pinmux pin 0: %u\n", option);

	pinmux_get_option(mux_dev, 8, &option);
	printk("  Pinmux pin 8: %u\n", option);

	printk("  PWM CH0 ctrl:   0x%08x\n", sys_read32(PWM_CH0_CTRL));
	printk("  PWM CH0 period: %u\n", sys_read32(PWM_CH0_PERIOD));
	printk("  PWM CH0 pulse:  %u\n", sys_read32(PWM_CH0_PULSE));
	printk("  PWM CH1 ctrl:   0x%08x\n", sys_read32(PWM_CH1_CTRL));
	printk("  PWM CH1 period: %u\n", sys_read32(PWM_CH1_PERIOD));
	printk("  PWM CH1 pulse:  %u\n", sys_read32(PWM_CH1_PULSE));

	if (errors == 0) {
		printk("Hybrid Pinmux-PWM Integration Test PASSED\n");
	} else {
		printk("Hybrid Pinmux-PWM Integration Test FAILED (%d errors)\n",
		       errors);
	}

	return 0;
}
