module RSR_BCDB(
    input CLK,
    input SH,
    input LD,

    output [23:0] Op_A_out,

    input [3:0] UNITN,
    input [3:0] DECN,
    input [3:0] CENTN,
    input [3:0] MILN,
    input [3:0] DIEZMILN,
    input [3:0] CIENMILN,
    input [3:0] MILLONN,

    input [3:0] SIGN,

    input [3:0] UNIT_LOAD,
    input [3:0] DEC_LOAD,
    input [3:0] CENT_LOAD,
    input [3:0] MIL_LOAD,
    input [3:0] DIEZMIL_LOAD,
    input [3:0] CIENMIL_LOAD,
    input [3:0] MILLON_LOAD,

    output [3:0] UNIT,
    output [3:0] DEC,
    output [3:0] CENT,
    output [3:0] MIL,
    output [3:0] DIEZMIL,
    output [3:0] CIENMIL,
    output [3:0] MILLON
);

reg [27:0] A;
reg [23:0] Op_A;
reg [3:0]  SIGN_reg;

assign UNIT    = A[3:0];
assign DEC     = A[7:4];
assign CENT    = A[11:8];
assign MIL     = A[15:12];
assign DIEZMIL = A[19:16];
assign CIENMIL = A[23:20];
assign MILLON  = A[27:24];

assign Op_A_out = (SIGN_reg == 4'hA) ? (~Op_A + 1'b1) : Op_A;

always @(posedge CLK) begin
    if(LD) begin
        // ← Ahora carga desde los inputs originales, no desde sus propias salidas
        A        <= {MILLON_LOAD, CIENMIL_LOAD, DIEZMIL_LOAD, MIL_LOAD, CENT_LOAD, DEC_LOAD, UNIT_LOAD};
        Op_A     <= 24'd0;
        SIGN_reg <= SIGN;
    end
    else begin
        if(SH) begin
            A    <= {1'b0, A[27:1]};
            Op_A <= {A[0], Op_A[23:1]};
        end
        else begin
            A[3:0]   <= UNITN;
            A[7:4]   <= DECN;
            A[11:8]  <= CENTN;
            A[15:12] <= MILN;
            A[19:16] <= DIEZMILN;
            A[23:20] <= CIENMILN;
            A[27:24] <= MILLONN;
        end
    end
end
endmodule