module mux_timer_ws2812 (
    input  wire [1:0]  SEL_TIM,
    output reg  [10:0] mux_out
);

    localparam T0H = 11'd10;
    localparam T1H = 11'd20;
    localparam RES = 11'd1250;
    localparam PER = 11'd31;

    always @(*) begin
        case (SEL_TIM)
            2'd0: mux_out = T0H;
            2'd1: mux_out = T1H;
            2'd2: mux_out = RES;
            2'd3: mux_out = PER;
            default: mux_out = T0H;
        endcase
    end

endmodule