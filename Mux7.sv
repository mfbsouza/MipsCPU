module Mux7(input logic [31:0] A, input logic [31:0] B, input logic [31:0] C, input logic [31:0] D, input logic [31:0] E, input logic [31:0] F, input logic [31:0] G, output logic [31:0] S, input logic [2:0] sel) ;

always
	case(sel)
		3'b000: S = A;
		3'b001: S = B;
		3'b010: S = C;
		3'b011: S = D;
		3'b100: S = E;
		3'b101: S = F;
		3'b110: S = G;
	endcase

endmodule: Mux7