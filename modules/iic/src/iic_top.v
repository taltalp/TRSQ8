`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 2017/09/20 22:41:14
// Module Name: iic_top
// Project Name: TRSQ8
//////////////////////////////////////////////////////////////////////////////////


module iic_top #(
    parameter ADDR_LSB = 0,
    parameter OPT_MEM_ADDR_BITS = 1
    )(
    input clk, reset_n,
    
    // CPU Interface
    input [7:0] addr, din,
    output reg [7:0] dout,
    input wr_en, rd_en,
    
    // IIC Interface
    output sck,
    inout  sda
    );
    
    wire busy, sending;
    wire start, stop, rw;
    
    reg [7:0] iic_din;
    wire [7:0] iic_dout;
    
    
    wire [OPT_MEM_ADDR_BITS:0] loc_addr = addr[ADDR_LSB + OPT_MEM_ADDR_BITS:ADDR_LSB];
    always @(posedge clk) begin
        if (wr_en) begin
            case (loc_addr)

                default : begin : wr_def

                          end
            endcase
        end else if (rd_en) begin
            case (loc_addr)

                default : dout <= 8'h00;
            endcase
        end
    end
    
    iic_core iic_core_inst
    (
        .clock(clk),
        .reset_n(reset_n),
        .busy(busy),
        .sending(sending),
        .start(start),
        .stop(stop),
        .rw(rw),
        .din(iic_din),
        .dout(iic_dout),
        .sck(sck),
        .sda(sda)
    );
    
endmodule