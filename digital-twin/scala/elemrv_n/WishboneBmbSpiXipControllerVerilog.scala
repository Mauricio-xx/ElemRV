// SPDX-FileCopyrightText: 2025 aesc silicon
//
// SPDX-License-Identifier: CERN-OHL-W-2.0

package elemrv_n.test

import spinal.core._
import spinal.lib._
import spinal.lib.bus.wishbone._
import spinal.lib.bus.bmb._
import nafarr.peripherals.com.spi.{Spi, SpiControllerCtrl}
import nafarr.memory.spi.BmbSpiXipController

// G.1c: Full BmbSpiXipController digital-twin wrapper.
//
// Exposes the three internal buses as a single Wishbone slave so Renode
// can drive everything through one CoSimulatedPeripheral:
//   0x0000..0x0FFF  -> cfgSpiBus (SPI master config)
//   0x1000..0x1FFF  -> cfgXipBus (XIP config: mode/dummyCycles/evcr)
//   0x2000..0x2FFF  -> XIP data (BMB read-only data bus via
//                                 WishboneToBmbMaster bridge)
//
// The SPI master pins (4-bit Quad I/O) are routed to the top so the
// C++ wrapper can attach the SpiQioFlashSlave behavioral model.

case class WishboneBmbSpiXipController() extends Component {
  val spiParam = SpiControllerCtrl.Parameter.xip()
  val dataRomBytes = 0x1000
  val dataBusParam = BmbParameter(
    addressWidth = log2Up(dataRomBytes),
    dataWidth = 32,
    lengthWidth = 6,
    sourceWidth = 4,
    contextWidth = 4
  )
  val wbCfg = WishboneConfig(addressWidth = 14, dataWidth = 32)

  val io = new Bundle {
    val wb = slave(Wishbone(wbCfg))
    val spi = master(Spi.Io(spiParam.io))
    val interrupt = out(Bool)
  }

  val cfgSpiWb = Wishbone(wbCfg.copy(addressWidth = 10))
  val cfgXipWb = Wishbone(wbCfg.copy(addressWidth = 10))
  val dataWb = Wishbone(wbCfg.copy(addressWidth = log2Up(dataRomBytes / 4)))

  cfgSpiWb.CYC := False
  cfgSpiWb.STB := False
  cfgSpiWb.WE := io.wb.WE
  cfgSpiWb.ADR := io.wb.ADR.resized
  cfgSpiWb.DAT_MOSI := io.wb.DAT_MOSI

  cfgXipWb.CYC := False
  cfgXipWb.STB := False
  cfgXipWb.WE := io.wb.WE
  cfgXipWb.ADR := io.wb.ADR.resized
  cfgXipWb.DAT_MOSI := io.wb.DAT_MOSI

  dataWb.CYC := False
  dataWb.STB := False
  dataWb.WE := io.wb.WE
  dataWb.ADR := io.wb.ADR.resized
  dataWb.DAT_MOSI := io.wb.DAT_MOSI

  // Word-addressed WB: each 4 KiB byte bank = 1024 words, so bank bits
  // start at ADR[10]. Two bank-select bits give 4 KiB * 4 = 16 KiB span.
  val bank = io.wb.ADR(10, 2 bits)
  val active = io.wb.CYC && io.wb.STB
  when(active && bank === U(0)) { cfgSpiWb.CYC := True; cfgSpiWb.STB := True }
  when(active && bank === U(1)) { cfgXipWb.CYC := True; cfgXipWb.STB := True }
  when(active && bank === U(2)) { dataWb.CYC := True; dataWb.STB := True }

  io.wb.ACK := cfgSpiWb.ACK | cfgXipWb.ACK | dataWb.ACK
  io.wb.DAT_MISO := Mux(
    cfgSpiWb.ACK,
    cfgSpiWb.DAT_MISO,
    Mux(cfgXipWb.ACK, cfgXipWb.DAT_MISO, dataWb.DAT_MISO)
  )

  val ctrl = BmbSpiXipController(spiParam, dataBusParam, wbCfg)
  ctrl.io.cfgSpiBus <> cfgSpiWb
  ctrl.io.cfgXipBus <> cfgXipWb
  ctrl.io.spi <> io.spi
  io.interrupt := ctrl.io.interrupt

  val dataBridge = WishboneToBmbMaster(dataWb.config, dataBusParam)
  dataBridge.io.wb <> dataWb
  ctrl.io.dataBus <> dataBridge.io.bmb
}

object WishboneBmbSpiXipControllerVerilog extends App {
  SpinalConfig(
    targetDirectory = "digital-twin/gen_n",
    defaultConfigForClockDomains = ClockDomainConfig(resetKind = ASYNC, resetActiveLevel = LOW),
    defaultClockDomainFrequency = FixedFrequency(30 MHz)
  ).generateVerilog(WishboneBmbSpiXipController())
}
