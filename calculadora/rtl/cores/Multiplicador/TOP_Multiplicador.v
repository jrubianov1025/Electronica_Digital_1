module TOP_Multiplicador (

    input reset,
    input clk,
    input init,

    input [15:0] Multiplicando,
    input [15:0] Multiplicador,
    
    output [31:0] Resultado,
    output DONE

);

wire W_LD;
wire W_SH;
wire W_ADD;
wire W_DEC;
wire W_LSB;


//revisar si esto esta bien echo

Control_Multiplicador Control_Multiplicador0(
    
    .clk(clk),
    .init(init),
    .Z(zero),
    .LSB(),

    .ADD(),
    .SH(),
    .DEC(),
    .LD(),
    .DONE()
);

contador_Multiplicador contador_Multiplicador0(

    .clk(clk),
    .reset(LD),
    .in(DEC),

    .out(),
    .zero()
);

endmodule
