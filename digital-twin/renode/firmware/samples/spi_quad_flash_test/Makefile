# SPDX-FileCopyrightText: 2025 aesc silicon
#
# SPDX-License-Identifier: Apache-2.0

# Makefile for ElemRV-N bare-metal Quad I/O SPI flash test.

CC = riscv-none-elf-gcc
OBJCOPY = riscv-none-elf-objcopy
OBJDUMP = riscv-none-elf-objdump

CFLAGS = -march=rv32ic -mabi=ilp32 -nostdlib -nostartfiles -O2 -Wall
LDFLAGS = -T link.ld

TARGET = spi_quad_flash_test

.PHONY: all clean

all: $(TARGET).bin $(TARGET).lst

$(TARGET).elf: $(TARGET).c
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^

$(TARGET).bin: $(TARGET).elf
	$(OBJCOPY) -O binary $< $@

$(TARGET).lst: $(TARGET).elf
	$(OBJDUMP) -d $< > $@

clean:
	rm -f $(TARGET).elf $(TARGET).bin $(TARGET).lst
