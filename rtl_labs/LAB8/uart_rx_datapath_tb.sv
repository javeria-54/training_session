`timescale 1ns/1ps

module uart_rx_datapath_tb;

    // Parameters
    localparam CLK_FREQ   = 50_000_000;
    localparam BAUD_RATE  = 115200;
    localparam CLK_PERIOD = 20;  // 50 MHz

    // DUT signals
    logic clk;
    logic reset_n;
    logic [1:0] parity_sel;
    logic stop_bits;
    logic start_bit_en;
    logic rx_serial;
    logic rd_en;
    logic [7:0] rd_data;
    logic full, empty, almost_full, almost_empty;
    logic rx_busy, rx_error, rx_valid_out;
    logic [$clog2(16):0] fifo_count;

    // Instantiate DUT
    uart_rx_top #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE),
        .FIFO_DEPTH(16),
        .DATA_WIDTH(8),
        .ALMOST_FULL_THRESH(14),
        .ALMOST_EMPTY_THRESH(2)
    ) dut (
        .clk(clk),
        .reset_n(reset_n),
        .parity_sel(parity_sel),
        .stop_bits(stop_bits),
        .start_bit_en(start_bit_en),
        .rx_serial(rx_serial),
        .rd_en(rd_en),
        .rd_data(rd_data),
        .full(full),
        .empty(empty),
        .almost_full(almost_full),
        .almost_empty(almost_empty),
        .rx_busy(rx_busy),
        .rx_error(rx_error),
        .rx_valid_out(rx_valid_out),
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

    // UART RX stimulus task (send one byte)
    task send_byte(input [7:0] data);
        integer i;
        real bit_time;
        begin
            bit_time = 1e9 / BAUD_RATE;  // ns per bit

            // Start bit
            rx_serial = 0;
            #(bit_time);

            // Data bits (LSB first)
            for (i = 0; i < 8; i = i + 1) begin
                rx_serial = data[i];
                #(bit_time);
            end

            // Stop bit (1)
            rx_serial = 1;
            #(bit_time);

            // Optional: wait one bit time
            #(bit_time);
        end
    endtask

    // Stimulus process
    initial begin
        // Defaults
        parity_sel   = 2'b00;
        stop_bits    = 1'b0;
        start_bit_en = 1'b1;
        rd_en        = 0;
        rx_serial    = 1;  // Idle

        @(posedge reset_n);
        $display("[%0t] Starting UART RX test...", $time);

        // Send some bytes
        send_byte(8'h55);
        send_byte(8'hA5);
        send_byte(8'hFF);

        // Wait a little for last byte to finish
        repeat(5000) @(posedge clk);
        $finish;
    end

    // Read from FIFO whenever valid data is available
    always @(posedge clk) begin
        if (rx_valid_out && !empty) begin
            rd_en <= 1;
        end else begin
            rd_en <= 0;
        end
    end

    // Monitor received bytes
    always @(posedge clk) begin
        if (rd_en) begin
            $display("[%0t] Received byte: 0x%0h (FIFO count = %0d)", $time, rd_data, fifo_count);
        end
    end

endmodule
