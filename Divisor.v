module Divisor (A, B, Resto, clk, Reset, resultHigh, resultLow);

// A/B

input [31:0] A, B, Resto;
input clk, Reset;
input DivIn; //nosso StartDiv
output reg DivStop; //avisa que acabou
output reg DivZero; //avisa que A/0 - exceção
output reg [31:0] resultHigh, resultLow;
reg [64:0] Quociente;
integer contador = 32;


always @(posedge clk) begin

    if ( B == 0) begin
        DivZero = 1;
        //tratar exceção
    end

    Resto = Resto - B;

    if (Resto >= 0) begin
        Quociente = Quociente << 1;
        Quociente[0] = 1'b1;
    end

    if (Resto < 0) begin
        Resto = Resto + B;
        Quociente = Quociente << 1;
        Quociente[0] = 1'b0;
    end

    B = B >> 1;

    if (contador > 0) begin
        contador = (contador - 1);
    end

    if (contador == 0) begin
        //seta as saídas
        resultHigh = Quociente[64:33];
        resultLow = Quociente[32:1];
        DivStop = 0;
        contador = -1;
    end

    endmodule