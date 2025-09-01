`timescale 1ns/1ps

module tb_ddr_controller;

    // Parameters consistent with controller
    localparam ADDR_WIDTH = 13;
    localparam BANK_WIDTH = 2;
    localparam DATA_WIDTH = 16;

    // Clock / Reset
    logic clk;
    logic rst_n;

    // Request interface
    logic                    write_req;
    logic                    read_req;
    logic [ADDR_WIDTH-1:0]   addr_in;
    logic [BANK_WIDTH-1:0]   bank_in;
    logic [DATA_WIDTH-1:0]   wdata_in;
    logic                    wr_ready;
    logic                    rd_valid;
    logic [DATA_WIDTH-1:0]   rd_data_out;

    // DDR pins (abstract, no real DDR chip)
    logic [ADDR_WIDTH-1:0]   ddr_addr;
    logic [BANK_WIDTH-1:0]   ddr_ba;
    logic                    ddr_cke;
    logic                    ddr_cs_n;
    logic                    ddr_ras_n;
    logic                    ddr_cas_n;
    logic                    ddr_we_n;
    wire  [DATA_WIDTH-1:0]   ddr_dq;    // must be wire for inout!
    logic [DATA_WIDTH/8-1:0] ddr_dqm;
    logic                    ddr_dq_oe;

    // DUT instantiation
    ddr_controller #(
        .ADDR_WIDTH (ADDR_WIDTH),
        .BANK_WIDTH (BANK_WIDTH),
        .DATA_WIDTH (DATA_WIDTH)
    ) dut (
        .clk        (clk),
        .rst_n      (rst_n),

        .write_req  (write_req),
        .read_req   (read_req),
        .addr_in    (addr_in),
        .bank_in    (bank_in),
        .wdata_in   (wdata_in),
        .wr_ready   (wr_ready),
        .rd_valid   (rd_valid),
        .rd_data_out(rd_data_out),

        .ddr_addr   (ddr_addr),
        .ddr_ba     (ddr_ba),
        .ddr_cke    (ddr_cke),
        .ddr_cs_n   (ddr_cs_n),
        .ddr_ras_n  (ddr_ras_n),
        .ddr_cas_n  (ddr_cas_n),
        .ddr_we_n   (ddr_we_n),
        .ddr_dq     (ddr_dq),
        .ddr_dqm    (ddr_dqm),
        .ddr_dq_oe  (ddr_dq_oe)
    );

    // ------------------------------------------------------------------------
    // Clock generation: 100 MHz (10 ns period)
    // ------------------------------------------------------------------------
    initial clk = 0;
    always #5 clk = ~clk;

    // ------------------------------------------------------------------------
    // Simple tri-state driver model for ddr_dq (controller already drives it)
    // ------------------------------------------------------------------------
    assign ddr_dq = (ddr_dq_oe) ? wdata_in : 'hz;

    // ------------------------------------------------------------------------
    // Test sequence
    // ------------------------------------------------------------------------
    initial begin
        // Reset
        rst_n     = 0;
        write_req = 0;
        read_req  = 0;
        addr_in   = '0;
        bank_in   = '0;
        wdata_in  = '0;

        $display("[%0t] INFO: Applying reset", $time);
        #50;
        rst_n = 1;

        // Wait for initialization (controller default T_POWERUP=200 cycles)
        // Give some extra margin (3000 ns)
        #3000;

        $display("[%0t] INFO: Controller initialized, starting test", $time);

        // -------------------------------
        // Write request
        // -------------------------------
        @(posedge clk);
        if (wr_ready) begin
            addr_in   = 13'h1A3;
            bank_in   = 2'b01;
            wdata_in  = 16'hBEEF;
            write_req = 1;
            @(posedge clk);
            write_req = 0;
            $display("[%0t] INFO: Issued WRITE addr=0x%0h bank=%0d data=0x%0h",
                     $time, addr_in, bank_in, wdata_in);
        end else begin
            $display("[%0t] ERROR: Write not accepted", $time);
        end

        // Wait some cycles
        repeat (20) @(posedge clk);

        // -------------------------------
        // Read request
        // -------------------------------
        @(posedge clk);
        addr_in  = 13'h1A3;
        bank_in  = 2'b01;
        read_req = 1;
        @(posedge clk);
        read_req = 0;
        $display("[%0t] INFO: Issued READ addr=0x%0h bank=%0d",
                 $time, addr_in, bank_in);

        // Wait for read data to return
        wait (rd_valid);
        $display("[%0t] INFO: Read data returned = 0x%0h", $time, rd_data_out);

        // -------------------------------
        // Allow refresh cycle
        // -------------------------------
        $display("[%0t] INFO: Waiting for refresh event", $time);
        #10000;

        $display("[%0t] INFO: Simulation completed", $time);
        $finish;
    end

endmodule
