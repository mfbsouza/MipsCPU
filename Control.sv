module Control (
	input clk,
);

enum logic [meme:mene] {

	//Our Control Unit looks like an H

	//dentro do H - superior centro
	Reset=
	Fetch=
	Wait=
	Decode=
	//lado esquerdo
	Beq_compare=
	Bne_compare=
	Ble_compare=
	Bgt_compare=
	LW_address=
	LW_memory=
	LW_wait=
	LW_write=
	SW_address=
	SW_memory=
	SW_wait=
	SW_write=
	Lui_load=
	J_jump=
	Jal=
	saveEjump=
	LH_address=
	LH_memory=
	LH_wait=
	LH_write=
	LB_address=
	LB_memory=
	LB_wait=
	LB_write=
	SH_address=
	SH_memory=
	SH_wait
	SH_write=
	SB_address=
	SB_memory=
	SB_wait
	SB_write=
	Slti=
	RegT_Write_slti=
	Addiu=
	Addi=
	RegT_Write=

	//dentro do H -  inferior - esquerdo

	noop_load=
	noop_wait=
	noop_pc=

	//dentro do H  - inferior - direito

	Push=
	NewRA= //New_$RA
	SaveRA_write= //Save_$RA & WriteMem

	Pop=
	Address= //endereço
	readAddres= //ler endereço
	Stall=
	Save_Reg= //guarda no registrador
	New_pointer//novo ponteiro
	UpdateRA= //Atualiza $ra

	Rte= 

	//lado direito

	Mflo=
	Mfhi=
	Jr=
	Break=
	Slt=
	RegD_write_slt=
	SUb=
	And=
	Add=
	RegD_write=

	ShiftShamt=
	sll=
	srl=
	sra=

	ShiftShamt=
	sllv=
	srav=

	RegD_Shift=

	Div=
	HliLoD=
	Mult=
	HliLoM=

	//dentro de H - superior - direito

	Div_Zero=
	Div_Stall=
	noop_load=
	noop_wait=
	noop_pc=


}

endmodule: Control
