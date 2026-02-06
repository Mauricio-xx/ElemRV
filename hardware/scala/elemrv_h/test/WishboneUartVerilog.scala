// SPDX-FileCopyrightText: 2025 aesc silicon
//
// SPDX-License-Identifier: CERN-OHL-W-2.0

package elemrv_h.test

import spinal.core._
import spinal.lib._
import spinal.lib.bus.wishbone._
import nafarr.peripherals.com.uart._

// Generator for WishboneUart Verilog for co-simulation
object WishboneUartVerilog extends App {
  // Full UART with TX/RX/CTS/RTS
  val uartConfig = UartCtrl.Parameter.full()

  // NOTE: UartCtrl needs clock frequency for baud rate divider calculation
  SpinalConfig(
    targetDirectory = "gen",
    defaultConfigForClockDomains = ClockDomainConfig(resetKind = ASYNC, resetActiveLevel = LOW),
    defaultClockDomainFrequency = FixedFrequency(50 MHz)
  ).generateVerilog(
    WishboneUart(
      parameter = uartConfig,
      busConfig = WishboneConfig(32, 32)
    )
  )
}
