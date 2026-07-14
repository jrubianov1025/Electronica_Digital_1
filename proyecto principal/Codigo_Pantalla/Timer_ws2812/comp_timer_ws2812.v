module comp_timer_ws2812 (
    input  wire [10:0] count_out,
    input  wire [10:0] mux_out,
    output wire        Z
);

    assign Z = (count_out == (mux_out - 11'd1)) ? 1'b1 : 1'b0;

endmodule