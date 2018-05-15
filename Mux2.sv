module Mux2(input logic [31:0] A, input logic [31:0] B, output logic [31:0] S, input logic sel) ;

assign S = !sel ? A : B ;

endmodule: Mux2