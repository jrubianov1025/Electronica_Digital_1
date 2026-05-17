// ============================================================
// TESTBENCH DEBUG BINARIO -> BCD
// ============================================================
// Este testbench está pensado específicamente para:
//
// 1. Ver el algoritmo Double Dabble paso a paso
// 2. Ver TODOS los registros internos
// 3. Ver cada nibble BCD individualmente
// 4. Ver los shifts ciclo por ciclo
// 5. Detectar errores en ADD3
// 6. Visualizar claramente A y Op_A
//
// ============================================================

`timescale 1ns/1ps

module tb_BinarioABCD_Debug;

    // ========================================================
    // ENTRADAS
    // ========================================================
    reg CLK;
    reg INIT;

    reg signed [23:0] Op_A;

    // ========================================================
    // SALIDAS
    // ========================================================
    wire [3:0] SIGN;

    wire [3:0] MILLON;
    wire [3:0] CIENMIL;
    wire [3:0] DIEZMIL;
    wire [3:0] MIL;
    wire [3:0] CENT;
    wire [3:0] DEC;
    wire [3:0] UNIT;

    wire DONE;

    // ========================================================
    // INSTANCIA DEL DUT
    // ========================================================
    BinarioABCD DUT(

        .CLK(CLK),
        .Op_A(Op_A),
        .INIT(INIT),

        .SIGN(SIGN),

        .MILLON(MILLON),
        .CIENMIL(CIENMIL),
        .DIEZMIL(DIEZMIL),
        .MIL(MIL),
        .CENT(CENT),
        .DEC(DEC),
        .UNIT(UNIT),

        .DONE(DONE)
    );

    // ========================================================
    // CLOCK
    // ========================================================
    initial begin
        CLK = 0;
        forever #5 CLK = ~CLK;
    end

    // ========================================================
    // VARIABLES DEBUG
    // ========================================================
    integer ciclo;

    // ========================================================
    // NOMBRE DEL ESTADO
    // ========================================================
    reg [80:0] estado_nombre;

    always @(*) begin

        case(DUT.CONTROL_BBCD0.NEXT_STATE)

            3'b000: estado_nombre = "START";
            3'b001: estado_nombre = "SUM";
            3'b010: estado_nombre = "SHIFT_DEC";
            3'b011: estado_nombre = "CHECK";
            3'b100: estado_nombre = "END";

            default: estado_nombre = "UNKNOWN";

        endcase
    end

    // ========================================================
    // VCD
    // ========================================================
    initial begin

        $dumpfile("BinarioABCD_debug.vcd");
        $dumpvars(0, tb_BinarioABCD_Debug);

    end

    // ========================================================
    // HEADER
    // ========================================================
    initial begin

        $display("");
        $display("===============================================================================================================================================================================");
        $display("TIME | CICLO | ESTADO     |LD|SH|ADD3|DEC|Z|DONE|A (BCD)                              | Op_A                                | BCD DIGITS");
        $display("===============================================================================================================================================================================");

    end

    // ========================================================
    // DEBUG CICLO A CICLO
    // ========================================================
    always @(posedge CLK) begin

        ciclo = ciclo + 1;

        $display(

        "%5t | %5d | %s | %b | %b |  %b  | %b |%b|  %b | %028b | %024b | %1d %1d %1d %1d %1d %1d %1d",

            $time,
            ciclo,

            estado_nombre,

            DUT.W_LD,
            DUT.W_SH,
            DUT.W_ADD3,
            DUT.W_DEC,

            DUT.W_Z,
            DONE,

            DUT.LSR_BBCD0.A,
            DUT.LSR_BBCD0.Op_A,

            MILLON,
            CIENMIL,
            DIEZMIL,
            MIL,
            CENT,
            DEC,
            UNIT
        );
    end

    // ========================================================
    // ESTÍMULOS
    // ========================================================
    initial begin

        ciclo = 0;

        INIT = 0;
        Op_A = 0;

        // ====================================================
        // CAMBIAR AQUÍ EL NÚMERO A PROBAR
        // ====================================================

        // POSITIVO
        //Op_A = 24'd1234567;

        // NEGATIVO
        // Op_A = -24'd765432;

        // PEQUEÑO
        // Op_A = 24'd13;

        // MÁXIMO POSITIVO
        // Op_A = 24'd8388607;

        // MÁXIMO NEGATIVO
        // Op_A = -24'd8388608;

        // ====================================================

        #20;

        INIT = 1;

        #10;

        INIT = 0;

        #5000;

        $display("");
        $display("=========================================================");
        $display("TIMEOUT");
        $display("=========================================================");

        $finish;

    end

    // ========================================================
    // FINALIZAR CUANDO DONE
    // ========================================================
    always @(posedge CLK) begin

        if(DONE) begin

            $display("");
            $display("=========================================================");
            $display("CONVERSION TERMINADA");
            $display("Tiempo = %0t", $time);
            $display("=========================================================");

            $display("");

            $display("Numero Binario = %0d", Op_A);

            if(SIGN == 4'hA)
                $display("Signo = NEGATIVO");
            else
                $display("Signo = POSITIVO");

            $display("");

            $display(
                "BCD FINAL = %1d %1d %1d %1d %1d %1d %1d",
                MILLON,
                CIENMIL,
                DIEZMIL,
                MIL,
                CENT,
                DEC,
                UNIT
            );

            $display("");

            $display("A FINAL    = %028b", DUT.LSR_BBCD0.A);
            $display("Op_A FINAL = %024b", DUT.LSR_BBCD0.Op_A);

            $display("=========================================================");

            #20;

            $finish;

        end
    end

endmodule

/*
============================================================

COMPILAR

iverilog -o sim.out *.v

============================================================

EJECUTAR

vvp sim.out

============================================================

VER ONDAS

gtkwave BinarioABCD_debug.vcd

============================================================
*/