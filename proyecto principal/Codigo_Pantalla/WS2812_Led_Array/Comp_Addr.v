module Comp_Addr #(
    parameter ADDR_WIDTH = 8,
    parameter N_LEDS = 8
)(
    input [ADDR_WIDTH-1:0] ADDR,
    output Z
);

assign Z = (ADDR == N_LEDS);

endmodule
