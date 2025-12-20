/*
 *  Instruction Decoder Module
 *  Anika Mahesh + Henry Tejada Deras
 *  
 *  Decodes RISC-V RV32I and RV32M Instructions
 */

module decoder (
    input logic clk, 
    input  logic [31:0] instruction,
    output logic [6:0]  opcode,
    output logic [4:0]  rd,
    output logic [2:0]  funct3,
    output logic [4:0]  rs1,
    output logic [4:0]  rs2,
    output logic [6:0]  funct7,
    output logic [31:0] imm_i,
    output logic [31:0] imm_s,
    output logic [31:0] imm_b,
    output logic [31:0] imm_u,
    output logic [31:0] imm_j,
    output logic [4:0] index
);

    always_ff @(negedge clk) begin
        // Default assignments
        opcode = instruction[6:0];
        rd     = 5'd0;
        funct3 = 3'd0;
        rs1    = 5'd0;
        rs2    = 5'd0;
        funct7 = 7'd0;
        imm_i  = 32'd0;
        imm_s  = 32'd0;
        imm_b  = 32'd0;
        imm_u  = 32'd0;
        imm_j  = 32'd0;

        case (opcode)
            //U-type - lui
            7'b0110111: begin
                rd     = instruction[11:7];
                imm_u  = {instruction[31:12], 12'd0};
                index = 5'd1;
            end

            //U-type -  auipc
            7'b0010111: begin
                rd     = instruction[11:7];
                imm_u  = {instruction[31:12], 12'd0};
                index = 5'd2;
            end

            // J-type - jal
            7'b1101111: begin
                rd     = instruction[11:7];
                imm_j  = {{12{instruction[31]}},
                          instruction[19:12],
                          instruction[20],
                          instruction[30:21],
                          1'b0};  // sign-extend
                index = 5'd3;
            end

            // I-type - jalr
            7'b1100111: begin
                rd     = instruction[11:7];
                funct3 = instruction[14:12];
                rs1    = instruction[19:15];
                imm_i  = {{20{instruction[31]}}, instruction[31:20]};
                index = 5'd4;
            end

            // Branches — B-type -  beq, bne, blt, bge, bltu, bgeu
            7'b1100011: begin
                funct3 = instruction[14:12];
                rs1    = instruction[19:15];
                rs2    = instruction[24:20];
                imm_b  = {{19{instruction[31]}},
                          instruction[31],
                          instruction[7],
                          instruction[30:25],
                          instruction[11:8],
                          1'b0};  // sign-extend
                index = 5'd5;
            end

            // Loads — I-type -lb lh lw lbu lhu
            7'b0000011: begin
                rd     = instruction[11:7];
                funct3 = instruction[14:12];
                rs1    = instruction[19:15];
                imm_i  = {{20{instruction[31]}}, instruction[31:20]};
                index = 5'd6;
            end

            // Stores — S-type - sb, sh, sw
            7'b0100011: begin
                funct3 = instruction[14:12];
                rs1    = instruction[19:15];
                rs2    = instruction[24:20];
                imm_s  = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
                index = 5'd7;
            end

            // Immediate ALU ops — I-type -  addi, slti, sltiu, xori, ori, andi, slli, srli, srai
            7'b0010011: begin
                rd     = instruction[11:7];
                funct3 = instruction[14:12];
                rs1    = instruction[19:15];
                imm_i  = {{20{instruction[31]}}, instruction[31:20]};
                index = 5'd8;
            end

            // Register ALU ops — R-type -  add, sub, sll, slt, sltu, xor, srl, sra, or, and
            7'b0110011: begin
                rd     = instruction[11:7];
                funct3 = instruction[14:12];
                rs1    = instruction[19:15];
                rs2    = instruction[24:20];
                funct7 = instruction[31:25];
                index = 5'd9;
            end

            default: begin
                // Unknown opcode — all zero
                index = 5'd0;
            end
        endcase
    end
endmodule