/*
 *  Conway's Game of Life Game Instance on WS2812B LED Matrix
 *  Henry Tejada Deras - 10-19-2025
 *  
 *  Plays Conway's Game of Life Game and displays state on WS2812B LED Matrix.
 *  
 *  Rules Implemented:
 *  - Any living cell with fewer than two living neighbors dies.
 *  - Any living cell with two or three living neighbors continues living.
 *  - Any living cell with more than three living neighbors dies.
 *  - Any dead cell with exactly three living neighbors becomes a living cell.
 *  - Cyclic Boundary Conditions
 */ 
// `begin_keywords "1800-2005" // SystemVerilog-2005
`include "cgol_logic.sv"
`include "memory_controller.sv"

module top (
    input logic clk,
    input logic SW,
    output logic _31b
);
    // Variable Declarations
    localparam HIGH = 1'b1;
    localparam LOW = 1'b0;

    localparam PROCESS_GAME_STATE = 2'b00;
    localparam CYCLE_REGISTERS = 2'b01;
    localparam PROCESS_OUTPUT = 2'b10;
    localparam PAUSE = 2'b11;

    logic [23:0] shift_reg = 24'd0;
    logic [1:0] state_top = PAUSE;

    // Net Declarations
    logic u1_start_trigger = LOW;
    logic u1_i_data;
    logic u1_i_start;
    logic [1:0] u1_memory_operation;
    logic [5:0] u1_memory_operation_address;
    logic u1_o_data;
    logic u1_o_done;
    logic u1_start_trigger_save = LOW;

    logic ws2812b_out;

    // Module Declarations
    cgol_logic u1 (
        .clk                        (clk),
        .i_data                     (u1_i_data),
        .i_start                    (u1_i_start),
        .memory_operation           (u1_memory_operation),
        .memory_operation_address   (u1_memory_operation_address),
        .o_data                     (u1_o_data),
        .o_done                     (u1_o_done)
    );
    
    memory_controller #(
        .MEM_INIT_FILE  ("cgol_seeds/toad_tester.bin")
    ) u2 (
        .clk            (clk),
        .operation      (u1_memory_operation),
        .reg_address    (u1_memory_operation_address),
        .i_data         (u1_o_data),
        .o_data         (u1_i_data)
    );

    // cgol_logic u3 (
    //     .clk                        (clk),
    //     .i_data                     (u1_i_data),
    //     .i_start                    (u1_i_start),
    //     .memory_operation           (u1_memory_operation),
    //     .memory_operation_address   (u1_memory_operation_address),
    //     .o_data                     (u1_o_data),
    //     .o_done                     (u1_o_done)
    // );
    
    // memory_controller #(
    //     .MEM_INIT_FILE  ("cgol_seeds/toad_tester.bin")
    // ) u4 (
    //     .clk            (clk),
    //     .operation      (u1_memory_operation),
    //     .reg_address    (u1_memory_operation_address),
    //     .i_data         (u1_o_data),
    //     .o_data         (u1_i_data)
    // );

    // cgol_logic u5 (
    //     .clk                        (clk),
    //     .i_data                     (u1_i_data),
    //     .i_start                    (u1_i_start),
    //     .memory_operation           (u1_memory_operation),
    //     .memory_operation_address   (u1_memory_operation_address),
    //     .o_data                     (u1_o_data),
    //     .o_done                     (u1_o_done)
    // );
    
    // memory_controller #(
    //     .MEM_INIT_FILE  ("cgol_seeds/toad_tester.bin")
    // ) u6 (
    //     .clk            (clk),
    //     .operation      (u1_memory_operation),
    //     .reg_address    (u1_memory_operation_address),
    //     .i_data         (u1_o_data),
    //     .o_data         (u1_i_data)
    // );

    // Top State Machine
    always_ff @(posedge clk) begin
        case (state_top)
            PROCESS_GAME_STATE: begin
                u1_start_trigger <= HIGH;
            end

            CYCLE_REGISTERS: begin
                u1_start_trigger <= LOW;
                state_top = PROCESS_OUTPUT;
            end

            PROCESS_OUTPUT: begin
                u1_start_trigger <= LOW;
                state_top <= PAUSE;
            end

            PAUSE: begin
                u1_start_trigger <= LOW;
                state_top <= PROCESS_GAME_STATE;
            end
        endcase
    end

    // Start Processing Data Trigger
    always_ff @(posedge clk) begin
        if (u1_start_trigger == HIGH && u1_start_trigger_save == LOW) begin
            u1_i_start <= HIGH;
            u1_start_trigger_save <= HIGH;
        end else if (u1_start_trigger == HIGH && u1_start_trigger_save == HIGH) begin // makes start signal 1 clk period long
            u1_i_start <= LOW;
        end else if (u1_start_trigger == LOW) begin // start trigger low -> save low, start should already be low
            u1_i_start <= LOW;
            u1_start_trigger_save <= LOW;
        end
    end

    // Next Step Trigger from CGOL_Logic Module
    always_ff @(posedge clk) begin
        if (u1_o_done == HIGH) begin
            state_top <= CYCLE_REGISTERS;
        end
    end

    // Start Game Trigger from User - Not functional currently, top state machine must be more developed
    always_ff @(posedge clk) begin
        if (SW == HIGH) begin
            state_top <= PROCESS_GAME_STATE;
        end
    end

    // Timers

    // assign _31b = ws2812b_out;
endmodule
// `end_keywords "1800-2005" // SystemVerilog-2005