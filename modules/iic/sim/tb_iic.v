`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/09/18 22:35:05
// Design Name: 
// Module Name: tb_iic
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


module tb_iic();

    parameter PERIOD = 10;
        
    reg clk, reset_n;
    wire busy, sending;
    reg start, stop, rw;
    reg [7:0] din;
    wire [7:0] dout;
    wire sck, sda;
    
    always begin
       clk = 1'b0;
       #(PERIOD/2) clk = 1'b1;
       #(PERIOD/2);
    end
    
    iic_core uut(
        .clock(clk),
        .reset_n(reset_n),
        .busy(busy),
        .sending(sending),
        .start(start),
        .stop(stop),
        .rw(rw),
        .din(din),
        .dout(dout),
        .sck(sck),
        .sda(sda)
    );
    
    initial begin
        reset_n <= 1'b1;
        start <= 1'b0;
        stop  <= 1'b0;
        rw    <= 1'b0;
        #PERIOD;
        reset_n <= 1'b0;
        #PERIOD;
        reset_n <= 1'b1;
        #PERIOD;
        start <= 1'b1;
        din <= 8'hAA;
        #(PERIOD);
        start <= 1'b0;
        #(PERIOD * 20);
        start <= 1'b1;
        din <= 8'h55;
        #(PERIOD);
        start <= 1'b0;
        #(PERIOD * 20);
        stop <= 1'b1;
        #(PERIOD);
        stop <= 1'b0;
        #(PERIOD * 30);
    end

endmodule
