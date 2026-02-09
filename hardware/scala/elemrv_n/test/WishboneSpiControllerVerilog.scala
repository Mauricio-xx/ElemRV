// SPDX-FileCopyrightText: 2025 aesc silicon
//
// SPDX-License-Identifier: CERN-OHL-W-2.0

package elemrv_n.test

import spinal.core._
import spinal.lib._
import spinal.lib.bus.wishbone._
import nafarr.peripherals.com.spi.{SpiControllerCtrl, WishboneSpiController}

// Generator for WishboneSpiController Verilog for ElemRV-N co-simulation
object WishboneSpiControllerVerilog extends App {
  val spiConfig = SpiControllerCtrl.Parameter.default()

  // SPI controller needs clock frequency for clock divider calculation
  SpinalConfig(
    targetDirectory = "gen_n",
    defaultConfigForClockDomains = ClockDomainConfig(resetKind = ASYNC, resetActiveLevel = LOW),
    defaultClockDomainFrequency = FixedFrequency(20 MHz)
  ).generateVerilog(
    WishboneSpiController(
      parameter = spiConfig,
      busConfig = WishboneConfig(32, 32)
    )
  )
}
