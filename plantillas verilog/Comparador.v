// plantilla modulo comparador 

module comparador_nombre#(
    parameter width = 10 //define el tamaño de los registros, se puede cambiar en el main o aqui en el modulo. Sirve para instanciar multiples veces este modulo.
)(
    input [width:0]  in1,
    input [width:0]  in2,  

    output reg       OUT
);

    always @(*) begin // lógica combinacional

        if(in1 == in2)
            OUT = 1;
        else
            OUT = 0;
    end

endmodule