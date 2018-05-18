module Divisor (A, B, clk, Reset, resultHigh, resultLow, 
				DivIn, DivStop, DivZero );

	// A/B

	input [31:0] A, B;
	input clk, Reset;
	input DivIn; //nosso StartDiv
	output reg DivStop; //avisa que acabou
	output reg DivZero; //avisa que A/0 - exceÃ§Ã£o
	output reg [31:0] resultHigh, resultLow;
	integer contador = 32;
	reg [64:0] Quociente;
	reg [31:0] Resto ;
	reg [31:0] Dividendo;
	

	always @(posedge clk) begin

		if (contador == 32) begin
			Dividendo = B;
			Quociente = A;

		end
		
		if ( Dividendo == 0) begin
			DivZero = 1;
			//tratar exceÃ§Ã£o
		end

		Resto = Resto - Dividendo;

		if (Resto >= 0) begin
			Quociente = Quociente << 1;
			Quociente[0] = 1'b1;
		end

		if (Resto < 0) begin
			Resto = Resto + Dividendo;
			Quociente = Quociente << 1;
			Quociente[0] = 1'b0;
		end

		Dividendo = Dividendo >> 1;

		if (contador > 0) begin
			contador = (contador - 1);
		end

		if (contador == 0) begin
			//seta as saÃ­das
			resultHigh = Quociente[64:33];
			resultLow = Quociente[32:1];
			DivStop = 0;
			contador = -1;
		end
		
		if(contador == -1) begin
			Resto = 32'b0;
			Quociente = 65'b0;
		end

	end

endmodule 