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
 *  logic i_data: Data input from memory controller.
 *  logic i_state_top: Current state of top state machine.
 *  
 *  Outputs:
 *  logic [1:0] memory_operation: Memory operation output for memory
 *      controller.
 *  logic [5:0] memory_operation_address: Address to which to do memory
 *      operation.
 *  logic o_data: Data output to memory controller.
 *  logic o_done: Done trigger for top state machine.
 */ 
// `begin_keywords "1800-2005" // SystemVerilog-2005
`include "cgol_cell.sv"

// Macros Used to Determine Current Cell Row and Column Value for Creating Local Game Board
`define ROW_INDEX current_cell[5:3]
`define COLUMN_INDEX current_cell[2:0]

module cgol_logic(
    input   logic       clk,
    input   logic       i_data,
    input   logic [1:0] i_state_top,
    output  logic [1:0] memory_operation,
    output  logic [5:0] memory_operation_address,
    output  logic       o_data,
    output  logic       o_done
 );
   // Variable Declarations
   localparam HIGH = 1'b1;
   localparam LOW = 1'b0;

   localparam FETCH_DATA = 2'b00;
   localparam PROCESS_DATA = 2'b01;
   localparam SAVE_DATA = 2'b10;
   localparam RESET = 2'b11;

   localparam PROCESS_GAME_STATE = 2'b00; // cgol_logic module active (from top.sv)
   localparam CYCLE_REGISTERS = 2'b01; // cgol_logic module inactive (from top.sv)
   localparam PROCESS_OUTPUT = 2'b10; // cgol_logic module inactive (from top.sv)
   localparam PAUSE = 2'b11; // cgol_logic module inactive (from top.sv)

   localparam READ_REG = 2'b00; // Read from read-only register (from memory_controller.sv)
   localparam WRITE_REG = 2'b01; // Write to write-only register (from memory_controller.sv)
   localparam IDLE = 2'b10; // Do no operation (from memory_controller.sv)

   localparam READ_ENTRY_CLK_CYCLES = 4;
   localparam PROCESS_DATA_CLK_CYCLES = 4;
   localparam WRITE_ENTRY_CLK_CYCLES = 4;

   logic [5:0] current_cell = 6'b111111; // Used to keep track of which is the current cell being simulated; initialized as 5'b11111 to prevent initialization reset from immediately starting fetch sequence
   logic [8:0] local_game_board = 0;
   logic [1:0] state = RESET; // to start initially in a fresh, reset state

   logic [3:0] fetch_data_counter = 0; // Counter used to keep track of which data has been fetched
   logic [$clog2(READ_ENTRY_CLK_CYCLES):0] read_entry_counter = 0;
   logic [$clog2(PROCESS_DATA_CLK_CYCLES):0] process_data_counter = 0;
   logic [$clog2(WRITE_ENTRY_CLK_CYCLES):0] write_entry_counter = 0;

   // Net Declarations
   logic [5:0] fetch_operation_memory_operation_address; // Used to control which address gets sent to memory controller
   logic [8:0] cgol_cell_i_local_game_board;
   logic cgol_cell_o_cell;

   logic o_done_trigger = LOW;
   logic o_done_trigger_save = LOW;

   // Memory Controller Interface
   always_comb begin
      case (state)
         FETCH_DATA: begin
            memory_operation = READ_REG;
            memory_operation_address = fetch_operation_memory_operation_address;
            o_data = 1'bx;
            cgol_cell_i_local_game_board = 0;
         end

         PROCESS_DATA: begin
            memory_operation = IDLE;
            memory_operation_address = 0;
            o_data = 1'bx;
            cgol_cell_i_local_game_board = local_game_board;
         end

         SAVE_DATA: begin
            memory_operation = WRITE_REG;
            memory_operation_address = current_cell;
            o_data = cgol_cell_o_cell;
            cgol_cell_i_local_game_board = local_game_board;
         end

         RESET: begin
            memory_operation = IDLE;
            memory_operation_address = 0;
            o_data = 1'bx;
            cgol_cell_i_local_game_board = 0;
         end
      endcase
   end

   always_ff @(posedge clk) begin
      // Main State Machine
      case (state)
         FETCH_DATA: begin
            if (read_entry_counter >= READ_ENTRY_CLK_CYCLES) begin
               fetch_data_counter <= fetch_data_counter + 1;
               read_entry_counter <= 0;
                  if (fetch_data_counter >= 4'b1000) begin // Got last local game board cell entry
                     fetch_data_counter <= 0;
                     state <= PROCESS_DATA;
                  end
            end else begin
               read_entry_counter <= read_entry_counter + 1;
            end
         end

         PROCESS_DATA: begin
            if (process_data_counter >= PROCESS_DATA_CLK_CYCLES) begin
               process_data_counter <= 0;
               state <= SAVE_DATA;
            end else begin
               process_data_counter <= process_data_counter + 1;
            end
         end

         SAVE_DATA: begin
            if (write_entry_counter >= WRITE_ENTRY_CLK_CYCLES) begin
               write_entry_counter <= 0;
               state <= RESET;
            end else begin
               write_entry_counter <= write_entry_counter + 1;
            end
         end

         RESET: begin
            if (current_cell == 6'b111111) begin // last cell
               current_cell <= 0;
               if (i_state_top == PROCESS_GAME_STATE) begin
                  o_done_trigger <= HIGH; // Send done signal
               end
               state <= RESET;
            end else begin
               // Start Logic
               if (i_state_top == PROCESS_GAME_STATE) begin
                  current_cell <= current_cell + 1;
                  o_done_trigger <= LOW;
                  state <= FETCH_DATA;
               end
            end
         end
      endcase

      // Done Signal Logic
      if (o_done_trigger == HIGH && o_done_trigger_save == LOW) begin
         o_done <= HIGH;
         o_done_trigger_save <= HIGH;
      end else if (o_done_trigger == HIGH && o_done_trigger_save == HIGH) begin // makes done signal 1 clk period long
         o_done <= LOW;
      end else if (o_done_trigger == LOW) begin // done trigger low -> save low, done should already be low
         o_done <= LOW;
         o_done_trigger_save <= LOW;
      end

      // Create Local Game Board
      case (fetch_data_counter)
         default: begin
            fetch_operation_memory_operation_address <= 6'b000000;
            local_game_board <= 9'b000000000;
         end

         4'b0000: begin // Local Board Cell 0
            fetch_operation_memory_operation_address <= {`ROW_INDEX - 3'd1, `COLUMN_INDEX - 3'd1};
            local_game_board[0] <= i_data;
         end

         4'b0001: begin // Local Board Cell 1
            fetch_operation_memory_operation_address <= {`ROW_INDEX - 3'd1, `COLUMN_INDEX};
            local_game_board[1] <= i_data;
         end

         4'b0010: begin // Local Board Cell 2
            fetch_operation_memory_operation_address <= {`ROW_INDEX - 3'd1, `COLUMN_INDEX + 3'd1};
            local_game_board[2] <= i_data;
         end

         4'b0011: begin // Local Board Cell 3
            fetch_operation_memory_operation_address <= {`ROW_INDEX, `COLUMN_INDEX - 3'd1};
            local_game_board[3] <= i_data;
         end

         4'b0100: begin // Local Board Cell 4
            fetch_operation_memory_operation_address <= {`ROW_INDEX, `COLUMN_INDEX};
            local_game_board[4] <= i_data;
         end

         4'b0101: begin // Local Board Cell 5
            fetch_operation_memory_operation_address <= {`ROW_INDEX, `COLUMN_INDEX + 3'd1};
            local_game_board[5] <= i_data;
         end

         4'b0110: begin // Local Board Cell 6
            fetch_operation_memory_operation_address <= {`ROW_INDEX + 3'd1, `COLUMN_INDEX - 3'd1};
            local_game_board[6] <= i_data;
         end

         4'b0111: begin // Local Board Cell 7
            fetch_operation_memory_operation_address <= {`ROW_INDEX + 3'd1, `COLUMN_INDEX};
            local_game_board[7] <= i_data;
         end

         4'b1000: begin // Local Board Cell 8
            fetch_operation_memory_operation_address <= {`ROW_INDEX + 3'd1, `COLUMN_INDEX + 3'd1};
            local_game_board[8] <= i_data;
         end
      endcase
   end

   // Calculate Cell Value at Next Stage
   cgol_cell u2 (
      .clk                 (clk),
      .i_local_game_board  (cgol_cell_i_local_game_board[8:0]),
      .o_cell              (cgol_cell_o_cell)
   );
 endmodule
 // `end_keywords "1800-2005" // SystemVerilog-2005