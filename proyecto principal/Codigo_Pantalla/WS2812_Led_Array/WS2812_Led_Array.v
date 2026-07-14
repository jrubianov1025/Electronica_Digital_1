module WS2812_Led_Array #(
    parameter ADDR_WIDTH = 8,
    parameter N_LEDS = 64
)(
    input clk,
    input reset,

    input INIT_M,
    input RST_CMD,
    input [3:0] IMG_SEL,

    output DOUT,
    output DONE_M
);

wire INIT_LED;
wire RST;
wire INC;
wire Z;

wire DONE_LED;

wire [ADDR_WIDTH-1:0] ADDR;
wire [23:0] RGB;


// Unidad de control
Control_WS2812_Led_Array control_array (
    .clk(clk),
    .reset(reset),

    .INIT_M(INIT_M),
    .DONE_LED(DONE_LED),
    .Z(Z),

    .INIT_LED(INIT_LED),
    .RST(RST),
    .INC(INC),
    .DONE_M(DONE_M)
);

// Contador de dirección
Count_Addr #(
    .ADDR_WIDTH(ADDR_WIDTH)
) count_addr (
    .clk(clk),
    .reset(reset),
    .RST(RST),
    .INC(INC),
    .ADDR(ADDR)
);

// Comparador ADDR == N_LEDS
Comp_Addr #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .N_LEDS(N_LEDS)
) comp_addr (
    .ADDR(ADDR),
    .Z(Z)
);

// Memoria / selector de imágenes
Led_Mem #(
    .ADDR_WIDTH(ADDR_WIDTH)
) led_mem (
    .ADDR(ADDR),
    .IMG_SEL(IMG_SEL),
    .RGB(RGB)
);

// Módulo que envía un LED WS2812
WS2812_led ws2812_led_inst (
    .clk(clk),
    .reset(reset),
    .INIT(INIT_LED),
    .RGB(RGB),
    .RST_CMD(RST_CMD),
    .DOUT(DOUT),
    .DONE(DONE_LED)
);

endmodule