// SPDX-FileCopyrightText: 2025 aesc silicon
//
// SPDX-License-Identifier: CERN-OHL-W-2.0

package elemrv_h.test

import spinal.core._
import spinal.lib._
import spinal.lib.bus.wishbone._
import nafarr.peripherals.io.pwm._

// Generator for WishbonePwm Verilog for co-simulation
object WishbonePwmVerilog extends App {
  // Create PWM with 2 channels (matching ElemRV-H configuration)
  val pwmConfig = PwmCtrl.Parameter.default(2)
  
  // Generate with 32-bit address for Renode IntegrationLibrary compatibility
  SpinalConfig(
    targetDirectory = "gen",
    defaultConfigForClockDomains = ClockDomainConfig(resetKind = ASYNC, resetActiveLevel = LOW)
  ).generateVerilog(
    WishbonePwm(
      parameter = pwmConfig,
      busConfig = WishboneConfig(32, 32)  // 32-bit address, 32-bit data
    )
  )
}
