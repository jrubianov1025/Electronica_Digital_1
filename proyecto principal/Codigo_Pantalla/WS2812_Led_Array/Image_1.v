module Image_1 #(
    parameter ADDR_WIDTH = 8
)(
    input  [ADDR_WIDTH-1:0] ADDR,
    output reg [23:0] RGB
);

always @(*) begin
    case (ADDR)

        // Carita feliz en verde clarito
        // LEDs encendidos:
        // 10, 11, 12, 13, 17, 22, 34, 37,
        // 41, 42, 45, 46, 49, 50, 53, 54

        8'd10: RGB = 24'hC75000;
        8'd11: RGB = 24'hC75000;
        8'd12: RGB = 24'hC75000;
       
        8'd13: RGB = 24'hC75000;
        8'd17: RGB = 24'hC75000;
        8'd22: RGB = 24'hC75000;

        8'd34: RGB = 24'hC75000;
        8'd37: RGB = 24'hC75000;

        8'd41: RGB = 24'hC75000;
        8'd42: RGB = 24'hC75000;
        8'd45: RGB = 24'hC75000;
        8'd46: RGB = 24'hC75000;

        8'd49: RGB = 24'hC75000;
        8'd50: RGB = 24'hC75000;
        8'd53: RGB = 24'hC75000;
        8'd54: RGB = 24'hC75000;

        default: RGB = 24'h000000; // apagado

    endcase
end

endmodule
