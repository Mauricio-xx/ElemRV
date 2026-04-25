# SPDX-FileCopyrightText: 2025 aesc silicon
#
# SPDX-License-Identifier: Apache-2.0

# Makefile for PWM test application
# Builds bare-metal RISC-V binary for ElemRV-H

# Toolchain (RISC-V)
PREFIX := riscv-none-elf-
CC := $(PREFIX)gcc
LD := $(PREFIX)ld
OBJCOPY := $(PREFIX)objcopy
OBJDUMP := $(PREFIX)objdump
SIZE := $(PREFIX)size

# Flags
CFLAGS := -march=rv32ic_zicsr -mabi=ilp32 -O2 -Wall -ffreestanding -nostdlib
LDFLAGS := -T kernel.ld -nostdlib

# Source files
SRCS := start.s pwm_test.c
OBJS := $(SRCS:.c=.o)
OBJS := $(OBJS:.s=.o)

SRCS_REGTEST := start.s pwm_regtest.c
OBJS_REGTEST := $(SRCS_REGTEST:.c=.o)
OBJS_REGTEST := $(OBJS_REGTEST:.s=.o)

# Targets
TARGET := pwm_test
TARGET_REGTEST := pwm_regtest

.PHONY: all clean hex dump size regtest

all: $(TARGET).elf $(TARGET).bin $(TARGET).hex

regtest: $(TARGET_REGTEST).elf $(TARGET_REGTEST).bin $(TARGET_REGTEST).hex

$(TARGET).elf: $(OBJS) kernel.ld
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(OBJS)
	$(SIZE) $@

$(TARGET_REGTEST).elf: $(OBJS_REGTEST) kernel.ld
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(OBJS_REGTEST)
	$(SIZE) $@

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

%.o: %.s
	$(CC) $(CFLAGS) -c -o $@ $<

$(TARGET).bin: $(TARGET).elf
	$(OBJCOPY) -O binary $< $@

$(TARGET).hex: $(TARGET).elf
	$(OBJCOPY) -O ihex $< $@

$(TARGET_REGTEST).bin: $(TARGET_REGTEST).elf
	$(OBJCOPY) -O binary $< $@

$(TARGET_REGTEST).hex: $(TARGET_REGTEST).elf
	$(OBJCOPY) -O ihex $< $@

hex: $(TARGET).hex

dump: $(TARGET).elf
	$(OBJDUMP) -d $<

size: $(TARGET).elf
	$(SIZE) $<

clean:
	rm -f $(OBJS) $(OBJS_REGTEST) $(TARGET).elf $(TARGET).bin $(TARGET).hex $(TARGET_REGTEST).elf $(TARGET_REGTEST).bin $(TARGET_REGTEST).hex
