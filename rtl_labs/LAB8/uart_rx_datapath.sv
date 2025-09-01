module uart_rx_datapath #(
    parameter int CLK_FREQ = 50_000_000,
    parameter int BAUD_RATE = 115200,
    parameter int FIFO_DEPTH = 16,
    parameter int DATA_WIDTH = 8,
    parameter int ALMOST_FULL_THRESH = 14,
    parameter int ALMOST_EMPTY_THRESH = 2
)(
    // System signals
    input   logic           clk,
    input   logic           reset_n,  // Active low reset
    
    // Configuration signals
    input   logic [1:0]     parity_sel,
    input   logic           stop_bits,
    input   logic           start_bit_en,
    
    // UART input
    input   logic           rx_serial,
    
    // FIFO read interface
    input   logic           rd_en,
    output  logic [7:0]     rd_data,
    
    // Status signals
    output  logic           full,
    output  logic           empty,
    output  logic           almost_full,
    output  logic           almost_empty,
    output  logic           rx_busy,
    output  logic           rx_error,
    output  logic           rx_valid_out,
    
    // Optional: FIFO count for monitoring
    output  logic [$clog2(FIFO_DEPTH):0] fifo_count
);

    // Internal signals
    logic [7:0]     rx_data;
    logic           rx_valid;
    logic           rx_error_int;
    logic           wr_en;
    logic           reset;
    
    // Convert active low reset to active high
    assign reset = ~reset_n;
    
    // Instantiate the UART receiver datapath
    Rx_Datapath #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) uart_rx (
        .clk(clk),
        .reset(reset),
        .rx_serial(rx_serial),
        .baud_divisor(),           // Internal calculation
        .parity_sel(parity_sel),
        .stop_bits(stop_bits),
        .start_bit_en(start_bit_en),
        .rx_data(rx_data),
        .rx_valid(rx_valid),
        .rx_error(rx_error_int),
        .rx_busy(rx_busy)
    );
    
    // Write enable for FIFO - only write when data is valid and no error
    assign wr_en = rx_valid && !rx_error_int;
    assign rx_error = rx_error_int;  // Output the error signal
    
    // Instantiate the synchronous FIFO
    uart_rx_sync_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .FIFO_DEPTH(FIFO_DEPTH),
        .ALMOST_FULL_THRESH(ALMOST_FULL_THRESH),
        .ALMOST_EMPTY_THRESH(ALMOST_EMPTY_THRESH)
    ) rx_fifo (
        .clk(clk),
        .rst_n(reset_n),
        .wr_en(wr_en),
        .wr_data(rx_data),
        .rd_en(rd_en),
        .rd_data(rd_data),
        .full(full),
        .empty(empty),
        .almost_full(almost_full),
        .almost_empty(almost_empty),
        .count(fifo_count)
    );
    
    // Output valid signal indicates data is available in FIFO
    assign rx_valid_out = !empty;

endmodule