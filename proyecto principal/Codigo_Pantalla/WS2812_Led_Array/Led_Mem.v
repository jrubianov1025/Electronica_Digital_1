module Led_Mem #(
    parameter ADDR_WIDTH = 8
)(
    input  [ADDR_WIDTH-1:0] ADDR,
    input  [3:0] IMG_SEL,
    output reg [23:0] RGB
);

wire [23:0] RGB_IMG_0;
wire [23:0] RGB_IMG_1;
wire [23:0] RGB_IMG_2;
wire [23:0] RGB_IMG_3;

// Imagen 0
Image_0 #(
    .ADDR_WIDTH(ADDR_WIDTH)
) image_0_inst (
    .ADDR(ADDR),
    .RGB(RGB_IMG_0)
);

// Imagen 1
Image_1 #(
    .ADDR_WIDTH(ADDR_WIDTH)
) image_1_inst (
    .ADDR(ADDR),
    .RGB(RGB_IMG_1)
);

// Imagen 2
Image_2 #(
    .ADDR_WIDTH(ADDR_WIDTH)
) image_2_inst (
    .ADDR(ADDR),
    .RGB(RGB_IMG_2)
);

// Imagen 3
Image_3 #(
    .ADDR_WIDTH(ADDR_WIDTH)
) image_3_inst (
    .ADDR(ADDR),
    .RGB(RGB_IMG_3)
);

// Selector de imagen
always @(*) begin
    case (IMG_SEL)

        4'd0: RGB = RGB_IMG_0;
        4'd1: RGB = RGB_IMG_1;
        4'd2: RGB = RGB_IMG_2;
        4'd3: RGB = RGB_IMG_3;

        default: RGB = 24'h000000;

    endcase
end

endmodule