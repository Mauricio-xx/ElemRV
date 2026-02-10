# Sensor Simulation

The ElemRV Digital Twin provides simulated sensor models for IoT application development and testing. Both I2C and SPI sensors are supported.

## I2C Sensor Simulation

### Overview

Both ElemRV-H and ElemRV-N platforms include a simulated SI7021 temperature and humidity sensor connected to the I2C0 bus.

**Sensor Model**: Renode's built-in `Sensors.SI70xx`
**I2C Address**: 0x48
**Protocol**: SI7021 (compatible)

### Architecture

```
I2C Sensor Setup
================

Firmware                    Renode                      Sensor Model
--------                    ------                      ------------
  |                            |                               |
  | i2c_write_read()           |                               |
  | (Zephyr API)               |                               |
  v                            v                               |
+--------+               +-----------+                         |
| Zephyr |               | LiteX I2C |                         |
| Driver |-------------->| Controller|<------------------------|
+--------+               +-----------+                         |
  |                            |                               |
  |                            | I2C transactions              |
  |                            v                               |
  |                      +-----------+                   +---------+
  |                      | I2C Bus   |<----------------->| SI70xx  |
  |                      | Model     |                   | Model   |
  |                      +-----------+                   +---------+
  |                            |                               |
  v                            v                               v
```

### Firmware Access

**Zephyr API**:
```c
#include <zephyr/drivers/i2c.h>

static const struct device *i2c_dev = DEVICE_DT_GET(DT_NODELABEL(i2c0));

// Read temperature
uint8_t cmd = 0xE3;  // Temperature command
uint8_t data[2];
i2c_write_read(i2c_dev, 0x48, &cmd, 1, data, 2);

// Convert raw to Celsius
uint16_t raw = (data[0] << 8) | data[1];
float temp = (175.72 * raw / 65536.0) - 46.85;
```

**Protocol**:
1. Write command byte (0xE3 for temp, 0xE5 for humidity)
2. Read 2 bytes (MSB first)
3. Apply conversion formula

### Dynamic Value Changes

Sensor values can be changed mid-simulation:

```renode
# In Renode monitor
i2c0.sensor Temperature 25.0
i2c0.sensor Humidity 60.0
```

**Example Test Script**:
```renode
# Start simulation
emulation RunFor "00:00:01.500000"

# Change temperature
i2c0.sensor Temperature 28.0

# Continue simulation
emulation RunFor "00:00:02.000000"
```

This tests firmware's ability to handle changing environmental conditions.

### Platform Files

| File | Board | Description |
|------|-------|-------------|
| `elemrv_h_i2c_sensor.repl` | H | H platform + SI70xx @ i2c0 |
| `elemrv_n_i2c_sensor.repl` | N | N platform + SI70xx @ i2c0 |

### Example Application

**Application**: `software/elemrv-zephyr/app/sensor_capture/`

**Functionality**:
- Reads 10 temperature samples at 200ms intervals
- Converts raw values to Celsius
- Reports pass/fail based on expected ranges

**Build**:
```bash
cd software/elemrv-zephyr
west build -b elemrv_h app/sensor_capture -d build-sensor-capture
```

**Test**:
```bash
task dt-sensor-test
```

**Expected Output**:
```
Sensor Capture Test
Sensor: SI7021 @ I2C 0x48
Samples: 10, interval: 200 ms
Sample 1: raw=0x6724 temp=22.00 C
Sample 2: raw=0x6724 temp=22.00 C
...
Capture complete: 10/10 samples OK
Sensor Capture Test PASSED
```

## SPI Sensor Simulation

### Overview

ElemRV-N includes an embedded SPI sensor slave within the SPI controller co-simulation wrapper. This allows testing SPI communication without external models.

### Architecture

```
SPI Sensor Setup (ElemRV-N)
============================

Zephyr                      nafarr Driver               RTL Wrapper
------                      -------------               -----------
  |                               |                            |
  | spi_transceive()              |                            |
  | (Zephyr API)                  |                            |
  v                               v                            |
+--------+                   +--------+                       |
| Zephyr |                   | Custom |                       |
| SPI    |------------------>| nafarr |                       |
| Driver |                   | Driver |                       |
+--------+                   +--------+                       |
  |                               |                            |
  |                               | Register writes            |
  |                               v                            |
  |                          +--------+                       |
  |                          | CMD    |                       |
  |                          | FIFO   |                       |
  |                          +--------+                       |
  |                               |                            |
  v                               v                            v
+--------+                   +--------+                  +-----------+
| Wishbone                   | SPI    |                  | Embedded  |
| Bus                        | RTL    |----------------->| Sensor    |
|                            |        |  SPI signals     | State Mchn|
+--------+                   +--------+                  +-----------+
```

### Custom SPI Driver

**Driver**: `drivers/spi/spi_nafarr.c`

Implements Zephyr's `spi_driver_api` for the nafarr WishboneSpiController command-FIFO interface.

**Command Format** (32-bit writes to register 0x050):
```
[29:28] = Mode
  00 = DATA
  01 = CS
  10 = DUMMY

DATA Mode [24] = Read flag (1=read, 0=write)
          [7:0] = Data byte

CS Mode   [24] = Enable (1=assert, 0=deassert)
          [3:0] = Chip select index
```

**Response**: Read from 0x050
```
[31] = Valid bit (1=data valid)
[7:0] = Data byte
```

### Embedded Sensor Register Map

The sensor state machine implements:

| Register | Address | Access | Value |
|----------|---------|--------|-------|
| Device ID | 0x00 | R | 0xCD |
| Temperature | 0x01 | R | Cycles: 20,21,22,23,24,23,22,21... |
| Pressure | 0x02 | R | Cycles: 45,47,50,52,55,53,50,48... |

### SPI Protocol

```
SPI Transaction
===============

1. Assert CS (active-low)
   CMD FIFO: CS mode, enable=1
   
2. Send register address (1 byte)
   CMD FIFO: DATA mode, write, data=addr
   
3. Read data bytes (auto-increment)
   CMD FIFO: DATA mode, read
   
4. Deassert CS (advances sample index)
   CMD FIFO: CS mode, enable=0
```

### Platform File

**File**: `elemrv_n_spi_sensor.repl`

N Zephyr platform with co-simulated SPI controller including embedded sensor.

### Building

```bash
# Rebuild SPI library with embedded sensor
cd renode/verilated/wrappers
make -f Makefile.spi BUILD_MODE=release

# Build Zephyr application
cd software/elemrv-zephyr
west build -b elemrv_n app/sensor_spi_capture -d build-n-sensor-spi-capture
```

## Portable Data Logger

A multi-threaded Zephyr application demonstrating sensor data logging on both platforms with zero board-specific `#ifdef` directives.

### Architecture

```
Data Logger Application
=======================

Main Thread
-----------
Initialize I2C sensor
Create worker threads
Wait for completion

Sensor Thread (Prio 5)
----------------------
Every 200ms:
  Read temperature
  Read humidity
  Store in shared buffer

Reporter Thread (Prio 6)
------------------------
Every 500ms:
  Read shared buffer
  Print with timestamp
  Toggle LED heartbeat
  Every 5th cycle:
    Print thread analyzer report
```

### Thread Configuration

| Thread | Stack | Priority | Function |
|--------|-------|----------|----------|
| main | default | 0 | Initialization |
| sensor_thread | 384B | 5 | Sensor reading |
| reporter_thread | 384B | 6 | Data reporting |

### Features

- I2C sensor reads (SI7021)
- GPIO LED toggle (`DT_ALIAS(led0)`)
- UART output with timestamps
- Thread analyzer reporting

### Board Support

**ElemRV-H**:
- Uses `elemrv_h_i2c_sensor.repl`
- Full thread analyzer auto-mode possible

**ElemRV-N**:
- Uses `elemrv_n_i2c_sensor.repl`
- On-demand thread analyzer only (RAM constraints)

### Build and Run

```bash
# Build for H
cd software/elemrv-zephyr
west build -b elemrv_h app/portable_data_logger

# Build for N
west build -b elemrv_n app/portable_data_logger

# Run tests
task dt-portable-test
```

### Expected Output

```
[    0.000] Data Logger Starting
[    0.500] Temp: 22.00C, Humidity: 55.00%
[    1.000] Temp: 22.00C, Humidity: 55.00%
[    1.500] Temp: 22.00C, Humidity: 55.00%
[    2.000] Temp: 22.00C, Humidity: 55.00%
[    2.500] Temp: 22.00C, Humidity: 55.00%
Thread Analyzer:
  main: stack 512/512 (100%)
  sensor_thread: stack 96/384 (25%)
  reporter_thread: stack 88/384 (23%)
[    3.000] Temp: 22.00C, Humidity: 55.00%
...
```

## Test Coverage

| Test | Name | Platform | Validates |
|------|------|----------|-----------|
| 29 | Sensor Detection | H | I2C scan finds SI7021 @ 0x40 |
| 30 | Sensor Capture | H | Dynamic temperature changes |
| 47 | I2C Sensor (H) | H | I2C sensor simulation |
| 48 | I2C Sensor (N) | N | I2C sensor simulation |
| 49 | SPI Sensor | N | SPI sensor with custom driver |
| 50 | Portable Logger (H) | H | Multi-thread sensor logging |
| 51 | Portable Logger (N) | N | Multi-thread sensor logging |

## Sensor Simulation Use Cases

### IoT Application Testing

Test sensor-to-cloud data pipelines:
```c
// Read sensor
read_sensor(&temp, &humidity);

// Process data
process_reading(temp, humidity);

// Send over network
send_to_cloud(buffer);
```

### Data Validation

Verify firmware handles sensor data correctly:
```c
// Range checking
if (temp < -40.0 || temp > 125.0) {
    LOG_ERR("Invalid temperature: %f", temp);
    return -EINVAL;
}
```

### Dynamic Testing

Test response to changing conditions:
```renode
# Simulate sensor warming up
emulation RunFor "00:00:05.000000"
i2c0.sensor Temperature 30.0
emulation RunFor "00:00:05.000000"
i2c0.sensor Temperature 35.0
```

### Error Handling

Test firmware resilience:
```c
// CRC validation
if (!validate_crc(data, crc)) {
    // Retry or error
}
```

## Extending Sensor Models

### Custom I2C Sensor

Create a new Renode peripheral model:

```csharp
// CustomI2CSensor.cs
public class CustomI2CSensor : II2CPeripheral
{
    public byte[] Read(int count)
    {
        // Return sensor data
    }
    
    public void Write(byte[] data)
    {
        // Handle commands
    }
}
```

### Custom SPI Sensor

Extend the embedded sensor in wrapper:

```cpp
// In spi_wrapper.cpp
void sensor_state_machine() {
    switch (reg_addr) {
        case 0x00: return device_id;
        case 0x01: return temperature;
        case 0x02: return pressure;
        case 0x03: return custom_value;  // New register
    }
}
```

---

**Previous**: [Co-simulation](co-simulation.md)  
**Next**: [RTOS Debugging](rtos-debugging.md)
