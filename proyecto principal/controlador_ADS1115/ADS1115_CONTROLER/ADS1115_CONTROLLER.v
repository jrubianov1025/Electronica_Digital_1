/*       >>> CONFIGURACIÓN DEL ADS1115 <<<
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

module ADS1115_CONTROLLER #(
    parameter CLK_FREQ_HZ    = 25_000_000,
    parameter DELAY_MS       = 500,
    parameter [6:0] I2C_ADDR = 7'h48,

    parameter [7:0] CFG_MSB = 8'hC2,     // 1100_0010 en binario
    parameter [7:0] CFG_LSB = 8'h03      // 0000_0011 en binario

)(
    input  wire        clk,
    input  wire        rst,
    input  wire        busy,
    input  wire        done,
    input  wire        byte_done,
    input  wire        ack_error,
    input  wire [7:0]  rx_data,

    output reg         start,
    output reg         rw,
    output reg  [7:0]  tx_byte,
    output reg  [7:0]  num_bytes,
    output reg  [15:0] adc_value,
    output reg         adc_valid,
    output reg         error_alert
);

    // Direcciones I2C con bit R/W integrado
    localparam [7:0] ADDR_W = {I2C_ADDR, 1'b0};  
    localparam [7:0] ADDR_R = {I2C_ADDR, 1'b1};  

    // DEFINICIÓN DE ESTADOS
    parameter S_RESET      = 9'b000000001;
    parameter S_CFG_START  = 9'b000000010;
    parameter S_CFG_WAIT   = 9'b000000100;
    parameter S_PTR_START  = 9'b000001000;
    parameter S_PTR_WAIT   = 9'b000010000;
    parameter S_READ_START = 9'b000100000;
    parameter S_READ_WAIT  = 9'b001000000;
    parameter S_DELAY      = 9'b010000000;
    parameter S_ERROR      = 9'b100000000;

    reg [8:0] NEXT_STATE;
    reg [1:0] byte_idx;        
    reg [7:0] adc_msb;

    // Actualización inmediata del índice de bytes transmitidos
    wire [1:0] effective_idx = byte_idx + (byte_done ? 2'd1 : 2'd0); 
    wire       tick_delay;

    TICK_GENERATOR #(
        .CLK_FREQ_HZ (CLK_FREQ_HZ),
        .DELAY_MS    (DELAY_MS)
    ) TICK (
        .clk    (clk),
        .rst    (rst),
        .enable (NEXT_STATE == S_DELAY),
        .tick   (tick_delay)
    );

    // MAQUINA DE ESTADOS Y LÓGICA SECUENCIAL
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            NEXT_STATE  <= S_RESET;
            byte_idx    <= 2'd0;
            adc_msb     <= 8'h00;
            adc_value   <= 16'h0000;
            adc_valid   <= 1'b0;
            error_alert <= 1'b0;
        end else begin
            adc_valid <= 1'b0;

            // Captura secuencial de datos del ADC y alertas de NACK
            if (NEXT_STATE == S_READ_WAIT && byte_done && byte_idx == 2'd1) begin
                adc_msb <= rx_data;
            end

            if (NEXT_STATE == S_READ_WAIT && byte_done && byte_idx == 2'd2) begin
                adc_value <= {adc_msb, rx_data};
                adc_valid <= 1'b1;
            end

            if ((NEXT_STATE == S_CFG_WAIT || NEXT_STATE == S_PTR_WAIT || NEXT_STATE == S_READ_WAIT) && done && ack_error) begin
                error_alert <= 1'b1;
            end

            // Control del contador de bytes internos por transacción
            if (NEXT_STATE == S_CFG_START || NEXT_STATE == S_PTR_START || NEXT_STATE == S_READ_START) begin
                byte_idx <= 2'd0;
            end else if (byte_done) begin
                byte_idx <= byte_idx + 2'd1;
            end

            case (NEXT_STATE)
                S_RESET: begin
                    NEXT_STATE <= S_CFG_START;
                end

                S_CFG_START: begin
                    NEXT_STATE <= S_CFG_WAIT;
                end

                S_CFG_WAIT: begin
                    if (done) NEXT_STATE <= ack_error ? S_ERROR : S_PTR_START;
                    else      NEXT_STATE <= S_CFG_WAIT;
                end

                S_PTR_START: begin
                    NEXT_STATE <= S_PTR_WAIT;
                end

                S_PTR_WAIT: begin
                    if (done) NEXT_STATE <= ack_error ? S_ERROR : S_READ_START;
                    else      NEXT_STATE <= S_PTR_WAIT;
                end

                S_READ_START: begin
                    NEXT_STATE <= S_READ_WAIT;
                end

                S_READ_WAIT: begin
                    if (done) NEXT_STATE <= ack_error ? S_ERROR : S_DELAY;
                    else      NEXT_STATE <= S_READ_WAIT;
                end

                S_DELAY: begin
                    if (tick_delay) NEXT_STATE <= S_PTR_START;
                    else            NEXT_STATE <= S_DELAY;
                end

                S_ERROR: begin
                    NEXT_STATE <= S_ERROR;
                end

                default: NEXT_STATE <= S_RESET;
            endcase
        end
    end

    // LOGICA DE SALIDAS
    always @(*) begin
        case (NEXT_STATE)
            S_RESET: begin
                start = 0;
                rw = 0; 
                tx_byte = 8'h00; 
                num_bytes = 8'h00;
            end

            S_CFG_START: begin
                start = 1; 
                rw = 0; 
                tx_byte = ADDR_W; 
                num_bytes = 8'd4;
            end

            S_CFG_WAIT: begin
                start = 0;
                rw = 0;
                num_bytes = 8'd4;
                case (effective_idx)
                    2'd0:    tx_byte = ADDR_W;
                    2'd1:    tx_byte = 8'h01;  // Registro de Configuración (0x01)
                    2'd2:    tx_byte = CFG_MSB;
                    2'd3:    tx_byte = CFG_LSB;
                    default: tx_byte = 8'h00;
                endcase
            end

            S_PTR_START: begin
                start = 1;
                rw = 0;
                tx_byte = ADDR_W;
                num_bytes = 8'd2;
            end

            S_PTR_WAIT: begin
                start = 0; 
                rw = 0; 
                num_bytes = 8'd2;
                case (effective_idx)
                    2'd0:    tx_byte = ADDR_W;
                    2'd1:    tx_byte = 8'h00;  // Registro de Conversión (0x00)
                    default: tx_byte = 8'h00;
                endcase
            end

            S_READ_START: begin
                start = 1; 
                rw = 1; 
                tx_byte = ADDR_R; 
                num_bytes = 8'd3;
            end

            S_READ_WAIT: begin
                start = 0; 
                rw = 1; 
                num_bytes = 8'd3;
                case (effective_idx)
                    2'd0:    tx_byte = ADDR_R;
                    default: tx_byte = 8'h00;
                endcase
            end

            S_DELAY: begin
                start = 0; 
                rw = 0; 
                tx_byte = 8'h00; 
                num_bytes = 8'h00;
            end

            S_ERROR: begin
                start = 0; 
                rw = 0; 
                tx_byte = 8'h00; 
                num_bytes = 8'h00;
            end

            default: begin
                start = 0; 
                rw = 0; 
                tx_byte = 8'h00; 
                num_bytes = 8'h00;
            end
        endcase
    end

endmodule