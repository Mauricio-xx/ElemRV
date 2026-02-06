/*
 * SPDX-License-Identifier: Apache-2.0
 *
 * ElemRV-H Timer-UART Integration Test
 * Validates the full interrupt chain: Timer HW interrupt -> VexRiscv IRQ ->
 * Zephyr scheduler -> k_timer callback -> UART TX (printk).
 *
 * Unlike blinky (which only uses k_sleep implicitly), this test explicitly
 * registers a k_timer with an expiry callback and verifies the callback
 * fires the expected number of times within a time window.
 */

#include <zephyr/kernel.h>

#define TIMER_PERIOD_MS  100
#define EXPECTED_CALLBACKS 4
#define WAIT_TIME_MS     500

static volatile int callback_count;

static void timer_expiry_cb(struct k_timer *timer)
{
	callback_count++;
	printk("TIMER_CB %d\n", callback_count);
}

K_TIMER_DEFINE(test_timer, timer_expiry_cb, NULL);

int main(void)
{
	printk("ElemRV-H Timer-UART Integration Test\n");
	printk("Timer period: %d ms, expecting >= %d callbacks in %d ms\n",
	       TIMER_PERIOD_MS, EXPECTED_CALLBACKS, WAIT_TIME_MS);

	callback_count = 0;

	k_timer_start(&test_timer, K_MSEC(TIMER_PERIOD_MS),
		       K_MSEC(TIMER_PERIOD_MS));

	/* Wait long enough for callbacks to accumulate */
	k_sleep(K_MSEC(WAIT_TIME_MS));

	k_timer_stop(&test_timer);

	printk("Timer stopped. Callback count: %d\n", callback_count);

	if (callback_count >= EXPECTED_CALLBACKS) {
		printk("Timer-UART Integration Test PASSED\n");
	} else {
		printk("Timer-UART Integration Test FAILED: only %d callbacks "
		       "(expected >= %d)\n", callback_count,
		       EXPECTED_CALLBACKS);
	}

	return 0;
}
