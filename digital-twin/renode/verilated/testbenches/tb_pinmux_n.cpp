// SPDX-FileCopyrightText: 2025 aesc silicon
//
// SPDX-License-Identifier: CERN-OHL-W-2.0

// Pure Verilator testbench for WishbonePinmux (N-variant, 20 pins).
// No IpIdentification — register map starts at offset 0x00.
// 20 pins, each with 1-bit mux select at pin*4.

#include "verilated.h"
#include "VWishbonePinmux.h"
#include "wb_helpers.h"

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);

    auto* top = new VWishbonePinmux();

    printf("=== Pinmux (N, 20-pin) Pure Verilator Testbench ===\n\n");

    wb_reset(top, (void (*)(VWishbonePinmux*))nullptr);
    wb_clock(top, 10, (void (*)(VWishbonePinmux*))nullptr);

    // Pin 0: default should be 0, write 1, read back
    verify("PINMUX_N", "PIN0_DEFAULT", 0x000, wb_read(top, 0x000), 0x00000000);
    wb_write(top, 0x000, 0x01);
    verify("PINMUX_N", "PIN0_SET1", 0x000, wb_read(top, 0x000), 0x00000001);

    // Pin 5
    wb_write(top, 0x014, 0x01);
    verify("PINMUX_N", "PIN5_SET1", 0x014, wb_read(top, 0x014), 0x00000001);

    // Pin 19 (last pin in 20-pin variant)
    wb_write(top, 0x04C, 0x01);
    verify("PINMUX_N", "PIN19_SET1", 0x04C, wb_read(top, 0x04C), 0x00000001);

    // Overwrite pin 0 back to 0
    wb_write(top, 0x000, 0x00);
    verify("PINMUX_N", "PIN0_CLEAR", 0x000, wb_read(top, 0x000), 0x00000000);

    top->final();
    delete top;

    return summary("PINMUX_N");
}
