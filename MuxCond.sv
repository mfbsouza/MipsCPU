module MuxCond (
	input logic A,
	input logic B,
	input logic C,
	input logic D,
	input logic [1:0] sel,
	output logic S
);

always
	case(sel)
		2'b00: S = A;
		2'b01: S = B;
		2'b10: S = C;
		2'b11: S = D;
	endcase

endmodule: MuxCond