`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/08/29 23:56:34
// Design Name: 
// Module Name: tb_spi_top
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


module tb_spi_top(

    );
    
    parameter PERIOD = 10;
    
    reg clk, reset_n;
    reg [7:0] addr, din;
    wire [7:0] dout;
    reg wr_en, rd_en;
    
    wire sclk, mosi;
    reg miso;
    wire [0:0] ss_n;
    
    always begin
       clk = 1'b0;
       #(PERIOD/2) clk = 1'b1;
       #(PERIOD/2);
    end
    
    spi_top #(
        .ADDR_LSB(0),
        .OPT_MEM_ADDR_BITS(1),
        .BASE_ADDR(8'h80)
        ) uut (
        .clk(clk),
        .reset_n(reset_n),
        
        // CPU Interface
        .addr(addr), 
        .din(din),
        .dout(dout),
        .wr_en(wr_en),
        .rd_en(rd_en),
        
        // SPI Interface
        .sclk(sclk),
        .mosi(mosi),
        .miso(miso),
        .ss_n(ss_n)
        );
    
    initial begin
        reset_n <= 1'b1;
        addr <= 8'h00;
        din <= 8'h00;
        wr_en <= 1'b0;
        rd_en <= 1'b0;
        #(PERIOD * 2);
        reset_n <= 1'b0;
        #PERIOD;
        reset_n <= 1'b1;
        #PERIOD;
        addr <= 8'h02;
        din <= 8'hA1;
        wr_en <= 1'b1;
        #PERIOD;
        wr_en <= 1'b0;
        #PERIOD;
        addr <= 8'h00;
        din <= 8'h10;
        wr_en <= 1'b1;
        #PERIOD;
        wr_en <= 1'b0;
        #(PERIOD * 5);
        addr <= 8'h00;
        rd_en <= 1'b1;
        #PERIOD;
        rd_en <= 1'b0;
        #(PERIOD * 30);
    end
endmodule
