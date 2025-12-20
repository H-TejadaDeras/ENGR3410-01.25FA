/*
 *  Arithmetic Logic Unit (with RV32M Instructions)
 *  Anika Mahesh + Henry Tejada Deras - 12-11-2025
 *  
 *  Computes Addition and Subtraction Operations
 *  Supported Operations:
 *  Immediate ALU ops — I-type -  addi, slti, sltiu, xori, ori, andi, slli, srli, srai
 *  Register ALU ops — R-type -  add, sub, sll, slt, sltu, xor, srl, sra, or, and
 *  RV32M Instructions
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
    logic [63:0] product = 64'b0;

    always_ff @(posedge clk) begin
        out <= 32'd0;
        if (index == 5'd9 || index == 5'd8 || index == 5'd10) begin    // Register ALU ops
            if (funct7 == 7'b0000001) begin // Division and Multiplication Operations
                case(funct3)
                    3'b100: begin // div
                        out <= $signed(value1) / $signed(value2);
                    end
                    3'b101: begin // divu
                        out <= value1 / value2;
                    end
                    3'b110: begin // rem
                        out <= $signed(value1) % $signed(value2);
                    end
                    3'b111: begin // remu
                        out <= value1 % value2;
                    end
                    3'b000: begin // mul
                        product <= $signed(value1) * $signed(value2);
                        out <= product[31:0];
                    end
                    3'b001: begin // mulh
                        product <= $signed(value1) * $signed(value2);
                        out <= product[63:32];
                    end
                    3'b010: begin // mulhsu
                        product <= $signed(value1) * $signed({1'b0, value2}); // $signed({1'b0, value2}) makes sure value is unsigned when it is multiplied
                        out <= product[64:32];
                    end
                    3'b011: begin // mulhu
                        product <= value1 * value2;
                        out <= product[64:32];
                    end
                endcase
            end
            
            else begin
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
    end
endmodule