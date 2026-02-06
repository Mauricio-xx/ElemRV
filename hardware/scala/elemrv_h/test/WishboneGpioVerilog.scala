// SPDX-FileCopyrightText: 2025 aesc silicon
//
// SPDX-License-Identifier: CERN-OHL-W-2.0

package elemrv_h.test

import spinal.core._
import spinal.lib._
import spinal.lib.bus.wishbone._
import nafarr.peripherals.io.gpio._

// Generator for WishboneGpio Verilog for co-simulation
object WishboneGpioVerilog extends App {
  // 12 GPIO pins, 3 interrupt triggers (matching ElemRV-H configuration)
  val gpioConfig = GpioCtrl.Parameter(Gpio.Parameter(12), 3, null, null, null)

  SpinalConfig(
    targetDirectory = "gen",
    defaultConfigForClockDomains = ClockDomainConfig(resetKind = ASYNC, resetActiveLevel = LOW)
  ).generateVerilog(
    WishboneGpio(
      parameter = gpioConfig,
      busConfig = WishboneConfig(32, 32)
    )
  )
}
