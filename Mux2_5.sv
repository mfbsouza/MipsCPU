module Mux2_5(
	input logic [4:0] A,
	input logic [4:0] B,
	output logic [4:0] S,
	input logic sel
);

always
	case(sel)
		3'b0: S = A;
		3'b1: S = B;
	endcase

endmodule: Mux2_5
