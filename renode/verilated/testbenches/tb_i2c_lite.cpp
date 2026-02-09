// SPDX-FileCopyrightText: 2025 aesc silicon
//
// SPDX-License-Identifier: CERN-OHL-W-2.0

// Pure Verilator testbench for WishboneI2cController (lightweight).
// Validates IpIdentification and clock divider register.
// No io_i2c_interrupts port in lightweight variant.

#include "verilated.h"
#include "VWishboneI2cController.h"
#include "wb_helpers.h"

// Tie-off: I2C bus lines high (idle/pulled-up)
static void i2c_lite_tieoff(VWishboneI2cController* top) {
    top->io_i2c_scl_read = 1;
    top->io_i2c_sda_read = 1;
}

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);

    auto* top = new VWishboneI2cController();

    printf("=== I2C Lite Pure Verilator Testbench ===\n\n");

    wb_reset(top, i2c_lite_tieoff);
    wb_clock(top, 10, i2c_lite_tieoff);

    // IpIdentification registers
    verify_nonzero("I2C_LITE", "IP_HEADER", 0x000, wb_read(top, 0x000, i2c_lite_tieoff));
    verify_nonzero("I2C_LITE", "IP_VERSION", 0x004, wb_read(top, 0x004, i2c_lite_tieoff));
    verify_nonzero("I2C_LITE", "IP_FEATURES", 0x008, wb_read(top, 0x008, i2c_lite_tieoff));

    // Write clock divider and read back
    wb_write(top, 0x010, 0x64, i2c_lite_tieoff);
    verify("I2C_LITE", "CLK_DIV", 0x010, wb_read(top, 0x010, i2c_lite_tieoff), 0x00000064);

    top->final();
    delete top;

    return summary("I2C_LITE");
}
