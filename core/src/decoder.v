`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 2017/08/17 00:44:22
// Module Name: decoder
// Project Name: TRSQ8
//////////////////////////////////////////////////////////////////////////////////


module decoder (
    input [14:0] data_ip,
	output [4:0] alu_sel_op,
	output [1:0] sk_sel_op,
	output muxa_sel_op, muxb_sel_op,
	output [7:0] sram_addr_op,
	output sram_ld_op, sram_st_op, nop_op, halt_op, return_op, jump_op);


	assign alu_sel_op = data_ip[14:8] == 7'b0100000 ? 5'b00000: // ADD
					 	data_ip[14:8] == 7'b0100001 ? 5'b00001: // SUB
					 	data_ip[14:8] == 7'b0100111 ? 5'b00010: // AND
					 	data_ip[14:8] == 7'b0101000 ? 5'b00011: // OR
					 	data_ip[14:8] == 7'b0101001 ? 5'b00100: // NOT
					 	data_ip[14:8] == 7'b0101011 ? 5'b00101: // XOR
					 	data_ip[14:8] == 7'b0101100 ? 5'b01001: // ST
					 	data_ip[14:8] == 7'b0101101 ? 5'b01000: // LD
					 	data_ip[14:8] == 7'b0101110 ? 5'b01000: // LDL
					 	                              5'b11111;					 						 	


	assign sk_sel_op = data_ip[14:8] == 7'b0000101 ? 2'b01: // SKZ
					   data_ip[14:8] == 7'b0000110 ? 2'b10: // SKC
					                                 2'b00;


	assign muxa_sel_op = data_ip[14:8] == 7'b0101110 ? 1'b1: // Read from Literal
	                                                   1'b0; // Read from File Regs

	assign muxb_sel_op = data_ip[14:13] == 2'b10 ? 1'b1: // Bit instruction
	                                               1'b0; // from W


	assign sram_addr_op = data_ip[14:13] == 2'b01 ? data_ip[7:0]:
					 	  data_ip[14:13] == 2'b10 ? data_ip[7:0]:
					 	                            8'h00;


	assign sram_ld_op = data_ip[14:8] == 7'b0101101 ? 1'b1: 1'b0;
	assign sram_st_op = data_ip[14:8] == 7'b0101100 ? 1'b1: 1'b0;
	
	assign nop_op    = data_ip[14:8] == 7'b0000000 ? 1'b1: 1'b0;
	assign halt_op   = data_ip[14:8] == 7'b0000001 ? 1'b1: 1'b0;
	assign return_op = data_ip[14:8] == 7'b0000010 ? 1'b1: 1'b0;

	assign jump_op = data_ip[14:13]==2'b11 ? 1'b1: 1'b0;

endmodule
