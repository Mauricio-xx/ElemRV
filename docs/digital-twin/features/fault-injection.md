# Fault Injection Testing

Fault injection tests verify firmware robustness by corrupting peripheral state mid-execution. This document explains the technique and findings.

## Overview

Fault injection allows testing how firmware responds to:
- Register corruption due to electrical noise
- Unexpected peripheral behavior
- Missing or failed peripherals
- Timing violations

## Technique

### Core Mechanism

Faults are injected via Renode's `sysbus WriteDoubleWord` command:

```
Fault Injection Flow
====================

1. Load platform and firmware
   LoadPlatformDescription @platform.repl
   sysbus LoadBinary @firmware.bin 0xA0000000
   
2. Let system reach known state
   emulation RunFor "00:00:01.000000"
   
3. Inject fault
   sysbus WriteDoubleWord <addr> <value>
   
4. Let fault propagate
   emulation RunFor "00:00:00.500000"
   
5. Observe result
   sysbus ReadDoubleWord <addr>
```

### Target Types

**CoSimulatedPeripheral** (co-sim platform):
- Writes route through Verilator RTL Wishbone bus
- Reads return actual RTL state
- RTL logic handles overflow, read-only, etc.

**LiteX Model** (Zephyr platform):
- Writes interact with Renode C# peripheral models
- Behavior depends on model implementation

**Tag** (base platform):
- Reads always return 0
- Simulates missing peripheral
- No response from hardware

## Test Scripts

| Test | Script | Platform | Target | Fault Type |
|------|--------|----------|--------|------------|
| PWM Register Corruption | `run_fault_pwm_corruption.resc` | Full co-sim | PWM RTL | R/W register |
| GPIO Register Corruption | `run_fault_gpio_corruption.resc` | Full co-sim | GPIO RTL | R/W register |
| Timer Perturbation | `run_fault_timer_perturb.resc` | Zephyr | LiteX_Timer | IRQ enable |
| UART Injection | `run_fault_uart_injection.resc` | Zephyr | LiteX_UART | RX data |
| Missing Peripheral | `run_fault_missing_peripheral.resc` | Base (Tags) | PWM absent | Absent device |

## Findings

### Firmware Robustness Results

| Fault | Target | Firmware | Detected | Detection Method |
|-------|--------|----------|----------|------------------|
| R/W register corruption | PWM period to 0 | pwm_test.c | Only on initial check | Write-then-readback at startup |
| R/W register corruption | GPIO direction to 0 | blinky | NO | Write-only, never re-reads |
| RO register overwrite | PWM IP Header | RTL | N/A | RTL rejects write (hardwired) |
| Duty overflow (>20-bit) | PWM CH0 Pulse | RTL | N/A | RTL masks to 20 bits |
| Timer IRQ disable | LiteX_Timer ev_enable | timer_uart_test | PARTIAL | Fewer callbacks or hang |
| UART byte injection | LiteX_UART rxtx | hello_world | NO | No output integrity check |
| Missing peripheral (Tag) | PWM absent | pwm_test.c | YES | IP Header check fails |
| Missing peripheral (Tag) | PWM absent | pwm_regtest.c | NO | Never validates ID registers |

### Key Observations

**Write-then-forget vulnerability**:
```c
// Vulnerable - write and never check
*(uint32_t*)PWM_PERIOD = 1000;
// ... later ...
// Assumes period is still 1000

// Better - validate periodically
if (*(uint32_t*)PWM_PERIOD != 1000) {
    error_handler();
}
```

**IP header validation**:
```c
// Robust - check peripheral identity
if (*(uint32_t*)PWM_HEADER != PWM_EXPECTED_ID) {
    // Peripheral missing or wrong version
    gpio_failure();
}
```

**Output integrity**:
```c
// Vulnerable - no validation
printk("Temperature: %d\n", temp);

// Better - add CRC or sequence numbers
uint16_t crc = calculate_crc(buffer);
printf("DATA:%d:CRC:%04X\n", temp, crc);
```

## Recommendations

Based on fault injection findings, firmware can improve robustness:

### 1. Periodic Register Re-reads

Do not just write-and-forget. Re-read critical config registers periodically:

```c
void validate_pwm_config(void) {
    static uint32_t last_period = 0;
    uint32_t current_period = read_pwm_period();
    
    if (current_period != last_period && last_period != 0) {
        LOG_ERR("PWM period changed unexpectedly!");
        // Reconfigure or error
    }
    last_period = current_period;
}

// Call periodically
k_timer_start(&validation_timer, K_SECONDS(5), K_SECONDS(5));
```

### 2. IP Header Validation

Always check peripheral identification registers before use:

```c
int pwm_init(void) {
    uint32_t header = PWM_REG(PWM_HEADER_OFFSET);
    if (header != PWM_EXPECTED_HEADER) {
        LOG_ERR("PWM not found or wrong version: 0x%08X", header);
        return -ENODEV;
    }
    return 0;
}
```

### 3. Output Integrity Checks

Add CRCs or sequence numbers to critical data streams:

```c
// Sequence numbers detect dropped/misordered messages
static uint32_t seq_num = 0;

void send_sensor_data(float temp, float humidity) {
    struct data_packet pkt = {
        .seq = seq_num++,
        .temp = temp,
        .humidity = humidity,
        .crc = 0
    };
    pkt.crc = calculate_crc(&pkt, sizeof(pkt) - 4);
    uart_send(&pkt, sizeof(pkt));
}
```

### 4. Timer Health Monitoring

Monitor timer callback frequency:

```c
static uint32_t last_callback_time = 0;
static uint32_t callback_count = 0;

void timer_callback(struct k_timer *timer) {
    uint32_t now = k_uptime_get_32();
    uint32_t delta = now - last_callback_time;
    
    if (last_callback_time != 0 && delta > EXPECTED_INTERVAL_MS * 2) {
        LOG_ERR("Timer callback delayed: %u ms", delta);
    }
    
    last_callback_time = now;
    callback_count++;
}

// Check health periodically
void check_timer_health(void) {
    static uint32_t last_count = 0;
    if (callback_count == last_count) {
        LOG_ERR("Timer callbacks stopped!");
    }
    last_count = callback_count;
}
```

### 5. GPIO Direction Guards

Re-assert direction registers before critical I/O:

```c
void gpio_set_output_safe(uint32_t pin, uint8_t value) {
    // Ensure direction is output
    GPIO_REG(GPIO_DIRECTION) |= (1 << pin);
    
    // Small delay for direction change
    k_busy_wait(1);
    
    // Set value
    if (value) {
        GPIO_REG(GPIO_WRITE) |= (1 << pin);
    } else {
        GPIO_REG(GPIO_WRITE) &= ~(1 << pin);
    }
}
```

## Running Tests

### Full Test Suite

```bash
# All 60 tests including fault injection
task dt-integration-test
```

### Quick Run

```bash
# Run tests without rebuilding
task dt-test-quick
```

### Individual Fault Tests

```bash
# PWM register corruption
docker exec elemrv-test bash -c 'cd /workspace/elemrv/renode && \
  renode --disable-xwt --console -e "include @run_fault_pwm_corruption.resc"'

# Timer perturbation
docker exec elemrv-test bash -c 'cd /workspace/elemrv/renode && \
  renode --disable-xwt --console -e "include @run_fault_timer_perturb.resc"'

# Missing peripheral
docker exec elemrv-test bash -c 'cd /workspace/elemrv/renode && \
  renode --disable-xwt --console -e "include @run_fault_missing_peripheral.resc"'
```

## Test Implementation

### Example: PWM Corruption Test

```renode
# run_fault_pwm_corruption.resc

using sysbus

mach create "fault_pwm"
machine LoadPlatformDescription @platforms/elemrv_h_full_cosim.repl

# Load co-sim libraries
$pwm_lib?="/workspace/elemrv/renode/verilated/libs/libpwm.so"
$pwm0_cosim SimulationFilePathLinux $pwm_lib

# Load firmware
$elf?="/workspace/elemrv/software/elemrv_h/pwm_test/pwm_test.elf"
sysbus LoadBinary $elf 0xA0000000
cpu PC 0xA0000000

# Let firmware initialize PWM
echo "Letting firmware initialize..."
emulation RunFor "00:00:01.000000"

# Inject fault: corrupt PWM period register to 0
echo "Injecting fault: setting PWM period to 0"
sysbus WriteDoubleWord 0xF0003018 0x0

# Let fault propagate
echo "Observing fault effect..."
emulation RunFor "00:00:02.000000"

# Verify fault was applied
echo "Reading period register after fault:"
sysbus ReadDoubleWord 0xF0003018

quit
```

## Creating New Fault Tests

### Template

```renode
# New fault test template

mach create "fault_test"
machine LoadPlatformDescription @platform.repl

# Load libraries if co-sim
# $lib?="path"
# periph_cosim SimulationFilePathLinux $lib

# Load firmware
sysbus LoadBinary @firmware.bin 0xA0000000
cpu PC 0xA0000000

# Run to stable state
emulation RunFor "00:00:01.000000"

# Inject fault
sysbus WriteDoubleWord <target_addr> <corrupt_value>

# Observe
emulation RunFor "00:00:02.000000"

# Verify
echo "Value after fault:"
sysbus ReadDoubleWord <target_addr>

quit
```

## CI Integration

Fault injection tests are part of the automated test suite:

```yaml
# Example CI configuration
test:
  script:
    - task dt-integration-test
  artifacts:
    reports:
      junit: renode/logs/tests.xml
```

All fault tests must pass before merge.

---

**Previous**: [GDB Debugging](gdb-debugging.md)  
**Next**: [Zephyr Setup](../firmware/zephyr-setup.md)
