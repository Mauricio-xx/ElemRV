# Getting Started with ElemRV Digital Twin

This guide walks through the initial setup and first steps with the ElemRV Digital Twin platform.

## Prerequisites

### Required Software

- Docker (20.10+)
- [Task](https://taskfile.dev/) (task runner): `sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d -b /usr/local/bin`
- Git
- `repo` (Android repo tool): `curl https://storage.googleapis.com/git-repo-downloads/repo > /usr/local/bin/repo && chmod a+rx /usr/local/bin/repo`
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

# Initialize repo manifest and sync submodules
repo init -u https://github.com/aesc-silicon/ElemRV.git -b main -m manifest.xml
repo sync

# Build the Docker simulation container
docker build -t elemrv-sim:latest -f docker/Dockerfile.simulation docker/
```

This:
- Downloads all submodules (nafarr, zibal, vexriscv, SpinalCrypto)
- Builds the Docker image with Renode, Verilator, SBT, RISC-V GCC, and Zephyr SDK

### Step 2: Start the Container

```bash
# Start the development container
docker run -d --name elemrv-test \
  -v $(pwd):/workspace/elemrv \
  -w /workspace/elemrv \
  elemrv-sim:latest sleep infinity

# Configure git safe directories (required for mounted volumes)
docker exec elemrv-test git config --global --add safe.directory "*"
```

Alternatively, using docker compose:
```bash
cd docker && docker compose up -d renode
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
============================================
  ElemRV Digital Twin Test Suite
============================================
  Working dir: /workspace/elemrv/renode
  Date: 2026-02-10 12:00:00 UTC

=== TEST 1: Base Platform ===
  --- output tail ---
  ...
  ---
  RESULT: PASS

=== TEST 2: PWM Co-simulation ===
  ...

============================================
  SUMMARY: 51/51 passed
============================================
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
docker run -d --name elemrv-test \
  -v $(pwd):/workspace/elemrv \
  -w /workspace/elemrv \
  elemrv-sim:latest sleep infinity

# Or using docker compose
cd docker && docker compose up -d renode
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
docker exec -w /workspace/elemrv elemrv-test sbt "runMain elemrv_h.test.WishbonePwmVerilog"
```

## Directory Layout After Setup

```
ElemRV/
├── gen/                        # Generated H Verilog (pre-committed)
│   ├── WishbonePwm.v
│   ├── WishboneGpio.v
│   └── ...
├── gen_n/                      # Generated N Verilog (via sbt)
├── renode/
│   ├── platforms/              # Platform definitions
│   ├── verilated/
│   │   ├── wrappers/           # C++ co-sim wrappers
│   │   └── libs/               # Compiled .so libraries
│   ├── run_tests.sh            # Test runner
│   └── *.resc                  # Test scripts
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
