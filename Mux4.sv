module Mux4(
	input logic [31:0] A,
	input logic [31:0] B,
	input logic [31:0] C,
	input logic [31:0] D,
	output logic [31:0] S,
	input logic [1:0] sel
);

always
	case(sel)
		2'b00: S = A;
		2'b01: S = B;
		2'b10: S = C;
		2'b11: S = D;
	endcase

endmodule: Mux4