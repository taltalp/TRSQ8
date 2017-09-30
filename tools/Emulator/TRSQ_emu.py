# -*- coding: utf-8 -*-
import numpy as np


class cpu:
    """ """

    # define
    CF = 0
    ZF = 1

    def __init__(self):
        self.prom = [0] * 65536 # PROM 
        self.ram = [0] * 256    # RAM
        self.pc = 0             # Program Counter 
        self.w = 0              # Accumulator (Working Register) 
        self.halt = 0           # CPU halt flag 
        self.clock_count = 0    # clock counter


    def start(self, filepath, max_clock):
        # open prom bin file
        f = open(filepath, 'r', encoding='utf-8-sig')
        data = f.read()
        lines = data.split('\n')

        f_ram = open('./ram.csv', 'w');

        # Load PROM from bin files
        i = 0
        for line in lines:
            if(line != ''):
                self.prom[i] = int(line, 2)
                i += 1

        print('CLK\tPC\tOperation\tSTATUS')
        print('----------------------------------------------------')

        # Execute until halt 
        # This is the main routine
        while(self.halt == 0):
            print(str(self.clock_count) + '\t' + str(self.pc) + '\t', end='')
            self.decode(self.prom[self.pc])

            # dump ram to csv file
            f_ram.writelines(str(self.ram) + '\n')

            # increment program counter
            self.pc += 1

            # run emulation until max clock period
            if self.clock_count >= max_clock :
                break
            else :
                self.clock_count += 1


        if (self.halt == 1):
            print('HALT!')

        # Dump SRAM
        # i = 0
        # print('-----CORE DUMP-----')
        # for data in self.ram:
        #     print(i, end='')
        #     print('\t', end='')
        #     print(data)
        #     i += 1

        print('----------------------------------------------------')
        print(str(self.clock_count) + ' clocks emulation has finished')
        return


    # TRSQ8 operation decoder
    def decode(self, inst):
        # Immediate Data
        imf = inst & 0xf  # File Register Address
        imb = (inst >> 8) & 0x7 # Bit Address

        if ((inst >> 8) & 0x7f == 0b0100000):
            print("ADD " + str(hex(self.ram[imf])), end='')
            # W <- W + F + CF
            self.w = self.w + self.ram[imf] + self.__getStatus(self.CF)
            # Carry Flag
            if(self.__checkCarry(self.w)):
                self.__setStatus(self.CF)
                
        elif ((inst >> 8) & 0x7f == 0b0100001):
            print("SUB " + str(hex(self.ram[imf])), end='')
            # W <- W + F + CF
            self.w = self.w - self.ram[imf] + self.__getStatus(self.CF)
            # Carry Flag
            if(self.__checkCarry(self.w)):
                self.__setStatus(self.CF)
                
        elif ((inst >> 8) & 0x7f == 0b0100010):
            print("MULL", end='')
            # MULL

        elif ((inst >> 8) & 0x7f == 0b0100011):
            print("MULH", end='')
            # MULH

        elif ((inst >> 8) & 0x7f == 0b0100101):
            print("UMULL", end='')
            # UMULL

        elif ((inst >> 8) & 0x7f == 0b0100110):
            print("UMULH", end='')
            # UMULH

        elif ((inst >> 8) & 0x7f == 0b0100111):
            print("AND " + str(hex(self.ram[imf])), end='')
            self.w &= self.ram[imf]

        elif ((inst >> 8) & 0x7f == 0b0101000):
            print("OR " + str(hex(self.ram[imf])), end='')
            self.w |= self.ram[imf]

        elif ((inst >> 8) & 0x7f == 0b0101001):
            print("NOT " + str(hex(self.ram[imf])), end='')
            self.w = ~self.ram[imf]
        elif ((inst >> 8) & 0x7f == 0b0101011):
            print("XOR " + str(hex(self.ram[imf])), end='')
            self.w ^= self.ram[imf]

        elif ((inst >> 11) & 0xf == 0b1000):
            print("BTC", end='')
            self.ram[imf] = self.__bitClear(imb, self.ram[imf])

        elif ((inst >> 11) & 0xf == 0b1001):
            print("BTS", end='')
            self.ram[imf] = self.__bitSet(imb, self.ram[imf])


        elif ((inst >> 8) & 0x7f == 0b0101100):
            print("ST " + str(hex(self.ram[imf])), end='')
            self.ram[imf] = self.w
        elif ((inst >> 8) & 0x7f == 0b0101101):
            print("LD " + str(hex(self.ram[imf])), end='')
            self.w = self.ram[imf]
        elif ((inst >> 8) & 0x7f == 0b0101110):
            print("LDL " + str(hex(self.ram[imf])), end='')
            self.w = imf

        elif ((inst >> 8) & 0x7f == 0b0000101):
            print("SKZ", end='')
            if (self.__getStatus(self.ZF)):
                self.pc += 1 

        elif ((inst >> 8) & 0x7f == 0b0000110):
            print("SKC", end='')
            if (self.__getStatus(self.CF)):
                self.pc += 1

        elif ((inst >> 8) & 0x7f == 0b0000000):
            print("NOP", end='')

        elif ((inst >> 8) & 0x7f == 0b0000001):
            print("HALT", end='')
            self.halt = 1

        elif ((inst >> 13) & 0x3 == 0b11):
            print("GOTO", end='')
            self.pc = (inst & 0x3ff) 
        else:
            print("not implemented", end='')

        # Zero Flag
        if(self.__checkZero(self.w)):
            self.__setStatus(self.ZF)

        print('\t\t', end='')
        print(bin(self.ram[0]))

        return


    # Set each bits of STATUS 
    def __setStatus(self, num):
        if (num < 8):
            self.ram[0] |= (1 << num)
        else:
            print("error")
            self.halt = 1
        return


    # Get each bits of STATUS 
    def __getStatus(self, num):
        status = self.ram[0]
        if (num < 8):
            status >>= num
            status &= 1 
            return status
        else:
            print("error")
            self.halt = 1
            return 0


    # Check Carry 
    def __checkCarry(self, num):
        if(num > 255):
            self.w &= 0xFF
            return 1
        else:
            return 0


    # Check Zero 
    def __checkZero(self, num):
        if (num & 0xFF == 0):
            return 1
        else:
            return 0

    
    # Set Bit
    def __bitSet(self, bit, data):
        return (data | (1 << bit)) & 0xFF


    # Clear Bit 
    def __bitClear(self, bit, data):
        return (data & (0xFF - (1 << bit))) & 0xFF
        

if __name__ == '__main__':
    cpu = cpu()
    f = "prom.bin"
    cpu.start(f, 100)
