`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 2017/09/07 18:15:28
// Module Name: gpio
// Project Name: TRSQ8
//////////////////////////////////////////////////////////////////////////////////
`define vivado

module gpio #(
    parameter BASE_ADDR = 8'h80,
    parameter LAST_ADDR = 8'h83
    )(
    input clk, reset_n,
    
    // CPU Interface
    input [7:0] addr, dout,
    output[7:0] din,
    input wr_en, rd_en,
    
    // GPIO Interface
    inout [7:0] port
    );
    
    localparam integer ADDR_LSB = 0;
    localparam integer OPT_MEM_ADDR_BITS = 1;
    
    reg [7:0] TRIS = 8'h00;
    reg [7:0] OGPIO = 8'h00; 
    reg [7:0] IGPIO = 8'h00;
    reg [7:0] DUMMY = 8'h00;
    
    wire [7:0] ibuf;
    
    reg [7:0] gpio_dout;
    wire [7:0] gpio_addr, gpio_din;
    wire gpio_wr_en, gpio_rd_en;
    
    assign din = (addr >= BASE_ADDR & addr <= LAST_ADDR) ? gpio_dout : 8'hZZ;
    assign gpio_addr = addr;
    assign gpio_din = dout;
    assign gpio_wr_en = (addr >= BASE_ADDR & addr <= LAST_ADDR) ? wr_en : 1'b0;
    assign gpio_rd_en = (addr >= BASE_ADDR & addr <= LAST_ADDR) ? rd_en : 1'b0;
    
    initial begin
        gpio_dout = 8'h0;
    end
    
    wire [OPT_MEM_ADDR_BITS:0] loc_addr = addr[ADDR_LSB + OPT_MEM_ADDR_BITS:ADDR_LSB];
    always @(posedge clk) begin
        if (gpio_wr_en == 1'b1) begin
            case (loc_addr)
                2'b00 : OGPIO <= gpio_din;
                2'b01 : TRIS <= gpio_din;
                // 2'b10 : IGPIO <= din;
                // 2'b11 : DUMMY <= din;
                default : begin : wr_def
                          TRIS <= TRIS;
                          OGPIO <= OGPIO;
                          end
            endcase
        end else if (gpio_rd_en == 1'b1) begin
            case (loc_addr)
                2'b00 : gpio_dout <= OGPIO;
                2'b01 : gpio_dout <= TRIS;
                2'b10 : gpio_dout <= IGPIO;
                // 2'b11 : dout <= DUMMY;
                default : gpio_dout <= 8'h00;
            endcase
        end
        
        // fetch buffer input to registers
        IGPIO <= ibuf;
    end
    
    `ifdef vivado
        generate
            genvar i;
            for (i=0; i<8; i=i+1)
            begin: iobuf_loop
                IOBUF #(
                  .DRIVE(12), // Specify the output drive strength
                  .IBUF_LOW_PWR("TRUE"),  // Low Power - "TRUE", High Performance = "FALSE" 
                  .IOSTANDARD("DEFAULT"), // Specify the I/O standard
                  .SLEW("SLOW") // Specify the output slew rate
               ) IOBUF_inst (
                  .O(ibuf[i]),     // Buffer output
                  .IO(port[i]),     // Buffer inout port (connect directly to top-level port)
                  .I(OGPIO[i]),     // Buffer input
                  .T(TRIS[i])       // 3-state enable input, high=input, low=output
               );
            end
        endgenerate
    `endif
    
endmodule