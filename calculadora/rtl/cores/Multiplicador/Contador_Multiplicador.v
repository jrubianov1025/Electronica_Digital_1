module contador_Multiplicador
(
    input   clk,    
    input   reset,  
    input   in,
  
    output  reg [4:0] out,
    output  zero 
);
    always @(posedge clk) begin, //logica secuencial en flanco de subida 

        if(reset)
            out <= 5'd16;
        else if(in)
            out <= out - 1;
    end
    
    assign zero = (out == 0) ? 1 : 0; 

endmodule