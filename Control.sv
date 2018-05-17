module Control (
	input logic clk,
	input logic reset,

	//fios da instrucao
	input logic [4:0] shamt,
	input logic [5:0] funct,
	input logic [5:0] op,

	//sinais da alu
	input logic Overflow, //ta faltando mais coisa aqui, acho (bois)
  
	//sinais de saida da Unidade de controle
	//sinais de pc
	output logic PCWriteCond,
	output logic PCWrite,

	//sinais dos registradores
	output logic MDRS,
	output logic IRWrite,
	output logic RegWriteSignal,
	output logic RegAW,
	output logic RegBW,
	output logic RegAluWrite,
	output logic EPCWrite,
	output logic RegHighW,
	output logic RegLowW,

	//sinais dos MUX
	output logic [1:0] PCCondMux,
	output logic [2:0] IorDMux,
	output logic ReadSMux,
	output logic [1:0] ReadDstMux,
	output logic [2:0] MemToRegMux,
	output logic AluSrcAMux,
	output logic [1:0] AluSrcBMux,
	output logic [2:0] PCSourceMux,
	output logic RegInMux,
	output logic ShiftSMux,
	output logic DivMultMux,
	output logic MultSMux,

	//sinais dos componentes
	output logic [1:0] WMS,
	output logic MemRead,
	output logic MemWrite,
	output logic [2:0] AluOP,
	output logic ShiftOp,
	output logic StartDiv,
	output logic DivStop,
	output logic DivZero,
	output logic StartMult,
	output logic StopMult,
	output logic MultO,
	//estado
    output logic [6:0] stateOut,
);
  
enum logic [6:0] {
	//Our Control Unit looks like an H
	//dentro do H - superior centro
	Reset= 7'd1,
	Fetch= 7'd2,
	Wait= 7'd3,
	Decode= 7'd4,
	//lado esquerdo
	Beq_compare= 7'd5,
	Bne_compare= 7'd6,
	Ble_compare= 7'd7,
	Bgt_compare= 7'd8,
	LW_address= 7'd9,
	LW_memory= 7'd10,
	LW_wait= 7'd11,
	LW_write= 7'd12,
	SW_address= 7'd13,
	SW_memory= 7'd14,
	SW_wait= 7'd15,
	SW_write= 7'd16,
	Lui_load= 7'd17,
	J_jump= 7'd18,
	Jal= 7'd19,
	saveEjump= 7'd20,
	LH_address= 7'd21,
	LH_memory= 7'd22,
	LH_wait= 7'd23,
	LH_wait=  7'd24,
	LH_wait=  7'd25,
	LH_wait=  7'd26,
	LH_write= 7'd27,
	LB_address= 7'd28,
	LB_memory= 7'd29,
	LB_wait= 7'd30,
	LB_write= 7'd31,
	SH_address= 7'd32,
	SH_memory= 7'd33,
	SH_wait 7'd34,
	SH_write= 7'd35,
	SB_address= 7'd36,
	SB_memory= 7'd37,
	SB_wait=  7'd38,
	SB_write= 7'd39,
	Slti= 7'd40,
	RegT_Write_slti= 7'd41,
	Addiu= 7'd42,
	Addi= 7'd43,
	RegT_Write= 7'd44,
	//dentro do H -  inferior - esquerdo
	ov_load= 7'd45,
	ov_wait= 7'd46,
	ov_pc= 7'd47,
	//dentro do H  - inferior - direito
	Push= 7'd48,
	NewRA=  7'd49,//New_$RA
	SaveRA_write=  7'd50, //Save_$RA & WriteMem
	Pop=  7'd51,
	Address=   7'd52,//endereço
	readAddres=  7'd53, //ler endereço
	Stall= 7'd54,
	Save_Reg=  7'd55,//guarda no registrador
	New_pointer=  7'd56,//novo ponteiro
	UpdateRA= 7'd57, //Atualiza $ra
	Rte= 7'd58,
	//lado direito
	Mflo= 7'd59,
	Mfhi= 7'd60,
	Jr= 7'd61,
	Break= 7'd62,
	Slt= 7'd63,
	RegD_write_slt= 7'd64,
	Sub= 7'd65,
	And= 7'd66,
	Add= 7'd67,
	RegD_write= 7'd68,

	ShiftShamt= 7'd69,
	sll= 7'd70,
	srl= 7'd71,
	sra= 7'd72,

	ShiftReg= 7'd73,
	sllv= 7'd74,
	srav= 7'd75,

	RegD_Shift= 7'd76,

	Div= 7'd77,
	HliLoD= 7'd78,
	Mult= 7'd79,
	HliLoM= 7'd80,
	//dentro de H - superior - direito
	Div_Zero= 7'd81,
	Div_Stall= 7'd82,
	noop_load= 7'd83,
	noop_wait= 7'd84,
	noop_pc= 7'd85
} state, nextState;

always_ff@(posedge clk, posedge reset) begin
    if(reset) state <= Reset;
    else state <= nextState;
    stateOut = state;
end

always_comb
	case(state)
      
    	Reset: begin
			PCWriteCond = 0;
  			PCWrite = 0;
  			//sinais dos registradores
  			MDRS = 0;
  			IRWrite = 0;
  			RegWriteSignal = 1;
  			RegAW = 0;
  			RegBW = 0;
  			RegAluWrite = 0;
  			EPCWrite = 0;
  			RegHighW = 0;
  			RegLowW = 0;
  			//sinais dos MUX
			PCCondMux = 2'b00;
			IorDMux = 3'b000;
  			ReadSMux = 0;
			ReadDstMux = 2'b10;
			MemToRegMux = 3'b110;
  			AluSrcAMux = 0;
			AluSrcBMux = 2'b00;
  			PCSourceMux = 3'b000;
  			RegInMux = 0;
  			ShiftSMux = 0;
  			DivMultMux = 0;
  			MultSMux = 0;
  			//sinais dos componentes
  			WMS = 2'b00;
  			MemRead = 0;
			MemWrite = 0;
			AluOP = 3'b000;
  			ShiftOp = 3'b000;
  			StartDiv = 0;
  			DivStop = 0;
  			DivZero = 0;
  			StartMult = 0;
  			MultStop = 0;
  			MultO = 0;
          	
          	nextState = Fetch;
		end

		Fetch= begin
          PCWriteCond = 0;
  			PCWrite = 1;
  			//sinais dos registradores
  			MDRS = 0;
  			IRWrite = 0;
  			RegWriteSignal = 0;
  			RegAW = 0;
  			RegBW = 0;
  			RegAluWrite = 0;
  			EPCWrite = 1;
  			RegHighW = 0;
  			RegLowW = 0;
  			//sinais dos MUX
			PCCondMux = 2'b00;
			IorDMux = 3'b000;
  			ReadSMux = 0;
			ReadDstMux = 2'b00;
			MemToRegMux = 3'b000;
  			AluSrcAMux = 0;
			AluSrcBMux = 2'b01;
  			PCSourceMux = 3'b000;
  			RegInMux = 0;
  			ShiftSMux = 0;
  			DivMultMux = 0;
  			MultSMux = 0;
  			//sinais dos componentes
  			WMS = 2'b00;
  			MemRead = 1;
			MemWrite = 0;
			AluOP = 3'b001;
  			ShiftOp = 0;
  			StartDiv = 0;
  			DivStop = 0;
  			DivZero = 0;
  			StartMult = 0;
  			MultStop = 0;
  			MultO = 0;
          	
          	nextState = Wait;
		end
		Wait= begin
          PCWriteCond = 0;
  			PCWrite = 0;
  			//sinais dos registradores
  			MDRS = 0;
  			IRWrite = 1;
  			RegWriteSignal = 0;
  			RegAW = 0;
  			RegBW = 0;
  			RegAluWrite = 0;
  			EPCWrite = 0;
  			RegHighW = 0;
  			RegLowW = 0;
  			//sinais dos MUX
			PCCondMux = 2'b00;
			IorDMux = 3'b000;
  			ReadSMux = 0;
			ReadDstMux = 2'b00;
			MemToRegMux = 3'b000;
  			AluSrcAMux = 0;
			AluSrcBMux = 2'b00;
  			PCSourceMux = 3'b000;
  			RegInMux = 0;
  			ShiftSMux = 0;
  			DivMultMux = 0;
  			MultSMux = 0;
  			//sinais dos componentes
  			WMS = 2'b00;
  			MemRead = 1;
			MemWrite = 0;
			AluOP = 3'b000;
  			ShiftOp = 0;
  			StartDiv = 0;
  			DivStop = 0;
  			DivZero = 0;
  			StartMult = 0;
  			MultStop = 0;
  			MultO = 0;
          	
          	nextState = Decode;
		end
		Decode= begin
          PCWriteCond = 0;
  			PCWrite = 0;
  			//sinais dos registradores
  			MDRS = 0;
  			IRWrite = 0;
  			RegWriteSignal = 0;
  			RegAW = 1;
  			RegBW = 1;
  			RegAluWrite = 1;
  			EPCWrite = 0;
  			RegHighW = 0;
  			RegLowW = 0;
  			//sinais dos MUX
			PCCondMux = 2'b00;
			IorDMux = 3'b000;
  			ReadSMux = 1;
			ReadDstMux = 2'b00;
			MemToRegMux = 3'b000;
  			AluSrcAMux = 0;
			AluSrcBMux = 2'b11;
  			PCSourceMux = 3'b000;
  			RegInMux = 0;
  			ShiftSMux = 0;
  			DivMultMux = 0;
  			MultSMux = 0;
  			//sinais dos componentes
  			WMS = 2'b00;
  			MemRead = 0;
			MemWrite = 0;
			AluOP = 3'b001;
  			ShiftOp = 0;
  			StartDiv = 0;
  			DivStop = 0;
  			DivZero = 0;
  			StartMult = 0;
  			MultStop = 0;
  			MultO = 0;          	
          	
			case(op)
        		6'h8 : nextState = Addi;
        		6'h9 : nextState = Addiu;
        		6'h4 : nextState = Beq_compare;
        		6'h5 : nextState = Bne_compare;
        		6'h6 : nextState = Ble_compare;
        		6'h7 : nextState = Bgt_compare;
        		6'h20 : nextState = LB_address;
        		6'h21: nextState = LH_address;
        		6'hf : nextState = Lui_load;
        		6'h23 : nextState = LW_address;
        		6'h28: nextState = SB_address;
        		6'h29 : nextState = SH_address;
        		6'ha : nextState = Slti;
        		6'h2b : nextState = SW_address;
        		6'h2 : nextState = J_jump;
        		6'h3 : nextState = Jal;
              	6'h0: //caso o opcode for 0x0, olhar o funct
          			case(funct)
                      6'h20 : nextState = Add;
                      6'h24 : nextState = And;
                      6'h1a : nextState = Div;
                      6'h18 : nextState = Mult;
                      6'h8 : nextState = Jr;
                      6'h10 : nextState = Mfhi;
                      6'h12 : nextState = Mflo;
                      6'h0 : nextState = ShiftShamt;
                      6'h4 : nextState = ShiftReg;
                      6'h2a : nextState = Slt;
                      6'h3 : nextState = ShiftShamt;
                      6'h7 : nextState = ShiftReg;
                      6'h2 : nextState = ShiftShamt;
                      6'h22 : nextState = Sub;
                      6'hd : nextState = Break;
                      6'h13 : nextState = Rte;
                      6'h5 : nextState = Push;
                      6'h6 : nextState = Pop;
                  		default: nextstate = Reset; // n sei se serve de algo mas ta ai
        			endcase
              default: nextstate = noop_load;
      		endcase
		end

		Beq_compare= begin
          PCWriteCond = 1;
  			PCWrite = 0;
  			//sinais dos registradores
  			MDRS = 0;
  			IRWrite = 0;
  			RegWriteSignal = 0;
  			RegAW = 0;
  			RegBW = 0;
  			RegAluWrite = 0;
  			EPCWrite = 0;
  			RegHighW = 0;
  			RegLowW = 0;
  			//sinais dos MUX
			PCCondMux = 2'b11;
			IorDMux = 3'b000;
  			ReadSMux = 0;
			ReadDstMux = 2'b00;
			MemToRegMux = 3'b000;
  			AluSrcAMux = 1;
			AluSrcBMux = 2'b00;
  			PCSourceMux = 3'b001;
  			RegInMux = 0;
  			ShiftSMux = 0;
  			DivMultMux = 0;
  			MultSMux = 0;
  			//sinais dos componentes
  			WMS = 2'b00;
  			MemRead = 0;
			MemWrite = 0;
			AluOP = 3'b010;
  			ShiftOp = 0;
  			StartDiv = 0;
  			DivStop = 0;
  			DivZero = 0;
  			StartMult = 0;
  			MultStop = 0;
  			MultO = 0;
          	
          	nextState = Fetch;
    	end
    	Bne_compare= begin
          PCWriteCond = 1;
  			PCWrite = 0;
  			//sinais dos registradores
  			MDRS = 0;
  			IRWrite = 0;
  			RegWriteSignal = 0;
  			RegAW = 0;
  			RegBW = 0;
  			RegAluWrite = 0;
  			EPCWrite = 0;
  			RegHighW = 0;
  			RegLowW = 0;
  			//sinais dos MUX
			PCCondMux = 2'b10;
			IorDMux = 3'b000;
  			ReadSMux = 0;
			ReadDstMux = 2'b00;
			MemToRegMux = 3'b000;
  			AluSrcAMux = 1;
			AluSrcBMux = 2'b00;
  			PCSourceMux = 3'b001;
  			RegInMux = 0;
  			ShiftSMux = 0;
  			DivMultMux = 0;
  			MultSMux = 0;
  			//sinais dos componentes
  			WMS = 2'b00;
  			MemRead = 0;
			MemWrite = 0;
			AluOP = 3'b111;
  			ShiftOp = 0;
  			StartDiv = 0;
  			DivStop = 0;
  			DivZero = 0;
  			StartMult = 0;
  			MultStop = 0;
  			MultO = 0;
          	
          	nextState = Fetch;
    	end
    	Ble_compare= begin
          PCWriteCond = 1;
  			PCWrite = 0;
  			//sinais dos registradores
  			MDRS = 0;
  			IRWrite = 0;
  			RegWriteSignal = 0;
  			RegAW = 0;
  			RegBW = 0;
  			RegAluWrite = 0;
  			EPCWrite = 0;
  			RegHighW = 0;
  			RegLowW = 0;
  			//sinais dos MUX
			PCCondMux = 2'b01;
			IorDMux = 3'b000;
  			ReadSMux = 0;
			ReadDstMux = 2'b00;
			MemToRegMux = 3'b000;
  			AluSrcAMux = 1;
			AluSrcBMux = 2'b00;
  			PCSourceMux = 3'b001;
  			RegInMux = 0;
  			ShiftSMux = 0;
  			DivMultMux = 0;
  			MultSMux = 0;
  			//sinais dos componentes
  			WMS = 2'b00;
  			MemRead = 0;
			MemWrite = 0;
			AluOP = 3'b111;
  			ShiftOp = 0;
  			StartDiv = 0;
  			DivStop = 0;
  			DivZero = 0;
  			StartMult = 0;
  			MultStop = 0;
  			MultO = 0;
          	
          	nextState = Fetch;
    	end
    	Bgt_compare= begin
          PCWriteCond = 1;
  			PCWrite = 0;
  			//sinais dos registradores
  			MDRS = 0;
  			IRWrite = 0;
  			RegWriteSignal = 0;
  			RegAW = 0;
  			RegBW = 0;
  			RegAluWrite = 0;
  			EPCWrite = 0;
  			RegHighW = 0;
  			RegLowW = 0;
  			//sinais dos MUX
			PCCondMux = 2'b00;
			IorDMux = 3'b000;
  			ReadSMux = 0;
			ReadDstMux = 2'b00;
			MemToRegMux = 3'b000;
  			AluSrcAMux = 1;
			AluSrcBMux = 2'b00;
  			PCSourceMux = 3'b001;
  			RegInMux = 0;
  			ShiftSMux = 0;
  			DivMultMux = 0;
  			MultSMux = 0;
  			//sinais dos componentes
  			WMS = 2'b00;
  			MemRead = 0;
			MemWrite = 0;
			AluOP = 3'b111;
  			ShiftOp = 0;
  			StartDiv = 0;
  			DivStop = 0;
  			DivZero = 0;
  			StartMult = 0;
  			MultStop = 0;
  			MultO = 0;
          	
          	nextState = Fetch;
    	end
    	LW_address= begin
          PCWriteCond = 0;
  			PCWrite = 0;
  			//sinais dos registradores
  			MDRS = 0;
  			IRWrite = 0;
  			RegWriteSignal = 0;
  			RegAW = 0;
  			RegBW = 0;
  			RegAluWrite = 1;
  			EPCWrite = 0;
  			RegHighW = 0;
  			RegLowW = 0;
  			//sinais dos MUX
			PCCondMux = 2'b00;
			IorDMux = 3'b000;
  			ReadSMux = 0;
			ReadDstMux = 2'b00;
			MemToRegMux = 3'b000;
  			AluSrcAMux = 1;
			AluSrcBMux = 2'b10;
  			PCSourceMux = 3'b000;
  			RegInMux = 0;
  			ShiftSMux = 0;
  			DivMultMux = 0;
  			MultSMux = 0;
  			//sinais dos componentes
  			WMS = 2'b00;
  			MemRead = 0;
			MemWrite = 0;
			AluOP = 3'b001;
  			ShiftOp = 0;
  			StartDiv = 0;
  			DivStop = 0;
  			DivZero = 0;
  			StartMult = 0;
  			MultStop = 0;
  			MultO = 0;
          	
          	nextState = LW_memory;
    	end
    	LW_memory= begin
          PCWriteCond = 0;
  			PCWrite = 0;
  			//sinais dos registradores
  			MDRS = 0;
  			IRWrite = 0;
  			RegWriteSignal = 0;
  			RegAW = 0;
  			RegBW = 0;
  			RegAluWrite = 0;
  			EPCWrite = 0;
  			RegHighW = 0;
  			RegLowW = 0;
  			//sinais dos MUX
			PCCondMux = 2'b00;
			IorDMux = 3'b100;
  			ReadSMux = 0;
			ReadDstMux = 2'b00;
			MemToRegMux = 3'b000;
  			AluSrcAMux = 0;
			AluSrcBMux = 2'b00;
  			PCSourceMux = 3'b000;
  			RegInMux = 0;
  			ShiftSMux = 0;
  			DivMultMux = 0;
  			MultSMux = 0;
  			//sinais dos componentes
  			WMS = 2'b00;
  			MemRead = 1;
			MemWrite = 0;
			AluOP = 3'b000;
  			ShiftOp = 0;
  			StartDiv = 0;
  			DivStop = 0;
  			DivZero = 0;
  			StartMult = 0;
  			MultStop = 0;
  			MultO = 0;
          	
          	nextState = LW_wait;
    	end
    	LW_wait= begin
          PCWriteCond = 0;
  			PCWrite = 0;
  			//sinais dos registradores
  			MDRS = 1;
  			IRWrite = 0;
  			RegWriteSignal = 0;
  			RegAW = 0;
  			RegBW = 0;
  			RegAluWrite = 0;
  			EPCWrite = 0;
  			RegHighW = 0;
  			RegLowW = 0;
  			//sinais dos MUX
			PCCondMux = 2'b00;
			IorDMux = 3'b000;
  			ReadSMux = 0;
			ReadDstMux = 2'b00;
			MemToRegMux = 3'b000;
  			AluSrcAMux = 0;
			AluSrcBMux = 2'b00;
  			PCSourceMux = 3'b000;
  			RegInMux = 0;
  			ShiftSMux = 0;
  			DivMultMux = 0;
  			MultSMux = 0;
  			//sinais dos componentes
  			WMS = 2'b00;
  			MemRead = 1;
			MemWrite = 0;
			AluOP = 3'b000;
  			ShiftOp = 0;
  			StartDiv = 0;
  			DivStop = 0;
  			DivZero = 0;
  			StartMult = 0;
  			MultStop = 0;
  			MultO = 0;
          	
          	nextState = LW_write;
    	end
    	LW_write= begin
        PCWriteCond = 0;
  			PCWrite = 0;
  			//sinais dos registradores
  			MDRS = 0;
  			IRWrite = 0;
  			RegWriteSignal = 1;
  			RegAW = 0;
  			RegBW = 0;
  			RegAluWrite = 0;
  			EPCWrite = 0;
  			RegHighW = 0;
  			RegLowW = 0;
  			//sinais dos MUX
			PCCondMux = 2'b00;
			IorDMux = 3'b000;
  			ReadSMux = 0;
			ReadDstMux = 2'b00;
			MemToRegMux = 3'b010;
  			AluSrcAMux = 0;
			AluSrcBMux = 2'b00;
  			PCSourceMux = 3'b000;
  			RegInMux = 0;
  			ShiftSMux = 0;
  			DivMultMux = 0;
  			MultSMux = 0;
  			//sinais dos componentes
  			WMS = 2'b00;
  			MemRead = 0;
			MemWrite = 0;
			AluOP = 3'b000;
  			ShiftOp = 0;
  			StartDiv = 0;
  			DivStop = 0;
  			DivZero = 0;
  			StartMult = 0;
  			MultStop = 0;
  			MultO = 0;
          	
          	nextState = Fetch;
    	end
    	SW_address= begin
          PCWriteCond = 0;
  			PCWrite = 0;
  			//sinais dos registradores
  			MDRS = 0;
  			IRWrite = 0;
  			RegWriteSignal = 0;
  			RegAW = 0;
  			RegBW = 0;
  			RegAluWrite = 1;
  			EPCWrite = 0;
  			RegHighW = 0;
  			RegLowW = 0;
  			//sinais dos MUX
			PCCondMux = 2'b00;
			IorDMux = 3'b000;
  			ReadSMux = 0;
			ReadDstMux = 2'b00;
			MemToRegMux = 3'b000;
  			AluSrcAMux = 1;
			AluSrcBMux = 2'b10;
  			PCSourceMux = 3'b000;
  			RegInMux = 0;
  			ShiftSMux = 0;
  			DivMultMux = 0;
  			MultSMux = 0;
  			//sinais dos componentes
  			WMS = 2'b00;
  			MemRead = 0;
			MemWrite = 0;
			AluOP = 3'b001;
  			ShiftOp = 0;
  			StartDiv = 0;
  			DivStop = 0;
  			DivZero = 0;
  			StartMult = 0;
  			MultStop = 0;
  			MultO = 0;
          	
          	nextState = SW_memory;
    	end
    	SW_memory= begin
          PCWriteCond = 0;
  			PCWrite = 0;
  			//sinais dos registradores
  			MDRS = 0;
  			IRWrite = 0;
  			RegWriteSignal = 0;
  			RegAW = 0;
  			RegBW = 0;
  			RegAluWrite = 0;
  			EPCWrite = 0;
  			RegHighW = 0;
  			RegLowW = 0;
  			//sinais dos MUX
			PCCondMux = 2'b00;
			IorDMux = 3'b100;
  			ReadSMux = 0;
			ReadDstMux = 2'b00;
			MemToRegMux = 3'b000;
  			AluSrcAMux = 0;
			AluSrcBMux = 2'b00;
  			PCSourceMux = 3'b000;
  			RegInMux = 0;
  			ShiftSMux = 0;
  			DivMultMux = 0;
  			MultSMux = 0;
  			//sinais dos componentes
  			WMS = 2'b00;
  			MemRead = 1;
			MemWrite = 0;
			AluOP = 3'b000;
  			ShiftOp = 0;
  			StartDiv = 0;
  			DivStop = 0;
  			DivZero = 0;
  			StartMult = 0;
  			MultStop = 0;
  			MultO = 0;
          	
          	nextState = SW_wait;
    	end
    	SW_wait= begin
          PCWriteCond = 0;
  			PCWrite = 0;
  			//sinais dos registradores
  			MDRS = 1;
  			IRWrite = 0;
  			RegWriteSignal = 0;
  			RegAW = 0;
  			RegBW = 0;
  			RegAluWrite = 0;
  			EPCWrite = 0;
  			RegHighW = 0;
  			RegLowW = 0;
  			//sinais dos MUX
			PCCondMux = 2'b00;
			IorDMux = 3'b000;
  			ReadSMux = 0;
			ReadDstMux = 2'b00;
			MemToRegMux = 3'b000;
  			AluSrcAMux = 0;
			AluSrcBMux = 2'b00;
  			PCSourceMux = 3'b000;
  			RegInMux = 0;
  			ShiftSMux = 0;
  			DivMultMux = 0;
  			MultSMux = 0;
  			//sinais dos componentes
  			WMS = 2'b00;
  			MemRead = 1;
			MemWrite = 0;
			AluOP = 3'b000;
  			ShiftOp = 0;
  			StartDiv = 0;
  			DivStop = 0;
  			DivZero = 0;
  			StartMult = 0;
  			MultStop = 0;
  			MultO = 0;
          	
          	nextState = SW_write;
    	end
    	SW_write= begin
          PCWriteCond = 0;
  			PCWrite = 0;
  			//sinais dos registradores
  			MDRS = 0;
  			IRWrite = 0;
  			RegWriteSignal = 0;
  			RegAW = 0;
  			RegBW = 0;
  			RegAluWrite = 0;
  			EPCWrite = 0;
  			RegHighW = 0;
  			RegLowW = 0;
  			//sinais dos MUX
			PCCondMux = 2'b00;
			IorDMux = 3'b000;
  			ReadSMux = 0;
			ReadDstMux = 2'b00;
			MemToRegMux = 3'b000;
  			AluSrcAMux = 0;
			AluSrcBMux = 2'b00;
  			PCSourceMux = 3'b000;
  			RegInMux = 0;
  			ShiftSMux = 0;
  			DivMultMux = 0;
  			MultSMux = 0;
  			//sinais dos componentes
  			WMS = 2'b00;
  			MemRead = 0;
			MemWrite = 1;
			AluOP = 3'b000;
  			ShiftOp = 0;
  			StartDiv = 0;
  			DivStop = 0;
  			DivZero = 0;
  			StartMult = 0;
  			MultStop = 0;
  			MultO = 0;
          	
          	nextState = Fetch;
    	end
    	Lui_load=begin
          PCWriteCond = 0;
  			PCWrite = 0;
  			//sinais dos registradores
  			MDRS = 0;
  			IRWrite = 0;
  			RegWriteSignal = 1;
  			RegAW = 0;
  			RegBW = 0;
  			RegAluWrite = 0;
  			EPCWrite = 0;
  			RegHighW = 0;
  			RegLowW = 0;
  			//sinais dos MUX
			PCCondMux = 2'b00;
			IorDMux = 3'b000;
  			ReadSMux = 0;
			ReadDstMux = 2'b00;
			MemToRegMux = 3'b100;
  			AluSrcAMux = 0;
			AluSrcBMux = 2'b00;
  			PCSourceMux = 3'b000;
  			RegInMux = 0;
  			ShiftSMux = 0;
  			DivMultMux = 0;
  			MultSMux = 0;
  			//sinais dos componentes
  			WMS = 2'b00;
  			MemRead = 0;
			MemWrite = 0;
			AluOP = 3'b000;
  			ShiftOp = 0;
  			StartDiv = 0;
  			DivStop = 0;
  			DivZero = 0;
  			StartMult = 0;
  			MultStop = 0;
  			MultO = 0;
          	
          	nextState = Fetch;
    	end
    	J_jump= begin
          PCWriteCond = 0;
  			PCWrite = 1;
  			//sinais dos registradores
  			MDRS = 0;
  			IRWrite = 0;
  			RegWriteSignal = 0;
  			RegAW = 0;
  			RegBW = 0;
  			RegAluWrite = 0;
  			EPCWrite = 0;
  			RegHighW = 0;
  			RegLowW = 0;
  			//sinais dos MUX
			PCCondMux = 2'b00;
			IorDMux = 3'b000;
  			ReadSMux = 0;
			ReadDstMux = 2'b00;
			MemToRegMux = 3'b000;
  			AluSrcAMux = 0;
			AluSrcBMux = 2'b00;
  			PCSourceMux = 3'b100;
  			RegInMux = 0;
  			ShiftSMux = 0;
  			DivMultMux = 0;
  			MultSMux = 0;
  			//sinais dos componentes
  			WMS = 2'b00;
  			MemRead = 0;
			MemWrite = 0;
			AluOP = 3'b000;
  			ShiftOp = 0;
  			StartDiv = 0;
  			DivStop = 0;
  			DivZero = 0;
  			StartMult = 0;
  			MultStop = 0;
  			MultO = 0;
          	
          	nextState = Fetch;
    	end
    	Jal= begin
          PCWriteCond = 0;
  			PCWrite = 0;
  			//sinais dos registradores
  			MDRS = 0;
  			IRWrite = 0;
  			RegWriteSignal = 0;
  			RegAW = 0;
  			RegBW = 0;
  			RegAluWrite = 1;
  			EPCWrite = 0;
  			RegHighW = 0;
  			RegLowW = 0;
  			//sinais dos MUX
			PCCondMux = 2'b00;
			IorDMux = 3'b000;
  			ReadSMux = 0;
			ReadDstMux = 2'b00;
			MemToRegMux = 3'b000;
  			AluSrcAMux = 0;
			AluSrcBMux = 2'b00;
  			PCSourceMux = 3'b000;
  			RegInMux = 0;
  			ShiftSMux = 0;
  			DivMultMux = 0;
  			MultSMux = 0;
  			//sinais dos componentes
  			WMS = 2'b00;
  			MemRead = 0;
			MemWrite = 0;
			AluOP = 3'b000;
  			ShiftOp = 0;
  			StartDiv = 0;
  			DivStop = 0;
  			DivZero = 0;
  			StartMult = 0;
  			MultStop = 0;
  			MultO = 0;
          	
          	nextState = saveEjump;
    	end
    	saveEjump= begin
          PCWriteCond = 0;
  			PCWrite = 1;
  			//sinais dos registradores
  			MDRS = 0;
  			IRWrite = 0;
  			RegWriteSignal = 1;
  			RegAW = 0;
  			RegBW = 0;
  			RegAluWrite = 0;
  			EPCWrite = 0;
  			RegHighW = 0;
  			RegLowW = 0;
  			//sinais dos MUX
			PCCondMux = 2'b00;
			IorDMux = 3'b000;
  			ReadSMux = 0;
			ReadDstMux = 2'b01;
			MemToRegMux = 3'b000;
  			AluSrcAMux = 0;
			AluSrcBMux = 2'b00;
  			PCSourceMux = 3'b010;
  			RegInMux = 0;
  			ShiftSMux = 0;
  			DivMultMux = 0;
  			MultSMux = 0;
  			//sinais dos componentes
  			WMS = 2'b00;
  			MemRead = 0;
			MemWrite = 0;
			AluOP = 3'b000;
  			ShiftOp = 0;
  			StartDiv = 0;
  			DivStop = 0;
  			DivZero = 0;
  			StartMult = 0;
  			MultStop = 0;
  			MultO = 0;
          	
          	nextState = Fetch;
    	end
    	LH_address= begin
          PCWriteCond = 0;
  			PCWrite = 0;
  			//sinais dos registradores
  			MDRS = 0;
  			IRWrite = 0;
  			RegWriteSignal = 0;
  			RegAW = 0;
  			RegBW = 0;
  			RegAluWrite = 1;
  			EPCWrite = 0;
  			RegHighW = 0;
  			RegLowW = 0;
  			//sinais dos MUX
			PCCondMux = 2'b00;
			IorDMux = 3'b000;
  			ReadSMux = 0;
			ReadDstMux = 2'b00;
			MemToRegMux = 3'b000;
  			AluSrcAMux = 1;
			AluSrcBMux = 2'b10;
  			PCSourceMux = 3'b000;
  			RegInMux = 0;
  			ShiftSMux = 0;
  			DivMultMux = 0;
  			MultSMux = 0;
  			//sinais dos componentes
  			WMS = 2'b00;
  			MemRead = 0;
			MemWrite = 0;
			AluOP = 3'b001;
  			ShiftOp = 0;
  			StartDiv = 0;
  			DivStop = 0;
  			DivZero = 0;
  			StartMult = 0;
  			MultStop = 0;
  			MultO = 0;
          	
          	nextState = LH_memory;
      	end
    	LH_memory= begin
          PCWriteCond = 0;
  			PCWrite = 0;
  			//sinais dos registradores
  			MDRS = 0;
  			IRWrite = 0;
  			RegWriteSignal = 0;
  			RegAW = 0;
  			RegBW = 0;
  			RegAluWrite = 0;
  			EPCWrite = 0;
  			RegHighW = 0;
  			RegLowW = 0;
  			//sinais dos MUX
			PCCondMux = 2'b00;
			IorDMux = 3'b100;
  			ReadSMux = 0;
			ReadDstMux = 2'b00;
			MemToRegMux = 3'b000;
  			AluSrcAMux = 0;
			AluSrcBMux = 2'b00;
  			PCSourceMux = 3'b000;
  			RegInMux = 0;
  			ShiftSMux = 0;
  			DivMultMux = 0;
  			MultSMux = 0;
  			//sinais dos componentes
  			WMS = 2'b00;
  			MemRead = 1;
			MemWrite = 0;
			AluOP = 3'b000;
  			ShiftOp = 0;
  			StartDiv = 0;
  			DivStop = 0;
  			DivZero = 0;
  			StartMult = 0;
  			MultStop = 0;
  			MultO = 0;
          	
          	nextState = LH_wait;
    	end
    	LH_wait= begin
          PCWriteCond = 0;
  			PCWrite = 0;
  			//sinais dos registradores
  			MDRS = 1;
  			IRWrite = 0;
  			RegWriteSignal = 0;
  			RegAW = 0;
  			RegBW = 0;
  			RegAluWrite = 0;
  			EPCWrite = 0;
  			RegHighW = 0;
  			RegLowW = 0;
  			//sinais dos MUX
			PCCondMux = 2'b00;
			IorDMux = 3'b000;
  			ReadSMux = 0;
			ReadDstMux = 2'b00;
			MemToRegMux = 3'b000;
  			AluSrcAMux = 0;
			AluSrcBMux = 2'b00;
  			PCSourceMux = 3'b000;
  			RegInMux = 0;
  			ShiftSMux = 0;
  			DivMultMux = 0;
  			MultSMux = 0;
  			//sinais dos componentes
  			WMS = 2'b00;
  			MemRead = 1;
			MemWrite = 0;
			AluOP = 3'b000;
  			ShiftOp = 0;
  			StartDiv = 0;
  			DivStop = 0;
  			DivZero = 0;
  			StartMult = 0;
  			MultStop = 0;
  			MultO = 0;
          	
          	nextState = LH_write;
    	end    	
    	LH_write= begin
          PCWriteCond = 0;
  			PCWrite = 0;
  			//sinais dos registradores
  			MDRS = 0;
  			IRWrite = 0;
  			RegWriteSignal = 1;
  			RegAW = 0;
  			RegBW = 0;
  			RegAluWrite = 0;
  			EPCWrite = 0;
  			RegHighW = 0;
  			RegLowW = 0;
  			//sinais dos MUX
			PCCondMux = 2'b00;
			IorDMux = 3'b000;
  			ReadSMux = 0;
			ReadDstMux = 2'b00;
			MemToRegMux = 3'b010;
  			AluSrcAMux = 0;
			AluSrcBMux = 2'b00;
  			PCSourceMux = 3'b000;
  			RegInMux = 0;
  			ShiftSMux = 0;
  			DivMultMux = 0;
  			MultSMux = 0;
  			//sinais dos componentes
  			WMS = 2'b01;
  			MemRead = 0;
			MemWrite = 0;
			AluOP = 3'b000;
  			ShiftOp = 0;
  			StartDiv = 0;
  			DivStop = 0;
  			DivZero = 0;
  			StartMult = 0;
  			MultStop = 0;
  			MultO = 0;
          	
          	nextState = Fetch;
    	end
    	LB_address= begin
          PCWriteCond = 0;
  			PCWrite = 0;
  			//sinais dos registradores
  			MDRS = 0;
  			IRWrite = 0;
  			RegWriteSignal = 0;
  			RegAW = 0;
  			RegBW = 0;
  			RegAluWrite = 1;
  			EPCWrite = 0;
  			RegHighW = 0;
  			RegLowW = 0;
  			//sinais dos MUX
			PCCondMux = 2'b00;
			IorDMux = 3'b000;
  			ReadSMux = 0;
			ReadDstMux = 2'b00;
			MemToRegMux = 3'b000;
  			AluSrcAMux = 1;
			AluSrcBMux = 2'b10;
  			PCSourceMux = 3'b000;
  			RegInMux = 0;
  			ShiftSMux = 0;
  			DivMultMux = 0;
  			MultSMux = 0;
  			//sinais dos componentes
  			WMS = 2'b00;
  			MemRead = 0;
			MemWrite = 0;
			AluOP = 3'b001;
  			ShiftOp = 0;
  			StartDiv = 0;
  			DivStop = 0;
  			DivZero = 0;
  			StartMult = 0;
  			MultStop = 0;
  			MultO = 0;
          	
          	nextState = LB_memory;
    	end
    	LB_memory= begin
          PCWriteCond = 0;
  			PCWrite = 0;
  			//sinais dos registradores
  			MDRS = 0;
  			IRWrite = 0;
  			RegWriteSignal = 0;
  			RegAW = 0;
  			RegBW = 0;
  			RegAluWrite = 0;
  			EPCWrite = 0;
  			RegHighW = 0;
  			RegLowW = 0;
  			//sinais dos MUX
			PCCondMux = 2'b00;
			IorDMux = 3'b100;
  			ReadSMux = 0;
			ReadDstMux = 2'b00;
			MemToRegMux = 3'b000;
  			AluSrcAMux = 0;
			AluSrcBMux = 2'b00;
  			PCSourceMux = 3'b000;
  			RegInMux = 0;
  			ShiftSMux = 0;
  			DivMultMux = 0;
  			MultSMux = 0;
  			//sinais dos componentes
  			WMS = 2'b00;
  			MemRead = 1;
			MemWrite = 0;
			AluOP = 3'b000;
  			ShiftOp = 0;
  			StartDiv = 0;
  			DivStop = 0;
  			DivZero = 0;
  			StartMult = 0;
  			MultStop = 0;
  			MultO = 0;
          	
          	nextState = LB_wait;
    	end
    	LB_wait= begin
          PCWriteCond = 0;
  			PCWrite = 0;
  			//sinais dos registradores
  			MDRS = 1;
  			IRWrite = 0;
  			RegWriteSignal = 0;
  			RegAW = 0;
  			RegBW = 0;
  			RegAluWrite = 0;
  			EPCWrite = 0;
  			RegHighW = 0;
  			RegLowW = 0;
  			//sinais dos MUX
			PCCondMux = 2'b00;
			IorDMux = 3'b000;
  			ReadSMux = 0;
			ReadDstMux = 2'b00;
			MemToRegMux = 3'b000;
  			AluSrcAMux = 0;
			AluSrcBMux = 2'b00;
  			PCSourceMux = 3'b000;
  			RegInMux = 0;
  			ShiftSMux = 0;
  			DivMultMux = 0;
  			MultSMux = 0;
  			//sinais dos componentes
  			WMS = 2'b00;
  			MemRead = 1;
			MemWrite = 0;
			AluOP = 3'b000;
  			ShiftOp = 0;
  			StartDiv = 0;
  			DivStop = 0;
  			DivZero = 0;
  			StartMult = 0;
  			MultStop = 0;
  			MultO = 0;
          	
          	nextState = LB_write;
    	end
    	LB_write= begin
          PCWriteCond = 0;
  			PCWrite = 0;
  			//sinais dos registradores
  			MDRS = 0;
  			IRWrite = 0;
  			RegWriteSignal = 1;
  			RegAW = 0;
  			RegBW = 0;
  			RegAluWrite = 0;
  			EPCWrite = 0;
  			RegHighW = 0;
  			RegLowW = 0;
  			//sinais dos MUX
			PCCondMux = 2'b00;
			IorDMux = 3'b000;
  			ReadSMux = 0;
			ReadDstMux = 2'b00;
			MemToRegMux = 3'b010;
  			AluSrcAMux = 0;
			AluSrcBMux = 2'b00;
  			PCSourceMux = 3'b000;
  			RegInMux = 0;
  			ShiftSMux = 0;
  			DivMultMux = 0;
  			MultSMux = 0;
  			//sinais dos componentes
  			WMS = 2'b10;
  			MemRead = 0;
			MemWrite = 0;
			AluOP = 3'b000;
  			ShiftOp = 0;
  			StartDiv = 0;
  			DivStop = 0;
  			DivZero = 0;
  			StartMult = 0;
  			MultStop = 0;
  			MultO = 0;
          	
          	nextState = Fetch;
    	end
    	SH_address= begin
          PCWriteCond = 0;
  			PCWrite = 0;
  			//sinais dos registradores
  			MDRS = 0;
  			IRWrite = 0;
  			RegWriteSignal = 0;
  			RegAW = 0;
  			RegBW = 0;
  			RegAluWrite = 1;
  			EPCWrite = 0;
  			RegHighW = 0;
  			RegLowW = 0;
  			//sinais dos MUX
			PCCondMux = 2'b00;
			IorDMux = 3'b000;
  			ReadSMux = 0;
			ReadDstMux = 2'b00;
			MemToRegMux = 3'b000;
  			AluSrcAMux = 1;
			AluSrcBMux = 2'b10;
  			PCSourceMux = 3'b000;
  			RegInMux = 0;
  			ShiftSMux = 0;
  			DivMultMux = 0;
  			MultSMux = 0;
  			//sinais dos componentes
  			WMS = 2'b00;
  			MemRead = 0;
			MemWrite = 0;
			AluOP = 3'b001;
  			ShiftOp = 0;
  			StartDiv = 0;
  			DivStop = 0;
  			DivZero = 0;
  			StartMult = 0;
  			MultStop = 0;
  			MultO = 0;
          	
          	nextState = SH_memory;
          
    	end
    	SH_memory= begin
          PCWriteCond = 0;
  			PCWrite = 0;
  			//sinais dos registradores
  			MDRS = 0;
  			IRWrite = 0;
  			RegWriteSignal = 0;
  			RegAW = 0;
  			RegBW = 0;
  			RegAluWrite = 0;
  			EPCWrite = 0;
  			RegHighW = 0;
  			RegLowW = 0;
  			//sinais dos MUX
			PCCondMux = 2'b00;
			IorDMux = 3'b100;
  			ReadSMux = 0;
			ReadDstMux = 2'b00;
			MemToRegMux = 3'b000;
  			AluSrcAMux = 0;
			AluSrcBMux = 2'b00;
  			PCSourceMux = 3'b000;
  			RegInMux = 0;
  			ShiftSMux = 0;
  			DivMultMux = 0;
  			MultSMux = 0;
  			//sinais dos componentes
  			WMS = 2'b00;
  			MemRead = 1;
			MemWrite = 0;
			AluOP = 3'b000;
  			ShiftOp = 0;
  			StartDiv = 0;
  			DivStop = 0;
  			DivZero = 0;
  			StartMult = 0;
  			MultStop = 0;
  			MultO = 0;
          	
          	nextState = SH_wait;
    	end
    	SH_wait= begin
          PCWriteCond = 0;
  			PCWrite = 0;
  			//sinais dos registradores
  			MDRS = 1;
  			IRWrite = 0;
  			RegWriteSignal = 0;
  			RegAW = 0;
  			RegBW = 0;
  			RegAluWrite = 0;
  			EPCWrite = 0;
  			RegHighW = 0;
  			RegLowW = 0;
  			//sinais dos MUX
			PCCondMux = 2'b00;
			IorDMux = 3'b000;
  			ReadSMux = 0;
			ReadDstMux = 2'b00;
			MemToRegMux = 3'b000;
  			AluSrcAMux = 0;
			AluSrcBMux = 2'b00;
  			PCSourceMux = 3'b000;
  			RegInMux = 0;
  			ShiftSMux = 0;
  			DivMultMux = 0;
  			MultSMux = 0;
  			//sinais dos componentes
  			WMS = 2'b00;
  			MemRead = 1;
			MemWrite = 0;
			AluOP = 3'b000;
  			ShiftOp = 0;
  			StartDiv = 0;
  			DivStop = 0;
  			DivZero = 0;
  			StartMult = 0;
  			MultStop = 0;
  			MultO = 0;
          	
          	nextState = SH_write;
    	end
    	SH_write= begin
          PCWriteCond = 0;
  			PCWrite = 0;
  			//sinais dos registradores
  			MDRS = 0;
  			IRWrite = 0;
  			RegWriteSignal = 0;
  			RegAW = 0;
  			RegBW = 0;
  			RegAluWrite = 0;
  			EPCWrite = 0;
  			RegHighW = 0;
  			RegLowW = 0;
  			//sinais dos MUX
			PCCondMux = 2'b00;
			IorDMux = 3'b000;
  			ReadSMux = 0;
			ReadDstMux = 2'b00;
			MemToRegMux = 3'b000;
  			AluSrcAMux = 0;
			AluSrcBMux = 2'b00;
  			PCSourceMux = 3'b000;
  			RegInMux = 0;
  			ShiftSMux = 0;
  			DivMultMux = 0;
  			MultSMux = 0;
  			//sinais dos componentes
  			WMS = 2'b01;
  			MemRead = 0;
			MemWrite = 1;
			AluOP = 3'b000;
  			ShiftOp = 0;
  			StartDiv = 0;
  			DivStop = 0;
  			DivZero = 0;
  			StartMult = 0;
  			MultStop = 0;
  			MultO = 0;
          	
          	nextState = Fetch;
    	end
    	SB_address= begin
          PCWriteCond = 0;
  			PCWrite = 0;
  			//sinais dos registradores
  			MDRS = 0;
  			IRWrite = 0;
  			RegWriteSignal = 0;
  			RegAW = 0;
  			RegBW = 0;
  			RegAluWrite = 1;
  			EPCWrite = 0;
  			RegHighW = 0;
  			RegLowW = 0;
  			//sinais dos MUX
			PCCondMux = 2'b00;
			IorDMux = 3'b000;
  			ReadSMux = 0;
			ReadDstMux = 2'b00;
			MemToRegMux = 3'b000;
  			AluSrcAMux = 1;
			AluSrcBMux = 2'b10;
  			PCSourceMux = 3'b000;
  			RegInMux = 0;
  			ShiftSMux = 0;
  			DivMultMux = 0;
  			MultSMux = 0;
  			//sinais dos componentes
  			WMS = 2'b00;
  			MemRead = 0;
			MemWrite = 0;
			AluOP = 3'b001;
  			ShiftOp = 0;
  			StartDiv = 0;
  			DivStop = 0;
  			DivZero = 0;
  			StartMult = 0;
  			MultStop = 0;
  			MultO = 0;
          	
          	nextState = SB_memory;
    	end
    	SB_memory= begin
          PCWriteCond = 0;
  			PCWrite = 0;
  			//sinais dos registradores
  			MDRS = 0;
  			IRWrite = 0;
  			RegWriteSignal = 0;
  			RegAW = 0;
  			RegBW = 0;
  			RegAluWrite = 0;
  			EPCWrite = 0;
  			RegHighW = 0;
  			RegLowW = 0;
  			//sinais dos MUX
			PCCondMux = 2'b00;
			IorDMux = 3'b100;
  			ReadSMux = 0;
			ReadDstMux = 2'b00;
			MemToRegMux = 3'b000;
  			AluSrcAMux = 0;
			AluSrcBMux = 2'b00;
  			PCSourceMux = 3'b000;
  			RegInMux = 0;
  			ShiftSMux = 0;
  			DivMultMux = 0;
  			MultSMux = 0;
  			//sinais dos componentes
  			WMS = 2'b00;
  			MemRead = 1;
			MemWrite = 0;
			AluOP = 3'b000;
  			ShiftOp = 0;
  			StartDiv = 0;
  			DivStop = 0;
  			DivZero = 0;
  			StartMult = 0;
  			MultStop = 0;
  			MultO = 0;
          	
          	nextState = SB_wait;
    	end
    	SB_wait= begin
          PCWriteCond = 0;
  			PCWrite = 0;
  			//sinais dos registradores
  			MDRS = 1;
  			IRWrite = 0;
  			RegWriteSignal = 0;
  			RegAW = 0;
  			RegBW = 0;
  			RegAluWrite = 0;
  			EPCWrite = 0;
  			RegHighW = 0;
  			RegLowW = 0;
  			//sinais dos MUX
			PCCondMux = 2'b00;
			IorDMux = 3'b000;
  			ReadSMux = 0;
			ReadDstMux = 2'b00;
			MemToRegMux = 3'b000;
  			AluSrcAMux = 0;
			AluSrcBMux = 2'b00;
  			PCSourceMux = 3'b000;
  			RegInMux = 0;
  			ShiftSMux = 0;
  			DivMultMux = 0;
  			MultSMux = 0;
  			//sinais dos componentes
  			WMS = 2'b00;
  			MemRead = 1;
			MemWrite = 0;
			AluOP = 3'b000;
  			ShiftOp = 0;
  			StartDiv = 0;
  			DivStop = 0;
  			DivZero = 0;
  			StartMult = 0;
  			MultStop = 0;
  			MultO = 0;
          	
          	nextState = SB_write;
    	end
      	SB_write= begin
          PCWriteCond = 0;
  			PCWrite = 0;
  			//sinais dos registradores
  			MDRS = 0;
  			IRWrite = 0;
  			RegWriteSignal = 0;
  			RegAW = 0;
  			RegBW = 0;
  			RegAluWrite = 0;
  			EPCWrite = 0;
  			RegHighW = 0;
  			RegLowW = 0;
  			//sinais dos MUX
			PCCondMux = 2'b00;
			IorDMux = 3'b000;
  			ReadSMux = 0;
			ReadDstMux = 2'b00;
			MemToRegMux = 3'b000;
  			AluSrcAMux = 0;
			AluSrcBMux = 2'b00;
  			PCSourceMux = 3'b000;
  			RegInMux = 0;
  			ShiftSMux = 0;
  			DivMultMux = 0;
  			MultSMux = 0;
  			//sinais dos componentes
  			WMS = 2'b10;
  			MemRead = 0;
			MemWrite = 1;
			AluOP = 3'b000;
  			ShiftOp = 0;
  			StartDiv = 0;
  			DivStop = 0;
  			DivZero = 0;
  			StartMult = 0;
  			MultStop = 0;
  			MultO = 0;
          	
          	nextState = Fetch;
    	end
      	Slti= begin
          PCWriteCond = 0;
  			PCWrite = 0;
  			//sinais dos registradores
  			MDRS = 0;
  			IRWrite = 0;
  			RegWriteSignal = 0;
  			RegAW = 0;
  			RegBW = 0;
  			RegAluWrite = 0;
  			EPCWrite = 0;
  			RegHighW = 0;
  			RegLowW = 0;
  			//sinais dos MUX
			PCCondMux = 2'b00;
			IorDMux = 3'b000;
  			ReadSMux = 0;
			ReadDstMux = 2'b00;
			MemToRegMux = 3'b000;
  			AluSrcAMux = 1;
			AluSrcBMux = 2'b10;
  			PCSourceMux = 3'b000;
  			RegInMux = 0;
  			ShiftSMux = 0;
  			DivMultMux = 0;
  			MultSMux = 0;
  			//sinais dos componentes
  			WMS = 2'b00;
  			MemRead = 0;
			MemWrite = 0;
			AluOP = 3'b111;
  			ShiftOp = 0;
  			StartDiv = 0;
  			DivStop = 0;
  			DivZero = 0;
  			StartMult = 0;
  			MultStop = 0;
  			MultO = 0;
          	
          	nextState = RegT_Write_slti;
      	end
      	RegT_Write_slti= begin
          PCWriteCond = 0;
  			PCWrite = 0;
  			//sinais dos registradores
  			MDRS = 0;
  			IRWrite = 0;
  			RegWriteSignal = 1;
  			RegAW = 0;
  			RegBW = 0;
  			RegAluWrite = 0;
  			EPCWrite = 0;
  			RegHighW = 0;
  			RegLowW = 0;
  			//sinais dos MUX
			PCCondMux = 2'b00;
			IorDMux = 3'b000;
  			ReadSMux = 0;
			ReadDstMux = 2'b00;
			MemToRegMux = 3'b101;
  			AluSrcAMux = 0;
			AluSrcBMux = 2'b00;
  			PCSourceMux = 3'b000;
  			RegInMux = 0;
  			ShiftSMux = 0;
  			DivMultMux = 0;
  			MultSMux = 0;
  			//sinais dos componentes
  			WMS = 2'b00;
  			MemRead = 0;
			MemWrite = 0;
			AluOP = 3'b000;
  			ShiftOp = 0;
  			StartDiv = 0;
  			DivStop = 0;
  			DivZero = 0;
  			StartMult = 0;
  			MultStop = 0;
  			MultO = 0;
          	
          	nextState = Fetch;
      	end
      	
        Addiu=begin
          PCWriteCond = 0;
  			PCWrite = 0;
  			//sinais dos registradores
  			MDRS = 0;
  			IRWrite = 0;
  			RegWriteSignal = 0;
  			RegAW = 0;
  			RegBW = 0;
  			RegAluWrite = 1;
  			EPCWrite = 0;
  			RegHighW = 0;
  			RegLowW = 0;
  			//sinais dos MUX
			PCCondMux = 2'b00;
			IorDMux = 3'b000;
  			ReadSMux = 0;
			ReadDstMux = 2'b00;
			MemToRegMux = 3'b000;
  			AluSrcAMux = 1;
			AluSrcBMux = 2'b10;
  			PCSourceMux = 3'b000;
  			RegInMux = 0;
  			ShiftSMux = 0;
  			DivMultMux = 0;
  			MultSMux = 0;
  			//sinais dos componentes
  			WMS = 2'b00;
  			MemRead = 0;
			MemWrite = 0;
			AluOP = 3'b001;
  			ShiftOp = 0;
  			StartDiv = 0;
  			DivStop = 0;
  			DivZero = 0;
  			StartMult = 0;
  			MultStop = 0;
  			MultO = 0;
          	
          	nextState = RegT_write;
      	end
      	Addi= begin
          PCWriteCond = 0;
  			PCWrite = 0;
  			//sinais dos registradores
  			MDRS = 0;
  			IRWrite = 0;
  			RegWriteSignal = 0;
  			RegAW = 0;
  			RegBW = 0;
  			RegAluWrite = 1;
  			EPCWrite = 0;
  			RegHighW = 0;
  			RegLowW = 0;
  			//sinais dos MUX
			PCCondMux = 2'b00;
			IorDMux = 3'b000;
  			ReadSMux = 0;
			ReadDstMux = 2'b00;
			MemToRegMux = 3'b000;
  			AluSrcAMux = 1;
			AluSrcBMux = 2'b10;
  			PCSourceMux = 3'b000;
  			RegInMux = 0;
  			ShiftSMux = 0;
  			DivMultMux = 0;
  			MultSMux = 0;
  			//sinais dos componentes
  			WMS = 2'b00;
  			MemRead = 0;
			MemWrite = 0;
			AluOP = 3'b001;
  			ShiftOp = 0;
  			StartDiv = 0;
  			DivStop = 0;
  			DivZero = 0;
  			StartMult = 0;
  			MultStop = 0;
  			MultO = 0;
          	
          	nextState = Overflow ? ov_load : RegT_Write;
      	end
      	RegT_Write= begin
          PCWriteCond = 0;
  			PCWrite = 0;
  			//sinais dos registradores
  			MDRS = 0;
  			IRWrite = 0;
  			RegWriteSignal = 1;
  			RegAW = 0;
  			RegBW = 0;
  			RegAluWrite = 0;
  			EPCWrite = 0;
  			RegHighW = 0;
  			RegLowW = 0;
  			//sinais dos MUX
			PCCondMux = 2'b00;
			IorDMux = 3'b000;
  			ReadSMux = 0;
			ReadDstMux = 2'b00;
			MemToRegMux = 3'b000;
  			AluSrcAMux = 0;
			AluSrcBMux = 2'b00;
  			PCSourceMux = 3'b000;
  			RegInMux = 0;
  			ShiftSMux = 0;
  			DivMultMux = 0;
  			MultSMux = 0;
  			//sinais dos componentes
  			WMS = 2'b00;
  			MemRead = 0;
			MemWrite = 0;
			AluOP = 3'b000;
  			ShiftOp = 0;
  			StartDiv = 0;
  			DivStop = 0;
  			DivZero = 0;
  			StartMult = 0;
  			MultStop = 0;
  			MultO = 0;
          	
          	nextState = Fetch;
      	end

      	ov_load= begin
          PCWriteCond = 0;
  			PCWrite = 0;
  			//sinais dos registradores
  			MDRS = 0;
  			IRWrite = 0;
  			RegWriteSignal = 0;
  			RegAW = 0;
  			RegBW = 0;
  			RegAluWrite = 0;
  			EPCWrite = 0;
  			RegHighW = 0;
  			RegLowW = 0;
  			//sinais dos MUX
			PCCondMux = 2'b00;
			IorDMux = 3'b010;
  			ReadSMux = 0;
			ReadDstMux = 2'b00;
			MemToRegMux = 3'b000;
  			AluSrcAMux = 0;
			AluSrcBMux = 2'b00;
  			PCSourceMux = 3'b000;
  			RegInMux = 0;
  			ShiftSMux = 0;
  			DivMultMux = 0;
  			MultSMux = 0;
  			//sinais dos componentes
  			WMS = 2'b00;
  			MemRead = 1;
			MemWrite = 0;
			AluOP = 3'b000;
  			ShiftOp = 0;
  			StartDiv = 0;
  			DivStop = 0;
  			DivZero = 0;
  			StartMult = 0;
  			MultStop = 0;
  			MultO = 0;
          	
          	nextState = ov_wait;
      	end
      	ov_wait= begin
          PCWriteCond = 0;
  			PCWrite = 0;
  			//sinais dos registradores
  			MDRS = 1;
  			IRWrite = 0;
  			RegWriteSignal = 0;
  			RegAW = 0;
  			RegBW = 0;
  			RegAluWrite = 0;
  			EPCWrite = 0;
  			RegHighW = 0;
  			RegLowW = 0;
  			//sinais dos MUX
			PCCondMux = 2'b00;
			IorDMux = 3'b000;
  			ReadSMux = 0;
			ReadDstMux = 2'b00;
			MemToRegMux = 3'b000;
  			AluSrcAMux = 0;
			AluSrcBMux = 2'b00;
  			PCSourceMux = 3'b000;
  			RegInMux = 0;
  			ShiftSMux = 0;
  			DivMultMux = 0;
  			MultSMux = 0;
  			//sinais dos componentes
  			WMS = 2'b00;
  			MemRead = 1;
			MemWrite = 0;
			AluOP = 3'b000;
  			ShiftOp = 0;
  			StartDiv = 0;
  			DivStop = 0;
  			DivZero = 0;
  			StartMult = 0;
  			MultStop = 0;
  			MultO = 0;
          	
          	nextState = ov_pc;
      	end
      	ov_pc= begin
          PCWriteCond = 0;
  			PCWrite = 1;
  			//sinais dos registradores
  			MDRS = 0;
  			IRWrite = 0;
  			RegWriteSignal = 0;
  			RegAW = 0;
  			RegBW = 0;
  			RegAluWrite = 0;
  			EPCWrite = 0;
  			RegHighW = 0;
  			RegLowW = 0;
  			//sinais dos MUX
			PCCondMux = 2'b00;
			IorDMux = 3'b000;
  			ReadSMux = 0;
			ReadDstMux = 2'b00;
			MemToRegMux = 3'b000;
  			AluSrcAMux = 0;
			AluSrcBMux = 2'b00;
  			PCSourceMux = 3'b100;
  			RegInMux = 0;
  			ShiftSMux = 0;
  			DivMultMux = 0;
  			MultSMux = 0;
  			//sinais dos componentes
  			WMS = 2'b10;
  			MemRead = 0;
			MemWrite = 0;
			AluOP = 3'b000;
  			ShiftOp = 0;
  			StartDiv = 0;
  			DivStop = 0;
  			DivZero = 0;
  			StartMult = 0;
  			MultStop = 0;
  			MultO = 0;
          	
          	nextState = Fetch;
      	end

      	Push= begin
          PCWriteCond = 0;
  			PCWrite = 0;
  			//sinais dos registradores
  			MDRS = 0;
  			IRWrite = 0;
  			RegWriteSignal = 0;
  			RegAW = 1;
  			RegBW = 0;
  			RegAluWrite = 0;
  			EPCWrite = 0;
  			RegHighW = 0;
  			RegLowW = 0;
  			//sinais dos MUX
			PCCondMux = 2'b00;
			IorDMux = 3'b000;
  			ReadSMux = 1;
			ReadDstMux = 2'b00;
			MemToRegMux = 3'b000;
  			AluSrcAMux = 0;
			AluSrcBMux = 2'b00;
  			PCSourceMux = 3'b000;
  			RegInMux = 0;
  			ShiftSMux = 0;
  			DivMultMux = 0;
  			MultSMux = 0;
  			//sinais dos componentes
  			WMS = 2'b00;
  			MemRead = 0;
			MemWrite = 0;
			AluOP = 3'b000;
  			ShiftOp = 0;
  			StartDiv = 0;
  			DivStop = 0;
  			DivZero = 0;
  			StartMult = 0;
  			MultStop = 0;
  			MultO = 0;
          	
          	nextState = NewRA;
      	end
      	NewRA= begin
          PCWriteCond = 0;
  			PCWrite = 0;
  			//sinais dos registradores
  			MDRS = 0;
  			IRWrite = 0;
  			RegWriteSignal = 0;
  			RegAW = 0;
  			RegBW = 0;
  			RegAluWrite = 1;
  			EPCWrite = 0;
  			RegHighW = 0;
  			RegLowW = 0;
  			//sinais dos MUX
			PCCondMux = 2'b00;
			IorDMux = 3'b000;
  			ReadSMux = 0;
			ReadDstMux = 2'b00;
			MemToRegMux = 3'b000;
  			AluSrcAMux = 1;
			AluSrcBMux = 2'b01;
  			PCSourceMux = 3'b000;
  			RegInMux = 0;
  			ShiftSMux = 0;
  			DivMultMux = 0;
  			MultSMux = 0;
  			//sinais dos componentes
  			WMS = 2'b00;
  			MemRead = 0;
			MemWrite = 0;
			AluOP = 3'b010;
  			ShiftOp = 0;
  			StartDiv = 0;
  			DivStop = 0;
  			DivZero = 0;
  			StartMult = 0;
  			MultStop = 0;
  			MultO = 0;
          	
          	nextState = SaveRA_write;
      	end
      	SaveRA_write= begin
          PCWriteCond = 0;
  			PCWrite = 0;
  			//sinais dos registradores
  			MDRS = 0;
  			IRWrite = 0;
  			RegWriteSignal = 1;
  			RegAW = 0;
  			RegBW = 0;
  			RegAluWrite = 0;
  			EPCWrite = 0;
  			RegHighW = 0;
  			RegLowW = 0;
  			//sinais dos MUX
			PCCondMux = 2'b00;
			IorDMux = 3'b100;
  			ReadSMux = 0;
			ReadDstMux = 2'b10;
			MemToRegMux = 3'b000;
  			AluSrcAMux = 0;
			AluSrcBMux = 2'b00;
  			PCSourceMux = 3'b000;
  			RegInMux = 0;
  			ShiftSMux = 0;
  			DivMultMux = 0;
  			MultSMux = 0;
  			//sinais dos componentes
  			WMS = 2'b00;
  			MemRead = 0;
			MemWrite = 1;
			AluOP = 3'b000;
  			ShiftOp = 0;
  			StartDiv = 0;
  			DivStop = 0;
  			DivZero = 0;
  			StartMult = 0;
  			MultStop = 0;
  			MultO = 0;
          	
          	nextState = Fetch;
      	end

      	Pop=  begin
          PCWriteCond = 0;
  			PCWrite = 0;
  			//sinais dos registradores
  			MDRS = 0;
  			IRWrite = 0;
  			RegWriteSignal = 0;
  			RegAW = 1;
  			RegBW = 0;
  			RegAluWrite = 0;
  			EPCWrite = 0;
  			RegHighW = 0;
  			RegLowW = 0;
  			//sinais dos MUX
			PCCondMux = 2'b00;
			IorDMux = 3'b000;
  			ReadSMux = 0;
			ReadDstMux = 2'b00;
			MemToRegMux = 3'b000;
  			AluSrcAMux = 0;
			AluSrcBMux = 2'b00;
  			PCSourceMux = 3'b000;
  			RegInMux = 0;
  			ShiftSMux = 0;
  			DivMultMux = 0;
  			MultSMux = 0;
  			//sinais dos componentes
  			WMS = 2'b00;
  			MemRead = 0;
			MemWrite = 0;
			AluOP = 3'b000;
  			ShiftOp = 0;
  			StartDiv = 0;
  			DivStop = 0;
  			DivZero = 0;
  			StartMult = 0;
  			MultStop = 0;
  			MultO = 0;
          	
          	nextState = Address;
      	end
      	Address= begin
          PCWriteCond = 0;
  			PCWrite = 0;
  			//sinais dos registradores
  			MDRS = 0;
  			IRWrite = 0;
  			RegWriteSignal = 0;
  			RegAW = 0;
  			RegBW = 0;
  			RegAluWrite = 1;
  			EPCWrite = 0;
  			RegHighW = 0;
  			RegLowW = 0;
  			//sinais dos MUX
			PCCondMux = 2'b00;
			IorDMux = 3'b000;
  			ReadSMux = 0;
			ReadDstMux = 2'b00;
			MemToRegMux = 3'b000;
  			AluSrcAMux = 1;
			AluSrcBMux = 2'b00;
  			PCSourceMux = 3'b000;
  			RegInMux = 0;
  			ShiftSMux = 0;
  			DivMultMux = 0;
  			MultSMux = 0;
  			//sinais dos componentes
  			WMS = 2'b00;
  			MemRead = 0;
			MemWrite = 0;
			AluOP = 3'b000;
  			ShiftOp = 0;
  			StartDiv = 0;
  			DivStop = 0;
  			DivZero = 0;
  			StartMult = 0;
  			MultStop = 0;
  			MultO = 0;
          	
          	nextState = readAddress;
      	end
      	readAddres= begin
          PCWriteCond = 0;
  			PCWrite = 0;
  			//sinais dos registradores
  			MDRS = 0;
  			IRWrite = 0;
  			RegWriteSignal = 0;
  			RegAW = 0;
  			RegBW = 0;
  			RegAluWrite = 0;
  			EPCWrite = 0;
  			RegHighW = 0;
  			RegLowW = 0;
  			//sinais dos MUX
			PCCondMux = 2'b00;
			IorDMux = 3'b100;
  			ReadSMux = 0;
			ReadDstMux = 2'b00;
			MemToRegMux = 3'b000;
  			AluSrcAMux = 0;
			AluSrcBMux = 2'b00;
  			PCSourceMux = 3'b000;
  			RegInMux = 0;
  			ShiftSMux = 0;
  			DivMultMux = 0;
  			MultSMux = 0;
  			//sinais dos componentes
  			WMS = 2'b00;
  			MemRead = 1;
			MemWrite = 0;
			AluOP = 3'b000;
  			ShiftOp = 0;
  			StartDiv = 0;
  			DivStop = 0;
  			DivZero = 0;
  			StartMult = 0;
  			MultStop = 0;
  			MultO = 0;
          	
          	nextState = Stall;
      	end
      	Stall= begin
          PCWriteCond = 0;
  			PCWrite = 0;
  			//sinais dos registradores
  			MDRS = 1;
  			IRWrite = 0;
  			RegWriteSignal = 0;
  			RegAW = 0;
  			RegBW = 0;
  			RegAluWrite = 0;
  			EPCWrite = 0;
  			RegHighW = 0;
  			RegLowW = 0;
  			//sinais dos MUX
			PCCondMux = 2'b00;
			IorDMux = 3'b100;
  			ReadSMux = 0;
			ReadDstMux = 2'b00;
			MemToRegMux = 3'b000;
  			AluSrcAMux = 0;
			AluSrcBMux = 2'b00;
  			PCSourceMux = 3'b000;
  			RegInMux = 0;
  			ShiftSMux = 0;
  			DivMultMux = 0;
  			MultSMux = 0;
  			//sinais dos componentes
  			WMS = 2'b00;
  			MemRead = 1;
			MemWrite = 0;
			AluOP = 3'b000;
  			ShiftOp = 0;
  			StartDiv = 0;
  			DivStop = 0;
  			DivZero = 0;
  			StartMult = 0;
  			MultStop = 0;
  			MultO = 0;
          	
          	nextState = Save_reg;
      	end
      	Save_Reg=  begin
          PCWriteCond = 0;
  			PCWrite = 0;
  			//sinais dos registradores
  			MDRS = 0;
  			IRWrite = 0;
  			RegWriteSignal = 1;
  			RegAW = 0;
  			RegBW = 0;
  			RegAluWrite = 0;
  			EPCWrite = 0;
  			RegHighW = 0;
  			RegLowW = 0;
  			//sinais dos MUX
			PCCondMux = 2'b00;
			IorDMux = 3'b000;
  			ReadSMux = 0;
			ReadDstMux = 2'b00;
			MemToRegMux = 3'b010;
  			AluSrcAMux = 0;
			AluSrcBMux = 2'b00;
  			PCSourceMux = 3'b000;
  			RegInMux = 0;
  			ShiftSMux = 0;
  			DivMultMux = 0;
  			MultSMux = 0;
  			//sinais dos componentes
  			WMS = 2'b00;
  			MemRead = 0;
			MemWrite = 0;
			AluOP = 3'b000;
  			ShiftOp = 0;
  			StartDiv = 0;
  			DivStop = 0;
  			DivZero = 0;
  			StartMult = 0;
  			MultStop = 0;
  			MultO = 0;
          	
          	nextState = New_pointer;
      	end
      	New_pointer=  begin
          PCWriteCond = 0;
  			PCWrite = 0;
  			//sinais dos registradores
  			MDRS = 0;
  			IRWrite = 0;
  			RegWriteSignal = 0;
  			RegAW = 0;
  			RegBW = 0;
  			RegAluWrite = 1;
  			EPCWrite = 0;
  			RegHighW = 0;
  			RegLowW = 0;
  			//sinais dos MUX
			PCCondMux = 2'b00;
			IorDMux = 3'b000;
  			ReadSMux = 0;
			ReadDstMux = 2'b00;
			MemToRegMux = 3'b000;
  			AluSrcAMux = 1;
			AluSrcBMux = 2'b01;
  			PCSourceMux = 3'b000;
  			RegInMux = 0;
  			ShiftSMux = 0;
  			DivMultMux = 0;
  			MultSMux = 0;
  			//sinais dos componentes
  			WMS = 2'b00;
  			MemRead = 0;
			MemWrite = 0;
			AluOP = 3'b001;
  			ShiftOp = 0;
  			StartDiv = 0;
  			DivStop = 0;
  			DivZero = 0;
  			StartMult = 0;
  			MultStop = 0;
  			MultO = 0;
          	
          	nextState = UpdateRA;
      	end
      	UpdateRA= begin
          PCWriteCond = 0;
  			PCWrite = 0;
  			//sinais dos registradores
  			MDRS = 0;
  			IRWrite = 0;
  			RegWriteSignal = 1;
  			RegAW = 0;
  			RegBW = 0;
  			RegAluWrite = 0;
  			EPCWrite = 0;
  			RegHighW = 0;
  			RegLowW = 0;
  			//sinais dos MUX
			PCCondMux = 2'b00;
			IorDMux = 3'b000;
  			ReadSMux = 0;
			ReadDstMux = 2'b10;
			MemToRegMux = 3'b000;
  			AluSrcAMux = 0;
			AluSrcBMux = 2'b00;
  			PCSourceMux = 3'b000;
  			RegInMux = 0;
  			ShiftSMux = 0;
  			DivMultMux = 0;
  			MultSMux = 0;
  			//sinais dos componentes
  			WMS = 2'b00;
  			MemRead = 0;
			MemWrite = 0;
			AluOP = 3'b000;
  			ShiftOp = 0;
  			StartDiv = 0;
  			DivStop = 0;
  			DivZero = 0;
  			StartMult = 0;
  			MultStop = 0;
  			MultO = 0;
          	
          	nextState = Fetch;
      	end

      	Rte= begin
          PCWriteCond = 0;
  			PCWrite = 1;
  			//sinais dos registradores
  			MDRS = 0;
  			IRWrite = 0;
  			RegWriteSignal = 0;
  			RegAW = 0;
  			RegBW = 0;
  			RegAluWrite = 0;
  			EPCWrite = 0;
  			RegHighW = 0;
  			RegLowW = 0;
  			//sinais dos MUX
			PCCondMux = 2'b00;
			IorDMux = 3'b000;
  			ReadSMux = 0;
			ReadDstMux = 2'b00;
			MemToRegMux = 3'b000;
  			AluSrcAMux = 0;
			AluSrcBMux = 2'b00;
  			PCSourceMux = 3'b011;
  			RegInMux = 0;
  			ShiftSMux = 0;
  			DivMultMux = 0;
  			MultSMux = 0;
  			//sinais dos componentes
  			WMS = 2'b00;
  			MemRead = 0;
			MemWrite = 0;
			AluOP = 3'b000;
  			ShiftOp = 0;
  			StartDiv = 0;
  			DivStop = 0;
  			DivZero = 0;
  			StartMult = 0;
  			MultStop = 0;
  			MultO = 0;
          	
          	nextState = Fetch;
      	end

      	Mflo= begin
          PCWriteCond = 0;
  			PCWrite = 0;
  			//sinais dos registradores
  			MDRS = 0;
  			IRWrite = 0;
  			RegWriteSignal = 1;
  			RegAW = 0;
  			RegBW = 0;
  			RegAluWrite = 0;
  			EPCWrite = 0;
  			RegHighW = 0;
  			RegLowW = 0;
  			//sinais dos MUX
			PCCondMux = 2'b00;
			IorDMux = 3'b000;
  			ReadSMux = 0;
			ReadDstMux = 2'b11;
			MemToRegMux = 3'b011;
  			AluSrcAMux = 0;
			AluSrcBMux = 2'b00;
  			PCSourceMux = 3'b000;
  			RegInMux = 0;
  			ShiftSMux = 0;
  			DivMultMux = 0;
  			MultSMux = 1;
  			//sinais dos componentes
  			WMS = 2'b00;
  			MemRead = 0;
			MemWrite = 0;
			AluOP = 3'b000;
  			ShiftOp = 0;
  			StartDiv = 0;
  			DivStop = 0;
  			DivZero = 0;
  			StartMult = 0;
  			MultStop = 0;
  			MultO = 0;
          	
          	nextState = Fetch;
      	end
      	Mfhi= begin
          PCWriteCond = 0;
  			PCWrite = 0;
  			//sinais dos registradores
  			MDRS = 0;
  			IRWrite = 0;
  			RegWriteSignal = 1;
  			RegAW = 0;
  			RegBW = 0;
  			RegAluWrite = 0;
  			EPCWrite = 0;
  			RegHighW = 0;
  			RegLowW = 0;
  			//sinais dos MUX
			PCCondMux = 2'b00;
			IorDMux = 3'b000;
  			ReadSMux = 0;
			ReadDstMux = 2'b11;
			MemToRegMux = 3'b011;
  			AluSrcAMux = 0;
			AluSrcBMux = 2'b00;
  			PCSourceMux = 3'b000;
  			RegInMux = 0;
  			ShiftSMux = 0;
  			DivMultMux = 0;
  			MultSMux = 0;
  			//sinais dos componentes
  			WMS = 2'b00;
  			MemRead = 0;
			MemWrite = 0;
			AluOP = 3'b000;
  			ShiftOp = 0;
  			StartDiv = 0;
  			DivStop = 0;
  			DivZero = 0;
  			StartMult = 0;
  			MultStop = 0;
  			MultO = 0;
          	
          	nextState = Fetch;
      	end
      	Jr= begin
          PCWriteCond = 0;
  			PCWrite = 1;
  			//sinais dos registradores
  			MDRS = 0;
  			IRWrite = 0;
  			RegWriteSignal = 0;
  			RegAW = 0;
  			RegBW = 0;
  			RegAluWrite = 0;
  			EPCWrite = 0;
  			RegHighW = 0;
  			RegLowW = 0;
  			//sinais dos MUX
			PCCondMux = 2'b00;
			IorDMux = 3'b000;
  			ReadSMux = 0;
			ReadDstMux = 2'b00;
			MemToRegMux = 3'b000;
  			AluSrcAMux = 0;
			AluSrcBMux = 2'b00;
  			PCSourceMux = 3'b101;
  			RegInMux = 0;
  			ShiftSMux = 0;
  			DivMultMux = 0;
  			MultSMux = 0;
  			//sinais dos componentes
  			WMS = 2'b00;
  			MemRead = 0;
			MemWrite = 0;
			AluOP = 3'b000;
  			ShiftOp = 0;
  			StartDiv = 0;
  			DivStop = 0;
  			DivZero = 0;
  			StartMult = 0;
  			MultStop = 0;
  			MultO = 0;
          	
          	nextState = Fetch;
      	end
      	Break= begin
          PCWriteCond = 0;
  			PCWrite = 1;
  			//sinais dos registradores
  			MDRS = 0;
  			IRWrite = 0;
  			RegWriteSignal = 0;
  			RegAW = 0;
  			RegBW = 0;
  			RegAluWrite = 0;
  			EPCWrite = 0;
  			RegHighW = 0;
  			RegLowW = 0;
  			//sinais dos MUX
			PCCondMux = 2'b00;
			IorDMux = 3'b000;
  			ReadSMux = 0;
			ReadDstMux = 2'b00;
			MemToRegMux = 3'b000;
  			AluSrcAMux = 0;
			AluSrcBMux = 2'b01;
  			PCSourceMux = 3'b000;
  			RegInMux = 0;
  			ShiftSMux = 0;
  			DivMultMux = 0;
  			MultSMux = 0;
  			//sinais dos componentes
  			WMS = 2'b00;
  			MemRead = 0;
			MemWrite = 0;
			AluOP = 3'b010;
  			ShiftOp = 0;
  			StartDiv = 0;
  			DivStop = 0;
  			DivZero = 0;
  			StartMult = 0;
  			MultStop = 0;
  			MultO = 0;
          	
          	nextState = Fetch;
      	end
      	Slt= begin
          PCWriteCond = 0;
  			PCWrite = 0;
  			//sinais dos registradores
  			MDRS = 0;
  			IRWrite = 0;
  			RegWriteSignal = 0;
  			RegAW = 0;
  			RegBW = 0;
  			RegAluWrite = 0;
  			EPCWrite = 0;
  			RegHighW = 0;
  			RegLowW = 0;
  			//sinais dos MUX
			PCCondMux = 2'b00;
			IorDMux = 3'b000;
  			ReadSMux = 0;
			ReadDstMux = 2'b00;
			MemToRegMux = 3'b000;
  			AluSrcAMux = 1;
			AluSrcBMux = 2'b00;
  			PCSourceMux = 3'b000;
  			RegInMux = 0;
  			ShiftSMux = 0;
  			DivMultMux = 0;
  			MultSMux = 0;
  			//sinais dos componentes
  			WMS = 2'b00;
  			MemRead = 0;
			MemWrite = 0;
			AluOP = 3'b111;
  			ShiftOp = 0;
  			StartDiv = 0;
  			DivStop = 0;
  			DivZero = 0;
  			StartMult = 0;
  			MultStop = 0;
  			MultO = 0;
          	
          	nextState = RegD_write_slt;
      	end
      	RegD_write_slt= begin
          PCWriteCond = 0;
  			PCWrite = 0;
  			//sinais dos registradores
  			MDRS = 0;
  			IRWrite = 0;
  			RegWriteSignal = 1;
  			RegAW = 0;
  			RegBW = 0;
  			RegAluWrite = 0;
  			EPCWrite = 0;
  			RegHighW = 0;
  			RegLowW = 0;
  			//sinais dos MUX
			PCCondMux = 2'b00;
			IorDMux = 3'b000;
  			ReadSMux = 0;
			ReadDstMux = 2'b11;
			MemToRegMux = 3'b101;
  			AluSrcAMux = 0;
			AluSrcBMux = 2'b00;
  			PCSourceMux = 3'b000;
  			RegInMux = 0;
  			ShiftSMux = 0;
  			DivMultMux = 0;
  			MultSMux = 0;
  			//sinais dos componentes
  			WMS = 2'b00;
  			MemRead = 0;
			MemWrite = 0;
			AluOP = 3'b000;
  			ShiftOp = 0;
  			StartDiv = 0;
  			DivStop = 0;
  			DivZero = 0;
  			StartMult = 0;
  			MultStop = 0;
  			MultO = 0;
          	
          	nextState = Fetch;
      	end
      	Sub= begin
          PCWriteCond = 0;
  			PCWrite = 0;
  			//sinais dos registradores
  			MDRS = 0;
  			IRWrite = 0;
  			RegWriteSignal = 0;
  			RegAW = 0;
  			RegBW = 0;
  			RegAluWrite = 1;
  			EPCWrite = 0;
  			RegHighW = 0;
  			RegLowW = 0;
  			//sinais dos MUX
			PCCondMux = 2'b00;
			IorDMux = 3'b000;
  			ReadSMux = 0;
			ReadDstMux = 2'b00;
			MemToRegMux = 3'b000;
  			AluSrcAMux = 1;
			AluSrcBMux = 2'b00;
  			PCSourceMux = 3'b000;
  			RegInMux = 0;
  			ShiftSMux = 0;
  			DivMultMux = 0;
  			MultSMux = 0;
  			//sinais dos componentes
  			WMS = 2'b00;
  			MemRead = 0;
			MemWrite = 0;
			AluOP = 3'b010;
  			ShiftOp = 0;
  			StartDiv = 0;
  			DivStop = 0;
  			DivZero = 0;
  			StartMult = 0;
  			MultStop = 0;
  			MultO = 0;
          	
          	nextState = Overflow ? ov_load : RegD_write;
      	end
      	And= begin
          PCWriteCond = 0;
  			PCWrite = 0;
  			//sinais dos registradores
  			MDRS = 0;
  			IRWrite = 0;
  			RegWriteSignal = 0;
  			RegAW = 0;
  			RegBW = 0;
  			RegAluWrite = 1;
  			EPCWrite = 0;
  			RegHighW = 0;
  			RegLowW = 0;
  			//sinais dos MUX
			PCCondMux = 2'b00;
			IorDMux = 3'b000;
  			ReadSMux = 0;
			ReadDstMux = 2'b00;
			MemToRegMux = 3'b000;
  			AluSrcAMux = 1;
			AluSrcBMux = 2'b00;
  			PCSourceMux = 3'b000;
  			RegInMux = 0;
  			ShiftSMux = 0;
  			DivMultMux = 0;
  			MultSMux = 0;
  			//sinais dos componentes
  			WMS = 2'b00;
  			MemRead = 0;
			MemWrite = 0;
			AluOP = 3'b011;
  			ShiftOp = 0;
  			StartDiv = 0;
  			DivStop = 0;
  			DivZero = 0;
  			StartMult = 0;
  			MultStop = 0;
  			MultO = 0;
          	
          	nextState = RegD_write;
      	end
      	Add= begin
          PCWriteCond = 0;
  			PCWrite = 0;
  			//sinais dos registradores
  			MDRS = 0;
  			IRWrite = 0;
  			RegWriteSignal = 0;
  			RegAW = 0;
  			RegBW = 0;
  			RegAluWrite = 1;
  			EPCWrite = 0;
  			RegHighW = 0;
  			RegLowW = 0;
  			//sinais dos MUX
			PCCondMux = 2'b00;
			IorDMux = 3'b000;
  			ReadSMux = 0;
			ReadDstMux = 2'b00;
			MemToRegMux = 3'b000;
  			AluSrcAMux = 1;
			AluSrcBMux = 2'b00;
  			PCSourceMux = 3'b000;
  			RegInMux = 0;
  			ShiftSMux = 0;
  			DivMultMux = 0;
  			MultSMux = 0;
  			//sinais dos componentes
  			WMS = 2'b00;
  			MemRead = 0;
			MemWrite = 0;
			AluOP = 3'b001;
  			ShiftOp = 0;
  			StartDiv = 0;
  			DivStop = 0;
  			DivZero = 0;
  			StartMult = 0;
  			MultStop = 0;
  			MultO = 0;
          	
          	nextState = Overflow ? ov_load : RegD_write;
      	end
      	RegD_write= begin
          PCWriteCond = 0;
  			PCWrite = 0;
  			//sinais dos registradores
  			MDRS = 0;
  			IRWrite = 0;
  			RegWriteSignal = 1;
  			RegAW = 0;
  			RegBW = 0;
  			RegAluWrite = 0;
  			EPCWrite = 0;
  			RegHighW = 0;
  			RegLowW = 0;
  			//sinais dos MUX
			PCCondMux = 2'b00;
			IorDMux = 3'b000;
  			ReadSMux = 0;
			ReadDstMux = 2'b11;
			MemToRegMux = 3'b000;
  			AluSrcAMux = 0;
			AluSrcBMux = 2'b00;
  			PCSourceMux = 3'b000;
  			RegInMux = 0;
  			ShiftSMux = 0;
  			DivMultMux = 0;
  			MultSMux = 0;
  			//sinais dos componentes
  			WMS = 2'b00;
  			MemRead = 0;
			MemWrite = 0;
			AluOP = 3'b000;
  			ShiftOp = 0;
  			StartDiv = 0;
  			DivStop = 0;
  			DivZero = 0;
  			StartMult = 0;
  			MultStop = 0;
  			MultO = 0;
          	
          	nextState = Fetch;
      	end

      	ShiftShamt= begin
          PCWriteCond = 0;
  			PCWrite = 0;
  			//sinais dos registradores
  			MDRS = 0;
  			IRWrite = 0;
  			RegWriteSignal = 0;
  			RegAW = 0;
  			RegBW = 0;
  			RegAluWrite = 0;
  			EPCWrite = 0;
  			RegHighW = 0;
  			RegLowW = 0;
  			//sinais dos MUX
			PCCondMux = 2'b00;
			IorDMux = 3'b000;
  			ReadSMux = 0;
			ReadDstMux = 2'b00;
			MemToRegMux = 3'b000;
  			AluSrcAMux = 0;
			AluSrcBMux = 2'b00;
  			PCSourceMux = 3'b000;
  			RegInMux = 0;
  			ShiftSMux = 1;
  			DivMultMux = 0;
  			MultSMux = 0;
  			//sinais dos componentes
  			WMS = 2'b00;
  			MemRead = 0;
			MemWrite = 0;
			AluOP = 3'b000;
  			ShiftOp = 3'b001;
  			StartDiv = 0;
  			DivStop = 0;
  			DivZero = 0;
  			StartMult = 0;
  			MultStop = 0;
  			MultO = 0;
          	
          case(funct)
            6'h0 : nextstate = sll;
            6'h2 : nextstate = srl;
            6'h3 : nextstate = sra;
          endcase
      	end
      	sll= begin
          PCWriteCond = 0;
  			PCWrite = 0;
  			//sinais dos registradores
  			MDRS = 0;
  			IRWrite = 0;
  			RegWriteSignal = 0;
  			RegAW = 0;
  			RegBW = 0;
  			RegAluWrite = 0;
  			EPCWrite = 0;
  			RegHighW = 0;
  			RegLowW = 0;
  			//sinais dos MUX
			PCCondMux = 2'b00;
			IorDMux = 3'b000;
  			ReadSMux = 0;
			ReadDstMux = 2'b00;
			MemToRegMux = 3'b000;
  			AluSrcAMux = 0;
			AluSrcBMux = 2'b00;
  			PCSourceMux = 3'b000;
  			RegInMux = 0;
  			ShiftSMux = 0;
  			DivMultMux = 0;
  			MultSMux = 0;
  			//sinais dos componentes
  			WMS = 2'b00;
  			MemRead = 0;
			MemWrite = 0;
			AluOP = 3'b000;
  			ShiftOp = 3'b010;
  			StartDiv = 0;
  			DivStop = 0;
  			DivZero = 0;
  			StartMult = 0;
  			MultStop = 0;
  			MultO = 0;
          	
          	nextState = RegD_shift;
          
      	end
      	srl= begin
          PCWriteCond = 0;
  			PCWrite = 0;
  			//sinais dos registradores
  			MDRS = 0;
  			IRWrite = 0;
  			RegWriteSignal = 0;
  			RegAW = 0;
  			RegBW = 0;
  			RegAluWrite = 0;
  			EPCWrite = 0;
  			RegHighW = 0;
  			RegLowW = 0;
  			//sinais dos MUX
			PCCondMux = 2'b00;
			IorDMux = 3'b000;
  			ReadSMux = 0;
			ReadDstMux = 2'b00;
			MemToRegMux = 3'b000;
  			AluSrcAMux = 0;
			AluSrcBMux = 2'b00;
  			PCSourceMux = 3'b000;
  			RegInMux = 0;
  			ShiftSMux = 0;
  			DivMultMux = 0;
  			MultSMux = 0;
  			//sinais dos componentes
  			WMS = 2'b00;
  			MemRead = 0;
			MemWrite = 0;
			AluOP = 3'b000;
  			ShiftOp = 3'b011;
  			StartDiv = 0;
  			DivStop = 0;
  			DivZero = 0;
  			StartMult = 0;
  			MultStop = 0;
  			MultO = 0;
          	
          	nextState = RegD_shift;
      	end
      	sra= begin
          PCWriteCond = 0;
  			PCWrite = 0;
  			//sinais dos registradores
  			MDRS = 0;
  			IRWrite = 0;
  			RegWriteSignal = 0;
  			RegAW = 0;
  			RegBW = 0;
  			RegAluWrite = 0;
  			EPCWrite = 0;
  			RegHighW = 0;
  			RegLowW = 0;
  			//sinais dos MUX
			PCCondMux = 2'b00;
			IorDMux = 3'b000;
  			ReadSMux = 0;
			ReadDstMux = 2'b00;
			MemToRegMux = 3'b000;
  			AluSrcAMux = 0;
			AluSrcBMux = 2'b00;
  			PCSourceMux = 3'b000;
  			RegInMux = 0;
  			ShiftSMux = 0;
  			DivMultMux = 0;
  			MultSMux = 0;
  			//sinais dos componentes
  			WMS = 2'b00;
  			MemRead = 0;
			MemWrite = 0;
			AluOP = 3'b000;
  			ShiftOp = 3'b100;
  			StartDiv = 0;
  			DivStop = 0;
  			DivZero = 0;
  			StartMult = 0;
  			MultStop = 0;
  			MultO = 0;
          	
          	nextState = RegD_shift;
      	end

      	ShiftReg= begin
          PCWriteCond = 0;
  			PCWrite = 0;
  			//sinais dos registradores
  			MDRS = 0;
  			IRWrite = 0;
  			RegWriteSignal = 0;
  			RegAW = 0;
  			RegBW = 0;
  			RegAluWrite = 0;
  			EPCWrite = 0;
  			RegHighW = 0;
  			RegLowW = 0;
  			//sinais dos MUX
			PCCondMux = 2'b00;
			IorDMux = 3'b000;
  			ReadSMux = 0;
			ReadDstMux = 2'b00;
			MemToRegMux = 3'b000;
  			AluSrcAMux = 0;
			AluSrcBMux = 2'b00;
  			PCSourceMux = 3'b000;
  			RegInMux = 1;
  			ShiftSMux = 0;
  			DivMultMux = 0;
  			MultSMux = 0;
  			//sinais dos componentes
  			WMS = 2'b00;
  			MemRead = 0;
			MemWrite = 0;
			AluOP = 3'b000;
  			ShiftOp = 3'b001;
  			StartDiv = 0;
  			DivStop = 0;
  			DivZero = 0;
  			StartMult = 0;
  			MultStop = 0;
  			MultO = 0;
          	
          case(funct)
            6'h4 : nextstate = sllv;
            6'h7 : nextstate = srav;
          endcase
      	end
      	sllv= begin
          PCWriteCond = 0;
  			PCWrite = 0;
  			//sinais dos registradores
  			MDRS = 0;
  			IRWrite = 0;
  			RegWriteSignal = 0;
  			RegAW = 0;
  			RegBW = 0;
  			RegAluWrite = 0;
  			EPCWrite = 0;
  			RegHighW = 0;
  			RegLowW = 0;
  			//sinais dos MUX
			PCCondMux = 2'b00;
			IorDMux = 3'b000;
  			ReadSMux = 0;
			ReadDstMux = 2'b00;
			MemToRegMux = 3'b000;
  			AluSrcAMux = 0;
			AluSrcBMux = 2'b00;
  			PCSourceMux = 3'b000;
  			RegInMux = 0;
  			ShiftSMux = 0;
  			DivMultMux = 0;
  			MultSMux = 0;
  			//sinais dos componentes
  			WMS = 2'b00;
  			MemRead = 0;
			MemWrite = 0;
			AluOP = 3'b000;
  			ShiftOp = 3'b010;
  			StartDiv = 0;
  			DivStop = 0;
  			DivZero = 0;
  			StartMult = 0;
  			MultStop = 0;
  			MultO = 0;
          	
          	nextState = RegD_Shift;
      	end
      	srav= begin
          PCWriteCond = 0;
  			PCWrite = 0;
  			//sinais dos registradores
  			MDRS = 0;
  			IRWrite = 0;
  			RegWriteSignal = 0;
  			RegAW = 0;
  			RegBW = 0;
  			RegAluWrite = 0;
  			EPCWrite = 0;
  			RegHighW = 0;
  			RegLowW = 0;
  			//sinais dos MUX
			PCCondMux = 2'b00;
			IorDMux = 3'b000;
  			ReadSMux = 0;
			ReadDstMux = 2'b00;
			MemToRegMux = 3'b000;
  			AluSrcAMux = 0;
			AluSrcBMux = 2'b00;
  			PCSourceMux = 3'b000;
  			RegInMux = 0;
  			ShiftSMux = 0;
  			DivMultMux = 0;
  			MultSMux = 0;
  			//sinais dos componentes
  			WMS = 2'b00;
  			MemRead = 0;
			MemWrite = 0;
			AluOP = 3'b000;
  			ShiftOp = 3'b100;
  			StartDiv = 0;
  			DivStop = 0;
  			DivZero = 0;
  			StartMult = 0;
  			MultStop = 0;
  			MultO = 0;
          	
          	nextState = RegD_Shift;
      	end

      	RegD_Shift= begin
          PCWriteCond = 0;
  			PCWrite = 0;
  			//sinais dos registradores
  			MDRS = 0;
  			IRWrite = 0;
  			RegWriteSignal = 1;
  			RegAW = 0;
  			RegBW = 0;
  			RegAluWrite = 0;
  			EPCWrite = 0;
  			RegHighW = 0;
  			RegLowW = 0;
  			//sinais dos MUX
			PCCondMux = 2'b00;
			IorDMux = 3'b000;
  			ReadSMux = 0;
			ReadDstMux = 2'b11;
			MemToRegMux = 3'b001;
  			AluSrcAMux = 0;
			AluSrcBMux = 2'b00;
  			PCSourceMux = 3'b000;
  			RegInMux = 0;
  			ShiftSMux = 0;
  			DivMultMux = 0;
  			MultSMux = 0;
  			//sinais dos componentes
  			WMS = 2'b00;
  			MemRead = 0;
			MemWrite = 0;
			AluOP = 3'b000;
  			ShiftOp = 3'b000;
  			StartDiv = 0;
  			DivStop = 0;
  			DivZero = 0;
  			StartMult = 0;
  			MultStop = 0;
  			MultO = 0;
          	
          	nextState = Fetch;
      	end

      	Div= begin
      	end
      	HliLoD= begin
      	end
      	Mult= begin
      	end
      	HliLoM= begin
      	end

      	Div_Zero= begin
      	end
      	Div_Stall=begin
      	end
      	noop_load= begin
          PCWriteCond = 0;
  			PCWrite = 0;
  			//sinais dos registradores
  			MDRS = 0;
  			IRWrite = 0;
  			RegWriteSignal = 0;
  			RegAW = 0;
  			RegBW = 0;
  			RegAluWrite = 0;
  			EPCWrite = 0;
  			RegHighW = 0;
  			RegLowW = 0;
  			//sinais dos MUX
			PCCondMux = 2'b00;
			IorDMux = 3'b001;
  			ReadSMux = 0;
			ReadDstMux = 2'b00;
			MemToRegMux = 3'b000;
  			AluSrcAMux = 0;
			AluSrcBMux = 2'b00;
  			PCSourceMux = 3'b000;
  			RegInMux = 0;
  			ShiftSMux = 0;
  			DivMultMux = 0;
  			MultSMux = 0;
  			//sinais dos componentes
  			WMS = 2'b00;
  			MemRead = 1;
			MemWrite = 0;
			AluOP = 3'b000;
  			ShiftOp = 3'b000;
  			StartDiv = 0;
  			DivStop = 0;
  			DivZero = 0;
  			StartMult = 0;
  			MultStop = 0;
  			MultO = 0;
          	
          	nextState = noop_wait;
      	end
      	noop_wait= begin
          PCWriteCond = 0;
  			PCWrite = 0;
  			//sinais dos registradores
  			MDRS = 1;
  			IRWrite = 0;
  			RegWriteSignal = 0;
  			RegAW = 0;
  			RegBW = 0;
  			RegAluWrite = 0;
  			EPCWrite = 0;
  			RegHighW = 0;
  			RegLowW = 0;
  			//sinais dos MUX
			PCCondMux = 2'b00;
			IorDMux = 3'b000;
  			ReadSMux = 0;
			ReadDstMux = 2'b00;
			MemToRegMux = 3'b000;
  			AluSrcAMux = 0;
			AluSrcBMux = 2'b00;
  			PCSourceMux = 3'b000;
  			RegInMux = 0;
  			ShiftSMux = 0;
  			DivMultMux = 0;
  			MultSMux = 0;
  			//sinais dos componentes
  			WMS = 2'b00;
  			MemRead = 1;
			MemWrite = 0;
			AluOP = 3'b000;
  			ShiftOp = 3'b000;
  			StartDiv = 0;
  			DivStop = 0;
  			DivZero = 0;
  			StartMult = 0;
  			MultStop = 0;
  			MultO = 0;
          	
          	nextState = noop_pc;
      	end
      	noop_pc= begin
          PCWriteCond = 0;
  			PCWrite = 1;
  			//sinais dos registradores
  			MDRS = 0;
  			IRWrite = 0;
  			RegWriteSignal = 0;
  			RegAW = 0;
  			RegBW = 0;
  			RegAluWrite = 0;
  			EPCWrite = 0;
  			RegHighW = 0;
  			RegLowW = 0;
  			//sinais dos MUX
			PCCondMux = 2'b00;
			IorDMux = 3'b000;
  			ReadSMux = 0;
			ReadDstMux = 2'b00;
			MemToRegMux = 3'b000;
  			AluSrcAMux = 0;
			AluSrcBMux = 2'b00;
  			PCSourceMux = 3'b100;
  			RegInMux = 0;
  			ShiftSMux = 0;
  			DivMultMux = 0;
  			MultSMux = 0;
  			//sinais dos componentes
  			WMS = 2'b10;
  			MemRead = 0;
			MemWrite = 0;
			AluOP = 3'b000;
  			ShiftOp = 3'b000;
  			StartDiv = 0;
  			DivStop = 0;
  			DivZero = 0;
  			StartMult = 0;
  			MultStop = 0;
  			MultO = 0;
          	
          	nextState = Fetch;
      	end

endmodule: Control
