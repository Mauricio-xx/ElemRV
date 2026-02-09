# ElemRV-N (Nitrogen) Digital Twin

## Architecture Comparison

| Feature | ElemRV-H (Hydrogen) | ElemRV-N (Nitrogen) |
|---------|-------------------|-------------------|
| ISA | RV32IC | RV32IMC |
| Clock | 50 MHz | 20 MHz |
| SRAM | 8 KB | 4 KB |
| HyperRAM | — | 64 MB |
| Flash | 64 KB | 64 KB |
| GPIO pins | 12 | 20 |
| Pinmux pins | 12 | 20 |
| SPI | — | 1x SPI Controller |
| I2C | 1x (full) | 1x (full) + 1x (lightweight) |
| UART | 1x (full) | 1x (full) + 1x (lightweight) |
| PWM | 1x (2-ch) | 1x (2-ch) |
| PIO | 1x (3-pin) | 1x (3-pin) |
| Timer | 1x MachineTimer | 1x MachineTimer |

## Peripheral Memory Map

| Address | Peripheral | Type |
|---------|-----------|------|
| 0x80000000 | SRAM (4 KB) | Memory |
| 0x90000000 | HyperRAM (64 MB) | Memory |
| 0xA0000000 | Flash (64 KB) | Memory |
| 0xF0000000 | GPIO0 (20 pins) | LiteX / Co-sim |
| 0xF0001000 | I2C0 (full) | LiteX / Co-sim |
| 0xF0002000 | I2C1 (lightweight) | Co-sim |
| 0xF0003000 | PIO0 | Co-sim |
| 0xF0004000 | PWM0 | Co-sim |
| 0xF0005000 | SPI0 | Co-sim |
| 0xF0006000 | UART0 (full) | LiteX / Co-sim |
| 0xF0007000 | UART1 (lightweight) | Co-sim |
| 0xF0010000 | Pinmux (20 pins) | Co-sim |
| 0xF0020000 | Timer0 | LiteX / Co-sim |
| 0xF0023000 | HyperBus Config | Tag only |

## Co-simulation Library Reuse

5 peripherals reuse H's `.so` libraries (same RTL, clock-agnostic):
- `libpwm.so` — PWM0
- `libpio.so` — PIO0
- `libi2c.so` — I2C0
- `libuart.so` — UART0
- `libmtimer.so` — Timer0

5 peripherals use N-specific `.so` libraries (different parameters):
- `libgpio_n.so` — GPIO0 (20 pins vs 12)
- `libpinmux_n.so` — Pinmux (20 pins vs 12)
- `libspi.so` — SPI0 (new peripheral)
- `libi2c_lite.so` — I2C1 (lightweight, 0 interrupts)
- `libuart_lite.so` — UART1 (lightweight, no CTS/RTS)

## Platform Files

| File | Purpose |
|------|---------|
| `elemrv_n.repl` | Base platform (LiteX models + Tags) |
| `elemrv_n_zephyr.repl` | Zephyr variant (LiteX_Timer_CSR32) |
| `elemrv_n_cosim_*.repl` | Individual co-sim test platforms |
| `elemrv_n_full_cosim.repl` | All 10 peripherals co-simulated |

## Build Instructions

### Generate N-specific Verilog
```bash
task dt-n-cosim-generate
# OR manually:
docker exec -w /workspace/elemrv elemrv-gui sbt "runMain elemrv_n.test.WishboneGpioNVerilog"
# ... repeat for each generator
```

### Build Co-simulation Libraries
```bash
task dt-n-cosim-build
# OR manually:
docker exec elemrv-gui bash -c 'cd /workspace/elemrv/renode/verilated/wrappers && bash build_n_cosim.sh release'
```

### Build Zephyr Apps
```bash
task dt-n-zephyr-build
# OR manually:
docker exec elemrv-gui bash -c '
  export ZEPHYR_BASE=/workspace/elemrv/software/zephyr
  cd /workspace/elemrv/software/elemrv-zephyr && bash build_n_apps.sh'
```

### Run Tests
```bash
task dt-n-test        # Full rebuild + test
task dt-n-test-quick  # Test only (assumes artifacts exist)
```

## Test Suite (Tests 31-40)

| # | Test | Pass Marker |
|---|------|-------------|
| 31 | N Base Platform | ElemRV-N Base Platform Test PASSED |
| 32 | N GPIO Co-simulation | N GPIO Co-simulation Test PASSED |
| 33 | N SPI Co-simulation | N SPI Co-simulation Test PASSED |
| 34 | N I2C Lite Co-simulation | N I2C Lite Co-simulation Test PASSED |
| 35 | N UART Lite Co-simulation | N UART Lite Co-simulation Test PASSED |
| 36 | N Pinmux Co-simulation | N Pinmux Co-simulation Test PASSED |
| 37 | N Full Co-simulation | N Full Co-simulation Test PASSED |
| 38 | N Pure Verilator Testbenches | All N testbenches PASSED |
| 39 | N Zephyr Hello World | N Zephyr Hello World Test PASSED |
| 40 | N Zephyr Blinky | N Zephyr Blinky Test PASSED |

## Zephyr BSP

- **SoC:** `elemrv_n_vexriscv` (adds `RISCV_ISA_EXT_M` vs H's SoC)
- **Board:** `elemrv_n`
- **DTS:** `riscv32-elemrv-n-vexriscv.dtsi`
- **Boot:** XIP from Flash (code in 64 KB Flash, data in 4 KB SRAM)

## Known Limitations

1. **HyperRAM** is modeled as `MappedMemory` in Renode (no HyperBus protocol simulation)
2. **SPI pin names** — wrapper assumes `io_spi_dq_0_read`/`io_spi_dq_1_read`; verify after Verilog generation
3. **I2C Lite interrupts** — lightweight variant may omit `io_i2c_interrupts` port; wrapper handles this
4. **UART Lite CTS/RTS** — lightweight variant has no flow control pins
5. **4 KB RAM** is tight for Zephyr — stack sizes reduced (main=512, idle=256, ISR=512)
