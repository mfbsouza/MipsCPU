module Control (
  input logic clk,
  input logic resetwire,

  //fios da instrucao
  input logic [4:0] shamt,
  input logic [5:0] funct,
  input logic [5:0] op,
  input logic multstop,
  input logic divstop,
  input logic divzero,

  //sinais da alu
  input logic overflow,
  
  //sinais de saida da unidade de controle
  //sinais de pc
  output logic pcwritecond,
  output logic pcwrite,

  //sinais dos registradores
  output logic mdrs,
  output logic irwrite,
  output logic regwritesignal,
  output logic regaw,
  output logic regbw,
  output logic regaluwrite,
  output logic epcwrite,
  output logic reghighw,
  output logic regloww,

  //sinais dos mux
  output logic [1:0] pccondmux,
  output logic [2:0] iordmux,
  output logic readsmux,
  output logic [1:0] readdstmux,
  output logic [2:0] memtoregmux,
  output logic alusrcamux,
  output logic [1:0] alusrcbmux,
  output logic [2:0] pcsourcemux,
  output logic reginmux,
  output logic shiftsmux,
  output logic divmultmux,
  output logic multsmux,

  //sinais dos componentes
  output logic [1:0] wms,
  output logic memwrite,
  output logic [2:0] aluop,
  output logic [2:0] shiftop,
  output logic startdiv,
  output logic startmult,
  output logic multo,
  //estado
    output logic [6:0] stateout
);
  
enum logic [6:0] {
  //our control unit looks like an h
  //dentro do h - superior centro
  reset= 7'd1,
  fetch= 7'd2,
  wait_= 7'd3,
  decode= 7'd4,
  //lado esquerdo
  beq_compare= 7'd5,
  bne_compare= 7'd6,
  ble_compare= 7'd7,
  bgt_compare= 7'd8,
  lw_address= 7'd9,
  lw_memory= 7'd10,
  lw_wait_= 7'd11,
  lw_write= 7'd12,
  sw_address= 7'd13,
  sw_memory= 7'd14,
  sw_wait_= 7'd15,
  sw_write= 7'd16,
  lui_load= 7'd17,
  j_jump= 7'd18,
  jal= 7'd19,
  saveejump= 7'd20,
  lh_address= 7'd21,
  lh_memory= 7'd22,
  lh_wait_= 7'd23,
  lh_write= 7'd24,
  lb_address= 7'd25,
  lb_memory= 7'd26,
  lb_wait_= 7'd27,
  lb_write= 7'd28,
  sh_address= 7'd29,
  sh_memory= 7'd30,
  sh_wait_= 7'd31,
  sh_write= 7'd32,
  sb_address= 7'd33,
  sb_memory= 7'd34,
  sb_wait_=  7'd35,
  sb_write= 7'd36,
  slti= 7'd37,
  addiu= 7'd39,
  addi= 7'd40,
  regt_write= 7'd41,
  //dentro do h -  inferior - esquerdo
  ov_load= 7'd42,
  ov_wait_= 7'd43,
  ov_pc= 7'd44,
  //dentro do h  - inferior - direito
  push= 7'd45,
  newra=  7'd46,//new_$ra
  savera_write=  7'd47, //save_$ra & writemem
  pop=  7'd48,
  address=   7'd49,//endereã§o
  readaddress=  7'd50, //ler endereã§o
  stall= 7'd51,
  save_reg=  7'd52,//guarda no registrador
  new_pointer=  7'd53,//novo ponteiro
  updatera= 7'd54, //atualiza $ra
  rte= 7'd55,
  //lado direito
  mflo= 7'd56,
  mfhi= 7'd57,
  jr= 7'd58,
  break_= 7'd59,
  slt= 7'd60,
  sub= 7'd62,
  and_= 7'd63,
  add= 7'd64,
  regd_write= 7'd65,

  shiftshamt= 7'd66,
  sll= 7'd67,
  srl= 7'd68,
  sra= 7'd69,

  shiftreg= 7'd70,
  sllv= 7'd71,
  srav= 7'd72,

  regd_shift= 7'd73,

  div= 7'd74,
  hlilod= 7'd75,
  mult= 7'd76,
  hlilom= 7'd77,
  //dentro de h - superior - direito
  div_zero= 7'd78,
  div_stall= 7'd79,
  noop_load= 7'd80,
  noop_wait_= 7'd81,
  noop_pc= 7'd82,
  wait_1 = 7'd83,
  lw_wait2 = 7'd84,
  sw_wait2 = 7'd85,
  lh_wait2 = 7'd86,
  lb_wait2 = 7'd87,
  sh_wait2 = 7'd88,
  sb_wait2 = 7'd89,
  mult2 = 7'd90,
  mult3 = 7'd91,
  noop_wait2 = 7'd92,
  ov_wait2 = 7'd93,
  stall2 = 7'd94,
  div2 = 7'd95,
  div3 = 7'd96,
  div_stall2 = 7'd97
} state, nextstate;

always_ff@(posedge clk, posedge resetwire) begin
    if(resetwire) state <= reset;
    else state <= nextstate;
    stateout = state;
end

always_comb begin
  case(state)
      
      reset: begin
		pcwritecond = 0;
        pcwrite = 0;
        //sinais dos registradores
        mdrs = 0;
        irwrite = 0;
        regwritesignal = 1;
        regaw = 0;
        regbw = 0;
        regaluwrite = 0;
        epcwrite = 0;
        reghighw = 0;
        regloww = 0;
        //sinais dos mux
		pccondmux = 2'b00;
		iordmux = 3'b000;
        readsmux = 0;
		readdstmux = 2'b10;
		memtoregmux = 3'b110;
        alusrcamux = 0;
		alusrcbmux = 2'b00;
        pcsourcemux = 3'b000;
        reginmux = 0;
        shiftsmux = 0;
        divmultmux = 0;
        multsmux = 0;
        //sinais dos componentes
        wms = 2'b00;
        memwrite = 0;
        aluop = 3'b000;
        shiftop = 3'b000;
        startdiv = 0;
        startmult = 0;
        
        multo = 0;
            
        nextstate = fetch;
     end
     fetch: begin
        pcwritecond = 0;
        pcwrite = 1;
        //sinais dos registradores
        mdrs = 0;
        irwrite = 0;
        regwritesignal = 0;
        regaw = 0;
        regbw = 0;
        regaluwrite = 0;
        epcwrite = 1;
        reghighw = 0;
        regloww = 0;
        //sinais dos mux
		pccondmux = 2'b00;
		iordmux = 3'b000;
        readsmux = 0;
		readdstmux = 2'b00;
		memtoregmux = 3'b000;
        alusrcamux = 0;
		alusrcbmux = 2'b01;
        pcsourcemux = 3'b000;
        reginmux = 0;
        shiftsmux = 0;
        divmultmux = 0;
        multsmux = 0;
        //sinais dos componentes
        wms = 2'b00;   
		memwrite = 0;
		aluop = 3'b001;
        shiftop = 3'b000;
        startdiv = 0;
        
        
        startmult = 0;
        
        multo = 0;
            
        nextstate = wait_;
     end
     
     wait_: begin
        pcwritecond = 0;
        pcwrite = 0;
        //sinais dos registradores
        mdrs = 0;
        irwrite = 0;
        regwritesignal = 0;
        regaw = 0;
        regbw = 0;
        regaluwrite = 0;
        epcwrite = 0;
        reghighw = 0;
        regloww = 0;
        //sinais dos mux
		pccondmux = 2'b00;
		iordmux = 3'b000;
        readsmux = 0;
		readdstmux = 2'b00;
		memtoregmux = 3'b000;
        alusrcamux = 0;
		alusrcbmux = 2'b00;
        pcsourcemux = 3'b000;
        reginmux = 0;
        shiftsmux = 0;
        divmultmux = 0;
        multsmux = 0;
        //sinais dos componentes
        wms = 2'b00;
		memwrite = 0;
		aluop = 3'b000;
        shiftop = 3'b000;
        startdiv = 0;
        
        
        startmult = 0;
        
        multo = 0;
            
        nextstate = wait_1;
    end
    
    
    wait_1: begin
        pcwritecond = 0;
        pcwrite = 0;
        //sinais dos registradores
        mdrs = 0;
        irwrite = 1;
        regwritesignal = 0;
        regaw = 0;
        regbw = 0;
        regaluwrite = 0;
        epcwrite = 0;
        reghighw = 0;
        regloww = 0;
        //sinais dos mux
		pccondmux = 2'b00;
		iordmux = 3'b000;
        readsmux = 0;
		readdstmux = 2'b00;
		memtoregmux = 3'b000;
        alusrcamux = 0;
		alusrcbmux = 2'b00;
        pcsourcemux = 3'b000;
        reginmux = 0;
        shiftsmux = 0;
        divmultmux = 0;
        multsmux = 0;
        //sinais dos componentes
        wms = 2'b00;
		memwrite = 0;
		aluop = 3'b000;
        shiftop = 3'b000;
        startdiv = 0;
        
        
        startmult = 0;
        
        multo = 0;
    
		nextstate = decode;
	end
    
    decode: begin
        pcwritecond = 0;
        pcwrite = 0;
        //sinais dos registradores
        mdrs = 0;
        irwrite = 0;
        regwritesignal = 0;
        regaw = 1;
        regbw = 1;
        regaluwrite = 1;
        epcwrite = 0;
        reghighw = 0;
        regloww = 0;
        //sinais dos mux
		pccondmux = 2'b00;
		iordmux = 3'b000;
        readsmux = 1;
		readdstmux = 2'b00;
		memtoregmux = 3'b000;
        alusrcamux = 0;
		alusrcbmux = 2'b11;
        pcsourcemux = 3'b000;
        reginmux = 0;
        shiftsmux = 0;
        divmultmux = 0;
        multsmux = 0;
        //sinais dos componentes
        wms = 2'b00;   
		memwrite = 0;
		aluop = 3'b001;
        shiftop = 3'b000;
        startdiv = 0;
        
        
        startmult = 0;
        
        multo = 0; 
        case(op)
            6'h8 : nextstate = addi;
            6'h9 : nextstate = addiu;
            6'h4 : nextstate = beq_compare;
            6'h5 : nextstate = bne_compare;
            6'h6 : nextstate = ble_compare;
            6'h7 : nextstate = bgt_compare;
            6'h20 : nextstate = lb_address;
            6'h21: nextstate = lh_address;
            6'hf : nextstate = lui_load;
            6'h23 : nextstate = lw_address;
            6'h28: nextstate = sb_address;
            6'h29 : nextstate = sh_address;
            6'ha : nextstate = slti;
            6'h2b : nextstate = sw_address;
            6'h2 : nextstate = j_jump;
            6'h3 : nextstate = jal;
            6'h0: //caso o opcode for 0x0, olhar o funct
                case(funct)
                      6'h20 : nextstate = add;
                      6'h24 : nextstate = and_;
                      6'h1a : nextstate = div;
                      6'h18 : nextstate = mult;
                      6'h8 : nextstate = jr;
                      6'h10 : nextstate = mfhi;
                      6'h12 : nextstate = mflo;
                      6'h0 : nextstate = shiftshamt;
                      6'h4 : nextstate = shiftreg;
                      6'h2a : nextstate = slt;
                      6'h3 : nextstate = shiftshamt;
                      6'h7 : nextstate = shiftreg;
                      6'h2 : nextstate = shiftshamt;
                      6'h22 : nextstate = sub;
                      6'hd : nextstate = break_;
                      6'h13 : nextstate = rte;
                      6'h5 : nextstate = push;
                      6'h6 : nextstate = pop;
                      default: nextstate = reset; // n sei se serve de algo mas ta ai
              endcase
              default: nextstate = noop_load;
          endcase
    end
      
      beq_compare: begin
        pcwritecond = 1;
        pcwrite = 0;
        //sinais dos registradores
        mdrs = 0;
        irwrite = 0;
        regwritesignal = 0;
        regaw = 0;
        regbw = 0;
        regaluwrite = 0;
        epcwrite = 0;
        reghighw = 0;
        regloww = 0;
        //sinais dos mux
		pccondmux = 2'b11;
		iordmux = 3'b000;
        readsmux = 0;
		readdstmux = 2'b00;
		memtoregmux = 3'b000;
        alusrcamux = 1;
		alusrcbmux = 2'b00;
        pcsourcemux = 3'b001;
        reginmux = 0;
        shiftsmux = 0;
        divmultmux = 0;
        multsmux = 0;
        //sinais dos componentes
        wms = 2'b00;
        
		memwrite = 0;
		aluop = 3'b010;
        shiftop = 3'b000;
        startdiv = 0;
        
        
        startmult = 0;
        
        multo = 0;
            
        nextstate = fetch;
      end
      bne_compare: begin
        pcwritecond = 1;
        pcwrite = 0;
        //sinais dos registradores
        mdrs = 0;
        irwrite = 0;
        regwritesignal = 0;
        regaw = 0;
        regbw = 0;
        regaluwrite = 0;
        epcwrite = 0;
        reghighw = 0;
        regloww = 0;
        //sinais dos mux
		pccondmux = 2'b10;
		iordmux = 3'b000;
        readsmux = 0;
		readdstmux = 2'b00;
		memtoregmux = 3'b000;
        alusrcamux = 1;
		alusrcbmux = 2'b00;
        pcsourcemux = 3'b001;
        reginmux = 0;
        shiftsmux = 0;
        divmultmux = 0;
        multsmux = 0;
        //sinais dos componentes
        wms = 2'b00;
        
		memwrite = 0;
		aluop = 3'b111;
        shiftop = 3'b000;
        startdiv = 0;
        
        
        startmult = 0;
        
        multo = 0;
            
        nextstate = fetch;
      end
      ble_compare: begin
        pcwritecond = 1;
        pcwrite = 0;
        //sinais dos registradores
        mdrs = 0;
        irwrite = 0;
        regwritesignal = 0;
        regaw = 0;
        regbw = 0;
        regaluwrite = 0;
        epcwrite = 0;
        reghighw = 0;
        regloww = 0;
        //sinais dos mux
		pccondmux = 2'b01;
		iordmux = 3'b000;
        readsmux = 0;
		readdstmux = 2'b00;
		memtoregmux = 3'b000;
        alusrcamux = 1;
		alusrcbmux = 2'b00;
        pcsourcemux = 3'b001;
        reginmux = 0;
        shiftsmux = 0;
        divmultmux = 0;
        multsmux = 0;
        //sinais dos componentes
        wms = 2'b00;
        
		memwrite = 0;
		aluop = 3'b111;
        shiftop = 3'b000;
        startdiv = 0;
        
        
        startmult = 0;
        
        multo = 0;
            
            nextstate = fetch;
      end
      bgt_compare: begin
        pcwritecond = 1;
        pcwrite = 0;
        //sinais dos registradores
        mdrs = 0;
        irwrite = 0;
        regwritesignal = 0;
        regaw = 0;
        regbw = 0;
        regaluwrite = 0;
        epcwrite = 0;
        reghighw = 0;
        regloww = 0;
        //sinais dos mux
		pccondmux = 2'b00;
		iordmux = 3'b000;
        readsmux = 0;
		readdstmux = 2'b00;
		memtoregmux = 3'b000;
        alusrcamux = 1;
		alusrcbmux = 2'b00;
        pcsourcemux = 3'b001;
        reginmux = 0;
        shiftsmux = 0;
        divmultmux = 0;
        multsmux = 0;
        //sinais dos componentes
        wms = 2'b00;
        
		memwrite = 0;
		aluop = 3'b111;
        shiftop = 3'b000;
        startdiv = 0;
        
        
        startmult = 0;
        
        multo = 0;
            
            nextstate = fetch;
      end
      lw_address: begin
        pcwritecond = 0;
        pcwrite = 0;
        //sinais dos registradores
        mdrs = 0;
        irwrite = 0;
        regwritesignal = 0;
        regaw = 0;
        regbw = 0;
        regaluwrite = 1;
        epcwrite = 0;
        reghighw = 0;
        regloww = 0;
        //sinais dos mux
		pccondmux = 2'b00;
		iordmux = 3'b000;
        readsmux = 0;
		readdstmux = 2'b00;
		memtoregmux = 3'b000;
        alusrcamux = 1;
		alusrcbmux = 2'b10;
        pcsourcemux = 3'b000;
        reginmux = 0;
        shiftsmux = 0;
        divmultmux = 0;
        multsmux = 0;
        //sinais dos componentes
        wms = 2'b00;
		memwrite = 0;
		aluop = 3'b001;
        shiftop = 3'b000;
        startdiv = 0;
        
        
        startmult = 0;
        
        multo = 0;
            
            nextstate = lw_memory;
      end
      lw_memory: begin
        pcwritecond = 0;
        pcwrite = 0;
        //sinais dos registradores
        mdrs = 0;
        irwrite = 0;
        regwritesignal = 0;
        regaw = 0;
        regbw = 0;
        regaluwrite = 0;
        epcwrite = 0;
        reghighw = 0;
        regloww = 0;
        //sinais dos mux
		pccondmux = 2'b00;
		iordmux = 3'b100;
        readsmux = 0;
		readdstmux = 2'b00;
		memtoregmux = 3'b000;
        alusrcamux = 0;
		alusrcbmux = 2'b00;
        pcsourcemux = 3'b000;
        reginmux = 0;
        shiftsmux = 0;
        divmultmux = 0;
        multsmux = 0;
        //sinais dos componentes
        wms = 2'b00;
        
		memwrite = 0;
		aluop = 3'b000;
        shiftop = 3'b000;
        startdiv = 0;
        
        
        startmult = 0;
        
        multo = 0;
            
            nextstate = lw_wait_;
      end
      lw_wait_: begin
        pcwritecond = 0;
        pcwrite = 0;
        //sinais dos registradores
        mdrs = 0;
        irwrite = 0;
        regwritesignal = 0;
        regaw = 0;
        regbw = 0;
        regaluwrite = 0;
        epcwrite = 0;
        reghighw = 0;
        regloww = 0;
        //sinais dos mux
		pccondmux = 2'b00;
		iordmux = 3'b100;
        readsmux = 0;
		readdstmux = 2'b00;
		memtoregmux = 3'b000;
        alusrcamux = 0;
		alusrcbmux = 2'b00;
        pcsourcemux = 3'b000;
        reginmux = 0;
        shiftsmux = 0;
        divmultmux = 0;
        multsmux = 0;
        //sinais dos componentes
        wms = 2'b00;
        
		memwrite = 0;
		aluop = 3'b000;
        shiftop = 3'b000;
        startdiv = 0;
        
        
        startmult = 0;
        
        multo = 0;
            
            nextstate = lw_wait2;
      end
      
      lw_wait2: begin
        pcwritecond = 0;
        pcwrite = 0;
        //sinais dos registradores
        mdrs = 1;
        irwrite = 0;
        regwritesignal = 0;
        regaw = 0;
        regbw = 0;
        regaluwrite = 0;
        epcwrite = 0;
        reghighw = 0;
        regloww = 0;
        //sinais dos mux
		pccondmux = 2'b00;
		iordmux = 3'b100;
        readsmux = 0;
		readdstmux = 2'b00;
		memtoregmux = 3'b000;
        alusrcamux = 0;
		alusrcbmux = 2'b00;
        pcsourcemux = 3'b000;
        reginmux = 0;
        shiftsmux = 0;
        divmultmux = 0;
        multsmux = 0;
        //sinais dos componentes
        wms = 2'b00;
        
		memwrite = 0;
		aluop = 3'b000;
        shiftop = 3'b000;
        startdiv = 0;
        
        
        startmult = 0;
        
        multo = 0;
            
            nextstate = lw_write;
      end
      
      lw_write: begin
        pcwritecond = 0;
        pcwrite = 0;
        //sinais dos registradores
        mdrs = 0;
        irwrite = 0;
        regwritesignal = 1;
        regaw = 0;
        regbw = 0;
        regaluwrite = 0;
        epcwrite = 0;
        reghighw = 0;
        regloww = 0;
        //sinais dos mux
		pccondmux = 2'b00;
		iordmux = 3'b100;
        readsmux = 0;
		readdstmux = 2'b00;
		memtoregmux = 3'b010;
        alusrcamux = 0;
		alusrcbmux = 2'b00;
        pcsourcemux = 3'b000;
        reginmux = 0;
        shiftsmux = 0;
        divmultmux = 0;
        multsmux = 0;
        //sinais dos componentes
        wms = 2'b00;
        
		memwrite = 0;
		aluop = 3'b000;
        shiftop = 3'b000;
        startdiv = 0;
        
        
        startmult = 0;
        
        multo = 0;
            
       nextstate = fetch;
      end
      sw_address: begin
        pcwritecond = 0;
        pcwrite = 0;
        //sinais dos registradores
        mdrs = 0;
        irwrite = 0;
        regwritesignal = 0;
        regaw = 0;
        regbw = 0;
        regaluwrite = 1;
        epcwrite = 0;
        reghighw = 0;
        regloww = 0;
        //sinais dos mux
		pccondmux = 2'b00;
		iordmux = 3'b000;
        readsmux = 0;
		readdstmux = 2'b00;
		memtoregmux = 3'b000;
        alusrcamux = 1;
		alusrcbmux = 2'b10;
		pcsourcemux = 3'b000;
        reginmux = 0;
        shiftsmux = 0;
        divmultmux = 0;
        multsmux = 0;
        //sinais dos componentes
        wms = 2'b00;
        
		memwrite = 0;
		aluop = 3'b001;
        shiftop = 3'b000;
        startdiv = 0;
        
        
        startmult = 0;
        
        multo = 0;
            
        nextstate = sw_memory;
      end
      sw_memory: begin
        pcwritecond = 0;
        pcwrite = 0;
        //sinais dos registradores
        mdrs = 0;
        irwrite = 0;
        regwritesignal = 0;
        regaw = 0;
        regbw = 0;
        regaluwrite = 0;
        epcwrite = 0;
        reghighw = 0;
        regloww = 0;
        //sinais dos mux
		pccondmux = 2'b00;
		iordmux = 3'b100;
        readsmux = 0;
		readdstmux = 2'b00;
		memtoregmux = 3'b000;
        alusrcamux = 0;
		alusrcbmux = 2'b00;
        pcsourcemux = 3'b000;
        reginmux = 0;
        shiftsmux = 0;
        divmultmux = 0;
        multsmux = 0;
        //sinais dos componentes
        wms = 2'b00;
        
		memwrite = 0;
		aluop = 3'b000;
        shiftop = 3'b000;
        startdiv = 0;
        
        
        startmult = 0;
        
        multo = 0;
            
            nextstate = sw_wait_;
      end
      sw_wait_: begin
        pcwritecond = 0;
        pcwrite = 0;
        //sinais dos registradores
        mdrs = 0;
        irwrite = 0;
        regwritesignal = 0;
        regaw = 0;
        regbw = 0;
        regaluwrite = 0;
        epcwrite = 0;
        reghighw = 0;
        regloww = 0;
        //sinais dos mux
		pccondmux = 2'b00;
		iordmux = 3'b100;
        readsmux = 0;
		readdstmux = 2'b00;
		memtoregmux = 3'b000;
        alusrcamux = 0;
		alusrcbmux = 2'b00;
        pcsourcemux = 3'b000;
        reginmux = 0;
        shiftsmux = 0;
        divmultmux = 0;
        multsmux = 0;
        //sinais dos componentes
        wms = 2'b00;
        
		memwrite = 0;
		aluop = 3'b000;
        shiftop = 3'b000;
        startdiv = 0;
        
        
        startmult = 0;
        
        multo = 0;
            
            nextstate = sw_wait2;
      end
      
      sw_wait2: begin
        pcwritecond = 0;
        pcwrite = 0;
        //sinais dos registradores
        mdrs = 1;
        irwrite = 0;
        regwritesignal = 0;
        regaw = 0;
        regbw = 0;
        regaluwrite = 0;
        epcwrite = 0;
        reghighw = 0;
        regloww = 0;
        //sinais dos mux
		pccondmux = 2'b00;
		iordmux = 3'b100;
        readsmux = 0;
		readdstmux = 2'b00;
		memtoregmux = 3'b000;
        alusrcamux = 0;
		alusrcbmux = 2'b00;
        pcsourcemux = 3'b000;
        reginmux = 0;
        shiftsmux = 0;
        divmultmux = 0;
        multsmux = 0;
        //sinais dos componentes
        wms = 2'b00;
        
		memwrite = 0;
		aluop = 3'b000;
        shiftop = 3'b000;
        startdiv = 0;
        
        
        startmult = 0;
        
        multo = 0;
            
            nextstate = sw_write;
      end
      
      sw_write: begin
        pcwritecond = 0;
        pcwrite = 0;
        //sinais dos registradores
        mdrs = 0;
        irwrite = 0;
        regwritesignal = 0;
        regaw = 0;
        regbw = 0;
        regaluwrite = 0;
        epcwrite = 0;
        reghighw = 0;
        regloww = 0;
        //sinais dos mux
		pccondmux = 2'b00;
		iordmux = 3'b100;
        readsmux = 0;
		readdstmux = 2'b00;
		memtoregmux = 3'b000;
        alusrcamux = 0;
		alusrcbmux = 2'b00;
        pcsourcemux = 3'b000;
        reginmux = 0;
        shiftsmux = 0;
        divmultmux = 0;
        multsmux = 0;
        //sinais dos componentes
        wms = 2'b00;
        
		memwrite = 1;
		aluop = 3'b000;
        shiftop = 3'b000;
        startdiv = 0;
        
        
        startmult = 0;
        
        multo = 0;
            
        nextstate = fetch;
      end
      lui_load: begin
        pcwritecond = 0;
        pcwrite = 0;
        //sinais dos registradores
        mdrs = 0;
        irwrite = 0;
        regwritesignal = 1;
        regaw = 0;
        regbw = 0;
        regaluwrite = 0;
        epcwrite = 0;
        reghighw = 0;
        regloww = 0;
        //sinais dos mux
		pccondmux = 2'b00;
		iordmux = 3'b000;
        readsmux = 0;
		readdstmux = 2'b00;
		memtoregmux = 3'b100;
        alusrcamux = 0;
		alusrcbmux = 2'b00;
        pcsourcemux = 3'b000;
        reginmux = 0;
        shiftsmux = 0;
        divmultmux = 0;
        multsmux = 0;
        //sinais dos componentes
        wms = 2'b00;
        
		memwrite = 0;
		aluop = 3'b000;
        shiftop = 3'b000;
        startdiv = 0;
        
        
        startmult = 0;
        
        multo = 0;
            
        nextstate = fetch;
      end
      j_jump: begin
        pcwritecond = 0;
        pcwrite = 1;
        //sinais dos registradores
        mdrs = 0;
        irwrite = 0;
        regwritesignal = 0;
        regaw = 0;
        regbw = 0;
        regaluwrite = 0;
        epcwrite = 0;
        reghighw = 0;
        regloww = 0;
        //sinais dos mux
		pccondmux = 2'b00;
		iordmux = 3'b000;
        readsmux = 0;
		readdstmux = 2'b00;
		memtoregmux = 3'b000;
        alusrcamux = 0;
		alusrcbmux = 2'b00;
        pcsourcemux = 3'b010;
        reginmux = 0;
        shiftsmux = 0;
        divmultmux = 0;
        multsmux = 0;
        //sinais dos componentes
        wms = 2'b00;
        
		memwrite = 0;
		aluop = 3'b000;
        shiftop = 3'b000;
        startdiv = 0;
        
        
        startmult = 0;
        
        multo = 0;
            
            nextstate = fetch;
      end
      jal: begin
        pcwritecond = 0;
        pcwrite = 0;
        //sinais dos registradores
        mdrs = 0;
        irwrite = 0;
        regwritesignal = 0;
        regaw = 0;
        regbw = 0;
        regaluwrite = 1;
        epcwrite = 0;
        reghighw = 0;
        regloww = 0;
        //sinais dos mux
		pccondmux = 2'b00;
		iordmux = 3'b000;
        readsmux = 0;
		readdstmux = 2'b00;
		memtoregmux = 3'b000;
        alusrcamux = 0;
		alusrcbmux = 2'b00;
        pcsourcemux = 3'b000;
        reginmux = 0;
        shiftsmux = 0;
        divmultmux = 0;
        multsmux = 0;
        //sinais dos componentes
        wms = 2'b00;
        
		memwrite = 0;
		aluop = 3'b000;
        shiftop = 3'b000;
        startdiv = 0;
        
        
        startmult = 0;
        
        multo = 0;
            
            nextstate = saveejump;
      end
      saveejump: begin
        pcwritecond = 0;
        pcwrite = 1;
        //sinais dos registradores
        mdrs = 0;
        irwrite = 0;
        regwritesignal = 1;
        regaw = 0;
        regbw = 0;
        regaluwrite = 0;
        epcwrite = 0;
        reghighw = 0;
        regloww = 0;
        //sinais dos mux
		pccondmux = 2'b00;
		iordmux = 3'b000;
        readsmux = 0;
		readdstmux = 2'b01;
		memtoregmux = 3'b000;
        alusrcamux = 0;
		alusrcbmux = 2'b00;
        pcsourcemux = 3'b010;
        reginmux = 0;
        shiftsmux = 0;
        divmultmux = 0;
        multsmux = 0;
        //sinais dos componentes
        wms = 2'b00;
        
		memwrite = 0;
		aluop = 3'b000;
        shiftop = 3'b000;
        startdiv = 0;
        
        
        startmult = 0;
        
        multo = 0;
            
            nextstate = fetch;
      end
      lh_address: begin
        pcwritecond = 0;
        pcwrite = 0;
        //sinais dos registradores
        mdrs = 0;
        irwrite = 0;
        regwritesignal = 0;
        regaw = 0;
        regbw = 0;
        regaluwrite = 1;
        epcwrite = 0;
        reghighw = 0;
        regloww = 0;
        //sinais dos mux
		pccondmux = 2'b00;
		iordmux = 3'b000;
        readsmux = 0;
		readdstmux = 2'b00;
		memtoregmux = 3'b000;
        alusrcamux = 1;
		alusrcbmux = 2'b10;
        pcsourcemux = 3'b000;
        reginmux = 0;
        shiftsmux = 0;
        divmultmux = 0;
        multsmux = 0;
        //sinais dos componentes
        wms = 2'b00;
        
		memwrite = 0;
		aluop = 3'b001;
        shiftop = 3'b000;
        startdiv = 0;
        
        
        startmult = 0;
        
        multo = 0;
            
        nextstate = lh_memory;
        end
      lh_memory: begin
        pcwritecond = 0;
        pcwrite = 0;
        //sinais dos registradores
        mdrs = 0;
        irwrite = 0;
        regwritesignal = 0;
        regaw = 0;
        regbw = 0;
        regaluwrite = 0;
        epcwrite = 0;
        reghighw = 0;
        regloww = 0;
        //sinais dos mux
		pccondmux = 2'b00;
		iordmux = 3'b100;
        readsmux = 0;
		readdstmux = 2'b00;
		memtoregmux = 3'b000;
        alusrcamux = 0;
		alusrcbmux = 2'b00;
        pcsourcemux = 3'b000;
        reginmux = 0;
        shiftsmux = 0;
        divmultmux = 0;
        multsmux = 0;
        //sinais dos componentes
        wms = 2'b00;
        
		memwrite = 0;
		aluop = 3'b000;
        shiftop = 3'b000;
        startdiv = 0;
        
        
        startmult = 0;
        
        multo = 0;
            
        nextstate = lh_wait_;
      end
      lh_wait_: begin
        pcwritecond = 0;
        pcwrite = 0;
        //sinais dos registradores
        mdrs = 0;
        irwrite = 0;
        regwritesignal = 0;
        regaw = 0;
        regbw = 0;
        regaluwrite = 0;
        epcwrite = 0;
        reghighw = 0;
        regloww = 0;
        //sinais dos mux
		pccondmux = 2'b00;
		iordmux = 3'b100;
        readsmux = 0;
		readdstmux = 2'b00;
		memtoregmux = 3'b000;
        alusrcamux = 0;
		alusrcbmux = 2'b00;
        pcsourcemux = 3'b000;
        reginmux = 0;
        shiftsmux = 0;
        divmultmux = 0;
        multsmux = 0;
        //sinais dos componentes
        wms = 2'b00;
        
		memwrite = 0;
		aluop = 3'b000;
        shiftop = 3'b000;
        startdiv = 0;
        
        
        startmult = 0;
        
        multo = 0;
            
       nextstate = lh_wait2;
      end
      
      lh_wait2: begin
        pcwritecond = 0;
        pcwrite = 0;
        //sinais dos registradores
        mdrs = 1;
        irwrite = 0;
        regwritesignal = 0;
        regaw = 0;
        regbw = 0;
        regaluwrite = 0;
        epcwrite = 0;
        reghighw = 0;
        regloww = 0;
        //sinais dos mux
		pccondmux = 2'b00;
		iordmux = 3'b100;
        readsmux = 0;
		readdstmux = 2'b00;
		memtoregmux = 3'b000;
        alusrcamux = 0;
		alusrcbmux = 2'b00;
        pcsourcemux = 3'b000;
        reginmux = 0;
        shiftsmux = 0;
        divmultmux = 0;
        multsmux = 0;
        //sinais dos componentes
        wms = 2'b00;
        
		memwrite = 0;
		aluop = 3'b000;
        shiftop = 3'b000;
        startdiv = 0;
        
        
        startmult = 0;
        
        multo = 0;
            
       nextstate = lh_write;
      end
          
      lh_write: begin
        pcwritecond = 0;
        pcwrite = 0;
        //sinais dos registradores
        mdrs = 0;
        irwrite = 0;
        regwritesignal = 1;
        regaw = 0;
        regbw = 0;
        regaluwrite = 0;
        epcwrite = 0;
        reghighw = 0;
        regloww = 0;
        //sinais dos mux
		pccondmux = 2'b00;
		iordmux = 3'b100;
        readsmux = 0;
		readdstmux = 2'b00;
		memtoregmux = 3'b010;
        alusrcamux = 0;
		alusrcbmux = 2'b00;
        pcsourcemux = 3'b000;
        reginmux = 0;
        shiftsmux = 0;
        divmultmux = 0;
        multsmux = 0;
        //sinais dos componentes
        wms = 2'b01;
        
		memwrite = 0;
		aluop = 3'b000;
        shiftop = 3'b000;
        startdiv = 0;
        
        
        startmult = 0;
        
        multo = 0;
            
       nextstate = fetch;
      end
      lb_address: begin
        pcwritecond = 0;
        pcwrite = 0;
        //sinais dos registradores
        mdrs = 0;
        irwrite = 0;
        regwritesignal = 0;
        regaw = 0;
        regbw = 0;
        regaluwrite = 1;
        epcwrite = 0;
        reghighw = 0;
        regloww = 0;
        //sinais dos mux
		pccondmux = 2'b00;
		iordmux = 3'b000;
        readsmux = 0;
		readdstmux = 2'b00;
		memtoregmux = 3'b000;
        alusrcamux = 1;
		alusrcbmux = 2'b10;
        pcsourcemux = 3'b000;
        reginmux = 0;
        shiftsmux = 0;
        divmultmux = 0;
        multsmux = 0;
        //sinais dos componentes
        wms = 2'b00;
        
		memwrite = 0;
		aluop = 3'b001;
        shiftop = 3'b000;
        startdiv = 0;
        
        
        startmult = 0;
        
        multo = 0;
            
        nextstate = lb_memory;
      end
      lb_memory: begin
        pcwritecond = 0;
        pcwrite = 0;
        //sinais dos registradores
        mdrs = 0;
        irwrite = 0;
        regwritesignal = 0;
        regaw = 0;
        regbw = 0;
        regaluwrite = 0;
        epcwrite = 0;
        reghighw = 0;
        regloww = 0;
        //sinais dos mux
		pccondmux = 2'b00;
		iordmux = 3'b100;
        readsmux = 0;
		readdstmux = 2'b00;
		memtoregmux = 3'b000;
        alusrcamux = 0;
		alusrcbmux = 2'b00;
        pcsourcemux = 3'b000;
        reginmux = 0;
        shiftsmux = 0;
        divmultmux = 0;
        multsmux = 0;
        //sinais dos componentes
        wms = 2'b00;
        
		memwrite = 0;
		aluop = 3'b000;
        shiftop = 3'b000;
        startdiv = 0;
        
        
        startmult = 0;
        
        multo = 0;
            
       nextstate = lb_wait_;
      end
      lb_wait_: begin
        pcwritecond = 0;
        pcwrite = 0;
        //sinais dos registradores
        mdrs = 0;
        irwrite = 0;
        regwritesignal = 0;
        regaw = 0;
        regbw = 0;
        regaluwrite = 0;
        epcwrite = 0;
        reghighw = 0;
        regloww = 0;
        //sinais dos mux
		pccondmux = 2'b00;
		iordmux = 3'b100;
        readsmux = 0;
		readdstmux = 2'b00;
		memtoregmux = 3'b000;
        alusrcamux = 0;
		alusrcbmux = 2'b00;
        pcsourcemux = 3'b000;
        reginmux = 0;
        shiftsmux = 0;
        divmultmux = 0;
        multsmux = 0;
        //sinais dos componentes
        wms = 2'b00;
        
		memwrite = 0;
		aluop = 3'b000;
        shiftop = 3'b000;
        startdiv = 0;
        
        
        startmult = 0;
        
        multo = 0;
            
       nextstate = lb_wait2;
      end
      
      lb_wait2: begin
        pcwritecond = 0;
        pcwrite = 0;
        //sinais dos registradores
        mdrs = 1;
        irwrite = 0;
        regwritesignal = 0;
        regaw = 0;
        regbw = 0;
        regaluwrite = 0;
        epcwrite = 0;
        reghighw = 0;
        regloww = 0;
        //sinais dos mux
		pccondmux = 2'b00;
		iordmux = 3'b100;
        readsmux = 0;
		readdstmux = 2'b00;
		memtoregmux = 3'b000;
        alusrcamux = 0;
		alusrcbmux = 2'b00;
        pcsourcemux = 3'b000;
        reginmux = 0;
        shiftsmux = 0;
        divmultmux = 0;
        multsmux = 0;
        //sinais dos componentes
        wms = 2'b00;
        
		memwrite = 0;
		aluop = 3'b000;
        shiftop = 3'b000;
        startdiv = 0;
        
        
        startmult = 0;
        
        multo = 0;
            
       nextstate = lb_write;
      end
      
      lb_write: begin
        pcwritecond = 0;
        pcwrite = 0;
        //sinais dos registradores
        mdrs = 0;
        irwrite = 0;
        regwritesignal = 1;
        regaw = 0;
        regbw = 0;
        regaluwrite = 0;
        epcwrite = 0;
        reghighw = 0;
        regloww = 0;
        //sinais dos mux
		pccondmux = 2'b00;
		iordmux = 3'b100;
        readsmux = 0;
		readdstmux = 2'b00;
		memtoregmux = 3'b010;
        alusrcamux = 0;
		alusrcbmux = 2'b00;
        pcsourcemux = 3'b000;
        reginmux = 0;
        shiftsmux = 0;
        divmultmux = 0;
        multsmux = 0;
        //sinais dos componentes
        wms = 2'b10;
        
		memwrite = 0;
		aluop = 3'b000;
        shiftop = 3'b000;
        startdiv = 0;
        
        
        startmult = 0;
        
        multo = 0;
            
        nextstate = fetch;
      end
      sh_address: begin
        pcwritecond = 0;
        pcwrite = 0;
        //sinais dos registradores
        mdrs = 0;
        irwrite = 0;
        regwritesignal = 0;
        regaw = 0;
        regbw = 0;
        regaluwrite = 1;
        epcwrite = 0;
        reghighw = 0;
        regloww = 0;
        //sinais dos mux
		pccondmux = 2'b00;
		iordmux = 3'b000;
        readsmux = 0;
		readdstmux = 2'b00;
		memtoregmux = 3'b000;
        alusrcamux = 1;
		alusrcbmux = 2'b10;
        pcsourcemux = 3'b000;
        reginmux = 0;
        shiftsmux = 0;
        divmultmux = 0;
        multsmux = 0;
        //sinais dos componentes
        wms = 2'b00;
        
		memwrite = 0;
		aluop = 3'b001;
        shiftop = 3'b000;
        startdiv = 0;
        
        
        startmult = 0;
        
        multo = 0;
            
        nextstate = sh_memory;
          
      end
      sh_memory: begin
        pcwritecond = 0;
        pcwrite = 0;
        //sinais dos registradores
        mdrs = 0;
        irwrite = 0;
        regwritesignal = 0;
        regaw = 0;
        regbw = 0;
        regaluwrite = 0;
        epcwrite = 0;
        reghighw = 0;
        regloww = 0;
        //sinais dos mux
		pccondmux = 2'b00;
		iordmux = 3'b100;
        readsmux = 0;
		readdstmux = 2'b00;
		memtoregmux = 3'b000;
        alusrcamux = 0;
		alusrcbmux = 2'b00;
        pcsourcemux = 3'b000;
        reginmux = 0;
        shiftsmux = 0;
        divmultmux = 0;
        multsmux = 0;
        //sinais dos componentes
        wms = 2'b00;
        
		memwrite = 0;
		aluop = 3'b000;
        shiftop = 3'b000;
        startdiv = 0;
        
        
        startmult = 0;
        
        multo = 0;
            
        nextstate = sh_wait_;
      end
      sh_wait_: begin
        pcwritecond = 0;
        pcwrite = 0;
        //sinais dos registradores
        mdrs = 0;
        irwrite = 0;
        regwritesignal = 0;
        regaw = 0;
        regbw = 0;
        regaluwrite = 0;
        epcwrite = 0;
        reghighw = 0;
        regloww = 0;
        //sinais dos mux
		pccondmux = 2'b00;
		iordmux = 3'b100;
        readsmux = 0;
		readdstmux = 2'b00;
		memtoregmux = 3'b000;
        alusrcamux = 0;
		alusrcbmux = 2'b00;
        pcsourcemux = 3'b000;
        reginmux = 0;
        shiftsmux = 0;
        divmultmux = 0;
        multsmux = 0;
        //sinais dos componentes
        wms = 2'b00;
        
		memwrite = 0;
		aluop = 3'b000;
        shiftop = 3'b000;
        startdiv = 0;
        
        
        startmult = 0;
        
        multo = 0;
            
       nextstate = sh_wait2;
      end
      
      sh_wait2: begin
        pcwritecond = 0;
        pcwrite = 0;
        //sinais dos registradores
        mdrs = 1;
        irwrite = 0;
        regwritesignal = 0;
        regaw = 0;
        regbw = 0;
        regaluwrite = 0;
        epcwrite = 0;
        reghighw = 0;
        regloww = 0;
        //sinais dos mux
		pccondmux = 2'b00;
		iordmux = 3'b100;
        readsmux = 0;
		readdstmux = 2'b00;
		memtoregmux = 3'b000;
        alusrcamux = 0;
		alusrcbmux = 2'b00;
        pcsourcemux = 3'b000;
        reginmux = 0;
        shiftsmux = 0;
        divmultmux = 0;
        multsmux = 0;
        //sinais dos componentes
        wms = 2'b00;
        
		memwrite = 0;
		aluop = 3'b000;
        shiftop = 3'b000;
        startdiv = 0;
        
        
        startmult = 0;
        
        multo = 0;
            
       nextstate = sh_write;
      end
      
      sh_write: begin
        pcwritecond = 0;
        pcwrite = 0;
        //sinais dos registradores
        mdrs = 0;
        irwrite = 0;
        regwritesignal = 0;
        regaw = 0;
        regbw = 0;
        regaluwrite = 0;
        epcwrite = 0;
        reghighw = 0;
        regloww = 0;
        //sinais dos mux
		pccondmux = 2'b00;
		iordmux = 3'b100;
        readsmux = 0;
		readdstmux = 2'b00;
		memtoregmux = 3'b000;
        alusrcamux = 0;
		alusrcbmux = 2'b00;
        pcsourcemux = 3'b000;
        reginmux = 0;
        shiftsmux = 0;
        divmultmux = 0;
        multsmux = 0;
        //sinais dos componentes
        wms = 2'b01;
        
		memwrite = 1;
		aluop = 3'b000;
        shiftop = 3'b000;
        startdiv = 0;
        
        
        startmult = 0;
        
        multo = 0;
            
        nextstate = fetch;
      end
      sb_address: begin
        pcwritecond = 0;
        pcwrite = 0;
        //sinais dos registradores
        mdrs = 0;
        irwrite = 0;
        regwritesignal = 0;
        regaw = 0;
        regbw = 0;
        regaluwrite = 1;
        epcwrite = 0;
        reghighw = 0;
        regloww = 0;
        //sinais dos mux
		pccondmux = 2'b00;
		iordmux = 3'b000;
        readsmux = 0;
		readdstmux = 2'b00;
		memtoregmux = 3'b000;
        alusrcamux = 1;
		alusrcbmux = 2'b10;
        pcsourcemux = 3'b000;
        reginmux = 0;
        shiftsmux = 0;
        divmultmux = 0;
        multsmux = 0;
        //sinais dos componentes
        wms = 2'b00;
        
		memwrite = 0;
		aluop = 3'b001;
        shiftop = 3'b000;
        startdiv = 0;
        
        
        startmult = 0;
        
        multo = 0;
            
       nextstate = sb_memory;
      end
      sb_memory: begin
        pcwritecond = 0;
        pcwrite = 0;
        //sinais dos registradores
        mdrs = 0;
        irwrite = 0;
        regwritesignal = 0;
        regaw = 0;
        regbw = 0;
        regaluwrite = 0;
        epcwrite = 0;
        reghighw = 0;
        regloww = 0;
        //sinais dos mux
		pccondmux = 2'b00;
		iordmux = 3'b100;
        readsmux = 0;
		readdstmux = 2'b00;
		memtoregmux = 3'b000;
        alusrcamux = 0;
		alusrcbmux = 2'b00;
        pcsourcemux = 3'b000;
        reginmux = 0;
        shiftsmux = 0;
        divmultmux = 0;
        multsmux = 0;
        //sinais dos componentes
        wms = 2'b00;
        
		memwrite = 0;
		aluop = 3'b000;
        shiftop = 3'b000;
        startdiv = 0;
        
        
        startmult = 0;
        
        multo = 0;
            
            nextstate = sb_wait_;
      end
      sb_wait_: begin
        pcwritecond = 0;
        pcwrite = 0;
        //sinais dos registradores
        mdrs = 0;
        irwrite = 0;
        regwritesignal = 0;
        regaw = 0;
        regbw = 0;
        regaluwrite = 0;
        epcwrite = 0;
        reghighw = 0;
        regloww = 0;
        //sinais dos mux
		pccondmux = 2'b00;
		iordmux = 3'b100;
        readsmux = 0;
		readdstmux = 2'b00;
		memtoregmux = 3'b000;
        alusrcamux = 0;
		alusrcbmux = 2'b00;
        pcsourcemux = 3'b000;
        reginmux = 0;
        shiftsmux = 0;
        divmultmux = 0;
        multsmux = 0;
        //sinais dos componentes
        wms = 2'b00;
        
		memwrite = 0;
		aluop = 3'b000;
        shiftop = 3'b000;
        startdiv = 0;
        
        
        startmult = 0;
        
        multo = 0;
            
       nextstate = sb_wait2;
      end
      
      sb_wait2: begin
        pcwritecond = 0;
        pcwrite = 0;
        //sinais dos registradores
        mdrs = 1;
        irwrite = 0;
        regwritesignal = 0;
        regaw = 0;
        regbw = 0;
        regaluwrite = 0;
        epcwrite = 0;
        reghighw = 0;
        regloww = 0;
        //sinais dos mux
		pccondmux = 2'b00;
		iordmux = 3'b100;
        readsmux = 0;
		readdstmux = 2'b00;
		memtoregmux = 3'b000;
        alusrcamux = 0;
		alusrcbmux = 2'b00;
        pcsourcemux = 3'b000;
        reginmux = 0;
        shiftsmux = 0;
        divmultmux = 0;
        multsmux = 0;
        //sinais dos componentes
        wms = 2'b00;
        
		memwrite = 0;
		aluop = 3'b000;
        shiftop = 3'b000;
        startdiv = 0;
        
        
        startmult = 0;
        
        multo = 0;
            
       nextstate = sb_write;
      end
      
        sb_write: begin
        pcwritecond = 0;
        pcwrite = 0;
        //sinais dos registradores
        mdrs = 0;
        irwrite = 0;
        regwritesignal = 0;
        regaw = 0;
        regbw = 0;
        regaluwrite = 0;
        epcwrite = 0;
        reghighw = 0;
        regloww = 0;
        //sinais dos mux
		pccondmux = 2'b00;
		iordmux = 3'b100;
        readsmux = 0;
		readdstmux = 2'b00;
		memtoregmux = 3'b000;
        alusrcamux = 0;
		alusrcbmux = 2'b00;
        pcsourcemux = 3'b000;
        reginmux = 0;
        shiftsmux = 0;
        divmultmux = 0;
        multsmux = 0;
        //sinais dos componentes
        wms = 2'b10;
        
		memwrite = 1;
		aluop = 3'b000;
        shiftop = 3'b000;
        startdiv = 0;
        
        
        startmult = 0;
        
        multo = 0;
            
       nextstate = fetch;
      end
      slti: begin
        pcwritecond = 0;
        pcwrite = 0;
        //sinais dos registradores
        mdrs = 0;
        irwrite = 0;
        regwritesignal = 1;
        regaw = 0;
        regbw = 0;
        regaluwrite = 0;
        epcwrite = 0;
        reghighw = 0;
        regloww = 0;
        //sinais dos mux
		pccondmux = 2'b00;
		iordmux = 3'b000;
        readsmux = 0;
		readdstmux = 2'b00;
		memtoregmux = 3'b101;
		alusrcamux = 1;
		alusrcbmux = 2'b10;
        pcsourcemux = 3'b000;
        reginmux = 0;
        shiftsmux = 0;
        divmultmux = 0;
        multsmux = 0;
        //sinais dos componentes
        wms = 2'b00;
        
		memwrite = 0;
		aluop = 3'b111;
        shiftop = 3'b000;
        startdiv = 0;
        
        
        startmult = 0;
        
        multo = 0;
            
         nextstate = fetch;
        end
        
        addiu: begin
        pcwritecond = 0;
        pcwrite = 0;
        //sinais dos registradores
        mdrs = 0;
        irwrite = 0;
        regwritesignal = 0;
        regaw = 0;
        regbw = 0;
        regaluwrite = 1;
        epcwrite = 0;
        reghighw = 0;
        regloww = 0;
        //sinais dos mux
		pccondmux = 2'b00;
		iordmux = 3'b000;
        readsmux = 0;
		readdstmux = 2'b00;
		memtoregmux = 3'b000;
        alusrcamux = 1;
		alusrcbmux = 2'b10;
        pcsourcemux = 3'b000;
        reginmux = 0;
        shiftsmux = 0;
        divmultmux = 0;
        multsmux = 0;
        //sinais dos componentes
        wms = 2'b00;
        
		memwrite = 0;
		aluop = 3'b001;
        shiftop = 3'b000;
        startdiv = 0;
        
        
        startmult = 0;
        
        multo = 0;
            
        nextstate = regt_write;
        end
        addi: begin
        pcwritecond = 0;
        pcwrite = 0;
        //sinais dos registradores
        mdrs = 0;
        irwrite = 0;
        regwritesignal = 0;
        regaw = 0;
        regbw = 0;
        regaluwrite = 1;
        epcwrite = 0;
        reghighw = 0;
        regloww = 0;
        //sinais dos mux
		pccondmux = 2'b00;
		iordmux = 3'b000;
        readsmux = 0;
		readdstmux = 2'b00;
		memtoregmux = 3'b000;
        alusrcamux = 1;
		alusrcbmux = 2'b10;
        pcsourcemux = 3'b000;
        reginmux = 0;
        shiftsmux = 0;
        divmultmux = 0;
        multsmux = 0;
        //sinais dos componentes
        wms = 2'b00;
        
		memwrite = 0;
		aluop = 3'b001;
        shiftop = 3'b000;
        startdiv = 0;
        
        
        startmult = 0;
        
        multo = 0;
            
        nextstate = overflow ? ov_load : regt_write;
        end
        regt_write: begin
        pcwritecond = 0;
        pcwrite = 0;
        //sinais dos registradores
        mdrs = 0;
        irwrite = 0;
        regwritesignal = 1;
        regaw = 0;
        regbw = 0;
        regaluwrite = 0;
        epcwrite = 0;
        reghighw = 0;
        regloww = 0;
        //sinais dos mux
		pccondmux = 2'b00;
		iordmux = 3'b000;
        readsmux = 0;
		readdstmux = 2'b00;
		memtoregmux = 3'b000;
        alusrcamux = 0;
		alusrcbmux = 2'b00;
        pcsourcemux = 3'b000;
        reginmux = 0;
        shiftsmux = 0;
        divmultmux = 0;
        multsmux = 0;
        //sinais dos componentes
        wms = 2'b00;
        
		memwrite = 0;
		aluop = 3'b000;
        shiftop = 3'b000;
        startdiv = 0;
        
        
        startmult = 0;
        
        multo = 0;
            
        nextstate = fetch;
    end 
    ov_load: begin
        pcwritecond = 0;
        pcwrite = 0;
        //sinais dos registradores
        mdrs = 0;
        irwrite = 0;
        regwritesignal = 0;
        regaw = 0;
        regbw = 0;
        regaluwrite = 0;
        epcwrite = 0;
        reghighw = 0;
        regloww = 0;
        //sinais dos mux
		pccondmux = 2'b00;
		iordmux = 3'b010;
        readsmux = 0;
		readdstmux = 2'b00;
		memtoregmux = 3'b000;
        alusrcamux = 0;
		alusrcbmux = 2'b00;
        pcsourcemux = 3'b000;
        reginmux = 0;
        shiftsmux = 0;
        divmultmux = 0;
        multsmux = 0;
        //sinais dos componentes
        wms = 2'b00;
        
		memwrite = 0;
		aluop = 3'b000;
        shiftop = 3'b000;
        startdiv = 0;
        
        
        startmult = 0;
        
        multo = 0;
            
        nextstate = ov_wait_;
        end
        
        ov_wait_: begin
        pcwritecond = 0;
        pcwrite = 0;
        //sinais dos registradores
        mdrs = 0;
        irwrite = 0;
        regwritesignal = 0;
        regaw = 0;
        regbw = 0;
        regaluwrite = 0;
        epcwrite = 0;
        reghighw = 0;
        regloww = 0;
        //sinais dos mux
		pccondmux = 2'b00;
		iordmux = 3'b000;
        readsmux = 0;
		readdstmux = 2'b00;
		memtoregmux = 3'b000;
        alusrcamux = 0;
		alusrcbmux = 2'b00;
        pcsourcemux = 3'b000;
        reginmux = 0;
        shiftsmux = 0;
        divmultmux = 0;
        multsmux = 0;
        //sinais dos componentes
        wms = 2'b00;
        
		memwrite = 0;
		aluop = 3'b000;
        shiftop = 3'b000;
        startdiv = 0;
        
        
        startmult = 0;
        
        multo = 0;
            
        nextstate = ov_wait2;
        end
        
        ov_wait2: begin
        pcwritecond = 0;
        pcwrite = 0;
        //sinais dos registradores
        mdrs = 1;
        irwrite = 0;
        regwritesignal = 0;
        regaw = 0;
        regbw = 0;
        regaluwrite = 0;
        epcwrite = 0;
        reghighw = 0;
        regloww = 0;
        //sinais dos mux
		pccondmux = 2'b00;
		iordmux = 3'b000;
        readsmux = 0;
		readdstmux = 2'b00;
		memtoregmux = 3'b000;
        alusrcamux = 0;
		alusrcbmux = 2'b00;
        pcsourcemux = 3'b000;
        reginmux = 0;
        shiftsmux = 0;
        divmultmux = 0;
        multsmux = 0;
        //sinais dos componentes
        wms = 2'b00;
        
		memwrite = 0;
		aluop = 3'b000;
        shiftop = 3'b000;
        startdiv = 0;
        
        
        startmult = 0;
        
        multo = 0;
            
        nextstate = ov_pc;
        end
        
      ov_pc: begin
        pcwritecond = 0;
        pcwrite = 1;
        //sinais dos registradores
        mdrs = 0;
        irwrite = 0;
        regwritesignal = 0;
        regaw = 0;
        regbw = 0;
        regaluwrite = 0;
        epcwrite = 0;
        reghighw = 0;
        regloww = 0;
        //sinais dos mux
		pccondmux = 2'b00;
		iordmux = 3'b000;
        readsmux = 0;
		readdstmux = 2'b00;
		memtoregmux = 3'b000;
        alusrcamux = 0;
		alusrcbmux = 2'b00;
        pcsourcemux = 3'b100;
        reginmux = 0;
        shiftsmux = 0;
        divmultmux = 0;
        multsmux = 0;
        //sinais dos componentes
        wms = 2'b10;
        
		memwrite = 0;
		aluop = 3'b000;
        shiftop = 3'b000;
        startdiv = 0;
        
        
        startmult = 0;
        
        multo = 0;
            
        nextstate = fetch;
        end
      push: begin
        pcwritecond = 0;
        pcwrite = 0;
        //sinais dos registradores
        mdrs = 0;
        irwrite = 0;
        regwritesignal = 0;
        regaw = 1;
        regbw = 0;
        regaluwrite = 0;
        epcwrite = 0;
        reghighw = 0;
        regloww = 0;
        //sinais dos mux
		pccondmux = 2'b00;
		iordmux = 3'b000;
        readsmux = 0;
		readdstmux = 2'b00;
		memtoregmux = 3'b000;
        alusrcamux = 0;
		alusrcbmux = 2'b00;
        pcsourcemux = 3'b000;
        reginmux = 0;
        shiftsmux = 0;
        divmultmux = 0;
        multsmux = 0;
        //sinais dos componentes
        wms = 2'b00;
        
		memwrite = 0;
		aluop = 3'b000;
        shiftop = 3'b000;
        startdiv = 0;
        
        
        startmult = 0;
        
        multo = 0;
            
        nextstate = newra;
        end
      newra: begin
        pcwritecond = 0;
        pcwrite = 0;
        //sinais dos registradores
        mdrs = 0;
        irwrite = 0;
        regwritesignal = 0;
        regaw = 0;
        regbw = 0;
        regaluwrite = 1;
        epcwrite = 0;
        reghighw = 0;
        regloww = 0;
        //sinais dos mux
		pccondmux = 2'b00;
		iordmux = 3'b000;
        readsmux = 0;
		readdstmux = 2'b00;
		memtoregmux = 3'b000;
        alusrcamux = 1;
		alusrcbmux = 2'b01;
        pcsourcemux = 3'b000;
        reginmux = 0;
        shiftsmux = 0;
        divmultmux = 0;
        multsmux = 0;
        //sinais dos componentes
        wms = 2'b00;
        
		memwrite = 0;
		aluop = 3'b010;
        shiftop = 3'b000;
        startdiv = 0;
        
        
        startmult = 0;
        
        multo = 0;
            
       nextstate = savera_write;
        end
      savera_write: begin
        pcwritecond = 0;
        pcwrite = 0;
        //sinais dos registradores
        mdrs = 0;
        irwrite = 0;
        regwritesignal = 1;
        regaw = 0;
        regbw = 0;
        regaluwrite = 0;
        epcwrite = 0;
        reghighw = 0;
        regloww = 0;
        //sinais dos mux
		pccondmux = 2'b00;
		iordmux = 3'b100;
        readsmux = 0;
		readdstmux = 2'b10;
		memtoregmux = 3'b000;
        alusrcamux = 0;
		alusrcbmux = 2'b00;
        pcsourcemux = 3'b000;
        reginmux = 0;
        shiftsmux = 0;
        divmultmux = 0;
        multsmux = 0;
        //sinais dos componentes
        wms = 2'b00;
        
		memwrite = 1;
		aluop = 3'b000;
        shiftop = 3'b000;
        startdiv = 0;
        
        
        startmult = 0;
        
        multo = 0;
            
        nextstate = fetch;
        end

      pop: begin
        pcwritecond = 0;
        pcwrite = 0;
        //sinais dos registradores
        mdrs = 0;
        irwrite = 0;
        regwritesignal = 0;
        regaw = 1;
        regbw = 0;
        regaluwrite = 0;
        epcwrite = 0;
        reghighw = 0;
        regloww = 0;
        //sinais dos mux
		pccondmux = 2'b00;
		iordmux = 3'b000;
        readsmux = 0;
		readdstmux = 2'b00;
		memtoregmux = 3'b000;
        alusrcamux = 0;
		alusrcbmux = 2'b00;
        pcsourcemux = 3'b000;
        reginmux = 0;
        shiftsmux = 0;
        divmultmux = 0;
        multsmux = 0;
        //sinais dos componentes
        wms = 2'b00;
        
		memwrite = 0;
		aluop = 3'b000;
        shiftop = 3'b000;
        startdiv = 0;
        
        
        startmult = 0;
        
        multo = 0;
            
        nextstate = address;
        end
     address: begin
        pcwritecond = 0;
        pcwrite = 0;
        //sinais dos registradores
        mdrs = 0;
        irwrite = 0;
        regwritesignal = 0;
        regaw = 0;
        regbw = 0;
        regaluwrite = 1;
        epcwrite = 0;
        reghighw = 0;
        regloww = 0;
        //sinais dos mux
		pccondmux = 2'b00;
		iordmux = 3'b000;
        readsmux = 0;
		readdstmux = 2'b00;
		memtoregmux = 3'b000;
        alusrcamux = 1;
		alusrcbmux = 2'b00;
        pcsourcemux = 3'b000;
        reginmux = 0;
        shiftsmux = 0;
        divmultmux = 0;
        multsmux = 0;
        //sinais dos componentes
        wms = 2'b00;
        
		memwrite = 0;
		aluop = 3'b000;
        shiftop = 3'b000;
        startdiv = 0;
        
        
        startmult = 0;
        
        multo = 0;
            
        nextstate = readaddress;
        end
      readaddress: begin
        pcwritecond = 0;
        pcwrite = 0;
        //sinais dos registradores
        mdrs = 0;
        irwrite = 0;
        regwritesignal = 0;
        regaw = 0;
        regbw = 0;
        regaluwrite = 0;
        epcwrite = 0;
        reghighw = 0;
        regloww = 0;
        //sinais dos mux
		pccondmux = 2'b00;
		iordmux = 3'b100;
        readsmux = 0;
		readdstmux = 2'b00;
		memtoregmux = 3'b000;
        alusrcamux = 0;
		alusrcbmux = 2'b00;
        pcsourcemux = 3'b000;
        reginmux = 0;
        shiftsmux = 0;
        divmultmux = 0;
        multsmux = 0;
        //sinais dos componentes
        wms = 2'b00;
        
		memwrite = 0;
		aluop = 3'b000;
        shiftop = 3'b000;
        startdiv = 0;
        
        
        startmult = 0;
        
        multo = 0;
            
        nextstate = stall;
        end
      stall: begin
        pcwritecond = 0;
        pcwrite = 0;
        //sinais dos registradores
        mdrs = 0;
        irwrite = 0;
        regwritesignal = 0;
        regaw = 0;
        regbw = 0;
        regaluwrite = 0;
        epcwrite = 0;
        reghighw = 0;
        regloww = 0;
        //sinais dos mux
		pccondmux = 2'b00;
		iordmux = 3'b100;
        readsmux = 0;
		readdstmux = 2'b00;
		memtoregmux = 3'b000;
        alusrcamux = 0;
		alusrcbmux = 2'b00;
        pcsourcemux = 3'b000;
        reginmux = 0;
        shiftsmux = 0;
        divmultmux = 0;
        multsmux = 0;
        //sinais dos componentes
        wms = 2'b00;
        
		memwrite = 0;
		aluop = 3'b000;
        shiftop = 3'b000;
        startdiv = 0;
        
        
        startmult = 0;
        
        multo = 0;
            
        nextstate = stall2;
        end
        
        stall2: begin
        pcwritecond = 0;
        pcwrite = 0;
        //sinais dos registradores
        mdrs = 1;
        irwrite = 0;
        regwritesignal = 0;
        regaw = 0;
        regbw = 0;
        regaluwrite = 0;
        epcwrite = 0;
        reghighw = 0;
        regloww = 0;
        //sinais dos mux
		pccondmux = 2'b00;
		iordmux = 3'b100;
        readsmux = 0;
		readdstmux = 2'b00;
		memtoregmux = 3'b000;
        alusrcamux = 0;
		alusrcbmux = 2'b00;
        pcsourcemux = 3'b000;
        reginmux = 0;
        shiftsmux = 0;
        divmultmux = 0;
        multsmux = 0;
        //sinais dos componentes
        wms = 2'b00;     
		memwrite = 0;
		aluop = 3'b000;
        shiftop = 3'b000;
        startdiv = 0;
        
        
        startmult = 0;
        multo = 0;
            
        nextstate = save_reg;
        end
        
      save_reg: begin
        pcwritecond = 0;
        pcwrite = 0;
        //sinais dos registradores
        mdrs = 0;
        irwrite = 0;
        regwritesignal = 1;
        regaw = 0;
        regbw = 0;
        regaluwrite = 0;
        epcwrite = 0;
        reghighw = 0;
        regloww = 0;
        //sinais dos mux
		pccondmux = 2'b00;
		iordmux = 3'b000;
        readsmux = 0;
		readdstmux = 2'b00;
		memtoregmux = 3'b010;
        alusrcamux = 0;
		alusrcbmux = 2'b00;
        pcsourcemux = 3'b000;
        reginmux = 0;
        shiftsmux = 0;
        divmultmux = 0;
        multsmux = 0;
        //sinais dos componentes
        wms = 2'b00;
        
		memwrite = 0;
		aluop = 3'b000;
        shiftop = 3'b000;
        startdiv = 0;
        
        
        startmult = 0;
        
        multo = 0;
            
        nextstate = new_pointer;
        end
      new_pointer: begin
        pcwritecond = 0;
        pcwrite = 0;
        //sinais dos registradores
        mdrs = 0;
        irwrite = 0;
        regwritesignal = 0;
        regaw = 0;
        regbw = 0;
        regaluwrite = 1;
        epcwrite = 0;
        reghighw = 0;
        regloww = 0;
        //sinais dos mux
		pccondmux = 2'b00;
		iordmux = 3'b000;
        readsmux = 0;
		readdstmux = 2'b00;
		memtoregmux = 3'b000;
        alusrcamux = 1;
		alusrcbmux = 2'b01;
        pcsourcemux = 3'b000;
        reginmux = 0;
        shiftsmux = 0;
        divmultmux = 0;
        multsmux = 0;
        //sinais dos componentes
        wms = 2'b00;
        
		memwrite = 0;
		aluop = 3'b001;
        shiftop = 3'b000;
        startdiv = 0;
        
        
        startmult = 0;
        
        multo = 0;
            
        nextstate = updatera;
        end
      updatera: begin
        pcwritecond = 0;
        pcwrite = 0;
        //sinais dos registradores
        mdrs = 0;
        irwrite = 0;
        regwritesignal = 1;
        regaw = 0;
        regbw = 0;
        regaluwrite = 0;
        epcwrite = 0;
        reghighw = 0;
        regloww = 0;
        //sinais dos mux
		pccondmux = 2'b00;
		iordmux = 3'b000;
        readsmux = 0;
		readdstmux = 2'b10;
		memtoregmux = 3'b000;
        alusrcamux = 0;
		alusrcbmux = 2'b00;
        pcsourcemux = 3'b000;
        reginmux = 0;
        shiftsmux = 0;
        divmultmux = 0;
        multsmux = 0;
        //sinais dos componentes
        wms = 2'b00;
        
		memwrite = 0;
		aluop = 3'b000;
        shiftop = 3'b000;
        startdiv = 0;
        
        
        startmult = 0;
        
        multo = 0;
            
        nextstate = fetch;
        end
      rte: begin
        pcwritecond = 0;
        pcwrite = 1;
        //sinais dos registradores
        mdrs = 0;
        irwrite = 0;
        regwritesignal = 0;
        regaw = 0;
        regbw = 0;
        regaluwrite = 0;
        epcwrite = 0;
        reghighw = 0;
        regloww = 0;
        //sinais dos mux
		pccondmux = 2'b00;
		iordmux = 3'b000;
        readsmux = 0;
		readdstmux = 2'b00;
		memtoregmux = 3'b000;
        alusrcamux = 0;
		alusrcbmux = 2'b00;
        pcsourcemux = 3'b011;
        reginmux = 0;
        shiftsmux = 0;
        divmultmux = 0;
        multsmux = 0;
        //sinais dos componentes
        wms = 2'b00;
        
		memwrite = 0;
		aluop = 3'b000;
        shiftop = 3'b000;
        startdiv = 0;
        
        
        startmult = 0;
        
        multo = 0;
            
        nextstate = fetch;
        end

      mflo: begin
        pcwritecond = 0;
        pcwrite = 0;
        //sinais dos registradores
        mdrs = 0;
        irwrite = 0;
        regwritesignal = 1;
        regaw = 0;
        regbw = 0;
        regaluwrite = 0;
        epcwrite = 0;
        reghighw = 0;
        regloww = 0;
        //sinais dos mux
		pccondmux = 2'b00;
		iordmux = 3'b000;
        readsmux = 0;
		readdstmux = 2'b11;
		memtoregmux = 3'b011;
        alusrcamux = 0;
		alusrcbmux = 2'b00;
        pcsourcemux = 3'b000;
        reginmux = 0;
        shiftsmux = 0;
        divmultmux = 0;
        multsmux = 1;
        //sinais dos componentes
        wms = 2'b00;
        
		memwrite = 0;
		aluop = 3'b000;
        shiftop = 3'b000;
        startdiv = 0;
        
        
        startmult = 0;
        
        multo = 0;
            
        nextstate = fetch;
        end
        
      mfhi: begin
        pcwritecond = 0;
        pcwrite = 0;
        //sinais dos registradores
        mdrs = 0;
        irwrite = 0;
        regwritesignal = 1;
        regaw = 0;
        regbw = 0;
        regaluwrite = 0;
        epcwrite = 0;
        reghighw = 0;
        regloww = 0;
        //sinais dos mux
		pccondmux = 2'b00;
		iordmux = 3'b000;
        readsmux = 0;
		readdstmux = 2'b11;
		memtoregmux = 3'b011;
        alusrcamux = 0;
		alusrcbmux = 2'b00;
        pcsourcemux = 3'b000;
        reginmux = 0;
        shiftsmux = 0;
        divmultmux = 0;
        multsmux = 0;
        //sinais dos componentes
        wms = 2'b00;
		memwrite = 0;
		aluop = 3'b000;
        shiftop = 3'b000;
        startdiv = 0;
        
        
        startmult = 0;
        
        multo = 0;
            
        nextstate = fetch;
       end
      jr: begin
        pcwritecond = 0;
        pcwrite = 1;
        //sinais dos registradores
        mdrs = 0;
        irwrite = 0;
        regwritesignal = 0;
        regaw = 0;
        regbw = 0;
        regaluwrite = 0;
        epcwrite = 0;
        reghighw = 0;
        regloww = 0;
        //sinais dos mux
		pccondmux = 2'b00;
		iordmux = 3'b000;
        readsmux = 0;
		readdstmux = 2'b00;
		memtoregmux = 3'b000;
        alusrcamux = 0;
		alusrcbmux = 2'b00;
        pcsourcemux = 3'b101;
        reginmux = 0;
        shiftsmux = 0;
        divmultmux = 0;
        multsmux = 0;
        //sinais dos componentes
        wms = 2'b00;
			
		memwrite = 0;
		aluop = 3'b000;
        shiftop = 3'b000;
        startdiv = 0;
        
        
        startmult = 0;
        
        multo = 0;
            
            nextstate = fetch;
        end
        break_: begin
          pcwritecond = 0;
        pcwrite = 1;
        //sinais dos registradores
        mdrs = 0;
        irwrite = 0;
        regwritesignal = 0;
        regaw = 0;
        regbw = 0;
        regaluwrite = 0;
        epcwrite = 0;
        reghighw = 0;
        regloww = 0;
        //sinais dos mux
      pccondmux = 2'b00;
      iordmux = 3'b000;
        readsmux = 0;
      readdstmux = 2'b00;
      memtoregmux = 3'b000;
        alusrcamux = 0;
      alusrcbmux = 2'b01;
        pcsourcemux = 3'b000;
        reginmux = 0;
        shiftsmux = 0;
        divmultmux = 0;
        multsmux = 0;
        //sinais dos componentes
        wms = 2'b00;
        
      memwrite = 0;
      aluop = 3'b010;
        shiftop = 3'b000;
        startdiv = 0;
        
        
        startmult = 0;
        
        multo = 0;
            
            nextstate = fetch;
        end
        slt: begin
          pcwritecond = 0;
        pcwrite = 0;
        //sinais dos registradores
        mdrs = 0;
        irwrite = 0;
        regwritesignal = 1;
        regaw = 0;
        regbw = 0;
        regaluwrite = 0;
        epcwrite = 0;
        reghighw = 0;
        regloww = 0;
        //sinais dos mux
      pccondmux = 2'b00;
      iordmux = 3'b000;
        readsmux = 0;
      readdstmux = 2'b11;
      memtoregmux = 3'b101;
        alusrcamux = 1;
      alusrcbmux = 2'b00;
        pcsourcemux = 3'b000;
        reginmux = 0;
        shiftsmux = 0;
        divmultmux = 0;
        multsmux = 0;
        //sinais dos componentes
        wms = 2'b00;
        
      memwrite = 0;
      aluop = 3'b111;
        shiftop = 3'b000;
        startdiv = 0;
        
        
        startmult = 0;
        
        multo = 0;
            
            nextstate = fetch;
        end
     
        sub: begin
          pcwritecond = 0;
        pcwrite = 0;
        //sinais dos registradores
        mdrs = 0;
        irwrite = 0;
        regwritesignal = 0;
        regaw = 0;
        regbw = 0;
        regaluwrite = 1;
        epcwrite = 0;
        reghighw = 0;
        regloww = 0;
        //sinais dos mux
      pccondmux = 2'b00;
      iordmux = 3'b000;
        readsmux = 0;
      readdstmux = 2'b00;
      memtoregmux = 3'b000;
        alusrcamux = 1;
      alusrcbmux = 2'b00;
        pcsourcemux = 3'b000;
        reginmux = 0;
        shiftsmux = 0;
        divmultmux = 0;
        multsmux = 0;
        //sinais dos componentes
        wms = 2'b00;
        
      memwrite = 0;
      aluop = 3'b010;
        shiftop = 3'b000;
        startdiv = 0;
        
        
        startmult = 0;
        
        multo = 0;
            
            nextstate = overflow ? ov_load : regd_write;
        end
        and_: begin
          pcwritecond = 0;
        pcwrite = 0;
        //sinais dos registradores
        mdrs = 0;
        irwrite = 0;
        regwritesignal = 0;
        regaw = 0;
        regbw = 0;
        regaluwrite = 1;
        epcwrite = 0;
        reghighw = 0;
        regloww = 0;
        //sinais dos mux
      pccondmux = 2'b00;
      iordmux = 3'b000;
        readsmux = 0;
      readdstmux = 2'b00;
      memtoregmux = 3'b000;
        alusrcamux = 1;
      alusrcbmux = 2'b00;
        pcsourcemux = 3'b000;
        reginmux = 0;
        shiftsmux = 0;
        divmultmux = 0;
        multsmux = 0;
        //sinais dos componentes
        wms = 2'b00;
        
      memwrite = 0;
      aluop = 3'b011;
        shiftop = 3'b000;
        startdiv = 0;
        
        
        startmult = 0;
        
        multo = 0;
            
            nextstate = regd_write;
        end
        add: begin
          pcwritecond = 0;
        pcwrite = 0;
        //sinais dos registradores
        mdrs = 0;
        irwrite = 0;
        regwritesignal = 0;
        regaw = 0;
        regbw = 0;
        regaluwrite = 1;
        epcwrite = 0;
        reghighw = 0;
        regloww = 0;
        //sinais dos mux
      pccondmux = 2'b00;
      iordmux = 3'b000;
        readsmux = 0;
      readdstmux = 2'b00;
      memtoregmux = 3'b000;
        alusrcamux = 1;
      alusrcbmux = 2'b00;
        pcsourcemux = 3'b000;
        reginmux = 0;
        shiftsmux = 0;
        divmultmux = 0;
        multsmux = 0;
        //sinais dos componentes
        wms = 2'b00;
        
      memwrite = 0;
      aluop = 3'b001;
        shiftop = 3'b000;
        startdiv = 0;
        
        
        startmult = 0;
        
        multo = 0;
            
            nextstate = overflow ? ov_load : regd_write;
        end
        regd_write: begin
          pcwritecond = 0;
        pcwrite = 0;
        //sinais dos registradores
        mdrs = 0;
        irwrite = 0;
        regwritesignal = 1;
        regaw = 0;
        regbw = 0;
        regaluwrite = 0;
        epcwrite = 0;
        reghighw = 0;
        regloww = 0;
        //sinais dos mux
      pccondmux = 2'b00;
      iordmux = 3'b000;
        readsmux = 0;
      readdstmux = 2'b11;
      memtoregmux = 3'b000;
        alusrcamux = 0;
      alusrcbmux = 2'b00;
        pcsourcemux = 3'b000;
        reginmux = 0;
        shiftsmux = 0;
        divmultmux = 0;
        multsmux = 0;
        //sinais dos componentes
        wms = 2'b00;
        
      memwrite = 0;
      aluop = 3'b000;
        shiftop = 3'b000;
        startdiv = 0;
        
        
        startmult = 0;
        
        multo = 0;
            
            nextstate = fetch;
        end
         regd_shift: begin
          pcwritecond = 0;
        pcwrite = 0;
        //sinais dos registradores
        mdrs = 0;
        irwrite = 0;
        regwritesignal = 1;
        regaw = 0;
        regbw = 0;
        regaluwrite = 0;
        epcwrite = 0;
        reghighw = 0;
        regloww = 0;
        //sinais dos mux
      pccondmux = 2'b00;
      iordmux = 3'b000;
        readsmux = 0;
      readdstmux = 2'b11;
      memtoregmux = 3'b001;
        alusrcamux = 0;
      alusrcbmux = 2'b00;
        pcsourcemux = 3'b000;
        reginmux = 0;
        shiftsmux = 0;
        divmultmux = 0;
        multsmux = 0;
        //sinais dos componentes
        wms = 2'b00;
        
      memwrite = 0;
      aluop = 3'b000;
        shiftop = 3'b000;
        startdiv = 0;
        
        
        startmult = 0;
        
        multo = 0;
            
            nextstate = fetch;
        end
        shiftshamt: begin
          pcwritecond = 0;
        pcwrite = 0;
        //sinais dos registradores
        mdrs = 0;
        irwrite = 0;
        regwritesignal = 0;
        regaw = 0;
        regbw = 0;
        regaluwrite = 0;
        epcwrite = 0;
        reghighw = 0;
        regloww = 0;
        //sinais dos mux
      pccondmux = 2'b00;
      iordmux = 3'b000;
        readsmux = 0;
      readdstmux = 2'b00;
      memtoregmux = 3'b000;
        alusrcamux = 0;
      alusrcbmux = 2'b00;
        pcsourcemux = 3'b000;
        reginmux = 0;
        shiftsmux = 1;
        divmultmux = 0;
        multsmux = 0;
        //sinais dos componentes
        wms = 2'b00;
        
      memwrite = 0;
      aluop = 3'b000;
        shiftop = 3'b001;
        startdiv = 0;
        
        
        startmult = 0;
        
        multo = 0;
            
          if(funct== 6'h0)
            nextstate = sll;
          else 
      if(funct == 6'h2)
             nextstate = srl;
             else
             nextstate = sra;
          
        end
        sll: begin
          pcwritecond = 0;
        pcwrite = 0;
        //sinais dos registradores
        mdrs = 0;
        irwrite = 0;
        regwritesignal = 0;
        regaw = 0;
        regbw = 0;
        regaluwrite = 0;
        epcwrite = 0;
        reghighw = 0;
        regloww = 0;
        //sinais dos mux
      pccondmux = 2'b00;
      iordmux = 3'b000;
        readsmux = 0;
      readdstmux = 2'b00;
      memtoregmux = 3'b000;
        alusrcamux = 0;
      alusrcbmux = 2'b00;
        pcsourcemux = 3'b000;
        reginmux = 0;
        shiftsmux = 1;
        divmultmux = 0;
        multsmux = 0;
        //sinais dos componentes
        wms = 2'b00;
        
      memwrite = 0;
      aluop = 3'b000;
        shiftop = 3'b010;
        startdiv = 0;
        
        
        startmult = 0;
        
        multo = 0;
            
        nextstate = regd_shift;
        end  
        
        srl: begin
          pcwritecond = 0;
        pcwrite = 0;
        //sinais dos registradores
        mdrs = 0;
        irwrite = 0;
        regwritesignal = 0;
        regaw = 0;
        regbw = 0;
        regaluwrite = 0;
        epcwrite = 0;
        reghighw = 0;
        regloww = 0;
        //sinais dos mux
      pccondmux = 2'b00;
      iordmux = 3'b000;
        readsmux = 0;
      readdstmux = 2'b00;
      memtoregmux = 3'b000;
        alusrcamux = 0;
      alusrcbmux = 2'b00;
        pcsourcemux = 3'b000;
        reginmux = 0;
        shiftsmux = 1;
        divmultmux = 0;
        multsmux = 0;
        //sinais dos componentes
        wms = 2'b00;
        
      memwrite = 0;
      aluop = 3'b000;
        shiftop = 3'b011;
        startdiv = 0;
        
        
        startmult = 0;
        
        multo = 0;
            
            nextstate = regd_shift;
        end
        sra: begin
          pcwritecond = 0;
        pcwrite = 0;
        //sinais dos registradores
        mdrs = 0;
        irwrite = 0;
        regwritesignal = 0;
        regaw = 0;
        regbw = 0;
        regaluwrite = 0;
        epcwrite = 0;
        reghighw = 0;
        regloww = 0;
        //sinais dos mux
      pccondmux = 2'b00;
      iordmux = 3'b000;
        readsmux = 0;
      readdstmux = 2'b00;
      memtoregmux = 3'b000;
        alusrcamux = 0;
      alusrcbmux = 2'b00;
        pcsourcemux = 3'b000;
        reginmux = 0;
        shiftsmux = 1;
        divmultmux = 0;
        multsmux = 0;
        //sinais dos componentes
        wms = 2'b00;
        
      memwrite = 0;
      aluop = 3'b000;
        shiftop = 3'b100;
        startdiv = 0;
        
        
        startmult = 0;
        
        multo = 0;
            
            nextstate = regd_shift;
        end
         shiftreg: begin
          pcwritecond = 0;
        pcwrite = 0;
        //sinais dos registradores
        mdrs = 0;
        irwrite = 0;
        regwritesignal = 0;
        regaw = 0;
        regbw = 0;
        regaluwrite = 0;
        epcwrite = 0;
        reghighw = 0;
        regloww = 0;
        //sinais dos mux
      pccondmux = 2'b00;
      iordmux = 3'b000;
        readsmux = 0;
      readdstmux = 2'b00;
      memtoregmux = 3'b000;
        alusrcamux = 0;
      alusrcbmux = 2'b00;
        pcsourcemux = 3'b000;
        reginmux = 1;
        shiftsmux = 0;
        divmultmux = 0;
        multsmux = 0;
        //sinais dos componentes
        wms = 2'b00;
        
      memwrite = 0;
      aluop = 3'b000;
        shiftop = 3'b001;
        startdiv = 0;
        
        
        startmult = 0;
        
        multo = 0;
            
          if(funct== 6'h4)
            nextstate = sllv;
          else
             nextstate = srav;
          
        end
        sllv: begin
          pcwritecond = 0;
        pcwrite = 0;
        //sinais dos registradores
        mdrs = 0;
        irwrite = 0;
        regwritesignal = 0;
        regaw = 0;
        regbw = 0;
        regaluwrite = 0;
        epcwrite = 0;
        reghighw = 0;
        regloww = 0;
        //sinais dos mux
      pccondmux = 2'b00;
      iordmux = 3'b000;
        readsmux = 0;
      readdstmux = 2'b00;
      memtoregmux = 3'b000;
        alusrcamux = 0;
      alusrcbmux = 2'b00;
        pcsourcemux = 3'b000;
        reginmux = 1;
        shiftsmux = 0;
        divmultmux = 0;
        multsmux = 0;
        //sinais dos componentes
        wms = 2'b00;
        
      memwrite = 0;
      aluop = 3'b000;
        shiftop = 3'b010;
        startdiv = 0;
        
        
        startmult = 0;
        
        multo = 0;
            
            nextstate = regd_shift;
        end
        srav: begin
          pcwritecond = 0;
        pcwrite = 0;
        //sinais dos registradores
        mdrs = 0;
        irwrite = 0;
        regwritesignal = 0;
        regaw = 0;
        regbw = 0;
        regaluwrite = 0;
        epcwrite = 0;
        reghighw = 0;
        regloww = 0;
        //sinais dos mux
      pccondmux = 2'b00;
      iordmux = 3'b000;
        readsmux = 0;
      readdstmux = 2'b00;
      memtoregmux = 3'b000;
        alusrcamux = 0;
      alusrcbmux = 2'b00;
        pcsourcemux = 3'b000;
        reginmux = 1;
        shiftsmux = 0;
        divmultmux = 0;
        multsmux = 0;
        //sinais dos componentes
        wms = 2'b00;
        
      memwrite = 0;
      aluop = 3'b000;
        shiftop = 3'b100;
        startdiv = 0;
        
        
        startmult = 0;
        
        multo = 0;
            
            nextstate = regd_shift;
        end
        
        mult: begin
        
        pcwritecond = 0;
        pcwrite = 0;
        //sinais dos registradores
        mdrs = 0;
        irwrite = 0;
        regwritesignal = 0;
        regaw = 0;
        regbw = 0;
        regaluwrite = 0;
        epcwrite = 0;
        reghighw = 0;
        regloww = 0;
        //sinais dos mux
		pccondmux = 2'b00;
		iordmux = 3'b000;
        readsmux = 0;
		readdstmux = 2'b00;
		memtoregmux = 3'b000;
        alusrcamux = 0;
		alusrcbmux = 2'b00;
		pcsourcemux = 3'b000;
        reginmux = 0;
        shiftsmux = 0;
        divmultmux = 0;
        multsmux = 0;
        //sinais dos componentes
        wms = 2'b00;    
		memwrite = 0;
		aluop = 3'b000;
        shiftop = 3'b000;
        startdiv = 0;
        
        
        startmult = 1; //carrega o a e b
        
        multo = 0;
            
        nextstate = mult2;
        end
    
        mult2: begin
        
        pcwritecond = 0;
        pcwrite = 0;
        //sinais dos registradores
        mdrs = 0;
        irwrite = 0;
        regwritesignal = 0;
        regaw = 0;
        regbw = 0;
        regaluwrite = 0;
        epcwrite = 0;
        reghighw = 0;
        regloww = 0;
        //sinais dos mux
		pccondmux = 2'b00;
		iordmux = 3'b000;
        readsmux = 0;
		readdstmux = 2'b00;
		memtoregmux = 3'b000;
        alusrcamux = 0;
		alusrcbmux = 2'b00;
		pcsourcemux = 3'b000;
        reginmux = 0;
        shiftsmux = 0;
        divmultmux = 0;
        multsmux = 0;
        //sinais dos componentes
        wms = 2'b00;    
		memwrite = 0;
		aluop = 3'b000;
        shiftop = 3'b000;
        startdiv = 0;
        
        startmult = 0;
        
        multo = 0;
        
        if(multstop == 0) begin
			nextstate = mult2;
		end else begin
			nextstate = mult3;
		end 
        end
        
        mult3: begin
        
        pcwritecond = 0;
        pcwrite = 0;
        //sinais dos registradores
        mdrs = 0;
        irwrite = 0;
        regwritesignal = 0;
        regaw = 0;
        regbw = 0;
        regaluwrite = 0;
        epcwrite = 0;
        reghighw = 1;
        regloww = 1;
        //sinais dos mux
		pccondmux = 2'b00;
		iordmux = 3'b000;
        readsmux = 0;
		readdstmux = 2'b00;
		memtoregmux = 3'b000;
        alusrcamux = 0;
		alusrcbmux = 2'b00;
		pcsourcemux = 3'b000;
        reginmux = 0;
        shiftsmux = 0;
        divmultmux = 1;
        multsmux = 0;
        //sinais dos componentes
        wms = 2'b00;    
		memwrite = 0;
		aluop = 3'b000;
        shiftop = 3'b000;
        startdiv = 0;
        startmult = 0;
        multo = 0;
            
        nextstate = fetch;
        end
        
        div: begin
		
		pcwritecond = 0;
        pcwrite = 0;
        //sinais dos registradores
        mdrs = 0;
        irwrite = 0;
        regwritesignal = 0;
        regaw = 0;
        regbw = 0;
        regaluwrite = 0;
        epcwrite = 0;
        reghighw = 0;
        regloww = 0;
        //sinais dos mux
		pccondmux = 2'b00;
		iordmux = 3'b000;
        readsmux = 0;
		readdstmux = 2'b00;
		memtoregmux = 3'b000;
        alusrcamux = 0;
		alusrcbmux = 2'b00;
		pcsourcemux = 3'b000;
        reginmux = 0;
        shiftsmux = 0;
        divmultmux = 0;
        multsmux = 0;
        //sinais dos componentes
        wms = 2'b00;    
		memwrite = 0;
		aluop = 3'b000;
        shiftop = 3'b000;
        startdiv = 1;
        startmult = 0; //carrega o a e b
        
        multo = 0;
            
        nextstate = div2;
		
		end
		
		div2: begin
		
		pcwritecond = 0;
        pcwrite = 0;
        //sinais dos registradores
        mdrs = 0;
        irwrite = 0;
        regwritesignal = 0;
        regaw = 0;
        regbw = 0;
        regaluwrite = 0;
        epcwrite = 0;
        reghighw = 0;
        regloww = 0;
        //sinais dos mux
		pccondmux = 2'b00;
		iordmux = 3'b000;
        readsmux = 0;
		readdstmux = 2'b00;
		memtoregmux = 3'b000;
        alusrcamux = 0;
		alusrcbmux = 2'b00;
		pcsourcemux = 3'b000;
        reginmux = 0;
        shiftsmux = 0;
        divmultmux = 0;
        multsmux = 0;
        //sinais dos componentes
        wms = 2'b00;    
		memwrite = 0;
		aluop = 3'b000;
        shiftop = 3'b000;
        startdiv = 0;
        startmult = 0; //carrega o a e b
        
        multo = 0;
            
		if(divzero == 1) begin
			nextstate = div_zero;
		end 
		else begin
			if(divstop == 0) begin
				nextstate = div2;
			end else begin
					nextstate = div3;
			end
		end
		
		end
		
		div3: begin
        
        pcwritecond = 0;
        pcwrite = 0;
        //sinais dos registradores
        mdrs = 0;
        irwrite = 0;
        regwritesignal = 0;
        regaw = 0;
        regbw = 0;
        regaluwrite = 0;
        epcwrite = 0;
        reghighw = 1;
        regloww = 1;
        //sinais dos mux
		pccondmux = 2'b00;
		iordmux = 3'b011;
        readsmux = 0;
		readdstmux = 2'b00;
		memtoregmux = 3'b000;
        alusrcamux = 0;
		alusrcbmux = 2'b00;
		pcsourcemux = 3'b000;
        reginmux = 0;
        shiftsmux = 0;
        divmultmux = 0;
        multsmux = 0;
        //sinais dos componentes
        wms = 2'b00;    
		memwrite = 0;
		aluop = 3'b000;
        shiftop = 3'b000;
        startdiv = 0;
        startmult = 0; //carrega o a e b
        
        multo = 0;
        
        nextstate = fetch;
        
        end
        
        
        div_zero: begin
        
        pcwritecond = 0;
        pcwrite = 0;
        //sinais dos registradores
        mdrs = 0;
        irwrite = 0;
        regwritesignal = 0;
        regaw = 0;
        regbw = 0;
        regaluwrite = 0;
        epcwrite = 0;
        reghighw = 0;
        regloww = 0;
        //sinais dos mux
		pccondmux = 2'b00;
		iordmux = 3'b011;
        readsmux = 0;
		readdstmux = 2'b00;
		memtoregmux = 3'b000;
        alusrcamux = 0;
		alusrcbmux = 2'b00;
		pcsourcemux = 3'b000;
        reginmux = 0;
        shiftsmux = 0;
        divmultmux = 0;
        multsmux = 0;
        //sinais dos componentes
        wms = 2'b00;    
		memwrite = 0;
		aluop = 3'b000;
        shiftop = 3'b000;
        startdiv = 0;
        startmult = 0; //carrega o a e b
        
        multo = 0;
        
        nextstate = div_stall;
        
        end
                
        div_stall: begin
        
        pcwritecond = 0;
        pcwrite = 0;
        //sinais dos registradores
        mdrs = 0;
        irwrite = 0;
        regwritesignal = 0;
        regaw = 0;
        regbw = 0;
        regaluwrite = 0;
        epcwrite = 0;
        reghighw = 0;
        regloww = 0;
        //sinais dos mux
		pccondmux = 2'b00;
		iordmux = 3'b011;
        readsmux = 0;
		readdstmux = 2'b00;
		memtoregmux = 3'b000;
        alusrcamux = 0;
		alusrcbmux = 2'b00;
		pcsourcemux = 3'b000;
        reginmux = 0;
        shiftsmux = 0;
        divmultmux = 0;
        multsmux = 0;
        //sinais dos componentes
        wms = 2'b00;    
		memwrite = 0;
		aluop = 3'b000;
        shiftop = 3'b000;
        startdiv = 0;
        startmult = 0; //carrega o a e b
        
        multo = 0;
        
        nextstate = div_stall2;
        
        end
        
        
        div_stall2: begin
        
        pcwritecond = 0;
        pcwrite = 0;
        //sinais dos registradores
        mdrs = 1;
        irwrite = 0;
        regwritesignal = 0;
        regaw = 0;
        regbw = 0;
        regaluwrite = 0;
        epcwrite = 0;
        reghighw = 0;
        regloww = 0;
        //sinais dos mux
		pccondmux = 2'b00;
		iordmux = 3'b011;
        readsmux = 0;
		readdstmux = 2'b00;
		memtoregmux = 3'b000;
        alusrcamux = 0;
		alusrcbmux = 2'b00;
		pcsourcemux = 3'b000;
        reginmux = 0;
        shiftsmux = 0;
        divmultmux = 0;
        multsmux = 0;
        //sinais dos componentes
        wms = 2'b00;    
		memwrite = 0;
		aluop = 3'b000;
        shiftop = 3'b000;
        startdiv = 0;
        startmult = 0; //carrega o a e b
        
        multo = 0;
        
        nextstate = ov_pc;
        
        end
        
        
        noop_load: begin
          pcwritecond = 0;
        pcwrite = 0;
        //sinais dos registradores
        mdrs = 0;
        irwrite = 0;
        regwritesignal = 0;
        regaw = 0;
        regbw = 0;
        regaluwrite = 0;
        epcwrite = 0;
        reghighw = 0;
        regloww = 0;
        //sinais dos mux
		pccondmux = 2'b00;
		iordmux = 3'b001;
        readsmux = 0;
		readdstmux = 2'b00;
		memtoregmux = 3'b000;
        alusrcamux = 0;
		alusrcbmux = 2'b00;
        pcsourcemux = 3'b000;
        reginmux = 0;
        shiftsmux = 0;
        divmultmux = 0;
        multsmux = 0;
        //sinais dos componentes
        wms = 2'b00;     
		memwrite = 0;
		aluop = 3'b000;
        shiftop = 3'b000;
        startdiv = 0;     
        startmult = 0;
        
        multo = 0;
            
        nextstate = noop_wait_;
        end
        
        noop_wait_: begin
        pcwritecond = 0;
        pcwrite = 0;
        //sinais dos registradores
        mdrs = 0;
        irwrite = 0;
        regwritesignal = 0;
        regaw = 0;
        regbw = 0;
        regaluwrite = 0;
        epcwrite = 0;
        reghighw = 0;
        regloww = 0;
        //sinais dos mux
		pccondmux = 2'b00;
		iordmux = 3'b000;
        readsmux = 0;
		readdstmux = 2'b00;
		memtoregmux = 3'b000;
        alusrcamux = 0;
		alusrcbmux = 2'b00;
        pcsourcemux = 3'b000;
        reginmux = 0;
        shiftsmux = 0;
        divmultmux = 0;
        multsmux = 0;
        //sinais dos componentes
        wms = 2'b00;      
		memwrite = 0;
		aluop = 3'b000;
        shiftop = 3'b000;
        startdiv = 0;
        
        
        startmult = 0;
        
        multo = 0;
            
        nextstate = noop_wait2;
        end
        
        noop_wait2: begin
        pcwritecond = 0;
        pcwrite = 0;
        //sinais dos registradores
        mdrs = 1;
        irwrite = 0;
        regwritesignal = 0;
        regaw = 0;
        regbw = 0;
        regaluwrite = 0;
        epcwrite = 0;
        reghighw = 0;
        regloww = 0;
        //sinais dos mux
		pccondmux = 2'b00;
		iordmux = 3'b000;
        readsmux = 0;
		readdstmux = 2'b00;
		memtoregmux = 3'b000;
        alusrcamux = 0;
		alusrcbmux = 2'b00;
        pcsourcemux = 3'b000;
        reginmux = 0;
        shiftsmux = 0;
        divmultmux = 0;
        multsmux = 0;
        //sinais dos componentes
        wms = 2'b00;
        
		memwrite = 0;
		aluop = 3'b000;
        shiftop = 3'b000;
        startdiv = 0;
        
        
        startmult = 0;
        
        multo = 0;
            
        nextstate = noop_pc;
        end
        
        noop_pc: begin
        pcwritecond = 0;
        pcwrite = 1;
        //sinais dos registradores
        mdrs = 0;
        irwrite = 0;
        regwritesignal = 0;
        regaw = 0;
        regbw = 0;
        regaluwrite = 0;
        epcwrite = 0;
        reghighw = 0;
        regloww = 0;
        //sinais dos mux
      pccondmux = 2'b00;
		iordmux = 3'b000;
        readsmux = 0;
		readdstmux = 2'b00;
		memtoregmux = 3'b000;
        alusrcamux = 0;
		alusrcbmux = 2'b00;
        pcsourcemux = 3'b100;
        reginmux = 0;
        shiftsmux = 0;
        divmultmux = 0;
        multsmux = 0;
        //sinais dos componentes
        wms = 2'b10; 
		memwrite = 0;
		aluop = 3'b000;
        shiftop = 3'b000;
        startdiv = 0;
        startmult = 0;
        
        multo = 0;
                  
        nextstate = fetch;
        end
  endcase
  end
endmodule: Control
   