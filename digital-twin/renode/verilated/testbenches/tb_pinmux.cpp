// SPDX-FileCopyrightText: 2025 aesc silicon
//
// SPDX-License-Identifier: CERN-OHL-W-2.0

// Pure Verilator testbench for WishbonePinmux.
// Matches register operations from run_cosim_pinmux_test.resc.
// No IpIdentification — register map starts at offset 0x00.

#include "verilated.h"
#include "VWishbonePinmux.h"
#include "wb_helpers.h"

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);

    auto* top = new VWishbonePinmux();

    printf("=== Pinmux Pure Verilator Testbench ===\n\n");

    wb_reset(top);
    wb_clock(top, 10);

    // Write pin 0 = 0x01, read back
    wb_write(top, 0x000, 0x01);
    verify("PINMUX", "PIN_0", 0x000, wb_read(top, 0x000), 0x00000001);

    // Write pin 1 = 0x00, read back
    wb_write(top, 0x004, 0x00);
    verify("PINMUX", "PIN_1", 0x004, wb_read(top, 0x004), 0x00000000);

    // Write pin 5 = 0x01, read back
    wb_write(top, 0x014, 0x01);
    verify("PINMUX", "PIN_5", 0x014, wb_read(top, 0x014), 0x00000001);

    // Write pin 11 = 0x01, read back
    wb_write(top, 0x02C, 0x01);
    verify("PINMUX", "PIN_11", 0x02C, wb_read(top, 0x02C), 0x00000001);

    top->final();
    delete top;

    return summary("PINMUX");
}
