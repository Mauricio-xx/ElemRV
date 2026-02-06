# SPDX-License-Identifier: Apache-2.0

# ElemRV Zephyr module

zephyr_include_directories(include)

add_subdirectory_ifdef(CONFIG_PWM drivers/pwm)
add_subdirectory_ifdef(CONFIG_PIO_WISHBONE drivers/pio)
add_subdirectory_ifdef(CONFIG_PINMUX_WISHBONE drivers/pinctrl)
