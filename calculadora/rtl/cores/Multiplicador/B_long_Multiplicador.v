module B_long_Multiplicador(

    input clk,
    input LD,
    input SH,
    input ACC_LSB,   
    input signed [15:0] B,
 
    output reg signed [31:0] B_long,
    output LSB
);

    assign LSB = B_long[0];

    always @(posedge clk) begin
        if(LD)
            B_long <= {{16{B[15]}}, B};

        else if(SH)
        
        B_long <= {ACC_LSB, B_long[31:1]};
    end

endmodule





