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
 *  logic [1:0] o_memory_operation: Memory operation command for
 *      memory_controller module.
 *  logic [5:0] o_memory_operation_address: Memory operation address for
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
    output logic [1:0] o_memory_operation,
    output logic [5:0] o_memory_operation_address,
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

    localparam GET_CELL_STATE_CLK_CYCLES = 4;
    localparam LAST_TRANSMIT_BIT_CLK_CYCLES = 7;

    logic [23:0] shift_reg = 23'b0;
    logic [4:0] shift_reg_counter = 0;
    logic [5:0] current_cell = 0;
    logic [1:0] state_output = IDLE;
    logic [$clog2(GET_CELL_STATE_CLK_CYCLES):0] get_cell_state_counter = 0;
    logic [$clog2(LAST_TRANSMIT_BIT_CLK_CYCLES):0] last_transmit_bit_counter = 0; // Used to delay next transmit to allow proper transmit of last cell

    // Net Declarations
    logic transmit_command;
    logic shift_reg_command;
    logic o_done_trigger;
    logic o_done_trigger_save;
    logic last_transmit_bit_trigger;

    // Module Declarations
    ws2812b u8 (
        .clk            (clk),
        .serial_in      (shift_reg[23]),
        .transmit       (transmit_command),
        .ws2812b_out    (o_led_matrix),
        .shift          (shift_reg_command)
    );

    always_ff @(posedge clk) begin
        // Module State Machine
        case(state_output)
            GET_CELL_STATE: begin
                current_cell <= current_cell + 1;
                o_memory_operation <= READ_REG;
                transmit_command <= IDLE_DRIVER;
                if (get_cell_state_counter >= GET_CELL_STATE_CLK_CYCLES) begin
                    state_output <= ADD_COLOR_INFO;
                end else begin
                    get_cell_state_counter <= get_cell_state_counter + 1;
                end
            end

            ADD_COLOR_INFO: begin
                if (i_data_in_1 == HIGH) begin // Red Color
                    shift_reg[15:8] <= 8'b11111111;
                end else begin
                    shift_reg[15:8] <= 8'b00000000;
                end

                if (i_data_in_2 == HIGH) begin // Green Color
                    shift_reg[23:16] <= 8'b11111111;
                end else begin
                    shift_reg[23:16] <= 8'b00000000;
                end

                if (i_data_in_3 == HIGH) begin // Blue Color
                    shift_reg[7:0] <= 8'b11111111;
                end else begin
                    shift_reg[7:0] <= 8'b00000000;
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

        // LED Matrix Output Shift Register
        if (state_output == OUTPUT_DATA) begin
            if (shift_reg_command == HIGH) begin
                shift_reg <= { shift_reg[22:0], 1'b0 };
                shift_reg_counter <= shift_reg_counter + 1;
            end
        end

       // External Start Trigger Logic
        if (i_start == HIGH) begin
            state_output <= GET_CELL_STATE;
            o_done_trigger <= LOW;
        end

        // Update Current Cell and State Machine State
        if (shift_reg_counter >= 5'd23) begin
            last_transmit_bit_trigger <= HIGH;
            shift_reg_counter <= 0;
        end

        if (last_transmit_bit_trigger && last_transmit_bit_counter <= LAST_TRANSMIT_BIT_CLK_CYCLES) begin
            last_transmit_bit_counter <= last_transmit_bit_counter + 1;
        end else if (last_transmit_bit_trigger && last_transmit_bit_counter >= LAST_TRANSMIT_BIT_CLK_CYCLES && current_cell == 6'b111111) begin
                state_output <= IDLE;
                o_done_trigger <= HIGH;
                last_transmit_bit_counter <= 0;
                last_transmit_bit_trigger <= LOW;
        end else if (last_transmit_bit_trigger && last_transmit_bit_counter >= LAST_TRANSMIT_BIT_CLK_CYCLES && current_cell != 6'b111111) begin
                state_output <= GET_CELL_STATE;
                last_transmit_bit_counter <= 0;
                last_transmit_bit_trigger <= LOW;
        end

        // Done Signal Logic
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

    assign o_memory_operation_address = current_cell;
endmodule
// `end_keywords "1800-2005" // SystemVerilog-2005