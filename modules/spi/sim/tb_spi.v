`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/08/30 00:09:57
// Design Name: 
// Module Name: tb_spi
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


module tb_spi(

    );
    
    parameter PERIOD = 10;
        
    reg clk, reset_n, enable;
    wire sclk, mosi, busy;
    reg miso;
    wire [0:0] ss_n;
    wire [7:0] rx_data;
    
    always begin
       clk = 1'b0;
       #(PERIOD/2) clk = 1'b1;
       #(PERIOD/2);
    end
    
    spi_core #(
        .slaves(1),
        .d_width(8)
    ) uut (
        .clock(clk),
        .reset_n(reset_n),
        .enable(enable),
        .cpol(1),
        .cpha(1),
        .cont(0),
        .clk_div(0),
        .addr(0),
        .tx_data(8'h1B),
        .miso(miso),
        .sclk(sclk),
        .ss_n(ss_n),
        .mosi(mosi),
        .busy(busy),
        .rx_data(rx_data)
    );
    
    initial begin
        enable <= 1'b0;
        reset_n <= 1'b1;
        miso <= 1'b0;
        #PERIOD;
        reset_n <= 1'b0;
        #PERIOD;
        reset_n <= 1'b1;
        #PERIOD;
        enable <= 1'b1;
        #(PERIOD * 2);
        enable <= 1'b0;
        #(PERIOD * 30);
    end
    
endmodule
