module A_long_Multiplicador(

    input clk,
    input LD,
    input signed [15:0] A,
    
    output reg signed [31:0] A_long
);

    always @(posedge clk) begin
        if(LD)
            A_long <= {{16{A[15]}}, A};
    end

endmodule
