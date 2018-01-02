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
    else:
        print('err')
    return bit

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='TRSQ-8 assembler (verilog version)')
    parser.add_argument('path')
    args = parser.parse_args()
    
    # Open the file and split by return
    lines_raw = []
    with open(args.path, 'r', encoding='utf-8-sig') as text:
        lines_raw = text.read()
        lines_raw = lines_raw.split('\n')
    
    print('------- lines_raw -----------')
    print(lines_raw)
    print(len(lines_raw))

    # Delete comments
    lines = []
    for line in lines_raw:
        i = line.find('#')
        if (i > -1):
            line = line[0:i]
        lines.append(line)
    del(lines_raw)
    print('------- lines -----------')
    print(lines)
    print(len(lines))

    # TODO:
    # Delete white-space from ':' to next character
    # lines2 = []
    # for line in lines:
    #     i = line.find(':')
    #     if (i > -1):
    #         j = re.search(r'[a-z]+', line[i:]) 
    #         if (j == -1):

    # Remove blank line 
    asm = []
    for line in lines:
        i = re.search(r'\S', line)
        if (i != None):
            asm.append(line)
    del(lines)
    print('------- asm -----------')
    print(asm)
    print(len(asm))
    
    # Assiciate label with a line number
    labels = []
    cnt = 0
    for line in asm:
        i = line.find(':')
        if (i > -1):
            labels.append([line[:i], cnt])
        cnt += 1
    print('------- labels -----------')
    print(labels)

    # Delete Labels
    asm_nolabels = []
    for line in asm:
        i = line.find(':')
        if (i > -1):
            line = line[i+1:]
        asm_nolabels.append(line)
    del(asm)
    print('------- asm_nolabels -----------')
    print(asm_nolabels)
    print(len(asm_nolabels))

    # Replace Labels to each line number
    asm_replaced = []
    for line in asm_nolabels:
        for label in labels:
            i = re.search(label[0], line)
            if (i != None):
                line = line.replace(label[0], str(label[1]), 1)
        asm_replaced.append(line)
    del(asm_nolabels)
    print('------- asm_replaced -----------')
    print(asm_replaced)
    print(len(asm_replaced))

    # Split lines by white-spaces
    asm_split = []
    for line in asm_replaced:
        line = line.split()
        asm_split.append(line)
    del(asm_replaced)
    print('------- asm_split -----------')
    print(asm_split)
    print(len(asm_split))


    print('------- Start encode -----------')
    # 命令のエンコード
    bit = []
    for line in asm_split:
        # print(line)
        assemble = assembler(line)
        if (assemble != ''):
            bit.append(assemble)

    print('------- Finish encode -----------')
    # write bin file
    with open('./prom.bin', 'w', encoding='utf-8-sig') as text:
        for line in bit:
            text.write(line)
            text.write('\n')

    # write VHDL entity file
    with open('./prom.v', 'w', encoding='utf-8-sig') as text:
        hdl_text_0 = [
                'module prom (\n',
                '    input CLK_ip,\n',
                '    input [12:0] ADDR_ip,\n',
                '    output [14:0] DATA_op);\n',
                '\n',
                '    assign DATA_op = \n'
                ]

        hdl_text_1 = [
                '                           15\'b000000000000000;\n',
                'endmodule\n'
                ]

        text.writelines('// ' + args.path + '\n')
        text.writelines(hdl_text_0)

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

        text.writelines(hdl_text_1);
