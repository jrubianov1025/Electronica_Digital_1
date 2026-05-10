module Registro_A #(
    parameter width = 31
)(
    input                   clk,
    input                   INIT,
    input                   LD,
    input                   SH,
    input        [width:0]  SUM_C2,
    input                   MSB_DV,

    output reg   [width:0]  Residuo_NS
);
 
always @(posedge clk) begin

    if (INIT)
        Residuo_NS <= 0;
   
    else if (LD)
        Residuo_NS <= SUM_C2;
   
    else if (SH)
        Residuo_NS <= {Residuo_NS[width-1:0], MSB_DV};
end

endmodule
 
