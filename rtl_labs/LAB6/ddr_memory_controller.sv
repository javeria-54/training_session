// Simple DDR Memory Controller (educational, simplified)
// - Single clock domain (system clock)
// - Assumes an abstract "DDR device" that accepts command pulses with typical active low signals
// - Fixed burst length, simplified timing counters (parametric)
// - Request/response FIFO style interface for CPU/domain logic
//
// Interface:
//  write_req, read_req: single-cycle pulse to request op
//  addr_in, bank_in, wdata_in: request inputs
//  wr_ready / rd_valid: handshake outputs
//  rd_data_out: read data returned after latency
//
// Note: Timing parameters (in cycles) must be set to match simulation/testbench clock period.

module ddr_controller #(
    parameter ADDR_WIDTH  = 13,   // row/col separation not modeled; abstract address width
    parameter BANK_WIDTH  = 2,
    parameter DATA_WIDTH  = 16,   // per DQ (simple)
    parameter CLK_FREQ_HZ = 100_000_000, // 100 MHz example
    // timing in cycles (set according to clock period)
    parameter integer T_POWERUP = 200,  // cycles until we can issue precharge
    parameter integer T_RFC     = 10,   // refresh command to refresh complete
    parameter integer T_RCD     = 3,    // activate to read/write
    parameter integer T_RP      = 3,    // precharge period
    parameter integer T_CAS     = 3,    // CAS latency to return data
    parameter integer T_REF_INT = 7800  // cycles = tREFI (approx 7.8us at 100MHz -> 780 cycles; using 7800 as safe large default)
) (
    input  logic                     clk,
    input  logic                     rst_n,

    // Simple request interface (from CPU / master)
    input  logic                     write_req,   // single cycle pulse
    input  logic                     read_req,    // single cycle pulse
    input  logic [ADDR_WIDTH-1:0]    addr_in,
    input  logic [BANK_WIDTH-1:0]    bank_in,
    input  logic [DATA_WIDTH-1:0]    wdata_in,
    output logic                     wr_ready,    // controller can accept write
    output logic                     rd_valid,    // read data valid (single cycle)
    output logic [DATA_WIDTH-1:0]    rd_data_out,

    // Minimal DDR physical signals (abstracted)
    output logic [ADDR_WIDTH-1:0]    ddr_addr,
    output logic [BANK_WIDTH-1:0]    ddr_ba,
    output logic                     ddr_cke,
    output logic                     ddr_cs_n,
    output logic                     ddr_ras_n,
    output logic                     ddr_cas_n,
    output logic                     ddr_we_n,
    inout  logic [DATA_WIDTH-1:0]    ddr_dq,
    output logic [DATA_WIDTH/8-1:0]  ddr_dqm,
    output logic                     ddr_dq_oe   // drive enable for data bus
);
    // ================================
    // Dummy DDR Memory (for simulation)
    // ================================
    logic [DATA_WIDTH-1:0] mem [0:(1<<ADDR_WIDTH)-1][0:(1<<BANK_WIDTH)-1];

    // Internal constants & types
    typedef enum logic [2:0] {
        PWRUP,
        INIT_PRECHARGE,
        INIT_MRS,
        READY,
        REFRESH,
        CMD_ACTIVE
    } init_state_t;

    init_state_t init_state;

    // command state machine for scheduling read/write/refresh
    typedef enum logic [2:0] {
        IDLE,
        ACTIVATE,
        READ_CMD,
        WRITE_CMD,
        PRECHARGE_CMD,
        WAIT_DATA
    } cmd_state_t;

    cmd_state_t cmd_state;

    // Simple request FIFOs (depth 4)
    logic [ADDR_WIDTH-1:0] req_addr_q [0:3];
    logic [BANK_WIDTH-1:0] req_bank_q [0:3];
    logic [DATA_WIDTH-1:0] req_wdata_q [0:3];
    logic [1:0] req_type_q; // 0=none, 1=write, 2=read
    int head, tail, count;

    // simple read return buffer
    logic [DATA_WIDTH-1:0] read_return_data;
    logic read_return_valid;

    // timing counters
    int timer;
    int ref_timer;

    // DDR command outputs default inactive (CS# low active? In DDR typical CS# low selects - we'll keep active low)
    // For simplicity: cs_n = 0 (selected), we'll toggle ras/cas/we to encode commands.
    // A more complete design would use CS high to disable chip when not selected.
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // resets
            init_state <= PWRUP;
            cmd_state  <= IDLE;
            head <= 0; tail <= 0; count <= 0;
            wr_ready <= 1;
            rd_valid <= 0;
            read_return_valid <= 0;
            timer <= 0;
            ref_timer <= 0;
            // default DDR pins
            ddr_cke <= 0;
            ddr_cs_n <= 1; // deselected until init complete
            ddr_ras_n <= 1;
            ddr_cas_n <= 1;
            ddr_we_n  <= 1;
            ddr_dq_oe <= 0;
            ddr_addr <= '0;
            ddr_ba <= '0;
        end else begin
            // default outputs each cycle (inactive)
            rd_valid <= 0;
            ddr_ras_n <= 1;
            ddr_cas_n <= 1;
            ddr_we_n  <= 1;
            ddr_dq_oe <= 0;
            ddr_cs_n <= 0; // keep chip selected for simplicity
            // initialization FSM
            case (init_state)
                PWRUP: begin
                    ddr_cke <= 0;
                    if (timer < T_POWERUP) begin
                        timer <= timer + 1;
                    end else begin
                        ddr_cke <= 1; // enable clock
                        timer <= 0;
                        init_state <= INIT_PRECHARGE;
                    end
                end
                INIT_PRECHARGE: begin
                    // issue an all-bank precharge (simplified as asserting RAS & WE low)
                    ddr_ras_n <= 0;
                    ddr_cas_n <= 1;
                    ddr_we_n  <= 0; // PRECHARGE (Ras=0, We=0, Cas=1)
                    ddr_addr[10] <= 1'b1; // A10 = 1 -> all banks precharge in many ddr chips
                    // wait tRP cycles
                    if (timer < T_RP) begin
                        timer <= timer + 1;
                    end else begin
                        timer <= 0;
                        init_state <= INIT_MRS;
                    end
                end
                INIT_MRS: begin
                    // Mode Register Set - simplified
                    ddr_ras_n <= 0;
                    ddr_cas_n <= 0;
                    ddr_we_n  <= 0; // MRS (Ras=0,Cas=0,We=0) on a real device with address bits set
                    // wait 1 cycle then go to READY
                    if (timer < 1) begin
                        timer <= timer + 1;
                    end else begin
                        timer <= 0;
                        init_state <= READY;
                    end
                end
                READY: begin
                    // Controller operational
                    // handle refresh timer
                    if (ref_timer < T_REF_INT) begin
                        ref_timer <= ref_timer + 1;
                    end else begin
                        ref_timer <= 0;
                        init_state <= REFRESH;
                    end
                end
                REFRESH: begin
                    // issue refresh command (represented by RAS=0,CAS=0,WE=1)
                    ddr_ras_n <= 0;
                    ddr_cas_n <= 0;
                    ddr_we_n  <= 1; // REFRESH
                    // wait tRFC cycles
                    if (timer < T_RFC) begin
                        timer <= timer + 1;
                    end else begin
                        timer <= 0;
                        init_state <= READY;
                    end
                end
                default: init_state <= READY;
            endcase

            // Accept requests into simple FIFO if ready and init complete
            if (init_state == READY) begin
                if ((write_req || read_req) && (count < 4)) begin
                    // push request
                    req_addr_q[tail] <= addr_in;
                    req_bank_q[tail] <= bank_in;
                    req_wdata_q[tail] <= wdata_in;
                    if (write_req) req_type_q[tail] <= 1;
                    else req_type_q[tail] <= 2;
                    tail <= (tail + 1) % 4;
                    count <= count + 1;
                end
                // update wr_ready based on FIFO space
                wr_ready <= (count < 4);
            end else begin
                wr_ready <= 0;
            end

            // Command scheduler: service FIFO head requests when not in REFRESH/init
            if (init_state == READY && cmd_state == IDLE && count > 0) begin
                // start ACTIVATE then READ/WRITE
                cmd_state <= ACTIVATE;
                timer <= 0;
                // present address / bank to ddr_addr/ba (row)
                ddr_addr <= req_addr_q[head];
                ddr_ba   <= req_bank_q[head];
            end

            // Detailed command state machine
            case (cmd_state)
                IDLE: begin
                    // nothing
                end
                ACTIVATE: begin
                    // issue ACTIVATE command (RAS=0, CAS=1, WE=1)
                    ddr_ras_n <= 0;
                    ddr_cas_n <= 1;
                    ddr_we_n  <= 1;
                    // wait tRCD cycles then issue read/write
                    if (timer < T_RCD) begin
                        timer <= timer + 1;
                    end else begin
                        timer <= 0;
                        if (req_type_q[head] == 1) cmd_state <= WRITE_CMD;
                        else cmd_state <= READ_CMD;
                        // setup column address on addr lines (simple reuse)
                        ddr_addr <= req_addr_q[head];
                        ddr_ba   <= req_bank_q[head];
                    end
                end
                READ_CMD: begin
                        ddr_ras_n <= 1;
                        ddr_cas_n <= 0;
                        ddr_we_n  <= 1;  // READ

                        if (timer < T_CAS) begin
                            timer <= timer + 1;
                        end else begin
                            // return stored data
                            read_return_data <= mem[ req_addr_q[head] ][ req_bank_q[head] ];
                            read_return_valid <= 1;

                            // consume queue entry
                            head <= (head + 1) % 4;
                            count <= count - 1;
                            cmd_state <= IDLE;
                            timer <= 0;
                        end
                    end

                WRITE_CMD: begin
                        ddr_dq_oe <= 1;
                        ddr_ras_n <= 1;
                        ddr_cas_n <= 0;
                        ddr_we_n  <= 0;  // WRITE

                        if (timer < 1) begin
                            timer <= timer + 1;
                        end else begin
        // store to dummy memory
                            mem[ req_addr_q[head] ][ req_bank_q[head] ] <= req_wdata_q[head];

                            head <= (head + 1) % 4;
                            count <= count - 1;
                            cmd_state <= IDLE;
                            timer <= 0;
                        end
                    end
            endcase 
            // produce read data valid to external interface
            if (read_return_valid) begin
                rd_valid <= 1;
                rd_data_out <= read_return_data;
                read_return_valid <= 0;
            end
        end
    end

    // Simple inout DDQ handling for simulation: drive when ddr_dq_oe asserted, else high-Z
    // In real hardware this would be a tri-state buffer.
    assign ddr_dq = (ddr_dq_oe ? req_wdata_q[(head)%4] : 'z);

endmodule
