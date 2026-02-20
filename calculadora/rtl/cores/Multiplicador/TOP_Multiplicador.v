module TOP_Multiplicador (

    input reset,
    input clk,
    input init,

    input signed [15:0] Multiplicando,
    input signed [15:0] Multiplicador,
    
    output [31:0] Resultado,
    output DONE

);

assign Resultado = B_long;

wire signed [31:0] A_long;
wire signed [31:0] B_long;
wire signed [31:0] ACC;

wire W_LD;
wire W_SH;
wire W_ADD;
wire W_DEC;
wire W_LSB;
wire W_Z;

wire ACC_LSB;
wire [4:0] count;

A_long_Multiplicador A_long_reg (

    .clk(clk),
    .LD(W_LD),  
    .A(Multiplicando),

    .A_long(A_long)

);

B_long_Multiplicador B_long_reg(

    .clk(clk),
    .LD(W_LD),
    .SH(W_SH),
    .ACC_LSB(ACC_LSB),
    .B(Multiplicador),

    .B_long(B_long),
    .LSB(W_LSB)

);

Acumulador_Multiplicador ACC0(

    .clk(clk),
    .LD(W_LD),
    .ADD(W_ADD),
    .SH(W_SH),
    .A_long(A_long),

    .ACC(ACC),
    .ACC_LSB(ACC_LSB)

);

contador_Multiplicador contador_Multiplicador0(

    .clk(clk),
    .reset(W_LD),
    .in(W_DEC),

    .out(count),
    .zero(W_Z)
);

Control_Multiplicador Control_Multiplicador0(
    
    .clk(clk),
    .init(init),
    .Z(W_Z),
    .LSB(W_LSB),

    .ADD(W_ADD),
    .SH(W_SH),
    .DEC(W_DEC),
    .LD(W_LD),
    .DONE(DONE)
);

endmodule
