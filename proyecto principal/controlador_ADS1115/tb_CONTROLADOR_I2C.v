`timescale 1ns / 1ps

module tb_CONTROLADOR_I2C;

    // Parámetros de simulación acelerados
    localparam CLK_FREQ_HZ  = 25_000_000;
    localparam SIM_DELAY_MS = 2; // ¡2 ms en lugar de 500 ms para acelerar la simulación!
    localparam CLK_PERIOD   = 40; // 40 ns para 25 MHz

    reg clk;
    reg rst;
    tri1 SDA;
    tri1 SCL;
    wire [15:0] adc_value;

    reg slave_drive_low;
    assign SDA = slave_drive_low ? 1'b0 : 1'bz;
    
    // Pull-ups físicas/simuladas
    pullup(SDA);
    pullup(SCL);

    CONTROLADOR_I2C #(
        .CLK_FREQ_HZ(CLK_FREQ_HZ),
        .DELAY_MS(SIM_DELAY_MS) 
    ) uut (
        .clk(clk),
        .rst(rst),
        .SDA(SDA),
        .SCL(SCL),
        .adc_value(adc_value)
    );

    always #(CLK_PERIOD/2) clk = ~clk;

    reg i2c_busy;
    integer bit_cnt;
    reg [7:0] frame_idx;
    reg slave_rw;
    reg [7:0] shift_in;
    reg [7:0] active_ptr;
    reg [7:0] out_data;
    reg [15:0] dummy_adc;

    initial begin
        i2c_busy = 0; bit_cnt = 0; frame_idx = 0;
        slave_rw = 0; slave_drive_low = 0;
        active_ptr = 0; 
        dummy_adc = 16'h1A55; // Primer dato ficticio del ADC
    end

    // Detectores de Start y Stop
    always @(negedge SDA) if (SCL === 1'b1) begin
        i2c_busy <= 1; bit_cnt <= 0; frame_idx <= 0;
    end
    always @(posedge SDA) if (SCL === 1'b1) begin
        i2c_busy <= 0;
    end

    // Muestreo del Esclavo (Flanco de Subida de SCL)
    always @(posedge SCL) begin
        if (i2c_busy) begin
            if (bit_cnt < 8) begin
                if (frame_idx == 0 || slave_rw == 0) shift_in <= {shift_in[6:0], SDA};
            end
            bit_cnt <= bit_cnt + 1;
        end
    end

    // Respuesta del Esclavo (Flanco de Bajada de SCL)
    always @(negedge SCL) begin
        if (i2c_busy) begin
            if (bit_cnt == 8) begin
                // Reconocimiento (ACK)
                if (frame_idx == 0) begin
                    slave_drive_low <= 1; // ACK para dirección
                    slave_rw <= shift_in[0];
                end else if (slave_rw == 0) begin
                    slave_drive_low <= 1; // ACK para datos escritos
                    if (frame_idx == 1) active_ptr <= shift_in; // Guardar puntero
                end else begin
                    slave_drive_low <= 0; // NACK/ACK dejado al maestro
                end
            end else if (bit_cnt == 9) begin
                // Preparar siguiente byte
                bit_cnt <= 0;
                frame_idx <= frame_idx + 1;
                
                if (slave_rw == 1) begin

                    if (frame_idx == 0) out_data = dummy_adc[15:8]; // Enviar MSB
                    else                out_data = dummy_adc[7:0];  // Enviar LSB
                    slave_drive_low <= ~out_data[7];
                end else begin
                    slave_drive_low <= 0;
                end
            end else begin
                // Desplazar bits hacia el maestro (Modo Lectura)
                if (slave_rw == 1 && frame_idx > 0) begin
                    if (bit_cnt < 8) slave_drive_low <= ~out_data[7 - bit_cnt];
                end else begin
                    slave_drive_low <= 0;
                end
            end
        end
    end

    always @(negedge i2c_busy) begin
        if (slave_rw == 1 && frame_idx >= 2) begin
            dummy_adc <= dummy_adc + 16'h1111; // 1A55 -> 2B66 -> 3C77
        end
    end

    initial begin
        $dumpfile("CONTROLADOR_I2C.vcd");
        $dumpvars(0, uut);
        
        clk = 0;
        rst = 1;
        #(CLK_PERIOD * 10);
        rst = 0;
        
        $display("\n========================================================");
        $display("--- Iniciando Simulacion Global CONTROLADOR_I2C ---");
        $display("[INFO] DELAY_MS esta configurado a %0d ms para acelerar la simulacion.", SIM_DELAY_MS);
        $display("========================================================\n");
        $display("[TB] Esperando la inicializacion y trama de configuracion...");
        
        // Bucle infinito monitoreando los pines de salida
        forever begin
            @(adc_value);
            // Ignorar los estados de alta impedancia o ceros del arranque
            if (adc_value !== 16'hx && adc_value !== 16'h0) begin
                $display("[TB - EXITO] Nuevo valor ADC reflejado en pines fisicos: 0x%H", adc_value);
                
                // Finalizar tras verificar 3 ciclos de lectura exitosos
                if (adc_value == 16'h3C77) begin
                    $display("\n--- Tres lecturas completadas. Testbench Finalizado OK ---");
                    $finish;
                end
            end
        end
    end
    
    // Timeout de seguridad de 20 ms simulados
    initial begin
        #(CLK_PERIOD * 500_000); 
        $display("\n[ERROR] Timeout de simulacion alcanzado (posible bloqueo en la FSM).");
        $finish;
    end

endmodule