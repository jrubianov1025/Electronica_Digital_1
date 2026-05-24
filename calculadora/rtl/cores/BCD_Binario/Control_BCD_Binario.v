module CONTROL_BCDB(
    input CLK,
    input MSB,
    input Z,
    input INIT,

    output reg LD,
    output reg DEC,
    output reg SH,
    output reg SUB3,
    output reg DONE
);

    // DEFINICIÓN DE ESTADOS
parameter S_START     = 3'b000;
parameter S_SUB       = 3'b001;
parameter S_SHIFT_DEC = 3'b010;
parameter S_CHECK     = 3'b011;
parameter S_END1      = 3'b100;

reg [2:0] NEXT_STATE;
reg [5:0] count;

always @(posedge CLK) begin
    
    case(NEXT_STATE)
        
        S_START: begin
            count <= 0;
            if(INIT) NEXT_STATE <= S_SHIFT_DEC; 
            else     NEXT_STATE <= S_START;
        end
        
        S_CHECK: begin
            if(Z)               NEXT_STATE <= S_END1;
            else if(!MSB && !Z) NEXT_STATE <= S_SHIFT_DEC;
            else if(MSB && !Z)  NEXT_STATE <= S_SUB;
            else                NEXT_STATE <= S_CHECK;
        end
        
        S_SUB:
            NEXT_STATE <= S_SHIFT_DEC;
        
        S_SHIFT_DEC:
            NEXT_STATE <= S_CHECK;
        
        S_END1: begin
            count <= count + 1;
            if(count > 30) NEXT_STATE <= S_START;
            else           NEXT_STATE <= S_END1;
        end
        
        default:
            NEXT_STATE <= S_START;
    endcase
end

// Lógica de salidas — sin cambios

    // LÓGICA DE SALIDAS 

always @(*) begin

    case(NEXT_STATE)

        S_START: begin
            DONE = 0;
            SH   = 0;
            DEC  = 0;
            LD   = 1;
            SUB3 = 0;
        end

        S_SUB: begin
            DONE = 0;
            SH   = 0;
            DEC  = 0;
            LD   = 0;
            SUB3 = 1;
        end

        S_SHIFT_DEC: begin
            DONE = 0;
            SH   = 1;
            DEC  = 1;
            LD   = 0;
            SUB3 = 0;
        end

        S_CHECK: begin
            DONE = 0;
            SH   = 0;
            DEC  = 0;
            LD   = 0;
            SUB3 = 0;
        end

        S_END1: begin
            DONE = 1;
            SH   = 0;
            DEC  = 0;
            LD   = 0;
            SUB3 = 0;
        end

        default: begin
            DONE = 0;
            SH   = 0;
            LD   = 0;
            DEC  = 0;
            SUB3 = 0;
        end

    endcase
end

endmodule