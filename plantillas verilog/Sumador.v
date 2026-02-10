//plantilla modulo sumador en complemento a dos 

module sumador_nombre#(
    parameter width = 10 //define el tamaño de los registros, se puede cambiar en el main o aqui en el modulo. Sirve para instanciar multiples veces este modulo.
)(
    input signed [width:0]  in1, // el signed le dice a verilog que es un numero en complemento a dos, toma el MSB como bit de signo.
    input signed [width:0]  in2,  

    output signed [width:0] OUT
    output MSB,

);

// Resta en complemento a dos: in1 - in2
    assign OUT = in1 - in2;

// Bit de signo (MSB)
    assign MSB = OUT[width];

endmodule