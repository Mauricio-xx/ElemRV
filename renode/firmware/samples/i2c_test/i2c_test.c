/*
 * SPDX-FileCopyrightText: 2025 aesc silicon
 *
 * SPDX-License-Identifier: Apache-2.0
 */

/*
 * Stage 005: I2C Controller Test
 * Tests I2C register access and basic operations
 */

#define I2C0_BASE       0xF0001000

/* LiteX I2C register offsets */
#define I2C_CONTROL     0x00    /* Control register */
#define I2C_STATUS      0x04    /* Status register */
#define I2C_DATA        0x08    /* Data register */
#define I2C_ADDRESS     0x0C    /* Address register */

static volatile unsigned int *i2c_control = (unsigned int *)(I2C0_BASE + I2C_CONTROL);
static volatile unsigned int *i2c_status = (unsigned int *)(I2C0_BASE + I2C_STATUS);
static volatile unsigned int *i2c_data = (unsigned int *)(I2C0_BASE + I2C_DATA);
static volatile unsigned int *i2c_address = (unsigned int *)(I2C0_BASE + I2C_ADDRESS);

void _start(void)
{
    unsigned int val;
    
    /* Test I2C register write/read */
    *i2c_control = 0x01;        /* Enable I2C */
    *i2c_address = 0x50;        /* Set slave address */
    *i2c_data = 0xAB;           /* Write data */
    
    /* Read back registers */
    val = *i2c_control;
    val = *i2c_status;
    val = *i2c_data;
    val = *i2c_address;
    
    /* Infinite loop - test complete */
    while (1) {
        __asm__ volatile("nop");
    }
}
