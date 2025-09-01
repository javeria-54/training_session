module programmable_counter (
    input  logic        clk,
    input  logic        rst_n,       // active-low synchronous reset
    input  logic        load,        // load new value
    input  logic        enable,      // enable counting
    input  logic        up_down,     // 1 = up, 0 = down
    input  logic [7:0]  load_value,  // value to load
    input  logic [7:0]  max_count,   // programmable maximum
    output logic [7:0]  count,       // current counter value
    output logic        tc,          // terminal count flag
    output logic        zero         // zero detect flag
);

    always_ff @(posedge clk ) begin
        if (!rst_n ) begin
            count <= 0;
        end else if (!load) begin
            count <= 0;
        end else if (load & updown) begin
            count <= load_value;
        end else if (enable & !up_down) begin
            count <= count;
        end else if (enable & updown) begin
            count <= count;
        end else if (load & !updown) begin
            count <= load_value;
        end else if (!enable) begin
            count <= count;
        end else if (!load & enable & up_down) begin
            if (max_count > count) begin 
                count <= count + 1;
            end else if (max_count < count) begin
                count <= 0;
            end else begin
                count <= count;
            end      
        end else if (!load & enable & !up_down) begin
            if (count < load_value) begin
                count <= count - 1;
            end else if (load_value < count) begin
                count <= 0;
            end  else begin
                count <= count;
            end
        end else begin
            count <= 0;
        end 
    end 
    // Status flag outputs
    assign tc   = (up_down && (count == max_count)) ||   // Up reached max
                  (!up_down && (count == 0));            // Down reached zero

    assign zero = (count == 0);

endmodule
