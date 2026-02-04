# Session 001: Infrastructure Setup

**Date**: 2025-02-04  
**Branch**: dev-mont/digital-twin

## Summary

Created the foundational infrastructure for ElemRV digital twin simulation using Renode. This includes the Docker container setup with all necessary tools and the project documentation structure.

## Files Changed

- `renode/docs/plan.md` - Complete project plan with architecture details, memory map, peripheral specifications, and stage-based implementation roadmap
- `docker/Dockerfile.simulation` - Docker image with:
  - Renode 1.16.0 (latest stable)
  - Verilator (compiled from stable branch)
  - RISC-V GNU toolchain (xpack v13.2.0)
  - Python3 with pyrenode3, robotframework
  - Mono runtime for Renode
- `docker/docker-compose.yml` - Compose configuration for easy container management
- `renode/` directory structure created:
  - `platforms/` - Hardware description files (.repl)
  - `scripts/` - Startup scripts and tests
  - `firmware/samples/` - Test firmware
  - `verilated/` - RTL co-simulation files
  - `sessions/` - Session logs
  - `docs/` - Documentation

## Commit

```
001: Add Renode simulation infrastructure
```

## Docker Usage

Build and run the container:
```bash
cd docker
docker-compose up -d
docker-compose exec renode bash
```

Verify installation inside container:
```bash
renode --version
verilator --version
riscv-none-elf-gcc --version
```

## Testing

- [ ] Docker image builds successfully
- [ ] Renode starts inside container
- [ ] RISC-V toolchain accessible
- [ ] Verilator accessible

## Next Stage

**Stage 002**: Create base platform description (`elemrv_h.repl`) with CPU, RAM, and FLASH definitions.

## Technical Notes

### Memory Map Extracted from ElemRV-H

From `hardware/scala/elemrv_h/ElemRV.scala`:
- RAM: 0x80000000 (8 KB)
- FLASH: 0xA0000000 (64 KB)
- Peripherals base: 0xF0000000

### Peripherals

ElemRV-H (Hydrogen) has 6 peripherals:
1. GPIO0 @ 0xF0000000 (12 pins)
2. I2C0 @ 0xF0001000
3. PIO0 @ 0xF0002000 (3 pins)
4. PWM0 @ 0xF0003000 (2 channels)
5. UART0 @ 0xF0004000
6. Pinmux @ 0xF0010000

Total interrupts: 3

### Firmware Analysis

Existing demo firmware in `software/elemrv_h/demo/`:
- `kernel.c` - Main application with GPIO blink + UART banner
- `start.s` - Assembly startup code
- `kernel.ld` - Linker script with memory regions

The firmware expects:
- Stack at end of OCRAM (0x80000000 + 8KB)
- Entry point: `_head` in start.s
- Initial pin setup via `gpio_set_pin` at 0xF0000000

### Renode Version

Using Renode 1.16.0 (stable) downloaded from GitHub releases.
Portable Linux package includes Mono runtime.

### Verilator

Compiled from source using `stable` branch for latest features while maintaining stability.
Required for Stage 010+ RTL co-simulation.

### RISC-V Toolchain

Using xpack-dev-tools pre-built toolchain:
- riscv-none-elf-gcc 13.2.0
- Supports RV32IC (matching VexRiscv configuration)
- Pre-built for faster Docker builds

### Future Considerations

- GUI support requires X11 forwarding or VNC
- Current setup is headless-friendly
- Verilated peripherals will be in `renode/verilated/`
- Test scripts will use bash initially, Robot Framework later
