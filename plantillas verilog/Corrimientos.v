// plantillas para corrimientos de registro, tanto izquierda como derecha 

module corrimiento_izquierda_nombre#(
    parameter width = 10 //define el tamaño de los registros, se puede cambiar en el main o aqui en el modulo. Sirve para instanciar multiples veces este modulo.
)(
    input clk; // relog del procesador.
    input [width:0] Registro1;
    input load; // señal para cargar la informacion del registro.
    input shift; // señal para efectuar el corrimiento

    output reg [/*el doble de el width*/ :0] Registro2; 
);

    always @(negedge clk)
        if(load)
            Registro2 = Registro1 ;
        else
            begin
                if(shift) Registro2 = Registro2 << 1 ; // ese simbolo es para correr n veces hacia la izquierda
                else Registro2 = Registro2;
            end
endmodule



module corrimiento_derecha_nombre#(
    parameter width = 10 //define el tamaño de los registros, se puede cambiar en el main o aqui en el modulo. Sirve para instanciar multiples veces este modulo.
)(
    input clk; // relog del procesador.
    input [width:0] Registro1;
    input load; // señal para cargar la informacion del registro.
    input shift; // señal para efectuar el corrimiento

    output reg [/*el doble de el width*/ :0] Registro2; 
);


    always @(negedge clk)
        if(load)
            Registro2 = Registro1 ;
        else
            begin
                if(shift) Registro2 = Registro2 >> 1 ; // ese simbolo es para correr n veces hacia la derecha
                else Registro2 = Registro2;
            end
endmodule
