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
    output logic o_done,
    output logic o_memory_operation,
    output logic o_memory_operation_address,
    output logic o_led_matrix
);
    // Variable Declarations
    logic [23:0] shift_reg = 23'b0;

    // Net Declarations
    // Module Declarations
    ws2812b u7 (
        .clk            (clk),
        .serial_in      (),
        .transmit       (),
        .ws2812b_out    (o_led_matrix),
        .shift          ()
    );

    // State Machine
    // always_ff @(posedge clk) begin
    //     case()
    
    // Memory Address
    // Add Color Data
    // LED Matrix Output Shift Register

    // 
endmodule
// `end_keywords "1800-2005" // SystemVerilog-2005