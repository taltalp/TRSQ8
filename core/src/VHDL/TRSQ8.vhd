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
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity TRSQ8 is
  Port (
      clk     : IN STD_LOGIC;
      reset_n : IN STD_LOGIC;
      irq     : IN STD_LOGIC;
      
      -- User Logic
      sclk : BUFFER STD_LOGIC;
      miso : IN STD_LOGIC;
      mosi : out STD_LOGIC;
      ss_n : BUFFER STD_LOGIC_VECTOR(0 downto 0)
  );
end TRSQ8;

architecture Behavioral of TRSQ8 is
    signal reset : std_logic;
    signal cpu_status : std_logic_vector(7 downto 0);
    
    -- SRAM
    type ram_t is array (0 to 255) of std_logic_vector(7 downto 0);
    signal ram_i : ram_t;
    
    signal prom_addr : std_logic_vector(12 downto 0);
    signal prom_data : std_logic_vector(14 downto 0);
    
    signal ram_addr : std_logic_vector(7 downto 0);
    signal ram_data_in : std_logic_vector(7 downto 0);
    signal ram_data_out : std_logic_vector(7 downto 0);
    signal wr_en : std_logic;
    signal rd_en : std_logic;
    -- user added
    signal spi_addr : std_logic_vector(7 downto 0);
    signal spi_data : std_logic_vector(7 downto 0);
begin

reset <= not reset_n;

cpu_inst: entity work.cpu
    port map(
        clk_ip => clk,
        reset_n_ip => reset_n,
        STATUS => cpu_status,
        prom_addr => prom_addr,
        prom_data => prom_data,
        addr => ram_addr,
        data_in => ram_data_in,
        data_out => ram_data_out,
        wr_en => wr_en,
        rd_en => rd_en,
        irq_ip => irq
    );

PROM_INST : entity work.prom
    port map(
        CLK_ip => clk,
        ADDR_ip => prom_addr,
        DATA_op => prom_data
    );

RAM_process: process (clk) begin
        if (rising_edge(clk)) then
            if (reset = '1') then
                ram_i <= (others => x"00");
            else
                ram_i(0) <= cpu_status;
                
                if (wr_en = '1') then
                    if (ram_addr /= x"00") then
                        ram_i(conv_integer(ram_addr)) <= ram_data_out;
                    end if;
                end if;
--                ram_data_in <= ram_i(conv_integer(ram_addr));
            end if;
        end if;
    end process;
    ram_data_in <= ram_i(conv_integer(ram_addr));
    

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
    
--SPI_INST_0 : entity work.spi_top
--    port map(
--        clk => clk,
--        reset_n => reset_n,
        
--        addr  => addr,
--        din   => din,
--        dout  => dout,
--        wr_en => wr_en,
--        rd_en => rd_en,
        
--        sclk => sclk,
--        miso => miso,
--        mosi => mosi,
--        ss_n => ss_n
--    );
end Behavioral;
