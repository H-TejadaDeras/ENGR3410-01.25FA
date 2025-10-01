/*
 *  Smooth RGB LED
 *  Henry Tejada Deras - TBD
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
`begin_keywords "1800-2005" // SystemVerilog-2005
`include pwm.sv

module top(
    input  logic clk,
    output logic RGB_R,
    output logic RGB_G,
    output logic RGB_B
    );
    
    // Variable Declarations
    parameter STATE_PERIOD = 2000000000; // Clock Frequency = 12 MHz; Clock Frequency / 6 = State Period (2 MHz = 1 Period)
    parameter HIGH = 1'b0; // LED On (accounting for active-low setup)
    parameter LOW = 1'b1; // LED Off (accounting for active-low setup)
    parameter NUM_STATES = 6; // Number of States
    logic [$clog2(STATE_PERIOD) - 1:0] counter = 0;
    logic [$clog2(NUM_STATES) - 1:0] state = 0; 
    
    // Initial State Declarations
    initial begin
        RGB_R = HIGH;
        RGB_G = LOW;
        RGB_B = LOW;
    end

    // Update State Counter Logic
    always_ff @(posedge clk) begin
        if (counter == STATE_PERIOD - 1) begin
            if (state >= 5) begin // Reset State Counter
                state <= 0;
            end else begin // Increment State Counter
                state <= state + 1;
            end
            count <= 0;
        end else begin
            count <= count + 1;
        end
    end

    // State Machine Logic
    always_comb @(posedge state) begin
        case (state)
            0:
                RGB_R <= HIGH;
                RGB_G <= LOW; // tmp
                RGB_B <= LOW;
            1:
                RGB_R <= LOW; // tmp
                RGB_G <= HIGH;
                RGB_B <= LOW;
            2:
                RGB_R <= LOW;
                RGB_G <= HIGH;
                RGB_B <= LOW; // tmp
            3:
                RGB_R <= LOW;
                RGB_G <= LOW; // tmp
                RGB_B <= HIGH;
            4:
                RGB_R <= LOW; // tmp
                RGB_G <= LOW;
                RGB_B <= HIGH;
            5:
                RGB_R <= HIGH;
                RGB_G <= LOW;
                RGB_B <= LOW; // tmp
        endcase
    end
endmodule
`end_keywords "1800-2005" // SystemVerilog-2005