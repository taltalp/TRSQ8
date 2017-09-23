`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 2017/09/18 01:08:52
// Module Name: iic_core
// Project Name: TRSQ8
//////////////////////////////////////////////////////////////////////////////////

module iic_core(
    input  clock, reset_n,
    output reg busy, sending,
    input  start, stop, rw, // rw = 1 -> read
    input  [7:0] din,
    output reg [7:0] dout,
    output reg sck,
    input  sda_i,
    output reg sda_o,
    output reg sda_t
    );
    
    localparam [4:0] STATE_IDLE    = 5'h0,
                     STATE_START_0 = 5'h1,
                     STATE_START_1 = 5'h2,
                     STATE_WRITE_0 = 5'h3,
                     STATE_WRITE_1 = 5'h4,
                     STATE_WRITE_2 = 5'h5,
                     STATE_READ_0  = 5'h6,
                     STATE_READ_1  = 5'h7,
                     STATE_WAIT    = 5'h8,
                     STATE_STOP_0  = 5'h9,
                     STATE_STOP_1  = 5'h10;
                    
    reg [4:0] state_r = STATE_IDLE;
    
    reg [7:0] din_r, dout_r; 
    
    reg [3:0] bit_cnt;
    
    always @(posedge clock) begin
        if (!reset_n) begin
            din_r  <= 0;
            dout   <= 0;
            dout_r <= 0;
            sck   <= 1'b1;
            sda_o <= 1'b1;
            sda_t <= 1'b1;
            busy  <= 1'b0;
            sending <= 1'b0;
            bit_cnt <= 4'h8;
            state_r = STATE_IDLE;
        end else begin
            case (state_r)
                // IIC Idle Condition
                STATE_IDLE: begin
                    sck   <= 1'b1;
                    sda_o <= 1'b1;
                    sda_t <= 1'b1;
                    if (start) begin
                        din_r <= din;
                        busy <= 1'b1;
                        sending <= 1'b1;
                        state_r <= STATE_START_0;
                    end else begin
                        busy <= 1'b0;
                        sending <= 1'b0;
                        state_r <= STATE_IDLE;
                    end
                end
                
                // IIC Start Condition
                STATE_START_0: begin
                    sck   <= 1'b1;
                    sda_o <= 1'b0;
                    sda_t <= 1'b1;
                    busy  <= 1'b1;
                    sending <= 1'b1;
                    state_r <= STATE_START_1;
                end
                
                STATE_START_1: begin
                    sck   <= 1'b0;
                    sda_o <= 1'b0;
                    sda_t <= 1'b1;
                    bit_cnt <= 4'h8;
                    busy  <= 1'b1;
                    sending <= 1'b1;
                    state_r <= STATE_WRITE_0;
                end
                
                // IIC Write Condition
                STATE_WRITE_0: begin
                    sck   <= 1'b0;
                    if (bit_cnt == 0) begin
                        sda_t <= 1'b0; // Hi-Z
                    end else begin
                        sda_o <= din_r[7];
                        sda_t <= 1'b1;
                        din_r <= {din_r[6:0], 1'b0};
                    end
                    busy  <= 1'b1;
                    sending <= 1'b1;
                    state_r <= STATE_WRITE_1;
                end
                
                STATE_WRITE_1: begin
                    sck   <= 1'b1;
                    sda_o <= sda_o;
                    busy  <= 1'b1;
                    sending <= 1'b1;
                    
                    if (bit_cnt == 0) begin
                        bit_cnt <= 4'h8;
                        state_r <= STATE_WRITE_2;
                    end else begin
                        bit_cnt <= bit_cnt - 4'h1;
                        state_r <= STATE_WRITE_0;
                    end
                end
                
                STATE_WRITE_2: begin
                    sck <= 1'b0;
                    sda_o <= 1'b0;
                    busy <= 1'b1;
                    sending <= 1'b1;
                    sda_t <= 1'b1;
                    state_r <= STATE_WAIT;
                end
                
                // IIC Read Condition
                STATE_READ_0: begin
                    sck   <= 1'b0;
                    if (bit_cnt == 0) begin
                        sda_o <= 1'b1; // ACK
                        sda_t <= 1'b1; // output
                    end else begin
                        sda_t <= 1'b0;
                    end
                    busy  <= 1'b1;
                    sending <= 1'b1;
                    state_r <= STATE_READ_0;
                end
                
                STATE_READ_1: begin
                    sck   <= 1'b1;
                    busy  <= 1'b1;
                    sending <= 1'b1;
                    
                    
                    if (bit_cnt == 0) begin
                        bit_cnt <= 4'h8;
                        state_r <= STATE_WAIT;
                    end else begin
                        dout_r <= {dout_r[6:0], sda_i}; // read data
                        bit_cnt <= bit_cnt - 4'h1;
                        state_r <= STATE_READ_0;
                    end
                end
                
                // IIC Wait Condition
                STATE_WAIT: begin
                    sck   <= 1'b0;
                    sda_o <= 1'b1;
                    sda_t <= 1'b1;
                    bit_cnt <= 4'h8;
                    sending <= 1'b1;
                    dout  <= dout_r; // update dout
                    
                    if (start) begin
                        busy  <= 1'b1;
                        if (rw) begin
                            state_r <= STATE_READ_0;
                        end else begin
                            din_r   <= din;
                            state_r <= STATE_WRITE_0;
                        end
                    end else if (stop) begin
                        busy  <= 1'b1;
                        state_r <= STATE_STOP_0;
                    end else begin
                        busy  <= 1'b0;
                    end
                end
                
                // IIC Stop Condition
                STATE_STOP_0: begin
                    sck     <= 1'b1;
                    sda_o   <= 1'b0;
                    sda_t   <= 1'b1;
                    busy    <= 1'b1;
                    sending <= 1'b1;
                    state_r <= STATE_STOP_1;
                end
                
                STATE_STOP_1: begin
                    sck     <= 1'b1;
                    sda_o   <= 1'b1;
                    sda_t   <= 1'b1;
                    busy    <= 1'b1;
                    sending <= 1'b1;
                    state_r <= STATE_IDLE;
                end
                
                default: begin
                    state_r <= STATE_IDLE;
                end
            endcase
        end
    end
endmodule
