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
    parser = argparse.ArgumentParser(description='mitou cpu assembler')
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
                'library IEEE;\n',
                'use IEEE.STD_LOGIC_1164.ALL;\n',
                'use IEEE.STD_LOGIC_ARITH.ALL;\n',
                'use IEEE.STD_LOGIC_UNSIGNED.ALL;\n',
                'entity PROM is\n',
                '    Port ( CLK_ip  : in STD_LOGIC;\n',
                '           ADDR_ip : in STD_LOGIC_VECTOR(12 downto 0);\n',
                '           DATA_op : out STD_LOGIC_VECTOR(14 downto 0)\n',
                '         );\n',
                'end PROM;\n',
                '\n',
                'architecture Behavioral of PROM is\n',
                '    function rom (addr_ip : std_logic_vector(12 downto 0))\n',
                '    return std_logic_vector is\n',
                '        variable data_op : std_logic_vector(14 downto 0);\n',
                '    begin\n',
                '        case (conv_integer(ADDR_ip)) is\n'
                ]

        vhdl_text_1 = [
                '            when others => DATA_op := "000000000000000";\n',
                '        end case;\n',
                '        return data_op;\n', 
                '    end rom;\n',
                '\n',
                'begin\n',
                '    DATA_op <= rom(ADDR_ip);\n',
                'end Behavioral;\n'
                ]

        text.writelines('-- ' + args.path + '\n')
        text.writelines(vhdl_text_0)

        i = 0
        for line in bit:
            if (line != ''):
                # TODO
                # comment out the original code
                text.write(
                        '            when ' + str(i) + ' => DATA_op := ' + \
                        '"' + line + '"; -- ' + '' + '\n'
                        )
                i += 1

        text.writelines(vhdl_text_1);
