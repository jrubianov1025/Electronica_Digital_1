`timescale 1ns/1ps
module tb_Periferico_BinarioABCD;

// Señales del bus
reg         CLK;
reg         reset;
reg         cs;
reg         rd;
reg         wr;
reg  [5:0]  addr;
reg  [23:0] d_in;
wire [31:0] d_out;

// Instancia del periférico
Periferico_BinarioABCD DUT (
    .CLK  (CLK  ),
    .reset(reset),
    .d_in (d_in ),
    .cs   (cs   ),
    .addr (addr ),
    .rd   (rd   ),
    .wr   (wr   ),
    .d_out(d_out)
);

// Generador de reloj
initial CLK = 0;
always #5 CLK = ~CLK;   // 10 ns de periodo (100 MHz)

// Archivo de ondas
initial begin
    $dumpfile("BinarioABCD.vcd");
    $dumpvars(0, tb_Periferico_BinarioABCD);
end

// ─── Tareas ───────────────────────────────────────────────────────────────────

task write_reg;
    input [5:0]  addr_in;
    input [23:0] data;
    begin
        @(negedge CLK);
        cs   = 1;
        wr   = 1;
        rd   = 0;
        addr = addr_in;
        d_in = data;
        @(negedge CLK);
        cs   = 0;
        wr   = 0;
        d_in = 0;
    end
endtask

task read_reg;
    input [5:0] addr_in;
    begin
        @(negedge CLK);
        cs   = 1;
        rd   = 1;
        wr   = 0;
        addr = addr_in;
        @(negedge CLK);
        $display("Tiempo=%0t ns | READ addr=%h -> d_out=%h", $time, addr_in, d_out);
        cs   = 0;
        rd   = 0;
    end
endtask

// Decodifica d_out[31:0] = {SIGN,MILLON,CIENMIL,DIEZMIL,MIL,CENT,DEC,UNIT}
task mostrar_resultado;
    begin
        read_reg(6'h0C); // lee RESULT
        $display("  SIGN=%0d | %0d,%0d%0d%0d,%0d%0d%0d",
            d_out[31:28],           // SIGN
            d_out[27:24],           // MILLON
            d_out[23:20],           // CIENMIL
            d_out[19:16],           // DIEZMIL
            d_out[15:12],           // MIL
            d_out[11:8],            // CENT
            d_out[7:4],             // DEC
            d_out[3:0]              // UNIT
        );
    end
endtask

// ─── Esperar DONE o timeout ────────────────────────────────────────────────────

task wait_done;
    reg [8:0] contador;
    begin
        contador = 0;
        while (contador < 9'd300) begin
            read_reg(6'h10);        // lee DONE
            if (d_out[0] == 1'b1) begin
                $display("Tiempo=%0t ns | DONE detectado (iter=%0d).", $time, contador);
                contador = 9'd300;  // salir
            end else begin
                contador = contador + 1;
            end
        end
        if (d_out[0] == 1'b0)
            $display("ERROR: Timeout esperando DONE.");
    end
endtask

// ─── Helper: escribe Op_A e INIT, espera DONE y muestra resultado ─────────────

task run_test;
    input signed [23:0] operando;
    begin
        write_reg(6'h04, operando); // Op_A (24 bits, puede ser negativo)
        write_reg(6'h08, 24'h1);    // INIT = 1
        write_reg(6'h08, 24'h0);    // INIT = 0 (pulso de 1 ciclo)
        wait_done();
        mostrar_resultado();
    end
endtask

// ─── Secuencia principal de prueba ────────────────────────────────────────────

initial begin
    // Inicialización
    reset = 1;
    cs    = 0;
    rd    = 0;
    wr    = 0;
    addr  = 0;
    d_in  = 0;

    // Reset por 4 ciclos
    repeat(4) @(negedge CLK);
    reset = 0;

    $display("\n=== INICIO DE SIMULACIÓN BinarioABCD ===\n");

    // ── Test 1: número positivo pequeño ──
    //$display("--- Test 1: +123 ---");
    //run_test(24'sd123);

    // ── Test 2: número positivo grande ──
    //$display("--- Test 2: +1234567 ---");
    //run_test(24'sd1234567);

    // ── Test 3: número negativo ──
    //$display("--- Test 3: -456 ---");
    //run_test(-24'sd456);

    // ── Test 4: cero ──
    //$display("--- Test 4: 0 ---");
    //run_test(24'sd0);

    // ── Test 5: máximo positivo 24 bits signed (8388607) ──
    //$display("--- Test 5: +8388607 (max) ---");
    //run_test(24'sd8388607);

    // ── Test 6: máximo negativo 24 bits signed (-8388608) ──
    //$display("--- Test 6: -8388608 (min) ---");
    //run_test(-24'sd8388608);

    $display("\n=== FIN DE SIMULACIÓN ===");
    #20 $finish;
end

endmodule
