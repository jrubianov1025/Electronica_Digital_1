module Count_Addr #(
    parameter ADDR_WIDTH = 8
)(
    input clk,
    input reset,
    input RST,
    input INC,
    output reg [ADDR_WIDTH-1:0] ADDR
);

always @(posedge clk) begin
    if (reset) begin
        ADDR <= 0;
    end
    else begin
        if (RST) begin
            ADDR <= 0;
        end
        else if (INC) begin
            ADDR <= ADDR + 1'b1;
        end
        else begin
            ADDR <= ADDR;
        end
    end
end

endmodule
