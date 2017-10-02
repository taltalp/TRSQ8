# -*- coding: utf-8 -*-
import logging
import numpy as np

logging.basicConfig(level=logging.DEBUG)

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
        logging.info('start emulation')
        # open prom bin file
        f = open(filepath, 'r', encoding='utf-8-sig')
        data = f.read()
        lines = data.split('\n')

        f_ram = open('./ram.csv', 'w');
        for i in range(len(self.ram)) :
            f_ram.writelines(str(i) + ',')
        f_ram.writelines('\n')

        # Load PROM from bin files
        i = 0
        for line in lines:
            if(line != ''):
                self.prom[i] = int(line, 2)
                i += 1

        logging.debug('CLK\tPC\tOperation\tSTATUS')
        logging.debug('----------------------------------------------------')

        # Execute until halt 
        # This is the main routine
        while(self.halt == 0):
            logging.debug('clock = ' + str(self.clock_count) + '\t' + 'pc = ' + str(self.pc) + '\t')
            self.decode(self.prom[self.pc])

            # dump ram to csv file
            for x in self.ram :
                f_ram.writelines(str(x) + ',')
            f_ram.writelines('\n')

            # increment program counter
            self.pc += 1

            # run emulation until max clock period
            if self.clock_count >= max_clock :
                break
            else :
                self.clock_count += 1


        if (self.halt == 1):
            logging.debug('HALT!')

        logging.debug('----------------------------------------------------')
        logging.info(str(self.clock_count) + ' clocks emulation has finished')
        return


    # TRSQ8 operation decoder
    def decode(self, inst):
        # Immediate Data
        imf = inst & 0xf  # File Register Address
        imb = (inst >> 8) & 0x7 # Bit Address

        if ((inst >> 8) & 0x7f == 0b0100000):
            logging.debug("ADD " + str(hex(self.ram[imf])))
            # W <- W + F + CF
            self.w = self.w + self.ram[imf] + self.__getStatus(self.CF)
            # Carry Flag
            if(self.__checkCarry(self.w)):
                self.__setStatus(self.CF)
                
        elif ((inst >> 8) & 0x7f == 0b0100001):
            logging.debug("SUB " + str(hex(self.ram[imf])))
            # W <- W + F + CF
            self.w = self.w - self.ram[imf] + self.__getStatus(self.CF)
            # Carry Flag
            if(self.__checkCarry(self.w)):
                self.__setStatus(self.CF)
                
        elif ((inst >> 8) & 0x7f == 0b0100010):
            logging.debug("MULL")
            # MULL

        elif ((inst >> 8) & 0x7f == 0b0100011):
            logging.debug("MULH")
            # MULH

        elif ((inst >> 8) & 0x7f == 0b0100101):
            logging.debug("UMULL")
            # UMULL

        elif ((inst >> 8) & 0x7f == 0b0100110):
            logging.debug("UMULH")
            # UMULH

        elif ((inst >> 8) & 0x7f == 0b0100111):
            logging.debug("AND " + str(hex(self.ram[imf])))
            self.w &= self.ram[imf]

        elif ((inst >> 8) & 0x7f == 0b0101000):
            logging.debug("OR " + str(hex(self.ram[imf])))
            self.w |= self.ram[imf]

        elif ((inst >> 8) & 0x7f == 0b0101001):
            logging.debug("NOT " + str(hex(self.ram[imf])))
            self.w = ~self.ram[imf]
        elif ((inst >> 8) & 0x7f == 0b0101011):
            logging.debug("XOR " + str(hex(self.ram[imf])))
            self.w ^= self.ram[imf]

        elif ((inst >> 11) & 0xf == 0b1000):
            logging.debug("BTC")
            self.ram[imf] = self.__bitClear(imb, self.ram[imf])

        elif ((inst >> 11) & 0xf == 0b1001):
            logging.debug("BTS")
            self.ram[imf] = self.__bitSet(imb, self.ram[imf])


        elif ((inst >> 8) & 0x7f == 0b0101100):
            logging.debug("ST " + str(hex(self.ram[imf])))
            self.ram[imf] = self.w
        elif ((inst >> 8) & 0x7f == 0b0101101):
            logging.debug("LD " + str(hex(self.ram[imf])))
            self.w = self.ram[imf]
        elif ((inst >> 8) & 0x7f == 0b0101110):
            logging.debug("LDL " + str(hex(self.ram[imf])))
            self.w = imf

        elif ((inst >> 8) & 0x7f == 0b0000101):
            logging.debug("SKZ")
            if (self.__getStatus(self.ZF)):
                self.pc += 1 

        elif ((inst >> 8) & 0x7f == 0b0000110):
            logging.debug("SKC")
            if (self.__getStatus(self.CF)):
                self.pc += 1

        elif ((inst >> 8) & 0x7f == 0b0000000):
            logging.debug("NOP")

        elif ((inst >> 8) & 0x7f == 0b0000001):
            logging.debug("HALT")
            self.halt = 1

        elif ((inst >> 13) & 0x3 == 0b11):
            logging.debug("GOTO")
            self.pc = (inst & 0x3ff) 
        else:
            logging.debug("not implemented")

        # Zero Flag
        if(self.__checkZero(self.w)):
            self.__setStatus(self.ZF)

        logging.debug(bin(self.ram[0]))

        return


    # Set each bits of STATUS 
    def __setStatus(self, num):
        if (num < 8):
            self.ram[0] |= (1 << num)
        else:
            logging.error("error")
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
            logging.error("error")
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
    cpu.start(f, 10000)
