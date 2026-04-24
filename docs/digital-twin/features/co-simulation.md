# Co-simulation Guide

This guide explains how RTL co-simulation works in the ElemRV Digital Twin platform and how to use it effectively.

## Overview

Co-simulation combines Renode's fast CPU simulation with Verilator's cycle-accurate RTL simulation, allowing firmware to interact with actual Verilog implementations of peripherals.

## How It Works

### Data Flow

```
Firmware Access to Peripheral
==============================

1. Firmware executes:
   *(volatile uint32_t*)0xF0003000 = 0x01;
   
2. Renode detects bus access to co-sim region (0xF0000000-0xF001FFFF)

3. IntegrationLibrary packages transaction:
   - Address: 0xF0003000
   - Data: 0x01
   - Write: true
   
4. Socket communication to Verilator process

5. Wrapper applies to RTL signals:
   - io_bus_CYC = 1
   - io_bus_STB = 1
   - io_bus_WE = 1
   - io_bus_ADR = 0x3000
   - io_bus_DAT_MOSI = 0x01

6. Verilator evaluates clock cycles

7. RTL responds:
   - io_bus_ACK = 1
   - io_bus_DAT_MISO = register_value

8. Response returns to Renode

9. CPU continues execution
```

### Timing Model

Each bus transaction takes multiple simulation cycles:

```
Cycle 0:  CPU initiates transaction
          Renode pauses CPU
          IntegrationLibrary sends request
          
Cycle 1:  Wrapper applies signals
          Verilator evaluates
          
Cycle 2:  RTL generates ACK
          Response captured
          
Cycle 3:  Response returned
          CPU resumes
```

This provides cycle-accurate timing at the cost of simulation speed.

## Co-simulation vs Pure Renode

| Aspect | Pure Renode | Co-simulation |
|--------|-------------|---------------|
| Speed | ~100 MIPS | ~1-10 KIPS |
| Accuracy | Model-based | Cycle-accurate |
| Use Case | Firmware dev | Driver/RTL validation |
| Debugging | Limited | Full signal visibility |
| CI/CD | Fast feedback | Thorough validation |

## Platform Modes

### 1. Base Platform

No co-simulation - uses LiteX models:

```
File: elemrv_h.repl

Components:
- VexRiscv CPU
- LiteX UART
- LiteX Timer
- Tags for memory regions
```

**Use**: Fast CPU debugging, algorithm development

### 2. Zephyr Platform

Adds RTOS support:

```
File: elemrv_h_zephyr.repl

Additional:
- MachineTimer (mtime)
- Correct CSR widths
```

**Use**: Zephyr RTOS development

### 3. Co-simulation Platform

Full RTL peripherals:

```
File: elemrv_h_full_cosim.repl

Components:
- GPIO0: CoSimulated @ 0xF0000000
- I2C0: CoSimulated @ 0xF0001000
- PIO0: CoSimulated @ 0xF0002000
- PWM0: CoSimulated @ 0xF0003000
- UART0: CoSimulated @ 0xF0004000
- Timer0: CoSimulated @ 0xF0005000
- Pinmux: CoSimulated @ 0xF0010000
```

**Use**: Driver validation, RTL verification

### 4. Hybrid Platform

Mix of both approaches:

```
File: elemrv_h_hybrid.repl

Configuration:
- PWM: Co-sim (critical timing)
- Pinmux: Co-sim (hardware routing)
- PIO: Co-sim (programmable I/O)
- GPIO: LiteX (sufficient for LED toggle)
- UART: LiteX (standard I/O)
- Timer: LiteX (sufficient for RTOS)
```

**Use**: Balanced performance and accuracy

## Creating a Co-simulation Platform

### Step 1: Define Peripheral in .repl

```renode
gpio0_cosim: CoSimulated.CoSimulatedPeripheral @ sysbus <0xF0000000, +0x1000>
    frequency: 50000000
    limitBuffer: 10000

pwm0_cosim: CoSimulated.CoSimulatedPeripheral @ sysbus <0xF0003000, +0x1000>
    frequency: 50000000
    limitBuffer: 10000
```

### Step 2: Load Co-simulation Library

```renode
$lib?="/workspace/elemrv/renode/verilated/libs/libpwm.so"
pwm0_cosim SimulationFilePathLinux $lib
```

### Step 3: Complete Script

```renode
using sysbus

mach create "cosim_test"
machine LoadPlatformDescription @platforms/elemrv_h_full_cosim.repl

# Load co-sim libraries
$gpio_lib?="/workspace/elemrv/renode/verilated/libs/libgpio.so"
gpio0_cosim SimulationFilePathLinux $gpio_lib

$pwm_lib?="/workspace/elemrv/renode/verilated/libs/libpwm.so"
pwm0_cosim SimulationFilePathLinux $pwm_lib

# Load firmware
sysbus LoadBinary @firmware.bin 0xA0000000
cpu PC 0xA0000000

# Run
emulation RunFor "00:00:05.000000"

quit
```

## Debugging Co-simulation

### Enable Verbose Logging

In wrapper code:
```cpp
#define DEBUG_ENABLE 1

void evalModel() {
    g_top->eval();
    
    if (DEBUG_ENABLE) {
        printf("[DEBUG] Time=%lu CYC=%d STB=%d WE=%d ADR=0x%X\n",
               g_top->clk_count,
               g_top->io_bus_CYC,
               g_top->io_bus_STB,
               g_top->io_bus_WE,
               g_top->io_bus_ADR);
    }
}
```

### Monitor Transactions

From Renode monitor:
```
(monitor) logLevel 3 sysbus
(monitor) sysbus LogPeripheralAccess true
```

### GDB Debugging

```bash
# Start with co-sim
task dt-debug-cosim

# Connect GDB
task dt-debug-connect

# In GDB:
(gdb) break main
(gdb) continue
(gdb) x/1xw 0xF0003000  # Read PWM register (goes to RTL)
```

### Signal Inspection

Add signal dumping to wrapper:
```cpp
// Dump internal signals periodically
if (g_top->clk_count % 100000 == 0) {
    printf("[SIGNAL] PWM=%X, Counter=%u, Period=%u\n",
           g_top->io_pwm_pwm,
           g_top->Pwm_output_counter,
           g_top->Pwm_output_period);
}
```

## Performance Optimization

### Build Modes

**Debug** (slow, verbose):
```bash
make -f Makefile.pwm BUILD_MODE=debug
```

**Release** (fast, minimal):
```bash
make -f Makefile.pwm BUILD_MODE=release
```

### Reduce Peripherals

Only enable peripherals you're testing:
```renode
# Instead of full co-sim, test just PWM
mach create "pwm_only"
machine LoadPlatformDescription @elemrv_h_minimal.repl

pwm0: CoSimulated.CoSimulatedPeripheral @ sysbus <0xF0003000, +0x1000>
    frequency: 50000000

$pwm_lib?="/workspace/elemrv/renode/verilated/libs/libpwm.so"
pwm0_cosim SimulationFilePathLinux $pwm_lib
```

Note: The `//` comment syntax is not valid in `.resc` scripts. Use `#` for comments.

### Limit Simulation Duration

```renode
# Short test runs
emulation RunFor "00:00:01.000000"  # 1 second virtual time
```

## Common Issues

### Library Not Found

**Error**: `Library not found: libpwm.so`

**Solution**:
```bash
# Check path
ls -la renode/verilated/libs/

# Verify architecture
file renode/verilated/libs/libpwm.so
# Should show: ELF 64-bit LSB shared object, x86-64

# Rebuild
cd renode/verilated/wrappers
make -f Makefile.pwm clean all
```

### Operation Timeout

**Error**: `Operation timeout`

**Causes**:
1. Missing `main` function in wrapper
2. Incorrect Verilator root linking
3. Infinite loop in RTL

**Solution**:
```bash
# Check symbols
nm -C libpwm.so | grep main

# Rebuild with all object files
make -f Makefile.pwm clean all
```

### Hang on Variable Assignment

**Issue**: Script hangs when using:
```renode
$value=sysbus ReadDoubleWord 0xF0003000
```

**Solution**: Do not assign read results to variables:
```renode
# Wrong - hangs
$value=sysbus ReadDoubleWord 0xF0003000

# Correct
sysbus ReadDoubleWord 0xF0003000
```

This is a Renode limitation with CoSimulatedPeripheral.

### Bus Transaction Errors

**Symptom**: Wrong data returned

**Check**:
1. Address alignment (32-bit word aligned)
2. Byte enable signals connected
3. Reset polarity (active-low)
4. Clock frequency matches platform

## Wrapper-Level Gotchas

The Phase G–I DTs and Gap 3.2 hardening pass surfaced four wrapper-level patterns that are easy to get subtly wrong. Any new `CoSimulatedPeripheral` wrapper on ElemRV should know about them.

### 1. Sub-word MMIO read shift

**Symptom:** Byte-level or half-word reads from a peripheral return wrong values even though word-level reads look correct. CPU fetching from the region may land on garbled opcodes.

**Root cause:** Our Wishbone slaves are 32-bit word-addressed: `ADR` indexes words, `DAT_MISO` is 32-bit, and we always return the full word at the nearest word boundary. Renode's bus framework, however, issues narrower reads — `sel=0x1` for a single byte or `sel=0x3` for a half-word — at any byte alignment within the peripheral window, and then takes the low N bits of whatever we returned. For non-zero byte offsets the low bits of the word-aligned value do not hold the requested slice, so the caller silently gets the wrong data.

**Fix:** Shift `g_bridge_rd_dat` right by `(byte_off * 8)` on every read ACK, where `byte_off = g_bridge_addr & 3`. This works uniformly for byte, half-word, and word reads because for word-aligned reads the shift is zero.

```cpp
// bmb_spi_xip_wrapper.cpp, evalModel(), end of read path:
if (/* ACK && !WE */) {
    uint32_t byte_off = g_bridge_addr & 3;
    g_bridge_rd_dat >>= (byte_off * 8);
}
```

**Regression guard:** test 33j runs 9 scenarios covering `byte_off` ∈ {0,1,2,3} via mixed instruction fetch (c.jal, uncompressed jal, mixed C + uncompressed) and data loads (`lw`/`lhu`/`lbu`). Mutation-verified: wrapping the shift in `if (false && ...)` crashes the CPU mid-run and drops the pass marker.

### 2. Write-latch extra posedge

**Symptom:** Writes to registers silently no-op. Readback of a write returns the default value.

**Root cause:** SpinalHDL's `WishboneSlaveFactory` derives `doWrite` from `CYC && STB && WE && ACK` evaluated simultaneously. But ACK is a registered signal, so it rises one posedge *after* CYC+STB. Renode drops CYC/STB as soon as it observes ACK=1, so the posedge at which all four are true together never happens — the RTL write never fires.

**Fix:** Inside `evalModel()`, detect the condition (CYC+STB+WE all high with ACK about to fire) and inject an extra posedge before returning. Guard the shortcut with `WE=1` so read ACK timing is unchanged.

```cpp
// Pattern shared across pwm_wrapper, pio_wrapper, bmb_spi_xip_wrapper:
if (io_wb_CYC && io_wb_STB && io_wb_WE) {
    tickHalf();
    tickHalf();  // one extra posedge so doWrite latches
}
```

**Detection:** This bug is silent unless the test validates read-after-write. Gap 3.2 #1 (test 33k) surfaced the `bmb_spi_xip_wrapper` instance: the cfgXip writes that should have re-configured the XIP protocol were being dropped.

### 3. Fetch-cache invalidation on cfgXip writes

**Symptom:** Firmware reconfigures the XIP protocol via a cfgXip bank write, but subsequent XIP fetches still return bytes formatted for the *old* protocol.

**Root cause:** The BmbSpiXip wrapper caches the last word fetched from the XIP data bank (`bank 2`) so that sequential in-order fetches through the same 32-bit word don't re-run the SPI master state machine for each sub-word access. If firmware rewrites cfgXip (`bank 1`) between fetches, the cache must be invalidated or the next fetch returns stale data.

**Fix:** invalidate the fetch cache on every bank-1 write ACK. Cheap: one line in the wrapper, zero cost when firmware doesn't reconfigure mid-run.

**Regression guard:** test 33k reads the same XIP word three times with a cfgXip write sandwiched between reads 2 and 3, and asserts read 3 reflects the new protocol. Surfaced during Gap 3.2 #1 via the mutation audit — no pre-existing test exercised this path.

### 4. QPI handshake

**Symptom:** The controller switches to a quad XIP read command (0xE7 on Micron), but the slave fails to decode the CMD byte or returns zeros.

**Root cause:** Micron MT25Q QPI mode is opt-in: commands arrive on a single IO line by default. The host enables QPI by issuing `0x06 WREN` + `0x61 WRITE_REGISTER` with an EVCR byte whose bit 7 = 0. From the next CS assertion forward, commands sample on all four IO pins (two SCLK cycles per byte). Before the handshake, sampling on 4 pins gives garbage.

**Fix:** In the flash slave model, track `m_qpi_enabled`. Capture EVCR on the data byte of the `0x61` transaction, update the flag once CS deasserts. On every CS-assert, pick `rx_width = m_qpi_enabled ? 4 : 1` for the CMD phase. Remaining phases (ADDR, MODE_BYTE, DUMMY, DATA) continue to use explicit widths per command opcode. Also: `0xE7` skips the MODE_BYTE phase between ADDR and DUMMY, unlike `0xEB`.

**Regression guard:** test 33l runs the upstream bootrom's `cfgXip=0x007F0702` end-to-end (mode=2 quad, dummyCycles=7, evcr=0x7F). Also note that nafarr's `SpiController.CmdDummyCycles.cycles` counts half-cycles — to emit 8 SCLK dummies write `cycles=15`; for the slave's 4-SCLK expectation pair this with `setDummyCycles(4)` in the wrapper.

## CPU Execution from MMIO Space

By default Renode's sysbus aborts CPU instruction fetch from any address range that isn't backed by `ArrayMemory` ("Trying to execute code outside RAM or ROM at 0x…"). The abort site in tlib (`tlib/include/exec-all.h:333`) explicitly excludes pages carrying the `IO_MEM_EXECUTABLE_IO` flag, which `ArrayMemory` sets automatically.

The same flag can be set on any address range from a `.resc` script by calling `cpu RegisterAccessFlags <start> <size> true` *before* setting PC. No Renode patch is needed — it's a public API on `TranslationCPU` that bridges to tlib's `tlib_register_access_flags_for_range(..., 1)`.

```renode
# Mark the BmbSpiXip data bank as executable-IO so the CPU can fetch from it
cpu RegisterAccessFlags 0xF000B000 0x1000 true
cpu PC 0xF000B000
emulation RunFor "00:00:05.000000"
```

**Performance:** every instruction fetch round-trips through Verilator. Measured on Phase I (tests 33h, 33i):

- Straight-line XIP code: ~30 instructions per wall-second.
- `jal`/`ret`-heavy code across pages: ~0.5 instructions per wall-second.

Feasible for short boot kernels (tens of instructions); impractical for full RTOS boot — stage via RAM instead.

## Optional Optimisation: `BMBXIP_FAST=1`

The `bmb_spi_xip_wrapper` provides an opt-in `BMBXIP_FAST=1` env var that accelerates 33i-class tests by ~2.3× (23.5 s → 10.4 s wall time on 33i standalone). Two correctness-preserving shortcuts:

1. **Idle-tick shortcut (dominant):** skip the Verilator `eval()` when both `!io_wb_CYC` and `io_spi_cs == 1`. No state progresses that the outside world can observe — the Wishbone bus is idle and the SPI bus is deasserted.
2. **Fetch cache:** a 1024-entry word-indexed cache for the XIP data bank, invalidated on any cfgXip write (see Gotcha #3 above).

**Default off** so CI preserves full-fidelity coverage. Wire it per-test in `run_tests.sh` only where the wall-time cost is prohibitive; tests 33f/33g/33h/33j/33l/etc. run on the default path as fidelity baseline.

## Advanced Topics

### Multi-Peripheral Synchronization

All co-simulated peripherals share the same clock domain:
```renode
# All at 50MHz
gpio0: ... frequency: 50000000
pwm0: ... frequency: 50000000
uart0: ... frequency: 50000000
```

### Custom Peripherals

To add a new RTL peripheral:

1. **Create RTL** in SpinalHDL
2. **Generate Verilog**
3. **Create wrapper** (see `pwm_wrapper.cpp` as template)
4. **Build library**
5. **Add to platform**

### Pure Verilator Validation

Validate RTL before integration:
```bash
cd renode/verilated/testbenches
make run  # Runs standalone testbenches
```

## Test Integration

### Test Script Template

```bash
#!/bin/bash
# test_peripheral.sh

RENODE_ARGS="--disable-xwt --console"
SCRIPT="test_peripheral.resc"
TIMEOUT=30

# Run test
timeout $TIMEOUT docker exec elemrv-test \
    renode $RENODE_ARGS -e "include @$SCRIPT"

# Check result
if [ $? -eq 0 ]; then
    echo "TEST PASSED"
    exit 0
else
    echo "TEST FAILED"
    exit 1
fi
```

---

**Previous**: [Platforms](../platforms/elemrv-n.md)
**Next**: [Multi-Node IoT](multi-node-iot.md)
