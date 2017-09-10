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
`define vivado

module gpio #(
    parameter ADDR_LSB = 0,
    parameter OPT_MEM_ADDR_BITS = 1
    )(
    input clk, reset_n,
    
    // CPU Interface
    input [7:0] addr, din,
    output reg [7:0] dout,
    input wr_en, rd_en,
    
    // GPIO Interface
    inout [7:0] port
    );
    
    reg [7:0] TRIS = 8'h00;
    reg [7:0] OGPIO = 8'h00; 
    reg [7:0] IGPIO = 8'h00;
    reg [7:0] DUMMY = 8'h00;
    
    wire [7:0] ibuf;
    
    wire [OPT_MEM_ADDR_BITS:0] loc_addr = addr[ADDR_LSB + OPT_MEM_ADDR_BITS:ADDR_LSB];
    always @(posedge clk) begin
        if (wr_en == 1'b1) begin
            case (loc_addr)
                2'b00 : OGPIO <= din;
                2'b01 : TRIS <= din;
                // 2'b10 : IGPIO <= din;
                // 2'b11 : DUMMY <= din;
                default : begin : wr_def
                          TRIS <= TRIS;
                          OGPIO <= OGPIO;
                          end
            endcase
        end else if (rd_en == 1'b1) begin
            case (loc_addr)
                2'b00 : dout <= OGPIO;
                2'b01 : dout <= TRIS;
                2'b10 : dout <= IGPIO;
                // 2'b11 : dout <= DUMMY;
                default : dout <= 8'h00;
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