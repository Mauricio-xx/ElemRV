// SPDX-FileCopyrightText: 2025 aesc silicon
//
// SPDX-License-Identifier: CERN-OHL-W-2.0

// Pure Verilator testbench for WishboneUart.
// Matches register operations from run_cosim_uart_test.resc.
// Tie-offs: rxd=1 (idle mark), cts=0 (asserted/clear-to-send).
//
// RTL register map (from WishboneUart.v):
//   0x000: IP Header (RO)
//   0x004: IP Version (RO)
//   0x008: IP Features (RO)
//   0x00C: Features 2 (RO)
//   0x010: Fixed value (RO) = 0x00004040
//   0x014: Permission bits (RO)
//   0x018: RX data (RO)
//   0x01C: FIFO status (RO)
//   0x020: Clock Divider (R/W, 20-bit)
//   0x024: Frame config (R/W)

#include "verilated.h"
#include "VWishboneUart.h"
#include "wb_helpers.h"

static void uart_tieoff(VWishboneUart* top) {
    top->io_uart_rxd = 1;
    top->io_uart_cts = 0;
}

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);

    auto* top = new VWishboneUart();

    printf("=== UART Pure Verilator Testbench ===\n\n");

    wb_reset(top, uart_tieoff);
    wb_clock(top, 10, uart_tieoff);

    // IpIdentification registers
    verify_nonzero("UART", "IP_HEADER", 0x000, wb_read(top, 0x000, uart_tieoff));
    verify_nonzero("UART", "IP_VERSION", 0x004, wb_read(top, 0x004, uart_tieoff));
    verify_nonzero("UART", "IP_FEATURES", 0x008, wb_read(top, 0x008, uart_tieoff));

    // Write clock divider = 0x1B2 (434 for 115200 baud at 50MHz)
    // at correct offset 0x020, read back
    wb_write(top, 0x020, 0x1B2, uart_tieoff);
    verify("UART", "CLK_DIV", 0x020, wb_read(top, 0x020, uart_tieoff), 0x000001B2);

    top->final();
    delete top;

    return summary("UART");
}
