module SignExtend(input logic [15:0] A, output logic [31:0] B);

assign B = (A[15] == 0) ? (32'b00000000000000000000000000000000 + A) : (32'b11111111111111110000000000000000 + A);

endmodule