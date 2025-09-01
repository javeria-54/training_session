module uart_tx_controller # (
    parameter int CLK_FREQ = 50_000_000,
    parameter int BAUD_RATE = 115200,
    parameter int FIFO_DEPTH = 8
)(
    input   logic         clk, reset,
    input   logic [7:0]   tx_data,
    input   logic [11:0]  baud_divisor,
    input                 data_available, 
    input   logic [1:0]   parity_sel, 
    input   logic         stop_bits, start_bit, tx_valid,
    output  logic         tx_done,     
    output  logic         tx_ready, tx_serial, tx_busy
);
    
    // Calculate baud divisor from parameters
    localparam int BAUD_DIVISOR = CLK_FREQ / BAUD_RATE;
    assign baud_divisor = BAUD_DIVISOR[11:0];  // Truncate to 12 bits if needed

    // Internal signals
    logic [11:0]    shift_reg;
    logic [3:0]     packet_size, bit_counter;
    logic           parity;
    logic [11:0]    baud_counter;
    logic           baud_tick;

    typedef enum logic [2:0] {
        IDLE,
        LOAD,
        START_BIT,
        DATA_BITS,
        PARITY,
        STOP_BIT
    } state_t;

    state_t current_state, next_state;

    // Baud rate generator
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            baud_counter <= 0;
            baud_tick <= 0;
        end else begin
            if (current_state != IDLE) begin
                if (baud_counter == baud_divisor - 1) begin
                    baud_counter <= 0;
                    baud_tick <= 1;
                end else begin
                    baud_counter <= baud_counter + 1;
                    baud_tick <= 0;
                end
            end else begin
                baud_counter <= 0;
                baud_tick <= 0;
            end
        end
    end

    // State register and output handling
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= IDLE;
            shift_reg <= 12'hFFF;
            bit_counter <= 0;
            tx_serial <= 1'b1;
            tx_done <= 0;
            tx_ready <= 1'b1;
            tx_busy <= 0;
        end else begin
            current_state <= next_state;
            
            // Default values
            tx_done <= 0;
            
            case (current_state)
                IDLE: begin
                    tx_serial <= 1'b1;
                    tx_ready <= 1'b1;
                    tx_busy <= 0;
                    bit_counter <= 0;
                end
                
                LOAD: begin
                    if (start_bit) begin
                        shift_reg <= {1'b1, parity, tx_data, 1'b0};
                    end else begin
                        shift_reg <= {1'b1, parity, tx_data};
                    end
                    tx_ready <= 0;
                    tx_busy <= 1;
                end
                
                START_BIT: begin
                    if (baud_tick) begin
                        tx_serial <= shift_reg[0];
                        shift_reg <= {1'b1, shift_reg[11:1]};
                    end
                end
                
                DATA_BITS: begin
                    if (baud_tick) begin
                         tx_serial <= shift_reg[0];  // Transmit data bit
                         shift_reg <= {1'b1, shift_reg[11:1]}; // Shift right, fill with 0
                        if (bit_counter == 7) begin
                            bit_counter <= 0;
                        end else begin
                            bit_counter <= bit_counter + 1;
                        end
                    end
                end
                
                PARITY: begin
                    if (baud_tick) begin
                        tx_serial <= parity;
                    end
                end
                
                STOP_BIT: begin
                    if (baud_tick) begin
                        tx_serial <= 1'b1;
                        tx_done <= 1;
                        if (data_available && tx_valid) begin
                            tx_ready <= 0;
                            tx_busy <= 1;
                        end else begin
                            tx_ready <= 1;
                            tx_busy <= 0;
                        end
                    end
                end
                
                default: begin
                    tx_serial <= 1'b1;
                    tx_ready <= 1'b1;
                    tx_busy <= 0;
                end
            endcase
        end
    end 

    // Next state logic
    always_comb begin
        next_state = current_state;
        
        case (current_state)
            IDLE: begin
                if (data_available && tx_valid) begin
                    next_state = LOAD;
                end
            end
            
            LOAD: begin
                next_state = start_bit ? START_BIT : DATA_BITS;
            end
            
            START_BIT: begin
                if (baud_tick) begin
                    next_state = DATA_BITS;
                end
            end
            
            DATA_BITS: begin
                if (baud_tick && (bit_counter == 7)) begin
                    if (parity_sel != 2'b00) begin
                        next_state = PARITY;
                    end else begin
                        next_state = STOP_BIT;
                    end
                end
            end
            
            PARITY: begin
                if (baud_tick) begin
                    next_state = STOP_BIT;
                end
            end
            
            STOP_BIT: begin
                if (baud_tick) begin
                    if (data_available && tx_valid) begin
                        next_state = LOAD;
                    end else begin
                        next_state = IDLE;
                    end
                end
            end
            
            default: next_state = IDLE;
        endcase
    end

    // Parity calculation
    always_comb begin
        case (parity_sel)
            2'b00: parity = 1'b0; // No parity
            2'b01: parity = ^tx_data; // Even parity
            2'b10: parity = ~^tx_data; // Odd parity
            2'b11: parity = 1'b1; // Always 1 (mark)
            default: parity = 1'b0;
        endcase
    end

    // Packet size determination
    always_comb begin
        case ({start_bit, stop_bits, parity_sel != 2'b00})
            3'b100: packet_size = 4'd9;  // Start + 8 data + stop
            3'b101: packet_size = 4'd10; // Start + 8 data + parity + stop
            3'b110: packet_size = 4'd10; // Start + 8 data + 2 stops
            3'b111: packet_size = 4'd11; // Start + 8 data + parity + 2 stops
            3'b000: packet_size = 4'd8;  // 8 data only
            3'b001: packet_size = 4'd9;  // 8 data + parity
            3'b010: packet_size = 4'd9;  // 8 data + stop
            3'b011: packet_size = 4'd10; // 8 data + parity + stop
            default: packet_size = 4'd10;
        endcase
    end

endmodule