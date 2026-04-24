# Test Suite Reference

Complete documentation of the ElemRV Digital Twin test suite. Tests 1-52 were the v1.0 baseline; Phase G (v1.1) added six N-specific tests (33b-33g) covering Quad I/O SPI, BMB co-simulation and the image-container boot flow; Phase I (v1.2) added two more (33h, 33i) proving direct CPU fetch + execute from the BmbSpiXip DT; Gap 3.2 (v1.3) added three more (33j c.jal sub-word regression harness, 33k XIP fetch-cache invalidation coverage, 33l end-to-end QPI handshake). Total in 1.3: **63 tests**. Per-test detail for the Phase G/I and Gap 3.2 additions lives in [platforms/elemrv-n.md](../platforms/elemrv-n.md#individual-tests) and in the retrospective [Digital Twin Gap Journey](../retrospective/gaps.md).

## Test Organization

Tests are numbered sequentially in `renode/run_tests.sh`. The ordering reflects the actual script:

| Range | Category | Count |
|-------|----------|-------|
| 1-2 | Base platform + PWM co-sim | 2 |
| 3-8 | Zephyr apps (H) | 6 |
| 9-15 | Co-sim per-peripheral + full integration (H) | 7 |
| 16-21 | Cross-peripheral + hybrid tests | 6 |
| 22-23 | Verilator + GDB validation | 2 |
| 24-28 | Fault injection | 5 |
| 29-30 | Sensor detection + capture (H) | 2 |
| 31-40 | ElemRV-N platform | 10 |
| 41-46 | RTOS debugging (H + N) | 6 |
| 47-51 | Sensor simulation (I2C + SPI + portable) | 5 |
| 52 | Multi-node IoT | 1 |
| 33b-33g | Phase G: Quad I/O SPI + BMB + image-container (N) | 6 |
| 33h-33i | Phase I: CPU-driven XIP fetch (N) | 2 |
| 33j-33l | Gap 3.2: sub-word regression + cache invalidate + QPI handshake (N) | 3 |

## Tests 1-2: Base Platform + PWM Co-sim

### Test 1: Base Platform
**Script**: `test_base.resc`
**Pass Marker**: `Base Platform Test PASSED`
**Validates**:
- VexRiscv CPU executes instructions
- RAM read/write operations
- `emulation RunFor` timing

### Test 2: PWM Co-simulation
**Script**: `run_pwm_test.resc`
**Pass Marker**: `PWM Co-simulation Test PASSED`
**Validates**:
- PWM Verilator library loads correctly
- Register read/write through RTL
- IP Header verification (0x00080002)

## Tests 3-8: Zephyr Apps (H)

### Test 3: Zephyr Hello World
**Script**: `run_zephyr_hello.resc`
**Pass Marker**: `Zephyr Hello World Test PASSED`
**Validates**: Zephyr kernel boot, UART console output, XIP from Flash

### Test 4: Zephyr Blinky (GPIO+Timer)
**Script**: `run_zephyr_blinky.resc`
**Pass Marker**: `Zephyr Blinky Test PASSED`
**Validates**: GPIO output, Timer k_sleep, LED toggle

### Test 5: Zephyr I2C Scan
**Script**: `run_zephyr_i2c_scan.resc`
**Pass Marker**: `Zephyr I2C Scan Test PASSED`
**Validates**: LiteX I2C driver, address probing

### Test 6: Zephyr PWM Driver
**Script**: `run_zephyr_pwm.resc`
**Pass Marker**: `Zephyr PWM Driver Test PASSED`
**Validates**: Custom WishbonePwm Zephyr driver

### Test 7: Zephyr PIO Driver
**Script**: `run_zephyr_pio.resc`
**Pass Marker**: `Zephyr PIO Driver Test PASSED`
**Validates**: Custom WishbonePio Zephyr driver

### Test 8: Zephyr Pinmux Driver
**Script**: `run_zephyr_pinmux.resc`
**Pass Marker**: `Zephyr Pinmux Driver Test PASSED`
**Validates**: Custom WishbonePinmux Zephyr driver

## Tests 9-15: Co-sim Per-Peripheral (H)

### Test 9: PIO Co-simulation
**Script**: `run_cosim_pio_test.resc`
**Pass Marker**: `PIO Co-simulation Test PASSED`
**Validates**: PIO RTL register verification, 3-pin operation

### Test 10: Pinmux Co-simulation
**Script**: `run_cosim_pinmux_test.resc`
**Pass Marker**: `Pinmux Co-simulation Test PASSED`
**Validates**: Pinmux RTL, 12-pin routing

### Test 11: GPIO Co-simulation
**Script**: `run_cosim_gpio_test.resc`
**Pass Marker**: `GPIO Co-simulation Test PASSED`
**Validates**: GPIO RTL, direction control, pin read/write

### Test 12: MachineTimer Co-simulation
**Script**: `run_cosim_mtimer_test.resc`
**Pass Marker**: `MachineTimer Co-simulation Test PASSED`
**Validates**: mtime counter, mtimecmp comparison

### Test 13: I2C Co-simulation
**Script**: `run_cosim_i2c_test.resc`
**Pass Marker**: `I2C Co-simulation Test PASSED`
**Validates**: I2C master RTL, start/stop conditions

### Test 14: UART Co-simulation
**Script**: `run_cosim_uart_test.resc`
**Pass Marker**: `UART Co-simulation Test PASSED`
**Validates**: UART RTL, baud rate config, TX/RX

### Test 15: Full Co-simulation Integration
**Script**: `run_cosim_full_test.resc`
**Pass Marker**: `Full Co-simulation Integration Test PASSED`
**Validates**: All 7 co-sim libraries loaded simultaneously, no conflicts

## Tests 16-21: Cross-Peripheral + Hybrid

### Test 16: Multi-Peripheral Register Sequence
**Script**: `run_cosim_multi_reg_test.resc`
**Pass Marker**: `Multi-Peripheral Register Sequence Test PASSED`
**Validates**: Sequential register access across all 7 co-sim peripherals

### Test 17: Pinmux+PWM Register Sequence
**Script**: `run_cosim_pinmux_pwm_seq_test.resc`
**Pass Marker**: `Pinmux+PWM Register Sequence Test PASSED`
**Validates**: Pinmux and PWM register interaction

### Test 18: Zephyr Timer-UART Integration
**Script**: `run_zephyr_timer_uart.resc`
**Pass Marker**: `Zephyr Timer-UART Integration Test PASSED`
**Validates**: Interrupt-driven timer + UART output flow

### Test 19: Hybrid Pinmux+PWM
**Script**: `run_hybrid_pinmux_pwm.resc`
**Pass Marker**: `Hybrid Pinmux-PWM Integration Test PASSED`
**Validates**: Co-sim PWM/Pinmux + LiteX UART/Timer

### Test 20: Hybrid PIO+UART
**Script**: `run_hybrid_pio_uart.resc`
**Pass Marker**: `Hybrid PIO-UART Integration Test PASSED`
**Validates**: Co-sim PIO + LiteX UART/Timer

### Test 21: Hybrid Multi-Cosim
**Script**: `run_hybrid_multi_cosim.resc`
**Pass Marker**: `Hybrid Multi-Cosim Integration Test PASSED`
**Validates**: Multiple co-sim peripherals + LiteX UART/Timer

## Tests 22-23: Verilator + GDB

### Test 22: Pure Verilator Testbenches
**Script**: N/A (runs `make -C verilated/testbenches run`)
**Pass Marker**: `All testbenches PASSED`
**Validates**: RTL correctness without Renode, standalone test coverage

### Test 23: GDB Server Validation
**Script**: `test_gdb_server.sh`
**Pass Marker**: `GDB_SERVER_TEST PASSED`
**Validates**: GDB server starts, accepts connections, responds to commands

## Tests 24-28: Fault Injection

### Test 24: Fault: PWM Register Corruption
**Script**: `run_fault_pwm_corruption.resc`
**Pass Marker**: `PWM Fault Injection Test PASSED`
**Validates**: Firmware behavior when PWM period register is corrupted

### Test 25: Fault: GPIO Register Corruption
**Script**: `run_fault_gpio_corruption.resc`
**Pass Marker**: `GPIO Fault Injection Test PASSED`
**Validates**: Firmware behavior when GPIO direction is corrupted

### Test 26: Fault: Timer Perturbation
**Script**: `run_fault_timer_perturb.resc`
**Pass Marker**: `Timer Perturbation Fault Test PASSED`
**Validates**: Firmware behavior when timer interrupt is perturbed

### Test 27: Fault: UART Injection
**Script**: `run_fault_uart_injection.resc`
**Pass Marker**: `UART Fault Injection Test PASSED`
**Validates**: Firmware behavior with injected UART byte

### Test 28: Fault: Missing Peripheral
**Script**: `run_fault_missing_peripheral.resc`
**Pass Marker**: `Missing Peripheral Fault Test PASSED`
**Validates**: Firmware behavior when peripheral is absent (Tag region)

## Tests 29-30: Sensor (H)

### Test 29: I2C Sensor Detection
**Script**: `run_sensor_detect.resc`
**Pass Marker**: `I2C Sensor Detection Test PASSED`
**Validates**: SI7021 presence at I2C address, scan detection

### Test 30: Sensor Capture
**Script**: `run_sensor_capture.resc`
**Pass Marker**: `Sensor Capture Integration Test PASSED`
**Validates**: Dynamic temperature reads, value changes

## Tests 31-40: ElemRV-N Platform

### Test 31: N Base Platform
**Script**: `run_n_base_test.resc`
**Pass Marker**: `ElemRV-N Base Platform Test PASSED`
**Validates**: RV32IMC execution, 4KB RAM

### Test 32: N GPIO Co-simulation
**Script**: `run_n_cosim_gpio_test.resc`
**Pass Marker**: `N GPIO Co-simulation Test PASSED`
**Validates**: 20-pin GPIO RTL

### Test 33: N SPI Co-simulation
**Script**: `run_n_cosim_spi_test.resc`
**Pass Marker**: `N SPI Co-simulation Test PASSED`
**Validates**: SPI controller RTL, command FIFO

### Test 33b: N SPI Quad Flash Co-simulation (Phase G.1b)
**Script**: `run_n_cosim_spi_quad_flash_test.resc`
**Pass Marker**: `N SPI Quad Flash Co-simulation Test PASSED`
**Library**: `libspi_quad.so` (`SpiController` + `spi_qio_flash_slave`)
**Validates**: `RDID (0x9F)`, Fast Read single (`0x0B`), Quad I/O Fast Read (`0xEB`) via register pokes. **Strengthened in Gap 3.2 #4**: tail python block now asserts all 7 response-FIFO bytes and emits PASS/FAIL accordingly (previously the marker was unconditional).

### Test 33c: N SPI Quad Flash Bare-Metal Firmware (Phase G.1b.2)
**Script**: `run_n_spi_quad_flash_firmware_test.resc`
**Firmware**: `renode/firmware/samples/spi_quad_flash_test/`
**Pass Marker**: `SPI Quad Flash Test PASSED`
**Validates**: C firmware drives SPI controller registers directly for RDID + Quad I/O Fast Read; UART logs results.

### Test 33d: N SPI Quad Flash Zephyr App (Phase G.1b.2)
**Script**: `run_n_spi_quad_flash_zephyr_test.resc`
**Firmware**: `software/elemrv-zephyr/app/spi_quad_flash/`
**Pass Marker**: `SPI Quad Flash Zephyr PASSED`
**Validates**: Zephyr `spi_transceive` API for RDID + `sys_write32` pokes for Quad I/O Fast Read.

### Test 33e: N BMB Bridge Round-Trip DT (Phase G.3)
**Script**: `run_n_cosim_bmb_bridge_test.resc`
**Library**: `libbmb_bridge.so` (`WishboneToBmbMaster` + `SimpleBmbRam`)
**Pass Marker**: `N BMB Bridge Co-simulation Test PASSED`
**Validates**: Wishbone writes round-trip through a BMB master FSM into a 256x32b internal RAM and back.

### Test 33f: N BmbSpiXipController DT (Phase G.1c)
**Script**: `run_n_cosim_bmb_spi_xip_test.resc`
**Library**: `libbmb_spi_xip.so`
**Pass Marker**: `N BMB SpiXip Co-simulation Test PASSED`
**Validates**: IP IDs for both config buses; XIP data reads return the synthetic backing pattern. Runs on the non-fast path (no `BMBXIP_FAST`).

### Test 33g: N BmbSpiXipController Image-Container Boot (Phase G.2)
**Script**: `run_n_bmb_spi_xip_boot_test.resc`
**Pass Marker**: `N BMB SpiXip Image-Container Boot Flow Test PASSED`
**Validates**: `gen_dt_image_container.sh` packages the image; wrapper's `BMBXIP_IMAGE_PATH` pre-loads the flash backing; sysbus reads validate the first four image words + ASCII marker bytes.

### Test 33h: N CPU-Driven XIP Execution (Phase I)
**Script**: `run_n_cpu_xip_exec_test.resc`
**Firmware**: `renode/firmware/samples/xip_exec_test/`
**Pass Marker**: `CPU-Driven XIP Execution Test PASSED`
**Validates**: VexRiscv fetches + executes a 30-byte straight-line kernel from the BmbSpiXip data bank, writing `0xCAFEBEEF` to RAM@`0x80000100`. `cpu RegisterAccessFlags 0xF000B000 0x1000 true` flips tlib's `IO_MEM_EXECUTABLE_IO` so the default fetch guard is bypassed. Wall time: ~0.3 s.

### Test 33i: N CPU-Driven XIP Bootrom-Adapted (Phase I)
**Script**: `run_n_cpu_xip_bootrom_test.resc`
**Firmware**: `renode/firmware/samples/xip_bootrom_test/`
**Pass Marker**: `CPU-Driven XIP Bootrom-Adapted Test PASSED`
**Env**: `BMBXIP_FAST=1`
**Validates**: Trimmed `software/elemrv_n/bootrom/start.s` (`_init_regs` + `_init_xip` with `CFGXIP_VALUE=0x007F0702` upstream value + marker `0xBEADFACE`) runs from XIP; exercises `jal`/`ret` control flow + cfgXip-bank register writes. Wall time: ~5-7 s with `BMBXIP_FAST=1`.

### Test 33j: N XIP c.jal Sub-Word Regression Harness (Gap 3.2 #3)
**Script**: `run_xip_cjal_repro.resc`
**Firmware**: `renode/firmware/samples/xip_cjal_repro/`
**Pass Marker**: `XIP c.jal Sub-Word Regression Test PASSED`
**Validates**: Mutation-proof regression guard for the Gap 1 sub-word shift fix in `bmb_spi_xip_wrapper.cpp`. Runs 9 scenarios covering `byte_off` ∈ {0,1,2,3} via c.jal to word-aligned + word+2 sub, uncompressed jal at word+2 PC, mixed C+uncompressed arithmetic, and data loads (`lw` word+0, `lhu` word+2, `lbu` word+1, `lbu` word+3). Tail python block asserts all 9 marker slots.

### Test 33k: XIP Fetch-Cache Invalidation Coverage (Gap 3.2 #1)
**Script**: `run_xip_cache_invalidate.resc`
**Firmware**: `renode/firmware/samples/xip_cache_invalidate/`
**Pass Marker**: `0xCA5E0001` (verdict-value literal)
**Env**: `BMBXIP_FAST=1`
**Validates**: Firmware reads the same XIP word before and after a cfgXip bank-1 write (mode=0, dummyCycles=15). Expected post-write value differs from the pre-write value because the controller emits extra dummy cycles that shift the slave's byte stream by one. Pre-Gap 3.2 #1, the wrapper silently dropped cfgXip writes (missing write-latch extra-posedge) and the fetch cache never invalidated — both bugs fixed together.

### Test 33l: BmbSpiXipController Quad I/O Fetch via QPI Handshake (Gap 3.2 #2)
**Script**: `run_n_cosim_bmb_spi_xip_quad_test.resc`
**Pass Marker**: `N BMB SpiXip Quad I/O Fetch Test PASSED`
**Env**: `unset BMBXIP_IMAGE_PATH` (test uses wrapper's built-in `rom[i] = i & 0xFF` pattern)
**Validates**: Full QPI handshake end-to-end. Reads fetch baseline via cmd=0x03 single-I/O, writes cfgXip `0x007F0702` (mode=2 quad, dummyCycles=7, evcr=0x7F — upstream bootrom value), lets the configure state machine run WREN + WRITE_REGISTER + latch, then re-reads asserting the rom pattern is unchanged through cmd=0xE7 quad fetches. Requires the slave's EVCR capture + `m_qpi_enabled` state machine + cmd=0xE7 ADDR→DUMMY (no mode byte) path.

### Test 34: N I2C Lite Co-simulation
**Script**: `run_n_cosim_i2c_lite_test.resc`
**Pass Marker**: `N I2C Lite Co-simulation Test PASSED`
**Validates**: Lightweight I2C RTL, polling operation

### Test 35: N UART Lite Co-simulation
**Script**: `run_n_cosim_uart_lite_test.resc`
**Pass Marker**: `N UART Lite Co-simulation Test PASSED`
**Validates**: Lightweight UART RTL, basic TX/RX

### Test 36: N Pinmux Co-simulation
**Script**: `run_n_cosim_pinmux_test.resc`
**Pass Marker**: `N Pinmux Co-simulation Test PASSED`
**Validates**: 20-pin pinmux RTL

### Test 37: N Full Co-simulation Integration
**Script**: `run_n_cosim_full_test.resc`
**Pass Marker**: `N Full Co-simulation Test PASSED`
**Validates**: All 10 co-sim peripherals simultaneously

### Test 38: N Pure Verilator Testbenches
**Script**: N/A (runs `make -C verilated/testbenches -f Makefile.nitrogen run`)
**Pass Marker**: `All N testbenches PASSED`
**Validates**: N-specific RTL correctness

### Test 39: N Zephyr Hello World
**Script**: `run_n_zephyr_hello.resc`
**Pass Marker**: `N Zephyr Hello World Test PASSED`
**Validates**: N Zephyr BSP, RV32IMC support

### Test 40: N Zephyr Blinky
**Script**: `run_n_zephyr_blinky.resc`
**Pass Marker**: `N Zephyr Blinky Test PASSED`
**Validates**: 20-pin GPIO driver on N

## Tests 41-46: RTOS Debugging

### Test 41: RTOS Debug Demo (H)
**Script**: `run_rtos_debug_demo_test.resc`
**Pass Marker**: `RTOS Debug Demo Test PASSED`
**Validates**: Multi-thread creation, thread analyzer output

### Test 42: RTOS Diagnostics (H)
**Script**: `run_rtos_diagnostics_test.resc`
**Pass Marker**: `RTOS Diagnostics Test PASSED`
**Validates**: Auto thread analyzer, logging subsystem

### Test 43: RTOS GDB Threads (H)
**Script**: `run_rtos_gdb_threads_test.resc`
**Pass Marker**: `RTOS GDB Threads Test PASSED`
**Validates**: Debug symbols, thread metadata accessible

### Test 44: N RTOS Debug Demo
**Script**: `run_n_rtos_debug_demo_test.resc`
**Pass Marker**: `N RTOS Debug Demo Test PASSED`
**Validates**: Multi-thread on 4KB RAM

### Test 45: N RTOS Diagnostics
**Script**: `run_n_rtos_diagnostics_test.resc`
**Pass Marker**: `N RTOS Diagnostics Test PASSED`
**Validates**: On-demand analyzer, no shell (RAM constraints)

### Test 46: N RTOS GDB Threads
**Script**: `run_n_rtos_gdb_threads_test.resc`
**Pass Marker**: `N RTOS GDB Threads Test PASSED`
**Validates**: N debug symbols, thread inspection

## Tests 47-51: Sensor Simulation

### Test 47: H I2C Sensor Capture
**Script**: `run_sensor_i2c_h_test.resc`
**Pass Marker**: `Sensor I2C H Test PASSED`
**Validates**: Generic I2C sensor simulation (SI70xx @ 0x48)

### Test 48: N I2C Sensor Capture
**Script**: `run_sensor_i2c_n_test.resc`
**Pass Marker**: `Sensor I2C N Test PASSED`
**Validates**: Same firmware on N board

### Test 49: N SPI Sensor Capture
**Script**: `run_sensor_spi_n_test.resc`
**Pass Marker**: `Sensor SPI N Test PASSED`
**Validates**: Co-sim SPI + embedded sensor slave, custom nafarr driver

### Test 50: H Portable Data Logger
**Script**: `run_portable_h_test.resc`
**Pass Marker**: `Portable H Test PASSED`
**Validates**: Multi-thread I2C sensor + LED + UART on H

### Test 51: N Portable Data Logger
**Script**: `run_portable_n_test.resc`
**Pass Marker**: `Portable N Test PASSED`
**Validates**: Same app on N, 4KB RAM operation

## Test 52: Multi-Node IoT

### Test 52: Multi-Node IoT (H edge + N gateway via UART hub)
**Script**: `run_multi_node.resc`
**Pass Marker**: `Multi-Node IoT Test PASSED`
**Validates**:
- Renode multi-machine simulation (two SoC variants)
- UARTHub cross-machine communication
- I2C sensor reading on edge (H)
- Text protocol parsing (DATA/ACK) on both machines
- Data aggregation and reporting on gateway (N)

## Running Tests

### Full Suite

```bash
# All 63 tests (build + test)
task dt-integration-test

# All 63 tests (no rebuild)
task dt-test-quick
```

### Platform-Specific

```bash
# ElemRV-N only
task dt-n-test
```

### Individual Tests

```bash
# Run a single test script
docker exec elemrv-test bash -c 'cd /workspace/elemrv/renode && \
  renode --disable-xwt --console -e "include @run_pwm_test.resc"'
```

## Test Reports

Test results are logged per-test to `/tmp/dt_test_N.log` (inside the Docker container), where N is the test number.

The `run_tests.sh` script prints a summary at the end:
```
============================================
  SUMMARY: 63/63 passed
============================================
```

### Exit Codes

| Code | Meaning |
|------|---------|
| 0 | All tests passed |
| 1 | One or more tests failed |

## Adding New Tests

### Test Script Template

```renode
# run_my_test.resc
using sysbus

mach create "my_test"
machine LoadPlatformDescription @platforms/elemrv_h_full_cosim.repl

# Load co-sim libraries if needed
$lib?="/workspace/elemrv/renode/verilated/libs/libpwm.so"
pwm0_cosim SimulationFilePathLinux $lib

# Load firmware
sysbus LoadBinary @firmware.bin 0xA0000000
cpu PC 0xA0000000

# Run
echo "Starting my test"
emulation RunFor "00:00:05.000000"

# Verify result
sysbus ReadDoubleWord 0xF0003000

echo "My Test PASSED"
quit
```

> **Note**: Do not assign `sysbus ReadDoubleWord` results to variables (e.g., `$result=sysbus ReadDoubleWord ...`) — this hangs with CoSimulatedPeripheral.

### Test Registration

Add to `renode/run_tests.sh`:

```bash
# Test N: My Test
run_test "My Test Name" "run_my_test.resc" "My Test PASSED"
```

The `run_test` function takes 3 arguments: test name, script path, and pass marker string.

---

**Previous**: [Bare-metal Firmware](../firmware/bare-metal.md)
**Next**: [Taskfile Commands](taskfile-commands.md)
