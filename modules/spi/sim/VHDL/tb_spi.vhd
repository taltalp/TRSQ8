----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2017/08/13 19:42:04
-- Design Name: 
-- Module Name: tb_spi - Behavioral
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

entity tb_spi is
--  Port ( );
end tb_spi;

architecture Behavioral of tb_spi is
    constant PERIOD : time := 10ns;
    signal clock : std_logic;
    signal reset_n : std_logic;
    
    signal mosi, miso : std_logic;
    signal sclk : std_logic;
    signal ss_n : std_logic_vector(0 downto 0);
    signal rx_data : std_logic_vector(7 downto 0);
    signal busy : std_logic;
    signal enable : std_logic;
begin

process begin
    clock <= '0';
    wait for PERIOD/2;
    clock <= '1';
    wait for PERIOD/2;
end process;

uut : entity work.spi
    generic map(
        slaves => 1,
        d_width => 8
    )
    port map(
        clock => clock,
        reset_n => reset_n,
        enable => enable,
        cpol => '1',
        cpha => '1',
        cont => '0',
        clk_div => 0,
        addr => 0,
        tx_data => x"1B",
        miso => miso,
        sclk => sclk,
        ss_n => ss_n,
        mosi => mosi,
        busy => busy,
        rx_data => rx_data
    );

process begin
    enable <= '0';
    wait for PERIOD * 3;
    enable <= '1';
    wait for PERIOD * 2;
    enable <= '0';
    wait;
end process;

end Behavioral;
