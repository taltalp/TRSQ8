----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2017/07/29 18:02:50
-- Design Name: 
-- Module Name: TRSQ8 - Behavioral
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

entity TRSQ8 is
  Port (
      clk : in std_logic;
      reset_n : in std_logic ;
      irq : in std_logic
  );
end TRSQ8;

architecture Behavioral of TRSQ8 is
    signal reset : std_logic;
    
    signal prom_addr : std_logic_vector(12 downto 0);
    signal prom_data : std_logic_vector(14 downto 0);
    
    signal ram_addr : std_logic_vector(7 downto 0);
    signal ram_data_in : std_logic_vector(7 downto 0);
    signal ram_data_out : std_logic_vector(7 downto 0);
    -- user added
    signal spi_addr : std_logic_vector(7 downto 0);
    signal spi_data : std_logic_vector(7 downto 0);
begin

reset <= not reset_n;

cpu_inst: entity work.cpu
    port map(
        clk_ip => clk,
        reset_n_ip => reset_n,
        prom_addr => prom_addr,
        prom_data => prom_data,
        addr => ram_addr,
        data_in => x"00",
        data_out => ram_data_out,
        irq_ip => irq
    );

PROM_INST : entity work.prom
    port map(
        CLK_ip => clk,
        ADDR_ip => prom_addr,
        DATA_op => prom_data
    );

    --
    -- ADD USER IPs
    --
--SWITCH : process (clk) begin
--    if (reset = '1') then
    
--    else
--        case (ram_addr) is
--            when x"00" => spi_addr <= ram_addr;
--        end case;
--    end if;
--end process;
    
--SPI_0_INST : entity work.spi
--    port map(
--        CLK_ip => clk,
--        ADDR_ip => spi_addr,
--        DATA_dp => spi_data
--    );
end Behavioral;
