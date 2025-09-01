module Rx_Datapath  #(
    parameter int CLK_FREQ = 50_000_000,
    parameter int BAUD_RATE = 115200
)(
    input   logic         clk, reset,
    input   logic         rx_serial,
    input   logic [11:0]  baud_divisor,
    input   logic [1:0]   parity_sel, 
    input   logic         stop_bits, start_bit_en,
    output  logic [7:0]   rx_data,
    output  logic         rx_valid,
    output  logic         rx_error,
    output  logic         rx_busy
);

    // Internal signals
    logic [7:0]    shift_reg;
    logic [3:0]    bit_counter;
    logic          calculated_parity;
    logic [11:0]   baud_counter;
    logic          baud_half_tick, baud_full_tick;
    logic          framing_error, parity_error;

    // Calculate baud divisor from parameters
    localparam int BAUD_DIVISOR = CLK_FREQ / BAUD_RATE;
    assign  baud_divisor = BAUD_DIVISOR[11:0];  // Truncate to 12 bits if needed


    // State machine
    typedef enum logic [2:0] {
        IDLE,
        START_BIT_DETECT,
        DATA_BITS,
        PARITY_CHECK,
        STOP_BIT,
        FRAME_COMPLETE
    } state_t;

    state_t current_state, next_state;

    // Baud rate generator with half and full ticks
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            baud_counter <= 0;
            baud_half_tick <= 0;
            baud_full_tick <= 0;
        end else begin
            if (current_state != IDLE) begin
                if (baud_counter == baud_divisor - 1) begin
                    baud_counter <= 0;
                    baud_full_tick <= 1;
                    baud_half_tick <= 0;
                end else if (baud_counter == (baud_divisor/2) - 1) begin
                    baud_counter <= baud_counter + 1;
                    baud_half_tick <= 1;
                    baud_full_tick <= 0;
                end else begin
                    baud_counter <= baud_counter + 1;
                    baud_half_tick <= 0;
                    baud_full_tick <= 0;
                end
            end else begin
                baud_counter <= 0;
                baud_half_tick <= 0;
                baud_full_tick <= 0;
            end
        end
    end

    // State register
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= IDLE;
            shift_reg <= 8'h00;
            bit_counter <= 0;
            rx_data <= 8'h00;
            rx_valid <= 0;
            rx_error <= 0;
            rx_busy <= 0;
            framing_error <= 0;
            parity_error <= 0;
        end else begin
            current_state <= next_state;
            
            // Default values
            rx_valid <= 0;
            
            case (current_state)
                IDLE: begin
                    rx_busy <= 0;
                    bit_counter <= 0;
                    framing_error <= 0;
                    parity_error <= 0;
                    rx_error <= 0;
                    if (rx_serial == 1'b0) begin  // Start bit detection
                        rx_busy <= 1;
                    end
                end
                
                START_BIT_DETECT: begin
                    rx_busy <= 1;
                    if (baud_half_tick) begin
                        // Verify start bit is still low at the center
                        if (rx_serial != 1'b0) begin
                            framing_error <= 1;  // False start bit
                        end
                    end
                end
                
                DATA_BITS: begin
                    rx_busy <= 1;
                    if (baud_full_tick) begin
                        // Sample data bit and shift into register
                        shift_reg <= {shift_reg[6:0], rx_serial};
                        bit_counter <= bit_counter + 1;
                    end
                end
                
                PARITY_CHECK: begin
                    rx_busy <= 1;
                    if (baud_full_tick) begin
                        // Check parity bit
                        case (parity_sel)
                            2'b01: parity_error <= (rx_serial != calculated_parity);  // Even parity
                            2'b10: parity_error <= (rx_serial == calculated_parity);  // Odd parity
                            default: parity_error <= 0;  // No parity check
                        endcase
                    end
                end
                
                STOP_BIT: begin
                    rx_busy <= 1;
                    if (baud_full_tick) begin
                        // Check stop bit(s)
                        if (rx_serial != 1'b1) begin
                            framing_error <= 1;  // Framing error
                        end
                    end
                end
                
                FRAME_COMPLETE: begin
                    rx_busy <= 0;
                    rx_data <= shift_reg;
                    rx_valid <= 1;
                    rx_error <= framing_error | parity_error;
                end
            endcase
        end
    end

    // Next state logic
    always_comb begin
        next_state = current_state;
        
        case (current_state)
            IDLE: begin
                if (rx_serial == 1'b0) begin  // Start bit detected
                    next_state = START_BIT_DETECT;
                end
            end
            
            START_BIT_DETECT: begin
                if (baud_half_tick) begin
                    if (rx_serial == 1'b0) begin  // Valid start bit
                        next_state = DATA_BITS;
                    end else begin               // False start
                        next_state = FRAME_COMPLETE;
                    end
                end
            end
            
            DATA_BITS: begin
                if (baud_full_tick && (bit_counter == 7)) begin
                    if (parity_sel != 2'b00) begin  // Parity enabled
                        next_state = PARITY_CHECK;
                    end else begin
                        next_state = STOP_BIT;
                    end
                end
            end
            
            PARITY_CHECK: begin
                if (baud_full_tick) begin
                    next_state = STOP_BIT;
                end
            end
            
            STOP_BIT: begin
                if (baud_full_tick) begin
                    next_state = FRAME_COMPLETE;
                end
            end
            
            FRAME_COMPLETE: begin
                next_state = IDLE;
            end
            
            default: next_state = IDLE;
        endcase
    end

    // Parity calculation (combinational)
    always_comb begin
        calculated_parity = ^shift_reg;  // Even parity calculation
    end

endmodule