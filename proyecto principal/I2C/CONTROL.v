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

    output reg scl_enable,
    output reg drive_sel,
    output reg drive_low_fsm,
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
    parameter S_IDLE      = 8'b00000001; 
    parameter S_START     = 8'b00000010; 
    parameter S_TX_DATA   = 8'b00000100; 
    parameter S_RX_ACK    = 8'b00001000; 
    parameter S_RX_DATA   = 8'b00010000; 
    parameter S_TX_ACK    = 8'b00100000; 
    parameter S_BYTE_DONE = 8'b01000000; 
    parameter S_STOP      = 8'b10000000; 

    reg [7:0] NEXT_STATE;

    // MAQUINA DE ESTADOS
    always @(posedge clk or posedge rst) begin

        if (rst) begin
            NEXT_STATE = S_IDLE;
            ack_error  = 0;
        
        end else begin
            case (NEXT_STATE)

                S_IDLE: begin
                    ack_error = 0;
                    if (start) NEXT_STATE = S_START;
                    else       NEXT_STATE = S_IDLE;
                end

                S_START: begin
                    if (scl_fall) NEXT_STATE = S_TX_DATA;
                    else          NEXT_STATE = S_START;
                end

                S_TX_DATA: begin
                    if (scl_fall && z_bits) NEXT_STATE = S_RX_ACK;
                    else                    NEXT_STATE = S_TX_DATA;
                end

                S_RX_ACK: begin
                    if (scl_rise && sda_in) ack_error = 1;
                    if (scl_fall)           NEXT_STATE = S_BYTE_DONE;
                    else                    NEXT_STATE = S_RX_ACK;
                end

                S_RX_DATA: begin
                    if (scl_fall && z_bits) NEXT_STATE = S_TX_ACK;
                    else                    NEXT_STATE = S_RX_DATA;
                end

                S_TX_ACK: begin
                    if (scl_fall) NEXT_STATE = S_BYTE_DONE;
                    else          NEXT_STATE = S_TX_ACK;
                end

                S_BYTE_DONE: begin
                    if (ack_error)    NEXT_STATE = S_STOP;
                    else if (z_bytes) NEXT_STATE = S_STOP;
                    else begin
                        if (rw) NEXT_STATE = S_RX_DATA;
                        else    NEXT_STATE = S_TX_DATA;
                    end
                end

                S_STOP: begin
                    if (scl_rise) NEXT_STATE = S_IDLE;
                    else          NEXT_STATE = S_STOP;
                end

                default: NEXT_STATE = S_IDLE;

            endcase
        end
    end

    // LOGICA DE SALIDAS
    always @(*) begin
        case (NEXT_STATE)

            S_IDLE: begin
                scl_enable    = 0; load_bit_counter  = 0;
                drive_sel     = 1; dec_bit_counter   = 0;
                drive_low_fsm = 0; load_byte_counter = 0;
                load_shift    = 0; dec_byte_counter  = 0;
                shift_tx      = 0; busy              = 0;
                shift_rx      = 0; done              = 0;
                store_rx      = 0; byte_done         = 0;
            end

            S_START: begin
                scl_enable    = 1; load_bit_counter  = 1;
                drive_sel     = 1; dec_bit_counter   = 0;
                drive_low_fsm = 1; load_byte_counter = 1;
                load_shift    = 1; dec_byte_counter  = 0;
                shift_tx      = 0; busy              = 1;
                shift_rx      = 0; done              = 0;
                store_rx      = 0; byte_done         = 0;
            end

            S_TX_DATA: begin
                scl_enable    = 1;        load_bit_counter  = 0;   
                drive_sel     = 0;        dec_bit_counter   = scl_fall;   
                drive_low_fsm = 0;        load_byte_counter = 0;   
                load_shift    = 0;        dec_byte_counter  = 0;   
                shift_tx      = scl_fall; busy              = 1;           
                shift_rx      = 0;        done              = 0;   
                store_rx      = 0;        byte_done         = 0;   
            end

            S_RX_ACK: begin
                scl_enable    = 1; load_bit_counter  = 0;
                drive_sel     = 1; dec_bit_counter   = 0;
                drive_low_fsm = 0; load_byte_counter = 0;
                load_shift    = 0; dec_byte_counter  = scl_fall;
                shift_tx      = 0; busy              = 1;
                shift_rx      = 0; done              = 0;
                store_rx      = 0; byte_done         = 0;
            end

            S_RX_DATA: begin
                scl_enable    = 1;        load_bit_counter  = 0;
                drive_sel     = 1;        dec_bit_counter   = scl_fall;            
                drive_low_fsm = 0;        load_byte_counter = 0;            
                load_shift    = 0;        dec_byte_counter  = 0;            
                shift_tx      = 0;        busy              = 1;            
                shift_rx      = scl_rise; done              = 0;                    
                store_rx      = 0;        byte_done         = 0;
            end

            S_TX_ACK: begin
                scl_enable    = 1;                       load_bit_counter  = 0;
                drive_sel     = 1;                       dec_bit_counter   = 0;
                drive_low_fsm = (z_bytes) ? 1'b0 : 1'b1; load_byte_counter = 0;                        
                load_shift    = 0;                       dec_byte_counter  = scl_fall;
                shift_tx      = 0;                       busy              = 1;
                shift_rx      = 0;                       done              = 0;
                store_rx      = scl_rise;                byte_done         = 0;        
            end

            S_BYTE_DONE: begin
                scl_enable    = 1;                 load_bit_counter  = 1;
                drive_sel     = 1;                 dec_bit_counter   = 0;
                drive_low_fsm = 1;                 load_byte_counter = 0;
                load_shift    = (~z_bytes && ~rw); dec_byte_counter  = 0;                
                shift_tx      = 0;                 busy              = 1;
                shift_rx      = 0;                 done              = 0;
                store_rx      = 0;                 byte_done         = 1;
            end

            S_STOP: begin
                scl_enable    = 1;                        load_bit_counter  = 0;
                drive_sel     = 1;                        dec_bit_counter   = 0;
                drive_low_fsm = (scl_rise) ? 1'b0 : 1'b1; load_byte_counter = 0;                        
                load_shift    = 0;                        dec_byte_counter  = 0;
                shift_tx      = 0;                        busy              = 1;
                shift_rx      = 0;                        done              = scl_rise;
                store_rx      = 0;                        byte_done         = 0;
            end

            default: begin
                scl_enable    = 0; load_bit_counter  = 0;
                drive_sel     = 0; dec_bit_counter   = 0;
                drive_low_fsm = 0; load_byte_counter = 0;
                load_shift    = 0; dec_byte_counter  = 0;
                shift_tx      = 0; busy              = 0;
                shift_rx      = 0; done              = 0;
                store_rx      = 0; byte_done         = 0;
            end

        endcase
    end

endmodule