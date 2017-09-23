`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/09/23 10:25:14
// Design Name: 
// Module Name: iic_core_fpga_demo
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


module iic_core_fpga_demo(
    input clock,
    input reset,
    
    output sck,
    inout  sda
    );
    
    wire reset_n;
    wire busy, sending;
    
    reg start, stop, rw;
    reg [7:0] din;
    wire [7:0] dout;
    
    wire sda_i, sda_o, sda_t;
    
    reg [3:0] state;
    integer counter;
    
    parameter S_IDLE  = 0;
    parameter S_START = 1;
    parameter S_WRITE = 2;
    parameter S_STOP  = 3;   
    
    assign reset_n = !reset;
    
    always @(posedge clock) begin
        if (reset) begin
            start <= 1'b0;
            stop  <= 1'b0;
            rw    <= 1'b0;
            din   <= 8'h0;
            counter <= 0;
        end else begin
            case (state)
                S_IDLE : begin
                    start <= 1'b0;
                    stop  <= 1'b0;
                    rw    <= 1'b0;
                    din   <= 8'h0;
                    counter <= 0;
                    
                    if (busy == 0 && sending == 0) begin
                        state <= S_START;
                    end else begin
                        state <= S_IDLE;
                    end
                end
                
                S_START : begin
                    start <= 1'b1;
                    din   <= 8'h7A;
                    stop  <= 1'b0;
                    rw    <= 1'h0; // write
                    
                    if (busy && sending) begin
                        state <= S_WRITE;
                    end else begin
                        state <= S_START;
                    end
                end
                
                S_WRITE : begin
                    start <= 1'b0;
                    din   <= din;
                    stop  <= 1'b0;
                    rw    <= 1'b0;
                    
                    if (!busy) begin
                        counter <= counter + 1;
                        if (counter < 8) begin
                            state <= S_START;
                        end else begin
                            state <= S_STOP;
                        end
                    end else begin
                        state <= S_WRITE;
                    end
                end
                
                S_STOP : begin
                    start <= 1'b0;
                    stop  <= 1'b1;
                    rw    <= 1'b0;
                    
                    if (!sending) begin
                        state <= S_IDLE;
                    end else begin
                        state <= S_STOP;
                    end
                end
                
                default : begin
                    state <= S_IDLE;
                end
            endcase
        end
    end
    
    iic_core iic_core_0(
        .clock(clock),
        .reset_n(reset_n),
        .busy(busy),
        .sending(sending),
        .start(start),
        .stop(stop),
        .rw(rw), // rw = 1 -> read
        .din(din),
        .dout(dout),
        .sck(sck),
        .sda_i(sda_i),
        .sda_o(sda_o),
        .sda_t(sda_t)
        );
    
    IOBUF #(
       .DRIVE(12), // Specify the output drive strength
       .IBUF_LOW_PWR("TRUE"),  // Low Power - "TRUE", High Performance = "FALSE" 
       .IOSTANDARD("DEFAULT"), // Specify the I/O standard
       .SLEW("SLOW") // Specify the output slew rate
    ) IOBUF_inst (
       .O(sda_i),     // Buffer output
       .IO(sda),   // Buffer inout port (connect directly to top-level port)
       .I(sda_o),     // Buffer input
       .T(~sda_t)      // 3-state enable input, high=input, low=output
    );
    
    ila_0 ila_0_inst (
        .clk(clock), // input wire clk
       
        .probe0(start), // input wire [0:0]  probe0  
        .probe1(stop), // input wire [0:0]  probe1 
        .probe2(rw), // input wire [0:0]  probe2 
        .probe3(busy), // input wire [0:0]  probe3 
        .probe4(sending), // input wire [0:0]  probe4 
        .probe5(din), // input wire [7:0]  probe5 
        .probe6(dout), // input wire [7:0]  probe6
        .probe7(sck), // input wire [0:0]  probe7  
        .probe8(sda_o), // input wire [0:0]  probe8  
        .probe9(sda_i) // input wire [0:0]  probe9  
        );
endmodule
