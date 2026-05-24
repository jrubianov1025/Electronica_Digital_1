module BCDABinario(
    input CLK,
    input INIT,
    
    input [3:0] SIGN,
    input [3:0] MILLON,
    input [3:0] CIENMIL,
    input [3:0] DIEZMIL,
    input [3:0] MIL,
    input [3:0] CENT,
    input [3:0] DEC,
    input [3:0] UNIT,

    output [23:0] Op_A_out, // Número binario de salida
    output DONE
);

wire W_MSB;
wire W_Z;
wire W_LD;
wire W_DEC;
wire W_SH;

wire W_SUB3;

wire [3:0] W_UNITN;
wire [3:0] W_DECN;
wire [3:0] W_CENTN;
wire [3:0] W_MILN;
wire [3:0] W_DIEZMILN;
wire [3:0] W_CIENMILN;
wire [3:0] W_MILLONN;

// wires para los valores actuales del registro (RSR → SUB_C2)
wire [3:0] W_UNIT_REG;
wire [3:0] W_DEC_REG;
wire [3:0] W_CENT_REG;
wire [3:0] W_MIL_REG;
wire [3:0] W_DIEZMIL_REG;
wire [3:0] W_CIENMIL_REG;
wire [3:0] W_MILLON_REG;


SUB_C2_BCDB SUB_C2_BCDB0(
    .SUB3    (W_SUB3),

    .UNIT    (W_UNIT_REG),      
    .DEC     (W_DEC_REG),
    .CENT    (W_CENT_REG),
    .MIL     (W_MIL_REG),
    .DIEZMIL (W_DIEZMIL_REG),
    .CIENMIL (W_CIENMIL_REG),
    .MILLON  (W_MILLON_REG),
    
    .UNITN   (W_UNITN),
    .DECN    (W_DECN),
    .CENTN   (W_CENTN),
    .MILN    (W_MILN),
    .DIEZMILN(W_DIEZMILN),
    .CIENMILN(W_CIENMILN),
    .MILLONN (W_MILLONN),
    
    .MSB     (W_MSB)
);

RSR_BCDB RSR_BCDB0(
    .CLK     (CLK),
    .SH      (W_SH),
    .LD      (W_LD),

    .Op_A_out(Op_A_out),
    
    .UNITN   (W_UNITN),
    .DECN    (W_DECN),
    .CENTN   (W_CENTN),
    .MILN    (W_MILN),
    .DIEZMILN(W_DIEZMILN),
    .CIENMILN(W_CIENMILN),
    .MILLONN (W_MILLONN),
    
    .SIGN    (SIGN),
    
    .UNIT    (W_UNIT_REG),
    .DEC     (W_DEC_REG),
    .CENT    (W_CENT_REG),
    .MIL     (W_MIL_REG),
    .DIEZMIL (W_DIEZMIL_REG),
    .CIENMIL (W_CIENMIL_REG),
    .MILLON  (W_MILLON_REG),
    
    .UNIT_LOAD   (UNIT),
    .DEC_LOAD    (DEC),
    .CENT_LOAD   (CENT),
    .MIL_LOAD    (MIL),
    .DIEZMIL_LOAD(DIEZMIL),
    .CIENMIL_LOAD(CIENMIL),
    .MILLON_LOAD (MILLON)
);

CONTADOR_BCDB CONTADOR_BCDB0(
    .CLK(CLK),
    .LD(W_LD), 
    .DEC(W_DEC), 
    .Z(W_Z)
);

CONTROL_BCDB CONTROL_BCDB0(
    .CLK(CLK), 
    .MSB(W_MSB), 
    .Z(W_Z), 
    .INIT(INIT),
    
    .LD(W_LD), 
    .DEC(W_DEC), 
    .SH(W_SH), 
    .SUB3(W_SUB3), 
    .DONE(DONE)
);

endmodule