/*
 *  Conway's Game of Life Game Instance on WS2812B LED Matrix Test Bench
 *  Henry Tejada Deras - 10-26-2025
 */
// `begin_keywords "1800-2005" // SystemVerilog-2005
`timescale 10ns/10ns
`include "top.sv"

module test_bench_top;
    logic clk = 0;
    logic led_matrix_input;

    top u0 (
        .clk    (clk), 
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

    // Display Game State
    always @(posedge clk) begin
        if (u0.cgol1_o_done) begin
            for (int i = 0; i < 64; i = i + 8) begin
                for (int j = 0; j < 8; j = j + 1) begin
                    $write("%b", u0.u2.write_register[i + j]);
                end
            $display("");
            end
        end
        $display("%s", ----------);
    end
endmodule
// `end_keywords "1800-2005" // SystemVerilog-2005