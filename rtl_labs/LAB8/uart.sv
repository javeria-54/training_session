module uart # (
    parameter int CLK_FREQ   = 50_000_000,
    parameter int BAUD_RATE  = 115200,
    parameter int FIFO_DEPTH = 8,
    parameter int DATA_WIDTH = 8,
    parameter int ALMOST_FULL_THRESH   = 6,
    parameter int ALMOST_EMPTY_THRESH  = 2
)(
    input  logic       clk,
    input  logic       rst_n,
    input  logic [7:0] tx_data,
    input  logic       tx_valid,
    output logic       rx_error,       // error (framing/parity)
    output logic       rx_busy,        // receiver busy
    output logic [7:0] rx_data,        // received data output
    output logic       rx_valid        // valid pulse when data is ready
);

    logic tx_busy,tx_ready,tx_serial,rx_serial;
    assign rx_serial = tx_serial;

    uart_transmitter #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE),
        .FIFO_DEPTH(FIFO_DEPTH),
        .DATA_WIDTH(DATA_WIDTH),
        .ALMOST_FULL_THRESH(ALMOST_FULL_THRESH),
        .ALMOST_EMPTY_THRESH(ALMOST_EMPTY_THRESH)
    )tx_inst(
        .clk(clk),
        .rst_n(rst_n),
        .tx_data(tx_data),
        .tx_valid(tx_valid),
        .tx_ready(tx_ready),
        .tx_serial(tx_serial),
        .tx_busy(tx_busy)
);
    uart_rx_datapath #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE),
        .FIFO_DEPTH(FIFO_DEPTH),
        .DATA_WIDTH(DATA_WIDTH),
        .ALMOST_FULL_THRESH(ALMOST_FULL_THRESH),
        .ALMOST_EMPTY_THRESH(ALMOST_EMPTY_THRESH)
    )rx_inst(
        .clk(clk),
        .rst_n(rst_n),
        .rx_serial(rx_serial),      
        .rx_error(rx_error),       
        .rx_busy(rx_busy),        
        .rx_data(rx_data),        
        .rx_valid(rx_valid)      
);
endmodule