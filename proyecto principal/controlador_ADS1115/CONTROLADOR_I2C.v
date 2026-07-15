module CONTROLADOR_I2C #(
    parameter CLK_FREQ_HZ = 25_000_000, 
    parameter DELAY_MS    = 500         
)(
    input wire clk,
    input wire rst,
    inout wire SDA,
    inout wire SCL,
    output wire [15:0] adc_value  
);

    wire busy;
    wire done;
    wire byte_done;
    wire ack_error;
    wire [7:0] rx_data;
    wire start;
    wire rw;
    wire [7:0] tx_byte;
    wire [7:0] num_bytes;

    ADS1115_TOP #(
        .CLK_FREQ_HZ(CLK_FREQ_HZ), 
        .DELAY_MS(DELAY_MS),       
        .I2C_ADDR(7'h48)
    ) ADS1115_TOP1 (
        .clk(clk),
        .rst(rst),
        .busy(busy),
        .done(done),
        .byte_done(byte_done),
        .ack_error(ack_error),
        .rx_data(rx_data),
        .start(start),
        .rw(rw),
        .tx_byte(tx_byte),
        .num_bytes(num_bytes),
        .adc_value(adc_value),
        .adc_valid(),     
        .error_alert()    
    );

    TOP_I2C #(
        .CLK_FREQ_HZ(CLK_FREQ_HZ), 
        .I2C_FREQ_HZ(100_000)      
    ) TOP_I2C1 (
        .clk(clk),
        .rst(rst),
        .start(start),
        .rw(rw),
        .tx_byte(tx_byte),
        .num_bytes(num_bytes),
        .rx_data(rx_data),
        .busy(busy),
        .done(done),
        .ack_error(ack_error),
        .byte_done(byte_done),
        .SDA(SDA),
        .SCL(SCL)
    );

endmodule