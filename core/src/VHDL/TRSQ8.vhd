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
    
    signal peri_addr : std_logic_vector(7 downto 0);
    signal peri_din : std_logic_vector(7 downto 0);
    signal peri_dout : std_logic_vector(7 downto 0);
    signal peri_wr_en : std_logic;
    signal peri_rd_en : std_logic;
    
    signal ram_addr : std_logic_vector(7 downto 0);
    signal ram_din  : std_logic_vector(7 downto 0);
    signal ram_dout : std_logic_vector(7 downto 0);
    signal ram_wr_en : std_logic;
    signal ram_rd_en : std_logic;
    
    -- user added
    signal spi_0_addr : std_logic_vector(7 downto 0);
    signal spi_0_din  : std_logic_vector(7 downto 0);
    signal spi_0_dout : std_logic_vector(7 downto 0);
    signal spi_0_wr_en : std_logic;
    signal spi_0_rd_en : std_logic;
begin

reset <= not reset_n;

cpu_inst: entity work.cpu
    port map(
        clk_ip => clk,
        reset_n_ip => reset_n,
        STATUS => cpu_status,
        prom_addr => prom_addr,
        prom_data => prom_data,
        addr => peri_addr,
        data_in => peri_din,
        data_out => peri_dout,
        wr_en => peri_wr_en,
        rd_en => peri_rd_en,
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
                
                if (ram_wr_en = '1') then
                    if (ram_addr /= x"00") then
                        ram_i(conv_integer(peri_addr)) <= ram_dout;
                    end if;
                end if;
--                ram_data_in <= ram_i(conv_integer(ram_addr));
            end if;
        end if;
    end process;
    ram_din <= ram_i(conv_integer(peri_addr));
    

-- ram_addr  <= peri_addr when (peri_addr >= x"00" and peri_addr <= x"7F") else x"00";
-- ram_dout  <= peri_dout when (peri_addr >= x"00" and peri_addr <= x"7F") else x"00";
ram_addr <= peri_addr;
ram_dout <= peri_dout;
ram_wr_en <= peri_wr_en when (peri_addr >= x"00" and peri_addr <= x"7F") else '0';
ram_rd_en <= peri_rd_en when (peri_addr >= x"00" and peri_addr <= x"7F") else '0';

peri_din  <= ram_din   when (peri_addr >= x"00" and peri_addr <= x"7F") else
             spi_0_din when (peri_addr >= x"80" and peri_addr <= x"83") else
             x"00";


    --
    -- ADD USER IPs
    --
    
    spi_0_addr <= peri_addr;
    spi_0_dout <= peri_dout;
    spi_0_wr_en <= peri_wr_en when (peri_addr >= x"80" and peri_addr <= x"83") else '0';
    spi_0_rd_en <= peri_rd_en when (peri_addr >= x"80" and peri_addr <= x"83") else '0';
    
SPI_INST_0 : entity work.spi_top
    generic map(
        ADDR_LSB => 0,
        OPT_MEM_ADDR_BITS => 1,
        BASE_ADDR => x"80"
    )
    port map(
        clk => clk,
        reset_n => reset_n,
        
        addr  => spi_0_addr,
        din   => spi_0_din,
        dout  => spi_0_dout,
        wr_en => spi_0_wr_en,
        rd_en => spi_0_rd_en,
        
        sclk => sclk,
        miso => miso,
        mosi => mosi,
        ss_n => ss_n
    );
end Behavioral;
