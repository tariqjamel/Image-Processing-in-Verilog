`timescale 1ns/1ps

module raw2rgb (
    input clk,
    input reset_n,
    input [7:0] raw_pixel,
    input pixel_valid,
    output reg [23:0] rgb_pixel,
    output reg rgb_valid,
    input [1:0] sensor_pattern
);
    // Buffer for 2 lines
    reg [7:0] line_buf_0 [0:639];
    reg [7:0] line_buf_1 [0:639];
    reg [9:0] x_pos = 0;
    reg [9:0] y_pos = 0;
    integer i, j;
    
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            x_pos <= 0;
            y_pos <= 0;
            rgb_valid <= 0;
            for (i = 0; i < 640; i = i + 1) begin
                line_buf_0[i] <= 0;
                line_buf_1[i] <= 0;
            end
        end
        else if (pixel_valid) begin
            // Store pixel in line buffer
            if (y_pos[0] == 0)
                line_buf_0[x_pos] <= raw_pixel;
            else
                line_buf_1[x_pos] <= raw_pixel;
            
            // Process when we have enough pixels
            if (x_pos >= 1 && y_pos >= 1) begin
                case(sensor_pattern)
                    2'b00: begin // RGGB
                        if (x_pos[0] ^ y_pos[0]) begin // Green pixel
                            rgb_pixel[23:16] <= (y_pos[0] ? line_buf_0[x_pos] : line_buf_1[x_pos]); // R or B
                            rgb_pixel[15:8]  <= raw_pixel; // G
                            rgb_pixel[7:0]   <= (y_pos[0] ? line_buf_1[x_pos-1] : line_buf_0[x_pos-1]); // B or R
                        end
                        else begin // Red or Blue
                            rgb_pixel[23:16] <= raw_pixel; // R or B
                            rgb_pixel[15:8]  <= ((y_pos[0] ? line_buf_1[x_pos-1] : line_buf_0[x_pos-1]) + 
                                              (y_pos[0] ? line_buf_0[x_pos] : line_buf_1[x_pos])) >> 1; // G
                            rgb_pixel[7:0]   <= (y_pos[0] ? line_buf_0[x_pos-1] : line_buf_1[x_pos-1]); // B or R
                        end
                        rgb_valid <= 1;
                    end
                endcase
            end
            
            // Update position
            if (x_pos == 639) begin
                x_pos <= 0;
                y_pos <= y_pos + 1;
            end
            else begin
                x_pos <= x_pos + 1;
            end
        end
        else begin
            rgb_valid <= 0;
        end
    end
endmodule

