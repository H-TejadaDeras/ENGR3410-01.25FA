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
`include "memory.sv"
`include "ws2812b.sv"

module top (
    input logic clk,
    input logic SW,
    output logic _31b
);
    // Variable Declarations
    logic [23:0] shift_reg = 24'd0;
    logic [7:0] seed_memory [7:0];
    logic [7:0] o_game_board [7:0];
    logic [63:0] seed_memory_vector;

    // Net Declarations
    logic ws2812b_out;

    // Read Seed Memories
    always_comb begin
        $readmemb("cgol_seeds/toad_tester.bin", seed_memory);
    end

    // Convert 2-D Memory to 1-D Memory
    genvar i;
    generate 
        for (i=0; i<8; ++i) begin
            assign seed_memory_vector[((i + 1) * 8 - 1): i * 8] = [i] seed_memory [7:0];
        end
    endgenerate

    // assign o_game_board = seed_memory;
    // Process CGOL State
    cgol_logic u1 (
        .clk            (clk),
        .i_game_board   (seed_memory_vector),
        .o_game_board   (o_game_board)
    );

    // WS2812B output driver
    // ws2812b u4 (
    //     .clk            (clk), 
    //     .serial_in      (shift_reg[23]), 
    //     .transmit       (transmit_pixel), 
    //     .ws2812b_out    (ws2812b_out), 
    //     .shift          (shift)
    // );
    // Timers

    // assign _31b = ws2812b_out;
endmodule
// `end_keywords "1800-2005" // SystemVerilog-2005