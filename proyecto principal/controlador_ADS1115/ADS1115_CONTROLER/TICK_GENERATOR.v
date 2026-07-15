module TICK_GENERATOR #(
    parameter CLK_FREQ_HZ = 25_000_000,
    parameter DELAY_MS    = 500
)(
    input  wire clk,
    input  wire rst,
    input  wire enable,
    
    output reg  tick
);

    localparam integer TICK_COUNT    = (CLK_FREQ_HZ / 1000) * DELAY_MS;
    localparam integer COUNTER_WIDTH = $clog2(TICK_COUNT);

    reg [COUNTER_WIDTH-1:0] counter;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter <= 0;
            tick    <= 1'b0;
        end else if (!enable) begin
            counter <= 0;          
            tick    <= 1'b0;
        end else if (counter == TICK_COUNT - 1) begin
            counter <= 0;
            tick    <= 1'b1;       
        end else begin
            counter <= counter + 1'b1;
            tick    <= 1'b0;
        end
    end

endmodule