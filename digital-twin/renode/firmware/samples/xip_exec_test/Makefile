# SPDX-FileCopyrightText: 2025 aesc silicon
#
# SPDX-License-Identifier: Apache-2.0

CC = riscv-none-elf-gcc
OBJCOPY = riscv-none-elf-objcopy
OBJDUMP = riscv-none-elf-objdump

CFLAGS = -march=rv32ic -mabi=ilp32 -nostdlib -nostartfiles -O2 -Wall
LDFLAGS = -T link.ld

TARGET = xip_exec_test
IMAGE = xip_exec_image.img
GEN_SCRIPT = /workspace/elemrv/digital-twin/scripts/gen_dt_image_container.sh

.PHONY: all clean image

all: $(TARGET).bin $(TARGET).lst $(IMAGE)

$(TARGET).elf: $(TARGET).c link.ld
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(TARGET).c

$(TARGET).bin: $(TARGET).elf
	$(OBJCOPY) -O binary $< $@

$(TARGET).lst: $(TARGET).elf
	$(OBJDUMP) -d $< > $@

$(IMAGE): $(TARGET).bin
	bash $(GEN_SCRIPT) $< $@

clean:
	rm -f $(TARGET).elf $(TARGET).bin $(TARGET).lst $(IMAGE)
