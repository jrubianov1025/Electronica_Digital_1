`timescale 1ns/1ps
module bench();

parameter tck          = 40;   // 25 MHz → periodo = 40ns
parameter c_BIT_PERIOD = 8680; // 115200 baud → 1/115200 ≈ 8680ns

reg CLK   = 0;
reg RESET;
reg RXD   = 1'b1;
wire TXD;
wire LEDS;

always #(tck/2) CLK = ~CLK;

// ─── Tarea UART ───────────────────────────────────────────
task UART_WRITE_BYTE;
    input [7:0] i_Data;
    integer ii;
    begin
        RXD <= 1'b0;           // Start bit
        #(c_BIT_PERIOD);
        for (ii = 0; ii < 8; ii = ii + 1) begin
            RXD <= i_Data[ii]; // 8 bits LSB primero
            #(c_BIT_PERIOD);
        end
        RXD <= 1'b1;           // Stop bit
        #(c_BIT_PERIOD);
    end
endtask

// ─── Instancia SOC ────────────────────────────────────────
SOC uut(
    .clk(CLK),
    .resetn(RESET),
    .LEDS(LEDS),
    .RXD(RXD),
    .TXD(TXD)
);

// ─── Monitor de LEDs ──────────────────────────────────────
always @(LEDS) begin
    $display("LEDS = %b  (t = %0t ns)", LEDS, $time);
end

// ─── Dump VCD ─────────────────────────────────────────────
integer idx;
initial begin
    $dumpfile("bench.vcd");
    $dumpvars(0, bench);
    `ifndef SYNTH
        for (idx = 0; idx < 32; idx = idx + 1)
            $dumpvars(0, bench.uut.CPU.registerFile[idx]);
    `endif
end

// ─── Estímulos ────────────────────────────────────────────
initial begin
    // Reset
    RESET = 0;
    #(tck * 20);   // 20 ciclos = 800ns
    RESET = 1;

    // Esperar que el CPU arranque y muestre el prompt
    @(posedge CLK);
    #(tck * 60000);

    // ── PRUEBA 1: RAÍZ de 1234 ──────────────────────
/*    //UART_WRITE_BYTE(8'h2D); // '-'
    //#(tck * 1500);
    UART_WRITE_BYTE(8'h31); // '1'
    #(tck * 1500);
    UART_WRITE_BYTE(8'h32); // '2'
    #(tck * 1500);
    UART_WRITE_BYTE(8'h33); // '3'
    #(tck * 1500);
    UART_WRITE_BYTE(8'h34); // '4'
    #(tck * 1500);
    UART_WRITE_BYTE(8'h0D); // Enter
    #(tck * 2500);
    UART_WRITE_BYTE(8'h40); // '@' raíz
 
*/
  // ── PRUEBA 2: SUMA o resta 1234 ──────────────────────
/*
    UART_WRITE_BYTE(8'h31); // '1'
    #(tck * 1500);
    UART_WRITE_BYTE(8'h32); // '2'
    #(tck * 1500);
    UART_WRITE_BYTE(8'h33); // '3'
    #(tck * 1500);
    UART_WRITE_BYTE(8'h34); // '4'
    #(tck * 1500);
    UART_WRITE_BYTE(8'h0D); // Enter
    #(tck * 25000);
    //UART_WRITE_BYTE(8'h2B); // '+'
    UART_WRITE_BYTE(8'h2D); // '-'
    #(tck * 25000);
    UART_WRITE_BYTE(8'h31); // '1'
    #(tck * 1500);
    UART_WRITE_BYTE(8'h32); // '2'
    #(tck * 1500);
    UART_WRITE_BYTE(8'h33); // '3'
    #(tck * 1500);
    UART_WRITE_BYTE(8'h34); // '4'
    #(tck * 1500);
    UART_WRITE_BYTE(8'h0D); // Enter
    #(tck * 2500);
*/

    // ── PRUEBA 3: MULTIPLICACIÓN -12 * -3 ───────────
/*
    UART_WRITE_BYTE(8'h2D); // '-'
    #(tck * 1500);
    UART_WRITE_BYTE(8'h31); // '1'
    #(tck * 1500);
    UART_WRITE_BYTE(8'h32); // '2'
    #(tck * 1500);
    UART_WRITE_BYTE(8'h0D); // Enter
    #(tck * 25000);
    UART_WRITE_BYTE(8'h2A); // '*'
    #(tck * 25000);
    UART_WRITE_BYTE(8'h2D); // '-'
    #(tck * 1500);
    UART_WRITE_BYTE(8'h33); // '3'
    #(tck * 1500);
    UART_WRITE_BYTE(8'h0D); // Enter
    #(tck * 25000);
*/

    // ── PRUEBA 4: DIVISIÓN -100 / 4 ─────────────────
/*
    UART_WRITE_BYTE(8'h2D); // '-'
    #(tck * 1500);
    UART_WRITE_BYTE(8'h31); // '1'
    #(tck * 1500);
    UART_WRITE_BYTE(8'h30); // '0'
    #(tck * 1500);
    UART_WRITE_BYTE(8'h30); // '0'
    #(tck * 1500);
    UART_WRITE_BYTE(8'h0D); // Enter
    #(tck * 25000);
    UART_WRITE_BYTE(8'h2F); // '/'
    #(tck * 25000);
    UART_WRITE_BYTE(8'h34); // '4'
    #(tck * 1500);
    UART_WRITE_BYTE(8'h0D); // Enter
    #(tck * 25000);
*/

    #(tck * 300000);
    $finish;
end

endmodule