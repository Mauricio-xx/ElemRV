// SPDX-FileCopyrightText: 2025 aesc silicon
//
// SPDX-License-Identifier: CERN-OHL-W-2.0

package elemrv_h.test

import spinal.core._
import spinal.lib._
import spinal.lib.bus.wishbone._

case class SimpleWishboneReg() extends Component {
  val io = new Bundle {
    val bus = slave(
      Wishbone(
        WishboneConfig(
          addressWidth = 32, // 32-bit address for Renode IntegrationLibrary compatibility
          dataWidth = 32
        )
      )
    )
    val led = out Bits (8 bits)
  }

  val regs = Vec(Reg(UInt(32 bits)) init (0), 16)

  // Use only lower 4 bits of address for register index
  val regIndex = io.bus.ADR(3 downto 0)

  // Default assignments
  io.bus.ACK := False
  io.bus.DAT_MISO := 0

  // Wishbone transaction logic - single cycle ACK
  when(io.bus.CYC && io.bus.STB) {
    io.bus.ACK := True

    when(io.bus.WE) {
      // Write transaction
      regs(regIndex) := io.bus.DAT_MOSI.asUInt
    } otherwise {
      // Read transaction
      io.bus.DAT_MISO := regs(regIndex).asBits
    }
  }

  // Connect first register to LEDs for visual feedback
  io.led := regs(0)(7 downto 0).asBits
}

// Generator object
object SimpleWishboneRegVerilog extends App {
  SpinalConfig(
    targetDirectory = "digital-twin/gen",
    defaultConfigForClockDomains = ClockDomainConfig(resetKind = ASYNC, resetActiveLevel = LOW)
  ).generateVerilog(SimpleWishboneReg())
}
