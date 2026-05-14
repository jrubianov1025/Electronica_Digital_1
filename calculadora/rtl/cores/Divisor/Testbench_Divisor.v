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

// DUT
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


// CLOCK
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

// GTKWave
initial begin

    $dumpfile("periferico_divisor.vcd");
    $dumpvars(0, tb_Periferico_Divisor);

end

// WRITE
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

// READ
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

initial begin

    reset = 1'b1;

    cs   = 0;
    rd   = 0;
    wr   = 0;

    addr = 0;
    d_in = 0;

    #20;

    reset = 1'b0;

    // Dividendo = 100
    write_reg(5'h04, 32'd100);

    // Divisor = 7
    write_reg(5'h08, 32'd7);

    // INIT
    write_reg(5'h0C, 32'd1);

    // Esperar DONE
    wait(DUT.DONE == 1'b1);
    #20;

    // Leer resultado
    read_reg(5'h10);

    // Leer residuo
    read_reg(5'h14);

    // Leer DONE
    read_reg(5'h18);

    #100;

    $finish;

end

endmodule