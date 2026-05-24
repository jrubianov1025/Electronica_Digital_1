`timescale 1ns / 1ps
module SOC (
    input 	     clk,    // system clock 
    input 	     resetn, // reset button
    output wire  LEDS,   // system LEDs
    input 	     RXD,    // UART receive
    output 	     TXD     // UART transmit
);

   // Señales del bus del CPU

   wire [31:0] mem_addr;
   reg  [31:0] mem_rdata;
   wire        mem_rstrb;
   wire [31:0] mem_wdata;
   wire [3:0]  mem_wmask;

   // Instancia del CPU RISC-V

   FemtoRV32 CPU(
      .clk(clk),
      .reset(resetn),		 
      .mem_addr(mem_addr),
      .mem_rdata(mem_rdata),
      .mem_rstrb(mem_rstrb),
      .mem_wdata(mem_wdata),
      .mem_wmask(mem_wmask),
      .mem_rbusy(1'b0),
      .mem_wbusy(1'b0)
   );

      // Señales comunes

   wire [31:0] RAM_rdata;
   wire  wr = |mem_wmask;
   wire  rd = mem_rstrb; 
   
   // Memoria principal (RAM)

   bram RAM(
      .clk(clk),
      .mem_addr(mem_addr),
      .mem_rdata(RAM_rdata),
      .mem_rstrb(cs[0] & rd),
      .mem_wdata(mem_wdata),
      .mem_wmask({4{cs[0]}}&mem_wmask)
   );
   
   // Señales de salida de los periféricos

   wire [31:0] Multiplicador_dout;
   wire [31:0] Divisor_dout;
   wire [31:0] Raiz_dout;
   wire [31:0] Binario_BCD_dout;
   wire [31:0] BCD_Binario_dout;

   wire [31:0] uart_dout;

   // Instancia de periféricos

    Periferico_Multiplicador Periferico_Multiplicador1 (
		.clk(clk), 
		.reset(!resetn), 
		.d_in(mem_wdata[15:0]), 
		.cs(cs[1]), 
		.addr(mem_addr[4:0]), 
		.rd(rd), 
		.wr(wr), 
		.d_out(Multiplicador_dout) 
	);

    Periferico_Divisor Periferico_Divisor1 (
      .clk(clk),
      .reset(!resetn),
      .d_in(mem_wdata[31:0]),
      .cs(cs[2]),
      .addr(mem_addr[4:0]),
      .rd(rd),
      .wr(wr),
      .d_out(Divisor_dout)
   );

   Periferico_raiz Periferico_raiz1 (
      .CLK(clk),
      .reset(!resetn),
      .d_in(mem_wdata[15:0]),
      .cs(cs[3]),
      .addr(mem_addr[4:0]),
      .rd(rd),
      .wr(wr),
      .d_out(Raiz_dout)
   );

   Periferico_Binario_BCD Periferico_Binario_BCD1 (
      .CLK(clk),
      .reset(!resetn),
      .d_in(mem_wdata[23:0]),
      .cs(cs[4]),
      .addr(mem_addr[5:0]), // más ancho (6 bits)
      .rd(rd),
      .wr(wr),
      .d_out(Binario_BCD_dout)
   );

   Periferico_BCD_Binario Periferico_BCD_Binario1 (
      .CLK(clk),
      .reset(!resetn),
      .d_in(mem_wdata[31:0]),
      .cs(cs[7]),
      .addr(mem_addr[5:0]), 
      .rd(rd),
      .wr(wr),
      .d_out(BCD_Binario_dout)
   );

  peripheral_uart #(
     .clk_freq(26000000),    // 27000000 for gowin 33333333 for efinix
     .baud(115200)            // 57600 for gowin
   ) per_uart(
     .clk(clk), 
     .rst(!resetn), 
     .d_in(mem_wdata), 
     .cs(cs[5]), 
     .addr(mem_addr[4:0]), 
     .rd(rd), 
     .wr(wr), 
     .d_out(uart_dout), 
     .uart_tx(TXD), 
     .uart_rx(RXD), 
     .ledout(LEDS)
   ); 

  // ============== Chip_Select (Addres decoder) ======================== 
  // se hace con los 8 bits mas significativos de mem_addr
  // Se asigna el rango de la memoria de programa 0x00000000 - 0x003FFFFF

  reg [7:0]cs;  // CHIP-SELECT
  always @*
  begin
      case (mem_addr[31:16])	// direcciones - chip_select
        16'h0040: cs= 8'b00100000; 	  //uart
        16'h0041: cs= 8'b00010000;	   // Binario_BCD
        16'h0042: cs= 8'b00001000;	   // Raíz cuadrada
        16'h0043: cs= 8'b00000100;	   // Divisor
        16'h0044: cs= 8'b00000010;	   // Multiplicador
        16'h0045: cs= 8'b01000000;    //dpRAM
        16'h0046: cs= 8'b10000000;     // BCD_Binario
        16'h0000: cs= 8'b00000001;    //RAM   
        default:  cs= 8'b00000001;       
      endcase
  end

  // ============== MUX ========================  // se encarga de lecturas del RV32
  always @*
  begin
      case (cs)
        8'b10000000: mem_rdata = BCD_Binario_dout;
        8'b00100000: mem_rdata = uart_dout;
        8'b00010000: mem_rdata = Binario_BCD_dout;
        8'b00001000: mem_rdata = Raiz_dout;
        8'b00000100: mem_rdata = Divisor_dout;
        8'b00000010: mem_rdata = Multiplicador_dout;
        8'b00000001: mem_rdata = RAM_rdata;
        default:  mem_rdata = RAM_rdata;

      endcase
  end


 // ============== MUX ========================  // 

`ifdef BENCH
   always @(posedge clk) begin
      if(cs[5] & wr ) begin
	 $write("%c", mem_wdata[7:0] );
	 $fflush(32'h8000_0001);
      end
   end
`endif


endmodule