module LSR_RGB (
    input             clk,
    input             reset,
    input             LD,
    input             SH,
    input      [23:0] RGB,
    output     [23:0] RGB_OUT,
    output            RGB_MSB
);

reg [23:0] RGB_reg;

always @(posedge clk) begin
    if (reset) begin
        RGB_reg <= 24'b0;
    end
    else begin
        if (LD) begin
            RGB_reg <= RGB;
        end
        else if (SH) begin
            RGB_reg <= RGB_reg << 1;
        end
        else begin
            RGB_reg <= RGB_reg;
        end
    end
end

assign RGB_OUT = RGB_reg;
assign RGB_MSB = RGB_reg[23];

endmodule