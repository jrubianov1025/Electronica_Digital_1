module Pantalla #(
    parameter TIMEOUT_CYCLES = 32'd250000,
    parameter ADDR_WIDTH = 8,
    parameter N_LEDS = 64
)(
    input  wire clk,
    input  wire reset,
    input  wire sensor,

    output wire DOUT,
    output wire DONE_M
);

    // ------------------------------------------------------------
    // Señales internas
    // ------------------------------------------------------------
    reg [3:0] active_img_sel  = 4'd0;  // Imagen que se está enviando al core
    reg [3:0] pending_img_sel = 4'd0;  // Imagen nueva ya recibida por sensor
    reg [3:0] temp_img_sel    = 4'd0;  // Conteo temporal de pulsos

    reg sensor_meta = 1'b0;
    reg sensor_sync = 1'b0;
    reg sensor_prev = 1'b0;

    reg receiving = 1'b0;
    reg request_send = 1'b0;
    reg core_busy = 1'b0;
    reg startup_done = 1'b0;

    reg init_m = 1'b0;

    reg [31:0] timeout_count = 32'd0;

    wire sensor_rise;
    wire done_core;

    assign sensor_rise = sensor_sync & ~sensor_prev;
    assign DONE_M = done_core;

    // ------------------------------------------------------------
    // Interpretación del sensor serial
    // ------------------------------------------------------------
    always @(posedge clk) begin
        if (reset) begin
            sensor_meta     <= 1'b0;
            sensor_sync     <= 1'b0;
            sensor_prev     <= 1'b0;

            active_img_sel  <= 4'd0;
            pending_img_sel <= 4'd0;
            temp_img_sel    <= 4'd0;

            receiving       <= 1'b0;
            request_send    <= 1'b0;
            core_busy       <= 1'b0;
            startup_done    <= 1'b0;

            init_m          <= 1'b0;
            timeout_count   <= 32'd0;
        end
        else begin
            // Sincronización de la señal externa del sensor
            sensor_meta <= sensor;
            sensor_sync <= sensor_meta;
            sensor_prev <= sensor_sync;

            // INIT_M será un pulso de un ciclo
            init_m <= 1'b0;

            // Cuando el core termina de mandar la imagen, queda libre
            if (done_core) begin
                core_busy <= 1'b0;
            end

            // Al arrancar, manda la imagen 0 automáticamente
            if (!startup_done) begin
                startup_done    <= 1'b1;
                pending_img_sel <= 4'd0;
                request_send    <= 1'b1;
            end

            // Detecta pulsos del sensor y los cuenta
            if (sensor_rise) begin
                if (!receiving) begin
                    receiving     <= 1'b1;
                    temp_img_sel  <= 4'd1;
                    timeout_count <= 32'd0;
                end
                else begin
                    temp_img_sel  <= temp_img_sel + 4'd1;
                    timeout_count <= 32'd0;
                end
            end

            // Si ya empezó una ráfaga de pulsos, espera a que termine
            else if (receiving) begin
                if (timeout_count >= TIMEOUT_CYCLES) begin
                    receiving       <= 1'b0;
                    pending_img_sel <= temp_img_sel;
                    request_send    <= 1'b1;
                    timeout_count   <= 32'd0;
                end
                else begin
                    timeout_count <= timeout_count + 32'd1;
                end
            end

            // Cuando hay una imagen pendiente y el core está libre,
            // se actualiza IMG_SEL y se inicia el envío.
            if (request_send && !core_busy && !receiving) begin
                active_img_sel <= pending_img_sel;
                init_m         <= 1'b1;
                core_busy      <= 1'b1;
                request_send   <= 1'b0;
            end
        end
    end

    // ------------------------------------------------------------
    // Core de la pantalla WS2812
    // ------------------------------------------------------------
    WS2812_Led_Array #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .N_LEDS(N_LEDS)
    ) core_pantalla (
        .clk(clk),
        .reset(reset),

        .INIT_M(init_m),
        .RST_CMD(1'b0),
        .IMG_SEL(active_img_sel),

        .DOUT(DOUT),
        .DONE_M(done_core)
    );

endmodule
