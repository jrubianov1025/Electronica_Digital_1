module Timer_WS2812 (
    input  wire       clk,
    input  wire       reset,
    input  wire       INIT_T,
    input  wire [1:0] SEL,

    output wire       DOUT,
    output wire       DONE_T
);

    wire        w_RST;
    wire        w_INC;
    wire        w_Z;
    wire [1:0]  w_SEL_TIM;
    wire [10:0] w_count_out;
    wire [10:0] w_mux_out;

    Control_Timer_WS2812 control_timer (
        .clk     (clk),
        .reset   (reset),
        .INIT_T  (INIT_T),
        .SEL     (SEL),
        .Z       (w_Z),
        .DOUT    (DOUT),
        .DONE_T  (DONE_T),
        .RST     (w_RST),
        .INC     (w_INC),
        .SEL_TIM (w_SEL_TIM)
    );

    count_out contador_timer (
        .clk       (clk),
        .reset     (reset),
        .RST       (w_RST),
        .INC       (w_INC),
        .count_out (w_count_out)
    );

    mux_timer_ws2812 mux_timer (
        .SEL_TIM (w_SEL_TIM),
        .mux_out (w_mux_out)
    );

    comp_timer_ws2812 comparador_timer (
        .count_out (w_count_out),
        .mux_out   (w_mux_out),
        .Z         (w_Z)
    );

endmodule