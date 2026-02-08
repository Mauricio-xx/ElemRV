# SPDX-FileCopyrightText: 2025 aesc silicon
#
# SPDX-License-Identifier: CERN-OHL-W-2.0

# ElemRV-H GDB Convenience Script
# Usage: riscv-none-elf-gdb -x renode/gdb/elemrv.gdb <firmware.elf>
#
# Provides convenience commands for inspecting peripheral registers
# while debugging firmware on the ElemRV-H digital twin.

set architecture riscv:rv32
set pagination off
set confirm off
target remote :3333

# --- PWM0 Registers (0xF0003000) ---
define pwm-regs
  printf "=== PWM0 @ 0xF0003000 ===\n"
  printf "IP Header  (0x000): "
  x/1xw 0xF0003000
  printf "IP Version (0x004): "
  x/1xw 0xF0003004
  printf "Features   (0x008): "
  x/1xw 0xF0003008
  printf "Status     (0x00C): "
  x/1xw 0xF000300C
  printf "ClkDiv     (0x010): "
  x/1xw 0xF0003010
  printf "CH0 Ctrl   (0x014): "
  x/1xw 0xF0003014
  printf "CH0 Period (0x018): "
  x/1xw 0xF0003018
  printf "CH0 Duty   (0x01C): "
  x/1xw 0xF000301C
  printf "CH1 Ctrl   (0x020): "
  x/1xw 0xF0003020
  printf "CH1 Period (0x024): "
  x/1xw 0xF0003024
  printf "CH1 Duty   (0x028): "
  x/1xw 0xF0003028
end
document pwm-regs
Dump all PWM0 registers (IP header, clock divider, CH0/CH1 control/period/duty).
end

# --- GPIO0 Registers (0xF0000000) ---
define gpio-regs
  printf "=== GPIO0 @ 0xF0000000 ===\n"
  printf "IP Header  (0x000): "
  x/1xw 0xF0000000
  printf "IP Version (0x004): "
  x/1xw 0xF0000004
  printf "Features   (0x008): "
  x/1xw 0xF0000008
  printf "Status     (0x00C): "
  x/1xw 0xF000000C
  printf "Read       (0x010): "
  x/1xw 0xF0000010
  printf "Write      (0x014): "
  x/1xw 0xF0000014
  printf "WriteEn    (0x018): "
  x/1xw 0xF0000018
end
document gpio-regs
Dump GPIO0 registers (IP header, read/write/write-enable).
end

# --- PIO0 Registers (0xF0002000) ---
define pio-regs
  printf "=== PIO0 @ 0xF0002000 ===\n"
  printf "IP Header  (0x000): "
  x/1xw 0xF0002000
  printf "IP Version (0x004): "
  x/1xw 0xF0002004
  printf "Features   (0x008): "
  x/1xw 0xF0002008
  printf "Status     (0x00C): "
  x/1xw 0xF000200C
  printf "Config     (0x010): "
  x/1xw 0xF0002010
  printf "IO Status  (0x014): "
  x/1xw 0xF0002014
end
document pio-regs
Dump PIO0 registers (IP header, config, IO status).
end

# --- I2C0 Registers (0xF0001000) ---
define i2c-regs
  printf "=== I2C0 @ 0xF0001000 ===\n"
  printf "IP Header  (0x000): "
  x/1xw 0xF0001000
  printf "IP Version (0x004): "
  x/1xw 0xF0001004
  printf "Features   (0x008): "
  x/1xw 0xF0001008
  printf "Status     (0x00C): "
  x/1xw 0xF000100C
  printf "Config     (0x010): "
  x/1xw 0xF0001010
  printf "TX Data    (0x014): "
  x/1xw 0xF0001014
  printf "RX Data    (0x018): "
  x/1xw 0xF0001018
  printf "Command    (0x01C): "
  x/1xw 0xF000101C
end
document i2c-regs
Dump I2C0 registers (IP header, config, TX/RX data, command).
end

# --- UART0 Registers (0xF0004000) ---
define uart-regs
  printf "=== UART0 @ 0xF0004000 ===\n"
  printf "IP Header  (0x000): "
  x/1xw 0xF0004000
  printf "IP Version (0x004): "
  x/1xw 0xF0004004
  printf "Features   (0x008): "
  x/1xw 0xF0004008
  printf "Status     (0x00C): "
  x/1xw 0xF000400C
  printf "Clock Div  (0x010): "
  x/1xw 0xF0004010
  printf "Frame      (0x014): "
  x/1xw 0xF0004014
  printf "TX Data    (0x018): "
  x/1xw 0xF0004018
  printf "RX Data    (0x01C): "
  x/1xw 0xF000401C
end
document uart-regs
Dump UART0 registers (IP header, clock divider, frame config, TX/RX data).
end

# --- Timer0 Registers (0xF0005000) ---
define timer-regs
  printf "=== Timer0 @ 0xF0005000 ===\n"
  printf "mtime_lo   (0x000): "
  x/1xw 0xF0005000
  printf "mtime_hi   (0x004): "
  x/1xw 0xF0005004
  printf "mtimecmp_lo(0x008): "
  x/1xw 0xF0005008
  printf "mtimecmp_hi(0x00C): "
  x/1xw 0xF000500C
end
document timer-regs
Dump MachineTimer registers (mtime, mtimecmp).
end

# --- Pinmux Registers (0xF0010000) ---
define pinmux-regs
  printf "=== Pinmux @ 0xF0010000 ===\n"
  printf "Pin 0  (0x000): "
  x/1xw 0xF0010000
  printf "Pin 1  (0x004): "
  x/1xw 0xF0010004
  printf "Pin 2  (0x008): "
  x/1xw 0xF0010008
  printf "Pin 3  (0x00C): "
  x/1xw 0xF001000C
  printf "Pin 4  (0x010): "
  x/1xw 0xF0010010
  printf "Pin 5  (0x014): "
  x/1xw 0xF0010014
  printf "Pin 6  (0x018): "
  x/1xw 0xF0010018
  printf "Pin 7  (0x01C): "
  x/1xw 0xF001001C
end
document pinmux-regs
Dump Pinmux registers (pin 0-7 mux selection).
end

# --- Peripheral Scan (IP Headers) ---
define periph-scan
  printf "=== Peripheral IP Header Scan ===\n"
  printf "GPIO0  @ 0xF0000000: "
  x/1xw 0xF0000000
  printf "I2C0   @ 0xF0001000: "
  x/1xw 0xF0001000
  printf "PIO0   @ 0xF0002000: "
  x/1xw 0xF0002000
  printf "PWM0   @ 0xF0003000: "
  x/1xw 0xF0003000
  printf "UART0  @ 0xF0004000: "
  x/1xw 0xF0004000
  printf "Timer0 @ 0xF0005000: "
  x/1xw 0xF0005000
  printf "Pinmux @ 0xF0010000: "
  x/1xw 0xF0010000
end
document periph-scan
Read IP Header (offset 0x000) from all 7 peripherals to verify bus connectivity.
end

# --- Memory Map ---
define memmap
  printf "=== ElemRV-H Memory Map ===\n"
  printf "0x80000000 - 0x80001FFF  RAM      (8 KB)\n"
  printf "0xA0000000 - 0xA000FFFF  Flash    (64 KB)\n"
  printf "0xF0000000 - 0xF0000FFF  GPIO0\n"
  printf "0xF0001000 - 0xF0001FFF  I2C0\n"
  printf "0xF0002000 - 0xF0002FFF  PIO0\n"
  printf "0xF0003000 - 0xF0003FFF  PWM0\n"
  printf "0xF0004000 - 0xF0004FFF  UART0\n"
  printf "0xF0005000 - 0xF0005FFF  Timer0\n"
  printf "0xF0010000 - 0xF0010FFF  Pinmux\n"
end
document memmap
Print the ElemRV-H memory map (RAM, Flash, peripherals).
end

printf "ElemRV-H GDB helpers loaded. Commands: pwm-regs, gpio-regs, pio-regs,\n"
printf "  i2c-regs, uart-regs, timer-regs, pinmux-regs, periph-scan, memmap\n"
