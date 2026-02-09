/*
 * SPDX-License-Identifier: Apache-2.0
 *
 * ElemRV RTOS Debug Demo — multi-thread app for GDB thread inspection.
 *
 * Creates 3 named application threads doing distinct periodic work.
 * Used with renode/gdb/zephyr_threads.py to demonstrate RTOS-level
 * debugging in the digital twin (thread listing, stack usage).
 *
 * Thread layout:
 *   main        (prio 0)  — prints banner, runs thread analyzer, idles
 *   sensor_thread (prio 5)  — simulates periodic sensor reads
 *   uart_thread   (prio 6)  — prints periodic status messages
 *   gpio_thread   (prio 7)  — simulates GPIO toggle loop
 *
 * Total extra RAM: ~768 bytes (3 x 256B stacks). Fits H (8KB) and N (4KB).
 */

#include <zephyr/kernel.h>
#include <zephyr/debug/thread_analyzer.h>

#define SENSOR_STACK_SIZE 256
#define UART_STACK_SIZE   256
#define GPIO_STACK_SIZE   256

/* --- Sensor Thread --- */

static void sensor_entry(void *p1, void *p2, void *p3)
{
	ARG_UNUSED(p1);
	ARG_UNUSED(p2);
	ARG_UNUSED(p3);

	int reading = 0;

	while (1) {
		reading = (reading + 7) & 0xFF;
		printk("[sensor] read=%d\n", reading);
		k_sleep(K_MSEC(500));
	}
}

K_THREAD_DEFINE(sensor_thread, SENSOR_STACK_SIZE,
		sensor_entry, NULL, NULL, NULL,
		5, 0, 0);

/* --- UART Thread --- */

static void uart_entry(void *p1, void *p2, void *p3)
{
	ARG_UNUSED(p1);
	ARG_UNUSED(p2);
	ARG_UNUSED(p3);

	int count = 0;

	while (1) {
		printk("[uart] status count=%d\n", count++);
		k_sleep(K_MSEC(750));
	}
}

K_THREAD_DEFINE(uart_thread, UART_STACK_SIZE,
		uart_entry, NULL, NULL, NULL,
		6, 0, 0);

/* --- GPIO Thread --- */

static void gpio_entry(void *p1, void *p2, void *p3)
{
	ARG_UNUSED(p1);
	ARG_UNUSED(p2);
	ARG_UNUSED(p3);

	int state = 0;

	while (1) {
		state ^= 1;
		printk("[gpio] toggle=%d\n", state);
		k_sleep(K_MSEC(1000));
	}
}

K_THREAD_DEFINE(gpio_thread, GPIO_STACK_SIZE,
		gpio_entry, NULL, NULL, NULL,
		7, 0, 0);

/* --- Main --- */

int main(void)
{
	printk("=== RTOS Debug Demo ===\n");
	printk("Threads: sensor_thread, uart_thread, gpio_thread\n");
	printk("Waiting 2s for threads to run...\n");

	k_sleep(K_MSEC(2000));

	printk("\n--- Thread Analyzer Report ---\n");
	thread_analyzer_print(0);
	printk("--- End Report ---\n");

	printk("\nRTOS Debug Demo PASSED\n");

	/* Keep main alive so threads continue. */
	while (1) {
		k_sleep(K_MSEC(5000));
	}

	return 0;
}
