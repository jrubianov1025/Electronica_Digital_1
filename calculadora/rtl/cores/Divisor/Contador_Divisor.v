module Contador_Divisor(
    input   clk,    
    input   LD,  
    input   DEC,
  
    output  reg [5:0] out,
    output  Z 
);
    always @(posedge clk) begin, 

        if(LD)
            out <= 6'd32;
        else if(DEC)
            out <= out - 1;
    end
    
    assign Z = (out == 0) ? 1 : 0; 

endmodule
