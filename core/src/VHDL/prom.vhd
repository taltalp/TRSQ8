library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity PROM is
    Port ( CLK_ip  : in STD_LOGIC;
           ADDR_ip : in STD_LOGIC_VECTOR(12 downto 0);
           DATA_op : out STD_LOGIC_VECTOR(14 downto 0)
         );
end PROM;

architecture Behavioral of PROM is
    function rom (addr_ip : std_logic_vector(12 downto 0))
    return std_logic_vector is
        variable data_op : std_logic_vector(14 downto 0);
    begin
        case (conv_integer(ADDR_ip)) is
            when 0 => DATA_op := "010111000000001"; -- 
            when 1 => DATA_op := "010110000001010"; -- 
            when 2 => DATA_op := "010000000001010"; -- 
            when 3 => DATA_op := "010110000001010"; -- 
            when 4 => DATA_op := "010110100001011"; -- 
            when 5 => DATA_op := "000000100000000"; -- 
            when others => DATA_op := "000000000000000";
        end case;
        return data_op;
    end rom;

begin
    DATA_op <= rom(ADDR_ip);
end Behavioral;