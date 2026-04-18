/*
 * SPDX-FileCopyrightText: 2025 aesc silicon
 *
 * SPDX-License-Identifier: Apache-2.0
 */

/*
 * Bare-metal exerciser for the ElemRV-N Quad I/O SPI Controller co-sim
 * with the embedded MT25Q-style flash slave (G.1b.2).
 *
 * Drives the controller directly through its command-stream register to
 * issue a RDID (0x9F) followed by a Quad I/O Fast Read (0xEB), then
 * prints results via UART and reports PASSED/FAILED.
 */

#include <stdint.h>

/* LiteX UART register map (per Zephyr's uart_litex driver):
 *   0x00 rxtx, 0x04 txfull, 0x08 rxempty, 0x0C ev_status,
 *   0x10 ev_pending, 0x14 ev_enable, 0x18 txempty, 0x1C rxfull
 */
#define UART_RXTX   (*(volatile uint32_t *)0xF0006000)
#define UART_TXFULL (*(volatile uint32_t *)0xF0006004)
#define SPI_CMD     (*(volatile uint32_t *)0xF0005050)

/* Command-stream word layout (see nafarr SpiControllerCtrl.StreamMapper):
 *   [31:28] streamMode: 0=DATA, 1=CS, 2=DUMMYCYCLES
 *   DATA:   [24]=read, [19:16]=mode (0=single, 2=quad), [7:0]=data byte
 *   CS:     [24]=enable, [csWidth-1:0]=index
 *   DUMMY:  [4:0]=half-cycle count (cycles=15 -> 8 SCLK cycles)
 */
#define CS_ENABLE       0x11000000u
#define CS_DISABLE      0x10000000u
#define DATA_WR_SINGLE(b)  ((uint32_t)(b))
#define DATA_RD_SINGLE     0x01000000u
#define DATA_WR_QUAD(b)    (0x00020000u | (uint32_t)(b))
#define DATA_RD_QUAD       0x01020000u
#define DUMMY_8_SCLK       0x2000000Fu

static void uart_putc(char c)
{
    while (UART_TXFULL & 1) {
        /* spin while TX FIFO full */
    }
    UART_RXTX = (uint32_t)(unsigned char)c;
}

static void uart_print(const char *s)
{
    while (*s) {
        uart_putc(*s++);
    }
}

static void uart_print_hex8(uint8_t v)
{
    static const char hex[] = "0123456789ABCDEF";
    uart_putc(hex[(v >> 4) & 0xF]);
    uart_putc(hex[v & 0xF]);
}

static uint8_t spi_read_byte(void)
{
    uint32_t r;
    do {
        r = SPI_CMD;
    } while (!(r & 0x80000000u));
    return (uint8_t)(r & 0xFF);
}

int main(void)
{
    uart_print("SPI Quad Flash Test\n");

    /* --- RDID (0x9F) in single-I/O --- */
    SPI_CMD = CS_ENABLE;
    SPI_CMD = DATA_WR_SINGLE(0x9F);
    SPI_CMD = DATA_RD_SINGLE;
    SPI_CMD = DATA_RD_SINGLE;
    SPI_CMD = DATA_RD_SINGLE;
    SPI_CMD = CS_DISABLE;

    uint8_t id[3];
    id[0] = spi_read_byte();
    id[1] = spi_read_byte();
    id[2] = spi_read_byte();

    uart_print("RDID: ");
    uart_print_hex8(id[0]); uart_putc(' ');
    uart_print_hex8(id[1]); uart_putc(' ');
    uart_print_hex8(id[2]); uart_putc('\n');

    int rdid_ok = (id[0] == 0x20) && (id[1] == 0xBA) && (id[2] == 0x18);

    /* --- Quad I/O Fast Read (0xEB) from address 0x000050 --- */
    SPI_CMD = CS_ENABLE;
    SPI_CMD = DATA_WR_SINGLE(0xEB);   /* cmd byte in single */
    SPI_CMD = DATA_WR_QUAD(0x00);     /* addr[23:16] in quad */
    SPI_CMD = DATA_WR_QUAD(0x00);     /* addr[15:8]  in quad */
    SPI_CMD = DATA_WR_QUAD(0x50);     /* addr[7:0]   in quad */
    SPI_CMD = DATA_WR_QUAD(0xA5);     /* M byte (non-continuation) in quad */
    SPI_CMD = DUMMY_8_SCLK;
    SPI_CMD = DATA_RD_QUAD;           /* byte 0 */
    SPI_CMD = DATA_RD_QUAD;           /* byte 1 */
    SPI_CMD = DATA_RD_QUAD;           /* byte 2 */
    SPI_CMD = DATA_RD_QUAD;           /* byte 3 */
    SPI_CMD = CS_DISABLE;

    uint8_t data[4];
    data[0] = spi_read_byte();
    data[1] = spi_read_byte();
    data[2] = spi_read_byte();
    data[3] = spi_read_byte();

    uart_print("QIO @0x50: ");
    uart_print_hex8(data[0]); uart_putc(' ');
    uart_print_hex8(data[1]); uart_putc(' ');
    uart_print_hex8(data[2]); uart_putc(' ');
    uart_print_hex8(data[3]); uart_putc('\n');

    /* Backing ROM pattern: rom[i] = i & 0xFF */
    int qio_ok = (data[0] == 0x50) && (data[1] == 0x51) &&
                 (data[2] == 0x52) && (data[3] == 0x53);

    if (rdid_ok && qio_ok) {
        uart_print("SPI Quad Flash Test PASSED\n");
    } else {
        uart_print("SPI Quad Flash Test FAILED\n");
    }

    for (;;) {
        __asm__ volatile("nop");
    }
    return 0;
}

__attribute__((naked, section(".text.init")))
void _start(void)
{
    __asm__ volatile(
        "la sp, __stack_start\n"
        "call main\n"
        "1: j 1b\n"
    );
}
