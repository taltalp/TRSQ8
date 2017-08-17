----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2017/07/29 18:28:07
-- Design Name: 
-- Module Name: tb_trsq8 - Behavioral
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

entity tb_trsq8 is
--  Port ( );
end tb_trsq8;

architecture Behavioral of tb_trsq8 is
    constant PERIOD : time := 10ns;

    signal CLK : std_logic;
    signal reset : std_logic;
    signal irq_i : std_logic;
    
    signal sclk : std_logic;
    signal miso : std_logic;
    signal mosi : std_logic;
    signal ss_n : std_logic_vector(0 downto 0);
begin

    process begin
        CLK <= '0';
        wait for PERIOD/2;
        CLK <= '1';
        wait for PERIOD/2;
    end process;

uut : entity work.trsq8
    port map(
        clk => CLK,
        reset_n => reset,
        irq => irq_i,
        
        sclk => sclk,
        miso => miso,
        mosi => mosi,
        ss_n => ss_n
    );

    process begin
        reset <= '1';
        irq_i <= '0';
        wait for PERIOD;
        reset <= '0';
        wait for PERIOD;
        reset <= '1';
--        wait for PERIOD * 30 + 10ns;
--        irq_i <= '1';
--        wait for 4ns;
--        irq_i <= '0';
        wait;
    end process;

    
end Behavioral;