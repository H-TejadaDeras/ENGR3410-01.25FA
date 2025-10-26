/*
 *  Two-Bank Memory Controller
 *  Henry Tejada Deras - 10-25-2025
 *  
 *  Handles memory operations between the two banks of memory. One bank is for
 *  read-only memory, the other is for write-only memory.
 *  
 *  Inputs:
 *  parameter MEM_INIT_FILE: Initialization binary memory file path for initial
 *      read-only memory values.
 *  logic clk: Clock signal
 *  logic [1:0] operation: Memory operation to occur.
 *      - 2'b00: Read from read-only register; 1 cycle operation.
 *      - 2'b01: Write to write-only register; 1 cycle operation.
 *      - 2'b11: Cycle contents from write-only register to read-only register;
 *          64 cycles operation.
 *      - 2'b10: Do no operation.
 *  logic [5:0] reg_address: Address to which to execute operation.
 *  logic i_data: Data input for write operation. Will be ignored in other
 *      operations.
 *  
 *  Outputs:
 *  logic o_data: Data output from read operation. Will output logic low output
 *      in other operations.
 */
// `begin_keywords "1800-2005" // SystemVerilog-2005

module memory_controller #(
    parameter MEM_INIT_FILE = ""
) (
    input logic clk,
    input logic [1:0] operation,
    input logic [5:0] reg_address,
    input logic i_data,
    output logic o_data
);
    // Variable Declarations
    localparam READ_REG = 2'b00; // Read from read-only register
    localparam WRITE_REG = 2'b01; // Write to write-only register
    localparam CYCLE_REG = 2'b11; // Transfer contents from write-only register to read-only register
    localparam IDLE = 2'b10; // Do no operation

    logic read_register [63:0];
    logic write_register [63:0];

    logic [5:0] address_counter = 0; // Used to transfer contents from write-only register to read-only register

    // Memory Initialization
    initial if (MEM_INIT_FILE) begin
        $readmemb(MEM_INIT_FILE, read_register);
    end

    always_ff @(posedge clk) begin
        case (operation)
            READ_REG: begin
                o_data <= read_register[reg_address];
            end

            WRITE_REG: begin
                write_register[reg_address] <= i_data;
            end

            CYCLE_REG: begin
                read_register[address_counter] <= write_register[address_counter];
                address_counter <= address_counter + 1;
            end

            IDLE: begin
            end
        endcase
    end
endmodule
// `end_keywords "1800-2005" // SystemVerilog-2005