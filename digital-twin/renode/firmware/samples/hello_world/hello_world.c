/*
 * SPDX-FileCopyrightText: 2025 aesc silicon
 *
 * SPDX-License-Identifier: Apache-2.0
 */

/*
 * Hello World Firmware for ElemRV-H
 * Uses UART0 to print "Hello World" and echo input
 */

#define UART0_BASE      0xF0004000

/* LiteX UART register offsets */
#define UART_RXTX       0x00    /* Receive/Transmit register */
#define UART_TXFULL     0x04    /* TX FIFO full flag */
#define UART_RXEMPTY    0x08    /* RX FIFO empty flag */
#define UART_EV_PENDING 0x10    /* Event pending */
#define UART_EV_ENABLE  0x14    /* Event enable */

#define DELAY_COUNT     10000

static volatile unsigned int *uart_rxtx = (unsigned int *)(UART0_BASE + UART_RXTX);
static volatile unsigned int *uart_txfull = (unsigned int *)(UART0_BASE + UART_TXFULL);
static volatile unsigned int *uart_rxempty = (unsigned int *)(UART0_BASE + UART_RXEMPTY);

void delay(void)
{
    volatile unsigned int i;
    for (i = 0; i < DELAY_COUNT; i++) {
        __asm__ volatile("nop");
    }
}

void uart_putc(char c)
{
    /* Wait until TX FIFO is not full */
    while (*uart_txfull);
    *uart_rxtx = c;
}

void uart_puts(const char *str)
{
    while (*str) {
        uart_putc(*str++);
    }
}

char uart_getc(void)
{
    /* Wait until RX FIFO is not empty */
    while (*uart_rxempty);
    return (char)*uart_rxtx;
}

int uart_rx_available(void)
{
    return !*uart_rxempty;
}

void _start(void)
{
    const char *hello = "\r\nHello World from ElemRV-H!\r\n> ";
    const char *prompt = "\r\n> ";
    char c;

    /* Print welcome message */
    uart_puts(hello);

    /* Echo loop */
    while (1) {
        if (uart_rx_available()) {
            c = uart_getc();
            uart_putc(c);
            
            /* Print prompt on newline */
            if (c == '\r' || c == '\n') {
                uart_puts(prompt);
            }
        }
    }
}
