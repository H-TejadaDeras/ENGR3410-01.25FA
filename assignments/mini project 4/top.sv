/*
 *  RISC-V Processor with RV32I Instructions
 */

`include "memory.sv"
`include "decoder.sv"
`include "alu.sv"

module top (
    input logic clk, 
    output logic LED, 
    output logic RGB_R, 
    output logic RGB_G, 
    output logic RGB_B
);
    /////////////////////////////// Declarations //////////////////////////////
    // Variable Declarations
    localparam FETCH_INSTRUCTION = 2'b00;
    localparam FETCH_REGISTERS = 2'b01;
    localparam EXECUTE_INSTRUCTION = 2'b10;
    localparam WRITE_BACK = 2'b11;

    localparam HIGH = 1'b1;
    localparam LOW = 1'b0;

    localparam DEFAULT_PCREL_13 = 32'd4;

    // Net Declarations
    logic reset;
    logic led;
    logic red;
    logic green;
    logic blue;

    logic instruction_completed;
    logic [31:0] increment = 32'b0;

    logic [2:0] w_funct3_memory;
    logic w_dmem_wren;
    logic [31:0] w_dmem_address;
    logic [31:0] w_dmem_data_in;
    logic [31:0] w_imem_address;
    logic [31:0] w_imem_data_out;
    logic [31:0] w_dmem_data_out;

    logic [6:0] opcode;
    logic [4:0] rd;
    logic [2:0] w_funct3_decoder;
    logic [4:0] rs1;
    logic [4:0] rs2;
    logic [6:0] w_funct7_decoder;
    logic [31:0] w_imm_i_decoder;
    logic [31:0] w_imm_s_decoder;
    logic [31:0] w_imm_b_decoder;
    logic [31:0] w_imm_u_decoder;
    logic [31:0] w_imm_j_decoder;
    logic [4:0] w_index_decoder;

    logic [31:0] alu_value1;
    logic [31:0] alu_value2;
    logic [31:0] alu_output;

    logic [31:0] rs1_value;
    logic [31:0] rs2_value;
    logic [31:0] pcrel_13;
    logic [31:0] pcrel_21;
    logic [31:0] jalr_increment = 32'b0;

    logic [2:0] processor_state = FETCH_INSTRUCTION;

    parameter EXECUTE_INSTRUCTION_CLK_CYCLES = 2 - 1; // Zero-based indexing
    logic [$clog2(EXECUTE_INSTRUCTION_CLK_CYCLES):0] execute_instruction_counter = 0;

    // Register Declarations
    logic [31:0][31:0] registers = 0;
    logic [31:0] pc = 32'h1000; // Instruction memory as implemented in memory.sv starts at 0x1000
    logic [31:0] current_instruction; // Current instruction being executed by processor

    // Module Declarations
    memory #(
        .IMEM_INIT_FILE_PREFIX  ("tester_memories/misc_instruct_test_"),
        .DMEM_INIT_FILE_PREFIX  ("tester_memories/tester_dmem_")
    ) u1 (
        .clk            (clk), 
        .funct3         (w_funct3_memory), 
        .dmem_wren      (w_dmem_wren), 
        .dmem_address   (w_dmem_address[31:0]), 
        .dmem_data_in   (w_dmem_data_in[31:0]), 
        .imem_address   (w_imem_address[31:0]), 
        .imem_data_out  (w_imem_data_out[31:0]), 
        .dmem_data_out  (w_dmem_data_out[31:0]), 
        .reset          (reset), 
        .led            (led), 
        .red            (red), 
        .green          (green), 
        .blue           (blue)
    );

    decoder u2 (
        .clk            (clk),
        .instruction    (current_instruction[31:0]),
        .opcode         (opcode),
        .rd             (rd),
        .funct3         (w_funct3_decoder),
        .rs1            (rs1),
        .rs2            (rs2),
        .funct7         (w_funct7_decoder),
        .imm_i          (w_imm_i_decoder),
        .imm_s          (w_imm_s_decoder),
        .imm_b          (w_imm_b_decoder),
        .imm_u          (w_imm_u_decoder),
        .imm_j          (w_imm_j_decoder),
        .index          (w_index_decoder)
    );

    alu u3 (
        .clk            (clk),
        .funct3         (w_funct3_decoder),
        .funct7         (w_funct7_decoder),
        .index          (w_index_decoder),
        .value1         (alu_value1),
        .value2         (alu_value2),
        .out            (alu_output)
    );

    /////////////////////////// Processor State Machine ///////////////////////
    always_comb begin
        case (processor_state)
            FETCH_INSTRUCTION: begin
                w_dmem_wren = LOW;
                w_funct3_memory = 3'b010;
                w_imem_address = pc[31:0]; // Get instr. address from pc
                instruction_completed = LOW;
            end

            FETCH_REGISTERS: begin
                current_instruction = w_imem_data_out; // Save current instruction for use by decoder
                instruction_completed = LOW;
            end

            EXECUTE_INSTRUCTION: begin
                instruction_completed = LOW;
            end

            WRITE_BACK: begin
                // Update pc
                // Store Word
                instruction_completed = HIGH;
            end
        endcase
    end

    always_ff @(posedge clk) begin
        case (processor_state)
            FETCH_INSTRUCTION: begin
                processor_state <= FETCH_REGISTERS;
            end

            FETCH_REGISTERS: begin
                processor_state <= EXECUTE_INSTRUCTION;
            end

            EXECUTE_INSTRUCTION: begin
                if (execute_instruction_counter >= EXECUTE_INSTRUCTION_CLK_CYCLES) begin
                    processor_state <= WRITE_BACK;
                    execute_instruction_counter = 0;
                end else begin
                    execute_instruction_counter = execute_instruction_counter + 1;
                end
            end

            WRITE_BACK: begin
                processor_state <= FETCH_INSTRUCTION;
            end
        endcase
    end

    /////////////////////// Data Memory Operations ////////////////////////////
    always_ff @(negedge clk) begin
        if (processor_state == EXECUTE_INSTRUCTION) begin
            case (opcode)
                default: begin
                    w_dmem_wren <= LOW;
                    w_funct3_memory <= 3'b0;
                    w_dmem_address <= 32'b0;
                end

                7'b0000011: begin // lb, lh, lw, lbu, lhu
                    w_dmem_wren <= LOW; // Read Operation
                    w_funct3_memory <= w_funct3_decoder;
                    w_dmem_address <= registers[rs1] + w_imm_i_decoder;
                    registers[rd] <= w_dmem_data_out;
                end

                7'b0100011: begin // sb, sh, sw
                    w_dmem_wren <= HIGH; // Write Operation
                    w_funct3_memory <= w_funct3_decoder;
                    w_dmem_address <= registers[rs1] + w_imm_s_decoder;
                    w_dmem_data_in <= registers[rs2];
                end

                7'b0010011: begin // Immediate ALU ops — I-type -  addi, slti, sltiu, xori, ori, andi, slli, srli, srai
                    alu_value1 = w_imm_i_decoder;
                    alu_value2 = registers[rs1];
                    registers[rd] <= alu_output;
                end

                7'b0110011: begin // Register ALU ops — R-type -  add, sub, sll, slt, sltu, xor, srl, sra, or, and
                    alu_value1 = registers[rs1];
                    alu_value2 = registers[rs2];
                    registers[rd] <= alu_output;                   
                end
            endcase
        end
    end

    /////////////////// Branch Instruction Operations /////////////////////////
    always_ff @(negedge clk) begin
        if (processor_state == EXECUTE_INSTRUCTION && opcode == 7'b1100011) begin
            rs1_value = registers[rs1];
            rs2_value = registers[rs2];

            case (w_funct3_decoder)
                default: begin // any other
                    pcrel_13 = 32'b0;
                end

                3'b000: begin // beq
                    if (rs1_value == rs2_value) begin
                        pcrel_13 = w_imm_b_decoder;
                    end else begin
                        pcrel_13 = DEFAULT_PCREL_13;
                    end
                end

                3'b001: begin // bne
                    if (rs1_value != rs2_value) begin
                        pcrel_13 = w_imm_b_decoder;
                    end else begin
                        pcrel_13 = DEFAULT_PCREL_13;
                    end
                end

                3'b100: begin // blt
                    if (rs1_value < rs2_value) begin
                        pcrel_13 = w_imm_b_decoder;
                    end else begin
                        pcrel_13 = DEFAULT_PCREL_13;
                    end
                end

                3'b101: begin // bge
                    if (rs1_value >= rs2_value) begin
                        pcrel_13 = w_imm_b_decoder;
                    end else begin
                        pcrel_13 = DEFAULT_PCREL_13;
                    end
                end

                3'b110: begin // bltu
                    if (rs1_value < rs2_value) begin
                        pcrel_13 = w_imm_b_decoder;
                    end else begin
                        pcrel_13 = DEFAULT_PCREL_13;
                    end
                end

                3'b111: begin // bgeu
                    if (rs1_value >= rs2_value) begin
                        pcrel_13 = w_imm_b_decoder;
                    end else begin
                        pcrel_13 = DEFAULT_PCREL_13;
                    end
                end
            endcase
        end
    end

    ////////////////////// Other Instruction Operations ///////////////////////
    always_ff @(negedge clk) begin
        if (processor_state == EXECUTE_INSTRUCTION) begin
            case (opcode)
                default: begin // All other instructions
                end
                
                7'b0110111: begin // lui
                    registers[rd] <= w_imm_u_decoder;
                end

                7'b0010111: begin // auipc
                    registers[rd] <= pc + w_imm_u_decoder;
                end

                7'b1101111: begin // jal
                    registers[rd] <= pc + 32'd4;
                    pcrel_21 <= w_imm_j_decoder;
                end

                7'b1100111: begin // jalr
                    registers[rd] <= pc + 32'd4;
                    jalr_increment <= (registers[rs1] + w_imm_i_decoder) - pc; // equivalent to setting pc equal to rs1 + imm_i
                end

            endcase
        end
    end

    ////////////////////////////// Registers //////////////////////////////////
    // Maintain Zero Register Equal to Zero
    always_ff @(posedge clk) begin
        registers[0] = 32'b0;
    end

    /////////////////////////// Program Counter ///////////////////////////////
    always_ff @(posedge clk) begin
        if (instruction_completed) begin
            pc <= pc + increment;
        end
        else begin
            pc <= pc;
        end
    end

    // Update Program Counter
    always_ff @(negedge clk) begin
        case (opcode)
            default: begin // All other instructions
                increment <= 32'd4;
            end

            7'b1101111: begin // jal
                increment <= pcrel_21;
            end

            7'b1100111: begin // jalr
                increment <= {jalr_increment[31:1], 1'b0}; // Used to make sure LSB is always 0
            end

            7'b1100011: begin // beq, bne, blt, bge, bltu, bgeu
                increment <= pcrel_13;
            end
        endcase
    end

    ///////////////////////////////////////////////////////////////////////////
    assign LED = ~led;
    assign RGB_R = ~red;
    assign RGB_G = ~green;
    assign RGB_B = ~blue;
endmodule