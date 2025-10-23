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

// Macros for Variable Names
`define CELL(idx) ({cell_, ``idx})
`define CELL_LOCAL_GAME_BOARD(idx) ({cell_, ``idx, _local_game_board})

 module cgol_logic(
    input   logic        clk,
    input   logic [63:0] i_game_board_vector,
    output  logic [63:0] o_game_board_vector
 );
   // Variable Declarations
   parameter CURRENT_CELL_COUNTER_AMT = 20;
   logic [5:0] current_cell = 0; // Used to keep track of which is the current cell being simulated
   logic [9:0] local_game_board = 0;
   logic [2:0] column_index = 3'b0;
   logic [2:0] row_index = 3'b0;
   logic [$clog2(CURRENT_CELL_COUNTER_AMT):0] current_cell_timer = 0; // Used to change current cell
   logic reset;
   logic [7:0] i_game_board [7:0];

   // Internal Timers and things
   // Current Cell Variable
   always_ff @(posedge clk) begin
      if (current_cell_timer >= CURRENT_CELL_COUNTER_AMT) begin
         if (current_cell >= 63) begin
            current_cell <= 0;
         end else begin
            current_cell <= current_cell + 1;
         end
      end else begin
         current_cell_timer <= current_cell_timer + 1;
      end
   end

   // Column and Row Index for Game Board Indexing
   always_ff @(posedge current_cell) begin
      column_index[2:0] = column_index + 1;
      if (column_index == 3'b111) begin // Will fix later with counter for column index (every 8)
         row_index = column_index + 1;
      end
   end

   // Convert Vector to 2-D Array
   genvar j;
   generate 
      for (j=0; j<8; ++j) begin
         assign [j] i_game_board [7:0] = i_game_board_vector[((j + 1) * 8 - 1): j * 8];
      end
   endgenerate

   // Logic for creating local game board
   always_comb begin
      local_game_board = {i_game_board[{row_index - 1, column_index - 1}], 
      i_game_board[{row_index - 1, column_index}], 
      i_game_board[{row_index - 1, column_index + 1}], 
      i_game_board[{row_index, column_index - 1}], 
      i_game_board[{row_index, column_index}], 
      i_game_board[{row_index, column_index + 1}], 
      i_game_board[{row_index + 1, column_index - 1}], 
      i_game_board[{row_index + 1, column_index}], 
      i_game_board[{row_index + 1, column_index + 1}]};
   end

   // Cells
   cgol_cell u2 (
      .clk                 (clk),
      .reset               (reset),
      .i_local_game_board  (local_game_board),
      .o_cell              (o_game_board[current_cell])
   );

   // Lookup Table to make 3x3 grids
   // always_comb begin
   //    cell_0_local_game_board = {i_game_board[63], i_game_board[56], i_game_board[57], i_game_board[7], i_game_board[0], i_game_board[1], i_game_board[15], i_game_board[8], i_game_board[9]};
   //    cell_1_local_game_board = {i_game_board[56], i_game_board[57], i_game_board[58], i_game_board[0], i_game_board[1], i_game_board[2], i_game_board[8], i_game_board[9], i_game_board[10]};
   //    cell_2_local_game_board = {i_game_board[57], i_game_board[58], i_game_board[59], i_game_board[1], i_game_board[2], i_game_board[3], i_game_board[9], i_game_board[10], i_game_board[11]};
   //    cell_3_local_game_board = {i_game_board[58], i_game_board[59], i_game_board[60], i_game_board[2], i_game_board[3], i_game_board[4], i_game_board[10], i_game_board[11], i_game_board[12]};
   //    cell_4_local_game_board = {i_game_board[59], i_game_board[60], i_game_board[61], i_game_board[3], i_game_board[4], i_game_board[5], i_game_board[11], i_game_board[12], i_game_board[13]};
   //    cell_5_local_game_board = {i_game_board[60], i_game_board[61], i_game_board[62], i_game_board[4], i_game_board[5], i_game_board[6], i_game_board[12], i_game_board[13], i_game_board[14]};
   //    cell_6_local_game_board = {i_game_board[61], i_game_board[62], i_game_board[63], i_game_board[5], i_game_board[6], i_game_board[7], i_game_board[13], i_game_board[14], i_game_board[15]};
   //    cell_7_local_game_board = {i_game_board[62], i_game_board[63], i_game_board[56], i_game_board[6], i_game_board[7], i_game_board[0], i_game_board[14], i_game_board[15], i_game_board[16]};
   //    cell_8_local_game_board = {i_game_board[7], i_game_board[0], i_game_board[1], i_game_board[15], i_game_board[8], i_game_board[9], i_game_board[23], i_game_board[16], i_game_board[17]};
   //    cell_9_local_game_board = {i_game_board[0], i_game_board[1], i_game_board[2], i_game_board[8], i_game_board[9], i_game_board[10], i_game_board[16], i_game_board[17], i_game_board[18]};
   //    cell_10_local_game_board = {i_game_board[1], i_game_board[2], i_game_board[3], i_game_board[9], i_game_board[10], i_game_board[11], i_game_board[17], i_game_board[18], i_game_board[19]};
   //    cell_11_local_game_board = {i_game_board[2], i_game_board[3], i_game_board[4], i_game_board[10], i_game_board[11], i_game_board[12], i_game_board[18], i_game_board[19], i_game_board[20]};
   //    cell_12_local_game_board = {i_game_board[3], i_game_board[4], i_game_board[5], i_game_board[11], i_game_board[12], i_game_board[13], i_game_board[19], i_game_board[20], i_game_board[21]};
   //    cell_13_local_game_board = {i_game_board[4], i_game_board[5], i_game_board[6], i_game_board[12], i_game_board[13], i_game_board[14], i_game_board[20], i_game_board[21], i_game_board[22]};
   //    cell_14_local_game_board = {i_game_board[5], i_game_board[6], i_game_board[7], i_game_board[13], i_game_board[14], i_game_board[15], i_game_board[21], i_game_board[22], i_game_board[23]};
   //    cell_15_local_game_board = {i_game_board[6], i_game_board[7], i_game_board[0], i_game_board[14], i_game_board[15], i_game_board[8], i_game_board[22], i_game_board[23], i_game_board[16]};
   //    cell_16_local_game_board = {i_game_board[15], i_game_board[8], i_game_board[9], i_game_board[23], i_game_board[16], i_game_board[17], i_game_board[31], i_game_board[32], i_game_board[33]};
   //    cell_17_local_game_board = {i_game_board[8], i_game_board[9], i_game_board[10], i_game_board[16], i_game_board[17], i_game_board[18], i_game_board[24], i_game_board[25], i_game_board[26]};
   //    cell_18_local_game_board = {i_game_board[9], i_game_board[10], i_game_board[11], i_game_board[17], i_game_board[18], i_game_board[19], i_game_board[25], i_game_board[26], i_game_board[27]};
   //    cell_19_local_game_board = {i_game_board[10], i_game_board[11], i_game_board[12], i_game_board[18], i_game_board[19], i_game_board[20], i_game_board[26], i_game_board[27], i_game_board[28]};
   //    cell_20_local_game_board = {i_game_board[11], i_game_board[12], i_game_board[13], i_game_board[19], i_game_board[20], i_game_board[21], i_game_board[27], i_game_board[28], i_game_board[29]};
   //    cell_21_local_game_board = {i_game_board[12], i_game_board[13], i_game_board[14], i_game_board[20], i_game_board[21], i_game_board[22], i_game_board[28], i_game_board[29], i_game_board[30]};
   //    cell_22_local_game_board = {i_game_board[13], i_game_board[14], i_game_board[15], i_game_board[21], i_game_board[22], i_game_board[23], i_game_board[29], i_game_board[30], i_game_board[31]};
   //    cell_23_local_game_board = {i_game_board[14], i_game_board[15], i_game_board[8], i_game_board[22], i_game_board[23], i_game_board[16], i_game_board[30], i_game_board[31], i_game_board[24]};
   //    cell_24_local_game_board = {i_game_board[23], i_game_board[16], i_game_board[17], i_game_board[31], i_game_board[24], i_game_board[25], i_game_board[39], i_game_board[32], i_game_board[33]};
   //    cell_25_local_game_board = {i_game_board[16], i_game_board[17], i_game_board[18], i_game_board[24], i_game_board[25], i_game_board[26], i_game_board[32], i_game_board[33], i_game_board[34]};
   //    cell_26_local_game_board = {i_game_board[17], i_game_board[18], i_game_board[19], i_game_board[25], i_game_board[26], i_game_board[27], i_game_board[33], i_game_board[34], i_game_board[35]};
   //    cell_27_local_game_board = {i_game_board[18], i_game_board[19], i_game_board[20], i_game_board[26], i_game_board[27], i_game_board[28], i_game_board[34], i_game_board[35], i_game_board[36]};
   //    cell_28_local_game_board = {i_game_board[19], i_game_board[20], i_game_board[21], i_game_board[27], i_game_board[28], i_game_board[29], i_game_board[35], i_game_board[36], i_game_board[37]};
   //    cell_29_local_game_board = {i_game_board[20], i_game_board[21], i_game_board[22], i_game_board[28], i_game_board[29], i_game_board[30], i_game_board[36], i_game_board[37], i_game_board[38]};
   //    cell_30_local_game_board = {i_game_board[21], i_game_board[22], i_game_board[23], i_game_board[29], i_game_board[30], i_game_board[31], i_game_board[37], i_game_board[38], i_game_board[39]};
   //    cell_31_local_game_board = {i_game_board[22], i_game_board[23], i_game_board[16], i_game_board[30], i_game_board[31], i_game_board[24], i_game_board[38], i_game_board[39], i_game_board[32]};
   //    cell_32_local_game_board = {i_game_board[31], i_game_board[24], i_game_board[25], i_game_board[39], i_game_board[32], i_game_board[33], i_game_board[47], i_game_board[40], i_game_board[41]};
   //    cell_33_local_game_board = {i_game_board[24], i_game_board[25], i_game_board[26], i_game_board[32], i_game_board[33], i_game_board[34], i_game_board[40], i_game_board[41], i_game_board[42]};
   //    cell_34_local_game_board = {i_game_board[25], i_game_board[26], i_game_board[27], i_game_board[33], i_game_board[34], i_game_board[35], i_game_board[41], i_game_board[42], i_game_board[43]};
   //    cell_35_local_game_board = {i_game_board[26], i_game_board[27], i_game_board[28], i_game_board[34], i_game_board[35], i_game_board[36], i_game_board[42], i_game_board[43], i_game_board[44]};
   //    cell_36_local_game_board = {i_game_board[27], i_game_board[28], i_game_board[29], i_game_board[35], i_game_board[36], i_game_board[37], i_game_board[43], i_game_board[44], i_game_board[45]};
   //    cell_37_local_game_board = {i_game_board[28], i_game_board[29], i_game_board[30], i_game_board[36], i_game_board[37], i_game_board[38], i_game_board[44], i_game_board[45], i_game_board[46]};
   //    cell_38_local_game_board = {i_game_board[29], i_game_board[30], i_game_board[31], i_game_board[37], i_game_board[38], i_game_board[39], i_game_board[45], i_game_board[46], i_game_board[47]};
   //    cell_39_local_game_board = {i_game_board[30], i_game_board[31], i_game_board[24], i_game_board[38], i_game_board[39], i_game_board[32], i_game_board[46], i_game_board[47], i_game_board[40]};
   //    cell_40_local_game_board = {i_game_board[39], i_game_board[32], i_game_board[33], i_game_board[47], i_game_board[40], i_game_board[41], i_game_board[55], i_game_board[48], i_game_board[49]};
   //    cell_41_local_game_board = {i_game_board[32], i_game_board[33], i_game_board[34], i_game_board[40], i_game_board[41], i_game_board[42], i_game_board[48], i_game_board[49], i_game_board[50]};
   //    cell_42_local_game_board = {i_game_board[33], i_game_board[34], i_game_board[35], i_game_board[41], i_game_board[42], i_game_board[43], i_game_board[49], i_game_board[50], i_game_board[51]};
   //    cell_43_local_game_board = {i_game_board[34], i_game_board[35], i_game_board[36], i_game_board[42], i_game_board[43], i_game_board[44], i_game_board[50], i_game_board[51], i_game_board[52]};
   //    cell_44_local_game_board = {i_game_board[35], i_game_board[36], i_game_board[37], i_game_board[43], i_game_board[44], i_game_board[45], i_game_board[51], i_game_board[52], i_game_board[53]};
   //    cell_45_local_game_board = {i_game_board[36], i_game_board[37], i_game_board[38], i_game_board[44], i_game_board[45], i_game_board[46], i_game_board[52], i_game_board[53], i_game_board[54]};
   //    cell_46_local_game_board = {i_game_board[37], i_game_board[38], i_game_board[39], i_game_board[45], i_game_board[46], i_game_board[47], i_game_board[53], i_game_board[54], i_game_board[55]};
   //    cell_47_local_game_board = {i_game_board[38], i_game_board[39], i_game_board[32], i_game_board[46], i_game_board[47], i_game_board[40], i_game_board[54], i_game_board[55], i_game_board[48]};
   //    cell_48_local_game_board = {i_game_board[47], i_game_board[40], i_game_board[41], i_game_board[55], i_game_board[48], i_game_board[49], i_game_board[63], i_game_board[56], i_game_board[57]};
   //    cell_49_local_game_board = {i_game_board[40], i_game_board[41], i_game_board[42], i_game_board[48], i_game_board[49], i_game_board[50], i_game_board[56], i_game_board[57], i_game_board[58]};
   //    cell_50_local_game_board = {i_game_board[41], i_game_board[42], i_game_board[43], i_game_board[49], i_game_board[50], i_game_board[51], i_game_board[57], i_game_board[58], i_game_board[59]};
   //    cell_51_local_game_board = {i_game_board[42], i_game_board[43], i_game_board[44], i_game_board[50], i_game_board[51], i_game_board[52], i_game_board[58], i_game_board[59], i_game_board[60]};
   //    cell_52_local_game_board = {i_game_board[43], i_game_board[44], i_game_board[45], i_game_board[51], i_game_board[52], i_game_board[53], i_game_board[59], i_game_board[60], i_game_board[61]};
   //    cell_53_local_game_board = {i_game_board[44], i_game_board[45], i_game_board[46], i_game_board[52], i_game_board[53], i_game_board[54], i_game_board[60], i_game_board[61], i_game_board[62]};
   //    cell_54_local_game_board = {i_game_board[45], i_game_board[46], i_game_board[47], i_game_board[53], i_game_board[54], i_game_board[55], i_game_board[61], i_game_board[62], i_game_board[63]};
   //    cell_55_local_game_board = {i_game_board[46], i_game_board[47], i_game_board[40], i_game_board[54], i_game_board[55], i_game_board[48], i_game_board[62], i_game_board[63], i_game_board[56]};
   //    cell_56_local_game_board = {i_game_board[55], i_game_board[48], i_game_board[49], i_game_board[63], i_game_board[56], i_game_board[57], i_game_board[7], i_game_board[0], i_game_board[1]};
   //    cell_57_local_game_board = {i_game_board[48], i_game_board[49], i_game_board[50], i_game_board[56], i_game_board[57], i_game_board[58], i_game_board[0], i_game_board[1], i_game_board[2]};
   //    cell_58_local_game_board = {i_game_board[49], i_game_board[50], i_game_board[51], i_game_board[57], i_game_board[58], i_game_board[59], i_game_board[1], i_game_board[2], i_game_board[3]};
   //    cell_59_local_game_board = {i_game_board[50], i_game_board[51], i_game_board[52], i_game_board[58], i_game_board[59], i_game_board[60], i_game_board[2], i_game_board[3], i_game_board[4]};
   //    cell_60_local_game_board = {i_game_board[51], i_game_board[52], i_game_board[53], i_game_board[59], i_game_board[60], i_game_board[61], i_game_board[3], i_game_board[4], i_game_board[5]};
   //    cell_61_local_game_board = {i_game_board[52], i_game_board[53], i_game_board[54], i_game_board[60], i_game_board[61], i_game_board[62], i_game_board[4], i_game_board[5], i_game_board[6]};
   //    cell_62_local_game_board = {i_game_board[53], i_game_board[54], i_game_board[55], i_game_board[61], i_game_board[62], i_game_board[63], i_game_board[5], i_game_board[6], i_game_board[7]};
   //    cell_63_local_game_board = {i_game_board[54], i_game_board[55], i_game_board[48], i_game_board[62], i_game_board[63], i_game_board[56], i_game_board[6], i_game_board[7], i_game_board[0]};
   // end

    // Calculate whether center of 3x3 grid would survive/die/spawn
   //  genvar i;
   //  generate;
   //    for (i=0; i<64; ++i) begin
   //       gol_cell u_cell (
   //      .clk                  (clk),
   //      .reset                (reset),
   //      .i_local_game_board   (CELL_LOCAL_GAME_BOARD(i)),
   //      .o_cell               (o_game_board[i])
   //    );
   //    end
   //  endgenerate
 endmodule
 // `end_keywords "1800-2005" // SystemVerilog-2005