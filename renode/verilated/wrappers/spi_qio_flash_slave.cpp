// SPDX-FileCopyrightText: 2025 aesc silicon
//
// SPDX-License-Identifier: CERN-OHL-W-2.0

#include "spi_qio_flash_slave.h"

#include <cstdio>

uint8_t SpiQioFlashSlave::widthFromOe(uint8_t oe) {
  return ((oe & 0xF) == 0xF) ? 4 : 1;
}

SpiQioFlashSlave::SpiQioFlashSlave() { reset(); }

void SpiQioFlashSlave::reset() {
  m_phase = Phase::IDLE;
  m_prev_cs = 1;
  m_prev_sclk = 0;
  m_rx_width = 1;
  m_tx_width = 1;
  m_cmd = 0;
  m_last_cmd = 0;
  m_last_addr = 0;
  m_rx_shift = 0;
  m_rx_bits = 0;
  m_rx_bits_needed = 0;
  m_addr = 0;
  m_dummy_left = 0;
  m_data_in_bytes_left = 0;
  m_id_index = 0;
  m_tx_current = 0;
  m_tx_oe = 0;
  m_tx_byte = 0;
  m_tx_bits_left = 0;
  m_id[0] = 0x20;
  m_id[1] = 0xBA;
  m_id[2] = 0x18;
  m_dummy_cycles = 8;
  m_backing = nullptr;
  m_backing_size = 0;
  m_debug = false;
}

void SpiQioFlashSlave::setBacking(const uint8_t* data, size_t size) {
  m_backing = data;
  m_backing_size = size;
}

void SpiQioFlashSlave::setDeviceId(uint8_t m, uint8_t t, uint8_t c) {
  m_id[0] = m; m_id[1] = t; m_id[2] = c;
}

void SpiQioFlashSlave::setDummyCycles(uint8_t n) { m_dummy_cycles = n; }

void SpiQioFlashSlave::setDebug(bool on) { m_debug = on; }

void SpiQioFlashSlave::loadNextTxByte() {
  if (m_cmd == 0x9F) {
    m_tx_byte = (m_id_index < 3) ? m_id[m_id_index] : 0xFF;
    m_id_index++;
  } else {
    if (m_backing && m_backing_size > 0) {
      m_tx_byte = m_backing[m_addr % m_backing_size];
    } else {
      m_tx_byte = 0xFF;
    }
    m_addr = (m_addr + 1) & 0xFFFFFF;
  }
  m_tx_bits_left = 8;
}

void SpiQioFlashSlave::shiftOutChunk() {
  if (m_tx_bits_left == 0) loadNextTxByte();

  if (m_tx_width == 4) {
    uint8_t nib = (m_tx_byte >> 4) & 0xF;
    m_tx_byte = (uint8_t)(m_tx_byte << 4);
    m_tx_bits_left -= 4;
    m_tx_current = nib;
    m_tx_oe = 0xF;
  } else {
    uint8_t bit = (m_tx_byte >> 7) & 1;
    m_tx_byte = (uint8_t)(m_tx_byte << 1);
    m_tx_bits_left -= 1;
    m_tx_current = (uint8_t)((bit & 1) << 1);
    m_tx_oe = 0x2;
  }
}

void SpiQioFlashSlave::afterCmdDispatch() {
  m_last_cmd = m_cmd;
  m_last_addr = 0;
  m_addr = 0;
  m_rx_shift = 0;
  m_rx_bits = 0;
  m_id_index = 0;
  m_tx_bits_left = 0;
  m_tx_current = 0;
  m_tx_oe = 0;

  if (m_debug) {
    fprintf(stderr, "[QIOFLASH] cmd=0x%02X dispatched\n", m_cmd);
  }

  switch (m_cmd) {
    case 0x06:
      m_phase = Phase::DONE;
      break;
    case 0x61:
      m_phase = Phase::DATA_IN;
      m_rx_width = 1;
      m_rx_bits_needed = 8;
      m_data_in_bytes_left = 2;
      break;
    case 0x81:
      m_phase = Phase::DATA_IN;
      m_rx_width = 1;
      m_rx_bits_needed = 8;
      m_data_in_bytes_left = 1;
      break;
    case 0x9F:
      m_phase = Phase::DATA_OUT;
      m_tx_width = 1;
      break;
    case 0x03:
    case 0x0B:
      m_phase = Phase::ADDR;
      m_rx_width = 1;
      m_rx_bits_needed = 24;
      break;
    case 0xEB:
    case 0xE7:
      m_phase = Phase::ADDR;
      m_rx_width = 4;
      m_rx_bits_needed = 24;
      break;
    default:
      m_phase = Phase::DONE;
      break;
  }
}

void SpiQioFlashSlave::tick(uint8_t cs, uint8_t sclk, uint8_t io_in,
                            uint8_t oe_in, uint8_t& io_out,
                            uint8_t& oe_out) {
  cs   &= 1;
  sclk &= 1;

  // CS edge detection.
  if (m_prev_cs == 1 && cs == 0) {
    m_phase = Phase::CMD;
    m_rx_width = 1;
    m_rx_bits_needed = 8;
    m_rx_shift = 0;
    m_rx_bits = 0;
    m_tx_current = 0;
    m_tx_oe = 0;
    if (m_debug) fprintf(stderr, "[QIOFLASH] CS asserted\n");
  } else if (m_prev_cs == 0 && cs == 1) {
    if (m_debug) fprintf(stderr, "[QIOFLASH] CS deasserted\n");
    m_phase = Phase::IDLE;
    m_tx_current = 0;
    m_tx_oe = 0;
  }
  m_prev_cs = cs;

  if (cs == 1) {
    io_out = 0;
    oe_out = 0;
    m_prev_sclk = sclk;
    return;
  }

  // SCLK rising edge: sample RX / count dummy.
  if (m_prev_sclk == 0 && sclk == 1) {
    switch (m_phase) {
      case Phase::CMD:
      case Phase::ADDR:
      case Phase::MODE_BYTE:
      case Phase::DATA_IN: {
        if (m_rx_bits == 0 &&
            (m_phase == Phase::ADDR || m_phase == Phase::MODE_BYTE)) {
          m_rx_width = widthFromOe(oe_in);
        }
        uint32_t bits;
        if (m_rx_width == 4) {
          bits = io_in & 0xF;
          m_rx_shift = (m_rx_shift << 4) | bits;
          m_rx_bits += 4;
        } else {
          bits = io_in & 1;
          m_rx_shift = (m_rx_shift << 1) | bits;
          m_rx_bits += 1;
        }

        if (m_rx_bits >= m_rx_bits_needed) {
          if (m_phase == Phase::CMD) {
            m_cmd = (uint8_t)(m_rx_shift & 0xFF);
            afterCmdDispatch();
          } else if (m_phase == Phase::ADDR) {
            m_addr = m_rx_shift & 0xFFFFFF;
            m_last_addr = m_addr;
            if (m_debug) {
              fprintf(stderr, "[QIOFLASH] addr=0x%06X\n", m_addr);
            }
            if (m_cmd == 0xEB || m_cmd == 0xE7) {
              m_phase = Phase::MODE_BYTE;
              m_rx_width = 4;
              m_rx_bits_needed = 8;
              m_rx_shift = 0;
              m_rx_bits = 0;
            } else if (m_cmd == 0x0B) {
              m_phase = Phase::DUMMY;
              m_dummy_left = m_dummy_cycles;
            } else {
              m_phase = Phase::DATA_OUT;
              m_tx_width = 1;
              m_tx_bits_left = 0;
            }
          } else if (m_phase == Phase::MODE_BYTE) {
            m_phase = Phase::DUMMY;
            m_dummy_left = m_dummy_cycles;
          } else if (m_phase == Phase::DATA_IN) {
            m_data_in_bytes_left--;
            if (m_data_in_bytes_left <= 0) {
              m_phase = Phase::DONE;
            } else {
              m_rx_bits = 0;
              m_rx_shift = 0;
            }
          }
        }
        break;
      }
      case Phase::DUMMY: {
        m_dummy_left--;
        if (m_dummy_left <= 0) {
          m_phase = Phase::DATA_OUT;
          m_tx_width = (m_cmd == 0xEB || m_cmd == 0xE7) ? 4 : 1;
          m_tx_bits_left = 0;
        }
        break;
      }
      default:
        break;
    }
  }

  // SCLK falling edge: update TX.
  if (m_prev_sclk == 1 && sclk == 0) {
    if (m_phase == Phase::DATA_OUT) {
      shiftOutChunk();
    }
  }

  m_prev_sclk = sclk;
  io_out = m_tx_current;
  oe_out = m_tx_oe;
}
