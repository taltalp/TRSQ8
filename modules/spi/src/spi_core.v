`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 2017/08/23 21:51:37
// Module Name: spi_core
// Project Name: TRSQ8
//////////////////////////////////////////////////////////////////////////////////
`default_nettype wire

module spi_core #(
    parameter SLAVES = 1,
    parameter D_WIDTH = 8
    )(
    input                clock, reset_n,
    input                enable, cpol, cpha, cont,
    input [7:0]          clk_div,
    input [D_WIDTH-1:0]  tx_data,
    input                miso,
    output reg               sclk, mosi,
    output reg [SLAVES-1:0]  ss_n,
    output reg               busy,
    output reg [D_WIDTH-1:0] rx_data
    );
    
    `define SS_N_LEN SLAVES
    
    localparam reg ready = 1'h0;
    localparam reg execute = 1'h1;
    reg state;
    reg [7:0] clk_ratio;
    reg [7:0] count;
    reg [7:0] clk_toggles;
    reg assert_data;
    reg continue;
    reg [D_WIDTH-1:0] rx_buffer;
    reg [D_WIDTH-1:0] tx_buffer;
    reg [7:0] last_bit_rx;
    
    always @(posedge clock, negedge reset_n) begin
        if (!reset_n) begin
            busy <= 1;
            ss_n <= {`SS_N_LEN{1'b0}};
            mosi <= 1'bz;
            rx_data <= 0;
            tx_buffer <= 0;
            rx_buffer <= 0;
            state <= ready;
        end else begin
            case (state)
                ready : begin : ready_state
                    busy <= 0;
                    ss_n <= {`SS_N_LEN{1'b1}};
                    mosi <= 1'bz;
                    continue <= 1'b1;
                    
                    // user input to initiate transaction
                    if (enable) begin
                        busy <= 1'b1;
                        
                        if (clk_div == 0) begin
                            clk_ratio <= 1;
                            count <= 1;
                        end else begin
                            clk_ratio <= clk_div;
                            count <= clk_div;
                        end
                        
                        sclk <= cpol;
                        assert_data <= ~cpha;
                        tx_buffer <= tx_data;
                        clk_toggles <= 0;
                        last_bit_rx <= D_WIDTH*2 + cpha - 1;
                        state <= execute;
                    end else begin
                        state <= ready;
                    end
                end
                execute : begin : execute_state
                    busy <= 1'b1;
                    ss_n[0] <= 1'b0;
                    
                    // system clock to sclk ratio is met
                    if (count == clk_ratio) begin
                        count <= 1;
                        assert_data <= ~assert_data;
                        if (clk_toggles == D_WIDTH*2+1) begin
                            clk_toggles <= 0;
                        end else begin
                            clk_toggles <= clk_toggles + 1;
                        end 
                        
                        // spi clock toggle needed
                        if (clk_toggles <= D_WIDTH*2 && ss_n[0] == 1'b0) begin
                            sclk <= ~sclk;
                        end
                        
                        // receive spi clock toggle
                        if (assert_data == 1'b0 && clk_toggles < last_bit_rx + 1 && ss_n[0] == 1'b0) begin
                            rx_buffer <= {rx_buffer[D_WIDTH-2:0], miso};
                        end
                        
                        // transmit spi clock toggle
                        if (assert_data == 1'b1 && clk_toggles < last_bit_rx) begin
                            mosi <= tx_buffer[D_WIDTH-1];
                            tx_buffer <= {tx_buffer[D_WIDTH-2:0], 1'b0};
                        end
                            
                        // last data receive, but continue
                        if (clk_toggles == last_bit_rx && cont == 1'b1) begin
                            tx_buffer <= tx_data;
                            clk_toggles <= last_bit_rx - D_WIDTH*2 + 1;
                            continue <= 1'b1;
                        end
                        
                        // normal end of transaction, but continue
                        if (continue) begin
                            continue <= 1'b0;
                            busy <= 1'b1;
                            rx_data <= rx_buffer;
                        end
                        
                        // end of transaction
                        if (clk_toggles == D_WIDTH*2-1 && cont == 1'b0) begin
                            busy <= 1'b0;
                            ss_n <= {`SS_N_LEN{1'b1}};
                            mosi <= 1'bz;
                            rx_data <= rx_buffer;
                            state <= ready;
                        end else begin
                            state <= execute;
                        end
                    end else begin
                        count <= count + 1;
                        state <= execute;
                    end
                end
            endcase
        end
    end
endmodule
