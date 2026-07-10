module SHIFT_REGISTER(
    input  wire       clk,
    input  wire       rst,
    input  wire       load,
    input  wire       shift_tx,
    input  wire       shift_rx,
    input  wire       store_rx,
    input  wire [7:0] tx_byte,
    input  wire       sda_in,

    output wire       tx_bit,
    output wire [7:0] rx_data
);

    reg [7:0] shift_reg;
    reg [7:0] rx_reg;

    // logica del registro de desplazamiento (shift_reg)
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            shift_reg <= 8'd0;

        end else if (load) begin
            shift_reg <= tx_byte;

        end else if (shift_tx) begin
            shift_reg <= {shift_reg[6:0], 1'b0};     

        end else if (shift_rx) begin
            shift_reg <= {shift_reg[6:0], sda_in};            
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            rx_reg <= 8'd0;

        end else if (store_rx) begin
            rx_reg <= shift_reg;
        end
    end

    assign tx_bit  = shift_reg[7];
    assign rx_data = rx_reg;

endmodule