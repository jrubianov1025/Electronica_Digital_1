module contador_Multiplicador
(
    input   clk,    
    input   reset,  
    input   in,
  
    output  reg [15:0] out,
    output  zero 
);
    always @(posedge clk) begin, //logica secuencial en flanco de subida 

        if(reset)
            out <= 0;
        else if(in)
            out <= out + 1;
    end
    
    assign zero = (out == 16) ? 1 : 0; 

endmodule