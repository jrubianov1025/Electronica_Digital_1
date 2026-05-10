module Divisor_Top #(
    parameter width = 31
)(
    input                    clk,
    input                    init,
    input signed  [width:0]  Dividendo,
    input signed  [width:0]  DR,

    output signed [width:0]  Residuo,
    output signed [width:0]  Resultado,
    output                   DONE
);

wire LD; 
wire SH;
wire DEC;
wire DV0;

wire              Z;
wire              MSB_DV;
wire              MSB;
wire [width:0]    SUM_C2_out;
wire [width:0]    Residuo_NS;
wire [width:0]    Resultado_NS;

wire result_sign  = Dividendo[width] ^ DR[width];
wire residue_sign = Dividendo[width];

wire corregir = result_sign | residue_sign;

wire [width:0] Dividendo_abs = Dividendo[width] ? (~Dividendo + 1) : Dividendo;
wire [width:0] DR_abs        = DR[width]        ? (~DR + 1)        : DR;


Control_Divisor control (

    .clk      (clk),
    .init     (init),
    .Z        (Z),
    .MSB      (MSB),
    .corregir (corregir),
    .LD       (LD),
    .SH       (SH),
    .DEC      (DEC),
    .DV0      (DV0),
    .DONE     (DONE)

);

Contador_Divisor contador (

    .clk (clk),
    .INIT(init),
    .DEC (DEC),
    .out (),
    .Z   (Z)

);

Registro_DV #(.width(width)) reg_DV (

    .Dividendo (Dividendo_abs),  
    .clk         (clk),
    .INIT        (init),   
    .SH          (SH),
    .DV0         (DV0),
    .MSB_DV      (MSB_DV),
    .Resultado_NS(Resultado_NS)

);
Registro_A #(.width(width)) reg_A (

    .clk       (clk),
    .INIT      (init),
    .LD        (LD),
    .SH        (SH),
    .SUM_C2    (SUM_C2_out),
    .MSB_DV    (MSB_DV),
    .Residuo_NS(Residuo_NS)

);

Sumador_Divisor #(.width(width)) sumador (

    .DR (DR_abs),               
    .A   (Residuo_NS),
    .OUT (SUM_C2_out),
    .MSB (MSB)

);

Corregir_Signos #(.width(width)) corrector (

    .Residuo_NS  (Residuo_NS),
    .Resultado_NS(Resultado_NS),
    .result_sign (result_sign),
    .residue_sign(residue_sign),
    .Residuo     (Residuo),
    .Resultado   (Resultado)

);

endmodule