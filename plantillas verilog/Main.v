// plantilla para el modulo main o principal

module NOMBRE(
    input clk,
    input INIT,
    input [15:0] ENTRADA_PRINCIPAL1,   
    input [15:0] ENTRADA_PRINCIPAL2,   
    
    output DONE,
    output [15:0] RESULTADO    
);

    // Señales internas, si es solo wire, es un dato de un bit. si no, toca determinar el tamaño del cable para lo cual esta el [x:x]
    wire W_1;
    wire W_2;
    wire W_3;

    wire [15:0] W_4;
    wire [31:0] W_5;
    wire [1:0]  W_6;     
    wire [4:0]  W_7;

    // como llamar los otros modulos

    SUMADOR_nombre SUMADOR_nombre0 (
        .in1(W_4), //entrada de 16 bits
        .in2(w_1), // entrada de un solo bit

        .RESULTADO(W_5), //salida de 32 bits
        .MSB(W_2) // salida un solo bit
    );

// ejemplo de como llamar un modulo que se puede parametrizar

   contador_nombre #(.width(16))  count_nombre_1 (

      .clk(clk1),
      .reset(w_RST_C),
      .inc(w_INC_C),
      .outc(COL),
      .zero(w_ZC)
    );

// se puede cambiar el tamaño o no, depende de lo que  se necesite, las variables se cambian de nombre deacuerdo a las necesidades 
   contador_nombre #(.width(12))  count_nombre_1 (

      .clk(clk1),
      .reset(w_RST_R),
      .inc(w_INC_R),
      .outc(ROW),
      .zero(w_ZR)
    );


endmodule
