/*       >>> CONFIGURACIÓN DEL ADS1115 <
       Bit [15]     OS: Iniciar conversión. (1 = Inicia lectura en modo single-shot).
       Bits [14:12] MUX: Multiplexor analógico 
                      - 100 = AIN0 vs GND                 <-- CONFIGURACIÓN ACTUAL
                      - 101 = AIN1 vs GND
                      - 110 = AIN2 vs GND
                      - 111 = AIN3 vs GND
                      - 000 = Diferencial AIN0 vs AIN1

       Bits [11:9]  PGA: Ganancia programable (Rango de voltaje máximo).
                      - 000 = ±6.144V
                      - 001 = ±4.096V                     <-- CONFIGURACIÓN ACTUAL
                      - 010 = ±2.048V
                      - 011 = ±1.024V

       Bit [8]      MODE: Modo de operación.
                      - 0 = Conversión continua           <-- CONFIGURACIÓN ACTUAL
                      - 1 = Single-shot (ahorro de energía, lee solo cuando se pide)

       Bits [7:5]   DR: Tasa de datos (Muestras por segundo - SPS).
                      - 000 = 8 SPS                       <-- CONFIGURACIÓN ACTUAL 
                      - 001 = 16 SPS                     
                      - 010 = 32 SPS                     
                      - 011 = 64 SPS                       
                      - 100 = 128 SPS                     
                      - 101 = 250 SPS                     
                      - 110 = 475 SPS                       
                      - 111 = 860 SPS                       

       Bit [4]      COMP_MODE: Modo del comparador (0 = Tradicional).
       Bit [3]      COMP_POL:  Polaridad del pin ALERT/RDY (0 = Activo en bajo).
       Bit [2]      COMP_LAT:  Latch del comparador (0 = No guarda el estado).
       Bits [1:0]   COMP_QUE:  Cola y desactivación del comparador.
                      - 00 = Activar alerta después de 1 conversión
                      - 01 = Activar alerta después de 2 conversiones
                      - 10 = Activar alerta después de 4 conversiones
                      - 11 = Desactivar comparador        <-- CONFIGURACIÓN ACTUAL
*/

module ADS1115_TOP #(
    parameter CLK_FREQ_HZ    = 25_000_000,
    parameter DELAY_MS       = 500,
    parameter [6:0] I2C_ADDR = 7'h48,

    parameter [7:0] CFG_MSB = 8'hC2,     // 1100_0010 en binario
    parameter [7:0] CFG_LSB = 8'h03      // 0000_0011 en binario
)(
    input wire clk,
    input wire rst,
    input wire busy,
    input wire done,
    input wire byte_done,
    input wire ack_error,
    input wire [7:0] rx_data,

    output wire start,
    output wire rw,
    output wire adc_valid,
    output wire error_alert,
    output wire [7:0] tx_byte,
    output wire [7:0] num_bytes,
    output wire [15:0] adc_value
);

wire [1:0] count_byte;
    wire Ld_count_byte;
    wire capture_msb;
    wire capture_lsb;
    wire error_set;
    wire delay_en;
    wire tick;

    ADS1115_CONTROL #(
        .CLK_FREQ_HZ (CLK_FREQ_HZ),
        .DELAY_MS    (DELAY_MS),
        .I2C_ADDR    (I2C_ADDR),
        .CFG_MSB     (CFG_MSB),
        .CFG_LSB     (CFG_LSB)
    ) CONTROL (
        .clk           (clk),
        .rst           (rst),
        .done          (done),
        .ack_error     (ack_error),
        .byte_done     (byte_done),
        .tick          (tick),
        .delay_en      (delay_en),
        .count_byte    (count_byte),
        .start         (start),
        .rw            (rw),
        .tx_byte       (tx_byte),
        .num_bytes     (num_bytes),
        .Ld_count_byte (Ld_count_byte),
        .capture_msb   (capture_msb),
        .capture_lsb   (capture_lsb),
        .error_set     (error_set)
    );

    ADS1115_DATA ADS1115_DATA1 (
        .clk           (clk),
        .rst           (rst),
        .byte_done     (byte_done),
        .rx_data       (rx_data),
        .Ld_count_byte (Ld_count_byte),
        .capture_msb   (capture_msb),
        .capture_lsb   (capture_lsb),
        .error_set     (error_set),
        .count_byte    (count_byte),
        .adc_value     (adc_value),
        .adc_valid     (adc_valid),
        .error_alert   (error_alert)
    );

    TICK_GENERATOR #(
        .CLK_FREQ_HZ (CLK_FREQ_HZ),
        .DELAY_MS    (DELAY_MS)
    ) TICK (
        .clk    (clk),
        .rst    (rst),
        .enable (delay_en),
        .tick   (tick)
    );

endmodule