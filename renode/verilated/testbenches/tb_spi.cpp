// SPDX-FileCopyrightText: 2025 aesc silicon
//
// SPDX-License-Identifier: CERN-OHL-W-2.0

// Pure Verilator testbench for WishboneSpiController.
// Validates IpIdentification and clock divider register.

#include "verilated.h"
#include "VWishboneSpiController.h"
#include "wb_helpers.h"

// Tie-off: SPI TriState dq read inputs = 0
static void spi_tieoff(VWishboneSpiController* top) {
    top->io_spi_dq_0_read = 0;
    top->io_spi_dq_1_read = 0;
}

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);

    auto* top = new VWishboneSpiController();

    printf("=== SPI Controller Pure Verilator Testbench ===\n\n");

    wb_reset(top, spi_tieoff);
    wb_clock(top, 10, spi_tieoff);

    // IpIdentification registers
    verify_nonzero("SPI", "IP_HEADER", 0x000, wb_read(top, 0x000, spi_tieoff));
    verify_nonzero("SPI", "IP_VERSION", 0x004, wb_read(top, 0x004, spi_tieoff));
    verify_nonzero("SPI", "IP_FEATURES", 0x008, wb_read(top, 0x008, spi_tieoff));

    // Write clock divider and read back
    wb_write(top, 0x010, 0x0A, spi_tieoff);
    verify("SPI", "CLK_DIV", 0x010, wb_read(top, 0x010, spi_tieoff), 0x0000000A);

    top->final();
    delete top;

    return summary("SPI");
}
