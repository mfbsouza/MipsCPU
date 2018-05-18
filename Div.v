module Div (A, B, clk, Reset, resultHigh, resultLow, 
				DivIn, DivStop, DivZero );

	// A/B

	input [31:0] A, B;
	input clk, Reset;
	input DivIn; //nosso StartDiv
	output reg DivStop; //avisa que acabou
	output reg DivZero; //avisa que A/0 - excecao
	output reg [31:0] resultHigh, resultLow;
	integer contador = 32;
	reg [64:0] Quociente = 0;
	reg [31:0] Resto ;
	reg [31:0] Dividendo;
	reg [31:0] Divisor;
	
	
	

	always @(posedge clk) begin

		if (contador == 32) begin
			Divisor = B;
			Dividendo = A;

		end
		
		if ( Dividendo == 0) begin
			DivZero = 1;
			//tratar excecao
		end

		Resto = Resto - Divisor;

		if (Resto >= 0) begin
			Quociente = Quociente << 1;
			Quociente[0] = 1'b1;
		end

		if (Resto < 0) begin
			Resto = Resto + Divisor;
			Quociente = Quociente << 1;
			Quociente[0] = 1'b0;
		end

		Divisor = Divisor >> 1;

		if (contador > 0) begin
			contador = (contador - 1);
		end

		if (contador == 0) begin
			//seta as saidas
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
