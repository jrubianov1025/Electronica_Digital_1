`timescale 1ns/1ps

module Pantalla_TB;

    // ------------------------------------------------------------
    // Señales del testbench
    // ------------------------------------------------------------
    reg clk;
    reg reset;
    reg sensor;

    wire DOUT;
    wire DONE_M;

    // ------------------------------------------------------------
    // Instancia del DUT
    // TIMEOUT_CYCLES pequeño para que la simulación sea rápida.
    // N_LEDS pequeño para no esperar los 64 LEDs en cada prueba.
    // ------------------------------------------------------------
    Pantalla #(
        .TIMEOUT_CYCLES(32'd50),
        .ADDR_WIDTH(8),
        .N_LEDS(8)
    ) uut (
        .clk(clk),
        .reset(reset),
        .sensor(sensor),
        .DOUT(DOUT),
        .DONE_M(DONE_M)
    );

    // ------------------------------------------------------------
    // Reloj
    // ------------------------------------------------------------
    initial begin
        clk = 1'b0;
        forever #10 clk = ~clk;   // periodo = 20 ns
    end

    // ------------------------------------------------------------
    // Generar un pulso del sensor
    // ------------------------------------------------------------
    task SENSOR_PULSE;
        begin
            sensor = 1'b0;
            repeat(5) @(posedge clk);

            sensor = 1'b1;
            repeat(5) @(posedge clk);

            sensor = 1'b0;
            repeat(10) @(posedge clk);
        end
    endtask

    // ------------------------------------------------------------
    // Enviar N pulsos por el sensor
    // ------------------------------------------------------------
    task SEND_SENSOR_PULSES;
        input integer n_pulses;
        integer i;
        begin
            $display("\n========================================");
            $display("Enviando %0d pulsos por sensor", n_pulses);
            $display("========================================");

            for (i = 0; i < n_pulses; i = i + 1) begin
                SENSOR_PULSE();
            end

            // Esperar a que se cumpla el timeout interno
            repeat(80) @(posedge clk);
        end
    endtask

    // ------------------------------------------------------------
    // Esperar fin de imagen
    // ------------------------------------------------------------
    task WAIT_IMAGE_DONE;
        begin
            wait(DONE_M == 1'b1);
            @(posedge clk);
            $display("Tiempo %0t | DONE_M=1 | Imagen terminada | active_img_sel=%0d",
                     $time, uut.active_img_sel);

            // Esperar a que el sistema salga del done
            repeat(20) @(posedge clk);
        end
    endtask

    // ------------------------------------------------------------
    // Proceso principal de prueba
    // ------------------------------------------------------------
    initial begin
        $dumpfile("Pantalla_TB.vcd");
        $dumpvars(0, Pantalla_TB);

        sensor = 1'b0;
        reset  = 1'b1;

        repeat(10) @(posedge clk);
        reset = 1'b0;

        $display("\nInicio de simulacion Pantalla_TB");

        // Al arrancar, Pantalla debe mandar Image_0 automaticamente
        $display("\nEsperando envio inicial de Image_0...");
        WAIT_IMAGE_DONE();

        // 1 pulso -> Image_1
        SEND_SENSOR_PULSES(1);
        WAIT_IMAGE_DONE();

        // 2 pulsos -> Image_2
        SEND_SENSOR_PULSES(2);
        WAIT_IMAGE_DONE();

        // 3 pulsos -> Image_3
        SEND_SENSOR_PULSES(3);
        WAIT_IMAGE_DONE();

        // 4 pulsos -> Image_4, que por ahora debe quedar en negro
        SEND_SENSOR_PULSES(4);
        WAIT_IMAGE_DONE();

        $display("\nFin de simulacion Pantalla_TB");
        $finish;
    end

    // ------------------------------------------------------------
    // Monitor de eventos importantes
    // ------------------------------------------------------------
    always @(posedge clk) begin
        if (!reset) begin

            if (uut.sensor_rise) begin
                $display("Tiempo %0t | sensor_rise=1 | temp_img_sel=%0d",
                         $time, uut.temp_img_sel);
            end

            if (uut.receiving) begin
                if (uut.timeout_count == 0) begin
                    $display("Tiempo %0t | Recibiendo rafaga | temp_img_sel=%0d",
                             $time, uut.temp_img_sel);
                end
            end

            if (uut.init_m) begin
                $display("Tiempo %0t | INIT_M=1 | Enviando imagen active_img_sel=%0d",
                         $time, uut.active_img_sel);
            end

            if (DONE_M) begin
                $display("Tiempo %0t | DONE_M=1 | Core termino imagen %0d",
                         $time, uut.active_img_sel);
            end

        end
    end

endmodule
