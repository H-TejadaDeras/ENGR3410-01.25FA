/*
 *  Conway's Game of Life Game Instance on WS2812B LED Matrix
 *  Henry Tejada Deras - 10-19-2025
 *  
 *  Plays Conway's Game of Life Game and displays state on WS2812B LED Matrix.
 *  
 *  Rules Implemented:
 *  - Any living cell with fewer than two living neighbors dies.
 *  - Any living cell with two or three living neighbors continues living.
 *  - Any living cell with more than three living neighbors dies.
 *  - Any dead cell with exactly three living neighbors becomes a living cell.
 *  - Cyclic Boundary Conditions
 */ 
// `begin_keywords "1800-2005" // SystemVerilog-2005
`include "cgol_logic.sv"
`include "memory_controller.sv"
`include "output_controller.sv"

module top (
    input logic clk,
    input logic SW,
    output logic _31b
);
    // Variable Declarations
    localparam HIGH = 1'b1;
    localparam LOW = 1'b0;

    localparam PROCESS_GAME_STATE = 2'b00;
    localparam CYCLE_REGISTERS = 2'b01;
    localparam PROCESS_OUTPUT = 2'b10;
    localparam PAUSE = 2'b11;

    localparam CYCLE_REG = 2'b11; // From memory_controller.sv
    localparam IDLE = 2'b10; // From memory_controller.sv

    parameter PAUSED_STATE_CLK_CYCLES = 1200000; // 1200000 cycles is 0.1 s on a 12 MHz clk

    logic [23:0] shift_reg = 24'd0;
    logic [1:0] state_top = PAUSE;

    logic [5:0] cycle_reg_counter = 0;
    logic [$clog2(PAUSED_STATE_CLK_CYCLES):0] paused_state_counter = 0;

    // Net Declarations
    logic o_led_matrix;

    logic cgol1_start_trigger = LOW;
    logic cgol1_start_trigger_save = LOW;
    logic cgol1_i_data;
    logic cgol1_i_start;
    logic [1:0] cgol1_memory_operation;
    logic [5:0] cgol1_memory_operation_address;
    logic cgol1_o_data;
    logic cgol1_o_done;

    logic [1:0] w_cgol1_memory_operation; // After Top State Machine + Mux to memory_controller module
    logic [5:0] w_cgol1_memory_operation_address; // After Top State Machine + Mux to memory_controller module
    logic w_memctrl1_o_data; // Output from memory_controller module before Top State Machine + Mux

    logic cgol2_start_trigger = LOW;
    logic cgol2_start_trigger_save = LOW;
    logic cgol2_i_data;
    logic cgol2_i_start;
    logic [1:0] cgol2_memory_operation;
    logic [5:0] cgol2_memory_operation_address;
    logic cgol2_o_data;
    logic cgol2_o_done;

    logic [1:0] w_cgol2_memory_operation; // After Top State Machine + Mux to memory_controller module
    logic [5:0] w_cgol2_memory_operation_address; // After Top State Machine + Mux to memory_controller module
    logic w_memctrl2_o_data; // Output from memory_controller module before Top State Machine + Mux

    logic cgol3_start_trigger = LOW;
    logic cgol3_start_trigger_save = LOW;
    logic cgol3_i_data;
    logic cgol3_i_start;
    logic [1:0] cgol3_memory_operation;
    logic [5:0] cgol3_memory_operation_address;
    logic cgol3_o_data;
    logic cgol3_o_done;

    logic [1:0] w_cgol3_memory_operation; // After Top State Machine + Mux to memory_controller module
    logic [5:0] w_cgol3_memory_operation_address; // After Top State Machine + Mux to memory_controller module
    logic w_memctrl3_o_data; // Output from memory_controller module before Top State Machine + Mux

    logic outctrl_start_trigger = LOW;
    logic outctrl_start_trigger_save = LOW;
    logic outctrl_start;
    logic outctrl_done;
    logic outctrl_i_data_in_1;
    logic outctrl_i_data_in_2;
    logic outctrl_i_data_in_3;
    logic outctrl_memory_operation;
    logic outctrl_memory_operation_address;

    // Module Declarations
    cgol_logic u1 (
        .clk                        (clk),
        .i_data                     (cgol1_i_data),
        .i_start                    (cgol1_i_start),
        .memory_operation           (cgol1_memory_operation),
        .memory_operation_address   (cgol1_memory_operation_address),
        .o_data                     (cgol1_o_data),
        .o_done                     (cgol1_o_done)
    );
    
    memory_controller #(
        .MEM_INIT_FILE  ("cgol_seeds/toad_tester.bin")
    ) u2 (
        .clk            (clk),
        .operation      (w_cgol1_memory_operation),
        .reg_address    (w_cgol1_memory_operation_address),
        .i_data         (cgol1_o_data),
        .o_data         (w_memctrl1_o_data)
    );

    cgol_logic u3 (
        .clk                        (clk),
        .i_data                     (cgol2_i_data),
        .i_start                    (cgol2_i_start),
        .memory_operation           (cgol2_memory_operation),
        .memory_operation_address   (cgol2_memory_operation_address),
        .o_data                     (cgol2_o_data),
        .o_done                     (cgol2_o_done)
    );
    
    memory_controller #(
        .MEM_INIT_FILE  ("cgol_seeds/toad_tester.bin")
    ) u4 (
        .clk            (clk),
        .operation      (w_cgol2_memory_operation),
        .reg_address    (w_cgol2_memory_operation_address),
        .i_data         (cgol2_o_data),
        .o_data         (w_memctrl2_o_data)
    );

    cgol_logic u5 (
        .clk                        (clk),
        .i_data                     (cgol3_i_data),
        .i_start                    (cgol3_i_start),
        .memory_operation           (cgol3_memory_operation),
        .memory_operation_address   (cgol3_memory_operation_address),
        .o_data                     (cgol3_o_data),
        .o_done                     (cgol3_o_done)
    );
    
    memory_controller #(
        .MEM_INIT_FILE  ("cgol_seeds/toad_tester.bin")
    ) u6 (
        .clk            (clk),
        .operation      (w_cgol3_memory_operation),
        .reg_address    (w_cgol3_memory_operation_address),
        .i_data         (cgol3_o_data),
        .o_data         (w_memctrl3_o_data)
    );

    output_controller u7 (
        .clk                        (clk),
        .i_data_in_1                (outctrl_i_data_in_1),
        .i_data_in_2                (outctrl_i_data_in_2),
        .i_data_in_3                (outctrl_i_data_in_3),
        .i_start                    (outctrl_start),
        .o_done                     (outctrl_done),
        .o_memory_operation         (outctrl_memory_operation),
        .o_memory_operation_address (outctrl_memory_operation_address),
        .o_led_matrix               (o_led_matrix)
    );

    // Top State Machine + Switch Net Drivers
    always_ff @(posedge clk) begin
        case (state_top)
            PROCESS_GAME_STATE: begin
                cgol1_start_trigger <= HIGH;
                cgol2_start_trigger <= HIGH;
                cgol3_start_trigger <= HIGH;
                outctrl_start_trigger <= LOW;

                w_cgol1_memory_operation <= cgol1_memory_operation;
                w_cgol1_memory_operation_address <= cgol1_memory_operation_address;
                cgol1_i_data <= w_memctrl1_o_data;

                w_cgol2_memory_operation <= cgol2_memory_operation;
                w_cgol2_memory_operation_address <= cgol2_memory_operation_address;
                cgol2_i_data <= w_memctrl2_o_data;

                w_cgol3_memory_operation <= cgol3_memory_operation;
                w_cgol3_memory_operation_address <= cgol3_memory_operation_address;
                cgol3_i_data <= w_memctrl3_o_data;
            end

            CYCLE_REGISTERS: begin
                cgol1_start_trigger <= LOW;
                cgol2_start_trigger <= LOW;
                cgol3_start_trigger <= LOW;
                outctrl_start_trigger <= LOW;

                w_cgol1_memory_operation <= CYCLE_REG;
                w_cgol2_memory_operation <= CYCLE_REG;
                w_cgol3_memory_operation <= CYCLE_REG;
            end

            PROCESS_OUTPUT: begin
                cgol1_start_trigger <= LOW;
                cgol2_start_trigger <= LOW;
                cgol3_start_trigger <= LOW;
                outctrl_start_trigger <= HIGH;

                w_cgol1_memory_operation <= outctrl_memory_operation;
                w_cgol1_memory_operation_address <= outctrl_memory_operation_address;
                outctrl_i_data_in_1 <= w_memctrl1_o_data;

                w_cgol2_memory_operation <= outctrl_memory_operation;
                w_cgol2_memory_operation_address <= outctrl_memory_operation_address;
                outctrl_i_data_in_2 <= w_memctrl2_o_data;

                w_cgol3_memory_operation <= outctrl_memory_operation;
                w_cgol3_memory_operation_address <= outctrl_memory_operation_address;
                outctrl_i_data_in_3 <= w_memctrl3_o_data;
            end

            PAUSE: begin
                cgol1_start_trigger <= LOW;
                cgol2_start_trigger <= LOW;
                cgol3_start_trigger <= LOW;
                outctrl_start_trigger <= LOW;
            end
        endcase
    end

    // Start Processing Data Trigger
    always_ff @(posedge clk) begin
        if (cgol1_start_trigger == HIGH && cgol1_start_trigger_save == LOW) begin
            cgol1_i_start <= HIGH;
            cgol1_start_trigger_save <= HIGH;
        end else if (cgol1_start_trigger == HIGH && cgol1_start_trigger_save == HIGH) begin // makes start signal 1 clk period long
            cgol1_i_start <= LOW;
        end else if (cgol1_start_trigger == LOW) begin // start trigger low -> save low, start should already be low
            cgol1_i_start <= LOW;
            cgol1_start_trigger_save <= LOW;
        end
    end

    always_ff @(posedge clk) begin
        if (cgol2_start_trigger == HIGH && cgol2_start_trigger_save == LOW) begin
            cgol2_i_start <= HIGH;
            cgol2_start_trigger_save <= HIGH;
        end else if (cgol2_start_trigger == HIGH && cgol2_start_trigger_save == HIGH) begin // makes start signal 1 clk period long
            cgol2_i_start <= LOW;
        end else if (cgol2_start_trigger == LOW) begin // start trigger low -> save low, start should already be low
            cgol2_i_start <= LOW;
            cgol2_start_trigger_save <= LOW;
        end
    end

    always_ff @(posedge clk) begin
        if (cgol3_start_trigger == HIGH && cgol3_start_trigger_save == LOW) begin
            cgol3_i_start <= HIGH;
            cgol3_start_trigger_save <= HIGH;
        end else if (cgol3_start_trigger == HIGH && cgol3_start_trigger_save == HIGH) begin // makes start signal 1 clk period long
            cgol3_i_start <= LOW;
        end else if (cgol3_start_trigger == LOW) begin // start trigger low -> save low, start should already be low
            cgol3_i_start <= LOW;
            cgol3_start_trigger_save <= LOW;
        end
    end

    always_ff @(posedge clk) begin
        if (outctrl_start_trigger == HIGH && outctrl_start_trigger_save == LOW) begin
            outctrl_start <= HIGH;
            outctrl_start_trigger_save <= HIGH;
        end else if (outctrl_start_trigger == HIGH && outctrl_start_trigger_save == HIGH) begin // makes start signal 1 clk period long
            outctrl_start <= LOW;
        end else if (outctrl_start_trigger == LOW) begin // start trigger low -> save low, start should already be low
            outctrl_start <= LOW;
            outctrl_start_trigger_save <= LOW;
        end
    end

    // Next Step Trigger from CGOL_Logic Module
    always_ff @(posedge clk) begin
        if (cgol1_o_done == HIGH) begin
            state_top <= CYCLE_REGISTERS;
        end
    end

    // Next Step Trigger from Output_Controller Module
    always_ff @(posedge clk) begin
        if (outctrl_done == HIGH) begin
            state_top <= PAUSE;
        end
    end

    // Start Game Trigger from User
    always_ff @(posedge clk) begin
        if (SW == HIGH) begin
            state_top <= PROCESS_GAME_STATE;
        end
    end

    // Cycle Registers Operation Counter
    always_ff @(posedge clk) begin
        if (state_top == CYCLE_REGISTERS) begin
            cycle_reg_counter <= cycle_reg_counter + 1;
            if (cycle_reg_counter >= 6'b111111) begin
                state_top <= PROCESS_OUTPUT;
                cycle_reg_counter <= 0;
            end
        end
    end

    // Paused State Timer
    always_ff @(posedge clk) begin
        if (state_top == PAUSE) begin
            paused_state_counter <= paused_state_counter + 1;
            if (paused_state_counter >= PAUSED_STATE_CLK_CYCLES) begin
                paused_state_counter <= 0;
                state_top <= PROCESS_GAME_STATE;
            end
        end
    end

    assign _31b = o_led_matrix;
endmodule
// `end_keywords "1800-2005" // SystemVerilog-2005