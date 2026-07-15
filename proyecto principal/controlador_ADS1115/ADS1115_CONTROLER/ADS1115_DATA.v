module ADS1115_DATA (
    input  wire        clk,
    input  wire        rst,
    input  wire        byte_done,
    input  wire [7:0]  rx_data,
    input  wire        idx_ld,     
    input  wire        cap_msb,    // capturar rx_data como MSB
    input  wire        cap_lsb,    // capturar rx_data como LSB (+ adc_valid)
    input  wire        err_set,    

    output reg adc_valid,
    output reg error_alert,
    output reg [1:0] byte_idx,
    output reg [15:0] adc_value
);

    reg [7:0] adc_msb;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            byte_idx    <= 2'd0;
            adc_msb     <= 8'h00;
            adc_value   <= 16'h0000;
            adc_valid   <= 1'b0;
            error_alert <= 1'b0;

        end else begin
            adc_valid <= 1'b0;

            if (cap_msb) begin
                adc_msb <= rx_data;
            end

            if (cap_lsb) begin
                adc_value <= {adc_msb, rx_data};
                adc_valid <= 1'b1;
            end

            if (err_set) begin
                error_alert <= 1'b1;
            end

            if (idx_ld) begin
                byte_idx <= 2'd0;
            end else if (byte_done) begin
                byte_idx <= byte_idx + 2'd1;
            end
        end
    end

endmodule