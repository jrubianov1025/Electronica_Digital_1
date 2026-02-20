module Control_Multiplicador(
    
    input clk,
    input init,
    input Z,
    input LSB,

    output reg ADD,
    output reg SH,
    output reg DEC,
    output reg LD,
    output reg DONE

);

// DEFINICIÓN DE ESTADOS

    parameter S_START     = 3'b000;
    parameter S_CHECK     = 3'b001;
    parameter S_ADD       = 3'b010;
    parameter S_SHIFT     = 3'b011;
    parameter S_END       = 3'b100;

    reg [2:0] NEXT_STATE;
    reg [5:0] COUNT;

// MAQUINA DE ESTADOS

    always @(posedge clk) begin

        case (NEXT_STATE)
        
            S_START: begin
                if (init) NEXT_STATE = S_CHECK;
                else      NEXT_STATE = S_START;
            end
            
            S_CHECK: begin
                if (Z)    NEXT_STATE = S_END;
                if (LSB)  NEXT_STATE = S_ADD;
                else      NEXT_STATE = S_SHIFT;
                
            end

            S_ADD: begin
                NEXT_STATE = S_SHIFT;
            end

            S_SHIFT: begin
                if (Z)    NEXT_STATE = S_END;
                else      NEXT_STATE = S_CHECK;
                
            end

            S_END: begin
                COUNT = COUNT + 1;
                NEXT_STATE = (COUNT>30) ? S_START : S_END; // contador para alargar la señal DONE, esto para que el procesador le de tiempo de leer.
            end
                    
            default: NEXT_STATE = S_START;

        endcase
    end

// LOGICA DE SALIDAS

    always @(*) begin 
        case (NEXT_STATE)
        
            S_START: begin
                ADD   = 0;
                SH    = 0;
                DEC   = 0;
                LD    = 1;
                DONE  = 0;
            end
        
            S_CHECK: begin
                ADD   = 0;
                SH    = 0;
                DEC   = 0;
                LD    = 0;
                DONE  = 0;
            end     

            S_ADD: begin
                ADD   = 1;
                SH    = 0;
                DEC   = 0;
                LD    = 0;
                DONE  = 0;
            end

            S_SHIFT: begin
                ADD   = 0;
                SH    = 1;
                DEC   = 1;
                LD    = 0;
                DONE  = 0;
            end      

            S_END: begin
                ADD   = 0;
                SH    = 0;
                DEC   = 0;
                LD    = 0;
                DONE  = 1;
            end

            default: begin
                ADD   = 0;
                SH    = 0;
                DEC   = 0;
                LD    = 0;
                DONE  = 0;
            end

        endcase
    end

endmodule