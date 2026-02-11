/*
 * SPDX-License-Identifier: Apache-2.0
 *
 * Multi-Node IoT Edge Firmware (ElemRV-H)
 *
 * Reads temperature and humidity from an SI70xx sensor at I2C 0x48,
 * sends DATA frames to the gateway via UART, and waits for ACKs.
 *
 * Protocol:
 *   TX: DATA:<id>,<temp_x100>,<hum_x100>\n
 *   RX: ACK:<id>\n
 */

#include <zephyr/kernel.h>
#include <zephyr/drivers/i2c.h>
#include <zephyr/drivers/uart.h>

#define I2C_NODE           DT_NODELABEL(i2c0)
#define UART_NODE          DT_NODELABEL(uart0)
#define SENSOR_ADDR        0x48
#define CMD_MEASURE_TEMP   0xE3
#define CMD_MEASURE_HUM    0xE5
#define NUM_SAMPLES        10
#define SAMPLE_INTERVAL_MS 300
#define ACK_TIMEOUT_MS     2000

static int read_line(const struct device *uart, char *buf, int maxlen,
		     int timeout_ms)
{
	int pos = 0;
	int elapsed = 0;

	while (elapsed < timeout_ms && pos < maxlen - 1) {
		unsigned char c;

		if (uart_poll_in(uart, &c) == 0) {
			if (c == '\n') {
				buf[pos] = '\0';
				return pos;
			}
			if (c >= ' ') {
				buf[pos++] = (char)c;
			}
		} else {
			k_sleep(K_MSEC(10));
			elapsed += 10;
		}
	}
	buf[pos] = '\0';
	return -1;
}

static int parse_int(const char *s, int *pos)
{
	int val = 0;

	while (s[*pos] >= '0' && s[*pos] <= '9') {
		val = val * 10 + (s[*pos] - '0');
		(*pos)++;
	}
	return val;
}

int main(void)
{
	const struct device *i2c_dev = DEVICE_DT_GET(I2C_NODE);
	const struct device *uart_dev = DEVICE_DT_GET(UART_NODE);
	int acks = 0;

	printk("Edge: starting\n");

	if (!device_is_ready(i2c_dev)) {
		printk("Edge: I2C not ready\n");
		return -1;
	}

	if (!device_is_ready(uart_dev)) {
		printk("Edge: UART not ready\n");
		return -1;
	}

	for (int i = 1; i <= NUM_SAMPLES; i++) {
		uint8_t cmd;
		uint8_t data[2] = {0};
		int ret;

		/* Read temperature */
		cmd = CMD_MEASURE_TEMP;
		ret = i2c_write_read(i2c_dev, SENSOR_ADDR, &cmd, 1, data, 2);
		if (ret != 0) {
			printk("Edge: sample %d temp ERROR\n", i);
			continue;
		}
		uint16_t raw_temp = (data[0] << 8) | data[1];
		int32_t temp_x100 = ((int32_t)17572 * raw_temp) / 65536 - 4685;

		/* Read humidity */
		cmd = CMD_MEASURE_HUM;
		ret = i2c_write_read(i2c_dev, SENSOR_ADDR, &cmd, 1, data, 2);
		if (ret != 0) {
			printk("Edge: sample %d hum ERROR\n", i);
			continue;
		}
		uint16_t raw_hum = (data[0] << 8) | data[1];
		int32_t hum_x100 = ((int32_t)12500 * raw_hum) / 65536 - 600;

		/* Send DATA frame */
		printk("DATA:%d,%d,%d\n", i, (int)temp_x100, (int)hum_x100);

		/* Wait for ACK */
		char line[64];

		if (read_line(uart_dev, line, sizeof(line), ACK_TIMEOUT_MS) > 0) {
			/* Check for ACK:<id> */
			if (line[0] == 'A' && line[1] == 'C' && line[2] == 'K'
			    && line[3] == ':') {
				int pos = 4;
				int ack_id = parse_int(line, &pos);

				if (ack_id == i) {
					acks++;
				}
			}
		}

		k_sleep(K_MSEC(SAMPLE_INTERVAL_MS));
	}

	printk("Edge: capture complete, acks=%d/%d\n", acks, NUM_SAMPLES);
	return 0;
}
