`timescale 1ns / 1ps

module tb_TOP_I2C;

    localparam CLK_FREQ_HZ = 10_000_000;
    localparam I2C_FREQ_HZ = 1_000_000;
    localparam CLK_PERIOD  = 100; // 100ns

    reg        clk;
    reg        rst;
    reg        start;
    reg        rw;
    reg  [7:0] tx_byte;
    reg  [7:0] num_bytes;

    wire [7:0] rx_data;
    wire       busy;
    wire       done;
    wire       ack_error;
    wire       byte_done;

    tri1       SDA;
    wire       SCL;

    reg        slave_drive_low;
    reg  [7:0] bytes_enviados_master;
    reg  [7:0] bytes_recibidos_master;

    // Resistencias Pull-Up del bus
    assign SDA = slave_drive_low ? 1'b0 : 1'bz;

    pullup(SDA);

    // Instanciación de la Unidad Bajo Prueba (UUT)
    TOP_I2C #(
        .CLK_FREQ_HZ(CLK_FREQ_HZ),
        .I2C_FREQ_HZ(I2C_FREQ_HZ)
    ) uut (
        .clk(clk),
        .rst(rst),
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

    // Generador de Reloj del Sistema
    always #(CLK_PERIOD/2) clk = ~clk;

    task aplicar_reset;
        begin
            rst = 1; start = 0; rw = 0;
            tx_byte = 8'h00; num_bytes = 8'd0;
            slave_drive_low = 0;
            bytes_enviados_master = 0; bytes_recibidos_master = 0;
            #(CLK_PERIOD * 5);
            rst = 0;
            #(CLK_PERIOD * 2);
        end
    endtask

    // Modelo del Esclavo Emulado 

    integer bit_cnt;
    reg [7:0] frame_idx;
    reg [7:0] data_to_master;
    reg [7:0] shift_reg_esclavo;
    reg       slave_rw; // El esclavo guarda la dirección de flujo de forma autónoma

    // Reset de la transacción
    always @(posedge start or posedge rst) begin
        bit_cnt         <= 0;
        frame_idx       <= 0;
        slave_drive_low <= 0;
        slave_rw        <= 0;
    end

    // Muestreo de Datos Seguro: Siempre en el flanco de SUBIDA (SCL Alto = Dato Estable)
    always @(posedge SCL) begin
        if (busy) begin
            if (bit_cnt < 8) begin
                if (frame_idx == 0 || slave_rw == 0) begin
                    shift_reg_esclavo <= {shift_reg_esclavo[6:0], SDA};
                end
            end
            bit_cnt <= bit_cnt + 1;
        end
    end

    // Control del Bus y Respuestas: En el flanco de BAJADA (SCL Bajo = Permitido cambiar SDA)
    always @(negedge SCL) begin
        if (busy) begin
            if (bit_cnt == 8) begin
                // Fin del ciclo de transmisión de datos, flanco previo al ACK (9no pulso)
                if (frame_idx == 0) begin : FRAME_DIRECCION
                    slave_drive_low <= 1; // Responder con ACK
                    slave_rw        <= shift_reg_esclavo[0]; // El bit de dirección real (Bit 0)
                    $display("[TB - Esclavo] Direccion detectada: 0x%h. Modo seteado por Bus: %s", shift_reg_esclavo, shift_reg_esclavo[0] ? "LECTURA" : "ESCRITURA");
                end
                else if (slave_rw == 0) begin : FRAME_ESCRITURA
                    slave_drive_low <= 1; // Responder con ACK al maestro
                    $display("[TB - Esclavo] Recibido byte %0d del Maestro (Valor: 0x%h). Respondiendo con ACK.", bytes_enviados_master + 1, shift_reg_esclavo);
                end
                else begin : FRAME_LECTURA_ACK
                    slave_drive_low <= 0; // El maestro controla el ACK en modo lectura
                end
            end 
            else if (bit_cnt == 9) begin
                // Fin del ciclo de ACK, pasamos al siguiente frame
                bit_cnt         <= 0;
                frame_idx       <= frame_idx + 1;
                
                if (slave_rw == 1) begin
                    data_to_master = (frame_idx + 1 == 1) ? 8'hAB : 8'hCD;
                    slave_drive_low <= ~data_to_master[7];
                end else begin
                    slave_drive_low <= 0;
                end
            end
            else begin
                // Transmisión de los bits restantes (Bit 6 al Bit 0) en modo lectura
                if (slave_rw == 1 && frame_idx > 0) begin
                    if (bit_cnt < 8) begin
                        data_to_master = (frame_idx == 1) ? 8'hAB : 8'hCD;
                        slave_drive_low <= ~data_to_master[7 - bit_cnt];
                    end
                end else begin
                    slave_drive_low <= 0;
                end
            end
        end
    end

    // Contadores estadísticos del Testbench (Ajustado a bit_cnt == 8 debido al nuevo muestreo)
    always @(negedge SCL) begin
        if (busy && bit_cnt == 8) begin
            if (frame_idx != 0) begin
                if (slave_rw == 0) bytes_enviados_master   <= bytes_enviados_master + 1;
                else               bytes_recibidos_master  <= bytes_recibidos_master + 1;
            end
        end
    end

    // Estímulos de Prueba

    initial begin
        $dumpfile("tb_TOP_I2C.vcd");
        $dumpvars(0, tb_TOP_I2C);

        clk = 0;
        aplicar_reset();

        // PRUEBA 1: ESCRITURA DE 2 BYTES DE DATOS

        $display("\n--- Iniciando Transaccion de Escritura (2 Bytes de Datos) ---");

        num_bytes = 8'd3;      // Exactamente 2 bytes de datos
        rw        = 1'b0;      // Operación de escritura
        tx_byte   = 8'h3E;     // Byte de dirección (Bit 0 en '0' para escritura)
        start     = 1'b1;
        #(CLK_PERIOD);
        start     = 1'b0;

        @(posedge byte_done);  
        #(CLK_PERIOD / 4);     // Retardo de seguridad para evitar condiciones de carrera (Setup Time)
        tx_byte   = 8'h11;     
        $display("[TB] Direccion procesada de forma segura. Cargando dato 1: 0x11");

        @(posedge byte_done);  
        #(CLK_PERIOD / 4);     
        tx_byte   = 8'hA5;     
        $display("[TB] Dato 1 procesado de forma segura. Cargando dato 2: 0xA5");

        @(posedge done);
        $display("[TB] Transaccion de Escritura Finalizada de forma exitosa.");
        #(CLK_PERIOD * 20);

        // PRUEBA 2: LECTURA DE 2 BYTES DE DATOS

        $display("\n--- Iniciando Transaccion de Lectura (2 Bytes de Datos) ---");
        bytes_recibidos_master = 0;

        num_bytes = 8'd3;      // Se esperan exactamente 2 bytes
        rw        = 1'b1;      // Operación de lectura
        tx_byte   = 8'h3F;     // Byte de dirección (Bit 0 en '1' para lectura)
        start     = 1'b1;
        #(CLK_PERIOD);
        start     = 1'b0;

        @(posedge byte_done);  
        $display("[TB] Direccion de lectura validada.");

        @(posedge byte_done);  
        $display("[TB] Maestro capto el 1er Byte. Valor: 0x%H (Esperado: 0xAB)", rx_data);

        // El segundo byte provocará la activación de done directo debido al fin del conteo.
        @(posedge done);
        $display("[TB] Maestro capto el 2do Byte. Valor: 0x%H (Esperado: 0xCD)", rx_data);
        $display("[TB] Transaccion de Lectura Finalizada.");

        #(CLK_PERIOD * 20);
        $display("\n--- Todas las pruebas terminaron satisfactoriamente ---");
        $finish;
    end

endmodule