/*  
 *  Conway's Game of Life Cell Logic
 *  Henry Tejada Deras - 10-19-2025
 *  
 *  Generates next time step cell using John Conway's Game of Life Game Logic
 *  Rules Implemented:
 *  - Any living cell with fewer than two living neighbors dies.
 *  - Any living cell with two or three living neighbors continues living.
 *  - Any living cell with more than three living neighbors dies.
 *  - Any dead cell with exactly three living neighbors becomes a living cell.
 *  - Cyclic Boundary Conditions
 *  
 *  Inputs:
 *  logic clk: Clock signal
 *  logic reset: Used to reset module after computation.
 *  logic [9:0] i_local_game_board: Cell and neighbors to be simulated 1 time
 *      step. Note: Only entries from 0 to 8 will be valid. The remaining
 *      values will not be considered (as they are not part of the local 3x3 
 *      grid).
 *  
 *  Outputs:
 *  logic o_cell: State of cell for next time step; 1 - Alive, 0 - Dead
 */ 
// `begin_keywords "1800-2005" // SystemVerilog-2005

module cgol_cell(
    input  logic       clk,
    input  logic       reset,
    input  logic [9:0] i_local_game_board,
    output logic       o_cell
);
    // Variable Declarations
    localparam ALIVE = 1'b1;
    localparam DEAD = 1'b0;
    logic [3:0] alive_neighbors_count = 0;
    logic current_cell_state = i_local_game_board[5];

    // Reset Module Logic
    always_comb @(posedge reset) begin
        logic [3:0] alive_neighbors_count = 0;
        logic o_cell = 0;
    end

    // Count Alive Neighbors to Cell; Cell 5 is omitted since that is current cell
    always_comb @(posedge clk) begin
    alive_neighbors_count = i_local_game_board[0] + i_local_game_board[1] + 
        i_local_game_board[2] + i_local_game_board[3] + i_local_game_board[4] +
        i_local_game_board[6] + i_local_game_board[7] + i_local_game_board[8] + 
        i_local_game_board[9];
    end

    // Apply Alive/Dead Conditions
    always_ff begin
        case (current_cell_state)
            ALIVE: begin
                if (alive_neighbors_count == 2 | alive_neighbors_count == 3) begin
                    // Alive Condition 1 - Any living cell with two or three living
                    //      neighbors continues living.
                    o_cell <= ALIVE;
                end else if (alive_neighbors_count < 2) begin
                    // Dead Condition 1 - Any living cell with fewer than two living
                    //      neighbors dies.
                    o_cell <= DEAD;
                end else if (condition) begin
                    // Dead Condition 2 - Any living cell with more than three
                    //      living neighbors dies.
                    o_cell <= DEAD;
                    
                end
            end
            DEAD: begin
                if (alive_neighbors_count == 3) begin
                    // Alive Condition 2 - Any dead cell with exactly three living
                    //      neighbors becomes a living cell.
                    o_cell <= ALIVE;
                end
            end
        endcase
    end
endmodule
// `end_keywords "1800-2005" // SystemVerilog-2005