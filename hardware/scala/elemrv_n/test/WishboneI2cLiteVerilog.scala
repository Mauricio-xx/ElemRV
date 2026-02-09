// SPDX-FileCopyrightText: 2025 aesc silicon
//
// SPDX-License-Identifier: CERN-OHL-W-2.0

package elemrv_n.test

import spinal.core._
import spinal.lib._
import spinal.lib.bus.wishbone._
import nafarr.peripherals.com.i2c._

// Generator for lightweight WishboneI2cController Verilog for ElemRV-N co-simulation
// Lightweight: 0 external interrupt inputs (port may be absent in Verilog)
object WishboneI2cLiteVerilog extends App {
  val i2cConfig = I2cControllerCtrl.Parameter.lightweight()

  // I2C controller needs clock frequency for SCL clock divider calculation
  SpinalConfig(
    targetDirectory = "gen_n",
    defaultConfigForClockDomains = ClockDomainConfig(resetKind = ASYNC, resetActiveLevel = LOW),
    defaultClockDomainFrequency = FixedFrequency(20 MHz)
  ).generateVerilog(
    WishboneI2cController(
      parameter = i2cConfig,
      busConfig = WishboneConfig(32, 32)
    )
  )
}
