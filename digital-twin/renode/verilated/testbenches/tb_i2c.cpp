// SPDX-FileCopyrightText: 2025 aesc silicon
//
// SPDX-License-Identifier: CERN-OHL-W-2.0

// Pure Verilator testbench for WishboneI2cController.
// Matches register operations from run_cosim_i2c_test.resc.
// Tie-offs: scl_read=1, sda_read=1 (idle/pulled-up), interrupts=0.
//
// RTL register map (from WishboneI2cController.v):
//   0x000: IP Header (RO)
//   0x004: IP Version (RO)
//   0x008: IP Features (RO)
//   0x00C: Status (RO)
//   0x010: Permission bits (RO)
//   0x014: Response data (RO)
//   0x018: FIFO status (RO)
//   0x01C: Clock Divider (R/W, 16-bit)
//   0x024: Interrupt occupancy trigger (R/W)

#include "verilated.h"
#include "VWishboneI2cController.h"
#include "wb_helpers.h"

static void i2c_tieoff(VWishboneI2cController* top) {
    top->io_i2c_scl_read = 1;
    top->io_i2c_sda_read = 1;
    top->io_i2c_interrupts = 0;
}

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);

    auto* top = new VWishboneI2cController();

    printf("=== I2C Pure Verilator Testbench ===\n\n");

    wb_reset(top, i2c_tieoff);
    wb_clock(top, 10, i2c_tieoff);

    // IpIdentification registers
    verify_nonzero("I2C", "IP_HEADER", 0x000, wb_read(top, 0x000, i2c_tieoff));
    verify_nonzero("I2C", "IP_VERSION", 0x004, wb_read(top, 0x004, i2c_tieoff));
    verify_nonzero("I2C", "IP_FEATURES", 0x008, wb_read(top, 0x008, i2c_tieoff));

    // Write clock divider = 0x64 at correct offset 0x01C, read back
    wb_write(top, 0x01C, 0x64, i2c_tieoff);
    verify("I2C", "CLK_DIV", 0x01C, wb_read(top, 0x01C, i2c_tieoff), 0x00000064);

    top->final();
    delete top;

    return summary("I2C");
}
