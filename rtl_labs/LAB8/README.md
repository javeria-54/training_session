# UART TX Controller

## Overview

The `uart_tx_controller` module implements a UART transmitter with support for **start bit, data bits, optional parity, and stop bit** transmission.
It uses a **finite state machine (FSM)** and a **baud rate generator** to control the timing of each bit.

---

## Features

* Parameterized **clock frequency** and **baud rate**
* Configurable **FIFO depth**
* **Parity selection**: None, Even, Odd, or Mark
* Outputs:

  * `tx_serial`: Serial transmit line
  * `tx_done`: Transmission complete flag
  * `tx_ready`: Ready to accept new data
  * `tx_busy`: Transmitter active status

---

## Parameters

| Parameter    | Description                                  |
| ------------ | -------------------------------------------- |
| `CLK_FREQ`   | System clock frequency                       |
| `BAUD_RATE`  | Desired UART baud rate                       |
| `FIFO_DEPTH` | FIFO buffer depth (not used directly in FSM) |

---

## Ports

### Inputs

| Signal           | Width | Description                                              |
| ---------------- | ----- | -------------------------------------------------------- |
| `clk`            | 1     | System clock                                             |
| `reset`          | 1     | Asynchronous reset                                       |
| `tx_data`        | 8     | Data byte to be transmitted                              |
| `baud_divisor`   | 12    | Baud rate divisor for generating baud ticks              |
| `data_available` | 1     | Indicates data is available in FIFO/buffer               |
| `parity_sel`     | 2     | Parity selection (00: None, 01: Even, 10: Odd, 11: Mark) |
| `tx_valid`       | 1     | Data valid flag                                          |

### Outputs

| Signal      | Width | Description                          |
| ----------- | ----- | ------------------------------------ |
| `tx_done`   | 1     | Transmission complete flag           |
| `tx_ready`  | 1     | Transmitter ready to accept new data |
| `tx_serial` | 1     | UART TX serial line                  |
| `tx_busy`   | 1     | Indicates transmitter is busy        |

---

## FSM States

| State       | Description                                            |
| ----------- | ------------------------------------------------------ |
| `IDLE`      | Transmitter idle, waiting for valid data               |
| `LOAD`      | Load shift register with `{stop, parity, data, start}` |
| `START_BIT` | Transmit start bit (`0`)                               |
| `DATA_BITS` | Transmit 8 data bits (LSB first)                       |
| `PARITY`    | Transmit parity bit (if enabled)                       |
| `STOP_BIT`  | Transmit stop bit (`1`) and complete transmission      |

---

## Baud Rate Generator

* Divides the system clock using `baud_divisor`
* Generates a `baud_tick` signal at the baud rate frequency
* Ensures each bit is held for **1 baud period**

---

## Transmission Format

1. **Start Bit** = `0`
2. **Data Bits** = 8 bits (LSB first)
3. **Parity Bit** (optional, depends on `parity_sel`)
4. **Stop Bit** = `1`

---

## Example Timing

```

```


# UART TX Synchronous FIFO

## Overview

The `uart_tx_sync_fifo` module implements a **synchronous FIFO buffer** for UART transmitter data handling.
It stores data words written by the transmitter logic and provides them for serial transmission in order.
The FIFO is controlled using **read/write pointers** and a **counter** to track the number of stored elements.

---

## Features

* Parameterized **data width** and **FIFO depth**
* Configurable **almost full** and **almost empty** thresholds
* Synchronous read/write operations with single clock (`clk`)
* Status signals: **full, empty, almost\_full, almost\_empty**
* Internal counter (`count`) to track stored entries

---

## Parameters

| Parameter             | Description                              |
| --------------------- | ---------------------------------------- |
| `DATA_WIDTH`          | Width of each FIFO word (in bits)        |
| `FIFO_DEPTH`          | Number of entries in the FIFO            |
| `ALMOST_FULL_THRESH`  | Threshold value to assert `almost_full`  |
| `ALMOST_EMPTY_THRESH` | Threshold value to assert `almost_empty` |

---

## Ports

### Inputs

| Signal    | Width       | Description                        |
| --------- | ----------- | ---------------------------------- |
| `clk`     | 1           | System clock                       |
| `rst_n`   | 1           | Active-low reset                   |
| `wr_en`   | 1           | Write enable (push data into FIFO) |
| `wr_data` | DATA\_WIDTH | Data word to be written            |
| `rd_en`   | 1           | Read enable (pop data from FIFO)   |

### Outputs

| Signal         | Width               | Description                                     |
| -------------- | ------------------- | ----------------------------------------------- |
| `rd_data`      | DATA\_WIDTH         | Data word read from FIFO                        |
| `full`         | 1                   | Indicates FIFO is full (no more writes allowed) |
| `empty`        | 1                   | Indicates FIFO is empty (no data to read)       |
| `almost_full`  | 1                   | Indicates FIFO is nearly full                   |
| `almost_empty` | 1                   | Indicates FIFO is nearly empty                  |
| `count`        | log2(FIFO\_DEPTH)+1 | Current number of stored elements               |

---

## Internal Operation

### Write Operation

* Data is written into `fifo[wr_ptr]` when `wr_en=1` and FIFO is not `full`.
* `wr_ptr` increments after each write.

### Read Operation

* Data is read from `fifo[rd_ptr]` when `rd_en=1` and FIFO is not `empty`.
* `rd_ptr` increments after each read.

### Counter Update (`count`)

* Increments when only write occurs.
* Decrements when only read occurs.
* Unchanged when both read & write occur in the same cycle.

---

## Status Flags

| Signal         | Condition                      |
| -------------- | ------------------------------ |
| `full`         | `count == FIFO_DEPTH - 1`      |
| `empty`        | `count == 0`                   |
| `almost_full`  | `count == ALMOST_FULL_THRESH`  |
| `almost_empty` | `count == ALMOST_EMPTY_THRESH` |

---




