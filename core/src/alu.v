`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/08/17 00:40:01
// Design Name: 
// Module Name: alu
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module alu (
    input [7:0] A_ip, B_ip,
	input CF_ip,
	input [4:0] SEL_ip,
	output [7:0] O_op,
	output CF_op,
	output ZF_op);


	wire [8:0] alu_sum_i, alu_sub_i;
	wire [7:0] alu_and_i, alu_or_i, alu_not_i, alu_xor_i;
	wire [7:0] alu_bs_i, alu_bc_i;


	assign alu_sum_i = {1'b0, A_ip} + {1'b0, B_ip} + {7'b0000000, CF_ip};
	assign alu_sub_i = {1'b0, A_ip} - {1'b0, B_ip} + {7'b0000000, CF_ip};

	assign alu_and_i = A_ip & B_ip;
	assign alu_or_i = A_ip | B_ip;
	assign alu_not_i = ~ A_ip;
	assign alu_xor_i = A_ip ^ B_ip;

	assign alu_bs_i = A_ip & B_ip;
	assign alu_bc_i = A_ip & (~ B_ip);


	assign O_op = SEL_ip==5'b00000 ? alu_sum_i[7:0]:
			      SEL_ip==5'b00001 ? alu_sub_i[7:0]:
				  SEL_ip==5'b00010 ? alu_and_i:
				  SEL_ip==5'b00011 ? alu_or_i:
				  SEL_ip==5'b00100 ? alu_not_i:
				  SEL_ip==5'b00101 ? alu_xor_i:
				  SEL_ip==5'b00110 ? alu_bs_i:
				  SEL_ip==5'b00111 ? alu_bc_i:
				  SEL_ip==5'b01000 ? A_ip:
				  SEL_ip==5'b01001 ? B_ip: 8'h0;

 
	assign CF_op = SEL_ip==5'b00000 ? alu_sum_i[8]:
				   SEL_ip==5'b00001 ? alu_sub_i[8]: 1'b0;


	assign ZF_op = O_op==8'h0 ? 1'b1: 1'b0;
				   

endmodule
