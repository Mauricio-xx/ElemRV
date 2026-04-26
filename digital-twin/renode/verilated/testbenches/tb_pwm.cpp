// SPDX-FileCopyrightText: 2025 aesc silicon
//
// SPDX-License-Identifier: CERN-OHL-W-2.0

// Pure Verilator testbench for WishbonePwm.
// Matches register operations from run_pwm_test.resc.

#include "verilated.h"
#include "VWishbonePwm.h"
#include "wb_helpers.h"

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);

    auto* top = new VWishbonePwm();

    printf("=== PWM Pure Verilator Testbench ===\n\n");

    // Reset
    wb_reset(top);

    // Let peripheral settle
    wb_clock(top, 10);

    // Read-only IpIdentification registers
    verify("PWM", "IP_HEADER",  0x000, wb_read(top, 0x000), 0x00080002);
    verify("PWM", "IP_VERSION", 0x004, wb_read(top, 0x004), 0x01000000);
    verify("PWM", "IP_FEATURES",0x008, wb_read(top, 0x008), 0x14141402);

    // Write Clock Divider = 0x31, read back
    wb_write(top, 0x010, 0x31);
    verify("PWM", "CLK_DIV", 0x010, wb_read(top, 0x010), 0x00000031);

    // Write CH0 Control = 0x01 (enable), read back
    wb_write(top, 0x014, 0x01);
    verify("PWM", "CH0_CTRL", 0x014, wb_read(top, 0x014), 0x00000001);

    // Write CH0 Period = 0x3E8 (1000), read back
    wb_write(top, 0x018, 0x3E8);
    verify("PWM", "CH0_PERIOD", 0x018, wb_read(top, 0x018), 0x000003E8);

    // Write CH0 Pulse = 0x1F4 (500), read back
    wb_write(top, 0x01C, 0x1F4);
    verify("PWM", "CH0_PULSE", 0x01C, wb_read(top, 0x01C), 0x000001F4);

    // Write CH1 Period = 0x7D0 (2000), read back
    wb_write(top, 0x024, 0x7D0);
    verify("PWM", "CH1_PERIOD", 0x024, wb_read(top, 0x024), 0x000007D0);

    top->final();
    delete top;

    return summary("PWM");
}
