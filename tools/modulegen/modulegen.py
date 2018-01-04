# -*- coding: utf-8 -*- 

'''
This code generates TRSQ8.v Top Module file from modules.json
'''

# TODO:
# replace modules.json
# 使用するモジュールの定義
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
        
# 各モジュールのインスタンスを返す
def module_inst(module):
    if (module['module'] == 'gpio'):
        hdl_text = [
                '    // ' + module['name'] + '_inst\n',
                '    gpio #(\n',
                '        .BASE_ADDR(8\'h' + module['baseaddr'] + '),\n',
                '        .LAST_ADDR(8\'h' + module['lastaddr'] + ')\n',
                '    )' + module['name'] + '_inst',
                '        .clk(clk),\n',
                '        .reset_n(reset_n),\n',
                '        .addr(peri_addr),\n',
                '        .din(peri_din),\n',
                '        .dout(peri_dout),\n',
                '        .wr_en(peri_wr_en),\n',
                '        .rd_en(peri_rd_en),\n',
                '        .port(' + module['name'] + '_port),\n',
                '    );\n',
                '\n'
                ]
        return hdl_text

    elif (module['module'] == 'spi'):
        hdl_text = [
                '    // ' + module['name'] + '_inst\n',
                '    spi #(\n',
                '        .BASE_ADDR(8\'h' + module['baseaddr'] + '),\n',
                '        .LAST_ADDR(8\'h' + module['lastaddr'] + ')\n',
                '    )', module['name'] + '_inst(\n',
                '        .clk(clk),\n',
                '        .reset_n(reset_n),\n',
                '        .addr(peri_addr),\n',
                '        .din(peri_din),\n',
                '        .dout(peri_dout),\n',
                '        .wr_en(peri_wr_en),\n',
                '        .rd_en(peri_rd_en),\n',
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
                '    // ' + module['name'] + '_inst\n',
                '    iic #(\n',
                '        .BASE_ADDR(8\'h' + module['baseaddr'] + '),\n',
                '        .LAST_ADDR(8\'h' + module['lastaddr'] + ')\n',
                '    )' + module['name'] + '_inst(\n',
                '        .clk(clk),\n',
                '        .reset_n(reset_n),\n',
                '        .addr(peri_addr),\n',
                '        .din(peri_din),\n',
                '        .dout(peri_dout),\n',
                '        .wr_en(peri_wr_en),\n',
                '        .rd_en(peri_rd_en),\n',
                '        .sck(' + module['name'] + '_sck),\n',
                '        .sda(' + module['name'] + '_sda),\n',
                '    );\n',
                '\n'
                ]
        return hdl_text
    return

# 各モジュールのポートを返す
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

# 各モジュールのワイヤを返す
def module_wire(module):
    hdl_text = [
            '    // ' + module['name'] + '_inst\n',
            '    wire [7:0] ' + module['name'] + '_addr;\n',
            '    wire [7:0] ' + module['name'] + '_din;\n',
            '    wire [7:0] ' + module['name'] + '_dout;\n',
            '    wire ' + module['name'] + '_wr_en;\n',
            '    wire ' + module['name'] + '_rd_en;\n'
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
    print(module)
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
