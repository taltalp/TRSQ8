# -*- coding: utf-8 -*- 
modules = { 
        'spi_0' : {
            'name' : 'spi_0',
            'module' : 'spi',
            'baseaddr' : '80',
            'lastaddr' : '83' 
            },
        'iic_0' : {
            'name' : 'iic_0',
            'module' : 'iic',
            'baseaddr': '84',
            'lastaddr' : '87' 
            },
        'gpio_0' : {
            'name' : 'gpio_0',
            'module' : 'gpio',
            'baseaddr' : '88',
            'lastaddr' : '8B'
            }
        }
        

def module_inst(module):
    if (module['module'] == 'gpio'):
        hdl_text = [
                '    gpio #(\n',
                '        .ADDR_LSB(0),\n',
                '        .OPT_MEM_ADDR_BITS(1)\n',
                '    )gpio_',
                '        .clk(clk),\n',
                '        .reset_n(reset_n),\n',
                '        .addr(' + module['name'] + '_addr),\n',
                '        .din('  + module['name'] + '_din),\n',
                '        .dout(' + module['name'] + '_dout),\n',
                '        .wr_en(' + module['name'] + '_wr_en),\n',
                '        .rd_en(' + module['name'] + '_rd_en),\n',
                '        .port(' + module['name'] + '_port),\n',
                '    );\n',
                '\n'
                ]
        return hdl_text

    elif (module['module'] == 'spi'):
        hdl_text = [
                '    spi #(\n',
                '        .ADDR_LSB(0),\n',
                '        .OPT_MEM_ADDR_BITS(1)\n',
                '    )', module['name'] + '_inst(\n',
                '        .clk(clk),\n',
                '        .reset_n(reset_n),\n',
                '        .addr(' + module['name'] + '_addr),\n',
                '        .din('  + module['name'] + '_din),\n',
                '        .dout(' + module['name'] + '_dout),\n',
                '        .wr_en(' + module['name'] + '_wr_en),\n',
                '        .rd_en(' + module['name'] + '_rd_en),\n',
                '        .sclk(' + module['name'] + '_sclk),\n',
                '        .mosi(' + module['name'] + '_mosi),\n',
                '        .miso(' + module['name'] + '_miso),\n',
                '        .ss_n(' + module['name'] + '_ss_n),\n',
                '    );\n',
                '\n'
                ]
        return hdl_text

    elif (module['module'] == 'iic'):
        hdl_text = [
                '    iic #(\n',
                '        .ADDR_LSB(0),\n',
                '        .OPT_MEM_ADDR_BITS(1)\n',
                '    )' + module['name'] + '_inst(\n',
                '        .clk(clk),\n',
                '        .reset_n(reset_n),\n',
                '        .addr(' + module['name'] + '_addr),\n',
                '        .din('  + module['name'] + '_din),\n',
                '        .dout(' + module['name'] + '_dout),\n',
                '        .wr_en(' + module['name'] + '_wr_en),\n',
                '        .rd_en(' + module['name'] + '_rd_en),\n',
                '        .sck(' + module['name'] + '_sck),\n',
                '        .sda(' + module['name'] + '_sda),\n',
                '    );\n',
                '\n'
                ]
        return hdl_text
    return

def module_port(module):
    if (module['module'] == 'gpio'):
        hdl_text = [
                ',\n\n',
                '    // ' + module['name'] + '_inst\n',
                '    inout [7:0] ' + module['name'] + '_port'
                ]
        return hdl_text
    elif (module['module'] == 'spi'):
        hdl_text = [
                ',\n\n',
                '    // ' + module['name'] + '_inst\n',
                '    output ' + module['name'] + '_sclk,\n',
                '    output ' + module['name'] + '_mosi,\n',
                '    input ' + module['name'] + '_miso,\n',
                '    output [0:0] ' + module['name'] + '_cs'
                ]
        return hdl_text
    elif (module['module'] == 'iic'):
        hdl_text = [
                ',\n\n',
                '    // ' + module['name'] + '_inst\n',
                '    output ' + module['name'] + '_sck,\n',
                '    inout ' + module['name'] + '_sda',
                ]
        return hdl_text
    return

hdl_text_0 = [
        '`timescale 1ns / 1ps\n',
        'module TRSQ8(\n',
        '    input clk,\n',
        '    input reset',
        ]

hdl_text_port = [
        ]

hdl_text_1 = [
        ');\n',
        '\n',
        '    wire reset_n;\n',
        '    wire [7:0] cpu_status;\n',
        '    wire [12:0] prom_addr;\n',
        '    wire [14:0] prom_data;\n',
        '    wire [7:0]  peri_addr;\n',
        '    wire [7:0]  peri_din;\n',
        '    wire [7:0]  peri_dout;\n',
        '    wire        peri_wr_en;\n',
        '    wire        peri_rd_en;\n',
        '    reg [7:0] ram_i [0:255];\n',
        '    wire [7:0] ram_addr;\n',
        '    wire [7:0] ram_din;\n',
        '    wire [7:0] ram_dout;\n',
        '\n',
        '    // user module\n',
        ]

hdl_text_wire = [
        '    wire [7:0]  iic_0_addr;\n', 
        '    wire [7:0]  iic_0_din;\n', 
        '    wire [7:0]  iic_0_dout;\n', 
        '    wire iic_0_wr_en;\n', 
        '    wire iic_0_rd_en;\n' 
        ]

hdl_text_2 = [
        '\n',
        '    assign reset_n = ~reset;\n',
        '    cpu cpu_inst(\n',
        '        .clk_ip(clk),\n',
        '        .reset_n_ip(reset_n),\n',
        '        .STATUS(cpu_status),\n',
        '        .prom_addr(prom_addr),\n',
        '        .addr(peri_addr),\n',
        '        .data_in(peri_din),\n',
        '        .data_out(peri_dout),\n',
        '        .wr_en(peri_wr_en),\n',
        '        .rd_en(peri_rd_en),\n',
        '        .irq_ip(0)\n',
        '    );\n',
        '\n',
        '    prom prom_inst(\n',
        '        .CLK_ip(clk),\n',
        '        .ADDR_ip(prom_addr),\n',
        '        .DATA_op(prom_data),\n',
        '    );\n',
        '\n'
        '    // ram\n',
        '    always @(posedge clk) begin\n',
        '        if (reset) begin : init_mem\n',
        '            integer i;\n',
        '            for (i=0; i<256; i=i+1) begin\n',
        '                ram_i[i] <= 8\'h00;\n',
        '            end\n',
        '        end else begin\n',
        '            ram_i[0] <= cpu_status;\n',
        '            if (ram_wr_en) begin\n',
        '                if (ram_addr != 8\'h00) begin\n',
        '                    ram_i[ram_addr] <= ram_dout;\n',
        '                end\n',
        '            end\n',
        '        end\n',
        '    end\n',
        '    assign ram_din = ram_i[ram_addr];\n',
        '\n',
        '    // Interconnect\n',
        '    assign ram_addr = peri_addr;\n',
        '    assign ram_dout = peri_dout;\n',
        '    assign ram_wr_en = (peri_addr >= 8\'h00 & peri_addr <= 8\'h7F) ? peri_wr_en : 1\'b0;\n',
        '    assign ram_rd_en = (peri_addr >= 8\'h00 & peri_addr <= 8\'h7F) ? peri_rd_en : 1\'b0;\n'
        ]

hdl_text_intercon = [
        ]

hdl_text_module = [
        ]

for module in modules.values():
    print(module)
    hdl_text = [
           '\n'
           '    assign ' + module['name'] + '_addr = peri_addr;\n',
           '    assign ' + module['name'] + '_dout = peri_dout;\n',
           '    assign ' + module['name'] + '_wr_en = (peri_addr >= 8\'h' + module['baseaddr'] + 
           ' & peri_addr <= 8\'h' + module['lastaddr'] +  ') ? peri_wr_en : 1\'b0\n',
           '    assign ' + module['name'] + '_rd_en = (peri_addr >= 8\'h' + module['baseaddr'] + 
           ' & peri_addr <= 8\'h' + module['lastaddr'] +  ') ? peri_rd_en : 1\'b0\n',
            ]
    hdl_text_intercon += hdl_text

    hdl_text = module_inst(module)
    hdl_text_module += hdl_text

    hdl_text = module_port(module)
    hdl_text_port += hdl_text


with open('./TRSQ8.v', 'w', encoding='utf-8-sig') as text:
    text.writelines(hdl_text_0)
    text.writelines(hdl_text_port)
    text.writelines(hdl_text_1)
    text.writelines(hdl_text_wire)
    text.writelines(hdl_text_2)
    text.writelines(hdl_text_intercon)
    text.writelines(hdl_text_module)
    text.writelines('endmodule')
