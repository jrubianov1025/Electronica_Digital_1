module Image_3 #(
    parameter ADDR_WIDTH = 8
)(
    input  [ADDR_WIDTH-1:0] ADDR,
    output reg [23:0] RGB
);

always @(*) begin
    case (ADDR)

        // Cara triste en rojo
     

        8'd1:  RGB = 24'h00FF00;
        8'd6:  RGB = 24'h00FF00;

        8'd10: RGB = 24'h00FF00;
        8'd11: RGB = 24'h00FF00;
        8'd12: RGB = 24'h00FF00;
        8'd13: RGB = 24'h00FF00;

        8'd34: RGB = 24'h00FF00;
        8'd37: RGB = 24'h00FF00;

        8'd41: RGB = 24'h00FF00;
        8'd42: RGB = 24'h00FF00;
        8'd45: RGB = 24'h00FF00;
        8'd46: RGB = 24'h00FF00;

        8'd49: RGB = 24'h00FF00;
        8'd50: RGB = 24'h00FF00;
        8'd53: RGB = 24'h00FF00;
        8'd54: RGB = 24'h00FF00;

        default: RGB = 24'h000000; // apagado

    endcase
end

endmodule