# -*- coding: utf-8 -*- 
import re
import argparse


def assembler(line):
    inst = line[0]
    bit = ''
    if (inst == 'ADD'):
        bit = '0100000' + format(int(line[1]), 'b').zfill(8)
    elif (inst == 'SUB'):
        bit = '0100001' + format(int(line[1]), 'b').zfill(8)
    elif (inst == 'AND'):
        bit = '0100111' + format(int(line[1]), 'b').zfill(8)
    elif (inst == 'OR'):
        bit = '0101000' + format(int(line[1]), 'b').zfill(8)
    elif (inst == 'NOT'):
        bit = '0101001' + format(int(line[1]), 'b').zfill(8)
    elif (inst == 'XOR'):
        bit = '0101011' + format(int(line[1]), 'b').zfill(8)
    elif (inst == 'BTC'):
        bit = '1000' + format(int(line[1]), 'b').zfill(3) \
                     + format(int(line[2]), 'b').zfill(8)
    elif (inst == 'BTS'):
        bit = '1001' + format(int(line[1]), 'b').zfill(3) \
                     + format(int(line[2]), 'b').zfill(8)
    elif (inst == 'ST'):
        bit = '0101100' + format(int(line[1]), 'b').zfill(8)
    elif (inst == 'LD'):
        bit = '0101101' + format(int(line[1]), 'b').zfill(8)
    elif (inst == 'LDL'):
        bit = '0101110' + format(int(line[1]), 'b').zfill(8)
    elif (inst == 'SKZ'):
        bit = '000010100000000' 
    elif (inst == 'SKC'):
        bit = '000011000000000'
    elif (inst == 'NOP'):
        bit = '000000000000000'
    elif (inst == 'HALT'):
        bit = '000000100000000'
    elif (inst == 'GOTO'):
        bit = '11' + format(int(line[1]), 'b').zfill(13)
    elif (inst == 'RETURN'):
        bit = '000001000000000'
    elif (inst == ''):
        bit = '' 
    else:
        print('err')
    return bit

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='TRSQ-8 assembler')
    parser.add_argument('path')
    args = parser.parse_args()
    
    lines = []
    with open(args.path, 'r', encoding='utf-8-sig') as text:
        lines = text.read()
        lines = lines.split('\n')
    
    bit = []
    for line in lines:
        # remove comment
        i = line.find('#') 
        if (i > -1):
            line = line[0:i]
        # split by whitespace
        line = re.split(' +', line)
        assemble = assembler(line)
        if (assemble != ''):
            bit.append(assemble)

    # write bin file
    with open('./prom.bin', 'w', encoding='utf-8-sig') as text:
        for line in bit:
            text.write(line)
            text.write('\n')

    # write VHDL entity file
    with open('./prom.vhd', 'w', encoding='utf-8-sig') as text:
        vhdl_text_0 = [
                'module prom (\n',
                '    input CLK_ip,\n',
                '    input [12:0] ADDR_ip,\n',
                '    output [14:0] DATA_op);\n',
                '\n',
                '    assign DATA_op = \n'
                ]

        vhdl_text_1 = [
                '                           15\'b000000000000000;\n',
                'endmodule\n'
                ]

        text.writelines('-- ' + args.path + '\n')
        text.writelines(vhdl_text_0)

        i = 0
        for line in bit:
            if (line != ''):
                # TODO
                # comment out the original code
                text.write(
                        '        ADDR_ip==13\'d' + str(i) + ' ? ' + \
                                '15\'b' + line + ': // ' + '' + '\n'
                        )
                i += 1

        text.writelines(vhdl_text_1);
