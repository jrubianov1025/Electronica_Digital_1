module CONTADOR_BITS(
    input  wire clk,
    input  wire rst,
    input  wire load,
    input  wire dec,

    output wire z_bits,
    output wire [2:0] value
);

    reg [2:0] count;

    always @(posedge clk or posedge rst) begin

        if (rst)
            count <= 3'd0;

        else if (load)
            count <= 3'd7;

        else if (dec && (count != 3'd0))
            count <= count - 3'd1;
    end

    assign z_bits = (count == 3'd0);
    assign value  = count;

endmodule