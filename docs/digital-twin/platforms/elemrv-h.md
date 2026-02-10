# ElemRV-H (Hydrogen) Platform

ElemRV-H is the ASIC-focused platform variant with 8KB SRAM, running at 50MHz with the RV32IC instruction set.

## Specifications

| Feature | Specification |
|---------|--------------|
| ISA | RV32IC (Integer + Compressed) |
| Clock | 50 MHz |
| SRAM | 8 KB |
| Flash | 64 KB |
| GPIO | 12 pins |
| Pinmux | 12 pins |

## Memory Map

| Address Range | Size | Peripheral | Implementation |
|--------------|------|-----------|----------------|
| 0x80000000 | 8 KB | SRAM | Physical memory |
| 0xA0000000 | 64 KB | Flash | XIP execution |
| 0xF0000000 | 4 KB | GPIO0 | Co-simulation RTL |
| 0xF0001000 | 4 KB | I2C0 | Co-simulation RTL |
| 0xF0002000 | 4 KB | PIO0 | Co-simulation RTL |
| 0xF0003000 | 4 KB | PWM0 | Co-simulation RTL |
| 0xF0004000 | 4 KB | UART0 | Co-simulation RTL |
| 0xF0005000 | 4 KB | Timer0 | Co-simulation RTL |
| 0xF0010000 | 4 KB | Pinmux | Co-simulation RTL |

## Peripherals

### GPIO0 (General Purpose I/O)

12-pin GPIO controller with configurable direction and interrupt support.

**Features**:
- 12 independently configurable pins
- Input, output, and bidirectional modes
- Rising/falling edge interrupts
- Pin-level read/write

**Register Map**:
```
0x00 - IP Header (0x00000001)
0x04 - GPIO read value (RO)
0x08 - GPIO write value (WO)
0x0C - Write enable (direction: 1=output)
```

**Example Usage**:
```c
// Configure pin 0 as output
*(volatile uint32_t*)0xF000000C = 0x1;

// Set pin 0 high
*(volatile uint32_t*)0xF0000008 = 0x1;
```

### I2C0 Controller

Full-featured I2C master controller.

**Features**:
- Master mode operation
- Configurable clock frequency (100kHz, 400kHz)
- 7-bit and 10-bit addressing
- Interrupt support

**Register Map**:
```
0x00 - IP Header
0x04 - Clock prescaler
0x08 - Control (start, stop, ack)
0x0C - Transmit data
0x10 - Receive data
0x14 - Status
0x18 - Command
```

### PIO0 (Programmable I/O)

3-pin programmable state machine for custom protocols.

**Features**:
- 3 GPIO pins with programmable direction
- State machine with 32 instructions
- FIFO for data transfer
- Input/output shift registers

**Use Cases**:
- Custom serial protocols
- Bit-banged interfaces
- Precise timing control

### PWM0 (Pulse Width Modulation)

2-channel PWM controller for motor control and LED dimming.

**Features**:
- 2 independent channels
- 20-bit prescaler
- 20-bit period and duty cycle
- Output enable control

**Register Map**:
```
0x00 - Enable (bits 0-1: channel enables)
0x04 - Clock prescaler
0x08 - Period (20-bit)
0x0C - Channel 0 duty
0x10 - Channel 1 duty
0x14 - Channel 0 control
0x18 - Channel 1 control
```

**Example Configuration**:
```c
// 50% duty cycle at 1kHz (50MHz clock)
*(volatile uint32_t*)0xF0003004 = 0x31;  // Prescaler: 49
*(volatile uint32_t*)0xF0003008 = 0x3E7; // Period: 999
*(volatile uint32_t*)0xF000300C = 0x1F3; // Duty: 499
*(volatile uint32_t*)0xF0003000 = 0x1;   // Enable
```

### UART0

Full-featured UART controller.

**Features**:
- Configurable baud rate
- 8N1, 8N2 framing
- Hardware flow control (RTS/CTS)
- TX and RX FIFOs
- Interrupt support

**Register Map**:
```
0x00 - IP Header
0x04 - Clock divider
0x08 - Frame configuration
0x0C - Status
0x10 - TX data
0x14 - RX data
```

### Timer0

Machine timer (mtime/mtimecmp) for RTOS scheduling.

**Features**:
- 64-bit free-running counter
- Configurable compare value
- Periodic interrupt generation
- RISC-V standard MTIME interface

### Pinmux

Pin multiplexing controller for peripheral routing.

**Features**:
- 12 configurable pins
- Map peripherals to physical pins
- Software-controlled routing
- GPIO fallback mode

## Building for ElemRV-H

### Generate RTL

```bash
# Generate all H peripheral Verilog
task dt-cosim-generate

# Or individually:
docker exec -w /workspace/elemrv elemrv-gui sbt "runMain elemrv_h.test.WishbonePwmVerilog"
docker exec -w /workspace/elemrv elemrv-gui sbt "runMain elemrv_h.test.WishboneGpioVerilog"
# ... etc
```

### Build Co-simulation Libraries

```bash
# Build all 7 co-simulation libraries
task dt-cosim-build

# Or manually:
cd renode/verilated/wrappers
bash build_all_cosim.sh release
```

Output libraries:
- `libpwm.so` - PWM controller
- `libgpio.so` - GPIO
- `libi2c.so` - I2C
- `libuart.so` - UART
- `libpio.so` - PIO
- `libpinmux.so` - Pinmux
- `libmtimer.so` - Timer

### Build Zephyr Applications

```bash
# Build all H Zephyr apps
task dt-zephyr-build
```

## Testing

### Run H Test Suite

```bash
# Full test (generates, builds, tests)
task dt-integration-test

# Quick run (assumes artifacts exist)
task dt-test-quick
```

### Individual Tests

Tests 1-30 cover ElemRV-H:

| Test | Name | Description |
|------|------|-------------|
| 1 | Base Platform | CPU + RAM functionality |
| 2 | PWM Co-simulation | PWM RTL integration |
| 3 | GPIO Co-simulation | GPIO RTL integration |
| 4 | UART Co-simulation | UART RTL integration |
| 5 | I2C Co-simulation | I2C RTL integration |
| 6 | Timer Co-simulation | Timer RTL integration |
| 7 | PIO Co-simulation | PIO RTL integration |
| 8 | Pinmux Co-simulation | Pinmux RTL integration |
| 9 | Full Co-simulation | All 7 peripherals |
| 10 | Pure Verilator Testbenches | RTL validation |
| 11-30 | Zephyr applications | RTOS functionality |

## Platform Files

| File | Purpose |
|------|---------|
| `elemrv_h.repl` | Base platform (LiteX models) |
| `elemrv_h_zephyr.repl` | Zephyr support (MachineTimer) |
| `elemrv_h_cosim_*.repl` | Individual co-sim platforms |
| `elemrv_h_full_cosim.repl` | All 7 peripherals co-sim |
| `elemrv_h_sensor.repl` | With I2C sensor model |

## Debug Configuration

### GDB Debugging

```bash
# Start GDB server with co-simulation
task dt-debug-cosim

# Connect GDB (another terminal)
task dt-debug-connect ELF=software/elemrv_h/pwm_test/pwm_test.elf
```

Available commands:
- `pwm-regs` - Dump PWM registers
- `gpio-regs` - Dump GPIO registers
- `periph-scan` - Read all IP headers

### Renode Monitor

```bash
# Interactive session
renode --disable-xwt
(monitor) include @platforms/elemrv_h_full_cosim.repl
(monitor) sysbus LoadBinary @firmware.bin 0xA0000000
(monitor) cpu PC 0xA0000000
(monitor) start
```

## Known Limitations

1. **8KB RAM**: Limited for complex Zephyr configurations
2. **No HyperRAM**: Only internal SRAM and Flash
3. **Single I2C**: One I2C controller (vs two on ElemRV-N)
4. **No SPI**: SPI not available on H platform

## Applications

### Bare-metal Examples

Located in `software/elemrv_h/`:

- `pwm_test/` - PWM register testing
- `gpio_test/` - GPIO input/output
- `uart_test/` - UART communication
- `timer_test/` - Timer interrupts

### Zephyr Examples

Located in `software/elemrv-zephyr/app/`:

- `hello_world/` - Basic console output
- `blinky/` - GPIO LED toggle
- `rtos_debug_demo/` - Multi-threading demo
- `sensor_capture/` - I2C sensor reading

## Use Cases

ElemRV-H is ideal for:

- **ASIC Prototyping**: Verify RTL before tape-out
- **Driver Development**: Test peripheral drivers
- **RTOS Integration**: Zephyr RTOS validation
- **Education**: Learn RISC-V with full visibility
- **CI/CD**: Automated regression testing

---

**Previous**: [Architecture](architecture.md)  
**Next**: [ElemRV-N Platform](platforms/elemrv-n.md)
