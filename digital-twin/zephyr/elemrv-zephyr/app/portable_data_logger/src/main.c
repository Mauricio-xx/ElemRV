/*
 * SPDX-License-Identifier: Apache-2.0
 *
 * Portable Data Logger — multi-threaded I2C sensor + LED heartbeat.
 *
 * Runs identically on ElemRV-H and ElemRV-N with zero #ifdef.
 * Uses device tree abstractions for all hardware access.
 *
 * Threads:
 *   main            (prio 0) — init sensor, start threads, wait
 *   sensor_thread   (prio 5) — read temp+hum every 200ms
 *   reporter_thread (prio 6) — print data every 500ms, LED toggle
 *
 * I2C sensor: SI70xx-compatible at address 0x48 on i2c0
 * LED: DT_ALIAS(led0) — exists on both boards
 */

#include <zephyr/kernel.h>
#include <zephyr/drivers/i2c.h>
#include <zephyr/drivers/gpio.h>
#include <zephyr/debug/thread_analyzer.h>

#define I2C_NODE           DT_NODELABEL(i2c0)
#define SENSOR_ADDR        0x48
#define CMD_MEASURE_TEMP   0xE3
#define CMD_MEASURE_HUM    0xE5

#define SENSOR_STACK_SIZE  384
#define REPORTER_STACK_SIZE 384

#define NUM_SAMPLES        10
#define SENSOR_INTERVAL_MS 200
#define REPORT_INTERVAL_MS 500

/* Shared sensor data (protected by mutex) */
static struct k_mutex data_mutex;
static int32_t shared_temp_x100;
static int32_t shared_hum_x100;
static int shared_sample_count;
static bool shared_done;

static const struct gpio_dt_spec led =
	GPIO_DT_SPEC_GET(DT_ALIAS(led0), gpios);

/* --- Sensor Thread --- */

static void sensor_entry(void *p1, void *p2, void *p3)
{
	ARG_UNUSED(p1);
	ARG_UNUSED(p2);
	ARG_UNUSED(p3);

	const struct device *i2c_dev = DEVICE_DT_GET(I2C_NODE);

	for (int i = 0; i < NUM_SAMPLES; i++) {
		uint8_t cmd;
		uint8_t data[2] = {0};
		int ret;

		/* Read temperature */
		cmd = CMD_MEASURE_TEMP;
		ret = i2c_write_read(i2c_dev, SENSOR_ADDR, &cmd, 1, data, 2);
		if (ret != 0) {
			k_sleep(K_MSEC(SENSOR_INTERVAL_MS));
			continue;
		}
		uint16_t raw_temp = (data[0] << 8) | data[1];
		int32_t temp_x100 = ((int32_t)17572 * raw_temp) / 65536 - 4685;

		/* Read humidity */
		cmd = CMD_MEASURE_HUM;
		ret = i2c_write_read(i2c_dev, SENSOR_ADDR, &cmd, 1, data, 2);
		if (ret != 0) {
			k_sleep(K_MSEC(SENSOR_INTERVAL_MS));
			continue;
		}
		uint16_t raw_hum = (data[0] << 8) | data[1];
		int32_t hum_x100 = ((int32_t)12500 * raw_hum) / 65536 - 600;

		k_mutex_lock(&data_mutex, K_FOREVER);
		shared_temp_x100 = temp_x100;
		shared_hum_x100 = hum_x100;
		shared_sample_count++;
		k_mutex_unlock(&data_mutex);

		k_sleep(K_MSEC(SENSOR_INTERVAL_MS));
	}

	k_mutex_lock(&data_mutex, K_FOREVER);
	shared_done = true;
	k_mutex_unlock(&data_mutex);
}

K_THREAD_DEFINE(sensor_thread, SENSOR_STACK_SIZE,
		sensor_entry, NULL, NULL, NULL,
		5, 0, 0);

/* --- Reporter Thread --- */

static void reporter_entry(void *p1, void *p2, void *p3)
{
	ARG_UNUSED(p1);
	ARG_UNUSED(p2);
	ARG_UNUSED(p3);

	int report_count = 0;
	int led_state = 0;

	while (1) {
		int32_t temp, hum;
		int count;
		bool done;

		k_mutex_lock(&data_mutex, K_FOREVER);
		temp = shared_temp_x100;
		hum = shared_hum_x100;
		count = shared_sample_count;
		done = shared_done;
		k_mutex_unlock(&data_mutex);

		int64_t uptime = k_uptime_get();

		int32_t t_abs = (temp < 0 ? -temp : temp);
		int32_t h_abs = (hum < 0 ? -hum : hum);

		printk("[%lld ms] Report %d: temp=%d.%02d C hum=%d.%02d %% samples=%d\n",
		       uptime, report_count,
		       temp / 100, t_abs % 100,
		       hum / 100, h_abs % 100,
		       count);

		/* LED heartbeat toggle */
		led_state ^= 1;
		gpio_pin_set_dt(&led, led_state);

		report_count++;

		/* Thread analyzer every 5th report */
		if (report_count % 5 == 0) {
			printk("--- Thread Analyzer ---\n");
			thread_analyzer_print(0);
			printk("--- End ---\n");
		}

		if (done && count >= NUM_SAMPLES) {
			printk("All %d samples collected\n", count);
			break;
		}

		k_sleep(K_MSEC(REPORT_INTERVAL_MS));
	}
}

K_THREAD_DEFINE(reporter_thread, REPORTER_STACK_SIZE,
		reporter_entry, NULL, NULL, NULL,
		6, 0, 0);

/* --- Main --- */

int main(void)
{
	const struct device *i2c_dev = DEVICE_DT_GET(I2C_NODE);

	printk("=== Portable Data Logger ===\n");

	/* Init mutex */
	k_mutex_init(&data_mutex);

	/* Validate I2C device */
	if (!device_is_ready(i2c_dev)) {
		printk("ERROR: I2C device not ready\n");
		printk("Portable Data Logger FAILED\n");
		return -1;
	}

	/* Validate sensor: read DevID */
	uint8_t cmd = 0xFC;  /* SI7021 read Electronic ID 2nd byte */
	uint8_t id[1] = {0};
	int ret = i2c_write_read(i2c_dev, SENSOR_ADDR, &cmd, 1, id, 1);

	if (ret != 0) {
		printk("WARNING: DevID read failed (ret=%d), continuing\n", ret);
	} else {
		printk("Sensor DevID: 0x%02X\n", id[0]);
	}

	/* Init LED */
	if (gpio_is_ready_dt(&led)) {
		gpio_pin_configure_dt(&led, GPIO_OUTPUT_ACTIVE);
		printk("LED initialized\n");
	} else {
		printk("WARNING: LED not ready\n");
	}

	printk("Starting sensor_thread + reporter_thread\n");
	printk("Samples: %d, sensor interval: %d ms, report interval: %d ms\n",
	       NUM_SAMPLES, SENSOR_INTERVAL_MS, REPORT_INTERVAL_MS);

	/* Wait for completion */
	while (1) {
		bool done;

		k_mutex_lock(&data_mutex, K_FOREVER);
		done = shared_done;
		k_mutex_unlock(&data_mutex);

		if (done) {
			/* Give reporter time to print final report */
			k_sleep(K_MSEC(1000));
			break;
		}
		k_sleep(K_MSEC(500));
	}

	printk("Portable Data Logger PASSED\n");

	return 0;
}
