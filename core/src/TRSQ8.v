`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 2017/08/17 02:29:04
// Module Name: TRSQ8
// Project Name: TRSQ8
//////////////////////////////////////////////////////////////////////////////////


module TRSQ8(
    input  clk, reset,
    // input  irq,
    
    // spi_0_inst
    output spi_0_sclk, spi_0_mosi,
    input  spi_0_miso,
    output [0:0] spi_0_cs,
    // gpio_0_inst
    inout [7:0] gpio_0_port,
    // iic_0_inst
    output iic_0_sck,
    inout  iic_0_sda
    );
    
    wire reset_n;
    
    wire [7:0] cpu_status;
    
    wire [12:0] prom_addr;
    wire [14:0] prom_data;
    
    wire [7:0] peri_addr;
    wire [7:0] peri_din;
    wire [7:0] peri_din_i;
    wire [7:0] peri_dout;
    wire peri_wr_en, peri_rd_en;
    
//    reg  [7:0] ram_i [0:255];
    
    wire [7:0] ram_addr;
    wire [7:0] ram_din;
    wire [7:0] ram_dout;
    wire ram_wr_en, ram_rd_en;
    
    // ===== User logic =====
    // spi_0_inst
    wire [7:0] spi_0_addr;
    wire [7:0] spi_0_din;
    wire [7:0] spi_0_dout;
    wire spi_0_wr_en, spi_0_rd_en;
    // gpio_0_inst
    wire [7:0] gpio_0_addr;
    wire [7:0] gpio_0_din;
    wire [7:0] gpio_0_dout;
    wire gpio_0_wr_en, gpio_0_rd_en;
    // iic_0_inst
    wire [7:0] iic_0_addr;
    wire [7:0] iic_0_din;
    wire [7:0] iic_0_dout;
    wire iic_0_wr_en, iic_0_rd_en;
    
    assign reset_n = ~reset;
    
    cpu cpu_inst(
        .clk_ip(clk),
        .reset_n_ip(reset_n),
        .STATUS(cpu_status),
        .prom_addr(prom_addr),
        .prom_data(prom_data),
        .addr(peri_addr),
        .data_in(peri_din_i),
        .data_out(peri_dout),
        .wr_en(peri_wr_en),
        .rd_en(peri_rd_en),
        //.irq_ip(irq)
        .irq_ip(0)
    );
    
    assign peri_din_i = peri_rd_en ? peri_din : 8'h00;
    
    prom prom_inst(
        .CLK_ip(clk),
        .ADDR_ip(prom_addr),
        .DATA_op(prom_data)
    );
    
    ram ram_inst(
        .clk(clk),
        .reset_n(reset_n),
        .addr(peri_addr),
        .dout(peri_dout),
        .din(peri_din),
        .wr_en(peri_wr_en),
        .rd_en(peri_rd_en),
        .cpu_status(cpu_status)
        );
    
    // gpio_0_inst
    gpio #(
        .BASE_ADDR(8'h84),
        .LAST_ADDR(8'h87)
    )gpio_0_inst(
        .clk(clk), 
        .reset_n(reset_n),
        
        // CPU Interface
        .addr(peri_addr),
        .din(peri_din),
        .dout(peri_dout),
        .wr_en(peri_wr_en),
        .rd_en(peri_rd_en),
        
        // GPIO Interface
        .port(gpio_0_port)
    );
    
    // spi_0_inst
    spi_top #(
        .BASE_ADDR(8'h80),
        .LAST_ADDR(8'h83)
    )spi_0_inst(
        .clk(clk),
        .reset_n(reset_n),
        
        // CPU Interface
        .addr(peri_addr),
        .din(peri_din),
        .dout(peri_dout),
        .wr_en(peri_wr_en),
        .rd_en(peri_rd_en),
        
        // SPI Interface
        .sclk(spi_0_sclk),
        .mosi(spi_0_mosi),
        .miso(spi_0_miso),
        .ss_n(spi_0_cs)
    );
    
    // iic_0_inst
    iic_top #(
        .BASE_ADDR(8'h90),
        .LAST_ADDR(8'h93)
    )iic_0_inst(
        .clk(clk),
        .reset_n(reset_n),
        
        // CPU Interface
        .addr(peri_addr),
        .din(peri_din),
        .dout(peri_dout),
        .wr_en(peri_wr_en),
        .rd_en(peri_rd_en),
        
        // IIC Interface
        .sck(iic_0_sck),
        .sda(iic_0_sda)
    );
    
    ila_1 TRSQ_ila (
        .clk(clk), // input wire clk
    
        .probe0(peri_addr), // input wire [7:0]  probe1 
        .probe1(peri_din), // input wire [7:0]  probe1 
        .probe2(peri_dout), // input wire [7:0]  probe1 
        .probe3(peri_wr_en), // input wire [7:0]  probe1 
        .probe4(peri_rd_en) // input wire [7:0]  probe1 
    );
endmodule
