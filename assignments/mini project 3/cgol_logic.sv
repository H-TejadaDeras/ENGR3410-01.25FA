/*  
 *  Conway's Game of Life Logic
 *  Henry Tejada Deras - 10-19-2025
 *  
 *  Generates next time step board using John Conway's Game of Life Game Logic
 *  Rules Implemented:
 *  - Any living cell with fewer than two living neighbors dies.
 *  - Any living cell with two or three living neighbors continues living.
 *  - Any living cell with more than three living neighbors dies.
 *  - Any dead cell with exactly three living neighbors becomes a living cell.
 *  - Cyclic Boundary Conditions
 *  
 *  Inputs:
 *  logic clk: Clock signal
 *  logic [6:0] i_game_board: Game board to be simulated 1 time step.
 *  
 *  Outputs:
 *  logic [6:0] o_game_board: Updated Game Board after 1 time step.
 */ 
// `begin_keywords "1800-2005" // SystemVerilog-2005
`include "cgol_cell.sv"

 module cgol_logic(
    input   logic       clk,
    input   logic [63:0] i_game_board,
    output  logic [63:0] o_game_board
 );
   logic [9:0] cell_0_local_game_board = 0;
    // Add Lookup Table to make 3x3 grids
   cell_0_local_game_board = {i_game_board[63], i_game_board[56], i_game_board[57], i_game_board[7], i_game_board[0], i_game_board[1], i_game_board[15], i_game_board[8], i_game_board[9]};
    // Calculate whether center of 3x3 grid would survive/die/spawn
    gol_cell cell_0 (
        .clk                  (clk),
        .reset                (reset),
        .i_local_game_board   (cell_0_local_game_board),
        .o_cell               (o_game_board[0])
    );
    // Assemble back together values
 endmodule
 // `end_keywords "1800-2005" // SystemVerilog-2005