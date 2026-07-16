module Image_4 #(
    parameter ADDR_WIDTH = 8
)(
    input  [ADDR_WIDTH-1:0] ADDR,
    output reg [23:0] RGB
);

always @(*) begin
    case (ADDR)

        // Cara de error: una X en rojo 

        8'd0:  RGB = 24'h00FF00;
        8'd9:  RGB = 24'h00FF00;
        8'd18: RGB = 24'h00FF00;
        8'd27: RGB = 24'h00FF00;
        8'd36: RGB = 24'h00FF00;
        8'd45: RGB = 24'h00FF00;
        8'd54: RGB = 24'h00FF00;
        8'd63: RGB = 24'h00FF00;

        8'd7:  RGB = 24'h00FF00;
        8'd14: RGB = 24'h00FF00;
        8'd21: RGB = 24'h00FF00;
        8'd28: RGB = 24'h00FF00;
        8'd35: RGB = 24'h00FF00;
        8'd42: RGB = 24'h00FF00;
        8'd49: RGB = 24'h00FF00;
        8'd56: RGB = 24'h00FF00;

        default: RGB = 24'h000000; // apagado

    endcase
end

endmodule