module SUB_C2_BCDB(

    input SUB3,

    input [3:0] UNIT,
    input [3:0] DEC,
    input [3:0] CENT,
    input [3:0] MIL,
    input [3:0] DIEZMIL,
    input [3:0] CIENMIL,
    input [3:0] MILLON,

    output reg [3:0] UNITN,
    output reg [3:0] DECN,
    output reg [3:0] CENTN,
    output reg [3:0] MILN,
    output reg [3:0] DIEZMILN,
    output reg [3:0] CIENMILN,
    output reg [3:0] MILLONN,
    
    output MSB
);

// Registros intermedios de 5 bits 

reg [4:0] diffU;
reg [4:0] diffD;
reg [4:0] diffC;
reg [4:0] diffM;
reg [4:0] diffDM;
reg [4:0] diffCM;
reg [4:0] diffMM;

always @(*) begin
    // Detectar nibble >= 8: restar 8 en C2 (5'b11000 = -8)
    diffU  = {1'b0, UNIT}    + 5'b11000;
    diffD  = {1'b0, DEC}     + 5'b11000;
    diffC  = {1'b0, CENT}    + 5'b11000;
    diffM  = {1'b0, MIL}     + 5'b11000;
    diffDM = {1'b0, DIEZMIL} + 5'b11000;
    diffCM = {1'b0, CIENMIL} + 5'b11000;
    diffMM = {1'b0, MILLON}  + 5'b11000;

    // Por defecto: salida sin modificar

    UNITN = UNIT;
    DECN = DEC;
    CENTN = CENT;
    MILN = MIL;
    DIEZMILN = DIEZMIL;
    CIENMILN = CIENMIL;
    MILLONN = MILLON;

    // Si nibble >= 8 (diff[4]==0 → sin borrow) y SUB3 activo → restar 3
    if(SUB3 && diffU[4]== 1'b0)  UNITN    = UNIT    - 4'd3;
    if(SUB3 && diffD[4]== 1'b0)  DECN     = DEC     - 4'd3;
    if(SUB3 && diffC[4]== 1'b0)  CENTN    = CENT    - 4'd3;
    if(SUB3 && diffM[4]== 1'b0)  MILN     = MIL     - 4'd3;
    if(SUB3 && diffDM[4]== 1'b0) DIEZMILN = DIEZMIL - 4'd3;
    if(SUB3 && diffCM[4]== 1'b0) CIENMILN = CIENMIL - 4'd3;
    if(SUB3 && diffMM[4]== 1'b0) MILLONN  = MILLON  - 4'd3;
end

// MSB = 1 si ALGÚN nibble >= 8 
assign MSB =(!diffU[4]) ||(!diffD[4]) || (!diffC[4]) || (!diffM[4]) || (!diffDM[4]) || (!diffCM[4]) || (!diffMM[4]);

endmodule