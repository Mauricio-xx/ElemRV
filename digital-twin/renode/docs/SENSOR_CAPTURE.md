# I2C Sensor Capture — IoT Data Acquisition Demo

## Overview

Demonstrates a basic IoT data capture flow on ElemRV-H:
a simulated SI7021 temperature/humidity sensor attached to the I2C bus,
read periodically by Zephyr firmware, with samples reported via UART.

```
  +----------+     I2C      +-----------+     UART     +----------+
  |  SI7021  | <----------> | ElemRV-H  | -----------> |  Console |
  | (sensor) |   addr 0x40  | VexRiscv  |              |  output  |
  +----------+              +-----------+              +----------+
       ^                         ^
       |                         |
  Renode sets              Zephyr firmware
  Temperature              reads 10 samples
  dynamically              @ 200ms interval
```

## Sensor Model

- **Renode model**: `Sensors.SI70xx` (built-in, no custom code)
- **Variant**: SI7021 (temperature + humidity)
- **I2C address**: 0x40
- **Configurable properties**: `Temperature`, `Humidity`
- **Protocol**: Write command byte (0xE3) -> Read 2 bytes (MSB first)

## Firmware

**App**: `software/elemrv-zephyr/app/sensor_capture/`

- Uses raw Zephyr I2C API (`i2c_write_read()`)
- Reads 10 temperature samples at 200ms intervals
- Converts raw values to Celsius: `T = (175.72 * raw / 65536) - 46.85`
- Prints each sample and a final pass/fail summary

**Build**:
```bash
cd software/elemrv-zephyr
west build -b elemrv_h app/sensor_capture -d build-sensor-capture
```

## Renode Tests

### Test 29: Sensor Detection

Runs the existing `i2c_scan` firmware on the sensor platform.
Verifies the SI7021 is visible at address 0x40 on the I2C bus.

**Script**: `renode/run_sensor_detect.resc`

### Test 30: Sensor Capture

Runs `sensor_capture` firmware with dynamic temperature changes:
1. Phase 1: Sensor temperature set to 22.0 C (first ~5 samples)
2. Phase 2: Temperature changed to 28.0 C (remaining ~5 samples)

The firmware reads all 10 samples and reports pass/fail.

**Script**: `renode/run_sensor_capture.resc`

## Dynamic Temperature Changes

The `.resc` script changes sensor values between `emulation RunFor` blocks:

```
i2c0.sensor Temperature 22.0
emulation RunFor "00:00:01.500000"   # firmware reads ~5 samples at 22 C

i2c0.sensor Temperature 28.0
emulation RunFor "00:00:02.000000"   # firmware reads ~5 samples at 28 C
```

This demonstrates Renode's ability to simulate changing environmental
conditions during a single simulation run.

## How to Run

```bash
# Full test suite (includes sensor tests 29-30)
task dt-integration-test

# Quick run (assumes artifacts exist)
task dt-sensor-test

# Individual test
docker exec elemrv-gui bash -c \
  'cd /workspace/elemrv/renode && \
   renode --disable-xwt --console -e "include @run_sensor_capture.resc"'
```

## Expected Output

```
Sensor Capture Test
Sensor: SI7021 @ I2C 0x40
Samples: 10, interval: 200 ms
Sample 1: raw=0x6724 temp=22.00 C
Sample 2: raw=0x6724 temp=22.00 C
...
Sample 6: raw=0x6E72 temp=28.00 C
...
Capture complete: 10/10 samples OK
Sensor Capture Test PASSED
```

## Platform File

`renode/platforms/elemrv_h_sensor.repl` extends the Zephyr platform
(`elemrv_h_zephyr.repl`) with the SI7021 sensor attached to `i2c0`.
