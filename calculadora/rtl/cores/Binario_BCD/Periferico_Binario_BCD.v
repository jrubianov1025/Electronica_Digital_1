module Periferico_Binario_BCD (
  input         CLK,
  input         reset,
  input  [23:0] d_in,    // dato de entrada desde el bus
  input         cs,      // chip select
  input  [5:0]  addr,    // dirección del registro
  input         rd,      // lectura
  input         wr,      // escritura
  output reg [31:0] d_out // salida hacia el bus
);

  //  Registros internos 
  reg  [3:0]  s;              // Selector de dirección
  reg  [23:0] Op_A;           // Número binario de entrada (24 bits signed)
  reg         INIT;           // Señal de inicio

  wire [3:0] SIGN;
  wire [3:0] MILLON;
  wire [3:0] CIENMIL;
  wire [3:0] DIEZMIL;
  wire [3:0] MIL;
  wire [3:0] CENT;
  wire [3:0] DEC;
  wire [3:0] UNIT;
  wire DONE;

  wire [31:0] RESULT;
  assign RESULT = {SIGN, MILLON, CIENMIL, DIEZMIL, MIL, CENT, DEC, UNIT};

  always @(*) begin
    if (cs) begin
      case (addr)
        6'h04: s = 4'b0001; // Op_A
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
      Op_A <= 0;
      INIT <= 0;
    end
    else begin
      if (cs && wr) begin
		   Op_A <= s[0] ? d_in    : Op_A;	//Write Registers
		   INIT <= s[1] ? d_in[0] : INIT;
      end
    end
  end

  // 3. Lectura de registros

  always @(posedge CLK) begin
    
    if (reset)
      d_out <= 0;
    
    else if (cs && rd) begin
      
      case (s[3:0])
        4'b0100: d_out <= RESULT;   
        4'b1000: d_out <= {31'b0, DONE};     
        default: d_out <= 32'b0;
      endcase
    end
  end

  // 4. Instancia del módulo BinarioABCD
  
  BinarioABCD u_BinarioABCD (
    .CLK     (CLK),
    .Op_A    (Op_A),  
    .INIT    (INIT),
    .SIGN    (SIGN),
    .MILLON  (MILLON),
    .CIENMIL (CIENMIL),
    .DIEZMIL (DIEZMIL),
    .MIL     (MIL),
    .CENT    (CENT),
    .DEC     (DEC),
    .UNIT    (UNIT),
    .DONE    (DONE)
  );

endmodule