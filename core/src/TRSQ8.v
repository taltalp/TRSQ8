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
    wire [7:0] peri_dout;
    wire peri_wr_en, peri_rd_en;
    
    reg  [7:0] ram_i [0:255];
    
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
        .data_in(peri_din),
        .data_out(peri_dout),
        .wr_en(peri_wr_en),
        .rd_en(peri_rd_en),
        //.irq_ip(irq)
        .irq_ip(0)
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
    
    // ===== Interconnect =====
    assign ram_addr = peri_addr;
    assign ram_dout = peri_dout;
    assign ram_wr_en = (peri_addr >= 8'h00 & peri_addr <= 8'h7F) ? peri_wr_en : 1'b0;
    assign ram_rd_en = (peri_addr >= 8'h00 & peri_addr <= 8'h7F) ? peri_rd_en : 1'b0;
    
    assign peri_din = (peri_addr >= 8'h00 & peri_addr <= 8'h7F) ? ram_din :
                      (peri_addr >= 8'h80 & peri_addr <= 8'h83) ? spi_0_din :
                      (peri_addr >= 8'h84 & peri_addr <= 8'h87) ? gpio_0_din :
                      (peri_addr >= 8'h90 & peri_addr <= 8'h93) ? iic_0_din :
                      8'h00;
    
    // spi_0_inst
    assign spi_0_addr = peri_addr;
    assign spi_0_dout = peri_dout;
    assign spi_0_wr_en = (peri_addr >= 8'h80 & peri_addr <= 8'h83) ? peri_wr_en : 1'b0;
    assign spi_0_rd_en = (peri_addr >= 8'h80 & peri_addr <= 8'h83) ? peri_rd_en : 1'b0;
    // gpio_0_inst
    assign gpio_0_addr = peri_addr;
    assign gpio_0_dout = peri_dout;
    assign gpio_0_wr_en = (peri_addr >= 8'h84 & peri_addr <= 8'h87) ? peri_wr_en : 1'b0;
    assign gpio_0_rd_en = (peri_addr >= 8'h84 & peri_addr <= 8'h87) ? peri_rd_en : 1'b0;
    // iic_0_inst
    assign iic_0_addr = peri_addr;
    assign iic_0_dout = peri_dout;
    assign iic_0_wr_en = (peri_addr >= 8'h90 & peri_addr <= 8'h93) ? peri_wr_en : 1'b0;
    assign iic_0_rd_en = (peri_addr >= 8'h90 & peri_addr <= 8'h93) ? peri_rd_en : 1'b0;
    
    
    // gpio_0_inst
    gpio #(
        .ADDR_LSB(0),
        .OPT_MEM_ADDR_BITS(1)
    )gpio_0_inst(
        .clk(clk), 
        .reset_n(reset_n),
        
        // CPU Interface
        .addr(gpio_0_addr),
        .din(gpio_0_dout),
        .dout(gpio_0_din),
        .wr_en(gpio_0_wr_en),
        .rd_en(gpio_0_rd_en),
        
        // GPIO Interface
        .port(gpio_0_port)
    );
    
    // spi_0_inst
    spi_top #(
        .ADDR_LSB(0),
        .OPT_MEM_ADDR_BITS(1)
    )spi_0_inst(
        .clk(clk),
        .reset_n(reset_n),
        
        // CPU Interface
        .addr(spi_0_addr),
        .din(spi_0_dout),
        .dout(spi_0_din),
        .wr_en(spi_0_wr_en),
        .rd_en(spi_0_rd_en),
        
        // SPI Interface
        .sclk(spi_0_sclk),
        .mosi(spi_0_mosi),
        .miso(spi_0_miso),
        .ss_n(spi_0_cs)
    );
    
    // iic_0_inst
    iic_top #(
        .ADDR_LSB(0),
        .OPT_MEM_ADDR_BITS(1)
    )iic_0_inst(
        .clk(clk),
        .reset_n(reset_n),
        
        // CPU Interface
        .addr(iic_0_addr),
        .din(iic_0_dout),
        .dout(iic_0_din),
        .wr_en(iic_0_wr_en),
        .rd_en(iic_0_rd_en),
        
        // IIC Interface
        .sck(iic_0_sck),
        .sda(iic_0_sda)
    );
endmodule
