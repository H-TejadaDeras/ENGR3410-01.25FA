/*  Simple RGB LED - Mini Project 1
 *  Henry Tejada Deras - 09-12-2025
 */ 
// `include "led_controller.sv"

module top(
    input logic clk, 
    output logic RGB_R,
    output logic RGB_G,
    output logic RGB_B
    );

    // Variable Declarations
    parameter BLINK_INTERVAL = 2000000; // CLK frequency is 12 MHz, so 2,000,000 cycles is 1/6 s
    logic [$clog2(BLINK_INTERVAL) - 1:0] count = 0;
    logic red_led, green_led, blue_led;

    // Initial State Declarations
    initial begin
        RBG_R = 1'b0;
        RGB_G = 1'b1;
        RGB_B = 1'b1;
    end

    // assign RGB_R = ~red_led;
    // assign RGB_G = ~green_led;
    // assign RGB_B = ~blue_led;

    // led_controller U1(
    // .i_RGB_R(~RGB_R), 
    // .i_RGB_G(~RGB_G), 
    // .i_RGB_B(~RGB_B),
    // .o_RBG_R(red_led), 
    // .o_RBG_G(green_led),
    // .o_RBG_B(blue_led)
    // );

    // Counter Logic
    always_ff @(posedge clk) begin
        if (count == BLINK_INTERVAL - 1) begin
            count <= 0;

            if (RGB_R == 1'b0 && RGB_G == 1'b1 && RGB_B == 1'b1) begin // Red -> Yellow
            RGB_R <= 1'b0;
            RGB_G <= 1'b0;
            RGB_B <= 1'b1;
            end
            else if (RGB_R == 1'b0 && RGB_G == 1'b0 && RGB_B == 1'b1) begin // Yellow -> Green
                RGB_R <= 1'b1;
                RGB_G <= 1'b0;
                RGB_B <= 1'b1;
            end
            else if (RGB_R == 1'b1 && RGB_G == 1'b0 && RGB_B == 1'b1) begin // Green -> Cyan
                RGB_R <= 1'b1;
                RGB_G <= 1'b0;
                RGB_B <= 1'b0;
            end
            else if (RGB_R == 1'b1 && RGB_G == 1'b0 && RGB_B == 1'b0) begin // Cyan -> Blue
                RGB_R <= 1'b1;
                RGB_G <= 1'b1;
                RGB_B <= 1'b0;
            end
            else if (RGB_R == 1'b1 && RGB_G == 1'b1 && RGB_B == 1'b0) begin // Blue -> Magenta
                RGB_R <= 1'b0;
                RGB_G <= 1'b1;
                RGB_B <= 1'b0;
            end
            else if (RGB_R == 1'b0 && RGB_G == 1'b1 && RGB_B == 1'b0) begin // Magenta -> Red
                RGB_R <= 1'b0;
                RGB_G <= 1'b1;
                RGB_B <= 1'b1;
            end

        end
        else begin
            count <= count + 1;
        end
    end
endmodule