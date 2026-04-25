# Multi-Node IoT Simulation

Simulates an IoT network with two ElemRV SoC variants communicating over UART, all running in Renode without physical hardware.

## Architecture

```
┌─────────────────────────┐      UART Hub       ┌─────────────────────────┐
│  h_edge (ElemRV-H)      │  uart0 ←──hub──→   │  n_gateway (ElemRV-N)   │
│                         │   uart0             │                         │
│  SI70xx sensor @ i2c0   │                     │  uart0 = console + data │
│  50 MHz, 8 KB RAM       │                     │  30 MHz, 4 KB + HyperRAM│
│  Zephyr RTOS            │                     │  Zephyr RTOS            │
└─────────────────────────┘                     └─────────────────────────┘
```

- **Edge node** (ElemRV-H): Reads temperature and humidity from an I2C sensor, formats DATA frames, and transmits them over UART
- **Gateway node** (ElemRV-N): Receives DATA frames, sends acknowledgments, aggregates sensor data, and prints a summary report

## Protocol

Text-based protocol over shared UART:

| Direction | Format | Example |
|-----------|--------|---------|
| Edge -> Gateway | `DATA:<id>,<temp_x100>,<hum_x100>\n` | `DATA:1,2200,4500\n` |
| Gateway -> Edge | `ACK:<id>\n` | `ACK:1\n` |
| Gateway console | `REPORT: samples=N, avg_temp=T, avg_hum=H\n` | `REPORT: samples=10, avg_temp=2200, avg_hum=4500\n` |

Both machines share UART0 via a Renode UARTHub. Console output (printk) and protocol data coexist on the same UART with prefix-based filtering:

- Gateway ignores lines not starting with `DATA:`
- Edge ignores lines not starting with `ACK:`

## Renode Multi-Machine Setup

The simulation uses Renode's `CreateUARTHub` to connect UART0 of both machines:

```renode
emulation CreateUARTHub "uartHub"

mach create "h_edge"
machine LoadPlatformDescription @platforms/elemrv_h_i2c_sensor.repl
connector Connect sysbus.uart0 uartHub

mach create "n_gateway"
machine LoadPlatformDescription @platforms/elemrv_n_zephyr.repl
connector Connect sysbus.uart0 uartHub
```

Renode synchronizes virtual time across both machines automatically.

## Running

### Quick Run

```bash
task dt-multi-node
```

### Full Build + Test

```bash
task dt-multi-node-test
```

### Manual Run

```bash
# Build edge (H)
cd digital-twin/zephyr/elemrv-zephyr
west build -b elemrv_h app/multi_node_edge -d build-multi-node-edge

# Build gateway (N)
west build -b elemrv_n app/multi_node_gateway -d build-n-multi-node-gateway

# Run simulation
cd renode
renode --disable-xwt --console -e "include @run_multi_node.resc"
```

### Expected Output

The gateway's UART analyzer captures:

```
Gateway: waiting for data
ACK:1
ACK:2
...
ACK:10
REPORT: samples=10, avg_temp=2200, avg_hum=4500
Multi-Node IoT Test PASSED
```

## Firmware Details

### Edge (`app/multi_node_edge`)

Single-threaded main loop:

1. Initialize I2C and UART devices
2. Loop 10 times:
   - Read temperature + humidity from SI70xx at I2C 0x48
   - Send `DATA:<id>,<temp_x100>,<hum_x100>\n` via printk
   - Poll UART RX for `ACK:<id>` with 2-second timeout
   - Sleep 300ms between samples
3. Print summary: `Edge: capture complete, acks=N/10`

### Gateway (`app/multi_node_gateway`)

Single-threaded main loop:

1. Initialize UART device
2. Poll UART RX until 10 DATA frames received (30-second timeout):
   - Parse `DATA:<id>,<temp>,<hum>` lines
   - Accumulate temperature and humidity sums
   - Send `ACK:<id>` for each DATA frame
   - Ignore non-DATA lines
3. Compute averages and print `REPORT:` line
4. Print `Multi-Node IoT Test PASSED` if all 10 samples received

## Extending

### Adding More Nodes

Create additional machines in the .resc script and connect them to the same hub:

```renode
mach create "h_edge_2"
machine LoadPlatformDescription @platforms/elemrv_h_i2c_sensor.repl
connector Connect sysbus.uart0 uartHub
```

The gateway firmware can be extended to parse a node identifier from the DATA frame.

### Different Sensor Values Per Node

Set different sensor values per edge machine in the .resc script:

```renode
mach set "h_edge"
i2c0.sensor Temperature 22.0

mach set "h_edge_2"
i2c0.sensor Temperature 35.0
```

### Failure Scenarios

- Remove the hub connection from one machine to simulate link failure
- Set sensor values to extreme ranges to test gateway aggregation
- Reduce RunFor duration to trigger gateway timeout

## Test Integration

This feature is validated by **Test 52** in the test suite. See [Test Suite Reference](../reference/test-suite.md) for details.

---

**Previous**: [Co-simulation](co-simulation.md)
**Next**: [Sensor Simulation](sensors.md)
