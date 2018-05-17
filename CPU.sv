module CPU(input clock, input reset);

//Fios grandoes:
logic [31:0] PCIn; //saida do PCSource
logic [31:0] PCOut; //saida do pc
logic [31:0] IorDOut;
logic [31:0] MemOut;
logic [31:0] WMWriteData;
logic [31:0] MDROut;
logic [31:0] WMRegOut;
logic [25:0] inst25_0; //facilita ter só ele porque no jump não precisa concatenar nada
logic [5:0] op;
logic [4:0] rs; //inst25_0[25:21]
logic [4:0]rt; //inst25_0[20:16]
logic [15:0] inst15_0; //conferir se é isso msm vlw
logic [4:0] rd; // inst15_0 [15:11]
logic [4:0] shamt; // inst15_0[10:6]
logic [5:0] funct; // inst15_0[5:0]
logic [4:0] sp; //$29
logic [4:0] reg31; //$31
logic [4:0] ReadSOut;
logic [4:0] RegDstOut; 
logic [31:0] MemToRegOut;
logic [31:0] SignExtendOut;
logic [31:0] SL1Out;
logic [31:0] SL2Out;
logic [31:0] RegAIn;
logic [31:0] RegAOut;
logic [31:0] RegBIn;
logic [31:0] RegBOut;
logic [31:0] AluSrcAOut;
logic [31:0] AluSrcBOut;
logic [31:0] AluResult; //ALUOut
logic [31:0] RegAluOut; //saida ALUOut
logic [31:0] EPCOut;
logic [31:0] RegInOut;
logic [31:0] ShiftSOut;
logic [31:0] RegDeslocOut;
logic [31:0] DivHighOut;
logic [31:0] DivLowOut;
logic [31:0] MultHighOut;
logic [31:0] MultLowOut;
logic [31:0] MUXHighOut;
logic [31:0] MUXLowOut;
logic [31:0] HighOut;
logic [31:0] LowOut;
logic [31:0] MultSOut;
logic [31:0] stateOut;

//Sinais de PC:
logic PCCondOut; //saida do MUX PCCond
logic PCWriteCond; // sinal da unidade de controle
logic PCWrite; // sinal da unidade de controle
logic PCAnd; //PcWriteCond and PCCondOut
logic PCControl; //fio da unidade de controle que entra em PC (PCAnd or PCWrite)

//assign PCAnd = PCWriteCond and PCCondOut;
//assign PCControl = PCAnd or PCWrite;

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
logic [2:0] IorDMux; //mux 5
logic ReadSMux; //mux 2
logic [1:0] ReadDstMux; //mux 4
logic [2:0] MemToRegMux; //mux 7
logic AluSrcAMux; //mux 2
logic [1:0] AluSrcBMux; //mux 4
logic [2:0] PCSourceMux; //mux 6
logic RegInMux; //mux 2
logic ShiftSMux; //mux 2
logic DivMultMux; //mux 2
logic MultSMux; //mux 2
logic [1:0] PCCondMux;

// Sinais dos componentes:
logic WMS; //write mode signal
logic MemRead;
logic MemWrite;
logic [2:0] AluOp;
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

Control ControlUnit(
	.clk(clock),
	.reset(reset),
	//fios da instrucao
	.shamt(shamt),
	.funct(funct),
	.op(op),
	//sinais da alu
	.Overflow(overflowFlag),
	//sinais de pc
	.PCWriteCond(PCWriteCond),
	.PCWrite(PCWrite),

	//sinais dos registradores
	.MDRS(MDRS),
	.IRWrite(IRWrite),
	.RegWriteSignal(RegWriteSignal),
	.RegAW(RegAW),
	.RegBW(RegBW),
	.RegAluWrite(RegAluWrite),
	.EPCWrite(EPCWrite),
	.RegHighW(RegHighW),
	.RegLowW(RegLowW),

	//sinais dos MUX
	.PCCondMux(PCCondMux),
	.IorDMux(IorDMux),
	.ReadSMux(ReadSMux),
	.ReadDstMux(ReadDstMux),
	.MemToRegMux(MemToRegMux),
	.AluSrcAMux(AluSrcAMux),
	.AluSrcBMux(AluSrcBMux),
	.PCSourceMux(PCSourceMux),
	.RegInMux(RegInMux),
	.ShiftSMux(ShiftSMux),
	.DivMultMux(DivMultMux),
	.MultSMux(MultSMux),

	//sinais dos componentes
	.WMS(WMS),
	.MemWrite(MemWrite),
	.AluOP(AluOP),
	.ShiftOp(ShiftOp),
	.StartDiv(StartDiv),
	.DivStop(DivStop),
	.DivZero(DivZero),
	.StartMult(StartMult),
	.StopMult(StopMult),
	.MultO(MultO),
	//estado
    .stateOut(stateOut)
);

Registrador PC(
	.Clk(clock),
	.Reset(reset),
	.Load(PCControl), //conferir se é isso(ta certo, so falta fazer o OR entre os fios. bois)
	.Entrada(PCIn),
	.Saida(PCOut)
);

Mux5 IorD( //faltando declarar os outros fios
	.A(PCOut),
	.B(32'd253),
	.C(32'd254),
	.D(32'd255),
	.E(RegAluOut),
	.S(IorDOut),
	.sel(IorDMux)
);

Memoria Mem( // terminar *
	.Address(IorDOut),
	.Clock(clock),
	.Wr(MemWrite),
	.Datain(WMWriteData),
	.Dataout(MemOut)
);

WriteMode WM(
	.RegIn(RegBOut),
	.MemIn(MDROut),
	.mode(WMS),
	.MemOut(WMWriteData),
	.RegOut(WMRegOut)
);

Registrador MDR(
	.Clk(clock),
	.Reset(reset),
	.Load(MDRS), //conferir se é isso(ta certo tbm. bois)
	.Entrada(MemOut),
	.Saida(MDROut)
);

Instr_Reg IR(
	.Clk(clock),
	.Reset(reset),
	.Load_ir(IRWrite), //conferir(certo tbm. bois)
	.Entrada(MemOut),
	.Instr31_26(op),
	.Instr25_21(rs),
	.Instr20_16(rt),
	.Instr15_0(inst15_0)
);

Mux2_5 ReadS(
	.A(sp),
	.B(rs),
	.S(ReadSOut),
	.sel(ReadSMux)
);

Mux4_5 ReadDST(
	.A(rt),
	.B(reg31),
	.C(sp),
	.D(rd),
	.S(RegDstOut),
	.sel(ReadDSTMux)
);

Mux7 MemToReg(
	.A(RegAluOut),
	.B(RegDeslocOut),
	.C(WMRegOut),
	.D(MultSOut),
	.E({inst15_0, 16'd0}),
	.F({ltFlag, 16'd0}),
	.G(32'd227), //inicialmente: 8'd227
	.S(MemToRegOut),
	.sel(MemToRegMux)
);

Banco_reg Registers(
	.Clk(clock),
	.Reset(reset),
	.RegWrite(RegWriteSignal), //ver se tem problema(certo, eh o sinal que escreve ou lê. bois)
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
	.Load(RegAW), //conferir se é isso(ok. bois)
	.Entrada(RegAIn),
	.Saida(RegAOut)
);

Registrador B(
	.Clk(clock),
	.Reset(reset),
	.Load(RegBW), //conferir se é isso(ok. bois)
	.Entrada(RegBIn),
	.Saida(RegBOut)
);


SignExtend SE(
	.Instruction15_0(inst15_0),
	.Instruction31_0(SignExtendOut)
);

ShiftLeft SL1( //shift left dps do sign extend (16 bits para 32)
	.In(SignExtendOut),
	.Out(SL1Out)
);

ShiftLeft26_28 SL2( //shift left do jump (26 bits para 28)
	.In(inst25_0),
	.Out(SL2Out)
);

Mux2 AluSrcA(
	.A(PCOut),
	.B(RegAOut),
	.S(AluSrcAOut),
	.sel(AluSrcAMux)
);

Mux4 AluSrcB(
	.A(RegBOut),
	.B(32'd4),
	.C(SignExtendOut),
	.D(SL1Out),
	.S(AluSrcBOut),
	.sel(AluSrcBMux)
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
	.Load(RegALuWrite), //conferir se é isso(ok. bois)
	.Entrada(AluResult),
	.Saida(RegAluOut)
);

Registrador EPC(
	.Clk(clock),
	.Reset(reset),
	.Load(EPCWrite), //conferir se é isso(ok, bois)
	.Entrada(AluResult),
	.Saida(EPCOut)
);

Mux6 PCSource(
	.A(AluResult),
	.B(RegAluOut),
	.C(SL2Out),
	.D(EPCOut),
	.E(WMRegOut),
	.F(RegAOut),
	.S(PCIn),
	.sel(PCSourceMux)
);

Mux4 PCCond(
	.A(gtFlag),
	.B(),
	.C(),
	.D(zeroFlag),
	.S(PCCondOut),
	.sel(PCCondMux)
);

Mux2 RegIn( //escolhe qual entrada sera deslocada no reg desloc
	.A(RegBOut),
	.B(RegAOut),
	.S(RegInOut),
	.sel(RegInMux)
);

Mux2 ShiftS( //escolhe qual o shamt (shift amount) do reg desloc
	.A(RegBOut),
	.B({shamt, 27'd0}),
	.S(ShiftSOut),
	.sel(ShiftSMux)
);

RegDesloc RD( //Reg Desloc
	.Clk(clock),
	.Reset(reset),
	.Shift(ShiftOp),
	.N(ShiftSOut),
	.Entrada(RegInOut),
	.Saida(RegDeslocOut)
);

//Div Divisor(
//);

//Mult Multiplicador(
//);

Mux2 DivMultHigh( //escolhe se vai pro reg HIGH o high do mult ou div
	.A(DivHighOut),
	.B(MultHighOut),
	.S(MUXHighOut),
	.sel(DivMultMux)

);

Mux2 DivMultLow( //escolhe se vai pro reg LOW o low do mult ou div
	.A(DivLowOut),
	.B(MultLowOut),
	.S(MUXLowOut),
	.sel(DivMultMux)
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
	.A(HighOut),
	.B(LowOut),
	.S(MultSOut),
	.sel(MultSMux)
);

assign rs = inst25_0 [25:21];
assign rt = inst25_0 [20:16];
assign rd = inst15_0 [15:11];
assign shamt = inst15_0 [10:6];
assign funct = inst15_0 [5:0];
assign sp = 29;
assign reg31 = 31;

endmodule:CPU
