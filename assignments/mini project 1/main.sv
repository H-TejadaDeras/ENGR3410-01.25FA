/*  Simple RGB LED - Mini Project 1
 *  Henry Tejada Deras - 09-12-2025
 */ 

module top(
    input logic clk, 
    output logic RGB_R,
    output logic RGB_G,
    output logic RGB_B
    );

    // Variable Declarations
    parameter BLINK_INTERVAL = 2000000; // CLK frequency is 12 MHz, so 2,000,000 cycles is 1/6 s
    logic [$clog2(BLINK_INTERVAL) - 1:0] count = 0;
    parameter HIGH = 1'b0; // LED On (accounting for active-low setup)
    parameter LOW = 1'b1; // LED Off (accounting for active-low setup)

    // Initial State Declarations
    initial begin
        RGB_R = HIGH;
        RGB_G = LOW;
        RGB_B = LOW;
    end

    // Counter Logic
    always_ff @(posedge clk) begin
        if (count == BLINK_INTERVAL - 1) begin
            count <= 0;

            // LED Control Logic
            if (RGB_R == HIGH && RGB_G == LOW && RGB_B == LOW) begin // Red -> Yellow
                RGB_R <= HIGH;
                RGB_G <= HIGH;
                RGB_B <= LOW;
            end
            else if (RGB_R == HIGH && RGB_G == HIGH && RGB_B == LOW) begin // Yellow -> Green
                RGB_R <= LOW;
                RGB_G <= HIGH;
                RGB_B <= LOW;
            end
            else if (RGB_R == LOW && RGB_G == HIGH && RGB_B == LOW) begin // Green -> Cyan
                RGB_R <= LOW;
                RGB_G <= HIGH;
                RGB_B <= HIGH;
            end
            else if (RGB_R == LOW && RGB_G == HIGH && RGB_B == HIGH) begin // Cyan -> Blue
                RGB_R <= LOW;
                RGB_G <= LOW;
                RGB_B <= HIGH;
            end
            else if (RGB_R == LOW && RGB_G == LOW && RGB_B == HIGH) begin // Blue -> Magenta
                RGB_R <= HIGH;
                RGB_G <= LOW;
                RGB_B <= HIGH;
            end
            else if (RGB_R == HIGH && RGB_G == LOW && RGB_B == HIGH) begin // Magenta -> Red
                RGB_R <= HIGH;
                RGB_G <= LOW;
                RGB_B <= LOW;
            end
        end
        else begin
            count <= count + 1;
        end
    end
endmodule