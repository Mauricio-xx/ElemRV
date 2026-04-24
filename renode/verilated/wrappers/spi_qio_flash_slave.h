// SPDX-FileCopyrightText: 2025 aesc silicon
//
// SPDX-License-Identifier: CERN-OHL-W-2.0

// Behavioral MT25Q-style SPI flash slave with Quad I/O support.
// Consumed by digital-twin wrappers that expose SPI pins via the
// nafarr TriStateArray convention:
//   - io_in : 4-bit value master drives on IO[3:0] (dq_write)
//   - oe_in : 4-bit master drive mask (dq_writeEnable)
//   - io_out: 4-bit value slave drives (feeds dq_read)
//   - oe_out: 4-bit slave drive mask
// The slave adapts its RX width (single vs quad) from oe_in at the
// start of each phase; TX width is determined by the command opcode.

#pragma once
#include <cstdint>
#include <cstddef>

class SpiQioFlashSlave {
 public:
  SpiQioFlashSlave();
  void reset();

  void setBacking(const uint8_t* data, size_t size);
  void setDeviceId(uint8_t manufacturer, uint8_t type, uint8_t capacity);
  void setDummyCycles(uint8_t n);
  void setDebug(bool on);

  void tick(uint8_t cs, uint8_t sclk, uint8_t io_in, uint8_t oe_in,
            uint8_t& io_out, uint8_t& oe_out);

  uint8_t  lastCommand() const { return m_last_cmd; }
  uint32_t lastAddress() const { return m_last_addr; }

 private:
  enum class Phase : uint8_t {
    IDLE, CMD, ADDR, MODE_BYTE, DUMMY, DATA_OUT, DATA_IN, DONE
  };

  Phase    m_phase;
  uint8_t  m_prev_cs;
  uint8_t  m_prev_sclk;
  uint8_t  m_rx_width;
  uint8_t  m_tx_width;
  uint8_t  m_cmd;
  uint8_t  m_last_cmd;
  uint32_t m_last_addr;
  uint32_t m_rx_shift;
  int      m_rx_bits;
  int      m_rx_bits_needed;
  uint32_t m_addr;
  int      m_dummy_left;
  int      m_data_in_bytes_left;
  int      m_id_index;

  uint8_t  m_tx_current;
  uint8_t  m_tx_oe;
  uint8_t  m_tx_byte;
  int      m_tx_bits_left;

  uint8_t  m_id[3];
  uint8_t  m_dummy_cycles;
  const uint8_t* m_backing;
  size_t   m_backing_size;
  bool     m_debug;

  // QPI (Quad Peripheral Interface) state. When enabled, every command
  // following CS-assert is received on IO[3:0] in 4-bit nibbles instead
  // of on IO[0] alone. Enabled by the controller via WRITE_REGISTER
  // (0x61) writing an Enhanced Volatile Configuration Register value
  // whose bit 7 is cleared (MT25Q convention: 0 = Quad I/O enabled).
  // Latched on DATA_IN completion of the 0x61 transaction.
  bool     m_qpi_enabled;

  void afterCmdDispatch();
  void loadNextTxByte();
  void shiftOutChunk();
  static uint8_t widthFromOe(uint8_t oe);
};
