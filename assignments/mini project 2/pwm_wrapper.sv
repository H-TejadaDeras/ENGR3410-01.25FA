/*
 *  Wrapper Module for PWM Generator
 *  Henry Tejada Deras - 10-04-2025
 *
 *  Wrapper Module increments or decrements duty cycle from minimum to maximum
 *  within the specified DUTY_CYCLE_FUNC_PERIOD and returns the generated PWM
 *  signal from the PWM generator.
 *
 *  Inputs:
 *  parameter DUTY_CYCLE_FUNC_MODE: 1'b0 -> Decrement Duty Cycle from 100% ->
 *      0%; 1'b1 -> Increment Duty Cycle from 0% -> 100%
 *  parameter DUTY_CYCLE_FUNC_PERIOD: Number of clock cycles in the duty cycle
 *      mode period (e.g. an input of 2000000 means 2,000,000 clock cycles make
 *      up the increment period)
 *  parameter DUTY_CYCLE_FUNC_TICK: Tick Rate in Period (rate at which PWM duty
 *      cycle is changing e.g. every 2000 clk cycles)
 *  logic clk: Global Clock Signal
 * 
 *  Outputs:
 *  o_pwm: Generated PWM Signal
 */
// `begin_keywords "1800-2005" // SystemVerilog-2005
`include "pwm.sv"

module pwm_wrapper #(
    parameter DUTY_CYCLE_FUNC_MODE = 1'b0,
    parameter DUTY_CYCLE_FUNC_PERIOD = 2000000,
    parameter DUTY_CYCLE_FUNC_TICK = 2000
)(
    input logic clk,
    output logic o_pwm
);
    
    // Variable Declarations
    logic [$clog2(DUTY_CYCLE_FUNC_TICK) - 1:0] duty_cycle_func_counter = 0;
    // logic [$clog2(DUTY_CYCLE_FUNC_PERIOD) - 1:0] duty_cycle_period_counter = 0; // Tracks if period has ended
    logic [$clog2(DUTY_CYCLE_FUNC_TICK) - 1:0] duty_cycle_func_value; // Value inputted to pwm generator (value/tick = duty cycle)

    // Initialize DUTY_CYCLE_FUNC Specific Variables
    initial begin
        if (DUTY_CYCLE_FUNC_MODE) begin // Increment Duty Cycle Mode
            duty_cycle_func_value = 0; // Value inputted to pwm generator (value/tick = duty cycle)
        end else begin // Decrement Duty Cycle Mode
            duty_cycle_func_value = DUTY_CYCLE_FUNC_TICK; // Value inputted to pwm generator (value/tick = duty cycle)
        end
    end

    // Generate pwm_value
    always_ff @(posedge clk) begin
        if (DUTY_CYCLE_FUNC_MODE) begin // Increment Duty Cycle Mode
            if (duty_cycle_func_counter >= DUTY_CYCLE_FUNC_TICK - 1) begin // One Tick Completed -> Change Value
                duty_cycle_func_value <= duty_cycle_func_value + 1;
                duty_cycle_func_counter <= 0;
            end else begin // One Tick Not Completed -> Update Counter
                duty_cycle_func_counter <= duty_cycle_func_counter + 1;
            end

            // Reset duty_cycle_func_value; to make sure value does not exceed tick value and result in a duty cycle > 100%
            if (duty_cycle_func_value >= DUTY_CYCLE_FUNC_TICK - 1) begin
                duty_cycle_func_value <= 0;
            end
        end else begin // Decrement Duty Cycle Mode
            if (duty_cycle_func_counter >= DUTY_CYCLE_FUNC_TICK - 1) begin // One Tick Completed -> Change Value
                duty_cycle_func_value <= duty_cycle_func_value - 1;
                duty_cycle_func_counter <= 0;
            end else begin // One Tick Not Completed -> Update Counter
                duty_cycle_func_counter <= duty_cycle_func_counter + 1;
            end

            // Reset duty_cycle_func_value; to make sure value does go below 0 and result in a negative duty cycle > 0%
            if (0 + 1 >= duty_cycle_func_value) begin
                duty_cycle_func_value <= 0;
            end
        end
    end
    
    // Generate Output PWM Signal
    pwm #(
        .PWM_INTERVAL (DUTY_CYCLE_FUNC_TICK)
    ) u2 (
        .clk        (clk),
        .pwm_value  (duty_cycle_func_value),
        .pwm_out    (o_pwm)
    );
endmodule
// `end_keywords "1800-2005" // SystemVerilog-2005