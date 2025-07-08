`timescale 1ns/1ps

module img_filter (
    input clk,
    input reset_n,
    input [23:0] pixel_in,
    input pixel_valid,
    output reg [23:0] pixel_out,
    output reg pixel_out_valid,
    input [1:0] filter_type
);
    // 3x3 convolution kernel
    reg signed [7:0] kernel_0, kernel_1, kernel_2, kernel_3, kernel_4, kernel_5, kernel_6, kernel_7, kernel_8;
    reg [23:0] window_0, window_1, window_2, window_3, window_4, window_5, window_6, window_7, window_8;
    reg [23:0] line_buf_0_0, line_buf_0_1, line_buf_0_2;
    reg [23:0] line_buf_1_0, line_buf_1_1, line_buf_1_2;
    reg [23:0] line_buf_2_0, line_buf_2_1, line_buf_2_2;
    integer r, g, b;
    
    always @(*) begin
        case(filter_type)
            2'b00: begin 
                kernel_0 = 0; kernel_1 = 0; kernel_2 = 0;
                kernel_3 = 0; kernel_4 = 1; kernel_5 = 0;
                kernel_6 = 0; kernel_7 = 0; kernel_8 = 0;
            end
            2'b01: begin 
                kernel_0 = 1; kernel_1 = 2; kernel_2 = 1;
                kernel_3 = 2; kernel_4 = 4; kernel_5 = 2;
                kernel_6 = 1; kernel_7 = 2; kernel_8 = 1;
            end
        endcase
    end
    
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            pixel_out <= 0;
            pixel_out_valid <= 0;
            line_buf_0_0 <= 0; line_buf_0_1 <= 0; line_buf_0_2 <= 0;
            line_buf_1_0 <= 0; line_buf_1_1 <= 0; line_buf_1_2 <= 0;
            line_buf_2_0 <= 0; line_buf_2_1 <= 0; line_buf_2_2 <= 0;
        end
        else if (pixel_valid) begin
            line_buf_0_0 <= line_buf_0_1;
            line_buf_0_1 <= line_buf_0_2;
            line_buf_0_2 <= line_buf_1_2;
            
            line_buf_1_0 <= line_buf_1_1;
            line_buf_1_1 <= line_buf_1_2;
            line_buf_1_2 <= line_buf_2_2;
            
            line_buf_2_0 <= line_buf_2_1;
            line_buf_2_1 <= line_buf_2_2;
            line_buf_2_2 <= pixel_in;
            
            if (line_buf_0_0 != 0) begin 
                window_0 = line_buf_0_0; window_1 = line_buf_0_1; window_2 = line_buf_0_2;
                window_3 = line_buf_1_0; window_4 = line_buf_1_1; window_5 = line_buf_1_2;
                window_6 = line_buf_2_0; window_7 = line_buf_2_1; window_8 = line_buf_2_2;
                
                r = kernel_0 * window_0[23:16] + kernel_1 * window_1[23:16] + kernel_2 * window_2[23:16] +
                    kernel_3 * window_3[23:16] + kernel_4 * window_4[23:16] + kernel_5 * window_5[23:16] +
                    kernel_6 * window_6[23:16] + kernel_7 * window_7[23:16] + kernel_8 * window_8[23:16];
                
                g = kernel_0 * window_0[15:8] + kernel_1 * window_1[15:8] + kernel_2 * window_2[15:8] +
                    kernel_3 * window_3[15:8] + kernel_4 * window_4[15:8] + kernel_5 * window_5[15:8] +
                    kernel_6 * window_6[15:8] + kernel_7 * window_7[15:8] + kernel_8 * window_8[15:8];
                
                b = kernel_0 * window_0[7:0] + kernel_1 * window_1[7:0] + kernel_2 * window_2[7:0] +
                    kernel_3 * window_3[7:0] + kernel_4 * window_4[7:0] + kernel_5 * window_5[7:0] +
                    kernel_6 * window_6[7:0] + kernel_7 * window_7[7:0] + kernel_8 * window_8[7:0];
                
                pixel_out[23:16] <= (r > 255) ? 255 : (r < 0) ? 0 : r[7:0];
                pixel_out[15:8]  <= (g > 255) ? 255 : (g < 0) ? 0 : g[7:0];
                pixel_out[7:0]   <= (b > 255) ? 255 : (b < 0) ? 0 : b[7:0];
                pixel_out_valid <= 1;
            end
            else begin
                pixel_out_valid <= 0;
            end
        end
    end
endmodule
