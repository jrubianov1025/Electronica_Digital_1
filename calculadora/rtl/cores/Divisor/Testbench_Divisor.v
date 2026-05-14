
`timescale 1ns/1ps

module tb_Periferico_Divisor;

reg clk;
reg reset;

reg [31:0] d_in;
reg cs;
reg [4:0] addr;
reg rd;
reg wr;

wire [31:0] d_out;

//====================================================
// DUT
//====================================================

Periferico_Divisor DUT(

    .clk(clk),
    .reset(reset),

    .d_in(d_in),
    .cs(cs),
    .addr(addr),
    .rd(rd),
    .wr(wr),

    .d_out(d_out)

);

//====================================================
// CLOCK
//====================================================

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

//====================================================
// GTKWave
//====================================================

initial begin

    $dumpfile("periferico_divisor.vcd");
    $dumpvars(0, tb_Periferico_Divisor);

end

//====================================================
// WRITE
//====================================================

task write_reg;

    input [4:0] address;
    input [31:0] data;

    begin

        @(posedge clk);

        cs   <= 1'b1;
        wr   <= 1'b1;
        rd   <= 1'b0;

        addr <= address;
        d_in <= data;

        @(posedge clk);

        cs   <= 1'b0;
        wr   <= 1'b0;

        addr <= 5'd0;
        d_in <= 32'd0;

    end

endtask

//====================================================
// READ
//====================================================

task read_reg;

    input [4:0] address;

    begin

        @(posedge clk);

        cs   <= 1'b1;
        rd   <= 1'b1;
        wr   <= 1'b0;

        addr <= address;

        @(posedge clk);

        $display("--------------------------------");
        $display("ADDR  = %h", address);
        $display("D_OUT = %0d", d_out);
        $display("--------------------------------");

        cs   <= 1'b0;
        rd   <= 1'b0;

        addr <= 5'd0;

    end

endtask

//====================================================
// TEST
//====================================================

initial begin

    reset = 1'b1;

    cs   = 0;
    rd   = 0;
    wr   = 0;

    addr = 0;
    d_in = 0;

    #20;

    reset = 1'b0;

    //========================================
    // Dividendo = 100
    //========================================

    write_reg(5'h04, 32'd100);

    //========================================
    // Divisor = 7
    //========================================

    write_reg(5'h08, 32'd7);

    //========================================
    // INIT
    //========================================

    write_reg(5'h0C, 32'd1);

    //========================================
    // Esperar DONE
    //========================================

    wait(DUT.DONE == 1'b1);

    #20;

    //========================================
    // Leer resultado
    //========================================

    read_reg(5'h10);

    //========================================
    // Leer residuo
    //========================================

    read_reg(5'h14);

    //========================================
    // Leer DONE
    //========================================

    read_reg(5'h18);

    #100;

    $finish;

end

endmodule



/*
`timescale 1ns/1ps

module tb_Divisor_Top;

    // =========================================================
    // PARAMETROS
    // =========================================================
    parameter width = 31;

    // =========================================================
    // ENTRADAS
    // =========================================================
    reg clk;
    reg init;

    reg signed [width:0] Dividendo;
    reg signed [width:0] DR;

    // =========================================================
    // SALIDAS
    // =========================================================
    wire signed [width:0] Residuo;
    wire signed [width:0] Resultado;
    wire DONE;

    // =========================================================
    // INSTANCIA DEL DUT
    // =========================================================
    Divisor_Top #(width) DUT (
        .clk        (clk),
        .init       (init),
        .Dividendo  (Dividendo),
        .DR         (DR),
        .Residuo    (Residuo),
        .Resultado  (Resultado),
        .DONE       (DONE)
    );

    // =========================================================
    // CLOCK
    // =========================================================
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // =========================================================
    // VARIABLES DEBUG
    // =========================================================
    integer ciclo;

    // NOMBRE DEL ESTADO
    reg [63:0] estado_nombre;
    always @(*) begin
        case (DUT.control.NEXT_STATE)
            3'b000: estado_nombre = "START  ";
            3'b001: estado_nombre = "SHIFT  ";
            3'b010: estado_nombre = "CHECK  ";
            3'b011: estado_nombre = "ONE    ";
            3'b100: estado_nombre = "CORRECT";
            3'b101: estado_nombre = "END    ";
            default: estado_nombre = "UNKNOWN";
        endcase
    end

    // =========================================================
    // GENERAR VCD
    // =========================================================
    initial begin
        $dumpfile("divisor_debug.vcd");
        $dumpvars(0, tb_Divisor_Top);
    end

    // =========================================================
    // HEADER TABLA
    // =========================================================
    initial begin
        $display("");
        $display("========================================================================================================================================================================================");
        $display("Tiempo | Ciclo | Estado  |LD|SH|DC|DV0|Z|M|CNT| A (Residuo_NS)                   | DV (Resultado_NS)                | SUM_C2_out                      ");
        $display("========================================================================================================================================================================================");
    end

    // =========================================================
    // DEBUG CICLO A CICLO
    // =========================================================
    always @(posedge clk) begin
        ciclo = ciclo + 1;
        $display("%6t | %5d | %s | %b| %b| %b| %b |%b|%b| %2d | %032b (%0d) | %032b (%0d) | %032b (%0d)",
            $time,
            ciclo,
            estado_nombre,
            DUT.LD,
            DUT.SH,
            DUT.DEC,
            DUT.DV0,
            DUT.Z,
            DUT.MSB,
            DUT.contador.out,
            DUT.Residuo_NS,   $signed(DUT.Residuo_NS),
            DUT.Resultado_NS, $signed(DUT.Resultado_NS),
            DUT.SUM_C2_out,   $signed(DUT.SUM_C2_out)
        );
    end

    // =========================================================
    // ESTIMULOS — cambia aqui los valores a probar
    // =========================================================
    initial begin
        ciclo    = 0;
        init     = 0;

        // -----------------------------------------------------
        // CASO ACTIVO — descomenta el que quieras probar
        // -----------------------------------------------------

        // positivo / positivo
        //Dividendo =  32'd25;
        //DR        =  32'd3;

        // negativo / positivo
        // Dividendo = -32'd25;
        // DR        =  32'd3;

        // positivo / negativo
        // Dividendo =  32'd25;
        // DR        = -32'd3;

        // negativo / negativo
        // Dividendo = -32'd25;
        // DR        = -32'd3;

        #20;
        init = 1;
        #10;
        init = 0;

        #1000;

        $display("");
        $display("==========================================================");
        $display("TIMEOUT");
        $display("Resultado = %032b (%0d)", Resultado, $signed(Resultado));
        $display("Residuo   = %032b (%0d)", Residuo,   $signed(Residuo));
        $display("DONE      = %b", DONE);
        $display("==========================================================");
        $finish;
    end

    // =========================================================
    // FINALIZAR SI DONE
    // =========================================================
    always @(posedge clk) begin
        if (DONE) begin
            $display("");
            $display("==========================================================");
            $display("DIVISION TERMINADA - Tiempo: %0t", $time);
            $display("Dividendo = %0d", $signed(Dividendo));
            $display("DR        = %0d", $signed(DR));
            $display("Resultado = %032b (%0d)", Resultado, $signed(Resultado));
            $display("Residuo   = %032b (%0d)", Residuo,   $signed(Residuo));
            $display("==========================================================");
            #20;
            $finish;
        end
    end

endmodule*/