`timescale 1ns/1ps

module pixel_pipeline (
    input clk,
    input reset_n,
    input [7:0] raw_pixel,
    input pixel_valid,
    output [23:0] processed_pixel,
    output pixel_out_valid,
    input [1:0] sensor_pattern,
    input [1:0] filter_type
);
    wire [23:0] rgb_pixel;
    wire rgb_valid;
    
    raw2rgb demosaic (
        .clk(clk),
        .reset_n(reset_n),
        .raw_pixel(raw_pixel),
        .pixel_valid(pixel_valid),
        .rgb_pixel(rgb_pixel),
        .rgb_valid(rgb_valid),
        .sensor_pattern(sensor_pattern)
    );
    
    img_filter filter (
        .clk(clk),
        .reset_n(reset_n),
        .pixel_in(rgb_pixel),
        .pixel_valid(rgb_valid),
        .pixel_out(processed_pixel),
        .pixel_out_valid(pixel_out_valid),
        .filter_type(filter_type)
    );
endmodule
