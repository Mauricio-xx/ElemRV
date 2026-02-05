# Stage 010: RTL Co-simulation - Implementation Plan

**Date:** 2025-02-05  
**Status:** Planning Complete - Ready for Implementation  
**Branch:** dev-mont/digital-twin  
**Option:** A (Full Implementation)

---

## Context from Previous Session

### Last Commits
- `36f42ca` - docs: Add comprehensive test results for Phase 1 and 2
- `1da9dc5` - feat: Complete Stages 005-009 - I2C, PWM, PIO, Pinmux tests
- `51bccac` - docs: Add completion report for Stages 005-009

### Current Functional State
- Platform: `elemrv_h.repl` with 7 peripherals
- 4 Working peripherals: UART, GPIO, I2C, Timer
- 3 Tagged peripherals (need RTL): PWM, PIO, Pinmux
- 7 Test firmwares created and working

---

## Objective

Connect **WishbonePwm RTL** (SpinalHDL → Verilog → Verilator → .so) to Renode, replacing the `Tag` with a functional RTL model.

---

## Dependencies to Clone

From `manifest.xml`:
```xml
<project name="aesc-silicon/elements-nafarr" path="modules/elements/nafarr" />
<project name="aesc-silicon/elements-zibal" path="modules/elements/zibal" />
```

**URLs:**
- nafarr: `https://github.com/aesc-silicon/elements-nafarr`
- zibal: `https://github.com/aesc-silicon/elements-zibal`

---

## Implementation Phases

### Phase 1: Clone Dependencies (Session 1)

**Tasks:**
1. Clone nafarr and zibal repositories
2. Verify sbt compilation works

**Commands:**
```bash
cd /home/montanares/personal_exp/digital-twins/ElemRV
mkdir -p modules/elements
git clone https://github.com/aesc-silicon/elements-nafarr modules/elements/nafarr
git clone https://github.com/aesc-silicon/elements-zibal modules/elements/zibal
```

**Commit:** `010a: Add nafarr and zibal submodules for RTL generation`

---

### Phase 2: Install Verilator in Docker (Session 1-2)

**Tasks:**
1. Update `docker/Dockerfile.simulation`
2. Rebuild Docker image with Verilator 5.006
3. Verify installation

**Commit:** `010b: Add Verilator 5.006 to Docker image`

---

### Phase 3: Generate RTL from SpinalHDL (Session 2)

**Tasks:**
1. Generate ECPIX5Top.v using sbt
2. Locate output Verilog file
3. Verify PWM module exists

**Commands:**
```bash
docker run --rm -v $(pwd):/workspace/elemrv \
  -w /workspace/elemrv elemrv-renode:verilator \
  sbt "runMain elemrv_h.ECPIX5.ECPIX5Generate"
```

**Commit:** `010c: Generate RTL Verilog from SpinalHDL (ECPIX5Top)`

---

### Phase 4: Create C++ Wrapper (Session 2-3)

**Files to Create:**
```
renode/verilated/
├── include/
│   └── renode_minimal.h       # Integration headers
├── wrappers/
│   ├── pwm_wrapper.cpp        # Implementation
│   └── Makefile.wrappers      # Build rules
└── .gitignore                 # Ignore generated/ and libs/
```

**Key Implementation:**
- Wishbone bus interface (wb_cyc, wb_stb, wb_we, wb_adr, wb_dat_w, wb_dat_r, wb_ack)
- C interface exported for Renode: `peripheral_create()`, `peripheral_read()`, `peripheral_write()`, `peripheral_tick()`

**Commit:** `010d: Add C++ wrapper for PWM co-simulation`

---

### Phase 5: Compile with Verilator (Session 3)

**Tasks:**
1. Verilator: Verilog → C++
2. Create shared library (.so)
3. Verify library exists

**Commands:**
```bash
# Verilator compilation
docker run --rm -v $(pwd):/workspace/elemrv \
  -w /workspace/elemrv elemrv-renode:verilator \
  verilator --cc --exe --build \
    -CFLAGS "-fPIC -I/usr/local/share/verilator/include" \
    --top-module ECPIX5Top \
    -Mdir renode/verilated/generated/Vpwm \
    gen/ECPIX5.v \
    renode/verilated/wrappers/pwm_wrapper.cpp

# Create shared library
docker run --rm -v $(pwd):/workspace/elemrv \
  -w /workspace/elemrv elemrv-renode:verilator \
  g++ -shared -fPIC \
    -o renode/verilated/libs/libpwm.so \
    renode/verilated/generated/Vpwm/*.o \
    -L/usr/local/lib -lverilated
```

**Commit:** `010e: Build verilated PWM peripheral library`

---

### Phase 6: Integrate into Renode (Session 4)

**Tasks:**
1. Create `elemrv_h_cosim.repl`
2. Replace PWM Tag with CoSimulatedPeripheral
3. Test platform loading

**Configuration:**
```repl
pwm0: CoSimulatedPeripheral @ sysbus 0xF0003000
    simulationFilePath: @renode/verilated/libs/libpwm.so
    frequency: 50000000
    address: 0xF0003000
```

**Commit:** `010f: Integrate co-simulated PWM into Renode platform`

---

### Phase 7: Testing (Session 4-5)

**Tests to Create:**
- `test_stage010_load.sh` - Load test
- `test_stage010_regs.sh` - Register access test
- `test_stage010_functional.sh` - Functional test with firmware

**Commit:** `010g: Add co-simulation tests for PWM`

---

### Phase 8: Documentation (Session 5)

**Tasks:**
1. Update docs/ with co-simulation process
2. Create troubleshooting guide
3. Update session log

**Commit:** `010h: Document PWM RTL co-simulation setup`

---

## Best Practices

### Commits
- Format: `010[a-h]: <description>`
- Language: English
- One commit per completed phase
- Descriptive but concise messages

### Testing
- Each phase must pass tests before continuing
- Document failures in sessions/ if they occur
- No broken code between sessions

### Docker
- All new tools go in Dockerfile
- Nothing on host (except git, basic docker)
- Test image after each change

### Generated Files
- DO NOT commit: Verilator output (obj/, .o, etc.)
- DO commit: .v files, .cpp wrappers, configurations
- Add to .gitignore: renode/verilated/generated/, renode/verilated/libs/

### Documentation
- Create session log at end of each session
- Include: What was done, problems found, solutions
- References: Useful links, important commands

---

## Risks and Plan B

### Risk 1: SBT Compilation Fails
**Symptom:** `sbt compile` fails due to missing dependencies  
**Solution:** Verify nafarr/zibal are in correct paths  
**Plan B:** Use local SpinalHDL if version conflicts

### Risk 2: Verilator Too Slow
**Symptom:** Compilation takes >30 minutes  
**Solution:** Use Docker cache, parallelize with -j$(nproc)  
**Plan B:** Reduce optimization (-O0 instead of -O2)

### Risk 3: Wishbone Interface Mismatch
**Symptom:** Wrappers don't communicate correctly with RTL  
**Solution:** Inspect signals in generated .v, adjust wrapper  
**Plan B:** Use simpler interface (direct registers without bus)

---

## Success Criteria

Stage 010 is **COMPLETE** when:
- ✅ PWM RTL connected to Renode via CoSimulatedPeripheral
- ✅ pwm_test.bin firmware works equal or better than with Tag
- ✅ Can read/write PWM registers without bus errors
- ✅ Automated tests pass
- ✅ Documentation updated

---

## Next Session: Start Phase 1

**At the start of next session:**
1. Read this plan completely
2. Verify current state: `git status`, `git log --oneline -5`
3. Start Phase 1: Clone nafarr and zibal
4. Create session log: `renode/sessions/010-session-01.md`

**First command to run:**
```bash
cd /home/montanares/personal_exp/digital-twins/ElemRV && git status
```

---

## File Locations

This plan is saved at:
- `renode/docs/STAGE_010_IMPLEMENTATION_PLAN.md`

**Do not modify this file** - use it as reference only.
Create session logs in `renode/sessions/` for progress tracking.
