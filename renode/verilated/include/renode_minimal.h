// SPDX-FileCopyrightText: 2025 aesc silicon
//
// SPDX-License-Identifier: CERN-OHL-W-2.0

// Minimal Renode co-simulation interface header
// Based on Renode's CoSimulatedPeripheral integration

#ifndef RENODE_MINIMAL_H
#define RENODE_MINIMAL_H

#include <stdint.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

// Peripheral context handle
typedef void* peripheral_t;

// Create a new peripheral instance
// Returns handle to the peripheral or NULL on error
peripheral_t peripheral_create(void);

// Destroy a peripheral instance
void peripheral_destroy(peripheral_t peripheral);

// Reset the peripheral
void peripheral_reset(peripheral_t peripheral);

// Execute one clock cycle
// Returns true if the peripheral is active, false otherwise
bool peripheral_tick(peripheral_t peripheral, uint64_t time_ps);

// Read from the peripheral
// Returns the value read from the specified offset
uint64_t peripheral_read(peripheral_t peripheral, uint64_t offset, uint8_t size);

// Write to the peripheral
// size: 1, 2, 4, or 8 bytes
void peripheral_write(peripheral_t peripheral, uint64_t offset, uint8_t size, uint64_t value);

// Set clock frequency in Hz
void peripheral_set_frequency(peripheral_t peripheral, uint64_t frequency_hz);

#ifdef __cplusplus
}
#endif

#endif // RENODE_MINIMAL_H
