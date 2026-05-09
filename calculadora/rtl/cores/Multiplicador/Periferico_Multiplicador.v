// revisar al finalizar los 4 modulos
module Periferico_multiplicador(
  input clk,
  input reset,
  input [15:0] d_in,   // dato que llega del procesador
  input cs,            // chip select (habilita el periférico)
  input [4:0] addr,    // dirección desde el bus
  input rd,            // señal de lectura
  input wr,            // señal de escritura
  output reg [31:0] d_out  // dato de salida hacia el procesador
);


//------------------------------------ regs and wires-------------------------------

reg [4:0] s;

reg signed [15:0] Multiplicando;
reg signed [15:0] Multiplicador;
reg init;

wire [31:0] Resultado;
wire DONE;

//------------------------------------ regs and wires-------------------------------

always @(*) begin//------address_decoder------------------------------

    if(cs) begin

        case(addr)

            5'h04: s = 5'b00001; // Multiplicando
            5'h08: s = 5'b00010; // Multiplicador
            5'h0C: s = 5'b00100; // init
            5'h10: s = 5'b01000; // Resultado
            5'h14: s = 5'b10000; // DONE

            default: s = 5'b00000;

        endcase

    end
    else
        s = 5'b00000;

end//------------------address_decoder--------------------------------




always @(posedge clk) begin//-------------------- escritura de registros 


    if(reset) begin

        Multiplicando <= 16'd0;
        Multiplicador <= 16'd0;
        init          <= 1'b0;

    end
    else begin

        if(cs && wr) begin

            Multiplicando <= s[0] ? d_in      : Multiplicando;
            Multiplicador <= s[1] ? d_in      : Multiplicador;
            init          <= s[2] ? d_in[0]   : 1'b0;

        end
        else begin
            init <= 1'b0;
        end

    end


end//------------------------------------------- escritura de registros


always @(posedge clk) begin//-----------------------mux_4 :  multiplexa salidas del periferico

    if(reset)
        d_out <= 32'd0;

    else if(cs && rd) begin

        case(s)

            5'b01000: d_out <= Resultado;
            5'b10000: d_out <= {31'b0, DONE};

            default:  d_out <= 32'd0;

        endcase

    end

end//-----------------------------------------------mux_4


TOP_Multiplicador u_TOP_Multiplicador(

    .reset(reset),
    .clk(clk),
    .init(init),

    .Multiplicando(Multiplicando),
    .Multiplicador(Multiplicador),

    .Resultado(Resultado),
    .DONE(DONE)

);

  
endmodule