// SPDX-FileCopyrightText: 2025 aesc silicon
//
// SPDX-License-Identifier: CERN-OHL-W-2.0

package elemrv_h.test

import spinal.core._
import spinal.lib._
import spinal.lib.bus.wishbone._
import nafarr.system.mtimer._

// Generator for WishboneMachineTimer Verilog for co-simulation
object WishboneMachineTimerVerilog extends App {
  // RISC-V standard mtime/mtimecmp (NOT LiteX timer layout)
  val timerConfig = MachineTimerCtrl.Parameter.default

  // MachineTimer needs clock frequency for tick counter derivation
  SpinalConfig(
    targetDirectory = "gen",
    defaultConfigForClockDomains = ClockDomainConfig(resetKind = ASYNC, resetActiveLevel = LOW),
    defaultClockDomainFrequency = FixedFrequency(50 MHz)
  ).generateVerilog(
    WishboneMachineTimer(
      parameter = timerConfig,
      busConfig = WishboneConfig(32, 32)
    )
  )
}
