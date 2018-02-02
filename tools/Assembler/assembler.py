#!/usr/bin/env python
# -*- coding: utf-8 -*- 
import re
import logging
import argparse

logging.basicConfig(level=logging.INFO)

parser = argparse.ArgumentParser(\
            description='TRSQ-8 assembler (verilog version)')
parser.add_argument('path')
args = parser.parse_args()

def get_inst(line):
  return line.split()[0]

def assembler(line):
    inst = line[0]
    logging.debug(inst)
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
    elif (inst == 'STR'):
        bit = '011110000000000'
    elif (inst == 'LDR'):
        bit = '011110100000000'
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
        logging.error('err: ' + inst)

    logging.debug(bit)
    return bit

if __name__ == '__main__':
    # Open the file and split by return
    lines_raw = []
    with open(args.path, 'r', encoding='utf-8-sig') as text:
        lines_raw = text.read()
        lines_raw = lines_raw.split('\n')
    
    logging.debug('------- lines_raw -----------')
    logging.debug(lines_raw)
    logging.debug(len(lines_raw))

    # Delete comments
    lines = []
    for line in lines_raw:
        i = line.find('#')
        if (i > -1):
            line = line[0:i]
        lines.append(line)
    del(lines_raw)
    logging.debug('------- lines -----------')
    logging.debug(lines)
    logging.debug(len(lines))

    # Remove blank line 
    asm = []
    for line in lines:
        i = re.search(r'\S', line)
        if (i != None):
            asm.append(line)
    del(lines)
    logging.debug('------- asm -----------')
    logging.debug(asm)
    logging.debug(len(asm))

    # TODO:
    # Delete white-space from ':' to next character
    # asm_shaped = []
    # tmp = ""
    # flag = False
    # for line in asm:
    #     if (flag = True):
    #         line = tmp + line
    #         flag = False

    #     # search characters from ':' to EOL
    #     i = line.find(':')
    #     j = re.search(r'\S', line[i+1:])
    #     if (j == None):
    #         tmp = line[:i]
    #         flag = True

    labels = {}
    lines2 = []
    # Create labels dict.
    label_cache = []
    for line in asm:
      label_m = re.search(r'(\w+):', line)
      if label_m:
        l_name = label_m.group(1)
        label_cache.append(l_name)
        continue
      for l_name in label_cache:
        labels[l_name] = len(lines2)
      label_cache = []
      lines2.append(line)

    logging.debug('------- labels -----------')
    logging.debug(labels)

    # Delete Labels
    asm_nolabels = []
    for line in asm:
        i = line.find(':')
        if (i > -1):
            line = line[i+1:]
        asm_nolabels.append(line)
    del(asm)
    logging.debug('------- asm_nolabels -----------')
    logging.debug(asm_nolabels)
    logging.debug(len(asm_nolabels))

    asm_list = []

    # Replace Labels to each line number
    for line in lines2:
      if get_inst(line) == 'GOTO':
        l_name = line.split()[1]
        ln = labels[l_name]
        asm_list.append(line.replace(l_name, str(ln)))
      else:
        asm_list.append(line)

    # Split lines by white-spaces
    asm_split = []
    for line in asm_list:
        line = line.split()
        asm_split.append(line)
    logging.debug('------- asm_split -----------')
    logging.debug(asm_split)
    logging.debug(len(asm_split))


    logging.debug('------- Start encode -----------')
    bit = []
    for line in asm_split:
        assemble = assembler(line)
        if (assemble != ''):
            bit.append(assemble)

    logging.debug('------- Finish encode -----------')
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
