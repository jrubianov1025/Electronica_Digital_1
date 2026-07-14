module I2C_CLOCK_GENERATOR #(
    parameter CLK_FREQ_HZ = 25_000_000,
    parameter I2C_FREQ_HZ = 100_000
)(
    input  wire clk,
    input  wire rst,
    input  wire enable,

    output reg  scl,
    output reg  scl_rise,
    output reg  scl_fall
);

    // Cálculo del número de ciclos de reloj por cada semiciclo I2C
    localparam HALF_PERIOD = CLK_FREQ_HZ / (2 * I2C_FREQ_HZ);    
    
    // Calcula automáticamente los bits necesarios para el contador
    localparam COUNTER_WIDTH = $clog2(HALF_PERIOD);

    reg [COUNTER_WIDTH-1:0] counter;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter  <= 0;
            scl      <= 1'b1; 
            scl_rise <= 1'b0;
            scl_fall <= 1'b0;
            
        end else if (!enable) begin
            counter  <= 0;
            scl      <= 1'b1; 
            scl_rise <= 1'b0;
            scl_fall <= 1'b0;
            
        end else if (counter == HALF_PERIOD - 1) begin
            counter  <= 0;
            scl      <= ~scl;     
            scl_rise <= ~scl;     
            scl_fall <= scl;      
            
        end else begin
            counter  <= counter + 1'b1;
            scl_rise <= 1'b0;
            scl_fall <= 1'b0;
        end
    end

endmodule