// SPDX-FileCopyrightText: 2025 aesc silicon
//
// SPDX-License-Identifier: CERN-OHL-W-2.0

// Self-test for SpiQioFlashSlave. Bit-bangs SPI-like signalling and
// validates each supported command against the behavioral model.
// Each primitive starts and ends with SCLK=0 (Mode 0 idle).
// Build: g++ -std=c++17 -Wall -O1 spi_qio_flash_slave.cpp spi_qio_flash_slave_test.cpp -o test_qio
// Run:   ./test_qio

#include "spi_qio_flash_slave.h"

#include <cassert>
#include <cstdint>
#include <cstdio>
#include <cstring>
#include <vector>

namespace {

struct SpiDriver {
  SpiQioFlashSlave& slave;
  uint8_t cs = 1;
  uint8_t sclk = 0;
  uint8_t io_drive = 0;
  uint8_t oe_mask = 0;
  uint8_t io_from_slave = 0;
  uint8_t oe_from_slave = 0;

  explicit SpiDriver(SpiQioFlashSlave& s) : slave(s) {}

  void step() {
    slave.tick(cs, sclk, io_drive, oe_mask, io_from_slave, oe_from_slave);
  }

  void cycle() { sclk = 1; step(); sclk = 0; step(); }

  void assertCs()   { sclk = 0; cs = 0; step(); }
  void deassertCs() { sclk = 0; step(); cs = 1; step(); }

  void sendSingle(uint8_t byte, int bits = 8) {
    oe_mask = 0x1;
    for (int i = bits - 1; i >= 0; --i) {
      io_drive = (byte >> i) & 1;
      cycle();
    }
    io_drive = 0;
    oe_mask = 0;
  }

  void sendQuad(uint8_t byte) {
    oe_mask = 0xF;
    io_drive = (byte >> 4) & 0xF;
    cycle();
    io_drive = byte & 0xF;
    cycle();
    io_drive = 0;
    oe_mask = 0;
  }

  uint8_t recvSingle() {
    uint8_t byte = 0;
    oe_mask = 0;
    io_drive = 0;
    for (int i = 0; i < 8; ++i) {
      sclk = 1; step();                        // rising: master samples
      uint8_t bit = (io_from_slave >> 1) & 1;  // IO1 = MISO
      byte = (uint8_t)((byte << 1) | bit);
      sclk = 0; step();                        // falling: slave shifts
    }
    return byte;
  }

  uint8_t recvQuad() {
    uint8_t byte = 0;
    oe_mask = 0;
    io_drive = 0;
    for (int n = 0; n < 2; ++n) {
      sclk = 1; step();
      uint8_t nib = io_from_slave & 0xF;
      byte = (uint8_t)((byte << 4) | nib);
      sclk = 0; step();
    }
    return byte;
  }

  void dummy(int cycles) {
    oe_mask = 0;
    io_drive = 0;
    for (int i = 0; i < cycles; ++i) cycle();
  }
};

int g_fails = 0;

#define EXPECT_EQ(a, b, tag) do {                                       \
    auto _va = (a); auto _vb = (b);                                     \
    if (_va != _vb) {                                                   \
      fprintf(stderr, "FAIL %s: got 0x%lX, expected 0x%lX\n", (tag),    \
              (unsigned long)_va, (unsigned long)_vb);                  \
      g_fails++;                                                        \
    }                                                                   \
  } while (0)

void testReadId() {
  SpiQioFlashSlave s;
  s.setDeviceId(0x20, 0xBA, 0x18);
  SpiDriver d(s);

  d.deassertCs();
  d.assertCs();
  d.sendSingle(0x9F);
  uint8_t m = d.recvSingle();
  uint8_t t = d.recvSingle();
  uint8_t c = d.recvSingle();
  d.deassertCs();

  EXPECT_EQ((int)m, 0x20, "RDID[0]");
  EXPECT_EQ((int)t, 0xBA, "RDID[1]");
  EXPECT_EQ((int)c, 0x18, "RDID[2]");
}

void testFastRead() {
  std::vector<uint8_t> rom(256);
  for (size_t i = 0; i < rom.size(); ++i) rom[i] = (uint8_t)(i ^ 0xA5);

  SpiQioFlashSlave s;
  s.setBacking(rom.data(), rom.size());
  s.setDummyCycles(8);
  SpiDriver d(s);

  d.deassertCs();
  d.assertCs();
  d.sendSingle(0x0B);
  d.sendSingle(0x00);
  d.sendSingle(0x00);
  d.sendSingle(0x10);  // addr = 0x000010
  d.dummy(8);
  uint8_t b0 = d.recvSingle();
  uint8_t b1 = d.recvSingle();
  uint8_t b2 = d.recvSingle();
  d.deassertCs();

  EXPECT_EQ((int)b0, (int)rom[0x10], "FastRead b0");
  EXPECT_EQ((int)b1, (int)rom[0x11], "FastRead b1");
  EXPECT_EQ((int)b2, (int)rom[0x12], "FastRead b2");
}

void testQuadIoRead() {
  std::vector<uint8_t> rom(4096);
  for (size_t i = 0; i < rom.size(); ++i) {
    rom[i] = (uint8_t)((i * 7 + 3) & 0xFF);
  }

  SpiQioFlashSlave s;
  s.setBacking(rom.data(), rom.size());
  s.setDummyCycles(7);
  SpiDriver d(s);

  d.deassertCs();
  d.assertCs();
  d.sendSingle(0xEB);   // cmd single per MT25Q convention
  d.sendQuad(0x00);     // addr[23:16]
  d.sendQuad(0x01);     // addr[15:8]
  d.sendQuad(0x20);     // addr[7:0] = 0x000120
  d.sendQuad(0xA5);     // M byte (discarded)
  d.dummy(7);
  uint8_t b0 = d.recvQuad();
  uint8_t b1 = d.recvQuad();
  uint8_t b2 = d.recvQuad();
  uint8_t b3 = d.recvQuad();
  d.deassertCs();

  EXPECT_EQ((int)b0, (int)rom[0x120], "QIO b0");
  EXPECT_EQ((int)b1, (int)rom[0x121], "QIO b1");
  EXPECT_EQ((int)b2, (int)rom[0x122], "QIO b2");
  EXPECT_EQ((int)b3, (int)rom[0x123], "QIO b3");
}

void testWriteEnable() {
  SpiQioFlashSlave s;
  SpiDriver d(s);

  d.deassertCs();
  d.assertCs();
  d.sendSingle(0x06);
  d.deassertCs();

  EXPECT_EQ((int)s.lastCommand(), 0x06, "WREN cmd captured");
}

void testWriteNvConfig() {
  SpiQioFlashSlave s;
  SpiDriver d(s);

  d.deassertCs();
  d.assertCs();
  d.sendSingle(0x61);
  d.sendSingle(0x7F);
  d.sendSingle(0xFB);
  d.deassertCs();

  EXPECT_EQ((int)s.lastCommand(), 0x61, "WRVR cmd captured");
}

void testAutoIncrement() {
  std::vector<uint8_t> rom(16);
  for (size_t i = 0; i < rom.size(); ++i) rom[i] = (uint8_t)(0x10 + i);

  SpiQioFlashSlave s;
  s.setBacking(rom.data(), rom.size());
  s.setDummyCycles(4);
  SpiDriver d(s);

  d.deassertCs();
  d.assertCs();
  d.sendSingle(0xEB);
  d.sendQuad(0x00);
  d.sendQuad(0x00);
  d.sendQuad(0x00);
  d.sendQuad(0x00);
  d.dummy(4);
  uint8_t seq[8];
  for (int i = 0; i < 8; ++i) seq[i] = d.recvQuad();
  d.deassertCs();

  for (int i = 0; i < 8; ++i) {
    char tag[32]; snprintf(tag, sizeof(tag), "QIO seq[%d]", i);
    EXPECT_EQ((int)seq[i], (int)rom[i], tag);
  }
}

}  // namespace

int main() {
  testReadId();
  testFastRead();
  testQuadIoRead();
  testWriteEnable();
  testWriteNvConfig();
  testAutoIncrement();

  if (g_fails) {
    fprintf(stderr, "%d FAILURE(S)\n", g_fails);
    return 1;
  }
  printf("spi_qio_flash_slave_test: OK\n");
  return 0;
}
