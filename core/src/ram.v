`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/10/04 23:59:43
// Design Name: 
// Module Name: ram
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


module ram(
    input clk,
    input reset_n,
    
    // CPU Interface
    input [7:0] addr, dout,
    output[7:0] din,
    input wr_en, rd_en,
    
    input cpu_status
    );
    
    localparam BASE_ADDR = 8'h00;
    localparam LAST_ADDR = 8'h7F;
    
    wire reset;
    wire [7:0] ram_addr, ram_din;
    wire ram_wr_en, ram_rd_en;
    reg  [7:0] ram_dout;
    reg  [7:0] ram_i [0:255];
    
    assign reset = ~reset_n;
    
        // RAM
    always @ (posedge clk) begin
        if (reset == 1'b1) begin : init_mem
            integer i;
            for (i=0;i<256;i=i+1) begin
                ram_i[i] <= 8'h00;
            end
        end else begin
            ram_i[0] <= cpu_status;
                
            if (ram_wr_en == 1'b1) begin
                if (ram_addr != 8'h00) begin
                    ram_i[ram_addr] <= ram_dout;
                end
            end
        end    
    end
    assign ram_din = ram_i[ram_addr];
    
    // ===== Interconnect =====
    assign din = (addr >= BASE_ADDR & addr <= LAST_ADDR) ? ram_dout : 8'hZZ;
    assign ram_addr = addr;
    assign ram_din = dout;
    assign ram_wr_en = (addr >= BASE_ADDR & addr <= LAST_ADDR) ? wr_en : 1'b0;
    assign ram_rd_en = (addr >= BASE_ADDR & addr <= LAST_ADDR) ? rd_en : 1'b0;
    
endmodule
