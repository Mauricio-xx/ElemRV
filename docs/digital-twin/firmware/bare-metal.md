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
├── pwm_test/
│   ├── main.c
│   ├── pwm.h
│   └── Makefile
├── gpio_test/
│   ├── main.c
│   └── Makefile
├── uart_test/
│   ├── main.c
│   └── Makefile
└── timer_test/
    ├── main.c
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
// pwm.h
#ifndef PWM_H
#define PWM_H

#define PWM_BASE        0xF0003000

#define PWM_ENABLE      (PWM_BASE + 0x00)
#define PWM_PRESCALER   (PWM_BASE + 0x04)
#define PWM_PERIOD      (PWM_BASE + 0x08)
#define PWM_DUTY_CH0    (PWM_BASE + 0x0C)
#define PWM_DUTY_CH1    (PWM_BASE + 0x10)
#define PWM_CTRL_CH0    (PWM_BASE + 0x14)
#define PWM_CTRL_CH1    (PWM_BASE + 0x18)

#define PWM_IP_HEADER   0x00000001

static inline void pwm_write(uint32_t reg, uint32_t value) {
    *(volatile uint32_t *)reg = value;
}

static inline uint32_t pwm_read(uint32_t reg) {
    return *(volatile uint32_t *)reg;
}

#endif
```

### Main Application

```c
// main.c
#include "pwm.h"
#include <stdint.h>

// Simple delay loop
void delay_ms(uint32_t ms) {
    volatile uint32_t count;
    // Calibrated for 50MHz
    for (count = 0; count < ms * 5000; count++);
}

int main(void) {
    // Verify PWM present
    uint32_t header = pwm_read(PWM_ENABLE);
    if (header != PWM_IP_HEADER) {
        // PWM not found
        return -1;
    }
    
    // Configure PWM for 1kHz, 50% duty
    pwm_write(PWM_PRESCALER, 49);     // 50MHz / 50 = 1MHz
    pwm_write(PWM_PERIOD, 999);       // 1MHz / 1000 = 1kHz
    pwm_write(PWM_DUTY_CH0, 499);     // 50% duty cycle
    pwm_write(PWM_CTRL_CH0, 1);       // Enable channel 0
    pwm_write(PWM_ENABLE, 1);         // Enable PWM
    
    // Main loop
    while (1) {
        // Toggle duty cycle between 25% and 75%
        pwm_write(PWM_DUTY_CH0, 249);
        delay_ms(500);
        
        pwm_write(PWM_DUTY_CH0, 749);
        delay_ms(500);
    }
    
    return 0;
}
```

### Makefile

```makefile
# Makefile
CC = riscv-none-elf-gcc
OBJCOPY = riscv-none-elf-objcopy
CFLAGS = -march=rv32ic -mabi=ilp32 -O2 -Wall
LDFLAGS = -T linker_script.ld -nostdlib -nostartfiles

TARGET = pwm_test

all: $(TARGET).bin

$(TARGET).elf: main.c
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^

$(TARGET).bin: $(TARGET).elf
	$(OBJCOPY) -O binary $< $@

clean:
	rm -f $(TARGET).elf $(TARGET).bin

.PHONY: all clean
```

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
// gpio_test.c
#include <stdint.h>

#define GPIO_BASE       0xF0000000
#define GPIO_READ       (GPIO_BASE + 0x04)
#define GPIO_WRITE      (GPIO_BASE + 0x08)
#define GPIO_DIR        (GPIO_BASE + 0x0C)

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
    uint32_t val = *(volatile uint32_t *)GPIO_READ;
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

```c
// uart_test.c
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
/* linker_script.ld */

MEMORY {
    RAM (rwx) : ORIGIN = 0x80000000, LENGTH = 8K
    FLASH (rx) : ORIGIN = 0xA0000000, LENGTH = 64K
}

SECTIONS {
    .text : {
        *(.text*)
        *(.rodata*)
    } > FLASH
    
    .data : {
        *(.data*)
    } > RAM AT > FLASH
    
    .bss : {
        *(.bss*)
    } > RAM
    
    __stack_top = 0x80002000;
}
```

## Running in Digital Twin

### Test Script

```renode
// test_bare_metal.resc
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
#define PWM_HEADER_EXPECTED 0x00000001

uint32_t header = pwm_read(PWM_ENABLE);
if (header != PWM_HEADER_EXPECTED) {
    // Handle error
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
| PWM | pwm_test.c | PWM register access |
| GPIO | gpio_test.c | GPIO read/write |
| UART | uart_test.c | UART communication |
| Timer | timer_test.c | Timer interrupts |

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
    assert(pwm_read(PWM_ENABLE) == PWM_HEADER);
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
