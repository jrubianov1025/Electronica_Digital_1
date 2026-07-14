module Image_0 #(
    parameter ADDR_WIDTH = 8
)(
    input  [ADDR_WIDTH-1:0] ADDR,
    output reg [23:0] RGB
);

always @(*) begin
    case (ADDR)

        // Imagen 0: todos los LEDs en azul celeste
        // Azul celeste = 24'hFF00FF

        8'd0:  RGB = 24'hFF00FF;
        8'd1:  RGB = 24'hFF00FF;
        8'd2:  RGB = 24'hFF00FF;
        8'd3:  RGB = 24'hFF00FF;
        8'd4:  RGB = 24'hFF00FF;
        8'd5:  RGB = 24'hFF00FF;
        8'd6:  RGB = 24'hFF00FF;
        8'd7:  RGB = 24'hFF00FF;

        8'd8:  RGB = 24'hFF00FF;
        8'd9:  RGB = 24'hFF00FF;
        8'd10: RGB = 24'hFF00FF;
        8'd11: RGB = 24'hFF00FF;
        8'd12: RGB = 24'hFF00FF;
        8'd13: RGB = 24'hFF00FF;
        8'd14: RGB = 24'hFF00FF;
        8'd15: RGB = 24'hFF00FF;

        8'd16: RGB = 24'hFF00FF;
        8'd17: RGB = 24'hFF00FF;
        8'd18: RGB = 24'hFF00FF;
        8'd19: RGB = 24'hFF00FF;
        8'd20: RGB = 24'hFF00FF;
        8'd21: RGB = 24'hFF00FF;
        8'd22: RGB = 24'hFF00FF;
        8'd23: RGB = 24'hFF00FF;

        8'd24: RGB = 24'hFF00FF;
        8'd25: RGB = 24'hFF00FF;
        8'd26: RGB = 24'hFF00FF;
        8'd27: RGB = 24'hFF00FF;
        8'd28: RGB = 24'hFF00FF;
        8'd29: RGB = 24'hFF00FF;
        8'd30: RGB = 24'hFF00FF;
        8'd31: RGB = 24'hFF00FF;

        8'd32: RGB = 24'hFF00FF;
        8'd33: RGB = 24'hFF00FF;
        8'd34: RGB = 24'hFF00FF;
        8'd35: RGB = 24'hFF00FF;
        8'd36: RGB = 24'hFF00FF;
        8'd37: RGB = 24'hFF00FF;
        8'd38: RGB = 24'hFF00FF;
        8'd39: RGB = 24'hFF00FF;

        8'd40: RGB = 24'hFF00FF;
        8'd41: RGB = 24'hFF00FF;
        8'd42: RGB = 24'hFF00FF;
        8'd43: RGB = 24'hFF00FF;
        8'd44: RGB = 24'hFF00FF;
        8'd45: RGB = 24'hFF00FF;
        8'd46: RGB = 24'hFF00FF;
        8'd47: RGB = 24'hFF00FF;

        8'd48: RGB = 24'hFF00FF;
        8'd49: RGB = 24'hFF00FF;
        8'd50: RGB = 24'hFF00FF;
        8'd51: RGB = 24'hFF00FF;
        8'd52: RGB = 24'hFF00FF;
        8'd53: RGB = 24'hFF00FF;
        8'd54: RGB = 24'hFF00FF;
        8'd55: RGB = 24'hFF00FF;

        8'd56: RGB = 24'hFF00FF;
        8'd57: RGB = 24'hFF00FF;
        8'd58: RGB = 24'hFF00FF;
        8'd59: RGB = 24'hFF00FF;
        8'd60: RGB = 24'hFF00FF;
        8'd61: RGB = 24'hFF00FF;
        8'd62: RGB = 24'hFF00FF;
        8'd63: RGB = 24'hFF00FF;

        default: RGB = 24'h000000;

    endcase
end

endmodule
