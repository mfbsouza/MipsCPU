module cpu(
	input clock,
	input reset,
	
	output 
	
);

//Fios grandões:

logic PCIn[31:0]; //saída do PCSource
logic PCOut[31:0];
logic IorROut[31:0];
logic MemOut[31:0];
logic WMWriteData[31:0];
logic MDROut[31:0];
logic WMRegOut[31:0];
logic op[5:0];
logic rs[4:0];
logic rt[4:0];
logic offset[15:0]; //lembrar como concateca e desconcatena fios (tirar bits do fio)
// pegar os bits [15:11] - rd, [10:6] - shamt, e [5:0] - funct
//lembrar como fazer a entrada $29 no mux ReadS
//e $31 pro mux RegDST
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
logic RegAluOut[31:0]; //saída ALUOut
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

logic PCCondOut; //saída do MUX PCCond
logic PCWriteCond; // sinal da uc
logic PCWrite; // sinal da uc
logic PCAnd; //PcWriteCond and PCCOndOut
logic PCControl; //fio da unidade de controle que entra em PC (PCAnd and PCWrite)

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
logic ReadDSTMux[1:0];
logic MemToRegMux[2:0];
logic AluSrcAMux;
logic AluSrcBMux[1:0];
logic PCSourceMux[2:0];
logic RegInMux;
logic ShiftSMux;
logic DivMUltMux;
logic MultSMux;




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

ShiftLeft SL1( //shift left pós sign extend

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

Mux2 RegIn( //escolhe qual entrada será deslocada no reg desloc

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
