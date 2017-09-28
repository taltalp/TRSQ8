`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 2017/08/17 00:59:30
// Module Name: cpu
// Project Name: TRSQ8
//////////////////////////////////////////////////////////////////////////////////


module cpu (
    input       clk_ip, reset_n_ip,
    // registers
    output reg [7:0] STATUS,
    // program rom
    output reg [12:0] prom_addr,
    input      [14:0] prom_data,
    // peripheral bus
    output      [7:0] addr,
    input       [7:0] data_in,
    output      [7:0] data_out,
    output      wr_en, rd_en,
    // interrupts
    input       irq_ip);


    wire reset;

    wire [12:0] prom_addr_i;
    reg  [12:0] prom_stack;

    wire [7:0] alu_in_a, alu_in_b;
    wire [4:0] alu_in_sel;
    wire [7:0] alu_out;
    wire       alu_out_cf, alu_out_zf;
    wire       alu_out_r_zf;
    reg        alu_out_cf_r;
    reg  [7:0] alu_out_r, alu_out_stack;

    wire muxa_sel, muxb_sel;

    wire [7:0] peri_addr, peri_dout, peri_din;
    wire peri_wr_en, peri_rd_en;

    wire       nop_i, halt_i, sk_i;
    wire [1:0] sk_sel;

    wire       irq_i, return_i;
    reg        irq_pre_i; 
    reg  [7:0] irq_r = 8'b00000000;

    wire       jmp_i;
    reg        halt_r;

    wire ZF_s, CF_s;

    function [7:0] decode3to8 (input [2:0] data_ip);
    	begin
        	case (data_ip)
  				3'b000: decode3to8 = 8'h01;
  				3'b001: decode3to8 = 8'h02;
  				3'b010: decode3to8 = 8'h04;
  				3'b011: decode3to8 = 8'h08;
  				3'b100: decode3to8 = 8'h10;
  				3'b101: decode3to8 = 8'h20;
  				3'b110: decode3to8 = 8'h40;
  				3'b111: decode3to8 = 8'h80;
  				default: decode3to8 = 8'h00;
  			endcase
		end
	endfunction

    assign reset = ~ reset_n_ip;
    assign addr = peri_addr;
    assign data_out = peri_dout;
    assign peri_din = data_in;

    decoder decoder_inst (
    	.data_ip(prom_data),
		.alu_sel_op(alu_in_sel),
		.sk_sel_op(sk_sel),
		.muxa_sel_op(muxa_sel),
		.muxb_sel_op(muxb_sel),
		.sram_addr_op(peri_addr),
		.sram_ld_op(rd_en),
		.sram_st_op(wr_en),
		.nop_op(nop_i),
		.halt_op(halt_i),
		.jump_op(jmp_i),
		.return_op(return_i)		
    );


    alu alu (
    	.A_ip(alu_in_a),
    	.B_ip(alu_in_b),
		.CF_ip(CF_s),
		.SEL_ip(alu_in_sel),
		.O_op(alu_out),
		.CF_op(alu_out_cf),
		.ZF_op(alu_out_zf)
	);


	// STATUS REGISTER
	always @ (posedge clk_ip) begin
		STATUS <= {6'b0, alu_out_r_zf, alu_out_cf_r};  
	end

	assign CF_s = STATUS[0];
	assign ZF_s = STATUS[1];


	// MUX A
	assign alu_in_a = muxa_sel == 1'b1 ? prom_data[7:0] : peri_din;


	// MUX B
	assign alu_in_b = muxb_sel == 1'b1 ? decode3to8(prom_data[10:8]) : alu_out_r;


	// W Register
	always @ (negedge clk_ip) begin
		if (reset == 1'b1) begin
			alu_out_r    <= 8'h0;
			alu_out_cf_r <= 1'b0;
		end else if ( (nop_i == 1'b1) || (halt_i == 1'b1) || (jmp_i == 1'b1) || (sk_sel != 2'b00) ) begin
            alu_out_r    <= alu_out_r;
            alu_out_cf_r <= alu_out_cf_r;
        end else if ( (irq_i==1'b1) && (irq_pre_i==1'b0) ) begin
            alu_out_stack <= alu_out_r;
            alu_out_r     <= alu_out;
        end else if (return_i==1'b1) begin
            alu_out_r <= alu_out_stack;
        end else begin
            alu_out_r    <= alu_out;
            alu_out_cf_r <= alu_out_cf;
        end
	end
	assign peri_dout = alu_out_r;

    assign alu_out_r_zf = alu_out_r==8'h0 ? 1'b1: 1'b0; // ZERO flag

    // PC
 	always @ (negedge clk_ip) begin
		if (reset == 1'b1) begin
			prom_addr <= 13'h0;
			irq_pre_i <= 1'b0;
		end else if (halt_i == 1'b1) begin
            prom_addr <= prom_addr;
        end else begin
            if (jmp_i == 1'b1) begin
                prom_addr <= prom_data[12:0];
            end else if (sk_i == 1'b1) begin
        		prom_addr <= prom_addr + 2;
        	end else if ( (irq_i == 1'b1) && (irq_pre_i == 1'b0) ) begin
        		prom_addr <= 13'd4; // jump to 0x4
        		irq_pre_i <= 1'b1;
        		prom_stack <= prom_addr;
        	end else if (return_i == 1'b1) begin
        		prom_addr <= prom_stack;
        	end else begin
        		irq_pre_i <= 1'b0;
        		prom_addr <= prom_addr + 1;
        	end
        end
    end

    // SKIP
    assign sk_i = (sk_sel[0] & ZF_s) | (sk_sel[1] & CF_s);

    // STATUS
    always @ (posedge clk_ip) begin
		if (reset == 1'b1) begin
			halt_r <= 1'b0;
		end
		else begin
			halt_r <= halt_i;
		end
	end


	// IRQ ( not tested )
    always @ (posedge clk_ip, posedge irq_ip) begin
        if (irq_ip == 1'b1) begin
            irq_r[1] <= 1;
		end else if (peri_addr == 8'd3) begin
			irq_r <= alu_out_r;
		end
	end	

    assign irq_i = irq_r[1] & irq_r[0];

endmodule
