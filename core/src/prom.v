`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/08/17 00:56:26
// Design Name: 
// Module Name: prom
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


module prom (
    input CLK_ip,
	input [12:0] ADDR_ip,
	output [14:0] DATA_op);


	assign DATA_op = ADDR_ip==13'd0 ? 15'b010111000000001:
    				 ADDR_ip==13'd1 ? 15'b010110000000011:
    				 ADDR_ip==13'd2 ? 15'b110000000001010:
    				 ADDR_ip==13'd3 ? 15'b000000000000000:
    				 ADDR_ip==13'd4 ? 15'b110000000010100:
    				 ADDR_ip==13'd5 ? 15'b000000000000000:
    				 ADDR_ip==13'd6 ? 15'b000000000000000:
    				 ADDR_ip==13'd7 ? 15'b000000000000000:
    				 ADDR_ip==13'd8 ? 15'b000000000000000:
    				 ADDR_ip==13'd9 ? 15'b000000000000000:
    				 ADDR_ip==13'd10 ? 15'b010111000000001:
    				 ADDR_ip==13'd11 ? 15'b010110000001010:
    				 ADDR_ip==13'd12 ? 15'b010111000000000:
    				 ADDR_ip==13'd13 ? 15'b010000000001010:
    				 ADDR_ip==13'd14 ? 15'b110000000001101:
    				 ADDR_ip==13'd15 ? 15'b000000000000000:
    				 ADDR_ip==13'd16 ? 15'b000000000000000:
    				 ADDR_ip==13'd17 ? 15'b000000000000000:
    				 ADDR_ip==13'd18 ? 15'b000000000000000:
    				 ADDR_ip==13'd19 ? 15'b000000000000000:
    				 ADDR_ip==13'd20 ? 15'b010111000000001:
    				 ADDR_ip==13'd21 ? 15'b010110000000011:
    				 ADDR_ip==13'd22 ? 15'b000001000000000:
    				 ADDR_ip==13'd23 ? 15'b000000000000000:
    				 ADDR_ip==13'd24 ? 15'b000000100000000:
    				                   15'b000000000000000;


endmodule