`timescale 1ns/1ps

module WS2812_led_TB;

reg clk = 0;
reg reset = 1;
reg INIT = 0;
reg RST_CMD = 0;
reg [23:0] RGB = 24'h000000;

wire DOUT;
wire DONE;

parameter TCK = 20;   // 50 MHz

always #(TCK/2) clk = ~clk;

WS2812_led uut (
    .clk     (clk),
    .reset   (reset),
    .INIT    (INIT),
    .RGB     (RGB),
    .RST_CMD (RST_CMD),
    .DOUT    (DOUT),
    .DONE    (DONE)
);

task pulse_init;
begin
    @(posedge clk);
    INIT <= 1'b1;
    @(posedge clk);
    INIT <= 1'b0;
end
endtask

task wait_done;
    input [31:0] max_cycles;
    integer i;
begin
    i = 0;

    while ((DONE !== 1'b1) && (i < max_cycles)) begin
        @(posedge clk);
        i = i + 1;
    end

    if (i == max_cycles) begin
        $display("ERROR: timeout esperando DONE");
        $finish;
    end
    else begin
        $display("DONE detectado en tiempo %0t despues de %0d ciclos", $time, i);
    end

    @(posedge clk);
end
endtask

always @(posedge clk) begin
    if (uut.w_INIT_T) begin
        $display("t=%0t BIT=%0d COUNT=%0d RGB_MSB=%b SEL=%b",
                 $time,
                 25 - uut.w_COUNT,
                 uut.w_COUNT,
                 uut.w_RGB_MSB,
                 uut.w_SEL);
    end
end


initial begin
    $dumpfile("WS2812_led_TB.vcd");
    $dumpvars(-1, WS2812_led_TB);

    $display("Inicio simulacion WS2812_led");

    reset = 1'b1;
    INIT = 1'b0;
    RST_CMD = 1'b0;
    RGB = 24'h000000;

    repeat (5) @(posedge clk);
    reset = 1'b0;
    repeat (5) @(posedge clk);

    // =========================
    // Prueba 1: VERDE puro
    // WS2812 usa orden GRB:
    // G=FF, R=00, B=00
    // =========================
    RGB = 24'hFF0000;
    RST_CMD = 1'b0;

    $display("\n--- Enviando VERDE ---");
    $display("RGB(GRB) = %h", RGB);
    pulse_init();
    wait_done(32'd200000);

    repeat (20) @(posedge clk);

    // Reset para latch del WS2812
    RST_CMD = 1'b1;
    $display("--- Enviando RESET despues de VERDE ---");
    pulse_init();
    wait_done(32'd200000);

    repeat (20) @(posedge clk);

    // =========================
    // Prueba 2: ROJO puro
    // G=00, R=FF, B=00
    // =========================
    RGB = 24'h00FF00;
    RST_CMD = 1'b0;

    $display("\n--- Enviando ROJO ---");
    $display("RGB(GRB) = %h", RGB);
    pulse_init();
    wait_done(32'd200000);

    repeat (20) @(posedge clk);

    RST_CMD = 1'b1;
    $display("--- Enviando RESET despues de ROJO ---");
    pulse_init();
    wait_done(32'd200000);

    repeat (20) @(posedge clk);

    // =========================
    // Prueba 3: AZUL puro
    // G=00, R=00, B=FF
    // =========================
    RGB = 24'h0000FF;
    RST_CMD = 1'b0;

    $display("\n--- Enviando AZUL ---");
    $display("RGB(GRB) = %h", RGB);
    pulse_init();
    wait_done(32'd200000);

    repeat (20) @(posedge clk);

    RST_CMD = 1'b1;
    $display("--- Enviando RESET despues de AZUL ---");
    pulse_init();
    wait_done(32'd200000);

    repeat (20) @(posedge clk);

    $display("\nFin simulacion WS2812_led");
    $finish;
end

endmodule