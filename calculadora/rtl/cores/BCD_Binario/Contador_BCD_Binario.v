module CONTADOR_BCDB(
    input CLK,
    input LD,
    input DEC,

    output reg Z
);

reg [5:0] count;

always @(posedge CLK) begin

    if(LD) begin
        count <= 6'd23;
        Z <= 0;
    end

    else if(DEC && count != 0)
        count <= count - 1;

    else if(count == 0)
        Z <= 1;

end

endmodule