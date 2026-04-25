// SPDX-FileCopyrightText: 2025 aesc silicon
//
// SPDX-License-Identifier: CERN-OHL-W-2.0

package elemrv_h.test

import spinal.core._
import spinal.lib._
import spinal.lib.bus.wishbone._
import nafarr.peripherals.io.pio._

// Generator for WishbonePio Verilog for co-simulation
object WishbonePioVerilog extends App {
  // Create PIO with 3 pins (matching ElemRV-H configuration)
  val pioConfig = PioCtrl.Parameter.default(3)

  // Generate with 32-bit address for Renode IntegrationLibrary compatibility
  SpinalConfig(
    targetDirectory = "digital-twin/gen",
    defaultConfigForClockDomains = ClockDomainConfig(resetKind = ASYNC, resetActiveLevel = LOW)
  ).generateVerilog(
    WishbonePio(
      parameter = pioConfig,
      busConfig = WishboneConfig(32, 32)
    )
  )
}
