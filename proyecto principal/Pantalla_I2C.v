module Pantalla_I2C #(
    parameter ADDR_WIDTH   = 8,
    parameter N_LEDS       = 64,

    parameter [15:0] UMBRAL_1 = 16'd6000,   // frontera neutral(encharcado) <-> feliz
    parameter [15:0] UMBRAL_2 = 16'd15000,  // frontera feliz <-> seria
    parameter [15:0] UMBRAL_3 = 16'd24000   // frontera seria <-> triste (muy seco)
)(
    input  wire        clk,
    input  wire        reset,

    input  wire [15:0] adc_value,   // valor actual del ADS1115
    input  wire        adc_valid,   // 1 = adc_value contiene una lectura real
    input  wire        adc_error,   // 1 = error de I2C (ack_error) -> forzar X de error

    output wire         DOUT,
    output wire         DONE_M
);

reg [3:0] active_img_sel  = 4'd0;  // Imagen que se está enviando al core
reg [3:0] pending_img_sel = 4'd0;  // Última clasificación pendiente de enviar

reg request_send = 1'b0;
reg core_busy    = 1'b0;
reg init_m       = 1'b0;

wire [3:0] img_sel_actual;
wire       done_core;

assign DONE_M = done_core;

// adc_value ALTO = tierra seca | adc_value BAJO = tierra humeda
assign img_sel_actual =
        (adc_error)                 ? 4'd4 :  // error de I2C -> X
        (!adc_valid)                ? 4'd0 :  // sin lectura real todavia -> neutral
        (adc_value > UMBRAL_3)      ? 4'd3 :  // muy seco          -> triste
        (adc_value > UMBRAL_2)      ? 4'd2 :  // seco, poca humedad -> seria
        (adc_value > UMBRAL_1)      ? 4'd1 :  // humedad buena     -> feliz
                                       4'd0;   // muy humedo/encharcado -> neutral

always @(posedge clk) begin
    if (reset) begin
        active_img_sel  <= 4'd0;
        pending_img_sel <= 4'd0;
        request_send    <= 1'b0;
        core_busy       <= 1'b0;
        init_m          <= 1'b0;
    end
    else begin

        init_m <= 1'b0;

        if (done_core) begin
            core_busy <= 1'b0;
        end

        if (img_sel_actual != pending_img_sel) begin
            pending_img_sel <= img_sel_actual;
            request_send    <= 1'b1;
        end

        if (request_send && !core_busy) begin
            active_img_sel <= pending_img_sel;
            init_m         <= 1'b1;
            core_busy      <= 1'b1;
            request_send   <= 1'b0;
        end
    end
end

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