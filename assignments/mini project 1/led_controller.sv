module led_controller(
    // LED Controlling Logic
    input logic i_RGB_R,
    input logic i_RGB_G,
    input logic i_RGB_B,
    output logic o_RBG_R,
    output logic o_RBG_G,
    output logic o_RBG_B
);
    always_comb begin
        // Variable Initialization
        // o_RBG_R = 1'b0;
        // o_RBG_G = 1'b0;
        // o_RBG_B = 1'b0;
        
        if (i_RGB_R == 1'b1 && i_RGB_G == 1'b0 && i_RGB_B == 1'b0) begin // Red -> Yellow
            o_RBG_R <= 1'b1;
            o_RBG_G <= 1'b1;
            o_RBG_B <= 1'b0;
        end
        else if (i_RGB_R == 1'b1 && i_RGB_G == 1'b1 && i_RGB_B == 1'b0) begin // Yellow -> Green
            o_RBG_R <= 1'b0;
            o_RBG_G <= 1'b1;
            o_RBG_B <= 1'b0;
        end
        else if (i_RGB_R == 1'b0 && i_RGB_G == 1'b1 && i_RGB_B == 1'b0) begin // Green -> Cyan
            o_RBG_R <= 1'b0;
            o_RBG_G <= 1'b1;
            o_RBG_B <= 1'b1;
        end
        else if (i_RGB_R == 1'b0 && i_RGB_G == 1'b1 && i_RGB_B == 1'b1) begin // Cyan -> Blue
            o_RBG_R <= 1'b0;
            o_RBG_G <= 1'b0;
            o_RBG_B <= 1'b1;
        end
        else if (i_RGB_R == 1'b0 && i_RGB_G == 1'b0 && i_RGB_B == 1'b1) begin // Blue -> Magenta
            o_RBG_R <= 1'b1;
            o_RBG_G <= 1'b0;
            o_RBG_B <= 1'b1;
        end
        else if (i_RGB_R == 1'b1 && i_RGB_G == 1'b0 && i_RGB_B == 1'b1) begin // Magenta -> Red
            o_RBG_R <= 1'b1;
            o_RBG_G <= 1'b0;
            o_RBG_B <= 1'b0;
        end
    end
endmodule