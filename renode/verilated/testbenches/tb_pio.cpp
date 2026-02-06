// SPDX-FileCopyrightText: 2025 aesc silicon
//
// SPDX-License-Identifier: CERN-OHL-W-2.0

// Pure Verilator testbench for WishbonePio.
// Matches register operations from run_cosim_pio_test.resc.

#include "verilated.h"
#include "VWishbonePio.h"
#include "wb_helpers.h"

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);

    auto* top = new VWishbonePio();

    printf("=== PIO Pure Verilator Testbench ===\n\n");

    wb_reset(top);
    wb_clock(top, 10);

    // IpIdentification registers
    verify_nonzero("PIO", "IP_HEADER", 0x000, wb_read(top, 0x000));
    verify_nonzero("PIO", "IP_VERSION", 0x004, wb_read(top, 0x004));
    verify_nonzero("PIO", "IP_FEATURES", 0x008, wb_read(top, 0x008));

    // Write clock divider = 0x31, read back
    wb_write(top, 0x01C, 0x31);
    verify("PIO", "CLK_DIV", 0x01C, wb_read(top, 0x01C), 0x00000031);

    // Write read delay = 0x05, read back
    wb_write(top, 0x020, 0x05);
    verify("PIO", "READ_DELAY", 0x020, wb_read(top, 0x020), 0x00000005);

    top->final();
    delete top;

    return summary("PIO");
}
