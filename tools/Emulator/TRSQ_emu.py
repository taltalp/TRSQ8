# -*- coding: utf-8 -*-

import logging
import json
import copy
# import numpy as np
# import matplotlib.pyplot as plt

logging.basicConfig(level=logging.DEBUG)

PROM_FILE       = 'prom.bin'
MODULE_SETTINGS = 'modules.json'
PORT_INFO_JSON  = 'portinfo.json'
RAM_DUMP        = 'ram_dump.csv'
PORT_DUMP       = 'port_dump.json'


class trsq8:
    '''
    CPU Emulator
    '''
    # define
    CF = 0
    ZF = 1

    def __init__(self, modules_path):
        '''
        init cpu internal registers
        modules : dict from json
        '''
        self.prom = [0] * 65536  # PROM 
        self.ram  = [0] * 256    # RAM
        self.pc   = 0            # Program Counter 
        self.w    = 0            # Accumulator (Working Register) 
        self.halt = 0            # CPU halt flag 
        self.clock_count = 0     # clock counter

        # load module instances and get port dict
        f = open(modules_path, 'r')
        modules = json.load(f)
        self.modules, self.port = self.__initModules(modules)
        f.close()

    def start(self, prom_path, max_clock):
        '''
        Start TRSQ8 Emulation
        '''
        logging.info('START TRSQ8 EMULATION')

        # open prom bin file
        f = open(prom_path, 'r', encoding='utf-8-sig')
        data = f.read()
        lines = data.split('\n')
        f.close()

        # open portinfo file
        f = open(PORT_INFO_JSON, 'r')
        portinfo = json.load(f)
        f.close()

        # write csv header
        f_ram = open(RAM_DUMP, 'w')
        for i in range(len(self.ram)):
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
            logging.debug('clock = ' + str(self.clock_count) + '\t' + 'pc = ' \
                          + str(self.pc) + '\t')

            # Emulate CPU core and Update registers
            self.decode(self.prom[self.pc])

            # Emulate each modules
            self.__updateModules(portinfo)

            # Dump ram to csv file
            for x in self.ram:
                f_ram.writelines(str(x) + ',')
            f_ram.writelines('\n')

            # Run emulation until max clock period
            if self.clock_count >= max_clock:
                break
            else:
                self.clock_count += 1

        if (self.halt == 1):
            logging.debug('HALT!')

        logging.debug('----------------------------------------------------')
        logging.info(str(self.clock_count) + ' clocks emulation has finished')

       # dump all port status
        with open(PORT_DUMP, 'w') as f:
            json.dump(self.port, f) 

        f_ram.close()
        return

    def decode(self, inst):
        '''
        TRSQ8 Operation Decoder
        '''
        # Immediate Data
        imf = inst & 0xff        # File Register Address
        imb = (inst >> 8) & 0x7  # Bit Address

        # ADD
        if ((inst >> 8) & 0x7f == 0b0100000):
            logging.debug("ADD " + str(hex(imf)))
            # W <- W + F + CF
            self.w = self.w + self.ram[imf] + self.__getStatus(self.CF)
            # Carry Flag
            if(self.__checkCarry(self.w)):
                self.__setStatus(self.CF)
            self.pc += 1

        # SUB
        elif ((inst >> 8) & 0x7f == 0b0100001):
            logging.debug("SUB " + str(hex(imf)))
            # W <- W + F + CF
            self.w = self.w - self.ram[imf] + self.__getStatus(self.CF)
            # Carry Flag
            if(self.__checkCarry(self.w)):
                self.__setStatus(self.CF)
            self.pc += 1

        # MULL
        elif ((inst >> 8) & 0x7f == 0b0100010):
            logging.debug("MULL")
            self.pc += 1

        # MULH
        elif ((inst >> 8) & 0x7f == 0b0100011):
            logging.debug("MULH")
            self.pc += 1

        # UMULL
        elif ((inst >> 8) & 0x7f == 0b0100101):
            logging.debug("UMULL")
            self.pc += 1

        # UMULH
        elif ((inst >> 8) & 0x7f == 0b0100110):
            logging.debug("UMULH")
            self.pc += 1

        # AND
        elif ((inst >> 8) & 0x7f == 0b0100111):
            logging.debug("AND " + str(hex(imf)))
            self.w &= self.ram[imf]
            self.pc += 1

        # OR
        elif ((inst >> 8) & 0x7f == 0b0101000):
            logging.debug("OR " + str(hex(imf)))
            self.w |= self.ram[imf]
            self.pc += 1

        # NOT
        elif ((inst >> 8) & 0x7f == 0b0101001):
            logging.debug("NOT " + str(hex(imf)))
            self.w = ~self.ram[imf]
            self.pc += 1

        # XOR
        elif ((inst >> 8) & 0x7f == 0b0101011):
            logging.debug("XOR " + str(hex(imf)))
            self.w ^= self.ram[imf]
            self.pc += 1

        # BTC
        elif ((inst >> 11) & 0xf == 0b1000):
            logging.debug("BTC")
            self.ram[imf] = self.__bitClear(imb, imf)
            self.pc += 1

        # BTS
        elif ((inst >> 11) & 0xf == 0b1001):
            logging.debug("BTS")
            self.ram[imf] = self.__bitSet(imb, imf)
            self.pc += 1

        # ST
        elif ((inst >> 8) & 0x7f == 0b0101100):
            logging.debug("ST " + str(hex(imf)))
            self.ram[imf] = self.w
            self.pc += 1

        # LD
        elif ((inst >> 8) & 0x7f == 0b0101101):
            logging.debug("LD " + str(hex(imf)))
            self.w = self.ram[imf]
            self.pc += 1

        # LDL
        elif ((inst >> 8) & 0x7f == 0b0101110):
            logging.debug("LDL " + str(hex(imf)))
            self.w = imf
            self.pc += 1

        # STR
        elif ((inst >> 8) & 0x7f == 0b0111100):
            logging.debug("STR " + str(hex(self.ram[3])))
            self.ram[self.ram[3]] = self.w
            self.pc += 1
            
        # LDR
        elif ((inst >> 8) & 0x7f == 0b0111101):
            logging.debug("LDR " + str(hex(self.ram[3])))
            self.w = self.ram[self.ram[3]]
            self.pc += 1

        # SKZ
        elif ((inst >> 8) & 0x7f == 0b0000101):
            logging.debug("SKZ")
            if (self.__getStatus(self.ZF)):
                self.pc += 2 
            else:
                self.pc += 1

        # SKC
        elif ((inst >> 8) & 0x7f == 0b0000110):
            logging.debug("SKC")
            if (self.__getStatus(self.CF)):
                self.pc += 2
            else:
                self.pc += 1

        # NOP
        elif ((inst >> 8) & 0x7f == 0b0000000):
            logging.debug("NOP")
            self.pc += 1

        # HALT
        elif ((inst >> 8) & 0x7f == 0b0000001):
            logging.debug("HALT")
            self.halt = 1

        # GOTO
        elif ((inst >> 13) & 0x3 == 0b11):
            if ((inst & 0x3ff) == 0x3ff):
                # goto address is selected from direct addressing registers
                goto_addr = (self.ram[1] * 256 + self.ram[2]) & 0x3ff
                logging.debug("GOTO " + str(hex(goto_addr)))
                self.pc = goto_addr
            else:
                # goto address is selected from literal
                logging.debug("GOTO " + str(hex(inst & 0x3ff)))
                self.pc = (inst & 0x3ff) 
        else:
            logging.debug("not implemented")
            self.halt = 1

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
            logging.error('error')
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
            logging.error('error')
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

    def __initModules(self, modules):
        '''
        Initialize Module Instances

        decode json and generate each instance
        '''
        module_inst = []
        port_dict = {}
        for module in modules:
            baseaddr = int(modules[module]['BASEADDR'], 16)
            if (modules[module]['MODULE'] == 'GPIO'):
                # append module instance
                module_inst.append(gpio(baseaddr, module))
                # join port status dictionary
                port_dict.update({module:[]})
            elif (modules[module]['MODULE'] == 'SPI'):
                # append module instance
                module_inst.append(spi(baseaddr, module))
                # join port status dictionary
                port_dict.update({module:[]})
        return module_inst, port_dict

    def __updateModules(self, portinfo):
        '''
        Update Module Instances

        '''
        for i in range(len(self.modules)):
            moduleclass = self.modules[i].__class__.__name__
            modulename  = self.modules[i].modulename
            if (moduleclass == 'gpio'):
                if (self.clock_count < len(portinfo[modulename]['IGPIO'])):
                    igpio = portinfo[modulename]['IGPIO'][self.clock_count]
                else:
                    igpio = 0
                # Update module instance
                port = copy.deepcopy(self.modules[i].update(self.ram, igpio))
                # Export port statuses
                self.port[modulename].append(port)

            elif (moduleclass == 'spi'):
                if (self.clock_count < len(portinfo[modulename]['SPIRX'])):
                    rxbuf = portinfo[modulename]['SPIRX'][self.clock_count]
                else:
                    rxbuf = 0
                # Update module instance
                port = copy.deepcopy(self.modules[i].update(self.ram, rxbuf))
                # Export port statuses
                self.port[modulename].append(port)


class gpio:
    '''
    GPIO EMULATOR
    '''
    def __init__(self, baseaddr, modulename):
        self.modulename = modulename
        self.baseaddr = baseaddr
        self.OGPIO = 0
        self.TRIS  = 0
        self.IGPIO = 0
        self.PORT  = ['X', 'X', 'X', 'X', 'X', 'X', 'X', 'X']

    def update(self, ram, igpio):
        self.OGPIO = ram[self.baseaddr + 0x00]
        self.TRIS  = ram[self.baseaddr + 0x01]
        self.IGPIO = igpio & 0xFF
        ram[self.baseaddr + 0x02] = self.IGPIO

        for i in range(8):
            if ((self.TRIS >> i) & 1):      # TRIS bits equal to 1 (Input)
                if ((self.IGPIO >> i) & 1):
                    self.PORT[i] = 'I1'     # Set "IN 1" to PORT bits
                else:
                    self.PORT[i] = 'I0'     # Set "IN 0" to PORT bits
            else:                           # TRIS bits equal to 0 (Output)
                if ((self.OGPIO >> i) & 1):
                    self.PORT[i] = 'O1'     # Set "OUT 1" to PORT bits
                else:
                    self.PORT[i] = 'O0'     # Set "OUT 0" to PORT bits

        logging.debug(self.modulename + ' UPDATE')
        logging.debug(self.PORT)
        return self.PORT


class spi:
    '''
    SPI EMULATOR
    '''
    def __init__(self, baseaddr, modulename):
        self.modulename = modulename
        self.baseaddr  = baseaddr
        self.RXBUF     = ''
        self.TXBUF     = ''
        self.counter   = 0
        self.inTransaction = False
        self.PORT      = ''

    def update(self, ram, rxbuf):
        self.SPICON    = ram[self.baseaddr + 0x0]
        self.SPICLKDIV = ram[self.baseaddr + 0x1]
        self.SPITX     = ram[self.baseaddr + 0x2]
        self.SPIRX     = ram[self.baseaddr + 0x3]

        logging.debug(self.modulename + ' UPDATE')

        # TODO: RXの実装

        # 送信中
        if (self.inTransaction):
            self.SPICON &= 0x11101111   # clear enable flag
            self.SPICON |= 0x1          # busy flag

            # 送信完了 (送信開始から19クロック)
            if (self.counter == 19):
                self.PORT = self.TXBUF  # 送信データがセットされる
                self.counter = 0        # カウンタをリセット
                self.inTransaction = False

            # 送信中
            else:
                self.PORT = ''          # 送信データは空とする
                self.counter = self.counter + 1
                self.inTransaction = True
        else:
            self.PORT = ''              # 出力値は空

            # SPI_ENABLE フラグ建った場合
            if ((self.SPICON >> 4) & 1):
                self.inTransaction = True
                self.TXBUF = self.SPITX  # 値をバッファに保持

        logging.debug(self.PORT)
        return self.PORT


class i2c:
    '''
    I2C Emulator
    '''
    def __init__(self, baseaddr):
        self.baseaddr = baseaddr


if __name__ == '__main__':
    cpu = trsq8(MODULE_SETTINGS)
    cpu.start(PROM_FILE, 40)
