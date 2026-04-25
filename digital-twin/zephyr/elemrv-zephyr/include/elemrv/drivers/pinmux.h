/*
 * SPDX-License-Identifier: Apache-2.0
 *
 * Public API for the AESC WishbonePinmux driver.
 *
 * The pinmux controller routes internal peripheral signals to external
 * physical pins. Each pin has one register (at offset pin*4) that selects
 * which of N options to route. Default on reset: option 0.
 *
 * ElemRV-H pin mapping (12 pins, 2 options each):
 *   Pin 0:  gpio0_0  | pwm0_0
 *   Pin 1:  gpio0_1  | pio0_0
 *   Pin 2:  gpio0_2  | pio0_1
 *   Pin 3:  gpio0_3  | pio0_2
 *   Pin 4:  uart0_tx | gpio0_4
 *   Pin 5:  uart0_rx | gpio0_5
 *   Pin 6:  uart0_cts| gpio0_6
 *   Pin 7:  uart0_rts| gpio0_7
 *   Pin 8:  gpio0_8  | pwm0_1
 *   Pin 9:  gpio0_9  | i2c0_scl
 *   Pin 10: gpio0_10 | i2c0_sda
 *   Pin 11: gpio0_11 | i2c0_int
 */

#ifndef ELEMRV_DRIVERS_PINMUX_H_
#define ELEMRV_DRIVERS_PINMUX_H_

#include <zephyr/device.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/**
 * @brief Set the mux option for a physical pin.
 *
 * @param dev Pinmux device
 * @param pin Physical pin number (0-based)
 * @param option Mux option to select (0-based)
 * @return 0 on success, -EINVAL for bad parameters
 */
int pinmux_set_option(const struct device *dev, uint8_t pin, uint8_t option);

/**
 * @brief Get the current mux option for a physical pin.
 *
 * @param dev Pinmux device
 * @param pin Physical pin number (0-based)
 * @param option Output: current mux option
 * @return 0 on success, -EINVAL for bad parameters
 */
int pinmux_get_option(const struct device *dev, uint8_t pin, uint8_t *option);

/**
 * @brief Get the number of physical pins.
 *
 * @param dev Pinmux device
 * @return Number of pins
 */
uint8_t pinmux_get_num_pins(const struct device *dev);

/**
 * @brief Get the number of mux options per pin.
 *
 * @param dev Pinmux device
 * @return Number of options
 */
uint8_t pinmux_get_num_options(const struct device *dev);

#ifdef __cplusplus
}
#endif

#endif /* ELEMRV_DRIVERS_PINMUX_H_ */
