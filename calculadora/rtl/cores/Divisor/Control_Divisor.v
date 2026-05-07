module Control_Divisor(
 
input clk,
input init,
input Z,
input MSB,
input corregir,

output reg LD,
output reg SH,
output reg DEC,
output reg DV0,
output reg DONE
);
 
// DEFINICIÓN DE ESTADOS
parameter S_START   = 3'b000;
parameter S_SHIFT   = 3'b001;
parameter S_ZERO    = 3'b010;
parameter S_ONE     = 3'b011;
parameter S_CHECK   = 3'b100;
parameter S_CORRECT = 3'b101;
parameter S_END     = 3'b110;
 
reg [2:0] NEXT_STATE;
reg [5:0] COUNT;
 
// MAQUINA DE ESTADOS
always @(posedge clk) begin
    case (NEXT_STATE)
 
        S_START: begin
            if (init) NEXT_STATE = S_SHIFT;
            else      NEXT_STATE = S_START;
        end
 
        S_SHIFT: begin
            NEXT_STATE = S_CHECK;

        end
 
        S_ZERO: begin
            NEXT_STATE = S_SHIFT;
        end
 
        S_ONE: begin
            NEXT_STATE = S_SHIFT;
        end
 
        S_CHECK: begin
            if      (MSB & !corregir)   NEXT_STATE = S_ZERO;
            else if (!MSB & !corregir)  NEXT_STATE = S_ONE;
            else if (Z & corregir)      NEXT_STATE = S_CORRECT;
            else if (Z & !corregir)     NEXT_STATE = S_END;
        end
 
        S_CORRECT: begin
            NEXT_STATE = S_END;
        end
 
        S_END: begin
            COUNT = COUNT + 1;
            NEXT_STATE = (COUNT > 30) ? S_START : S_END;
        end
 
        default: NEXT_STATE = S_START;
 
    endcase
end
 
// LOGICA DE SALIDAS
always @(*) begin
    case (NEXT_STATE)
 
        S_START: begin
            LD   = 1;
            SH   = 0;
            DEC  = 0;
            DV0  = 0;
            DONE = 0;
        end
 
        S_SHIFT: begin
            LD   = 0;
            SH   = 1;
            DEC  = 1;
            DV0  = 0;
            DONE = 0;
        end
 
        S_ZERO: begin
            LD   = 0; //verificar si 1
            SH   = 0;
            DEC  = 0;
            DV0  = 0;
            DONE = 0;
        end
 
        S_ONE: begin
            LD   = 1;
            SH   = 0;
            DEC  = 0;
            DV0  = 1;
            DONE = 0;
        end
 
        S_CHECK: begin
            LD   = 0;
            SH   = 0;
            DEC  = 0;
            DV0  = 0;
            DONE = 0;
        end
 
        S_CORRECT: begin
            LD   = 1;
            SH   = 0;
            DEC  = 0;
            DV0  = 0;
            DONE = 0;
        end
 
        S_END: begin
            LD   = 0;
            SH   = 0;
            DEC  = 0;
            DV0  = 0;
            DONE = 1;
        end
 
        default: begin
            LD   = 0;
            SH   = 0;
            DEC  = 0;
            DV0  = 0;
            DONE = 0;
        end
 
    endcase
end
 
endmodule
