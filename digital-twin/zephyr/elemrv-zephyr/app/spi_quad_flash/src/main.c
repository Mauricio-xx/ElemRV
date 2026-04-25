/*
 * SPDX-License-Identifier: Apache-2.0
 *
 * Zephyr exerciser for the ElemRV-N Quad I/O SPI flash co-sim.
 *
 * Part 1: standard Zephyr SPI API (spi_transceive) issues RDID (0x9F)
 * and validates MT25Q-style manufacturer/family/capacity bytes. This
 * proves the Zephyr nafarr-SPI driver stack talks to the new DT.
 *
 * Part 2: direct command-stream pokes drive a Quad I/O Fast Read
 * (0xEB) from address 0x000050 and validate the synthetic backing-ROM
 * pattern rom[i] = i & 0xFF. Zephyr's SPI API is single-I/O only, so
 * the quad mode bits in the command word are set by hand.
 */

#include <zephyr/kernel.h>
#include <zephyr/drivers/spi.h>
#include <zephyr/sys/sys_io.h>

#define SPI_NODE DT_NODELABEL(spi0)

#define SPI_BASE        0xF0005000u
#define REG_CMD_RSP     (SPI_BASE + 0x050)

/* Command-stream encoding — see nafarr SpiControllerCtrl.StreamMapper. */
#define CS_ENABLE_CMD       0x11000000u
#define CS_DISABLE_CMD      0x10000000u
#define DATA_WR_SINGLE(b)   ((uint32_t)(b))
#define DATA_WR_QUAD(b)     (0x00020000u | (uint32_t)(b))
#define DATA_RD_QUAD        0x01020000u
#define DUMMY_8_SCLK        0x2000000Fu
#define RSP_VALID           0x80000000u

static const struct spi_config spi_cfg = {
	.frequency = 1000000,
	.operation = SPI_WORD_SET(8) | SPI_TRANSFER_MSB,
	.slave = 0,
};

static int do_rdid(const struct device *spi, uint8_t id[3])
{
	uint8_t tx[1] = { 0x9F };
	uint8_t rx[3] = { 0 };

	struct spi_buf tx_b = { .buf = tx, .len = 1 };
	struct spi_buf_set tx_s = { .buffers = &tx_b, .count = 1 };
	struct spi_buf rx_b = { .buf = rx, .len = 3 };
	struct spi_buf_set rx_s = { .buffers = &rx_b, .count = 1 };

	int ret = spi_transceive(spi, &spi_cfg, &tx_s, &rx_s);
	if (ret != 0) {
		return ret;
	}

	/* Zephyr's full-duplex transceive returns bytes shifted during the
	 * MOSI tx phase too — skip the first byte (echo of 0x9F) and take
	 * the next 3. Here rx starts at the RX side of the same transfer,
	 * which in single-I/O half-duplex fashion aligns from byte 0.
	 */
	id[0] = rx[0];
	id[1] = rx[1];
	id[2] = rx[2];
	return 0;
}

static uint8_t spi_read_rsp(void)
{
	uint32_t v;
	do {
		v = sys_read32(REG_CMD_RSP);
	} while (!(v & RSP_VALID));
	return (uint8_t)(v & 0xFF);
}

static void do_qio_fast_read(uint32_t addr, uint8_t out[4])
{
	sys_write32(CS_ENABLE_CMD,                 REG_CMD_RSP);
	sys_write32(DATA_WR_SINGLE(0xEB),          REG_CMD_RSP);
	sys_write32(DATA_WR_QUAD((addr >> 16) & 0xFF), REG_CMD_RSP);
	sys_write32(DATA_WR_QUAD((addr >> 8)  & 0xFF), REG_CMD_RSP);
	sys_write32(DATA_WR_QUAD((addr >> 0)  & 0xFF), REG_CMD_RSP);
	sys_write32(DATA_WR_QUAD(0xA5),            REG_CMD_RSP);
	sys_write32(DUMMY_8_SCLK,                  REG_CMD_RSP);
	sys_write32(DATA_RD_QUAD,                  REG_CMD_RSP);
	sys_write32(DATA_RD_QUAD,                  REG_CMD_RSP);
	sys_write32(DATA_RD_QUAD,                  REG_CMD_RSP);
	sys_write32(DATA_RD_QUAD,                  REG_CMD_RSP);
	sys_write32(CS_DISABLE_CMD,                REG_CMD_RSP);

	out[0] = spi_read_rsp();
	out[1] = spi_read_rsp();
	out[2] = spi_read_rsp();
	out[3] = spi_read_rsp();
}

int main(void)
{
	const struct device *spi = DEVICE_DT_GET(SPI_NODE);

	printk("SPI Quad Flash Zephyr Test\n");

	if (!device_is_ready(spi)) {
		printk("SPI device not ready\n");
		printk("SPI Quad Flash Zephyr FAILED\n");
		return -1;
	}

	uint8_t id[3] = { 0 };
	int ret = do_rdid(spi, id);
	if (ret != 0) {
		printk("RDID transceive error: %d\n", ret);
		printk("SPI Quad Flash Zephyr FAILED\n");
		return -1;
	}
	printk("RDID: %02X %02X %02X\n", id[0], id[1], id[2]);
	int rdid_ok = (id[0] == 0x20) && (id[1] == 0xBA) && (id[2] == 0x18);

	uint8_t data[4] = { 0 };
	do_qio_fast_read(0x000050, data);
	printk("QIO @0x50: %02X %02X %02X %02X\n",
	       data[0], data[1], data[2], data[3]);
	int qio_ok = (data[0] == 0x50) && (data[1] == 0x51) &&
		     (data[2] == 0x52) && (data[3] == 0x53);

	if (rdid_ok && qio_ok) {
		printk("SPI Quad Flash Zephyr PASSED\n");
	} else {
		printk("SPI Quad Flash Zephyr FAILED\n");
	}

	return 0;
}
