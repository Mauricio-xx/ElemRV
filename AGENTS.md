# Agent Guidelines for ElemRV

> Guidelines for AI agents working in this SpinalHDL-based RISC-V microcontroller repository.

## Build & Development Commands

### Essential Commands

```bash
# Install dependencies (run once)
task install

# Generate Verilog for FPGA
task fpga-prepare

# Generate Verilog for ASIC
task prepare

# Run RTL simulation (FPGA)
task fpga-simulate duration=10

# Run RTL simulation (ASIC)
task simulate duration=10

# Full ASIC flow (RTL to GDSII)
task
```

### SBT Commands (Scala/SpinalHDL)

```bash
# Compile project
sbt compile

# Run specific generator
sbt "runMain elemrv_n.ECPIX5.ECPIX5Generate"

# Format code
sbt scalafmt

# Check formatting
sbt scalafmtCheck
```

### Testing

There are currently no tests in this repository. Tests would be added to `test/scala/` and run with:

```bash
# Run all tests
sbt test

# Run single test class
sbt "testOnly *ClassName"

# Run single test method
sbt "testOnly *ClassName -- -z testMethodName"
```

## Code Style Guidelines

### Formatting
- **Tool**: scalafmt v3.2.1 with Scala 2.12 dialect
- **Max column width**: 100 characters
- **Indentation**: 2 spaces (no tabs)
- **No align preset** - don't align operators or parameters
- **Docstrings**: Don't wrap

### License Headers
Every source file MUST start with SPDX license headers:

```scala
// SPDX-FileCopyrightText: 2025 aesc silicon
//
// SPDX-License-Identifier: CERN-OHL-W-2.0
```

### Imports
1. Group by library: `spinal` imports first, then `nafarr`, then `zibal`, then `elements`
2. Separate groups with blank lines
3. Within groups, order alphabetically:

```scala
import spinal.core._
import spinal.core.sim._
import spinal.lib._
import spinal.lib.bus.bmb._

import nafarr.blackboxes.lattice.ecp5._
import nafarr.memory.ocram.ihp.sg13g2.BmbIhpOnChipRam
import nafarr.system.clock._
import nafarr.system.clock.ClockControllerCtrl._
import nafarr.system.reset._
import nafarr.system.reset.ResetControllerCtrl._

import zibal.board.{BoardParameter, KitParameter}
import zibal.misc._
import zibal.platform.Nitrogen
import zibal.sim.hyperram.W956A8MBYA
import zibal.sim.MT25Q

import elements.board.ECPIX5
import elements.sdk.ElementsApp
```

### Naming Conventions

| Type | Convention | Example |
|------|-----------|---------|
| Packages | lowercase with underscores | `elemrv_n`, `elemrv_h` |
| Classes/Objects | PascalCase | `ElemRV`, `ECPIX5Top` |
| Parameters | PascalCase | `GpioCtrl.Parameter` |
| Methods/functions | camelCase | `simHook()`, `generateVerilog` |
| Variables/vals | camelCase | `socParameter`, `gpio0Ctrl` |
| Constants | PascalCase in objects | `ECPIX5.SystemClock.frequency` |

### Code Organization

```scala
// 1. Package declaration
package elemrv_n

// 2. Imports (grouped by library)
import spinal.core._
...

// 3. Object containing factory/parameter
object ElemRV {
  def apply(parameter: Nitrogen.Parameter) = ElemRV(parameter)
  
  case class Parameter(boardParameter: BoardParameter) extends ... {
    // Parameter definitions
  }
  
  // 4. Main component case class
  case class ElemRV(parameter: Nitrogen.Parameter) extends Nitrogen.Nitrogen(parameter) {
    // Implementation
  }
}
```

### SpinalHDL Conventions
- Use `val io = new Bundle` for top-level IO
- Use `ClockingArea` for clocked logic blocks
- Use `Vec(...)` for vector types
- Prefer `inout(Analog(...))` for tri-state signals
- Use `FakeI()`, `FakeO()`, `FakeIo()` wrappers for pin connections

### Error Handling
SpinalHDL is hardware description - errors are caught at compile/elaboration time:
- Use `SpinalError()` for user errors
- Use `assert()` for design-time checks
- Width mismatches are caught by SpinalHDL automatically

## Project Structure

```
hardware/scala/
├── elemrv_n/           # Nitrogen platform variant
│   ├── ElemRV.scala    # Main SoC definition
│   ├── ECPIX5/         # FPGA board files
│   └── SG13G2/         # ASIC PDK files
└── elemrv_h/           # Hydrogen platform variant
    └── ...

software/
├── elemrv_n/           # Zephyr firmware for Nitrogen
└── elemrv_h/           # Zephyr firmware for Hydrogen

modules/                # Git submodules
├── elements/nafarr/    # Hardware library
└── elements/zibal/     # Platform/framework
```

## Key Technologies

- **Language**: Scala 2.12.18
- **HDL**: SpinalHDL 1.10.2a (generates Verilog)
- **CPU**: VexRiscv (RV32IC)
- **FPGA**: Lattice ECP5 (ECPIX5 board)
- **ASIC PDK**: IHP Open SG13G2
- **Build**: sbt + Task
- **Container**: Podman

## CI/CD (Travis CI)

Runs on PRs and nightly cron:
```bash
task install branch=main
IS_HEADLESS=true task prepare layout filler
IS_HEADLESS=true task run-drc
```
