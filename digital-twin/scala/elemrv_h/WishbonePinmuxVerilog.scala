// SPDX-FileCopyrightText: 2025 aesc silicon
//
// SPDX-License-Identifier: CERN-OHL-W-2.0

package elemrv_h.test

import spinal.core._
import spinal.lib._
import spinal.lib.bus.wishbone._
import nafarr.peripherals.pinmux._

import scala.collection.mutable.ArrayBuffer

// Generator for WishbonePinmux Verilog for co-simulation
object WishbonePinmuxVerilog extends App {
  // 12 pins, each with 2 mux options (24 total inputs)
  val pinmuxConfig = PinmuxCtrl.Parameter(Pinmux.Parameter(12), 24, 2)

  // Dummy mapping: 12 pins, each selects between 2 options
  // Only affects internal pin routing, NOT the Wishbone register interface
  val mapping = ArrayBuffer.tabulate(12)(i => (i, List(i * 2, i * 2 + 1)))

  SpinalConfig(
    targetDirectory = "digital-twin/gen",
    defaultConfigForClockDomains = ClockDomainConfig(resetKind = ASYNC, resetActiveLevel = LOW)
  ).generateVerilog(
    WishbonePinmux(
      parameter = pinmuxConfig,
      mapping = mapping,
      busConfig = WishboneConfig(32, 32)
    )
  )
}
