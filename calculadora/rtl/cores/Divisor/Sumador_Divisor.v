module Sumador_Divisor#(
    parameter width = 31 
)(
    input signed [width:0]  A, // el signed le dice a verilog que es un numero en complemento a dos, toma el MSB como bit de signo.
    input signed [width:0]  DR,  

    output signed [width:0] OUT,
    output MSB

);

// Resta en complemento a dos: in1 - in2
    assign OUT = A - DR;

// Bit de signo (MSB)
    assign MSB = OUT[width];

endmodule
