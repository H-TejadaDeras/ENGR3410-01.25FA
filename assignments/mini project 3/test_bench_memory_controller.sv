/*
 *  Two-Bank Memory Controller Test Bench
 *  Henry Tejada Deras - 10-28-2025
 */
// `begin_keywords "1800-2005" // SystemVerilog-2005
`timescale 10ns/10ns
`include "memory_controller.sv"

module test_bench_memory_controller;
    logic clk = 0;
    logic data;
    
    // Variable Declarations
    localparam READ_ENTRY = 2'b00;
    localparam WRITE_ENTRY = 2'b01;
    localparam CYCLE_REGISTERS = 2'b10;
    localparam PAUSE = 2'b11;

    localparam READ_REG = 2'b00; // From memory_controller.sv
    localparam WRITE_REG = 2'b01; // From memory_controller.sv
    localparam CYCLE_REG = 2'b11; // From memory_controller.sv
    localparam IDLE = 2'b10; // From memory_controller.sv

    parameter READ_ENTRY_CLK_CYCLES = 2;
    parameter WRITE_ENTRY_CLK_CYCLES = 2;
    parameter CYCLE_REGISTERS_CLK_CYCLES = 64;
    parameter PAUSED_STATE_CLK_CYCLES = 500;

    logic [$clog2(READ_ENTRY_CLK_CYCLES):0] read_entry_counter = 0;
    logic [$clog2(WRITE_ENTRY_CLK_CYCLES):0] write_entry_counter = 0;
    logic [$clog2(CYCLE_REGISTERS_CLK_CYCLES):0] cycle_registers_counter = 0;
    logic [$clog2(PAUSED_STATE_CLK_CYCLES):0] paused_state_counter = 0;
    logic [5:0] memory_address_counter = 63;
    logic [1:0] state = PAUSE;

    // Net Declarations
    logic [1:0] memory_operation;
    logic [5:0] memory_operation_address;
    logic i_data;
    logic o_data;

    // Module Declarations
    memory_controller #(
        .MEM_INIT_FILE  ("cgol_seeds/toad_tester.bin")
    ) u0 (
        .clk            (clk), 
        .operation      (memory_operation),
        .reg_address    (memory_operation_address),
        .i_data         (i_data),
        .o_data         (o_data)
    );

    initial begin
        $dumpfile("memory_controller.vcd");
        $dumpvars(0, u0);
        #100000000
        $finish;
    end

    // Make Clock Signal
    always begin
        #2
        clk = ~clk;
    end

    // Simulate Memory Requests
    always_ff @(posedge clk) begin
        case (state)
            READ_ENTRY: begin
                memory_operation <= READ_REG;
                memory_operation_address <= memory_address_counter;
                data <= o_data;
                if (read_entry_counter >= READ_ENTRY_CLK_CYCLES) begin
                    state <= WRITE_ENTRY;
                    read_entry_counter <= 0;
                end else begin
                    read_entry_counter <= read_entry_counter + 1;
                end
            end

            WRITE_ENTRY: begin
                memory_operation <= WRITE_REG;
                memory_operation_address <= memory_address_counter;
                i_data <= ~data;
                if (write_entry_counter >= WRITE_ENTRY_CLK_CYCLES) begin
                    write_entry_counter <= 0;
                    if (memory_address_counter >= 6'd63) begin
                        state <= CYCLE_REGISTERS;
                    end else begin
                        state <= READ_ENTRY;
                        memory_address_counter <= memory_address_counter + 1;
                    end
                end else begin
                    write_entry_counter <= write_entry_counter + 1;
                end
            end

            CYCLE_REGISTERS: begin
                memory_operation <= CYCLE_REG;
                if (cycle_registers_counter >= CYCLE_REGISTERS_CLK_CYCLES) begin
                    cycle_registers_counter <= 0;
                    state <= PAUSE;
                end else begin
                    cycle_registers_counter <= cycle_registers_counter + 1;
                    state <= CYCLE_REGISTERS;
                end
            end

            PAUSE:begin
                paused_state_counter <= paused_state_counter + 1;
                if (paused_state_counter >= PAUSED_STATE_CLK_CYCLES) begin
                    state <= READ_ENTRY;
                end
            end
        endcase
    end
endmodule
// `end_keywords "1800-2005" // SystemVerilog-2005
