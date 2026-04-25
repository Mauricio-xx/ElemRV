# SPDX-License-Identifier: Apache-2.0

zephyr_library()
zephyr_library_sources_ifdef(CONFIG_PINMUX_WISHBONE pinmux_wishbone.c)
zephyr_library_include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../../include)
