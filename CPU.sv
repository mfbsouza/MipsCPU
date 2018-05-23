module CPU(input clock,
	input reset,
	output logic [31:0] pcout,
	output logic [31:0] epcout,
	output logic [31:0] mdrout,
	output logic [5:0] op,
	output logic [4:0] rs,
    output logic [4:0] rt,
    output logic [15:0] inst15_0,
	output logic [6:0] stateout
);

//fios grandoes:
logic pccontrol;
logic [31:0] wmwritedata;
logic [31:0] alusrcaout;
logic [31:0] alusrcbout;
logic [31:0] regaluout;
logic [31:0] memtoregout;
logic [2:0] aluop;
logic [31:0] regdeslocout;
logic memwrite;
logic regwritesignal;
logic irwrite;
logic [31:0] regaout;
logic [31:0] regbout;
logic [4:0] shamt;
logic [2:0] shiftop;
logic [4:0] regdstout;
logic [1:0] readdstmux;
logic readsmux;
logic [31:0] regain;
logic [4:0] shiftsout;
logic [31:0] reginout;
logic [31:0] aluresult;
logic [31:0] highout;
logic [31:0] lowout;	
logic [31:0] iordout;



logic pcond1;
logic ltflag;
logic equalflag;
logic gtflag;
logic pccond2;
logic [5:0] funct;
logic [31:0] memout;
logic [31:0] pcin;
logic [31:0] wmregout;
logic [25:0] inst25_0; //facilita ter só ele porque no 
 //não precisa concatenar nada
logic [4:0] rd;
logic [4:0] sp; //$29
logic [4:0] reg31; //$31
logic [4:0] readsout; 
logic [31:0] signextendout;
logic [31:0] sl1out;
logic [31:0] sl2out;
logic [31:0] regbin;

logic [31:0] divhighout;
logic [31:0] divlowout;
logic [31:0] multhighout;
logic [31:0] multlowout;
logic [31:0] muxhighout;
logic [31:0] muxlowout;
logic [31:0] multsout;

//sinais de pc:
logic pccondout; //saida do mux pccond
logic pcwritecond; // sinal da unidade de controle
logic pcwrite; // sinal da unidade de controle
logic pcand; //pcwritecond and pccondout
 //fio da unidade de controle que entra em pc (pcand or pcwrite)

assign pcand = pcwritecond && pccondout;
assign pccontrol = pcand || pcwrite;

//sinais de registradores:
logic mdrs;
logic regaw;
logic regbw;
logic regaluwrite;
logic epcwrite;
logic reghighw;
logic regloww;

//sinais dos mux:
logic [2:0] iordmux; //mux 5 //mux 2 //mux 4
logic [2:0] memtoregmux; //mux 7
logic alusrcamux; //mux 2
logic [1:0] alusrcbmux; //mux 4
logic [2:0] pcsourcemux; //mux 6
logic reginmux; //mux 2
logic shiftsmux; //mux 2
logic divmultmux; //mux 2
logic multsmux; //mux 2
logic [1:0] pccondmux;

// sinais dos componentes:
logic [1:0] wms; //write mode signal

logic startdiv;
logic divstop;
logic divzero;
logic startmult;
logic stopmult;
logic multo;

// saidas da ula:
logic zeroflag;
logic negflag;
logic overflowflag;
 //et
 //less than
 //greater than

//assign pccond2 = !(0 || equalflag);

nor_module(
	.a(1'b0),
	.b(equalflag),
	.s(pccond2)
);

or_module(
	.a(ltflag),
	.b(equalflag),
	.s(pcond1)
);

//assign pccond1 = equalflag || ltflag;

Control controlunit(
	.clk(clock),
	.resetwire(reset),
	//fios da instrucao
	.shamt(shamt),
	.funct(funct),
	.op(op),
	//sinais da alu
	.overflow(overflowflag),
	//sinais de pc
	.pcwritecond(pcwritecond),
	.pcwrite(pcwrite),

	//sinais dos registradores
	.mdrs(mdrs),
	.irwrite(irwrite),
	.regwritesignal(regwritesignal),
	.regaw(regaw),
	.regbw(regbw),
	.regaluwrite(regaluwrite),
	.epcwrite(epcwrite),
	.reghighw(reghighw),
	.regloww(regloww),

	//sinais dos mux
	.pccondmux(pccondmux),
	.iordmux(iordmux),
	.readsmux(readsmux),
	.readdstmux(readdstmux),
	.memtoregmux(memtoregmux),
	.alusrcamux(alusrcamux),
	.alusrcbmux(alusrcbmux),
	.pcsourcemux(pcsourcemux),
	.reginmux(reginmux),
	.shiftsmux(shiftsmux),
	.divmultmux(divmultmux),
	.multsmux(multsmux),

	//sinais dos componentes
	.wms(wms),
	.memwrite(memwrite),
	.aluop(aluop),
	.shiftop(shiftop),
	.startdiv(startdiv),
	.divstop(divstop),
	.divzero(divzero),
	.startmult(startmult),
	.multstop(stopmult),
	.multo(multo),
	//estado
    .stateout(stateout)
);

Registrador pc(
	.Clk(clock),
	.Reset(reset),
	.load(pccontrol), //conferir se é isso(ta certo, so falta fazer o or entre os fios. bois)
	.Entrada(pcin),
	.Saida(pcout)
);

Mux5 iord( //faltando declarar os outros fios
	.A(pcout),
	.B(32'd253),
	.C(32'd254),
	.D(32'd255),
	.E(regaluout),
	.S(iordout),
	.sel(iordmux)
);

Memoria mem( // terminar *
	.Address(iordout),
	.Clock(clock),
	.Wr(memwrite),
	.DataIn(wmwritedata),
	.DataOut(memout)
);

WriteMode wm(
	.RegIn(regbout),
	.MemIn(mdrout),
	.mode(wms),
	.MemOut(wmwritedata),
	.RegOut(wmregout)
);

Registrador mdr(
	.Clk(clock),
	.Reset(reset),
	.Load(mdrs), //conferir se é isso(ta certo tbm. bois)
	.Entrada(memout),
	.Saida(mdrout)
);

Instr_Reg ir(
	.Clk(clock),
	.Reset(reset),
	.Load_ir(irwrite), //conferir(certo tbm. bois)
	.Entrada(memout),
	.Instr31_26(op),
	.Instr25_21(rs),
	.Instr20_16(rt),
	.Instr15_0(inst15_0)
);

Mux2_5 reads(
	.A(sp),
	.B(rs),
	.S(readsout),
	.sel(readsmux)
);

Mux4_5 readdst(
	.A(rt),
	.B(reg31),
	.C(sp),
	.D(rd),
	.S(regdstout),
	.sel(readdstmux)
);

Mux7 memtoreg(
	.A(regaluout),
	.B(regdeslocout),
	.C(wmregout),
	.D(multsout),
	.E({inst15_0, 16'd0}),
	.F({31'd0, ltflag}), //lt tem que virar 32 bits
	.G(32'd227), //inicialmente: 8'd227
	.S(memtoregout),
	.sel(memtoregmux)
);

Banco_Reg registers(
	.Clk(clock),
	.Reset(reset),
	.RegWrite(regwritesignal), //ver se tem problema(certo, eh o sinal que escreve ou lê. bois)
	.ReadReg1(readsout),
	.ReadReg2(rt),
	.writeReg(regdstout),
	.WriteData(memtoregout),
	.ReadData1(regain),
	.ReadData2(regbin)
);


Registrador a(
	.Clk(clock),
	.Reset(reset),
	.Load(regaw), //conferir se é isso(ok. bois)
	.Entrada(regain),
	.Saida(regaout)
);

Registrador b(
	.Clk(clock),
	.Reset(reset),
	.Load(regbw), //conferir se é isso(ok. bois)
	.Entrada(regbin),
	.Saida(regbout)
);


SignExtend se(
	.Instruction15_0(inst15_0),
	.Instruction31_0(signextendout)
);

ShiftLeft sl1( //shift left dps do sign extend (16 bits para 32)
	.In(signextendout),
	.Out(sl1out)
);

ShiftLeft26_28 sl2( //shift left do jump (26 bits para 28)
	.In(inst25_0),
	.Out(sl2out)
);

Mux2 alusrca(
	.A(pcout),
	.B(regaout),
	.S(alusrcaout),
	.sel(alusrcamux)
);

Mux4 alusrcb(
	.A(regbout),
	.B(32'd4),
	.C(signextendout),
	.D(sl1out),
	.S(alusrcbout),
	.sel(alusrcbmux)
);

ula32 alu(
	.A(alusrcaout),
	.B(alusrcbout),
	.Seletor(aluop),
	.S(aluresult),
	.Overflow(overflowflag),
	.Negativo(negflag),
	.z(zeroflag),
	.Igual(equalflag),
	.Maior(gtflag),
	.Menor(ltflag)
);

Registrador aluout(
	.Clk(clock),
	.Reset(reset),
	.Load(regaluwrite), //conferir se é isso(ok. bois)
	.Entrada(aluresult),
	.Saida(regaluout)
);

Registrador epc(
	.Clk(clock),
	.Reset(reset),
	.Load(epcwrite), //conferir se é isso(ok, bois)
	.Entrada(aluresult),
	.Saida(epcout)
);

Mux6 pcsource(
	.A(aluresult),
	.B(regaluout),
	.C({pcout[31:28], sl2out}),
	.D(epcout),
	.E(wmregout),
	.F(regaout),
	.S(pcin),
	.sel(pcsourcemux)
);

Mux4 pccond(
	.A(gtflag),
	.B(pcond1),
	.C(pccond2),
	.D(zeroflag),
	.S(pccondout),
	.sel(pccondmux)
);

Mux2 regin( //escolhe qual entrada sera deslocada no reg desloc
	.A(regbout),
	.B(regaout),
	.S(reginout),
	.sel(reginmux)
);

Mux2_5 shifts( //escolhe qual o shamt (shift amount) do reg desloc
	.A(regbout[4:0]),
	.B(shamt),
	.S(shiftsout),
	.sel(shiftsmux)
);

RegDesloc RegD( //reg desloc
	.Clk(clock),
	.Reset(reset),
	.Shift(shiftop),
	.N(shiftsout),
	.Entrada(reginout),
	.Saida(regdeslocout)
);

//div divisor(
//);

Multiplicador multp(
	.clk(clock),
	.Reset(reset),
	.A(regaout),
	.B(regbout),
	.resultHigh(multhighout),
	.resultLow(multlowout),
	.MultOut(stopmult),
	.MultIn(startmult),
);

Mux2 divmulthigh( //escolhe se vai pro reg high o high do mult ou div
	.A(divhighout),
	.B(multhighout),
	.S(muxhighout),
	.sel(divmultmux)

);

Mux2 divmultlow( //escolhe se vai pro reg low o low do mult ou div
	.A(divlowout),
	.B(multlowout),
	.S(muxlowout),
	.sel(divmultmux)
);

Registrador high(
	.Clk(clock),
	.Reset(reset),
	.Load(reghighw), //conferir se é isso
	.Entrada(muxhighout),
	.Saida(highout)
);

Registrador low(
	.Clk(clock),
	.Reset(reset),
	.Load(regloww), //conferir se é isso
	.Entrada(muxlowout),
	.Saida(lowout)
);

Mux2 mults( //manda guardar o valor do high (0) ou do low(0) no br
	.A(highout),
	.B(lowout),
	.S(multsout),
	.sel(multsmux)
);

assign inst25_0 [25:21] = rs;
assign inst25_0 [20:16] = rt;
assign inst25_0 [15:0] = inst15_0;

assign rd = inst15_0 [15:11];
assign shamt = inst15_0 [10:6];
assign funct = inst15_0 [5:0];
assign sp = 29;
assign reg31 = 31;

endmodule: CPU
