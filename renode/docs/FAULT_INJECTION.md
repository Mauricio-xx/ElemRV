# Fault Injection Testing

## Overview

Fault injection tests verify firmware robustness by corrupting peripheral state mid-execution via Renode's `sysbus WriteDoubleWord` command. No RTL or wrapper modifications are needed — all faults are injected externally through the system bus.

## Technique

The core mechanism is straightforward:

1. Load platform and firmware (or tight-loop CPU)
2. `emulation RunFor` to let the system reach a known state
3. `sysbus WriteDoubleWord <addr> <value>` to inject a fault
4. `emulation RunFor` to let the fault propagate
5. `sysbus ReadDoubleWord <addr>` to observe the result

For **CoSimulatedPeripheral** addresses (co-sim platform), writes route through the Verilator RTL Wishbone bus — reads return real RTL state. This means faults interact with actual register logic (e.g., RO registers reject writes, 20-bit fields mask overflow).

For **LiteX model** addresses (Zephyr platform), writes interact with Renode's C# peripheral models.

For **Tag** addresses (base platform), reads always return 0 — simulating a missing peripheral.

## Test Scripts

| Test | Script | Platform | Target |
|------|--------|----------|--------|
| PWM Register Corruption | `run_fault_pwm_corruption.resc` | Full co-sim | PWM RTL registers |
| GPIO Register Corruption | `run_fault_gpio_corruption.resc` | Full co-sim | GPIO RTL registers |
| Timer Perturbation | `run_fault_timer_perturb.resc` | Zephyr | LiteX_Timer_CSR32 |
| UART Injection | `run_fault_uart_injection.resc` | Zephyr | LiteX_UART |
| Missing Peripheral | `run_fault_missing_peripheral.resc` | Base (Tags) | PWM absent |

## Findings

| Fault | Target | Firmware | Detected? | How |
|-------|--------|----------|-----------|-----|
| R/W register corruption | PWM period → 0 | pwm_test.c | Only on initial check | write-then-readback at startup |
| R/W register corruption | GPIO direction → 0 | blinky | NO | write-only, never re-reads |
| RO register overwrite | PWM IP Header | RTL | N/A | RTL rejects write (hardwired) |
| Duty overflow (>20-bit) | PWM CH0 Pulse | RTL | N/A | RTL masks to 20 bits |
| Timer IRQ disable | LiteX_Timer ev_enable | timer_uart_test | PARTIAL | fewer callbacks or hang |
| UART byte injection | LiteX_UART rxtx | hello_world | NO | no output integrity check |
| Missing peripheral (Tag) | PWM absent | pwm_test.c | YES | IP Header ≠ expected → GPIO FAIL |
| Missing peripheral (Tag) | PWM absent | pwm_regtest.c | NO | never validates ID registers |

## Recommendations

Based on fault injection findings, firmware can improve robustness with:

1. **Periodic register re-reads**: Don't just write-and-forget. Re-read critical config registers (period, duty) periodically to detect external corruption.
2. **IP Header validation**: Always check peripheral identification registers before use. `pwm_test.c` demonstrates this pattern — `pwm_regtest.c` does not.
3. **Output integrity checks**: UART output has no CRC or sequence numbers. Consider checksums for critical data streams.
4. **Timer health monitoring**: Monitor timer callback frequency. If callbacks stop or slow unexpectedly, flag an error.
5. **GPIO direction guards**: Re-assert direction registers before critical I/O operations.

## How to Run

Run all fault injection tests as part of the full suite:

```bash
# Full test suite (28 tests including fault injection)
task dt-integration-test

# Quick run (no rebuild)
task dt-test-quick

# Individual test
docker exec elemrv-gui bash -c 'cd /workspace/elemrv/renode && \
  renode --disable-xwt --console -e "include @run_fault_pwm_corruption.resc"'
```
