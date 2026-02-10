# Bare-metal Firmware Development

Develop firmware without an operating system for the ElemRV Digital Twin platform.

## Overview

Bare-metal firmware provides direct hardware access without RTOS overhead. Ideal for:
- Learning embedded systems
- Minimal code size
- Deterministic timing
- Hardware abstraction layer development

## Architecture

```
Bare-metal Firmware
===================

Application (main.c)
    └── Direct register access

Hardware Abstraction (optional)
    └── Register definitions
    └── Peripheral drivers

Hardware
    └── Memory-mapped peripherals
    └── CPU registers
```

## Project Structure

```
software/elemrv_h/
└── pwm_test/
    ├── start.s
    ├── pwm_test.c
    ├── pwm_regtest.c
    ├── pwm.h
    ├── kernel.ld
    └── Makefile
```

## Building Bare-metal Firmware

### Manual Build

```bash
cd software/elemrv_h/pwm_test

# Build
make

# Output: pwm_test.bin, pwm_test.elf
```

### Using Taskfile

```bash
# Build all bare-metal firmware
task dt-build-firmware
```

## Example: PWM Test

### Register Definitions

```c
// pwm.h (simplified from actual software/elemrv_h/pwm_test/pwm.h)
#ifndef PWM_H
#define PWM_H

#include <stdint.h>

#define PWM_BASE                0xF0003000

// Register offsets (from WishbonePwm.v RTL)
#define PWM_IP_HEADER_OFFSET    0x000
#define PWM_IP_VERSION_OFFSET   0x004
#define PWM_IP_FEATURES_OFFSET  0x008
#define PWM_IP_STATUS_OFFSET    0x00C
#define PWM_CLK_DIV_OFFSET      0x010
#define PWM_CH0_CTRL_OFFSET     0x014
#define PWM_CH0_PERIOD_OFFSET   0x018
#define PWM_CH0_PULSE_OFFSET    0x01C
#define PWM_CH1_CTRL_OFFSET     0x020
#define PWM_CH1_PERIOD_OFFSET   0x024
#define PWM_CH1_PULSE_OFFSET    0x028

// Expected read-only register values
#define PWM_EXPECTED_HEADER     0x00080002
#define PWM_EXPECTED_VERSION    0x01000000
#define PWM_EXPECTED_FEATURES   0x14141402

// Channel control bits
#define PWM_CTRL_ENABLE         (1 << 0)
#define PWM_CTRL_INVERT         (1 << 1)

#define REG32(addr) (*(volatile uint32_t *)(addr))

#endif
```

### Main Application

```c
// pwm_test.c (simplified from actual firmware)
#include "pwm.h"

extern void hang(void);

// GPIO for pass/fail indication
#define GPIO_BASE    0xF0000000
#define GPIO_OUT     (GPIO_BASE + 0x10)
#define GPIO_OE      (GPIO_BASE + 0x14)

#define RESULT_PASS  0xAA1
#define RESULT_FAIL  0xF00

void _kernel(void)
{
    // Verify PWM present via IP Header
    if (REG32(PWM_BASE + PWM_IP_HEADER_OFFSET) != PWM_EXPECTED_HEADER) {
        REG32(GPIO_OE) = RESULT_FAIL;
        REG32(GPIO_OUT) = RESULT_FAIL;
        hang();
    }

    // Configure PWM: 1kHz, 50% duty
    REG32(PWM_BASE + PWM_CLK_DIV_OFFSET) = 49;      // 50MHz/50 = 1MHz
    REG32(PWM_BASE + PWM_CH0_PERIOD_OFFSET) = 999;   // 1MHz/1000 = 1kHz
    REG32(PWM_BASE + PWM_CH0_PULSE_OFFSET) = 499;    // 50% duty
    REG32(PWM_BASE + PWM_CH0_CTRL_OFFSET) = PWM_CTRL_ENABLE;

    // Signal pass
    REG32(GPIO_OE) = RESULT_PASS;
    REG32(GPIO_OUT) = RESULT_PASS;

    hang();
}
```

> **Note**: The entry point is `_kernel` (not `main`). The startup assembly in `start.s` calls `_kernel` after initializing the stack. The full code uses a `struct pwm_driver` pattern for cleaner abstraction.

### Makefile

```makefile
# Makefile (from actual software/elemrv_h/pwm_test/Makefile)
PREFIX := riscv-none-elf-
CC := $(PREFIX)gcc
OBJCOPY := $(PREFIX)objcopy

CFLAGS := -march=rv32ic_zicsr -mabi=ilp32 -O2 -Wall -ffreestanding -nostdlib
LDFLAGS := -T kernel.ld -nostdlib

SRCS := start.s pwm_test.c
OBJS := $(SRCS:.c=.o)
OBJS := $(OBJS:.s=.o)

TARGET := pwm_test

all: $(TARGET).elf $(TARGET).bin

$(TARGET).elf: $(OBJS) kernel.ld
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(OBJS)

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

%.o: %.s
	$(CC) $(CFLAGS) -c -o $@ $<

$(TARGET).bin: $(TARGET).elf
	$(OBJCOPY) -O binary $< $@

clean:
	rm -f $(OBJS) $(TARGET).elf $(TARGET).bin
```

Key differences from a typical bare-metal Makefile: `-march=rv32ic_zicsr` (not just `rv32ic`), `-T kernel.ld` (not a generic `linker_script.ld`), and sources include `start.s` assembly startup.

## Memory Map

```c
// memory_map.h
#ifndef MEMORY_MAP_H
#define MEMORY_MAP_H

// RAM
#define RAM_BASE        0x80000000
#define RAM_SIZE        0x2000  // 8KB for H

// Flash
#define FLASH_BASE      0xA0000000
#define FLASH_SIZE      0x10000 // 64KB

// Peripherals
#define GPIO_BASE       0xF0000000
#define I2C_BASE        0xF0001000
#define PIO_BASE        0xF0002000
#define PWM_BASE        0xF0003000
#define UART_BASE       0xF0004000
#define TIMER_BASE      0xF0005000
#define PINMUX_BASE     0xF0010000

#endif
```

## GPIO Example

```c
// gpio_example.c
#include <stdint.h>

#define GPIO_BASE       0xF0000000
#define GPIO_VALUE      (GPIO_BASE + 0x0C)  // Pin input values (RO)
#define GPIO_WRITE      (GPIO_BASE + 0x10)  // Output data register (R/W)
#define GPIO_DIR        (GPIO_BASE + 0x14)  // Direction register (RO in H)

static inline void gpio_set_dir(uint32_t pin, uint8_t output) {
    uint32_t val = *(volatile uint32_t *)GPIO_DIR;
    if (output) {
        val |= (1 << pin);
    } else {
        val &= ~(1 << pin);
    }
    *(volatile uint32_t *)GPIO_DIR = val;
}

static inline void gpio_write(uint32_t pin, uint8_t value) {
    uint32_t val = *(volatile uint32_t *)GPIO_WRITE;
    if (value) {
        val |= (1 << pin);
    } else {
        val &= ~(1 << pin);
    }
    *(volatile uint32_t *)GPIO_WRITE = val;
}

static inline uint8_t gpio_read(uint32_t pin) {
    uint32_t val = *(volatile uint32_t *)GPIO_VALUE;
    return (val >> pin) & 1;
}

int main(void) {
    // Configure pin 0 as output (LED)
    gpio_set_dir(0, 1);

    // Configure pin 1 as input (button)
    gpio_set_dir(1, 0);

    while (1) {
        // LED follows button state
        gpio_write(0, gpio_read(1));

        // Simple delay
        for (volatile int i = 0; i < 100000; i++);
    }

    return 0;
}
```

## UART Example

> **Note**: This UART example is conceptual. No `uart_test.c` exists in the repository. Consult `gen/WishboneUart.v` for the actual register layout.

```c
// uart_example.c (conceptual)
#include <stdint.h>

#define UART_BASE       0xF0004000
#define UART_TX         (UART_BASE + 0x10)
#define UART_STATUS     (UART_BASE + 0x0C)

#define UART_TX_READY   0x01

static inline void uart_putc(char c) {
    // Wait for TX ready
    while (!(*(volatile uint32_t *)UART_STATUS & UART_TX_READY));
    *(volatile uint32_t *)UART_TX = c;
}

static void uart_puts(const char *s) {
    while (*s) {
        uart_putc(*s++);
    }
}

int main(void) {
    uart_puts("Hello from bare-metal!\r\n");
    
    int count = 0;
    while (1) {
        uart_puts("Count: ");
        // Simple number print
        char buf[12];
        int i = 0;
        int n = count;
        do {
            buf[i++] = '0' + (n % 10);
            n /= 10;
        } while (n > 0);
        while (i > 0) {
            uart_putc(buf[--i]);
        }
        uart_puts("\r\n");
        
        // Delay
        for (volatile int j = 0; j < 500000; j++);
        count++;
    }
    
    return 0;
}
```

## Linker Script

```ld
/* kernel.ld */

MEMORY {
    OCRAM (xrw): ORIGIN = 0x80000000, LENGTH = 8k
    FLASH (xr ): ORIGIN = 0xA0000000, LENGTH = 64k
}

SECTIONS {
    .text : {
        *(.text*)
        *(.rodata*)
    } > FLASH

    .data : {
        *(.data*)
    } > OCRAM AT > FLASH

    .bss : {
        *(.bss*)
    } > OCRAM

    __stack_top = ORIGIN(OCRAM) + LENGTH(OCRAM);
}
```

## Running in Digital Twin

### Test Script

```renode
# test_bare_metal.resc
using sysbus

mach create "bare_metal_test"
machine LoadPlatformDescription @platforms/elemrv_h.repl

# Load firmware
sysbus LoadBinary @software/elemrv_h/pwm_test/pwm_test.bin 0xA0000000
cpu PC 0xA0000000

# Run
emulation RunFor "00:00:05.000000"

echo "Test complete"
quit
```

### GDB Debugging

```bash
# Start GDB server
task dt-debug-bare-metal

# Connect
task dt-debug-connect ELF=software/elemrv_h/pwm_test/pwm_test.elf
```

## Best Practices

### Register Access

Always use `volatile` for hardware registers:
```c
// Good
*(volatile uint32_t *)REG = value;

// Bad - may be optimized away
*(uint32_t *)REG = value;
```

### Memory Barriers

Insert barriers after critical operations:
```c
#define memory_barrier() __asm__ volatile ("" ::: "memory")

*(volatile uint32_t *)REG = value;
memory_barrier();
```

### Error Checking

Verify peripheral presence:
```c
#define PWM_EXPECTED_HEADER 0x00080002

uint32_t header = REG32(PWM_BASE + PWM_IP_HEADER_OFFSET);
if (header != PWM_EXPECTED_HEADER) {
    // Handle error - peripheral not present or wrong version
    return -1;
}
```

### Timing Calibration

Calibrate delay loops for target frequency:
```c
// 50MHz = 50,000,000 cycles/second
// 1ms = 50,000 cycles (approximate)
void delay_ms(uint32_t ms) {
    volatile uint32_t count;
    for (count = 0; count < ms * 50000; count++);
}
```

## Comparison with Zephyr

| Aspect | Bare-metal | Zephyr RTOS |
|--------|------------|-------------|
| Code size | 1-5 KB | 20-50 KB |
| RAM usage | Minimal | 2-4 KB base |
| Scheduling | Manual | Preemptive |
| Drivers | Custom | Provided |
| Debugging | Limited | Advanced |
| Use case | Learning, minimal | Complex apps |

## Testing

### Automated Tests

Bare-metal tests are part of the digital twin test suite:

| Test | Firmware | Validates |
|------|----------|-----------|
| 1 | Base Platform | CPU + RAM functionality |
| 2 | pwm_test.c | PWM register co-sim |

### Running Tests

```bash
# All tests
task dt-integration-test

# Or manually
docker exec elemrv-gui renode --disable-xwt \
  -e "include @run_pwm_test.resc"
```

## Debugging Tips

### Use Assertions

```c
#include <stdint.h>

#define assert(x) \
    do { \
        if (!(x)) { \
            *(volatile uint32_t *)ERROR_REG = __LINE__; \
            while (1); \
        } \
    } while (0)

void configure_pwm(void) {
    assert(REG32(PWM_BASE + PWM_IP_HEADER_OFFSET) == PWM_EXPECTED_HEADER);
    // ...
}
```

### Memory Dump

```c
void dump_memory(uint32_t addr, uint32_t len) {
    for (uint32_t i = 0; i < len; i += 4) {
        uint32_t val = *(volatile uint32_t *)(addr + i);
        // Output via UART
        uart_hex32(val);
        uart_puts("\r\n");
    }
}
```

---

**Previous**: [Zephyr Setup](zephyr-setup.md)  
**Next**: [Test Suite](../reference/test-suite.md)
