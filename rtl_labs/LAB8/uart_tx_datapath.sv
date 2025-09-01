module uart_tx_datapath #(
    parameter int CLK_FREQ = 50_000_000,
    parameter int BAUD_RATE = 115200,
    parameter int FIFO_DEPTH = 8,
    parameter int DATA_WIDTH = 8,
    parameter int ALMOST_FULL_THRESH = 6,
    parameter int ALMOST_EMPTY_THRESH = 2
)(
    // System signals
    input   logic           clk,
    input   logic           reset_n,  // Active low reset
    
    // Configuration signals
    input   logic [1:0]     parity_sel,
    input   logic           stop_bits,
    input   logic           start_bit,
    
    // FIFO write interface
    input   logic           wr_en,
    input   logic [7:0]     wr_data,
    
    // Status signals
    output  logic           full,
    output  logic           empty,
    output  logic           almost_full,
    output  logic           almost_empty,
    output  logic           tx_busy,
    output  logic           tx_ready,
    output  logic           tx_done,
    
    // UART output
    output  logic           tx_serial,
    
    // Optional: FIFO count for monitoring
    output  logic [$clog2(FIFO_DEPTH):0] fifo_count
);

    // Internal signals
    logic [7:0]     tx_data;
    logic           data_available;
    logic           rd_en;
    logic           tx_valid;
    
    // Instantiate the synchronous FIFO
    uart_tx_sync_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .FIFO_DEPTH(FIFO_DEPTH),
        .ALMOST_FULL_THRESH(ALMOST_FULL_THRESH),
        .ALMOST_EMPTY_THRESH(ALMOST_EMPTY_THRESH)
    ) uart_fifo (
        .clk(clk),
        .rst_n(reset_n),
        .wr_en(wr_en),
        .wr_data(wr_data),
        .rd_en(rd_en),
        .rd_data(tx_data),
        .full(full),
        .empty(empty),
        .almost_full(almost_full),
        .almost_empty(almost_empty),
        .count(fifo_count)
    );
    
    // Control signal for reading from FIFO
    assign data_available = !empty;
    assign rd_en = tx_ready && data_available;
    logic tx_valid_reg;

    always_ff @(posedge clk or posedge reset_n) begin
        if (reset_n)
            tx_valid_reg <= 0;
        else
            tx_valid_reg <= rd_en;  // pulse when FIFO is read
        end

        assign tx_valid = tx_valid_reg;

    
    // Instantiate the UART transmitter controller
    uart_tx_controller #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE),
        .FIFO_DEPTH(FIFO_DEPTH)
    ) uart_controller (
        .clk(clk),
        .reset(~reset_n),  // Convert active low to active high reset
        .tx_data(tx_data),
        .baud_divisor(),   // Internal calculation, not used externally
        .data_available(data_available),
        .parity_sel(parity_sel),
        .stop_bits(stop_bits),
        .start_bit(start_bit),
        .tx_valid(tx_valid),
        .tx_done(tx_done),
        .tx_ready(tx_ready),
        .tx_serial(tx_serial),
        .tx_busy(tx_busy)
    );

endmodule