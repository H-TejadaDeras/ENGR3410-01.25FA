/*
 *  Smooth RGB LED
 *  Henry Tejada Deras - 10-04-2025
 *  
 *  Drives RGB LED smoothly through HSV Color Wheel in 1 s
 * 
 *  States:
 *  0 = Red -> Yellow   | 0 -> 60 |     (R: -; G: /; B: _)
 *  1 = Yellow -> Green | 60 -> 120 |   (R: \; G: -; B: _)
 *  2 = Green -> Cyan   | 120 -> 180 |  (R: _; G: -; B: /)
 *  3 = Cyan -> Blue    | 180 -> 240 |  (R: _; G: \; B: -)
 *  4 = Blue -> Magenta | 240 -> 300 |  (R: /; G: _; B: -)
 *  5 = Magenta -> Red  | 300 -> 360 |  (R: -; G: _; B: \)
 */
// `begin_keywords "1800-2005" // SystemVerilog-2005
`include "pwm.sv"
`include "pwm_wrapper.sv"

module top(
    input  logic clk,
    output logic RGB_R,
    output logic RGB_G,
    output logic RGB_B
    );
    
    // Variable Declarations
    parameter STATE_PERIOD = 2000000; // Clock Frequency = 12 MHz; Clock Frequency / 6 = State Period (2 MHz = 1 Period)
    parameter HIGH = 1'b1; // Digital Logical Low Signal
    parameter LOW = 1'b0; // Digital Logical Low Signal
    parameter LED_ON = 1'b0; // LED On (accounting for active-low setup)
    parameter LED_OFF = 1'b1; // LED Off (accounting for active-low setup)
    parameter NUM_STATES = 6; // Number of States
    parameter INCREMENT_DUTY_CYCLE_MODE = 1'b1; // Used for PWM Wrapper Module (Increment Duty Cycle from 0% -> 100%)
    parameter DECREMENT_DUTY_CYCLE_MODE = 1'b0; // Used for PWM Wrapper Module (Decrement Duty Cycle from 100% -> 0%)
    logic [$clog2(STATE_PERIOD) - 1:0] counter = 0;
    logic [$clog2(NUM_STATES) - 1:0] state = 0; 
    logic [$clog2(3) - 1:0] pwm_led = X; // 0 - Red, 1 - Green, 2 - Blue
    logic pwm_mode = X;
    logic pwm_output = X;

    // Net Declarations
    logic state_updater = 0; // Intermediate signal to trigger changes in state (triggers one every 1/6 s)
    // logic pwm_trigger = 0; // Intermediate signal to trigger PWM Module
    
    // Initial State Declarations
    initial begin
        RGB_R = LED_ON;
        RGB_G = LED_OFF;
        RGB_B = LED_OFF;
    end

    // Update State Counter Logic
    always_ff @(posedge clk) begin
        if (counter == STATE_PERIOD - 1) begin
            state_updater <= LED_ON;
            counter <= 0;
        end else begin
            state_updater <= LED_OFF;
            counter <= counter + 1;
        end
    end

    // Update State Logic
    always_ff @(posedge state_updater) begin
        if (state >= 5) begin // Reset State Counter
            state <= 0;
        end else begin // Increment State Counter
            state <= state + 1;
        end
    end

    // State Machine Logic
    always_comb begin
        case (state)
            default: begin
                RGB_R = LED_OFF;
                RGB_G = LED_OFF;
                RGB_B = LED_OFF;
            end
            0: begin
                RGB_R = LED_ON;
                // RGB_G = LED_OFF; // tmp
                RGB_B = LED_OFF;
                pwm_trigger = HIGH;
                pwm_led = 1; // Green
                pwm_mode = INCREMENT_DUTY_CYCLE_MODE;
                RGB_G = pwm_output;
            end
            1: begin
                RGB_R = LED_OFF; // tmp
                RGB_G = LED_ON;
                RGB_B = LED_OFF;
            end
            2: begin
                RGB_R = LED_OFF;
                RGB_G = LED_ON;
                RGB_B = LED_OFF; // tmp
            end
            3: begin
                RGB_R = LED_OFF;
                RGB_G = LED_OFF; // tmp
                RGB_B = LED_ON;
            end
            4: begin
                RGB_R = LED_OFF; // tmp
                RGB_G = LED_OFF;
                RGB_B = LED_ON;
            end
            5: begin
                RGB_R = LED_ON;
                RGB_G = LED_OFF;
                RGB_B = LED_OFF; // tmp
            end
        endcase
    end

    // PWM Module
    always_ff @(posedge state) begin
        pwm_wrapper #(
            .DUTY_CYCLE_FUNC_MODE   (pwm_mode),
            .DUTY_CYCLE_FUNC_PERIOD (STATE_PERIOD),
            .DUTY_CYCLE_FUNC_TICK   (2000)
        ) U_PWM (
            .clk    (clk),
            .o_pwm  (pwm_output)
        );
    end
endmodule
// `end_keywords "1800-2005" // SystemVerilog-2005