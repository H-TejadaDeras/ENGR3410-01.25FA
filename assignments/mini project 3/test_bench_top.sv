/*
 *  Conway's Game of Life Game Instance on WS2812B LED Matrix Test Bench
 *  Henry Tejada Deras - 10-26-2025
 */
// `begin_keywords "1800-2005" // SystemVerilog-2005
`timescale 10ns/10ns
`include "top.sv"

module test_bench_top;
    logic clk = 0;
    logic SW;
    logic led_matrix_input;

    top u0 (
        .clk    (clk), 
        .SW     (SW),
        ._31b   (led_matrix_input)
    );

    initial begin
        $dumpfile("cgol.vcd");
        $dumpvars(0, u0);
        #60000000
        $finish;
    end

    always begin
        #2
        clk = ~clk;
    end
endmodule