/*
 * SPDX-License-Identifier: Apache-2.0
 *
 * ElemRV-H PWM Driver Test: Validates the custom WishbonePwm Zephyr driver.
 * Configures both channels and tests API edge cases.
 */

#include <zephyr/kernel.h>
#include <zephyr/drivers/pwm.h>

#define PWM_NODE DT_NODELABEL(pwm0)

int main(void)
{
	const struct device *pwm_dev = DEVICE_DT_GET(PWM_NODE);
	uint64_t cycles_per_sec;
	uint32_t period, pulse;
	int ret;

	printk("ElemRV-H PWM Driver Test\n");

	if (!device_is_ready(pwm_dev)) {
		printk("ERROR: PWM device not ready\n");
		return -1;
	}

	/* Query clock rate */
	ret = pwm_get_cycles_per_sec(pwm_dev, 0, &cycles_per_sec);
	if (ret) {
		printk("ERROR: pwm_get_cycles_per_sec failed: %d\n", ret);
		return -1;
	}
	printk("PWM clock: %u Hz\n", (uint32_t)cycles_per_sec);

	/* CH0: 1 kHz, 50% duty */
	period = (uint32_t)(cycles_per_sec / 1000);
	pulse = period / 2;
	printk("CH0: period=%u pulse=%u (1 kHz, 50%%)\n", period, pulse);
	ret = pwm_set_cycles(pwm_dev, 0, period, pulse, 0);
	if (ret) {
		printk("ERROR: CH0 set failed: %d\n", ret);
		return -1;
	}

	/* CH1: 10 kHz, 25% duty */
	period = (uint32_t)(cycles_per_sec / 10000);
	pulse = period / 4;
	printk("CH1: period=%u pulse=%u (10 kHz, 25%%)\n", period, pulse);
	ret = pwm_set_cycles(pwm_dev, 1, period, pulse, 0);
	if (ret) {
		printk("ERROR: CH1 set failed: %d\n", ret);
		return -1;
	}

	/* Disable CH0 (period=0) */
	ret = pwm_set_cycles(pwm_dev, 0, 0, 0, 0);
	if (ret) {
		printk("ERROR: CH0 disable failed: %d\n", ret);
		return -1;
	}
	printk("CH0 disabled OK\n");

	/* Re-enable CH0 with inverted polarity */
	period = (uint32_t)(cycles_per_sec / 1000);
	pulse = period / 2;
	ret = pwm_set_cycles(pwm_dev, 0, period, pulse, PWM_POLARITY_INVERTED);
	if (ret) {
		printk("ERROR: CH0 inverted set failed: %d\n", ret);
		return -1;
	}
	printk("CH0 inverted polarity OK\n");

	/* Invalid channel (expect -EINVAL) */
	ret = pwm_set_cycles(pwm_dev, 2, 1000, 500, 0);
	if (ret != -EINVAL) {
		printk("ERROR: invalid channel not rejected (ret=%d)\n", ret);
		return -1;
	}
	printk("Invalid channel rejected OK\n");

	/* Overflow (expect -EINVAL for > 20-bit) */
	ret = pwm_set_cycles(pwm_dev, 0, 0x200000, 0x100000, 0);
	if (ret != -EINVAL) {
		printk("ERROR: overflow not rejected (ret=%d)\n", ret);
		return -1;
	}
	printk("Overflow rejected OK\n");

	printk("PWM Driver Test PASSED\n");
	return 0;
}
