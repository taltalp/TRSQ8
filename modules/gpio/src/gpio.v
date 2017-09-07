`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/09/07 18:15:28
// Design Name: 
// Module Name: gpio
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


module gpio #(
    parameter ADDR_LSB = 0,
    parameter OPT_MEM_ADDR_BITS = 1,
    parameter BASE_ADDR = 8'h80
    )(
    input clk, reset_n,
    
    // CPU Interface
    input [7:0] addr, din,
    output reg [7:0] dout,
    input wr_en, rd_en,
    
    // SPI Interface
    inout [7:0] port
    );
    
    reg [7:0] TRIS, OGPIO, IGPIO, DUMMY;
    
    wire [OPT_MEM_ADDR_BITS:0] loc_addr = addr[ADDR_LSB + OPT_MEM_ADDR_BITS:ADDR_LSB];
    always @(posedge clk) begin
        if (wr_en == 1'b1) begin
            case (loc_addr)
                2'b00 : TRIS <= din;
                2'b01 : OGPIO <= din;
                // 2'b10 : IGPIO <= din;
                // 2'b11 : DUMMY <= din;
                default : begin : wr_def
                          TRIS <= TRIS;
                          OGPIO <= OGPIO;
                          end
            endcase
        end else if (rd_en == 1'b1) begin
            case (loc_addr)
                2'b00 : dout <= TRIS;
                2'b01 : dout <= OGPIO;
                2'b10 : dout <= IGPIO;
                // 2'b11 : dout <= DUMMY;
                default : dout <= 8'h00;
            endcase
        end
    end
    
endmodule