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
    input  irq,
    
    output sclk, mosi,
    input  miso,
    output [0:0] ss_n
    );
    
    wire reset;
    
    wire [7:0] cpu_status;
    
    wire [12:0] prom_addr;
    wire [14:0] prom_data;
    
    wire [7:0] peri_addr;
    wire [7:0] peri_din;
    wire [7:0] peri_dout;
    wire peri_wr_en, peri_rd_en;
    
    reg  [7:0] ram_i [0:255];
    
    wire [7:0] ram_addr;
    wire [7:0] ram_din;
    wire [7:0] ram_dout;
    wire ram_wr_en, ram_rd_en;
    
    // User logic
    wire [7:0] spi_0_addr;
    wire [7:0] spi_0_din;
    wire [7:0] spi_0_dout;
    wire spi_0_wr_en, spi_0_rd_en;
    
    assign reset = ~reset_n;
    
    cpu cpu_inst(
        .clk_ip(clk),
        .reset_n_ip(reset_n),
        .STATUS(cpu_status),
        .prom_addr(prom_addr),
        .prom_data(prom_data),
        .addr(peri_addr),
        .data_in(peri_din),
        .data_out(peri_dout),
        .wr_en(peri_wr_en),
        .rd_en(peri_rd_en),
        .irq_ip(irq)
    );
    
    prom prom_inst(
        .CLK_ip(clk),
        .ADDR_ip(prom_addr),
        .DATA_op(prom_data)
    );
    
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
    
    assign ram_addr = peri_addr;
    assign ram_dout = peri_dout;
    assign ram_wr_en = (peri_addr >= 8'h00 & peri_addr <= 8'h7F) ? 1'b1 : 1'b0;
    assign ram_rd_en = (peri_addr >= 8'h00 & peri_addr <= 8'h7F) ? 1'b1 : 1'b0;
    
    assign peri_din = (peri_addr >= 8'h00 & peri_addr <= 8'h7F) ? ram_din :
                      (peri_addr >= 8'h80 & peri_addr <= 8'h83) ? spi_0_din :
                      8'h00;
                      
    // ADD User Logic 
    assign spi_0_addr = peri_addr;
    assign spi_0_dout = peri_dout;
    assign spi_0_wr_en = (peri_addr >= 8'h80 & peri_addr <= 8'h83) ? 1'b1 : 1'b0;
    assign spi_0_rd_en = (peri_addr >= 8'h80 & peri_addr <= 8'h83) ? 1'b1 : 1'b0;
endmodule
