`timescale 1ns/1ps

module uart_tx_datapath_tb;

    // Parameters
    localparam CLK_FREQ   = 50_000_000;
    localparam BAUD_RATE  = 115200;
    localparam CLK_PERIOD = 20; // 50 MHz = 20 ns period

    // DUT signals
    logic clk;
    logic reset_n;
    logic [1:0] parity_sel;
    logic stop_bits;
    logic start_bit;
    logic wr_en;
    logic [7:0] wr_data;
    logic full, empty, almost_full, almost_empty;
    logic tx_busy, tx_ready, tx_done;
    logic tx_serial;
    logic [$clog2(8):0] fifo_count;  // FIFO_DEPTH = 8

    // Instantiate DUT
    uart_tx_datapath #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE),
        .FIFO_DEPTH(8),
        .DATA_WIDTH(8),
        .ALMOST_FULL_THRESH(6),
        .ALMOST_EMPTY_THRESH(2)
    ) dut (
        .clk(clk),
        .reset_n(reset_n),
        .parity_sel(parity_sel),
        .stop_bits(stop_bits),
        .start_bit(start_bit),
        .wr_en(wr_en),
        .wr_data(wr_data),
        .full(full),
        .empty(empty),
        .almost_full(almost_full),
        .almost_empty(almost_empty),
        .tx_busy(tx_busy),
        .tx_ready(tx_ready),
        .tx_done(tx_done),
        .tx_serial(tx_serial),
        .fifo_count(fifo_count)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // Reset
    initial begin
        reset_n = 0;
        #(10*CLK_PERIOD);
        reset_n = 1;
    end

    // Stimulus
    initial begin
        // Default values
        wr_en      = 0;
        wr_data    = 8'h00;
        parity_sel = 2'b00;   // 00 = No parity
        stop_bits  = 1'b0;    // 0 = 1 stop bit
        start_bit  = 1'b1;    // Enable start bit

        @(posedge reset_n);
        $display("[%0t] Starting UART TX test...", $time);

        // Wait a few cycles
        repeat(5) @(posedge clk);

        // Write 3 bytes to FIFO
        send_byte(8'h55); // 01010101
        send_byte(8'hA5); // 10100101
        send_byte(8'hFF); // 11111111

        // Wait until last byte is sent
        wait(tx_done);
        $display("[%0t] UART transmission done.", $time);

        repeat(20) @(posedge clk);
        $finish;
    end

    // Task to send a byte into FIFO
    task send_byte(input [7:0] data);
        begin
            @(posedge clk);
            wr_data = data;
            wr_en   = 1'b1;
            @(posedge clk);
            wr_en   = 1'b0;
            wait(tx_ready);
            $display("[%0t] Sent byte: 0x%0h (FIFO count = %0d)", $time, data, fifo_count);
        end
    endtask

    // Monitor UART TX activity
    initial begin
        $monitor("[%0t] tx_serial=%b tx_busy=%b tx_ready=%b tx_done=%b fifo_count=%0d",
                 $time, tx_serial, tx_busy, tx_ready, tx_done, fifo_count);
    end

endmodule
