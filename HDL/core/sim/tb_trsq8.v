`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/08/17 03:05:33
// Design Name: 
// Module Name: tb_trsq8
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


module tb_trsq8(

    );
    
    parameter PERIOD = 10;
    
    reg clk, reset, irq;
    
    always begin
       clk = 1'b0;
       #(PERIOD/2) clk = 1'b1;
       #(PERIOD/2);
    end
    
    TRSQ8 uut(
        .clk(clk),
        .reset_n(reset),
        .irq(irq)
    );
    
    initial begin
        reset <= 1'b1;
        irq <= 1'b0;
        #PERIOD;
        reset <= 1'b0;
        #PERIOD;
        reset <= 1'b1;
        #(PERIOD * 30);
        // $stop;
    end
    
endmodule
