module count_out (
    input  wire        clk,
    input  wire        reset,
    input  wire        RST,
    input  wire        INC,
    output reg  [10:0] count_out
);

    always @(posedge clk) begin
        if (reset) begin
            count_out <= 11'd0;
        end else begin
            if (RST) begin
                count_out <= 11'd0;
            end else begin
                if (INC) begin
                    count_out <= count_out + 11'd1;
                end else begin
                    count_out <= count_out;
                end
            end
        end
    end

endmodule