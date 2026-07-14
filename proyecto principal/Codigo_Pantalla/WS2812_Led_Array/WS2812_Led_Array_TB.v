`timescale 1ns/1ps

module WS2812_Led_Array_TB;

reg clk;
reg reset;
reg INIT_M;
reg RST_CMD;
reg [3:0] IMG_SEL;

wire DOUT;
wire DONE_M;

integer cycles;

// ============================
// Reloj
// ============================
initial begin
    clk = 0;
    forever #10 clk = ~clk;   // Periodo de 20 ns
end

// ============================
// DUT
// ============================
WS2812_Led_Array #(
    .ADDR_WIDTH(8),
    .N_LEDS(64)
) uut (
    .clk(clk),
    .reset(reset),

    .INIT_M(INIT_M),
    .RST_CMD(RST_CMD),
    .IMG_SEL(IMG_SEL),

    .DOUT(DOUT),
    .DONE_M(DONE_M)
);

// ============================
// Tarea para enviar una imagen
// ============================
task SEND_IMAGE;
    input [3:0] sel;
    begin
        IMG_SEL = sel;

        case (sel)
            4'd0: $display("Imagen 0");
            4'd1: $display("Imagen 1");
            4'd2: $display("Imagen 2");
            4'd3: $display("Imagen 3");
            default: $display("Imagen no existente, Negro");
        endcase

        @(posedge clk);
        INIT_M = 1'b1;
        @(posedge clk);
        INIT_M = 1'b0;

        wait(DONE_M == 1'b1);

        repeat(10) @(posedge clk);
    end
endtask

// ============================
// Prueba principal
// ============================
initial begin
    $dumpfile("WS2812_Led_Array_TB.vcd");
    $dumpvars(0, WS2812_Led_Array_TB);

    reset   = 1;
    INIT_M  = 0;
    RST_CMD = 0;
    IMG_SEL = 2'd0;

    repeat (5) @(posedge clk);
    reset = 0;

    repeat (5) @(posedge clk);

    SEND_IMAGE(4'd0);
    SEND_IMAGE(4'd1);
    SEND_IMAGE(4'd2);
    SEND_IMAGE(4'd3);

    $display("========================================");
    $display("Prueba completa de las 4 imagenes terminada");
    $display("========================================");

    repeat (20) @(posedge clk);
    $finish;
end

// ============================
// Monitor simple
// ============================
always @(posedge clk) begin
    if (!reset) begin

        if (uut.INIT_LED) begin
            $display("Tiempo %0t | IMG_SEL=%0d | INIT_LED=1 | ADDR=%0d | RGB=%h",
                     $time, IMG_SEL, uut.ADDR, uut.RGB);
        end

        if (uut.DONE_LED) begin
            $display("Tiempo %0t | IMG_SEL=%0d | DONE_LED=1 | LED terminado | ADDR=%0d",
                     $time, IMG_SEL, uut.ADDR);
        end

        if (uut.INC) begin
            $display("Tiempo %0t | IMG_SEL=%0d | INC=1 | incrementando ADDR",
                     $time, IMG_SEL);
        end

    end
end

endmodule