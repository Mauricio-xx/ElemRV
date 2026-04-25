/*
 * SPDX-License-Identifier: Apache-2.0
 *
 * ElemRV RTOS Diagnostics — thread analyzer, logging, and shell demo.
 *
 * Features (board-dependent):
 *   ElemRV-H (8KB): auto thread analyzer + LOG_INF + shell commands
 *   ElemRV-N (4KB): on-demand thread analyzer + LOG_INF only
 *
 * RAM budget:
 *   H: baseline ~2KB + 2 workers (512B) + analyzer auto (512B) + shell (1.5KB) = ~4.5KB
 *   N: baseline ~2KB + 2 workers (512B) + on-demand analyzer (0) = ~2.5KB
 */

#include <zephyr/kernel.h>
#include <zephyr/logging/log.h>
#include <zephyr/debug/thread_analyzer.h>

LOG_MODULE_REGISTER(rtos_diag, LOG_LEVEL_INF);

#define WORKER_STACK_SIZE 256

/* --- Worker A: periodic counter --- */

static void worker_a_entry(void *p1, void *p2, void *p3)
{
	ARG_UNUSED(p1);
	ARG_UNUSED(p2);
	ARG_UNUSED(p3);

	int count = 0;

	while (1) {
		LOG_INF("worker_a count=%d", count++);
		k_sleep(K_MSEC(1000));
	}
}

K_THREAD_DEFINE(worker_a, WORKER_STACK_SIZE,
		worker_a_entry, NULL, NULL, NULL,
		5, 0, 0);

/* --- Worker B: periodic sleep --- */

static void worker_b_entry(void *p1, void *p2, void *p3)
{
	ARG_UNUSED(p1);
	ARG_UNUSED(p2);
	ARG_UNUSED(p3);

	int cycle = 0;

	while (1) {
		LOG_INF("worker_b cycle=%d", cycle++);
		k_sleep(K_MSEC(1500));
	}
}

K_THREAD_DEFINE(worker_b, WORKER_STACK_SIZE,
		worker_b_entry, NULL, NULL, NULL,
		6, 0, 0);

/* --- Main --- */

int main(void)
{
	printk("=== RTOS Diagnostics ===\n");
	LOG_INF("Diagnostics started");
	LOG_INF("Threads: worker_a, worker_b");

	/* Wait for threads to run and build up some stack usage. */
	k_sleep(K_MSEC(3000));

	printk("\n--- On-Demand Thread Analyzer ---\n");
	thread_analyzer_print(0);
	printk("--- End Analyzer ---\n");

	printk("\nRTOS Diagnostics PASSED\n");

	/* Keep alive. On H, shell is available via UART. */
	while (1) {
		k_sleep(K_MSEC(10000));
	}

	return 0;
}
