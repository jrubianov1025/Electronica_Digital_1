module TOP_I2C #(
    parameter CLK_FREQ_HZ = 25_000_000,
    parameter I2C_FREQ_HZ = 100_000
)(
    input  wire clk,
    input  wire rst,
    input  wire start,
    input  wire rw,
    input  wire [7:0] tx_byte,
    input  wire [7:0] num_bytes,

    output wire [7:0] rx_data,
    output wire busy,
    output wire done,
    output wire ack_error,
    output wire byte_done,
    
    inout wire SDA,
    inout wire SCL
);

    // Señales internas de reloj I2C 
    wire scl_enable;
    wire scl_rise;
    wire scl_fall;
    wire scl_internal;

    // Señales de control de SDA
    wire sda_mux_sel;
    wire sda_force_low;
    wire sda_pull_low;
    wire sda_in;
    wire tx_bit;

    // Señales de control del registro de desplazamiento
    wire load_shift;
    wire shift_tx;
    wire shift_rx;
    wire store_rx;

    // Señales de control de los contadores
    wire load_bit_counter;
    wire dec_bit_counter;
    wire z_bits;
    wire [2:0] bit_value;

    wire load_byte_counter;
    wire dec_byte_counter;
    wire z_bytes;
    wire [7:0] byte_value;

    // bloque para sincronizar la señal de entrada de SDA con el relog de la FPGA
    reg sda_meta, sda_sync;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            sda_meta <= 1'b1;
            sda_sync <= 1'b1;
        end else begin
            sda_meta <= SDA;
            sda_sync <= sda_meta;
        end
    end
    assign sda_in = sda_sync;

   // I2C utiliza salidas Open-Drain: drive_low = 1 -> fuerza un '0' drive_low = 0 -> alta impedancia
    assign SDA = sda_pull_low ? 1'b0 : 1'bz;
    assign sda_pull_low = (sda_mux_sel) ? sda_force_low : ~tx_bit;
    assign SCL = (scl_internal) ? 1'bz : 1'b0;

    I2C_CLOCK_GENERATOR #(
        .CLK_FREQ_HZ(CLK_FREQ_HZ),
        .I2C_FREQ_HZ(I2C_FREQ_HZ)
    )
    CLOCK_GEN(
        .clk      (clk),
        .rst      (rst),
        .enable   (scl_enable),
        .scl      (scl_internal),
        .scl_rise (scl_rise),
        .scl_fall (scl_fall)
    );
    SHIFT_REGISTER SHIFT(
        .clk      (clk),
        .rst      (rst),
        .load     (load_shift),
        .shift_tx (shift_tx),
        .shift_rx (shift_rx),
        .store_rx (store_rx),
        .tx_byte  (tx_byte),
        .sda_in   (sda_in),
        .tx_bit   (tx_bit),
        .rx_data  (rx_data)
    );
    CONTADOR_BITS BIT_COUNTER(
        .clk    (clk),
        .rst    (rst),
        .load   (load_bit_counter),
        .dec    (dec_bit_counter),
        .z_bits (z_bits),
        .value  (bit_value)
    );
    CONTADOR_BYTES BYTE_COUNTER(
        .clk       (clk),
        .rst       (rst),
        .load      (load_byte_counter),
        .dec       (dec_byte_counter),
        .num_bytes (num_bytes),
        .z_bytes   (z_bytes),
        .value     (byte_value)
    );
    CONTROL_I2C CONTROL (
        .clk      (clk),
        .rst      (rst),
        .start    (start),
        .rw       (rw),
        .scl_rise (scl_rise),
        .scl_fall (scl_fall),
        .z_bits   (z_bits),
        .z_bytes  (z_bytes),
        .sda_in   (sda_in),
        .byte_value(byte_value),
        .scl_enable    (scl_enable),
        .sda_mux_sel   (sda_mux_sel),
        .sda_force_low (sda_force_low),
        .load_shift    (load_shift),
        .shift_tx      (shift_tx),
        .shift_rx      (shift_rx),
        .store_rx      (store_rx),
        .load_bit_counter  (load_bit_counter),
        .dec_bit_counter   (dec_bit_counter),
        .load_byte_counter (load_byte_counter),
        .dec_byte_counter  (dec_byte_counter),
        .busy      (busy),
        .done      (done),
        .ack_error (ack_error),
        .byte_done (byte_done)
    );
endmodule