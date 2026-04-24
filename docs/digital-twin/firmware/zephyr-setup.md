# Zephyr Setup Guide

This guide covers setting up and using Zephyr RTOS on the ElemRV Digital Twin platform.

## Overview

The ElemRV Digital Twin supports Zephyr RTOS for both ElemRV-H and ElemRV-N platforms, with full BSP (Board Support Package) integration.

## Architecture

```
Zephyr on ElemRV
================

Zephyr RTOS
-----------
Kernel
├── Scheduling
├── Interrupts
├── Timers
└── Threads

Drivers
├── UART (nafarr)
├── GPIO (nafarr)
├── I2C (nafarr)
├── SPI (nafarr, N only)
├── PWM (nafarr)
└── Timer (Machine Timer)

Board Support
├── SoC Definition
├── Device Tree
└── Pin Mux Config

Applications
├── hello_world
├── blinky
├── i2c_scan
├── pwm_test
├── pio_test
├── pinmux_test
├── timer_uart_test
├── rtos_debug_demo
├── rtos_diagnostics
├── sensor_capture
├── sensor_i2c_capture
├── portable_data_logger
└── ... (15 total for H, 7 for N)
```

## Board Support Package

### ElemRV-H (Hydrogen)

**Board**: `elemrv_h`

**SoC**: `elemrv_vexriscv`
- ISA: RV32IC
- Clock: 50 MHz
- RAM: 8 KB
- Flash: 64 KB

**Device Tree**: `riscv32-elemrv-vexriscv.dtsi`

### ElemRV-N (Nitrogen)

**Board**: `elemrv_n`

**SoC**: `elemrv_n_vexriscv`
- ISA: RV32IMC (adds M extension)
- Clock: 30 MHz peripheral / 60 MHz input
- RAM: 4 KB
- Flash: 64 KB
- HyperRAM: 64 MB

**Device Tree**: `riscv32-elemrv-n-vexriscv.dtsi`

## Initial Setup

### Initialize West Workspace

```bash
# Initialize west (run once)
task dt-zephyr-init

# Or manually:
cd software
west init -l elemrv-zephyr 2>/dev/null || true
west update
```

This fetches:
- Zephyr kernel
- HAL modules
- Required dependencies

### Verify Setup

```bash
# Check west installation
west --version

# List available boards
west boards | grep elemrv

# Expected output:
# elemrv_h
# elemrv_n
```

## Building Applications

### Build for ElemRV-H

```bash
cd software/elemrv-zephyr

# hello_world
west build -b elemrv_h app/hello_world -d build-hello

# blinky
west build -b elemrv_h app/blinky -d build-blinky

# RTOS debug demo
west build -b elemrv_h app/rtos_debug_demo -d build-rtos-debug
```

### Build for ElemRV-N

```bash
cd software/elemrv-zephyr

# hello_world
west build -b elemrv_n app/hello_world -d build-n-hello

# blinky
west build -b elemrv_n app/blinky -d build-n-blinky

# sensor_spi_capture (N only)
west build -b elemrv_n app/sensor_spi_capture -d build-n-sensor-spi
```

### Build All Applications

```bash
# Build all H apps
task dt-zephyr-build

# Build all N apps
task dt-n-zephyr-build
```

## Boot Configuration

### XIP (Execute In Place)

Both platforms use XIP from Flash:

```
Memory Layout:
==============

0xA0000000 - 0xA000FFFF  Flash (64 KB)
  └── Code executes directly from Flash
  
0x80000000 - 0x80001FFF  SRAM (H: 8KB, N: 4KB)
  └── Data (.data, .bss, stack, heap)
```

**Benefits**:
- More code space (64KB vs 4-8KB)
- No need to copy code to RAM

**Constraints**:
- Code runs slower from Flash
- Limited RAM for data/stack

### Stack Configuration

**ElemRV-H (8KB RAM)**:
```
CONFIG_MAIN_STACK_SIZE=1024
CONFIG_IDLE_STACK_SIZE=256
CONFIG_ISR_STACK_SIZE=2048
```

**ElemRV-N (4KB RAM)**:
```
CONFIG_MAIN_STACK_SIZE=512
CONFIG_IDLE_STACK_SIZE=256
CONFIG_ISR_STACK_SIZE=512
```

### Device Tree Configuration

Example peripherals in DTS:

```dts
// UART0
&uart0 {
    status = "okay";
    current-speed = <115200>;
};

// I2C0
&i2c0 {
    status = "okay";
    clock-frequency = <I2C_BITRATE_STANDARD>;
};

// PWM0
&pwm0 {
    status = "okay";
};

// GPIO
&gpio0 {
    status = "okay";
    ngpios = <12>;  // H: 12, N: 20
};
```

## Available Drivers

### UART

```c
#include <zephyr/drivers/uart.h>

static const struct device *uart_dev = DEVICE_DT_GET(DT_NODELABEL(uart0));

// Check ready
if (!device_is_ready(uart_dev)) {
    printk("UART not ready\n");
    return;
}

// Send data
uart_poll_out(uart_dev, 'A');
```

### GPIO

```c
#include <zephyr/drivers/gpio.h>

static const struct gpio_dt_spec led = GPIO_DT_SPEC_GET(DT_ALIAS(led0), gpios);

// Configure
gpio_pin_configure_dt(&led, GPIO_OUTPUT_ACTIVE);

// Toggle
gpio_pin_toggle_dt(&led);
```

### I2C

```c
#include <zephyr/drivers/i2c.h>

static const struct device *i2c_dev = DEVICE_DT_GET(DT_NODELABEL(i2c0));

// Write then read
uint8_t cmd = 0xE3;
uint8_t data[2];
i2c_write_read(i2c_dev, 0x48, &cmd, 1, data, 2);
```

### PWM

```c
#include <zephyr/drivers/pwm.h>

static const struct pwm_dt_spec pwm_led = PWM_DT_SPEC_GET(DT_ALIAS(pwm_led0));

// Set duty cycle
pwm_set_dt(&pwm_led, 1000, 500);  // period=1000, pulse=500 (50%)
```

### SPI (ElemRV-N only)

```c
#include <zephyr/drivers/spi.h>

static const struct device *spi_dev = DEVICE_DT_GET(DT_NODELABEL(spi0));

// Configure
transfer.tx_buf = &tx_buf;
transfer.rx_buf = &rx_buf;
transfer.len = 1;
spi_transceive(spi_dev, &spi_cfg, &transfer);
```

## Example Applications

### Hello World

Basic console output:

```c
#include <zephyr/kernel.h>

void main(void) {
    printk("Hello World from ElemRV!\n");
}
```

**Build**:
```bash
west build -b elemrv_h app/hello_world
```

### Blinky

LED toggle with timer:

```c
#include <zephyr/drivers/gpio.h>
#include <zephyr/kernel.h>

static const struct gpio_dt_spec led = GPIO_DT_SPEC_GET(DT_ALIAS(led0), gpios);

void main(void) {
    gpio_pin_configure_dt(&led, GPIO_OUTPUT);
    
    while (1) {
        gpio_pin_toggle_dt(&led);
        k_sleep(K_MSEC(500));
    }
}
```

### Multi-thread Demo

RTOS debugging demo with threads:

```c
#include <zephyr/kernel.h>

#define STACK_SIZE 256
#define PRIORITY 5

K_THREAD_STACK_DEFINE(sensor_stack, STACK_SIZE);
struct k_thread sensor_thread_data;

void sensor_thread(void *p1, void *p2, void *p3) {
    while (1) {
        // Read sensor
        k_sleep(K_MSEC(200));
    }
}

void main(void) {
    k_thread_create(&sensor_thread_data, sensor_stack,
                    K_THREAD_STACK_SIZEOF(sensor_stack),
                    sensor_thread, NULL, NULL, NULL,
                    PRIORITY, 0, K_NO_WAIT);
    
    while (1) {
        k_sleep(K_MSEC(1000));
    }
}
```

## Testing

### Run in Digital Twin

```bash
# Start Renode with Zephyr platform
task dt-debug-zephyr

# Or manually
cd renode
renode --disable-xwt --console -e "include @debug_zephyr.resc"
```

### Automated Tests

```bash
# Run Zephyr tests (see reference/test-suite.md for test numbering)
task dt-integration-test
```

### Interactive Debugging

```bash
# Terminal 1: Start GDB server
task dt-debug-zephyr

# Terminal 2: Connect GDB
task dt-debug-connect ELF=build/zephyr/zephyr.elf
```

## Configuration Options

### Kconfig Settings

**Essential for all apps**:
```
CONFIG_CONSOLE=y
CONFIG_UART_CONSOLE=y
CONFIG_SERIAL=y
```

**For multi-threading**:
```
CONFIG_MULTITHREADING=y
CONFIG_MAIN_STACK_SIZE=1024
```

**For debugging**:
```
CONFIG_DEBUG=y
CONFIG_DEBUG_THREAD_INFO=y
CONFIG_THREAD_NAME=y
```

**For minimal size (ElemRV-N)**:
```
CONFIG_SIZE_OPTIMIZATIONS=y
CONFIG_MAIN_STACK_SIZE=512
CONFIG_IDLE_STACK_SIZE=256
```

### prj.conf Templates

**ElemRV-H template**:
```ini
# Console
CONFIG_CONSOLE=y
CONFIG_UART_CONSOLE=y
CONFIG_SERIAL=y

# Kernel
CONFIG_MULTITHREADING=y
CONFIG_MAIN_STACK_SIZE=1024
CONFIG_HEAP_MEM_POOL_SIZE=256

# Debugging
CONFIG_THREAD_NAME=y
CONFIG_THREAD_STACK_INFO=y
```

**ElemRV-N template**:
```ini
# Console
CONFIG_CONSOLE=y
CONFIG_UART_CONSOLE=y
CONFIG_SERIAL=y

# Kernel (reduced for 4KB RAM)
CONFIG_MULTITHREADING=y
CONFIG_MAIN_STACK_SIZE=512
CONFIG_IDLE_STACK_SIZE=256
CONFIG_ISR_STACK_SIZE=512
CONFIG_HEAP_MEM_POOL_SIZE=128

# Size optimization
CONFIG_SIZE_OPTIMIZATIONS=y
```

## Troubleshooting

### Build Failures

```bash
# Clean build directory
rm -rf build

# Rebuild from scratch
west build -b elemrv_h app/hello_world -p always
```

### RAM Overflow

**Error**: `region 'RAM' overflowed`

**Solutions**:
1. Reduce stack sizes
2. Disable unused features
3. Use `CONFIG_SIZE_OPTIMIZATIONS=y`
4. Move data to Flash (const)

### UART No Output

**Check**:
1. Device tree has `status = "okay"`
2. Baud rate matches platform (115200)
3. Correct UART instance in DTS

### Device Not Ready

```c
if (!device_is_ready(dev)) {
    printk("Device not ready\n");
    return -ENODEV;
}
```

**Causes**:
- Missing device tree entry
- Driver not enabled in config
- Hardware not present

## Advanced Topics

### Custom Board Configuration

Create custom board in `elemrv-zephyr/boards/`:

```
boards/
├── my_custom_board/
│   ├── board.cmake
│   ├── Kconfig.board
│   ├── Kconfig.defconfig
│   └── my_custom_board.dts
```

### Custom Driver

Example: SPI driver for nafarr controller:

```c
// drivers/spi/spi_nafarr.c

static int spi_nafarr_init(const struct device *dev) {
    // Initialize controller
}

static int spi_nafarr_transceive(const struct device *dev,
                                  const struct spi_config *config,
                                  const struct spi_buf_set *tx_bufs,
                                  const struct spi_buf_set *rx_bufs) {
    // Perform transfer
}

static const struct spi_driver_api spi_nafarr_api = {
    .transceive = spi_nafarr_transceive,
};

DEVICE_DT_INST_DEFINE(0, spi_nafarr_init, NULL,
                      NULL, NULL, POST_KERNEL,
                      CONFIG_SPI_INIT_PRIORITY,
                      &spi_nafarr_api);
```

---

**Previous**: [Fault Injection](../features/fault-injection.md)  
**Next**: [Bare-metal Firmware](bare-metal.md)
