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
 *  
 *  Outputs:
 */ 
// `begin_keywords "1800-2005" // SystemVerilog-2005
`include "cgol_cell.sv"

 module cgol_logic(
    input   logic       clk,
    input   logic       i_data, // from memory controller
    input   logic       i_start, // from top state machine; trigger to start state machine
    output  logic [1:0] memory_operation, // to memory controller
    output  logic [5:0] memory_operation_address, // to memory controller
    output  logic       o_data, // to memory controller
    output  logic       o_done // to top state machine; trigger to start next step
 );
   // Variable Declarations
   localparam HIGH = 1'b1;
   localparam LOW = 1'b0;

   localparam FETCH_DATA = 2'b00;
   localparam PROCESS_DATA = 2'b01;
   localparam SAVE_DATA = 2'b10;
   localparam RESET = 2'b11;

   localparam READ_REG = 2'b00; // Read from read-only register (from memory_controller.sv)
   localparam WRITE_REG = 2'b01; // Write to write-only register (from memory_controller.sv)

   logic [5:0] current_cell = 5'b11111; // Used to keep track of which is the current cell being simulated; initialized as 5'b11111 to prevent initialization reset from immediately starting fetch sequence
   logic [8:0] local_game_board = 0;
   logic [2:0] column_index = 3'b0;
   logic [2:0] row_index = 3'b0;
   logic [1:0] state = RESET; // to start initially in a fresh, reset state

   logic [3:0] fetch_data_counter = 0; // Counter used to keep track of which data has been fetched

   // Net Declarations
   logic [5:0] fetch_operation_memory_operation_address; // Used to control which address gets sent to memory controller
   logic [8:0] cgol_cell_i_local_game_board;
   logic cgol_cell_o_cell;

   // Main State Machine + Memory Controller Interface
   always_comb begin
      case (state)
         FETCH_DATA: begin
            memory_operation = READ_REG;
            memory_operation_address = fetch_operation_memory_operation_address;
            if (fetch_data_counter >= 4'b1000) begin // Got last local game board cell entry
               fetch_data_counter = 0;
               state = PROCESS_DATA;
            end
         end

         PROCESS_DATA: begin
            cgol_cell_i_local_game_board = local_game_board;
            state = SAVE_DATA;
         end

         SAVE_DATA: begin
            memory_operation = WRITE_REG;
            memory_operation_address = current_cell;
            o_data = cgol_cell_o_cell;
            state = RESET;
         end

         RESET: begin
            cgol_cell_i_local_game_board = 0;
            if (current_cell == 5'b11111) begin // last cell
               current_cell = 0;
               if (i_start == LOW) begin
                  o_done = HIGH; // Send done signal
               end
            end else begin
               current_cell = current_cell + 1;
               state = FETCH_DATA;
            end
         end
      endcase
   end

   // Determine Current Cell Row and Column Value for Creating Local Game Board
   assign row_index = current_cell[5:3];
   assign column_index = current_cell[2:0];

   // External Start Trigger Logic
   always_comb begin
      if (i_start == HIGH) begin
         state = FETCH_DATA;
         o_done = LOW;
      end
   end

   // Create Local Game Board
   always_comb begin
      case (fetch_data_counter)
         default: begin
         end
         4'b0000: begin // Local Board Cell 0
            fetch_operation_memory_operation_address = {row_index - 1, column_index - 1};
            local_game_board[0] = i_data;
         end

         4'b0001: begin // Local Board Cell 1
            fetch_operation_memory_operation_address = {row_index - 1, column_index};
            local_game_board[1] = i_data;
         end

         4'b0010: begin // Local Board Cell 2
            fetch_operation_memory_operation_address = {row_index - 1, column_index + 1};
            local_game_board[2] = i_data;
         end

         4'b0011: begin // Local Board Cell 3
            fetch_operation_memory_operation_address = {row_index, column_index - 1};
            local_game_board[3] = i_data;
         end

         4'b0100: begin // Local Board Cell 4
            fetch_operation_memory_operation_address = {row_index, column_index};
            local_game_board[4] = i_data;
         end

         4'b0101: begin // Local Board Cell 5
            fetch_operation_memory_operation_address = {row_index, column_index + 1};
            local_game_board[5] = i_data;
         end

         4'b0110: begin // Local Board Cell 6
            fetch_operation_memory_operation_address = {row_index + 1, column_index - 1};
            local_game_board[6] = i_data;
         end

         4'b0111: begin // Local Board Cell 7
            fetch_operation_memory_operation_address = {row_index + 1, column_index};
            local_game_board[7] = i_data;
         end

         4'b1000: begin // Local Board Cell 8
            fetch_operation_memory_operation_address = {row_index + 1, column_index + 1};
            local_game_board[8] = i_data;
         end
      endcase
   end

   // Fetch Local Game Board Data Counter; Counter Reset by Main State Machine
   always_ff @(posedge clk) begin
      if (state == FETCH_DATA) begin
         fetch_data_counter = fetch_data_counter + 1;
      end
   end

   // Calculate Cell Value at Next Stage
   cgol_cell u2 (
      .clk                 (clk),
      .i_local_game_board  (cgol_cell_i_local_game_board[8:0]),
      .o_cell              (cgol_cell_o_cell)
   );
 endmodule
 // `end_keywords "1800-2005" // SystemVerilog-2005