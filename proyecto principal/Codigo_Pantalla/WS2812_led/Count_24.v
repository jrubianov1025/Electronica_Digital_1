module Count_24 (
    input        clk,
    input        reset,
    input        LD,
    input        DEC,
    output       Z,
    output [4:0] COUNT
);

reg [4:0] count_reg;

always @(posedge clk) begin
    if (reset) begin
        count_reg <= 5'd0;
    end
    else begin
        if (LD) begin
            count_reg <= 5'd24;
        end
        else if (DEC) begin
            if (count_reg != 5'd0)
                count_reg <= count_reg - 5'd1;
            else
                count_reg <= count_reg;
        end
        else begin
            count_reg <= count_reg;
        end
    end
end

assign Z = (count_reg == 5'd0);
assign COUNT = count_reg;

endmodule