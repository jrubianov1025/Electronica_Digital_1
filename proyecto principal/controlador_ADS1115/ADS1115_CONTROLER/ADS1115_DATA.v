module ADS1115_DATA (
    input wire clk,
    input wire rst,
    input wire byte_done,
    input wire Ld_count_byte,  
    input wire capture_msb,    // captura rx_data como byte alto
    input wire capture_lsb,    // captura rx_data como byte bajo (+ adc_valid)
    input wire error_set,      
    input wire [7:0] rx_data,

    output reg adc_valid,
    output reg error_alert,
    output reg [1:0] count_byte,
    output reg [15:0] adc_value
);

    reg [7:0] msb_byte_reg;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            count_byte   <= 2'd0;
            msb_byte_reg <= 8'h00;
            adc_value    <= 16'h0000;
            adc_valid    <= 1'b0;
            error_alert  <= 1'b0;

        end else begin
            adc_valid <= 1'b0;

            if (capture_msb) begin
                msb_byte_reg <= rx_data;
            end

            if (capture_lsb) begin
                adc_value <= {msb_byte_reg, rx_data};
                adc_valid <= 1'b1;
            end

            if (error_set) begin
                error_alert <= 1'b1;
            end

            if (Ld_count_byte) begin
                count_byte <= 2'd0;
            end else if (byte_done) begin
                count_byte <= count_byte + 2'd1;
            end
        end
    end

endmodule