module BinarioABCD(
    input CLK,
    input signed [23:0] Op_A, //numero binario entrada (tambien se puede negativo)
    input INIT,

    output [3:0] SIGN,
    output [3:0] MILLON,
    output [3:0] CIENMIL,
    output [3:0] DIEZMIL,
    output [3:0] MIL,
    output [3:0] CENT,
    output [3:0] DEC,
    output [3:0] UNIT,

    output DONE
);

// Señales internas
wire W_MSB;
wire W_Z;
wire W_LD;
wire W_DEC;
wire W_SH;
wire W_ADD3;

wire [3:0] W_UNITN;
wire [3:0] W_DECN;
wire [3:0] W_CENTN;
wire [3:0] W_MILN;
wire [3:0] W_DIEZMILN;
wire [3:0] W_CIENMILN;
wire [3:0] W_MILLONN;

SUM_C2_BBCD SUM_C2_BBCD0(
    .ADD3(W_ADD3),

    .UNIT(UNIT),
    .DEC(DEC),
    .CENT(CENT),
    .MIL(MIL),
    .DIEZMIL(DIEZMIL),
    .CIENMIL(CIENMIL),
    .MILLON(MILLON),

    .UNITN(W_UNITN),
    .DECN(W_DECN),
    .CENTN(W_CENTN),
    .MILN(W_MILN),
    .DIEZMILN(W_DIEZMILN),
    .CIENMILN(W_CIENMILN),
    .MILLONN(W_MILLONN),

    .MSB(W_MSB)
);

CONTADOR_BBCD CONTADOR_BBCD0(
    .CLK(CLK),
    .LD(W_LD),
    .DEC(W_DEC),
    .Z(W_Z)
);

LSR_BBCD LSR_BBCD0(
    .CLK(CLK),
    .SH(W_SH),
    .LD(W_LD),

    .Op_A_in(Op_A),

    .UNITN(W_UNITN),
    .DECN(W_DECN),
    .CENTN(W_CENTN),
    .MILN(W_MILN),
    .DIEZMILN(W_DIEZMILN),
    .CIENMILN(W_CIENMILN),
    .MILLONN(W_MILLONN),

    .SIGN(SIGN),

    .UNIT(UNIT),
    .DEC(DEC),
    .CENT(CENT),
    .MIL(MIL),
    .DIEZMIL(DIEZMIL),
    .CIENMIL(CIENMIL),
    .MILLON(MILLON)
);

CONTROL_BBCD CONTROL_BBCD0(
    .CLK(CLK),
    .MSB(W_MSB),
    .Z(W_Z),
    .INIT(INIT),

    .LD(W_LD),
    .DEC(W_DEC),
    .SH(W_SH),
    .ADD3(W_ADD3),
    .DONE(DONE)
);

endmodule