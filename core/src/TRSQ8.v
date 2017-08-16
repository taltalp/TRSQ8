`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/08/17 02:29:04
// Design Name: 
// Module Name: TRSQ8
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


module TRSQ8(
    input  clk, reset_n,
    input  irq
    );
    
    wire reset;
    wire [12:0] prom_addr;
    wire [14:0] prom_data;
    
    wire [7:0] ram_addr;
    wire [7:0] ram_data_in;
    wire [7:0] ram_data_out;
    
    assign reset = ~reset_n;
    
    cpu cpu_inst(
        .clk_ip(clk),
        .reset_n_ip(reset_n),
        .prom_addr(prom_addr),
        .prom_data(prom_data),
        .addr(ram_addr),
        .data_in(8'h00),
        .data_out(ram_data_out),
        .irq_ip(irq)
    );
    
    prom prom_inst(
        .CLK_ip(clk),
        .ADDR_ip(prom_addr),
        .DATA_op(prom_data)
    );
endmodule
