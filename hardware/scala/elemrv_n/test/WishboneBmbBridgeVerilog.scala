// SPDX-FileCopyrightText: 2025 aesc silicon
//
// SPDX-License-Identifier: CERN-OHL-W-2.0

package elemrv_n.test

import spinal.core._
import spinal.lib._
import spinal.lib.bus.wishbone._
import spinal.lib.bus.bmb._

// Digital-twin exerciser for the BMB <-> Wishbone transaction path.
// SpinalHDL ships BmbToWishbone (BMB master -> Wishbone master). We need
// the opposite direction to expose a BMB-native peripheral to Renode
// (Renode drives Wishbone). This wrapper bundles:
//
//   WishboneToBmbMaster : single-beat Wishbone slave -> BMB master adapter
//   SimpleBmbRam        : minimal BMB slave backed by an internal Mem
//   WishboneBmbBridge   : top-level that pipes WB into the bridge,
//                         bridge into the RAM
//
// The top is used as a standalone DT test: Renode writes a 32-bit
// pattern through the Wishbone port, reads it back; a PASS confirms the
// WB -> BMB -> Mem -> BMB -> WB round trip works.

case class WishboneToBmbMaster(wbConfig: WishboneConfig, bmbParam: BmbParameter)
    extends Component {
  val io = new Bundle {
    val wb = slave(Wishbone(wbConfig))
    val bmb = master(Bmb(bmbParam))
  }

  val state = RegInit(U(0, 2 bits))
  val IDLE = U(0, 2 bits)
  val ISSUE = U(1, 2 bits)
  val WAIT_RSP = U(2, 2 bits)

  io.wb.ACK := False
  io.wb.DAT_MISO := 0

  io.bmb.cmd.valid := False
  io.bmb.cmd.payload.source := 0
  io.bmb.cmd.payload.context := 0
  io.bmb.cmd.payload.address := (io.wb.ADR << 2).resized
  io.bmb.cmd.payload.length := bmbParam.access.byteCount - 1
  io.bmb.cmd.payload.data := io.wb.DAT_MOSI.asBits.resized
  io.bmb.cmd.payload.mask := B((BigInt(1) << bmbParam.access.byteCount) - 1,
                                bmbParam.access.byteCount bits)
  io.bmb.cmd.payload.last := True
  io.bmb.cmd.payload.opcode := B(0, 1 bits)

  io.bmb.rsp.ready := True

  val writeLatched = Reg(Bool()) init False

  switch(state) {
    is(IDLE) {
      when(io.wb.CYC && io.wb.STB) {
        writeLatched := io.wb.WE
        state := ISSUE
      }
    }
    is(ISSUE) {
      io.bmb.cmd.valid := True
      io.bmb.cmd.payload.opcode := writeLatched.asBits
      when(io.bmb.cmd.ready) {
        state := WAIT_RSP
      }
    }
    is(WAIT_RSP) {
      when(io.bmb.rsp.valid) {
        io.wb.DAT_MISO := io.bmb.rsp.payload.data.asBits.resized
        io.wb.ACK := True
        state := IDLE
      }
    }
  }
}

case class SimpleBmbRam(bmbParam: BmbParameter, sizeWords: Int) extends Component {
  val io = new Bundle {
    val bmb = slave(Bmb(bmbParam))
  }
  require(bmbParam.access.dataWidth == 32, "32-bit BMB expected")

  val mem = Mem(Bits(32 bits), sizeWords)

  val wordAddr = io.bmb.cmd.payload.address(2, log2Up(sizeWords) bits)

  io.bmb.cmd.ready := True

  val cmdFired = io.bmb.cmd.fire
  val wasRead = RegNextWhen(!io.bmb.cmd.payload.isWrite, cmdFired).init(False)
  val srcLatched = RegNextWhen(io.bmb.cmd.payload.source, cmdFired).init(0)
  val ctxLatched = RegNextWhen(io.bmb.cmd.payload.context, cmdFired).init(0)
  val rspValid = RegNext(cmdFired).init(False)

  val readData = mem.readSync(wordAddr, enable = io.bmb.cmd.valid &&
                                                   !io.bmb.cmd.payload.isWrite)

  when(io.bmb.cmd.valid && io.bmb.cmd.payload.isWrite) {
    mem.write(wordAddr, io.bmb.cmd.payload.data,
              mask = io.bmb.cmd.payload.mask)
  }

  io.bmb.rsp.valid := rspValid
  io.bmb.rsp.payload.data := readData
  io.bmb.rsp.payload.last := True
  io.bmb.rsp.payload.source := srcLatched
  io.bmb.rsp.payload.context := ctxLatched
  io.bmb.rsp.setSuccess()
}

case class WishboneBmbBridge() extends Component {
  val ramWords = 256
  val bmbParam = BmbParameter(
    addressWidth = log2Up(ramWords * 4),
    dataWidth = 32,
    lengthWidth = 6,
    sourceWidth = 4,
    contextWidth = 4
  )
  val wbConfig = WishboneConfig(addressWidth = bmbParam.access.addressWidth,
                                 dataWidth = 32)

  val io = new Bundle {
    val wb = slave(Wishbone(wbConfig))
  }

  val bridge = WishboneToBmbMaster(wbConfig, bmbParam)
  val ram = SimpleBmbRam(bmbParam, ramWords)

  bridge.io.wb <> io.wb
  ram.io.bmb <> bridge.io.bmb
}

object WishboneBmbBridgeVerilog extends App {
  SpinalConfig(
    targetDirectory = "gen_n",
    defaultConfigForClockDomains = ClockDomainConfig(resetKind = ASYNC,
                                                      resetActiveLevel = LOW),
    defaultClockDomainFrequency = FixedFrequency(30 MHz)
  ).generateVerilog(WishboneBmbBridge())
}
