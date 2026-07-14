`timescale 1ns/1ps

module Timer_WS2812_TB;

    reg clk;
    reg reset;
    reg INIT_T;
    reg [1:0] SEL;

    wire DOUT;
    wire DONE_T;

    parameter tck = 40;

    Timer_WS2812 uut (
        .clk    (clk),
        .reset  (reset),
        .INIT_T (INIT_T),
        .SEL    (SEL),
        .DOUT   (DOUT),
        .DONE_T (DONE_T)
    );

    always #(tck/2) clk = ~clk;

    task enviar_timer;
        input [1:0] sel_value;
        integer ciclos_total;
        integer ciclos_alto;
        begin
            ciclos_total = 0;
            ciclos_alto  = 0;

            @(negedge clk);
            SEL    = sel_value;
            INIT_T = 1'b1;

            @(negedge clk);
            INIT_T = 1'b0;

            // Esperar a que realmente empiece la operación:
            // para SEL 0/1, empieza cuando DOUT sube.
            // para SEL 2, empieza cuando w_INC se activa.
            if (sel_value == 2'd2) begin
                while (uut.w_INC == 1'b0)
                    @(negedge clk);
            end else begin
                while (DOUT == 1'b0)
                @(negedge clk);
            end

            while (DONE_T == 1'b0) begin
                if (DOUT == 1'b1)
                    ciclos_alto = ciclos_alto + 1;

                ciclos_total = ciclos_total + 1;
                @(negedge clk);
            end

            $display("SEL = %0d | ciclos_total = %0d | ciclos_alto = %0d | DONE_T = %b",
                    sel_value, ciclos_total, ciclos_alto, DONE_T);

            @(negedge clk);
        end
    endtask

    initial begin
        $dumpfile("Timer_WS2812_TB.vcd");
        $dumpvars(-1, Timer_WS2812_TB);

        clk    = 1'b0;
        reset  = 1'b1;
        INIT_T = 1'b0;
        SEL    = 2'd0;

        #(tck * 3);
        reset = 1'b0;

        #(tck * 2);

        $display("\n--- PRUEBA SEL = 0: envio de bit 0 ---");
        enviar_timer(2'd0);

        #(tck * 5);

        $display("\n--- PRUEBA SEL = 1: envio de bit 1 ---");
        enviar_timer(2'd1);

        #(tck * 5);

        $display("\n--- PRUEBA SEL = 2: envio de reset WS2812 ---");
        enviar_timer(2'd2);

        #(tck * 10);

        $display("\n--- FIN DE SIMULACION ---");
        $finish;
    end

endmodule