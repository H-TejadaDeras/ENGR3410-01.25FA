/*  RGB LED - Mini Project 1
 *  Henry Tejada Deras - 09-12-2025
 */ 

module top(
    input logic clk, 
    output logic RBG_R,
    output logic RBG_G,
    output logic RBG_B
    );

    // Variable Declarations
    parameter BLINK_INTERVAL = 2000000; // CLK frequency is 12 MHz, so 2,000,000 cycles is 1/6 s
    logic [$clog2(BLINK_INTERVAL) - 1:0] count = 0;

    // Initial State Declarations
    initial begin
        RBG_R = 1'b1;
        RBG_G = 1'b0;
        RBG_B = 1'b0;
    end

    // Counter Logic
    always_ff @(posedge clk) begin
        if (count == BLINK_INTERVAL - 1) begin
            count <= 0;
            LED <= ~LED; // TODO: Trigger change in state
        end
        else begin
            count <= count + 1;
        end
    end

endmodule

module state_machine(
    input logic state,
    output logic RBG_R,
    output logic RBG_G,
    output logic RBG_B
)
