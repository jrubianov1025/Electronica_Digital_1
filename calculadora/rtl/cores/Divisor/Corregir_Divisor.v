module Corregir_Signos #(
    parameter width = 31
)(
    input  signed [width:0] Residuo_NS,
    input  signed [width:0] Resultado_NS,
    input                   result_sign,
    input                   residue_sign,
    
    output signed [width:0] Residuo,
    output signed [width:0] Resultado
);
 
assign Resultado = result_sign  ? (~Resultado_NS + 1) : Resultado_NS;
assign Residuo   = residue_sign ? (~Residuo_NS   + 1) : Residuo_NS;
 
endmodule
 
