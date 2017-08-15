----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2017/07/29 17:57:38
-- Design Name: 
-- Module Name: decoder - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity decoder is
    Port ( data_ip : in STD_LOGIC_VECTOR(14 downto 0);
           alu_sel_op : out STD_LOGIC_VECTOR(4 downto 0);
           sk_sel_op  : out STD_LOGIC_VECTOR(1 downto 0);
           muxa_sel_op : out STD_LOGIC;
           muxb_sel_op : out STD_LOGIC;
           sram_addr_op : out STD_LOGIC_VECTOR(7 downto 0);
           sram_ld_op : out STD_LOGIC;
           sram_st_op : out STD_LOGIC;
           nop_op     : out STD_LOGIC;
           halt_op    : out STD_LOGIC;
           jump_op    : out STD_LOGIC;
           return_op  : out STD_LOGIC
           );
end decoder;

architecture Behavioral of decoder is
    signal data : std_logic_vector(14 downto 0);
begin
    data <= data_ip;

    alu_sel_op <= "00000" when data(14 downto 8) = "0100000" else  -- ADD
                  "00001" when data(14 downto 8) = "0100001" else  -- SUB
                  "00010" when data(14 downto 8) = "0100111" else  -- AND
                  "00011" when data(14 downto 8) = "0101000" else  -- OR
                  "00100" when data(14 downto 8) = "0101001" else  -- NOT
                  "00101" when data(14 downto 8) = "0101011" else  -- XOR
                  "01001" when data(14 downto 8) = "0101100" else  -- ST
                  "01000" when data(14 downto 8) = "0101101" else  -- LD
                  "01000" when data(14 downto 8) = "0101110" else  -- LDL
                  "11111";

    sk_sel_op <= "01" when data(14 downto 8) = "0000101" else -- SKZ
                 "10" when data(14 downto 8) = "0000110" else -- SKC
                 "00";

    muxa_sel_op <= '1' when data(14 downto 8) = "0101110" else -- Read from Literal
                   '0'; -- Read from File Regs
    
    muxb_sel_op <= '1' when data(14 downto 13) = "10" else -- Bit instruction
                   '0'; -- from W
    
    sram_addr_op <= data(7 downto 0) when data(14 downto 13) = "01" else
                    data(7 downto 0) when data(14 downto 13) = "10" else
                    (others => '0');
                    
    sram_ld_op <= '1' when data(14 downto 8) = "0101101" else '0';
    sram_st_op <= '1' when data(14 downto 8) = "0101100" else '0';
    
    nop_op  <= '1' when data(14 downto 8) = "0000000" else '0';
    halt_op <= '1' when data(14 downto 8) = "0000001" else '0';
    return_op <= '1' when data(14 downto 8) = "0000010" else '0';
    
    jump_op <= '1' when data(14 downto 13) = "11" else '0';
end Behavioral;