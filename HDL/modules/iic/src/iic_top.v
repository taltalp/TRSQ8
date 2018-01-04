`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 2017/09/20 22:41:14
// Module Name: iic_top
// Project Name: TRSQ8
//////////////////////////////////////////////////////////////////////////////////
`define vivado

module iic_top #(
    parameter BASE_ADDR = 8'h80,
    parameter LAST_ADDR = 8'h83
    )(
    input clk, reset_n,
    
    // CPU Interface
    input [7:0] addr, dout,
    output [7:0] din,
    input wr_en, rd_en,
    
    // IIC Interface
    output sck,
    inout  sda
    );
    
    localparam integer ADDR_LSB = 0;
    localparam integer OPT_MEM_ADDR_BITS = 1;
    
    wire busy, sending;
    wire start, stop, rw;
    
    wire [7:0] iic_rx;
    
    wire sda_i, sda_o, sda_t;
    
    reg [7:0] IICCON    = 8'h0;
    reg [7:0] IICCLKDIV = 8'h0;
    reg [7:0] IICTX     = 8'h0;
    reg [7:0] IICRX     = 8'h0;
    
    reg [7:0] iic_dout;
    wire [7:0] iic_addr, iic_din;
    wire iic_wr_en, iic_rd_en;
    
    assign din = (addr >= BASE_ADDR & addr <= LAST_ADDR) ? iic_dout : 8'hZZ;
    assign iic_addr = addr;
    assign iic_din = dout;
    assign iic_wr_en = (addr >= BASE_ADDR & addr <= LAST_ADDR) ? wr_en : 1'b0;
    assign iic_rd_en = (addr >= BASE_ADDR & addr <= LAST_ADDR) ? rd_en : 1'b0;
    
    initial begin
        iic_dout = 8'h0;
    end
    
    wire [OPT_MEM_ADDR_BITS:0] loc_addr = addr[ADDR_LSB + OPT_MEM_ADDR_BITS:ADDR_LSB];
    always @(clk) begin
        if (clk == 1'b1) begin
            if (iic_wr_en) begin
                case (loc_addr)
                    2'b00: IICCON <= iic_din;
                    2'b01: IICCLKDIV <= iic_din;
                    2'b10: IICTX <= iic_din;
                    2'b11: IICRX <= iic_din;
                    default : begin
                        
                              end
                endcase
            end else if (iic_rd_en) begin
                case (loc_addr)
                    2'b00 : iic_dout <= IICCON;
                    2'b01 : iic_dout <= IICCLKDIV;
                    2'b10 : iic_dout <= IICTX;
                    2'b11 : iic_dout <= IICRX;
                    default : iic_dout <= 8'h00;
                endcase
            end
        end else if (clk == 1'b0) begin
            IICCON <= {IICCON[7:2], sending, busy};
            IICRX  <= iic_rx;
        end
    end
    
    assign stop  = IICCON[4];
    assign start = IICCON[3];
    assign rw    = IICCON[2];
    
    iic_core iic_core_inst
    (
        .clock(clk),
        .reset_n(reset_n),
        .busy(busy),
        .sending(sending),
        .start(start),
        .stop(stop),
        .rw(rw),
        .din(IICTX),
        .dout(iic_rx),
        .sck(sck),
        .sda_i(sda_i),
        .sda_o(sda_o),
        .sda_t(sda_t)
    );
        
    `ifdef vivado
        IOBUF #(
           .DRIVE(12), // Specify the output drive strength
           .IBUF_LOW_PWR("TRUE"),  // Low Power - "TRUE", High Performance = "FALSE" 
           .IOSTANDARD("DEFAULT"), // Specify the I/O standard
           .SLEW("SLOW") // Specify the output slew rate
        ) IOBUF_inst (
           .O(sda_i),     // Buffer output
           .IO(sda),     // Buffer inout port (connect directly to top-level port)
           .I(sda_o),     // Buffer input
           .T(~sda_t)       // 3-state enable input, high=input, low=output
        );
    `endif
    
endmodule