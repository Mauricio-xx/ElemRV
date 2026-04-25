// SPDX-FileCopyrightText: 2025 aesc silicon
//
// SPDX-License-Identifier: CERN-OHL-W-2.0

// Pure Verilator testbench for WishboneGpio.
// Matches register operations from run_cosim_gpio_test.resc.
//
// RTL register map (from WishboneGpio.v):
//   0x000: IP Header (RO)
//   0x004: IP Version (RO)
//   0x008: IP Features (RO)
//   0x00C: GPIO pin value (RO, reads external pins)
//   0x010: Output write data (R/W, per-bit, 12-bit)
//   0x014: Direction (RO, hardwired 0xFFF = all output)

#include "verilated.h"
#include "VWishboneGpio.h"
#include "wb_helpers.h"

// Tie-off: GPIO pins read input = 0 (no external connections)
static void gpio_tieoff(VWishboneGpio* top) {
    top->io_gpio_pins_read = 0;
}

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);

    auto* top = new VWishboneGpio();

    printf("=== GPIO Pure Verilator Testbench ===\n\n");

    wb_reset(top, gpio_tieoff);
    wb_clock(top, 10, gpio_tieoff);

    // IpIdentification registers
    verify_nonzero("GPIO", "IP_HEADER", 0x000, wb_read(top, 0x000, gpio_tieoff));
    verify_nonzero("GPIO", "IP_VERSION", 0x004, wb_read(top, 0x004, gpio_tieoff));
    verify_nonzero("GPIO", "IP_FEATURES", 0x008, wb_read(top, 0x008, gpio_tieoff));

    // Write output data = 0x0F (pins 0-3 high), read back
    wb_write(top, 0x010, 0x0F, gpio_tieoff);
    verify("GPIO", "OUTPUT", 0x010, wb_read(top, 0x010, gpio_tieoff), 0x0000000F);

    // Write output data = 0x05 (pins 0,2 high), read back
    wb_write(top, 0x010, 0x05, gpio_tieoff);
    verify("GPIO", "OUTPUT_2", 0x010, wb_read(top, 0x010, gpio_tieoff), 0x00000005);

    top->final();
    delete top;

    return summary("GPIO");
}
