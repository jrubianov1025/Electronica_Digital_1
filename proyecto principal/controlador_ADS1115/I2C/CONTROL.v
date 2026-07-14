module CONTROL_I2C (
    input wire clk,
    input wire rst,
    input wire start,
    input wire rw,
    input wire scl_rise,
    input wire scl_fall,
    input wire z_bits,
    input wire z_bytes,
    input wire sda_in,
    input wire [7:0] byte_value,

    output reg scl_enable,
    output reg sda_mux_sel,
    output reg sda_force_low,
    output reg load_shift,
    output reg shift_tx,
    output reg shift_rx,
    output reg store_rx,
    output reg load_bit_counter,
    output reg dec_bit_counter,
    output reg load_byte_counter,
    output reg dec_byte_counter,
    output reg busy,
    output reg done,
    output reg ack_error,
    output reg byte_done
);

    // DEFINICIÓN DE ESTADOS
    parameter S_IDLE      = 10'b0000000001;
    parameter S_START     = 10'b0000000010;
    parameter S_TX_DATA   = 10'b0000000100;
    parameter S_RX_ACK    = 10'b0000001000;
    parameter S_RX_DATA   = 10'b0000010000;
    parameter S_TX_ACK    = 10'b0000100000;
    parameter S_BYTE_DONE = 10'b0001000000;
    parameter S_STOP      = 10'b0010000000;
    parameter S_STOP_WAIT = 10'b0100000000;
    parameter S_DONE      = 10'b1000000000;

    reg [9:0] NEXT_STATE;
    reg [7:0] delay_cnt;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            NEXT_STATE <= S_IDLE;
            ack_error  <= 0;
            delay_cnt  <= 0;
        end else begin

            // Administrador del contador de retardos I2C
            if (NEXT_STATE == S_STOP_WAIT || NEXT_STATE == S_DONE)
                delay_cnt <= delay_cnt + 1'b1;
            else
                delay_cnt <= 0;

            case (NEXT_STATE)
                S_IDLE: begin
                    ack_error <= 0;
                    if (start) NEXT_STATE <= S_START;
                    else       NEXT_STATE <= S_IDLE;
                end
                S_START: begin
                    if (scl_fall) NEXT_STATE <= S_TX_DATA;
                    else          NEXT_STATE <= S_START;
                end
                S_TX_DATA: begin
                    if (scl_fall && z_bits) NEXT_STATE <= S_RX_ACK;
                    else                    NEXT_STATE <= S_TX_DATA;
                end
                S_RX_ACK: begin
                    if (scl_rise && sda_in) ack_error <= 1;
                    if (scl_fall)           NEXT_STATE <= S_BYTE_DONE;
                    else                    NEXT_STATE <= S_RX_ACK;
                end
                S_RX_DATA: begin
                    if (scl_fall && z_bits) NEXT_STATE <= S_TX_ACK;
                    else                    NEXT_STATE <= S_RX_DATA;
                end
                S_TX_ACK: begin
                    if (scl_fall) NEXT_STATE <= S_BYTE_DONE;
                    else          NEXT_STATE <= S_TX_ACK;
                end
                S_BYTE_DONE: begin
                    if (ack_error)    NEXT_STATE <= S_STOP;
                    else if (z_bytes) NEXT_STATE <= S_STOP;
                    else begin
                        if (rw) NEXT_STATE <= S_RX_DATA;
                        else    NEXT_STATE <= S_TX_DATA;
                    end
                end
                S_STOP: begin
                    if (scl_rise) NEXT_STATE <= S_STOP_WAIT;
                    else          NEXT_STATE <= S_STOP;
                end
                S_STOP_WAIT: begin
                    // Espera 5 microsegundos (125 ciclos @ 25MHz) antes de liberar SDA
                    if (delay_cnt >= 8'd125) NEXT_STATE <= S_DONE;
                    else                     NEXT_STATE <= S_STOP_WAIT;
                end
                S_DONE: begin
                    // Espera 5 microsegundos extra antes de finalizar
                    if (delay_cnt >= 8'd250) NEXT_STATE <= S_IDLE;
                    else                     NEXT_STATE <= S_DONE;
                end
                default: NEXT_STATE <= S_IDLE;
            endcase
        end
    end

    // LOGICA DE SALIDAS 
    always @(*) begin
        case (NEXT_STATE)
            S_IDLE: begin
                scl_enable    = 0; load_bit_counter  = 0;
                sda_mux_sel   = 1; dec_bit_counter   = 0;
                sda_force_low = 0; load_byte_counter = 0;
                load_shift    = 0; dec_byte_counter  = 0;
                shift_tx      = 0; busy              = 0;
                shift_rx      = 0; done              = 0;
                store_rx      = 0; byte_done         = 0;
            end
            S_START: begin
                scl_enable    = 1; load_bit_counter  = 1;
                sda_mux_sel   = 1; dec_bit_counter   = 0;
                sda_force_low = 1; load_byte_counter = 1;
                load_shift    = 1; dec_byte_counter  = 0;
                shift_tx      = 0; busy              = 1;
                shift_rx      = 0; done              = 0;
                store_rx      = 0; byte_done         = 0;
            end
            S_TX_DATA: begin
                scl_enable    = 1;        load_bit_counter  = 0;
                sda_mux_sel   = 0;        dec_bit_counter   = scl_fall;
                sda_force_low = 0;        load_byte_counter = 0;
                load_shift    = 0;        dec_byte_counter  = 0;
                shift_tx      = scl_fall; busy              = 1;
                shift_rx      = 0;        done              = 0;
                store_rx      = 0;        byte_done         = 0;
            end
            S_RX_ACK: begin
                scl_enable    = 1; load_bit_counter  = 0;
                sda_mux_sel   = 1; dec_bit_counter   = 0;
                sda_force_low = 0; load_byte_counter = 0;
                load_shift    = 0; dec_byte_counter  = scl_fall;
                shift_tx      = 0; busy              = 1;
                shift_rx      = 0; done              = 0;
                store_rx      = 0; byte_done         = 0;
            end
            S_RX_DATA: begin
                scl_enable    = 1;        load_bit_counter  = 0;
                sda_mux_sel   = 1;        dec_bit_counter   = scl_fall;
                sda_force_low = 0;        load_byte_counter = 0;
                load_shift    = 0;        dec_byte_counter  = 0;
                shift_tx      = 0;        busy              = 1;
                shift_rx      = scl_rise; done              = 0;
                store_rx      = 0;        byte_done         = 0;
            end
            S_TX_ACK: begin
                scl_enable    = 1;                                   load_bit_counter  = 0;
                sda_mux_sel   = 1;                                   dec_bit_counter   = 0;
                sda_force_low = (byte_value == 8'd1) ? 1'b0 : 1'b1;  load_byte_counter = 0;
                load_shift    = 0;                                   dec_byte_counter  = scl_fall;
                shift_tx      = 0;                                   busy              = 1;
                shift_rx      = 0;                                   done              = 0;
                store_rx      = scl_rise;                            byte_done         = 0;
            end
            S_BYTE_DONE: begin
                scl_enable    = 1;                 load_bit_counter  = 1;
                sda_mux_sel   = 1;                 dec_bit_counter   = 0;
                sda_force_low = 1;                 load_byte_counter = 0;
                load_shift    = (~z_bytes && ~rw); dec_byte_counter  = 0;
                shift_tx      = 0;                 busy              = 1;
                shift_rx      = 0;                 done              = 0;
                store_rx      = 0;                 byte_done         = 1;
            end
            S_STOP: begin
                scl_enable    = 1; load_bit_counter  = 0;
                sda_mux_sel   = 1; dec_bit_counter   = 0;
                sda_force_low = 1; load_byte_counter = 0;
                load_shift    = 0; dec_byte_counter  = 0;
                shift_tx      = 0; busy              = 1;
                shift_rx      = 0; done              = 0;
                store_rx      = 0; byte_done         = 0;
            end
            S_STOP_WAIT: begin
                scl_enable    = 1; load_bit_counter  = 0;
                sda_mux_sel   = 1; dec_bit_counter   = 0;
                sda_force_low = 1; load_byte_counter = 0;
                load_shift    = 0; dec_byte_counter  = 0;
                shift_tx      = 0; busy              = 1;
                shift_rx      = 0; done              = 0;
                store_rx      = 0; byte_done         = 0;
            end
            S_DONE: begin
                scl_enable    = 0; load_bit_counter  = 0;
                sda_mux_sel   = 1; dec_bit_counter   = 0;
                sda_force_low = 0; load_byte_counter = 0; 
                load_shift    = 0; dec_byte_counter  = 0;
                shift_tx      = 0; busy              = 1; 
                shift_rx      = 0; done              = (delay_cnt >= 8'd250);
                store_rx      = 0; byte_done         = 0;
            end
            default: begin
                scl_enable    = 0; load_bit_counter  = 0;
                sda_mux_sel   = 0; dec_bit_counter   = 0;
                sda_force_low = 0; load_byte_counter = 0;
                load_shift    = 0; dec_byte_counter  = 0;
                shift_tx      = 0; busy              = 0;
                shift_rx      = 0; done              = 0;
                store_rx      = 0; byte_done         = 0;
            end
        endcase
    end
endmodule