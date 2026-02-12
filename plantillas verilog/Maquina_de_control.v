  // plantilla maquinas de control
  
  module CONTROL_nombre(
    
    input clk, // relog del procesador.
    input in1, // entrada cualquiera, se usa en algun momento para controlar algo.
    input in2, // entrada cualquiera. 
    input INIT,// entrada que da inicio del programa.
   
 // salidas usadas comunmente para indicarle a los diferentes modulos que funcionen.
    output reg out1,
    output reg out2,
    output reg out3,
    output reg out4,
    output reg out5,
    output reg DONE
  );    


// DEFINICIÓN DE ESTADOS, va acorde al diagrama de estados.
    parameter S_START     = 3'b000;
    parameter S_STATE_1   = 3'b001;
    parameter S_STATE_2   = 3'b010;
    parameter S_STATE_3   = 3'b011;
    parameter S_STATE_4   = 3'b100;
    parameter S_STATE_5   = 3'b101;
    parameter S_STATE_6   = 3'b110;
    parameter S_END       = 3'b111;
    
    reg [2:0] NEXT_STATE;
    reg [5:0] count; // alargar la señal DONE lo suficiente para que el procesador la lea.


    // MAQUINA DE ESTADOS - REGISTRO DE ESTADO
    // aqui se define la secuencia, bajo que señales y condiciones se pasa de un estado a otro, 

    always @(posedge CLK) begin //logica secuencial en flanco de subida 

        case (NEXT_STATE)
               
            S_START: begin
                if (INIT)  NEXT_STATE = S_STATE_1;
                else       NEXT_STATE = S_START;
                count = 0;
            end

            S_STATE_1: begin
                NEXT_STATE = S_STATE_2;
            end

            S_STATE_2: begin
                NEXT_STATE = S_STATE_3;
            end

            S_STATE_3: begin
                if (in1)        NEXT_STATE = S_STATE_4;
                else if (!in1)  NEXT_STATE = S_STATE_5;
            end

            S_STATE_4: begin
                NEXT_STATE = S_STATE_6;

            end
            S_STATE_5: begin
                NEXT_STATE = S_STATE_6;
            end
            
            S_STATE_6: begin
                if (!in2)        NEXT_STATE = S_STATE_2;
                else if (in2)    NEXT_STATE = S_END1;
            end
            
            S_END1: begin
              count = count + 1;
              NEXT_STATE = (count>30) ? S_START : S_END1; // contador para alargar la señal DONE, esto para que el procesador le de tiempo de leer.
            end

            default: NEXT_STATE = S_START;
        endcase
    end

    // LÓGICA DE SALIDAS Se realiza directamente en base al diagrama de estados.

    always @(*) begin // lógica combinacional


      case (NEXT_STATE)

        S_START: begin
          DONE   = 0;
          out1   = 0;
          out2   = 0;  
          out3   = 0;
          out4   = 1;
          out5   = 0;
        end

        S_STATE_1: begin
          DONE   = 0;
          out1   = 0;
          out2   = 0;  
          out3   = 1;
          out4   = 0;
          out5   = 0;
        end
/*
        .
        .
        .
        .
*/
// tambien se puede escribir dentro de los estados solo las variables que cambian con respecto al default, sin embargo es mejor escribir todas para evitar posibles bugs.

        S_STATE_1: begin 
          out3   = 1;
        end

// dejar al final siempre un default, 
        default: begin
          DONE   = 0;
          LD_TMP = 0;
          R0     = 0;  
          SH     = 0;
          LD     = 0;
          LDA2   = 0;
        end

      endcase
    end

endmodule