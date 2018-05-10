module cpu(input clock, input reset);

//Fios grandoes:
logic PCIn[31:0]; //saida do PCSource
logic PCOut[31:0];
logic IorDOut[31:0];
logic MemOut[31:0];
logic WMWriteData[31:0];
logic MDROut[31:0];
logic WMRegOut[31:0];
logic inst25_0[25:0]; //facilita ter só ele porque no jump não precisa concatenar nada
logic op[5:0];
logic rs[4:0]; //inst25_0[25:21]
logic rt[4:0]; //inst25_0[20:16]
logic inst15_0[15:0]; //conferir se é isso msm vlw
logic rd[4:0]; // inst15_0 [15:11]
logic shamt[4:0]; // inst15_0[10:6]
logic funct[5:0]; // inst15_0[5:0]
logic sp; //$29
logic reg31; //$31
logic ReadSOut[4:0];
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
logic PCWriteCond; // sinal da unidade de controle
logic PCWrite; // sinal da unidade de controle
logic PCAnd; //PcWriteCond and PCCondOut
logic PCControl; //fio da unidade de controle que entra em PC (PCAnd or PCWrite)

//Sinais de registradores:
logic MDRS;
logic IRWrite;
logic RegWriteSignal;
logic RegAW;
logic RegBW;
logic RegALuWrite;
logic EPCWrite;
logic RegHighW;
logic RegLowW;

//Sinais dos MUX:
logic IorDMux[2:0]; //mux 5
logic ReadSMux; //mux 2
logic ReadDstMux[1:0]; //mux 4
logic MemToRegMux[2:0]; //mux 7
logic AluSrcAMux; //mux 2
logic AluSrcBMux[1:0]; //mux 4
logic PCSourceMux[2:0]; //mux 6
logic RegInMux; //mux 2
logic ShiftSMux; //mux 2
logic DivMultMux; //mux 2
logic MultSMux; //mux 2

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

// Saidas da ULA:
logic zeroFlag;
logic negFlag;
logic overflowFlag;
logic equalFlag; //et
logic ltFlag; //less than
logic gtFlag; //greater than

Control ControlUnit( //unidade de controle (falta implementar)

);

Registrador PC(
	.Clk(clock),
	.Reset(reset),
	.Load(PCControl), //conferir se é isso
	.Entrada(PCIn),
	.Saida(PCOut)
);

Mux5 IorD(
	//conexoes
);

Memoria Mem( // terminar *
	.Address(IorDOut),
	.Clock(clock),
	.Wr(),
	.Datain(),
	.Dataout()
);

WriteMode WM(
	//conexoes
);

Registrador MDR(
	.Clk(clock),
	.Reset(reset),
	.Load(MDRS), //conferir se é isso
	.Entrada(MemOut),
	.Saida(MDROut)
);

Instr_Reg IR(
	.Clk(clock),
	.Reset(reset),
	.Load_ir(IRWrite), //conferir
	.Entrada(MemOut),
	.Instr31_26(op),
	.Instr25_21(rs),
	.Instr20_16(rt),
	.Instr15_0(inst15_0)
);

Mux2 ReadS(
	
);

Mux4 ReadDST(

);

Mux7 MemToReg(

);

Banco_reg Registers(
	.Clk(clock),
	.Reset(reset),
	.RegWrite(RegWriteSignal), //ver se tem problema
	.ReadReg1(ReadSOut),
	.ReadReg2(rt),
	.WriteReg(RegDstOut),
	.WriteData(MemToRegOut),
	.ReadData1(RegAIn),
	.ReadData2(RegBIn)
);


Registrador A(
	.Clk(clock),
	.Reset(reset),
	.Load(RegAW), //conferir se é isso
	.Entrada(RegAIn),
	.Saida(RegAOut)
);

Registrador B(
	.Clk(clock),
	.Reset(reset),
	.Load(RegBW), //conferir se é isso
	.Entrada(RegBIn),
	.Saida(RegBOut)
);


SignExtend SE(
	.Instruction15_0(inst15_0),
	.Instruction31_0(SignExtendOut)
);

ShiftLeft SL1( //shift left dps do sign extend
	.In(SignExtendOut),
	.Out(SL1Out)
);

ShiftLeft SL2( //shift left do jump
	.In(inst25_0),
	.Out(SL2Out)
);

Mux2 AluSrcA(

);

Mux4 AluSrcB(

);

ula32 ALU(
	.A(AluSrcAOut),
	.B(AluSrcBOut),
	.Seletor(AluOp),
	.S(AluResult),
	.Overflow(overflowFlag),
	.Negativo(negFlag),
	.z(zeroFlag),
	.Igual(equalFlag),
	.Maior(gtFlag),
	.Menor(ltFlag)
);

Registrador ALUOut(
	.Clk(clock),
	.Reset(reset),
	.Load(RegALuWrite), //conferir se é isso
	.Entrada(AluResult),
	.Saida(RegAluOut)
);

Registrador EPC(
	.Clk(clock),
	.Reset(reset),
	.Load(EPCWrite), //conferir se é isso
	.Entrada(AluResult),
	.Saida(EPCOut)
);

Mux6 PCSource(

);

Mux4 PCCond(

);

Mux2 RegIn( //escolhe qual entrada sera deslocada no reg desloc

);

Mux2 ShiftS( //escolhe qual o shamt (shift amount) do reg desloc

);

RegDesloc RD( //Reg Desloc
	.Clk(clock),
	.Reset(reset),
	.Shift(ShiftOp),
	.N(ShiftSOut),
	.Entrada(RegInOut),
	.Saida(RegDeslocOut)
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
	.Clk(clock),
	.Reset(reset),
	.Load(RegHighW), //conferir se é isso
	.Entrada(MUXHighOut),
	.Saida(HighOut)
);

Registrador Low(
	.Clk(clock),
	.Reset(reset),
	.Load(RegLowW), //conferir se é isso
	.Entrada(MUXLowOut),
	.Saida(LowOut)
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