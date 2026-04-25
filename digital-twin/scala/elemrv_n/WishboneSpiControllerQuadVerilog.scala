// SPDX-FileCopyrightText: 2025 aesc silicon
//
// SPDX-License-Identifier: CERN-OHL-W-2.0

package elemrv_n.test

import spinal.core._
import spinal.lib._
import spinal.lib.bus.wishbone._
import nafarr.peripherals.com.spi.{SpiControllerCtrl, WishboneSpiController}

// Generator for a Quad-I/O-capable WishboneSpiController, used by the
// digital-twin Quad I/O flash co-simulation. Exposes io_spi_dq[3:0] so
// software can drive single, dual or quad transactions via the mode
// field of the command stream.
object WishboneSpiControllerQuadVerilog extends App {
  val spiConfig = SpiControllerCtrl.Parameter.xip()

  SpinalConfig(
    targetDirectory = "digital-twin/gen_n",
    defaultConfigForClockDomains = ClockDomainConfig(resetKind = ASYNC, resetActiveLevel = LOW),
    defaultClockDomainFrequency = FixedFrequency(30 MHz)
  ).generateVerilog {
    val top = WishboneSpiController(
      parameter = spiConfig,
      busConfig = WishboneConfig(32, 32)
    )
    top.setDefinitionName("WishboneSpiControllerQuad")
    top
  }
}
