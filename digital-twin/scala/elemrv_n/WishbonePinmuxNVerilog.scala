// SPDX-FileCopyrightText: 2025 aesc silicon
//
// SPDX-License-Identifier: CERN-OHL-W-2.0

package elemrv_n.test

import spinal.core._
import spinal.lib._
import spinal.lib.bus.wishbone._
import nafarr.peripherals.pinmux._

import scala.collection.mutable.ArrayBuffer

// Generator for WishbonePinmux Verilog for ElemRV-N co-simulation
// 20 pins, each with 2 mux options (40 total inputs)
object WishbonePinmuxNVerilog extends App {
  val pinmuxConfig = PinmuxCtrl.Parameter(Pinmux.Parameter(20), 40, 2)

  // Dummy mapping: 20 pins, each selects between 2 options
  val mapping = ArrayBuffer.tabulate(20)(i => (i, List(i * 2, i * 2 + 1)))

  SpinalConfig(
    targetDirectory = "gen_n",
    defaultConfigForClockDomains = ClockDomainConfig(resetKind = ASYNC, resetActiveLevel = LOW)
  ).generateVerilog(
    WishbonePinmux(
      parameter = pinmuxConfig,
      mapping = mapping,
      busConfig = WishboneConfig(32, 32)
    )
  )
}
