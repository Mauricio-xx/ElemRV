// SPDX-FileCopyrightText: 2025 aesc silicon
//
// SPDX-License-Identifier: CERN-OHL-W-2.0

// Pure Verilator testbench for WishboneMachineTimer.
// Matches register operations from run_cosim_mtimer_test.resc.
// No IpIdentification. Counter auto-increments every clock cycle.
//
// RTL register map (from WishboneMachineTimer.v):
//   0x000: mtime_lo (RO, counter[31:0])
//   0x004: mtime_hi (RO, counter[63:32])
//   0x008: mtimecmp_lo (WO, compare[31:0]) — writing clears counter
//   0x00C: mtimecmp_hi (WO, compare[63:32]) — writing clears counter
//
// Note: mtimecmp registers are write-only — reads return 0.
// Writing to mtimecmp clears the counter (io_clear asserted).

#include "verilated.h"
#include "VWishboneMachineTimer.h"
#include "wb_helpers.h"

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);

    auto* top = new VWishboneMachineTimer();

    printf("=== MachineTimer Pure Verilator Testbench ===\n\n");

    wb_reset(top);

    // Clock 5000 cycles (~100us at 50MHz) to let counter increment
    wb_clock(top, 5000);

    // Read mtime_lo — should be non-zero (auto-incrementing counter)
    verify_nonzero("MTIMER", "MTIME_LO", 0x000, wb_read(top, 0x000));

    // Read mtime_hi — should be 0x00 for short run
    verify("MTIMER", "MTIME_HI", 0x004, wb_read(top, 0x004), 0x00000000);

    // Write mtimecmp_lo = 0x100 (small value)
    // Note: writing clears counter, so mtime resets to 0
    wb_write(top, 0x008, 0x100);
    wb_write(top, 0x00C, 0x0000);

    // Clock enough cycles for counter to exceed mtimecmp (0x100 = 256)
    wb_clock(top, 300);

    // Verify write took effect: interrupt should be asserted
    // (mtime ~= 300 > mtimecmp = 0x100 = 256)
    bool irq = top->io_interrupt;
    printf("VERIFY MTIMER INTERRUPT 0x000 0x%08X non-zero %s\n",
           (uint32_t)irq, irq ? "PASS" : "FAIL");
    if (irq) g_pass_count++;
    else g_fail_count++;

    top->final();
    delete top;

    return summary("MTIMER");
}
