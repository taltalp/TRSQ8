# -*- coding: utf-8 -*- 

'''
This code generates TRSQ8.v Top Module file from modules.json
'''

import json

MODULE_SETTINGS = '../settings/modules.json'

# 使用するモジュールの定義
f = open(MODULE_SETTINGS, 'r')
modules = json.load(f)
f.close()
        
# 各モジュールのインスタンスを返す
def module_inst(module):
    if (module['MODULE'] == 'GPIO'):
        hdl_text = [
                '    // ' + module['NAME'] + '_inst\n',
                '    gpio #(\n',
                '        .BASE_ADDR(8\'h' + module['BASEADDR'] + '),\n',
                '        .LAST_ADDR(8\'h' + module['LASTADDR'] + ')\n',
                '    )' + module['NAME'] + '_inst',
                '        .clk(clk),\n',
                '        .reset_n(reset_n),\n',
                '        .addr(peri_addr),\n',
                '        .din(peri_din),\n',
                '        .dout(peri_dout),\n',
                '        .wr_en(peri_wr_en),\n',
                '        .rd_en(peri_rd_en),\n',
                '        .port(' + module['NAME'] + '_port),\n',
                '    );\n',
                '\n'
                ]
        return hdl_text

    elif (module['MODULE'] == 'SPI'):
        hdl_text = [
                '    // ' + module['NAME'] + '_inst\n',
                '    spi #(\n',
                '        .BASE_ADDR(8\'h' + module['BASEADDR'] + '),\n',
                '        .LAST_ADDR(8\'h' + module['LASTADDR'] + ')\n',
                '    )', module['NAME'] + '_inst(\n',
                '        .clk(clk),\n',
                '        .reset_n(reset_n),\n',
                '        .addr(peri_addr),\n',
                '        .din(peri_din),\n',
                '        .dout(peri_dout),\n',
                '        .wr_en(peri_wr_en),\n',
                '        .rd_en(peri_rd_en),\n',
                '        .sclk(' + module['NAME'] + '_sclk),\n',
                '        .mosi(' + module['NAME'] + '_mosi),\n',
                '        .miso(' + module['NAME'] + '_miso),\n',
                '        .ss_n(' + module['NAME'] + '_ss_n),\n',
                '    );\n',
                '\n'
                ]
        return hdl_text

    elif (module['MODULE'] == 'IIC'):
        hdl_text = [
                '    // ' + module['NAME'] + '_inst\n',
                '    iic #(\n',
                '        .BASE_ADDR(8\'h' + module['BASEADDR'] + '),\n',
                '        .LAST_ADDR(8\'h' + module['LASTADDR'] + ')\n',
                '    )' + module['NAME'] + '_inst(\n',
                '        .clk(clk),\n',
                '        .reset_n(reset_n),\n',
                '        .addr(peri_addr),\n',
                '        .din(peri_din),\n',
                '        .dout(peri_dout),\n',
                '        .wr_en(peri_wr_en),\n',
                '        .rd_en(peri_rd_en),\n',
                '        .sck(' + module['NAME'] + '_sck),\n',
                '        .sda(' + module['NAME'] + '_sda),\n',
                '    );\n',
                '\n'
                ]
        return hdl_text
    else:
        print(err)
        return

# 各モジュールのポートを返す
def module_port(module):
    if (module['MODULE'] == 'GPIO'):
        hdl_text = [
                ',\n\n',
                '    // ' + module['NAME'] + '_inst\n',
                '    inout [7:0] ' + module['NAME'] + '_port'
                ]
        return hdl_text
    elif (module['MODULE'] == 'SPI'):
        hdl_text = [
                ',\n\n',
                '    // ' + module['NAME'] + '_inst\n',
                '    output ' + module['NAME'] + '_sclk,\n',
                '    output ' + module['NAME'] + '_mosi,\n',
                '    input ' + module['NAME'] + '_miso,\n',
                '    output [0:0] ' + module['NAME'] + '_cs'
                ]
        return hdl_text
    elif (module['MODULE'] == 'IIC'):
        hdl_text = [
                ',\n\n',
                '    // ' + module['NAME'] + '_inst\n',
                '    output ' + module['NAME'] + '_sck,\n',
                '    inout ' + module['NAME'] + '_sda',
                ]
        return hdl_text
    else:
        print(err)
        return

# 各モジュールのワイヤを返す
def module_wire(module):
    hdl_text = [
            '    // ' + module['NAME'] + '_inst\n',
            '    wire [7:0] ' + module['NAME'] + '_addr;\n',
            '    wire [7:0] ' + module['NAME'] + '_din;\n',
            '    wire [7:0] ' + module['NAME'] + '_dout;\n',
            '    wire ' + module['NAME'] + '_wr_en;\n',
            '    wire ' + module['NAME'] + '_rd_en;\n'
            ]
    return hdl_text


# モジュールの定義とポートの定義
hdl_text_0 = [
        '`timescale 1ns / 1ps\n',
        'module TRSQ8(\n',
        '    input clk,\n',
        '    input reset',
        ]

# 各モジュールのポートの定義
hdl_text_port = [
        ]

# 内部のワイヤ定義部分
hdl_text_1 = [
        ');\n',
        '\n',
        '    wire reset_n;\n',
        '    wire [7:0] cpu_status;\n',
        '    wire [12:0] prom_addr;\n',
        '    wire [14:0] prom_data;\n',
        '\n',
        '    // peripheral bus\n',
        '    wire [7:0]  peri_addr;\n',
        '    wire [7:0]  peri_din;\n',
        '    wire [7:0]  peri_dout;\n',
        '    wire        peri_wr_en;\n',
        '    wire        peri_rd_en;\n',
        '\n',
        '    wire [7:0] ram_addr;\n',
        '    wire [7:0] ram_din;\n',
        '    wire [7:0] ram_dout;\n',
        '    wire       ram_wr_en;\n',
        '    wire       ram_rd_en;\n',
        '\n',
        '    // ===== user module =====\n',
        ]

# 各種インスタンス呼び出し部
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
        '    assign peri_din_i = peri_rd_en ? peri_din : 8\'h00;\n',
        '\n'
        '    ram ram_inst(\n',
        '        .clk(clk),\n',
        '        .reset_n(reset_n),\n',
        '        .addr(peri_addr),\n',
        '        .dout(peri_dout),\n',
        '        .din(peri_din),\n',
        '        .wr_en(peri_wr_en),\n',
        '        .rd_en(peri_rd_en),\n',
        '        .cpu_status(cpu_status)\n',
        '    );\n'
        ]

# ユーザ定義のモジュールインスタンス呼び出し部
hdl_text_module = [
        ]

for module in modules.values():
    # print(module)
    # インスタンスの生成
    hdl_text = module_inst(module)
    hdl_text_module += hdl_text
    # ポートの生成
    hdl_text = module_port(module)
    hdl_text_port += hdl_text


# HDLへの書き出し
with open('./TRSQ8.v', 'w', encoding='utf-8-sig') as text:
    text.writelines(hdl_text_0)
    text.writelines(hdl_text_port)
    text.writelines(hdl_text_1)
    # text.writelines(hdl_text_wire)
    text.writelines(hdl_text_2)
    text.writelines(hdl_text_module)
    text.writelines('endmodule')
