module programmable_counter (
    input  logic        clk,        // Clock
    input  logic        rst_n,      // Active-low reset
    input  logic        load,       // Load enable
    input  logic        enable,     // Counter enable
    input  logic        up_down,    // 1 = count up, 0 = count down
    input  logic [7:0]  load_value, // Value to load
    input  logic [7:0]  max_count,  // Maximum count value (limit)
    output logic [7:0]  count,      // Counter value
    output logic        tc,         // Terminal count flag
    output logic        zero        // Zero flag
);

    // Flags
    assign tc   = (count == max_count); // Terminal count detect
    assign zero = (count == 8'b0);      // Zero detect

    // Sequential counter logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Scenario 7: RESET (highest priority)
            count <= 8'b0;

        end else begin
            if (load && (count > load_value) && !enable && !up_down) begin
                // Scenario 1: load=1, enable=0, up_down=0, count > load_value
                count <= count - 1;

            end else if (load && enable) begin
                // Scenarios 2, 3: load=1, enable=1 (LOAD)
                count <= load_value;

            end else if (load) begin
                // Scenario 8, 9: load=1 (acts as update)
                count <= load_value;

            end else if (!load && enable && up_down) begin
                // Scenarios 10-14: count UP
                if (count < max_count) begin
                    count <= count + 1;
                end else begin
                    count <= count;  // Wrap around at max
                end 

            end else if (!load && enable && !up_down) begin
                // Scenarios 4, 5, 15: count DOWN
                if (count > load_value) begin
                    count <= count - 1;
                end else begin
                    count <= load_value; // Wrap around at zero
                end 

            end else if (!enable) begin
                // Scenarios 16-17: HOLD
                count <= count;

            end else begin
                // Default case (do nothing)
                count <= count;
            end
        end
    end

endmodule
