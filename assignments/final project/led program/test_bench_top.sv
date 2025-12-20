/*
 *  RISC-V RV32I Processor Test Bench
 *  Henry Tejada Deras - 11-05-2025
 */
`timescale 10ns/10ns
`include "top.sv"

module test_bench_top;
    logic clk = 1;
    logic LED;
    logic RGB_R;
    logic RGB_G;
    logic RGB_B;
    string separator = "-----------------------------";

    top u0 (
        .clk                (clk), 
        .LED                (LED),
        .RGB_R              (RGB_R),
        .RGB_G              (RGB_G),
        .RGB_B              (RGB_B)
    );

    initial begin
        $dumpfile("processor.vcd");
        $dumpvars(0, u0);
        #60000000
        $finish;
    end

    always begin
        #50000 // this is normally 2; changed for the purpose of displaying processor state
        clk = ~clk;
    end

    // Display Processor State + Registers
    always @(posedge clk) begin
        if (u0.processor_state == 2'b11) begin
            for (int k = 0; k < 1; k = k + 1) begin
                $display("%s %h", "Program Counter:", u0.pc);
                $display("%s %h", "Current Instruction:", u0.current_instruction);
                for (int i = 0; i < 32; i = i + 1) begin
                    $display("%s%0d%s %h", "Register x", i, ":", u0.registers[i]);
                end
            $display("%s", separator);
            end
        end
    end
    endmodule