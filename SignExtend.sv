module SignExtend(input logic [15:0] Instruction15_0, output logic [31:0] Instruction31_0);

assign Instruction31_0 = (Instruction15_0[15] == 0) ? (32'b00000000000000000000000000000000 + Instruction15_0) : (32'b11111111111111110000000000000000 + Instruction15_0);

endmodule:SignExtend