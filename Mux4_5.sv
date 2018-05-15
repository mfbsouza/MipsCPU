module Mux4_5(
	input logic [4:0] A,
	input logic [4:0] B,
	input logic [4:0] C,
	input logic [4:0] D,
	output logic [4:0] S,
	input logic [1:0] sel
);

always
	case(sel)
		3'b00: S = A;
		3'b01: S = B;
		3'b10: S = C;
		3'b11: S = D;
	endcase

endmodule: Mux4_5
