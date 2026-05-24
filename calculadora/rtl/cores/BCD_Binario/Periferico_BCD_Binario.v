module Periferico_BCD_Binario (
    input         CLK,
    input         reset,
    input  [31:0] d_in,     // dato de entrada desde el bus 
    input         cs,       // chip select
    input  [5:0]  addr,     // dirección del registro
    input         rd,       // lectura
    input         wr,       // escritura
    output reg [23:0] d_out // salida hacia el bus
);

    // Registros internos 
    reg  [3:0] s;           // selector de dirección

    // Entradas 
    reg  [3:0] SIGN;
    reg  [3:0] MILLON;
    reg  [3:0] CIENMIL;
    reg  [3:0] DIEZMIL;
    reg  [3:0] MIL;
    reg  [3:0] CENT;
    reg  [3:0] DEC;
    reg  [3:0] UNIT;
    reg        INIT;

    // Salidas 
    wire [23:0] Op_A_out;
    wire        DONE;

    always @(*) begin
        if (cs) begin
            case (addr)
                6'h04: s = 4'b0001; // BCD_IN  
                6'h08: s = 4'b0010; // INIT    
                6'h0C: s = 4'b0100; // RESULT  
                6'h10: s = 4'b1000; // DONE    
                default: s = 4'b0000;
            endcase
        end else
            s = 4'b0000;
    end

  // 2. Escritura de registros

    always @(posedge CLK) begin
        if (reset) begin
            SIGN    <= 4'd0;
            MILLON  <= 4'd0;
            CIENMIL <= 4'd0;
            DIEZMIL <= 4'd0;
            MIL     <= 4'd0;
            CENT    <= 4'd0;
            DEC     <= 4'd0;
            UNIT    <= 4'd0;
            INIT    <= 1'b0;
        end else if (cs && wr) begin

            if (s[0]) begin         
                SIGN    <= d_in[31:28];
                MILLON  <= d_in[27:24];
                CIENMIL <= d_in[23:20];
                DIEZMIL <= d_in[19:16];
                MIL     <= d_in[15:12];
                CENT    <= d_in[11:8];
                DEC     <= d_in[7:4];
                UNIT    <= d_in[3:0];
            end
            if (s[1])                
                INIT <= d_in[0];
        end
    end

  // 3. Lectura de registros

    always @(posedge CLK) begin
        
        if (reset)
            d_out <= 32'd0;

        else if (cs && rd) begin
           
            case (s[3:0])
                4'b0100: d_out <= {8'b0, Op_A_out};      // RESULT (24 bits)
                4'b1000: d_out <= {31'b0, DONE};          // DONE   (1 bit)
                default: d_out <= 32'd0;
            endcase
        end
    end

    // 4. Instancia del módulo BCDABinario
    BCDABinario u_BCDABinario (
        .CLK     (CLK),
        .INIT    (INIT),
        .SIGN    (SIGN),
        .MILLON  (MILLON),
        .CIENMIL (CIENMIL),
        .DIEZMIL (DIEZMIL),
        .MIL     (MIL),
        .CENT    (CENT),
        .DEC     (DEC),
        .UNIT    (UNIT),
        .Op_A_out(Op_A_out),
        .DONE    (DONE)
    );

endmodule