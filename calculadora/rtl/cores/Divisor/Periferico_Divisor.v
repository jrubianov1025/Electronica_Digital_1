module Periferico_Divisor (

    input         clk,
    input         reset,

    input  [31:0] d_in,   // dato que llega del procesador
    input         cs,     // chip select
    input  [4:0]  addr,   // dirección desde el bus
    input         rd,     // señal de lectura
    input         wr,     // señal de escritura

    output reg [31:0] d_out

);


// REGISTROS Y WIRES INTERNOS

reg [5:0] s;

reg signed [23:0] Dividendo;
reg signed [23:0] DR;

reg init;

wire signed [31:0] Resultado;
wire signed [31:0] Residuo;

wire DONE;

// DECODIFICADOR DE DIRECCIONES

always @(*) begin

    if (cs) begin
    
        case (addr)
    
            5'h04: s = 6'b000001; // Dividendo
            5'h08: s = 6'b000010; // DR (Divisor)
            5'h0C: s = 6'b000100; // init
            5'h10: s = 6'b001000; // Resultado (cociente)
            5'h14: s = 6'b010000; // Residuo
            5'h18: s = 6'b100000; // DONE
            default: s = 6'b000000;
        endcase
    
    end else
        s = 6'b000000;
end

// ESCRITURA DE REGISTROS

always @(posedge clk) begin
    
    if (reset) begin
        Dividendo <= 32'd0;
        DR        <= 32'd0;
        init      <= 1'b0;
    
    end else if (cs && wr) begin
        Dividendo <= s[0] ? d_in    : Dividendo;
        DR        <= s[1] ? d_in    : DR;
        init      <= s[2] ? d_in[0] : 1'b0;
    
    end
end


// LECTURA DE REGISTROS

always @(posedge clk) begin
    
    if (reset)
        d_out <= 32'd0;
    
    else if (cs && rd) begin
    
        case (s)
    
            6'b001000: d_out <= Resultado;
            6'b010000: d_out <= Residuo;
            6'b100000: d_out <= {31'b0, DONE};
            default:   d_out <= 32'd0;
    
        endcase
    end
end

// INSTANCIA DEL TOP DEL DIVISOR

Divisor_Top #(.width(31)) u_Divisor_Top (
    .clk       (clk),
    .init      (init),
    .Dividendo (Dividendo),
    .DR        (DR),
    .Resultado (Resultado),
    .Residuo   (Residuo),
    .DONE      (DONE)
);

endmodule