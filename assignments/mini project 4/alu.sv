/*
 *  Arithmetic Logic Unit
 *  
 *  Computes Addition and Subtraction Operations
 *  Supported Operations:
 *  Immediate ALU ops — I-type -  addi, slti, sltiu, xori, ori, andi, slli, srli, srai
 *  Register ALU ops — R-type -  add, sub, sll, slt, sltu, xor, srl, sra, or, and
 */

 module alu (
    input logic clk, 
    input logic [2:0]  funct3,
    input logic [6:0]  funct7,
    input logic [4:0]   index,

    input logic [31:0] value1,
    input logic [31:0] value2,
    output logic [31:0] out
);
    logic [0:4] shamt = 5'd0;
    always_ff @(posedge clk) begin
        out <= 32'd0;
        if (index == 5'd9 || index == 5'd8) begin    // Register ALU ops
            case(funct3)
                3'b000: begin  // add or addi or sub or subi
                    if (funct7[5] == 1'b1) begin
                        out <= value1 - value2;
                    end else begin
                        out <= value1 + value2;
                    end
                end
                3'b010: begin // slti or slt
                    out <= 32'd0;
                    if (value2 < value1) begin
                        out <= 32'd1;
                    end
                end
                3'b011: begin // sltiu or sltu
                    out <= 32'd0;
                    if (value2 > value1) begin
                        out <= 32'd1;
                    end
                end
                3'b100: begin // xori or xor
                    out <= value1 ^ value2;
                end
                3'b110: begin // ori or or
                    out <= value1 | value2;
                end
                3'b111: begin // andi or and
                    out <= value1 & value2;
                end
                3'b001: begin // slli or sll
                    shamt = value2[4:0];
                    out <= value1 << shamt;
                end

                3'b101: begin // srli/srl/sra/srai
                    shamt = value1[4:0];
                    if (value1[10] == 1'b1)   // SRA / SRAI
                        out <= $signed(value2) >>> shamt;
                    else  // srli/srl
                        out <= value2 >> shamt;
                end
            endcase            
        end
    end
endmodule

 
