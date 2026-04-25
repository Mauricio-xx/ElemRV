# SPDX-FileCopyrightText: 2025 aesc silicon
#
# SPDX-License-Identifier: Apache-2.0

CC = riscv-none-elf-gcc
OBJCOPY = riscv-none-elf-objcopy
OBJDUMP = riscv-none-elf-objdump

CFLAGS = -march=rv32ic -mabi=ilp32 -nostdlib -nostartfiles -O2 -Wall
LDFLAGS = -T link.ld

TARGET = xip_cache_invalidate

.PHONY: all clean

all: $(TARGET).bin $(TARGET).lst

$(TARGET).elf: $(TARGET).S link.ld
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(TARGET).S

$(TARGET).bin: $(TARGET).elf
	$(OBJCOPY) -O binary $< $@

$(TARGET).lst: $(TARGET).elf
	$(OBJDUMP) -d $< > $@

clean:
	rm -f $(TARGET).elf $(TARGET).bin $(TARGET).lst
