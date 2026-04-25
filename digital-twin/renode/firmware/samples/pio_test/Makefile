# SPDX-FileCopyrightText: 2025 aesc silicon
#
# SPDX-License-Identifier: Apache-2.0

# Makefile for Hello World test firmware

CC = riscv-none-elf-gcc
OBJCOPY = riscv-none-elf-objcopy
OBJDUMP = riscv-none-elf-objdump

CFLAGS = -march=rv32ic -mabi=ilp32 -nostdlib -nostartfiles -O2
LDFLAGS = -T link.ld

TARGET = pio_test

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

# For Renode simulation - loads binary at RAM address
test: $(TARGET).bin
	@echo "Run in Renode:"
	@echo "  sysbus LoadBinary @$(TARGET).bin 0x80000000"
	@echo "  cpu PC 0x80000000"
	@echo "  start"
