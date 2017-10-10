`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 2017/08/23 21:51:14
// Module Name: spi_top
// Project Name: TRSQ8
//////////////////////////////////////////////////////////////////////////////////


module spi_top #(
        parameter BASE_ADDR = 8'h80,
        parameter LAST_ADDR = 8'h83
    )(
    input clk, reset_n,
    
    // CPU Interface
    input [7:0] addr, dout,
    output [7:0] din,
    input wr_en, rd_en,
    
    // SPI Interface
    output sclk, mosi,
    input miso,
    output [0:0] ss_n
    );
    
    localparam integer ADDR_LSB = 0;
    localparam integer OPT_MEM_ADDR_BITS = 1;
    
    wire spi_busy, spi_rx;
    reg  spi_enable, spi_busy_tmp;
    reg [7:0] SPICON    = 8'h00; 
    reg [7:0] SPICLKDIV = 8'h00; 
    reg [7:0] SPITX     = 8'h00;
    reg [7:0] SPIRX     = 8'h00;
    
    reg [7:0] spi_dout;
    wire [7:0] spi_addr, spi_din;
    wire spi_wr_en, spi_rd_en;
    
    assign din = (addr >= BASE_ADDR & addr <= LAST_ADDR) ? spi_dout : 8'hZZ;
    assign spi_addr = addr;
    assign spi_din = dout;
    assign spi_wr_en = (addr >= BASE_ADDR & addr <= LAST_ADDR) ? wr_en : 1'b0;
    assign spi_rd_en = (addr >= BASE_ADDR & addr <= LAST_ADDR) ? rd_en : 1'b0;
    
    initial begin
        spi_dout = 8'h0;
    end
    
    wire [OPT_MEM_ADDR_BITS:0] loc_addr = spi_addr[ADDR_LSB + OPT_MEM_ADDR_BITS:ADDR_LSB];
    always @(clk) begin
        if (clk == 1'b1) begin
            if (spi_wr_en) begin
                case (loc_addr)
                    2'b00 : SPICON <= spi_din;
                    2'b01 : SPICLKDIV <= spi_din;
                    2'b10 : SPITX <= spi_din;
                    2'b11 : SPIRX <= spi_din;
                    default : begin : wr_def
                              SPICON <= SPICON;
                              SPICLKDIV <= SPICLKDIV;
                              SPITX <= SPITX;
                              SPIRX <= SPIRX;
                              end
                endcase
            end else if (spi_rd_en) begin
                case (loc_addr)
                    2'b00 : spi_dout <= SPICON;
                    2'b01 : spi_dout <= SPICLKDIV;
                    2'b10 : spi_dout <= SPITX;
                    2'b11 : spi_dout <= SPIRX;
                    default : spi_dout <= 8'h00;
                endcase
            end
        end else if (clk == 1'b0) begin
//            spi_enable <= SPICON[4];
            // Clear enable flag automatically
            if (spi_busy == 1'b1 & SPICON[4] == 1'b1) begin
                SPICON <= {SPICON[7:5], 1'b0, SPICON[3:1], spi_busy};
            end else begin
                SPICON <= {SPICON[7:1], spi_busy};
            end
            SPIRX <= spi_rx;
        end
    end
    
    spi_core 
    #(
        .SLAVES(1),
        .D_WIDTH(8)
    )
    spi_core_inst
    (
        .clock(clk),
        .reset_n(reset_n),
        .enable(SPICON[4]),
        .cpol(SPICON[1]),
        .cpha(SPICON[2]),
        .cont(SPICON[3]),
        .clk_div(0),
        .tx_data(SPITX),
        .miso(miso),
        .sclk(sclk),
        .ss_n(ss_n),
        .mosi(mosi),
        .busy(spi_busy),
        .rx_data(spi_rx)
    );
    
endmodule
