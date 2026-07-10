module CONTADOR_BYTES(
    input  wire clk,
    input  wire rst,
    input  wire load,
    input  wire dec,
    input  wire [7:0] num_bytes,

    output wire z_bytes,
    output wire [7:0] value
);
    reg [7:0] count;

    always @(posedge clk or posedge rst) begin
        if (rst)
            count <= 8'd0;

        else if (load)
            count <= num_bytes;

        else if (dec && (count != 8'd0))
            count <= count - 8'd1;
    end

    assign z_bytes = (count == 8'd0);
    assign value   = count;
    
endmodule