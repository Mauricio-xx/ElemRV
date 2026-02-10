# Getting Started with ElemRV Digital Twin

This guide walks through the initial setup and first steps with the ElemRV Digital Twin platform.

## Prerequisites

### Required Software

- Docker (20.10+)
- Task (task runner)
- Git
- 8GB+ RAM (16GB recommended for full co-simulation)

### Supported Platforms

- Linux (Ubuntu 20.04+, tested on 22.04)
- macOS (with Docker Desktop)
- Windows (WSL2 with Docker)

## Installation

### Step 1: Clone and Initialize

```bash
# Clone the repository
git clone <repository-url>
cd ElemRV

# Initialize project and install dependencies
task install
```

This command:
- Creates a Python virtual environment
- Installs podman-compose
- Downloads repo tool
- Initializes the manifest
- Synchronizes all submodules

### Step 2: Build Docker Container

```bash
# Build the development container
task build-container
```

The container includes:
- Renode 1.16.0
- Verilator 5.x
- SBT (Scala build tool)
- RISC-V GCC toolchain
- Zephyr SDK

### Step 3: Verify Installation

```bash
# Check container is running
docker ps | grep elemrv

# Test basic functionality
task dt-test-quick
```

## Your First Simulation

### Quick Test (No Rebuild)

```bash
# Run existing tests without rebuilding
task dt-test-quick
```

Expected output:
```
========================================
ElemRV Digital Twin Test Suite
========================================

Test 1/51: Base Platform ............ PASSED
Test 2/51: PWM Co-simulation ........ PASSED
...
Test 51/51: Portable Logger (N) ..... PASSED

========================================
SUMMARY: 51/51 tests PASSED
========================================
```

### Full Build and Test

```bash
# Build everything from scratch
task dt-integration-test
```

This command:
1. Compiles bare-metal firmware
2. Generates RTL from SpinalHDL
3. Builds co-simulation libraries
4. Builds Zephyr applications
5. Runs all 51 tests

## Understanding the Platform

### What Happens During Co-simulation

When you run a test:

1. **Renode** starts the VexRiscv CPU at 50MHz (H) or 20MHz (N)
2. **Firmware** executes from Flash or RAM
3. **Peripheral accesses** route through the IntegrationLibrary
4. **Verilator** evaluates RTL cycles for each bus transaction
5. **Results** return to firmware as real hardware would respond

### Platform Variants

Choose your platform:

```bash
# ElemRV-H (Hydrogen) - ASIC focus
export SOC=ElemRV-H
task dt-cosim-build

# ElemRV-N (Nitrogen) - FPGA focus  
export SOC=ElemRV-N
task dt-n-cosim-build
```

## Next Steps

### Learn the Architecture

Read [architecture.md](architecture.md) to understand:
- How Renode and Verilator communicate
- The role of IntegrationLibrary
- Signal-level debugging capabilities

### Platform-Specific Guides

- [ElemRV-H Platform](platforms/elemrv-h.md) - 8KB SRAM, 7 peripherals
- [ElemRV-N Platform](platforms/elemrv-n.md) - 4KB SRAM, 10 peripherals, HyperRAM

### Try Example Applications

```bash
# Sensor data capture
task dt-sensor-test

# RTOS debugging demo
task dt-rtos-test

# Fault injection
task dt-fault-test
```

### Interactive Debugging

Start an interactive session:

```bash
# Terminal 1: Start Renode with GDB server
task dt-debug-cosim

# Terminal 2: Connect GDB
task dt-debug-connect
```

## Common Issues

### Container Not Running

```bash
# Start the container manually
docker-compose up -d elemrv-gui

# Or using podman
venv/bin/podman-compose up -d elemrv-gui
```

### Permission Errors

```bash
# Fix ownership issues
sudo chown -R $USER:$USER renode/verilated/libs/
```

### Memory Issues

If co-simulation tests fail with out-of-memory errors:

```bash
# Increase Docker memory limit
# Edit docker-compose.yml, set mem_limit: 8g

# Or run single tests
task dt-test-quick
```

### RTL Generation Fails

```bash
# Regenerate specific peripheral
docker exec -w /workspace/elemrv elemrv-gui sbt "runMain elemrv_h.test.WishbonePwmVerilog"
```

## Directory Layout After Setup

```
ElemRV/
├── gen/                        # Generated Verilog
│   ├── WishbonePwm.v
│   ├── WishboneGpio.v
│   └── ...
├── renode/
│   ├── platforms/              # Platform definitions
│   ├── verilated/
│   │   ├── wrappers/           # C++ co-sim wrappers
│   │   └── libs/               # Compiled .so libraries
│   └── tests/                  # Test scripts
├── software/
│   ├── elemrv_h/               # Bare-metal apps
│   └── elemrv-zephyr/          # Zephyr apps
└── build/                      # Build artifacts
```

## Task Reference

Quick command reference:

| Command | Purpose |
|---------|---------|
| `task install` | Initial setup |
| `task dt-cosim-build` | Build H co-sim libraries |
| `task dt-n-cosim-build` | Build N co-sim libraries |
| `task dt-zephyr-build` | Build H Zephyr apps |
| `task dt-n-zephyr-build` | Build N Zephyr apps |
| `task dt-integration-test` | Run all 51 tests |
| `task dt-test-quick` | Run tests without rebuild |
| `task dt-debug-cosim` | Start GDB server |

## Support

For issues and questions:
- Check [Troubleshooting](architecture.md#troubleshooting)
- Review test logs in `renode/logs/`
- Consult platform-specific documentation

---

**Next**: [Architecture Overview](architecture.md)
