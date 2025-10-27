/*  
 *  Output Controller
 *  Henry Tejada Deras - 10-26-2025
 *  
 *  Adds Color Data and Controls LED Matrix Driver.
 *  
 *  Inputs:
 *  logic clk: Clock signal
 *  logic i_data_in_1: Data from first memory controller.
 *  logic i_data_in_2: Data from second memory controller.
 *  logic i_data_in_3: Data from third memory controller.
 *  logic i_start: Start signal from state machine in top.sv.
 *  
 *  Outputs:
 *  logic o_done: Done signal for state machine in top.sv, used to trigger next
 *      state.
 *  logic o_memory_operation: Memory operation command for memory_controller
 *      module.
 *  logic o_memory_operation_address: Memory operation address for
 *      memory_controller.
 *  logic o_led_matrix: Output to WS2812B LED Matrix
 */ 
// `begin_keywords "1800-2005" // SystemVerilog-2005
`include "ws2812b.sv"

module output_controller(
    input logic clk,
    input logic i_data_in_1,
    input logic i_data_in_2,
    input logic i_data_in_3,
    input logic i_start,
    output logic o_done,
    output logic o_memory_operation,
    output logic o_memory_operation_address,
    output logic o_led_matrix
);
    // Variable Declarations
    localparam HIGH = 1'b1;
    localparam LOW = 1'b0;

    localparam GET_CELL_STATE = 2'b00;
    localparam ADD_COLOR_INFO = 2'b01;
    localparam OUTPUT_DATA = 2'b10;
    localparam IDLE = 2'b11;

    localparam READ_REG = 2'b00; // From memory_controller.sv
    localparam IDLE_MEMORY = 2'b10; // From memory_controller.sv

    localparam IDLE_DRIVER = 1'b0; // From ws2812b.sv
    localparam TRANSMITTING = 1'b1; // From ws2812b.sv

    logic [23:0] shift_reg = 23'b0;
    logic [4:0] shift_reg_counter = 0;
    logic [5:0] current_cell = 0;
    logic [1:0] state_output = IDLE;

    // Net Declarations
    logic transmit_command;
    logic shift_reg_command;
    logic o_done_trigger;
    logic o_done_trigger_save;

    // Module Declarations
    ws2812b u8 (
        .clk            (clk),
        .serial_in      (shift_reg[23]),
        .transmit       (transmit_command),
        .ws2812b_out    (o_led_matrix),
        .shift          (shift_reg_command)
    );

    // Module State Machine
    always_ff @(posedge clk) begin
        case(state_output)
            GET_CELL_STATE: begin
                current_cell <= current_cell + 1;
                o_memory_operation <= READ_REG;
                transmit_command <= IDLE_DRIVER;
                state_output <= ADD_COLOR_INFO;
            end

            ADD_COLOR_INFO: begin
                if (i_data_in_1 == HIGH) begin // Red Color
                    shift_reg[15:8] <= 8'b1;
                end else begin
                    shift_reg[15:8] <= 8'b0;
                end

                if (i_data_in_2 == HIGH) begin // Green Color
                    shift_reg[23:16] <= 8'b1;
                end else begin
                    shift_reg[23:16] <= 8'b0;
                end

                if (i_data_in_3 == HIGH) begin // Blue Color
                    shift_reg[7:0] <= 8'b1;
                end else begin
                    shift_reg[7:0] <= 8'b0;
                end

                o_memory_operation <= IDLE_MEMORY;
                transmit_command <= IDLE_DRIVER;
                state_output <= OUTPUT_DATA;
            end

            OUTPUT_DATA: begin
                o_memory_operation <= IDLE_MEMORY;
                transmit_command <= TRANSMITTING;
            end

            IDLE: begin
                o_memory_operation <= IDLE_MEMORY;
                transmit_command <= IDLE_DRIVER;
            end
        endcase
    end

    assign o_memory_operation_address = current_cell;

    // LED Matrix Output Shift Register
    always_ff @(posedge clk) begin
        if (shift_reg_command == HIGH) begin
            shift_reg <= { shift_reg[22:0], 1'b0 };
            shift_reg_counter <= shift_reg_counter + 1;
        end
    end

   // External Start Trigger Logic
   always_ff @(posedge clk) begin
      if (i_start == HIGH) begin
         state_output <= GET_CELL_STATE;
         o_done_trigger <= LOW;
      end
   end

    // Update Current Cell and State Machine State
    always_ff @(posedge clk) begin
        if (shift_reg_counter >= 5'd23) begin
            shift_reg_counter <= 0;
            if (current_cell == 6'b111111) begin
                state_output <= IDLE;
                o_done_trigger <= HIGH;
            end else begin
                state_output <= GET_CELL_STATE;
            end
        end
    end

    // Done Signal Logic
    always_ff @(posedge clk) begin
        if (o_done_trigger == HIGH && o_done_trigger_save == LOW) begin
            o_done <= HIGH;
            o_done_trigger_save <= HIGH;
        end else if (o_done_trigger == HIGH && o_done_trigger_save == HIGH) begin // makes done signal 1 clk period long
            o_done <= LOW;
        end else if (o_done_trigger == LOW) begin // dpne trigger low -> save low, done should already be low
            o_done <= LOW;
            o_done_trigger_save <= LOW;
        end
    end
endmodule
// `end_keywords "1800-2005" // SystemVerilog-2005