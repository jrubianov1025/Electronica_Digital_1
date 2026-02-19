module Acumulador_Multiplicador(

    input clk,
    input LD,                     
    input ADD,                    
    input SH,                     
    input signed [31:0] A_long,   

    output reg signed [31:0] ACC, 
    output ACC_LSB                
);

// bit que entra a B_long en shift
assign ACC_LSB = ACC[0];

always @(posedge clk) begin

    if(LD)
        ACC <= 32'd0;

    else if(ADD)
        ACC <= ACC + A_long;

    else if(SH)
        ACC <= ACC >>> 1;   // shift aritmético (guarda el signo)

end

endmodule
