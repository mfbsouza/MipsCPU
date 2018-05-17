module WriteMode(input logic [31:0] Address, input logic [31:0] RegIn, input logic [31:0] MemIn, input logic [2:0] mode, output logic [31:0] MemOut, output logic [31:0] RegOut);

logic [31:0] MRB, MRH, RMB, RMH;
logic [1:0] sel;

Mux4 mux_RegOUt(.A(MemIn), .B({16'b0, MemIn[15:0]}), .C({24'b0, MemIn[7:0]}), .S(RegOut), .sel(mode[1:0]));
Mux4 mux_MemOut(.A(RegIn), .B({MemIn[31:16], RegIn[15:0]}), .C({MemIn[31:8], RegIn[7:0]}), .S(MemOut), .sel(mode[1:0]));

endmodule: WriteMode
