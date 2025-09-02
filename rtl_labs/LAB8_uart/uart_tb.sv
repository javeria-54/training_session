`timescale 1ns/1ps

module uart_tb;

  // Parameters
  localparam int CLK_FREQ  = 50_000_000;
  localparam int BAUD_RATE = 115200;
  localparam real CLK_PERIOD = 1e9 / CLK_FREQ; // ns

  // DUT signals
  logic clk;
  logic rst_n;
  logic [7:0] tx_data;
  logic tx_valid;
  logic rx_error;
  logic rx_busy;
  logic [7:0] rx_data;
  logic rx_valid;

  // Expected data queue
  byte expected_data [0:3];   // store expected values
  int q_head = 0;             // pointer to expected_data
  logic tx_ready;

  // Instantiate DUT
  uart #(
    .CLK_FREQ(CLK_FREQ),
    .BAUD_RATE(BAUD_RATE)
  ) dut (
    .clk(clk),
    .rst_n(rst_n),
    .tx_data(tx_data),
    .tx_valid(tx_valid),

    .rx_error(rx_error),
    .rx_busy(rx_busy),
    .rx_data(rx_data),
    .rx_valid(rx_valid)
  );

  // Clock generation
  initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk = ~clk;
  end

  // Reset
  initial begin
    rst_n = 0;
    tx_valid = 0;
    tx_data = 0;
    #(10*CLK_PERIOD);
    rst_n = 1;
  end

  // Task to send a byte
  task send_byte(input [7:0] data);
    begin
      @(posedge clk);
      while (!tx_ready) @(posedge clk); // wait until transmitter ready
      tx_data  <= data;
      tx_valid <= 1;
      @(posedge clk);
      tx_valid <= 0;
    end
  endtask

  // Monitor received data
  always @(posedge clk) begin
    if (rx_valid) begin
      if (rx_data == expected_data[q_head]) begin
        $display("[%0t] PASS: Received %h", $time, rx_data);
      end else begin
        $display("[%0t] FAIL: Expected %h, Got %h", $time, expected_data[q_head], rx_data);
      end
      q_head++;
    end
  end

  // Test sequence
  initial begin
    expected_data[0] = 8'hA5;
    expected_data[1] = 8'h3C;
    expected_data[2] = 8'h55;
    expected_data[3] = 8'hFF;

    @(posedge rst_n);

    // Send test bytes
    send_byte(expected_data[0]);
    send_byte(expected_data[1]);
    send_byte(expected_data[2]);
    send_byte(expected_data[3]);

    // Wait for all responses
    #(1_000_000); // enough time for RX
    $finish;
  end

endmodule
