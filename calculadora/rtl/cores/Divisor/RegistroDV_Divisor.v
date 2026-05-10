module Registro_DV #(
    parameter width = 31
)(
    input                   clk,
    input                   INIT,
    input                   SH,
    input                   DV0,
    input        [width:0]  Dividendo,
    output reg              MSB_DV,
    output reg   [width:0]  Resultado_NS
);

always @(posedge clk) begin
    if (INIT) begin
        Resultado_NS <= Dividendo;
        MSB_DV       <= Dividendo[width];
    end
    else if (SH) begin
        Resultado_NS <= {Resultado_NS[width-1:0], 1'b0};
        MSB_DV       <= Resultado_NS[width-1];
    end
    else if (DV0) begin
        Resultado_NS[0] <= 1'b1;
    end
end

endmodule