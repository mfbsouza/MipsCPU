module cpu(
	input clock,
	input reset,
	
	output 
	
);

//Fios grandoes:

logic PCIn[31:0]; //saida do PCSource
logic PCOut[31:0];
logic IorROut[31:0];
logic MemOut[31:0];
logic WMWriteData[31:0];
logic MDROut[31:0];
logic WMRegOut[31:0];
logic inst25_0[25:0]; //facilita ter sÛ ele porque no jump n„o precisa concatenar nada
logic op[5:0];
logic rs[4:0]; //inst25_0[25:21]
logic rt[4:0]; //inst25_0[20:16]
logic inst15_0[15:0]; //conferir se È isso msm vlw
logic rd[4:0]; // inst15_0 [15:11]
logic shamt[4:0]; // inst15_0[10:6]
logic funct[5:0]; // inst15_0[5:0]
logic sp; //$29
logic reg31; //$31
logic RegDstOut[4:0];
logic MemToRegOut[31:0];
logic SignExtendOut[31:0];
logic SL1Out[31:0];
logic SL2Out[31:0];
logic RegAIn[31:0];
logic RegAOut[31:0];
logic RegBIn[31:0];
logic RegBOut[31:0];
logic AluSrcAOut[31:0];
logic AluSrcBOut[31:0];
logic AluResult[31:0]; //ALUOut
logic RegAluOut[31:0]; //saida ALUOut
logic EPCOut[31:0];
logic RegInOut[31:0];
logic ShiftSOut[31:0];
logic RegDeslocOut[31:0];
logic DivHighOut[31:0];
logic DivLowOut[31:0];
logic MultHighOut[31:0];
logic MultLowOut[31:0];
logic MUXHighOut[31:0];
logic MUXLowOut[31:0];
logic HighOut[31:0];
logic LowOut[31:0];
logic MultSOut[31:0];

//Sinais de PC:

logic PCCondOut; //saida do MUX PCCond
logic PCWriteCond; // sinal da uc
logic PCWrite; // sinal da uc
logic PCAnd; //PcWriteCond and PCCondOut
logic PCControl; //fio da unidade de controle que entra em PC (PCAnd or PCWrite)

//Sinais de registradores:

logic MDRS;
logic IRWrite;
logic RegWrite;
logic RegAW;
logic RegBW;
logic RegALuWrite;
logic EPCWrite;
logic RegHighW;
logic RegLowW;

//Sinais dos MUX:
logic IorDMux[2:0];
logic ReadSMux;
logic ReadDstMux[1:0];
logic MemToRegMux[2:0];
logic AluSrcAMux;
logic AluSrcBMux[1:0];
logic PCSourceMux[2:0];
logic RegInMux;
logic ShiftSMux;
logic DivMultMux;
logic MultSMux;

// Sinais dos componentes:
logic WMS; //write mode signal
logic MemRead;
logic MemWrite;
logic AluOp[2:0];
logic ShiftOp;
logic StartDiv;
logic DivStop;
logic DivZero;
logic StartMult;
logic StopMult;
logic MultO;


Control ControlUnit( //unidade de controle (falta implementar)

);

Registrador PC(
	//conexoes
);

Mux5 IorD(
	//conexoes
);

Memoria Mem(
	//conexoes
);

WriteMode WM(
	//conexoes
);

Registrador MDR(
	//conexoes
);

Instr_Reg IR(
	//conexoes
);

Mux2 ReadS(
	//fodase
);

Mux4 ReadDST(

);

Mux7 MemToReg(

);

Banco_reg Registers(

);


Registrador A(

);

Registrador B(

);


SignExtend SE(

);

ShiftLeft SL1( //shift left p√≥s sign extend

);

ShiftLeft SL2( //shift left jump

);

Mux2 AluSrcA(

);

Mux4 AluSrcB(

);

ula32 ALU(

);

Registrador ALUOut(

);

Registrador EPC(

);

Mux6 PCSource(

);

Mux4 PCCond(

);

Mux2 RegIn( //escolhe qual entrada ser√° deslocada no reg desloc

);

Mux2 ShiftS( //escolhe qual o shamt (shift amount) do reg desloc

);

RegDesloc RD( //Reg Desloc

);

Div Divisor(

);

Mult Multiplicador(

);

Mux2 DivMultHigh(

);

Mux2 DivMultLow(

);

Registrador High(

);

Registrador Low(

);

Mux2 MultS( //manda guardar o valor do high (0) ou do low(0) no br

);

assign rs = inst25_0[25:21];
assign rt = inst25_0[20:16];
assign rd = inst15_0 [15:11];
assign shamt = inst15_0 [10:6];
assign funct = inst15_0[5:0];
assign sp = 29;
assign reg31 = 31;

endmodule