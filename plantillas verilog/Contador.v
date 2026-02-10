// plantillas modulos contador logica en flanco de subida y de bajada 

module contador_nombre#(
    parameter width = 5 //define el tamaño de los registros, se puede cambiar en el main o aqui en el modulo. Sirve para instanciar multiples veces este modulo.
)(
    input   clk,    // relog del procesador.
    input   reset,  // señal para resetear el contador.
    input   in,
  
    output  reg [width:0] out,
    output  zero // señal de salida para la maquina de control indicando el punto del contador requerido.
);

    always @(negedge clk) begin // logica secuencial en flanco de bajada 

        if(reset)
            out <= 0;
        else if(in)
            out <= out + 1;
    end
    
    assign zero = (out == 0) ? 1 : 0; // Señal de bandera: vale 1 cuando la salida `out` es cero, de lo contrario vale 0

endmodule

module contador_nombre#(
    parameter width = 5 
)(
    input   clk,    
    input   reset,  
    input   in,
  
    output  reg [width:0] out,
    output  zero 
);
    always @(posedge clk) begin, //logica secuencial en flanco de subida 

        if(reset)
            out <= 0;
        else if(in)
            out <= out + 1;
    end
    
    assign zero = (out == 0) ? 1 : 0; 

endmodule