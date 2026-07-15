module ADS1115_CONTROL #(
    parameter CLK_FREQ_HZ    = 25_000_000,
    parameter DELAY_MS       = 500,
    parameter [6:0] I2C_ADDR = 7'h48,
    parameter [7:0] CFG_MSB  = 8'hC2,     // 1100_0010 en binario
    parameter [7:0] CFG_LSB  = 8'h03      // 0000_0011 en binario
)(
    input wire clk,
    input wire rst,
    input wire done,
    input wire ack_error,
    input wire byte_done,
    input wire tick,
    input wire [1:0] count_byte,

    output wire delay_en,
    output reg start,
    output reg rw,
    output reg Ld_count_byte,
    output reg capture_msb,
    output reg capture_lsb,
    output reg error_set,
    output reg [7:0] tx_byte,
    output reg [7:0] num_bytes
);

    // Direcciones I2C con bit R/W integrado
    localparam [7:0] ADDR_W = {I2C_ADDR, 1'b0};
    localparam [7:0] ADDR_R = {I2C_ADDR, 1'b1};

    // DEFINICION DE ESTADOS
    localparam S_INIT       = 9'b000000001;
    localparam S_CFG_START  = 9'b000000010;
    localparam S_CFG_WAIT   = 9'b000000100;
    localparam S_PTR_START  = 9'b000001000;
    localparam S_PTR_WAIT   = 9'b000010000;
    localparam S_READ_START = 9'b000100000;
    localparam S_READ_WAIT  = 9'b001000000;
    localparam S_DELAY      = 9'b010000000;
    localparam S_ERROR      = 9'b100000000;

    reg [8:0] NEXT_STATE;

    assign delay_en = (NEXT_STATE == S_DELAY);
    wire [1:0] effective_count = count_byte + (byte_done ? 2'd1 : 2'd0);

    // LÓGICA SECUENCIAL 
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            NEXT_STATE <= S_INIT;
        end else begin
            case (NEXT_STATE)

                S_INIT: begin
                    NEXT_STATE <= S_CFG_START;
                end

                S_CFG_START: begin
                    NEXT_STATE <= S_CFG_WAIT;
                end
                
                S_CFG_WAIT: begin
                    if (done && ack_error) NEXT_STATE <= S_ERROR;
                    else if (done)         NEXT_STATE <= S_PTR_START;
                    else                   NEXT_STATE <= S_CFG_WAIT;
                end

                S_PTR_START: begin
                    NEXT_STATE <= S_PTR_WAIT;
                end

                S_PTR_WAIT: begin
                    if (done && ack_error) NEXT_STATE <= S_ERROR;
                    else if (done)         NEXT_STATE <= S_READ_START;
                    else                   NEXT_STATE <= S_PTR_WAIT;
                end

                S_READ_START: begin
                    NEXT_STATE <= S_READ_WAIT;
                end

                S_READ_WAIT: begin
                    if (done && ack_error) NEXT_STATE <= S_ERROR;
                    else if (done)         NEXT_STATE <= S_DELAY;
                    else                   NEXT_STATE <= S_READ_WAIT;
                end

                S_DELAY: begin
                    if (tick) NEXT_STATE <= S_PTR_START;
                    else            NEXT_STATE <= S_DELAY;
                end

                S_ERROR: begin
                    NEXT_STATE <= S_ERROR;
                end

                default: begin
                    NEXT_STATE <= S_INIT;
                end
                
            endcase
        end
    end

    // LÓGICA COMBINACIONAL 
    always @(*) begin

        case (NEXT_STATE)
            S_INIT: begin
                start         = 0;
                rw            = 0;
                tx_byte       = 0;
                num_bytes     = 0;
                Ld_count_byte = 0;
                capture_msb   = 0;
                capture_lsb   = 0;
                error_set     = 0;
            end

            S_CFG_START: begin
                start         = 1;
                rw            = 0;
                tx_byte       = ADDR_W;
                num_bytes     = 4;
                Ld_count_byte = 1;
                capture_msb   = 0;
                capture_lsb   = 0;
                error_set     = 0;
            end

            S_CFG_WAIT: begin
                start         = 0;
                rw            = 0;
                num_bytes     = 4;
                Ld_count_byte = 0;
                capture_msb   = 0;
                capture_lsb   = 0;
                error_set     = done && ack_error;
                
                case (effective_count)
                    0:    tx_byte = ADDR_W;
                    1:    tx_byte = 8'h01;  // Registro de Configuracion (0x01)
                    2:    tx_byte = CFG_MSB;
                    3:    tx_byte = CFG_LSB;
                    default: tx_byte = 0;
                endcase
            end

            S_PTR_START: begin
                start         = 1;
                rw            = 0;
                tx_byte       = ADDR_W;
                num_bytes     = 2;
                Ld_count_byte = 1;
                capture_msb   = 0;
                capture_lsb   = 0;
                error_set     = 0;
            end

            S_PTR_WAIT: begin
                start         = 0;
                rw            = 0;
                num_bytes     = 2;
                Ld_count_byte = 0;
                capture_msb   = 0;
                capture_lsb   = 0;
                error_set     = done && ack_error;
                
                case (effective_count)
                    0:    tx_byte = ADDR_W;
                    1:    tx_byte = 8'h00;  // Registro de Conversion (0x00)
                    default: tx_byte = 0;
                endcase
            end

            S_READ_START: begin
                start         = 1;
                rw            = 1;
                tx_byte       = ADDR_R;
                num_bytes     = 3;
                Ld_count_byte = 1;
                capture_msb   = 0;
                capture_lsb   = 0;
                error_set     = 0;
            end

            S_READ_WAIT: begin
                start         = 0;
                rw            = 1;
                num_bytes     = 3;
                Ld_count_byte = 0;
                capture_msb   = byte_done && (count_byte == 1);
                capture_lsb   = byte_done && (count_byte == 2);
                error_set     = done && ack_error;
                
                case (effective_count)
                    0:    tx_byte = ADDR_R;
                    default: tx_byte = 0;
                endcase
            end

            S_DELAY: begin
                start         = 0;
                rw            = 0;
                tx_byte       = 0;
                num_bytes     = 0;
                Ld_count_byte = 0;
                capture_msb   = 0;
                capture_lsb   = 0;
                error_set     = 0;
            end

            S_ERROR: begin
                start         = 0;
                rw            = 0;
                tx_byte       = 0;
                num_bytes     = 0;
                Ld_count_byte = 0;
                capture_msb   = 0;
                capture_lsb   = 0;
                error_set     = 0;
            end

            default: begin
                start         = 0;
                rw            = 0;
                tx_byte       = 0;
                num_bytes     = 0;
                Ld_count_byte = 0;
                capture_msb   = 0;
                capture_lsb   = 0;
                error_set     = 0;
            end
        endcase
    end

endmodule