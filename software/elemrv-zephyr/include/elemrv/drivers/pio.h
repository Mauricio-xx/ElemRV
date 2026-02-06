/*
 * SPDX-License-Identifier: Apache-2.0
 *
 * Public API for the AESC WishbonePio driver.
 *
 * The PIO controller is a command-FIFO-based programmable I/O peripheral.
 * Commands are written to a FIFO; results from READ commands are read from
 * a separate result FIFO.
 */

#ifndef ELEMRV_DRIVERS_PIO_H_
#define ELEMRV_DRIVERS_PIO_H_

#include <zephyr/device.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/** PIO command types (matches RTL CommandType enum) */
enum pio_cmd_type {
	PIO_CMD_HIGH = 0, /**< Drive pin high (output) */
	PIO_CMD_LOW  = 1, /**< Drive pin low (output) */
	PIO_CMD_WAIT = 2, /**< Wait for data * clock-divider cycles */
	PIO_CMD_READ = 3, /**< Sample pin value (input) */
};

/** PIO read result */
struct pio_read_result {
	bool valid;       /**< True if result FIFO had data */
	uint8_t value;    /**< Pin value (0 or 1) */
};

/** FIFO status */
struct pio_fifo_status {
	uint8_t cmd_vacancy;   /**< Empty slots in command FIFO */
	uint8_t read_occupancy; /**< Results available in read FIFO */
};

/**
 * @brief Send a command to the PIO controller.
 *
 * @param dev PIO device
 * @param cmd Command type (HIGH, LOW, WAIT, READ)
 * @param pin Target pin number
 * @param data Command data (wait count for WAIT, ignored for others)
 * @return 0 on success, -EINVAL for bad parameters
 */
int pio_send_cmd(const struct device *dev, enum pio_cmd_type cmd,
		 uint8_t pin, uint32_t data);

/**
 * @brief Read a result from the PIO read FIFO.
 *
 * @param dev PIO device
 * @param result Output: valid flag and pin value
 * @return 0 on success
 */
int pio_read_result(const struct device *dev, struct pio_read_result *result);

/**
 * @brief Get FIFO status (command vacancy, read occupancy).
 *
 * @param dev PIO device
 * @param status Output: FIFO status
 * @return 0 on success
 */
int pio_get_fifo_status(const struct device *dev, struct pio_fifo_status *status);

/**
 * @brief Set the clock divider value.
 *
 * @param dev PIO device
 * @param divider Clock divider (20-bit, 0 = fastest)
 * @return 0 on success, -EINVAL if out of range
 */
int pio_set_clock_divider(const struct device *dev, uint32_t divider);

/**
 * @brief Set the read delay (cycles to wait before sampling in READ).
 *
 * @param dev PIO device
 * @param delay Read delay (8-bit)
 * @return 0 on success, -EINVAL if out of range
 */
int pio_set_read_delay(const struct device *dev, uint8_t delay);

#ifdef __cplusplus
}
#endif

#endif /* ELEMRV_DRIVERS_PIO_H_ */
