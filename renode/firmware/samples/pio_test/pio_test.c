/*
 * SPDX-FileCopyrightText: 2025 aesc silicon
 *
 * SPDX-License-Identifier: Apache-2.0
 */

/*
 * Stage 007: PIO (Programmable IO) Test
 * Tests PIO register access (3 pins)
 */

#define PIO0_BASE       0xF0002000

/* PIO register offsets */
#define PIO_CTRL        0x00    /* Control register */
#define PIO_STATUS      0x04    /* Status register */
#define PIO_INSTR       0x08    /* Instruction register */
#define PIO_PIN0        0x0C    /* Pin 0 control */
#define PIO_PIN1        0x10    /* Pin 1 control */
#define PIO_PIN2        0x14    /* Pin 2 control */

static volatile unsigned int *pio_ctrl = (unsigned int *)(PIO0_BASE + PIO_CTRL);
static volatile unsigned int *pio_status = (unsigned int *)(PIO0_BASE + PIO_STATUS);
static volatile unsigned int *pio_instr = (unsigned int *)(PIO0_BASE + PIO_INSTR);
static volatile unsigned int *pio_pin0 = (unsigned int *)(PIO0_BASE + PIO_PIN0);
static volatile unsigned int *pio_pin1 = (unsigned int *)(PIO0_BASE + PIO_PIN1);
static volatile unsigned int *pio_pin2 = (unsigned int *)(PIO0_BASE + PIO_PIN2);

void _start(void)
{
    unsigned int val;
    
    /* Configure PIO */
    *pio_instr = 0xE001;        /* Write instruction */
    *pio_pin0 = 0x01;           /* Configure pin 0 */
    *pio_pin1 = 0x01;           /* Configure pin 1 */
    *pio_pin2 = 0x01;           /* Configure pin 2 */
    *pio_ctrl = 0x01;           /* Enable PIO */
    
    /* Read back registers */
    val = *pio_instr;
    val = *pio_pin0;
    val = *pio_pin1;
    val = *pio_pin2;
    val = *pio_ctrl;
    
    /* Infinite loop */
    while (1) {
        __asm__ volatile("nop");
    }
}
