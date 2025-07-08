# 🎞️ Verilog Image Processing Pipeline

This project implements a basic **image processing pipeline** in Verilog. It performs:

- ✅ Bayer-pattern RAW to RGB conversion (`raw2rgb`)
- ✅ 3x3 convolution filtering (`img_filter`)
- ✅ Integration into a complete pipeline (`pixel_pipeline`)
- ✅ Testbench for verification (`tb_pixel_pipeline`)

## Screenshot
<img src="output.jpeg">

## 📌 Features

### 🔸 RAW to RGB (Demosaicing)
- Supports `RGGB` Bayer pattern
- Line-buffer based approach for streaming pixel input
- Generates valid RGB once a 2x2 neighborhood is filled

### 🔸 Image Filter
- Applies 3x3 convolution filters on RGB data
- Supported filters:
  - `00`: Identity
  - `01`: Blur
- Uses sliding window with shift registers

### 🔸 Pipeline Integration
- Top-level `pixel_pipeline` connects `raw2rgb` → `img_filter`
- Parameterized sensor pattern and filter type

### 🔸 Testbench
- Provides a 2x2 RAW input image:
- R G
- G B
