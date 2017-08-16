----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2017/08/16 15:53:28
-- Design Name: 
-- Module Name: tb_spi_top - Behavioral
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

entity tb_spi_top is
--  Port ( );
end tb_spi_top;

architecture Behavioral of tb_spi_top is
    constant PERIOD : time := 10ns;
    signal clock : std_logic;
    signal reset_n : std_logic;
    
    -- CPU Interface
    signal addr : std_logic_vector(7 downto 0) := x"00";
    signal din : std_logic_vector(7 downto 0) := x"00";
    signal dout : std_logic_vector(7 downto 0);
    signal wr_en : std_logic := '0';
    signal rd_en : std_logic := '0';
    
    -- SPI Interface
    signal sclk : std_logic;
    signal miso : std_logic;
    signal mosi : std_logic;
    signal ss_n : std_logic_vector(0 downto 0);
begin

process begin
    clock <= '0';
    wait for PERIOD/2;
    clock <= '1';
    wait for PERIOD/2;
end process;

uut : entity work.spi_top
    port map(
        clk => clock,
        reset_n => reset_n,
        addr => addr,
        din => din,
        dout => dout,
        wr_en => wr_en,
        rd_en => rd_en,
        sclk => sclk,
        miso => miso,
        mosi => mosi,
        ss_n => ss_n
    );

process begin
    reset_n <= '1';
    wait for PERIOD * 2;
    reset_n <= '0';
    wait for PERIOD * 2;
    reset_n <= '1';
    wait for PERIOD;
    addr <= x"00";
    din <= x"10";
    wr_en <= '1';
    wait for PERIOD;
    wr_en <= '0';
    wait for PERIOD;
    addr <= x"02";
    din <= x"AA";
    wr_en <= '1';
    wait for PERIOD;
    wr_en <= '0';
    wait;
end process;

end Behavioral;
