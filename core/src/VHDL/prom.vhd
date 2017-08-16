library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity prom is
    Port ( CLK_ip  : in STD_LOGIC;
           ADDR_ip : in STD_LOGIC_VECTOR(12 downto 0);
           DATA_op : out STD_LOGIC_VECTOR(14 downto 0)
         );
end prom;

architecture Behavioral of prom is
    function rom (addr_ip : std_logic_vector(12 downto 0))
    return std_logic_vector is
        variable data_op : std_logic_vector(14 downto 0);
    begin
        case (conv_integer(ADDR_ip)) is
            when 0 => DATA_op := "010111000000001"; -- 
            when 1 => DATA_op := "010110000000011"; -- 
            when 2 => DATA_op := "110000000001010"; -- 
            when 3 => DATA_op := "000000000000000"; -- 
            when 4 => DATA_op := "110000000010100"; -- 
            when 5 => DATA_op := "000000000000000"; -- 
            when 6 => DATA_op := "000000000000000"; -- 
            when 7 => DATA_op := "000000000000000"; -- 
            when 8 => DATA_op := "000000000000000"; -- 
            when 9 => DATA_op := "000000000000000"; -- 
            when 10 => DATA_op := "010111000000001"; -- 
            when 11 => DATA_op := "010110000001010"; -- 
            when 12 => DATA_op := "010111000000000"; -- 
            when 13 => DATA_op := "010000000001010"; -- 
            when 14 => DATA_op := "110000000001101"; -- 
            when 15 => DATA_op := "000000000000000"; -- 
            when 16 => DATA_op := "000000000000000"; -- 
            when 17 => DATA_op := "000000000000000"; -- 
            when 18 => DATA_op := "000000000000000"; -- 
            when 19 => DATA_op := "000000000000000"; -- 
            when 20 => DATA_op := "010111000000001"; -- 
            when 21 => DATA_op := "010110000000011"; -- 
            when 22 => DATA_op := "000001000000000"; -- 
            when 23 => DATA_op := "000000000000000"; -- 
            when 24 => DATA_op := "000000100000000"; -- 
            when others => DATA_op := "000000000000000";
        end case;
        return data_op;
    end rom;

begin
    DATA_op <= rom(ADDR_ip);
end Behavioral;
