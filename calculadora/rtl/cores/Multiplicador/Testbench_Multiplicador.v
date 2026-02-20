`timescale 1ns/1ps

module tb_TOP_Multiplicador;

reg clk;
reg reset;
reg init;

reg signed [15:0] Multiplicando;
reg signed [15:0] Multiplicador;

wire [31:0] Resultado;
wire DONE;

// --------instanciar--------
TOP_Multiplicador DUT(
    .reset(reset),
    .clk(clk),
    .init(init),
    .Multiplicando(Multiplicando),
    .Multiplicador(Multiplicador),
    .Resultado(Resultado),
    .DONE(DONE)
);

// -------- reloj 10ns --------
always #5 clk = ~clk;

// -------- simulación --------
initial begin

    // dump para GTKWave
    $dumpfile("multiplicador.vcd");

    clk = 0;
    reset = 0;
    init = 0;

    // valores iniciales
    Multiplicando = -100; 
    Multiplicador = 1000; 

    // reset inicial
    #10 reset = 1;
    #10 reset = 0;

    // iniciar multiplicación
    #10 init = 1;
    #10 init = 0;

    // esperar a que termine
    wait(DONE);

    #50 $finish;

end

// -------- monitor ciclo por ciclo --------
initial begin
    $display("--------------------------------------------------------------------------");
    $display("time | state señales internas");
    $display("--------------------------------------------------------------------------");

    $monitor(
        "t=%0t | LD=%b ADD=%b SH=%b DEC=%b | A_long=%b | B_long=%b | ACC=%b | count=%b | DONE=%b",
        $time,
        DUT.W_LD,
        DUT.W_ADD,
        DUT.W_SH,
        DUT.W_DEC,
        DUT.A_long,
        DUT.B_long,
        DUT.ACC,
        DUT.count,
        DONE
    );
end

endmodule