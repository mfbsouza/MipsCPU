module Control (
	input clk,
);

enum logic [meme:mene] {
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
}

endmodule: Control