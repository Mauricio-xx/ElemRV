# Digital Twin Gap Journey (post-Phase-I maturation)

After Phase I closed the "CPU cannot fetch from `CoSimulatedPeripheral`" caveat, the DT looked feature-complete on paper but was still missing some load-bearing correctness checks and coverage. This page documents the gaps surfaced during the maturation pass that became v1.3, what was wrong, and how each was closed. Intended as an internal retrospective — detailed enough that anyone re-entering the XIP DT code can quickly orient on why the wrapper looks the way it does and which tests guard which invariants.

The gap numbering reflects the order each issue was addressed, not severity or importance. All gaps listed here are closed. External-coordination items (upstream Renode contributions, for example) are listed at the end as open.

## Gap 1 — Sub-word MMIO reads (closed)

**What was broken.** After Phase I, test 33i (the bootrom-adapted flow) sporadically aborted with "Illegal instruction at PC=0xF000B022: 0x8293a5a5". It was initially attributed to a VexRiscv IBus quirk interacting with MMIO fetch, and a workaround (`.option norvc` in the XIP-resident assembly so every branch is 4-byte encoded) papered over the problem — all-aligned fetches worked, compressed ones tripped the abort.

**Actual root cause.** Not a CPU or tlib bug. The `bmb_spi_xip_wrapper` Wishbone slave is 32-bit word-addressed: `ADR` indexes words, `DAT_MISO` is 32-bit, and we always returned the full word at the nearest word boundary. Renode's bus framework, however, issues narrower reads (`sel=0x1` for a byte, `sel=0x3` for a half-word) at any byte alignment within the peripheral window, and takes the low N bits of whatever we return. For non-zero byte offsets the low bits of our word-aligned value do not hold the requested slice, so the caller silently got the wrong data. CPU fetches of compressed instructions at word+2 boundaries composed garbage like `0x37373737` (byte-replicated) into "instructions" and branched off into the weeds.

**Fix.** `bmb_spi_xip_wrapper.cpp` `evalModel()` now shifts `g_bridge_rd_dat` right by `(g_bridge_addr & 3) * 8` bits on every read ACK, uniformly for cache-hit and cache-miss paths. The `.option norvc` workaround was removed from 33i; it compiles with compressed instructions and still passes in ~10 s wall.

**Regression guard.** Test 33j (later parameterized in Gap 3.2 #3) runs 9 scenarios covering `byte_off` ∈ {0,1,2,3} via mixed instruction fetch and data loads. Mutation-verified: wrapping the shift in `if (false && ...)` crashes the CPU.

**Scope of impact.** Before the fix, every byte/half-word read from the BmbSpiXip peripheral returned wrong data unless the requested address happened to be word-aligned. Manifested only as a CPU-fetch failure in 33i because the Phase I tests were the only ones issuing non-word-aligned reads through the DT. Data paths in 33f/33g (word-aligned XIP reads) were unaffected. See detailed write-up in `SESSION_LOG.md` under Gap 1.

## Gap 2 — 33i wall-time (closed)

**What was slow.** 33i spent ~23.5 s wall time running 5 s virtual at 30 MHz (~150 M virtual ticks, each = 2 Verilator `eval()`s). Profiling showed >99 % of wall time lived in idle `tick()` calls, not in `evalModel()`'s pump loop. The bus was idle and SPI CS deasserted for nearly every tick, but we still paid for a Verilator `eval()` on each one.

**Fix.** Opt-in `BMBXIP_FAST=1` env var enables two correctness-preserving shortcuts in `bmb_spi_xip_wrapper.cpp`:

1. **Idle-tick shortcut (dominant).** Skip `eval()` when `!io_wb_CYC && io_spi_cs == 1`. No observable state progresses.
2. **Bank-2 fetch cache.** 1024-entry word-indexed cache for XIP data-bank fetches, invalidated on any cfgXip write (see Gap 3.2 #1).

**Measured.** 23.55 s → 10.43 s wall on 33i standalone (2.3× overall, ~3.6× on the sim-only fraction after subtracting Renode's ~5 s startup).

**Why opt-in.** CI preserves full-fidelity coverage by default. `BMBXIP_FAST=1` is wired only around 33i in `run_tests.sh`; other XIP tests run on the standard path.

## Gap 3.1 — Mutation audit (closed)

**What we did.** Manual mutation audit: 8 seeded bugs across `bmb_spi_xip_wrapper.cpp` (3) and `spi_qio_flash_slave.cpp` (5), scored against the 8 tests that touch either wrapper (33b/c/d via `libspi_quad.so`, 33f/g/h/i/j via `libbmb_spi_xip.so`). For each mutation: apply, rebuild, run the 8 tests with a 60 s per-test timeout, record which tests trip, revert.

**Coverage matrix** (`.` = caught, `P` = pass-through / uncaught):

```
mutation                          | 33b 33c 33d | 33f 33g 33h 33i 33j | count
----------------------------------+-------------+---------------------+------
M1 dummy cycles 8->4 (slave)      |  P   .   .  |  P   P   P   P   P  |  2
M2 quad nibble order swap         |  P   .   .  |  P   P   P   P   P  |  2
M3 flash addr +4 offset           |  P   .   .  |  P   P   P   P   P  |  2
M4 revert sub-word shift fix      |  P   P   P  |  P   P   P   .   .  |  2
M5 bank decode XOR bit 10         |  P   P   P  |  P   P   .   .   .  |  3
M6 flash addr step +2             |  P   .   .  |  P   P   .   .   .  |  5
M7 quad nibble XOR bit 0          |  P   .   .  |  P   P   P   P   P  |  2
M8 fetch-cache invalidate off     |  P   P   P  |  P   P   P   P   P  |  0  <-- UNCAUGHT
```

**Findings — three coverage holes surfaced:**

1. **M8 uncaught.** `invalidateFetchCache()` on bank-1 writes was not exercised by any test — no firmware re-fetched from an already-cached XIP data address after a cfgXip write. Addressed in Gap 3.2 #1.
2. **BmbSpiXip tests never issued cmd 0xEB.** All XIP traffic routed through cmd 0x03 (single-IO READ, no dummy cycles, no quad reassembly). The entire Quad I/O infrastructure in the controller and slave was only exercised via `libspi_quad.so` (33b/c/d). Addressed in Gap 3.2 #2 via 33l.
3. **33b weak — doesn't assert returned data.** Tests 33c/33d caught flash-slave mutations; 33b validated "the transaction completes" but not "the returned bytes match expectation". Addressed in Gap 3.2 #4.

**Post-audit state.** `git diff` on mutated files empty; all 8 mutations reverted. Final re-run of the 8-test harness (clean): 8/8 PASS.

## Gap 3.2 #1 — Test 33k: fetch-cache invalidation (closed)

**What was missing.** Zero test coverage for the wrapper's `invalidateFetchCache()` branch (the M8 gap from 3.1). Any mutation disabling the invalidate would silently return stale data for firmware that reconfigured XIP mid-run.

**What the new test does.** Firmware (running from RAM so a miscalibrated XIP protocol after cfgXip write can't crash instruction fetch) reads the same XIP word three times with a cfgXip write sandwiched between reads 2 and 3. The cfgXip write sets mode=0 / dummyCycles=15 (half-cycles — max usable before the controller's 4-bit counter wraps). The subsequent reads still use cmd 0x03, but the controller now emits 8 extra SCLK cycles between ADDR and DATA, so the slave ends up positioned at `rom[1]` rather than `rom[0]` when DATA starts. Post-write read should be `0x04030201` instead of `0x03020100`.

**Hidden bug surfaced.** `bmb_spi_xip_wrapper.cpp` was missing the write-latch extra-posedge pattern that `pwm_wrapper` and `pio_wrapper` use. Writes that should land (the cfgXip reconfiguration above, among others) were being silently dropped. Fixing that uncovered a separate hidden consequence:

**Secondary bug surfaced.** Test 33i was previously passing because its `_init_xip` cfgXip write of `0x007f0702` (mode=2 quad, upstream bootrom value) was one of those silently-dropped writes. With the write-latch fix, the value landed, the controller actually switched to cmd 0xE7 quad — and our flash slave didn't fully handle the quad path end-to-end. Test hung. Pragmatic workaround for this subgap: change `CFGXIP_VALUE` in 33i firmware from `0x007f0702` to `0x00000000` (still exercises the configure state machine + WREN + WRITE_REGISTER, but keeps subsequent fetches on cmd 0x03). Queued as Gap 3.2 #2 to restore upstream fidelity once the QPI path is validated.

**Verdict value.** 33k uses the literal `0xCA5E0001` as the pass marker in `run_tests.sh` instead of a PASSED string — deterministic across environments.

## Gap 3.2 #4 — Test 33b assertions (closed)

**What was wrong.** 33b already exercised RDID (0x9F), Fast Read 0x0B, and Quad I/O Fast Read 0xEB — and logged each response-FIFO read with "expect 0xXXXX" comments. But the final `log "=== N SPI Quad Flash Co-simulation Test PASSED ==="` fired unconditionally: any flash-slave mutation changed the logged bytes but left the test marker green. From the mutation audit (Gap 3.1), 0/5 flash-data mutations were caught by 33b.

**Fix.** Replaced the unconditional log with an inline `python """..."""` assertion block at the tail of the `.resc`. The python block reads the response FIFO 7 times (3 from RDID + 2 from Fast Read + 2 from Quad I/O), compares each word against the expected value, logs `[assert PASS/FAIL] <label> got=0xXXXXXXXX expected=0xXXXXXXXX`, and emits the PASS marker only when all 7 match.

**Renode scripting note.** The Renode `.resc` triple-quoted python idiom (`python """<multi-line>"""`) is officially supported in 1.16.0 — an earlier historical note about "python syntax broken" referred to the single-line `python "if cond: ..."` form, which IronPython 2.7 rejects as a compound one-liner. The triple-quoted form accepts full Python blocks, with `monitor.Machine.SystemBus.ReadDoubleWord(addr)` / `WriteDoubleWord(addr, value)` directly callable.

**Mutation-catch improvement.** 0/5 → 5/5 flash-data mutations that touch response bytes. M1 (manufacturer ID), M2 (MT25Q family), M3 (capacity), M6/M7 (rom-pattern reads) all caught.

## Gap 3.2 #2 — Test 33l: QPI handshake end-to-end (closed)

**What was missing.** The entire Quad I/O infrastructure in the BmbSpiXip DT was dead code from the mutation audit's perspective: all XIP traffic through 33f/g/h/i/j went via cmd 0x03 single-IO. No test exercised cmd=0xE7 quad fetches end-to-end. Meanwhile, 33i's `_init_xip` had been worked around to write `0x00000000` as the cfgXip value (Gap 3.2 #1 consequence) instead of the upstream bootrom's `0x007f0702`.

**Key finding during scoping.** The initial mental model "start with mode=1 dual since it's simpler" was wrong: `spi_qio_flash_slave.cpp` does not decode 0xBB (dual I/O Fast Read) at all — only 0x06/0x61/0x81/0x9F/0x03/0x0B/0xEB/0xE7. And nafarr's `SpiXipControllerCtrl` issues the opcode byte itself in the current `mode`, so with `mode=2` the cmd byte goes in quad on all four IO lines. That is the MT25Q **QPI (Quad Peripheral Interface)** convention: the host writes `EVCR` via `WRITE_REGISTER (0x61)` clearing bit 7, and thereafter all commands arrive in quad.

**Slave changes** (`spi_qio_flash_slave.{h,cpp}`):

- New `m_qpi_enabled` member, reset to `false`.
- On CS-assert: `m_rx_width = m_qpi_enabled ? 4 : 1`. Without QPI, CMD is sampled in single; with QPI, in 4-bit nibbles (2 SCLK cycles per command byte).
- `0x61` handler: read 1 data byte (was 2 — nafarr's `configureFlash` only emits a single evcr byte; waiting for two left the slave stuck mid-transaction).
- On completion of the 0x61 DATA_IN byte: capture the received byte as evcr, set `m_qpi_enabled = ((evcr >> 7) & 1) == 0`.
- `0xE7` (post-ADDR transition): skip MODE_BYTE, go directly to DUMMY. Matches nafarr's state machine. Conventional `0xEB` still goes ADDR → MODE_BYTE → DUMMY → DATA, preserving 33b/33c/33d's expectations.

**Wrapper change** (`bmb_spi_xip_wrapper.cpp`): `setDummyCycles(8)` → `setDummyCycles(4)`. Rationale: nafarr's `configureFlash` writes `configuration.dummyCycles` into `SpiController.CmdDummyCycles.cycles` (half-cycles), so upstream `cfgXip=0x007F0702` (dummyCycles=7) emits 4 SCLK dummy cycles on the wire. Non-quad tests on `libbmb_spi_xip.so` all use cmd=0x03 which bypasses DUMMY entirely, so this change is invisible to them.

**33l itself.** Reads baseline via cmd=0x03, writes `cfgXip=0x007F0702` + pulses the trigger, lets WREN + WRITE_REGISTER + EVCR latch run, then re-reads asserting the rom pattern is unchanged through cmd=0xE7 quad fetches. Mutation-verified.

**33i restored.** `CFGXIP_VALUE` back to the upstream `0x007f0702`. Wall time unchanged (~5–7 s with `BMBXIP_FAST=1`). Post-latch CPU fetches now go through the quad protocol end-to-end, matching the upstream bootrom.

## Gap 3.2 #3 — Test 33j: parameterized sub-word regression harness (closed)

**What was weak.** The original 33j was a one-shot repro for the Gap 1 sub-word bug: one c.jal to a word-aligned subroutine, then `0xCAFEBEEF` to `RAM[0x100]`, then the `.resc` emitted `"...PASSED"` unconditionally after a 5 s run. Same anti-pattern as 33b pre-Gap-3.2 #4: the regression guard was a guard in name only.

**Scope expansion.** 9 scenarios, one firmware, single resc, replaces previous 33j in place (suite count stays 63). Each scenario writes its own marker slot in RAM on success; python asserts every slot, emits PASSED only when all match.

| Slot | Addr          | Scenario                                             | byte_off | Path                        |
|------|---------------|------------------------------------------------------|----------|-----------------------------|
| S1   | `0x80000100`  | overall end-of-firmware (`0xCAFEBEEF`)               | —        | firmware reached completion |
| S2   | `0x80000104`  | c.jal → word-aligned sub                             | 0        | instr fetch                 |
| S3   | `0x80000108`  | c.jal → word+2 sub (c.nop shim before label)         | 2        | instr fetch of target       |
| S4   | `0x8000010C`  | uncompressed jal at word+2 PC                        | 2        | instr fetch straddling word |
| S5   | `0x80000110`  | mixed C+uncompressed arithmetic (sum=31)             | 0+2      | mixed fetch                 |
| S6   | `0x80000114`  | `lw`  from XIP rodata word+0                         | 0        | data fetch (control)        |
| S7   | `0x80000118`  | `lhu` from XIP rodata word+2                         | 2        | data fetch                  |
| S8   | `0x8000011C`  | `lbu` from XIP rodata word+1                         | 1        | data fetch                  |
| S9   | `0x80000120`  | `lbu` from XIP rodata word+3                         | 3        | data fetch                  |

Known rodata blob `_xip_bytes = DE AD BE EF CA FE BA BE` lets `lw/lhu/lbu` expected values be precomputed (little-endian): `0xEFBEADDE`, `0x0000EFBE`, `0xAD`, `0xEF`.

**Alignment tricks.** S3 uses `.balign 4` + `.half 0x0001` (c.nop shim) immediately before `_s3_sub:` so the label lands at word+2. S4 uses the same shim before a `.option push; .option norvc; jal _s4_sub; .option pop` block so a 4-byte `jal` is emitted at word+2 PC. Confirmed in the `.lst`: jal at `0xf000b03a`, `_s3_sub` at `0xf000b0da`.

**Data loads via `la` (auipc+addi).** PC-relative addressing resolves `_xip_bytes` from within the same XIP bank — no hardcoded absolute. Works because executable-IO covers the full 4 KiB range and the wrapper's sub-word shift applies uniformly to instruction and data fetches.

**Mutation verification.** Wrapping `bmb_spi_xip_wrapper.cpp`'s sub-word shift in `if (false && ...)` crashes the CPU mid-run (Illegal instruction trap during `_s2_sub` whose caller's c.jal at word+0 returns via the corrupted sub-word path). No `"...PASSED"` line emitted, `run_tests.sh` marker grep misses, test reported FAIL. Even a mutation subtle enough to skip the CPU abort would be caught: 9 distinct assertions, each depends on a different shift path.

## Gap 4 — Pre-PR hygiene: `reuse lint` + `scalafmt --check` (closed)

**Scope.** Not in the original plan; defined in a resume prompt as "verify the DT branch passes `reuse lint` + `scalafmt --check hardware/` locally, so any future PR to upstream main doesn't face CI surprises." Upstream workflows (`.github/workflows/{format,license-check}.yaml`) only trigger on `main` — the DT branch gets no CI coverage until merge. Full clean (Option A) chosen over narrower scoping.

**reuse lint.** 246 tracked files missing copyright/license info. Biggest bucket: 116 files in `digital-twin/zephyr/elemrv-zephyr/` (out-of-tree Zephyr module) — most declared Apache-2.0 inline but lacked `SPDX-FileCopyrightText`. Other buckets: DT docs, test driver `.resc` files, platform `.repl` files, bare-metal firmware build artefacts (`.bin/.elf/.lst/.img`), generated Verilog under `digital-twin/gen/**` + `digital-twin/gen_n/**`, tracked `.gitignore` files, per-user `.claude/settings.local.json` (gitignored but reuse 6.2.0 does not honour `.gitignore`).

**Fix.** Bulk path annotations in `REUSE.toml` — 103 lines added, one `[[annotations]]` block per bucket. REUSE 3.3 treats these as fallbacks for files missing info, so in-file headers still take precedence.

**scalafmt.** Four DT-added generators flagged by `scalafmt --check hardware/`:

- `digital-twin/scala/elemrv_h/SimpleWishboneReg.scala`
- `digital-twin/scala/elemrv_h/WishbonePwmVerilog.scala`
- `digital-twin/scala/elemrv_n/WishboneBmbBridgeVerilog.scala`
- `digital-twin/scala/elemrv_n/WishboneBmbSpiXipControllerVerilog.scala`

All violations cosmetic — trailing whitespace on blank lines, missing space before parenthesized method args (`init(0)` → `init (0)`), over-wide single-line constructor calls the project's profile wants expanded. Pure reformatting — no semantic change. `sbt compile` clean; full 63-test suite green.

**Tooling notes.**

- Container doesn't have `reuse` by default — install via `pip install reuse`.
- Install `scalafmt` via `cs install scalafmt` (coursier), matching how `format.yaml` does it. `sbt scalafmtCheck` fails because the project doesn't enable the sbt plugin.
- Run `git config --global --add safe.directory '*'` once inside the container or reuse/git refuses to operate on mounted volumes.

## Open items

- **Upstream Renode contribution** — the `RegisterAccessFlags` trick used in Phase I to flip `IO_MEM_EXECUTABLE_IO` for a `CoSimulatedPeripheral` range is not documented as a supported pattern. Worth contributing either an `executable=true` attribute on `CoSimulatedPeripheral` (surface it at the Renode language level) or a runtime helper so downstream users don't have to reach for `cpu RegisterAccessFlags` manually. External-coordination work; no priority deadline.

---

**Previous:** [Test Suite](../reference/test-suite.md)
**See also:** [Co-simulation Guide](../features/co-simulation.md), [Architecture Overview](../architecture.md)
