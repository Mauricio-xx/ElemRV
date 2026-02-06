/*
 * SPDX-License-Identifier: Apache-2.0
 *
 * ElemRV-H Hello World — validates UART console on Zephyr.
 */

#include <zephyr/kernel.h>

int main(void)
{
	printk("Hello World! ElemRV-H on Zephyr\n");
	return 0;
}
