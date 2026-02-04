/*
 * SPDX-FileCopyrightText: 2025 aesc silicon
 *
 * SPDX-License-Identifier: Apache-2.0
 */

/*
 * GPIO Test Firmware
 * Toggles GPIO pin 0 with simple delay loop
 */

#define GPIO0_BASE  0xF0000000
#define GPIO_DIR    0x00  /* Direction register */
#define GPIO_VAL    0x04  /* Value register */
#define GPIO_EN     0x08  /* Output enable */

#define DELAY_COUNT 500000

static volatile unsigned int *gpio_dir = (unsigned int *)GPIO0_BASE;
static volatile unsigned int *gpio_val = (unsigned int *)(GPIO0_BASE + GPIO_VAL);
static volatile unsigned int *gpio_en  = (unsigned int *)(GPIO0_BASE + GPIO_EN);

void delay(void)
{
    volatile unsigned int i;
    for (i = 0; i < DELAY_COUNT; i++) {
        __asm__ volatile("nop");
    }
}

void _start(void)
{
    /* Set pin 0 as output */
    *gpio_dir = 0x01;
    *gpio_en = 0x01;

    while (1) {
        /* Toggle pin 0 */
        *gpio_val = 0x01;
        delay();
        *gpio_val = 0x00;
        delay();
    }
}
