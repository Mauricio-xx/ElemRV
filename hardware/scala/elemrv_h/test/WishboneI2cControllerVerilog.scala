// SPDX-FileCopyrightText: 2025 aesc silicon
//
// SPDX-License-Identifier: CERN-OHL-W-2.0

package elemrv_h.test

import spinal.core._
import spinal.lib._
import spinal.lib.bus.wishbone._
import nafarr.peripherals.com.i2c._

// Generator for WishboneI2cController Verilog for co-simulation
object WishboneI2cControllerVerilog extends App {
  // I2C controller with 1 external interrupt input
  val i2cConfig = I2cControllerCtrl.Parameter.default(1)

  // I2C controller needs clock frequency for SCL clock divider calculation
  SpinalConfig(
    targetDirectory = "gen",
    defaultConfigForClockDomains = ClockDomainConfig(resetKind = ASYNC, resetActiveLevel = LOW),
    defaultClockDomainFrequency = FixedFrequency(50 MHz)
  ).generateVerilog(
    WishboneI2cController(
      parameter = i2cConfig,
      busConfig = WishboneConfig(32, 32)
    )
  )
}
