/*
 *  Smooth RGB LED Test Bench
 *  Henry Tejada Deras - 10-02-2025
 */
// `begin_keywords "1800-2005" // SystemVerilog-2005
`timescale 10ns/10ns
`include "top.sv"

module test_bench_top;
    logic clk = 0;
    logic o_RGB_R;
    logic o_RGB_G;
    logic o_RGB_B;

    top u0 (
        .clk    (clk), 
        .RGB_R  (o_RGB_R),
        .RGB_G  (o_RGB_G),
        .RGB_B  (o_RGB_B)
    );

    initial begin
        $dumpfile("smooth_rgb_led.vcd");
        $dumpvars(0, u0);
        #60000000
        $finish;
    end

    always begin
        #2
        clk = ~clk;
    end
endmodule