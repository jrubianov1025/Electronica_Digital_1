module WS2812_led (
    input             clk,
    input             reset,
    input             INIT,
    input      [23:0] RGB,
    input             RST_CMD,

    output            DOUT,
    output            DONE
);

wire        w_SH;
wire        w_INIT_T;
wire        w_DEC;
wire        w_LD;
wire [1:0]  w_SEL;

wire        w_DONE_T;
wire        w_Z;
wire        w_RGB_MSB;
wire [23:0] w_RGB_OUT;
wire [4:0]  w_COUNT;

LSR_RGB lsr_rgb0 (
    .clk     (clk),
    .reset   (reset),
    .LD      (w_LD),
    .SH      (w_SH),
    .RGB     (RGB),
    .RGB_OUT (w_RGB_OUT),
    .RGB_MSB (w_RGB_MSB)
);

Count_24 count_24_0 (
    .clk   (clk),
    .reset (reset),
    .LD    (w_LD),
    .DEC   (w_DEC),
    .Z     (w_Z),
    .COUNT (w_COUNT)
);

Control_WS2812_LED control0 (
    .clk     (clk),
    .reset   (reset),
    .INIT    (INIT),
    .DONE_T  (w_DONE_T),
    .Z       (w_Z),
    .RGB_MSB (w_RGB_MSB),
    .RST_CMD (RST_CMD),

    .SH      (w_SH),
    .INIT_T  (w_INIT_T),
    .DEC     (w_DEC),
    .LD      (w_LD),
    .DONE    (DONE),
    .SEL     (w_SEL)
);

Timer_WS2812 timer0 (
    .clk    (clk),
    .reset  (reset),
    .INIT_T (w_INIT_T),
    .SEL    (w_SEL),
    .DOUT   (DOUT),
    .DONE_T (w_DONE_T)
);

endmodule
