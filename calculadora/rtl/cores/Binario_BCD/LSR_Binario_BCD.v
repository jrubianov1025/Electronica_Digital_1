module LSR_BBCD(

    input CLK,
    input SH,
    input LD,

    input signed [23:0] Op_A_in,

 // Entradas desde los sumadores (nuevos valores de cada nibble)

    input [3:0] UNITN,
    input [3:0] DECN,
    input [3:0] CENTN,
    input [3:0] MILN,
    input [3:0] DIEZMILN,
    input [3:0] CIENMILN,
    input [3:0] MILLONN,

    output reg [3:0] SIGN,

  // Salidas: nibbles actuales de A
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

assign UNIT    = A[3:0];    // bits 3 a 0
assign DEC     = A[7:4];    // bits 7 a 4
assign CENT    = A[11:8];   // bits 11 a 8
assign MIL     = A[15:12];  // bits 15 a 12
assign DIEZMIL = A[19:16];  // bits 19 a 16
assign CIENMIL = A[23:20];  // bits 23 a 20
assign MILLON  = A[27:24];  // bits 27 a 24

always @(posedge CLK) begin

    if(LD) begin

        A <= 28'd0;
        // Si el bit más significativo es 1 el número es negativo (complemento a 2)
        if(Op_A_in[23]) begin
            SIGN <= 4'hA;
            Op_A <= ~Op_A_in + 1'b1;
        end
        else begin
            SIGN <= 4'hF;
            Op_A <= Op_A_in;
        end
    end

    else begin

        if(SH) begin

            A <= {A[26:0], Op_A[23]};
            Op_A <= {Op_A[22:0], 1'b0};

        end

        else begin

            A[3:0] <= UNITN;
            A[7:4] <= DECN;
            A[11:8] <= CENTN;
            A[15:12] <= MILN;
            A[19:16] <= DIEZMILN;
            A[23:20] <= CIENMILN;
            A[27:24] <= MILLONN;

        end
    end
end

endmodule