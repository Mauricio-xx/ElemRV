/*
 * SPDX-License-Identifier: Apache-2.0
 *
 * Multi-Node IoT Gateway Firmware (ElemRV-N)
 *
 * Receives DATA frames from the edge node via UART, sends ACKs,
 * aggregates sensor readings, and prints a final report.
 *
 * Protocol:
 *   RX: DATA:<id>,<temp_x100>,<hum_x100>\n
 *   TX: ACK:<id>\n
 *   Report: REPORT: samples=N, avg_temp=T, avg_hum=H\n
 */

#include <zephyr/kernel.h>
#include <zephyr/drivers/uart.h>

#define UART_NODE       DT_NODELABEL(uart0)
#define NUM_SAMPLES     10
#define TIMEOUT_MS      30000

static int parse_int(const char *s, int *pos)
{
	int val = 0;
	int neg = 0;

	if (s[*pos] == '-') {
		neg = 1;
		(*pos)++;
	}
	while (s[*pos] >= '0' && s[*pos] <= '9') {
		val = val * 10 + (s[*pos] - '0');
		(*pos)++;
	}
	return neg ? -val : val;
}

static int starts_with(const char *s, const char *prefix)
{
	while (*prefix) {
		if (*s != *prefix) {
			return 0;
		}
		s++;
		prefix++;
	}
	return 1;
}

int main(void)
{
	const struct device *uart_dev = DEVICE_DT_GET(UART_NODE);
	int32_t sum_temp = 0;
	int32_t sum_hum = 0;
	int count = 0;
	int elapsed = 0;
	char line[128];
	int line_pos = 0;

	printk("Gateway: waiting for data\n");

	if (!device_is_ready(uart_dev)) {
		printk("Gateway: UART not ready\n");
		return -1;
	}

	while (count < NUM_SAMPLES && elapsed < TIMEOUT_MS) {
		unsigned char c;

		if (uart_poll_in(uart_dev, &c) == 0) {
			if (c == '\n') {
				line[line_pos] = '\0';

				if (starts_with(line, "DATA:")) {
					/* Parse DATA:<id>,<temp>,<hum> */
					int pos = 5;
					int id = parse_int(line, &pos);

					if (line[pos] == ',') {
						pos++;
					}
					int32_t temp = parse_int(line, &pos);

					if (line[pos] == ',') {
						pos++;
					}
					int32_t hum = parse_int(line, &pos);

					sum_temp += temp;
					sum_hum += hum;
					count++;

					/* Send ACK */
					printk("ACK:%d\n", id);
				}
				/* Ignore non-DATA lines (edge status, etc.) */

				line_pos = 0;
			} else if (c >= ' ' && line_pos < (int)sizeof(line) - 1) {
				line[line_pos++] = (char)c;
			}
		} else {
			k_sleep(K_MSEC(10));
			elapsed += 10;
		}
	}

	if (count > 0) {
		int32_t avg_temp = sum_temp / count;
		int32_t avg_hum = sum_hum / count;

		printk("REPORT: samples=%d, avg_temp=%d, avg_hum=%d\n",
		       count, (int)avg_temp, (int)avg_hum);
	} else {
		printk("REPORT: samples=0, no data received\n");
	}

	if (count == NUM_SAMPLES) {
		printk("Multi-Node IoT Test PASSED\n");
	} else {
		printk("Multi-Node IoT Test FAILED (got %d/%d)\n",
		       count, NUM_SAMPLES);
	}

	return 0;
}
