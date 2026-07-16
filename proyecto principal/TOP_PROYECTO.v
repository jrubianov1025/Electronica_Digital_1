module TOP_PROYECTO #(
    parameter CLK_FREQ_HZ = 25_000_000,
    parameter DELAY_MS    = 500,

    parameter ADDR_WIDTH  = 8,
    parameter N_LEDS      = 64,

    // Umbrales de humedad — SENSOR RESISTIVO (activo)
    // Datos medidos: seco/aire ~26395-26400 | tierra humeda ~4000-6000

    parameter [15:0] UMBRAL_1 = 16'd6000,   // frontera neutral(encharcado) <-> feliz
    parameter [15:0] UMBRAL_2 = 16'd15000,  // frontera feliz <-> seria
    parameter [15:0] UMBRAL_3 = 16'd24000   // frontera seria <-> triste (muy seco)


    // Umbrales de humedad — SENSOR CAPACITIVO (comentado, referencia)
    // Datos medidos: seco/aire ~21550-21600 | tierra humeda ~7900 | agua ~10500

    // parameter [15:0] UMBRAL_1 = 16'd8000,   // frontera neutral(encharcado) <-> feliz
    // parameter [15:0] UMBRAL_2 = 16'd14000,  // frontera feliz <-> seria
    // parameter [15:0] UMBRAL_3 = 16'd19000   // frontera seria <-> triste (muy seco)
)(
)(
    input  wire clk,
    input  wire reset,

    inout  wire SDA,
    inout  wire SCL,

    output wire DOUT,
    output wire DONE_M
);

wire [15:0] adc_value;
wire        adc_valid;
wire        adc_error;   // <- error_alert del ADS1115

wire       busy;
wire       done;
wire       byte_done;
wire       ack_error;
wire [7:0] rx_data;
wire       start;
wire       rw;
wire [7:0] tx_byte;
wire [7:0] num_bytes;

ADS1115_TOP #(
        .CLK_FREQ_HZ(CLK_FREQ_HZ),
        .DELAY_MS(DELAY_MS),
        .I2C_ADDR(7'h48)
    ) mi_controlador (
        .clk(clk),
        .rst(reset),
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
        .adc_valid(adc_valid),
        .error_alert(adc_error)
    );

TOP_I2C #(
        .CLK_FREQ_HZ(CLK_FREQ_HZ),
        .I2C_FREQ_HZ(100_000)
    ) mi_i2c_driver (
        .clk(clk),
        .rst(reset),
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

Pantalla_I2C #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .N_LEDS(N_LEDS),
        .UMBRAL_1(UMBRAL_1),
        .UMBRAL_2(UMBRAL_2),
        .UMBRAL_3(UMBRAL_3)
    ) mi_pantalla (
        .clk(clk),
        .reset(reset),
        .adc_value(adc_value),
        .adc_valid(adc_valid),
        .adc_error(adc_error),
        .DOUT(DOUT),
        .DONE_M(DONE_M)
    );

endmodule