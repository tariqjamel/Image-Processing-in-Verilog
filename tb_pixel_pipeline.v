`timescale 1ns/1ps

module tb_pixel_pipeline;
    reg clk = 0;
    reg reset_n = 0;
    reg [7:0] raw_pixel;
    reg pixel_valid = 0;
    wire [23:0] processed_pixel;
    wire pixel_out_valid;

    reg [7:0] test_img [0:3];
    integer idx;

    // Output storage
    reg [23:0] output_pixels [0:1023]; 
    integer out_idx = 0;

    initial begin
        test_img[0] = 8'hFF; // Row 0, Col 0 (R)
        test_img[1] = 8'h00; // Row 0, Col 1 (G)
        test_img[2] = 8'h00; // Row 1, Col 0 (G)
        test_img[3] = 8'hFF; // Row 1, Col 1 (B)
    end

    pixel_pipeline dut (
        .clk(clk),
        .reset_n(reset_n),
        .raw_pixel(raw_pixel),
        .pixel_valid(pixel_valid),
        .processed_pixel(processed_pixel),
        .pixel_out_valid(pixel_out_valid),
        .sensor_pattern(2'b00), // RGGB
        .filter_type(2'b01)     // Blur
    );

    always #5 clk = ~clk;  // 10ns clock

    // Feed input pixels
    initial begin
        #100;
        reset_n = 1;

        for (idx = 0; idx < 4; idx = idx + 1) begin
            @(posedge clk);
            raw_pixel = test_img[idx];
            pixel_valid = 1;
        end

        @(posedge clk);
        pixel_valid = 0;

        // Wait for processing to finish
        #1000;

        // Save to hex file
        $writememh("output.hex", output_pixels, 0, out_idx - 1);
        $display("Output written to output.hex");
        $display("Simulation complete");
        $finish;
    end

    // Store output pixels when valid
    always @(posedge clk) begin
        if (pixel_out_valid) begin
            output_pixels[out_idx] = processed_pixel;
            $display("Pixel[%0d] = %h", out_idx, processed_pixel);
            out_idx = out_idx + 1;
        end
    end

    initial begin
        $dumpfile("pipeline_waves.vcd");
        $dumpvars(0, tb_pixel_pipeline);
    end
endmodule
