----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2017/08/14 12:22:02
-- Design Name: 
-- Module Name: spi_top - Behavioral
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

entity spi_top is
    Port ( clk : in STD_LOGIC;
           reset_n : in STD_LOGIC;
           
           -- CPU Interface
           addr : in  STD_LOGIC_VECTOR(7 downto 0);
           din  : in  STD_LOGIC_VECTOR(7 downto 0);
           dout : out STD_LOGIC_VECTOR(7 downto 0);
           wr_en : in STD_LOGIC;
           rd_en : in STD_LOGIC;
           
           -- SPI Interface
           sclk : BUFFER STD_LOGIC;
           miso : in  STD_LOGIC;
           mosi : out STD_LOGIC;
           ss_n : BUFFER STD_LOGIC_VECTOR(0 downto 0)
           );
end spi_top;

architecture Behavioral of spi_top is
    constant ADDR_LSB : integer := 1;
    constant OPT_MEM_ADDR_BITS : integer := 1;
    
    signal spi_busy : std_logic;
    signal spi_rx : std_logic_vector(7 downto 0);
    
    -- Slave Registers
    signal SPICON    : std_logic_vector(7 downto 0); -- loc_addr = 0x0
    signal SPICLKDIV : std_logic_vector(7 downto 0); -- loc_addr = 0x1
    signal SPITX     : std_logic_vector(7 downto 0); -- loc_addr = 0x2
    signal SPIRX     : std_logic_vector(7 downto 0); -- loc_addr = 0x3
begin

write_process: process (clk) 
        variable loc_addr : std_logic_vector(OPT_MEM_ADDR_BITS downto 0);
    begin
    
    loc_addr := addr(ADDR_LSB + OPT_MEM_ADDR_BITS downto ADDR_LSB);
    
    if (clk'event) then
        if (clk = '1') then
            if (wr_en = '1') then  -- WRITE STATE
                case (loc_addr) is
                    when b"00" =>
                        SPICON <= din;
                    when b"01" =>
                        SPICLKDIV <= din;
                    when b"10" =>
                        SPITX <= din;
                    when b"11" =>
                        SPIRX <= din;
                    when others =>
                        
                end case;
            elsif (rd_en = '1') then  -- READ STATE
                case (loc_addr) is
                    when b"00" =>
                        dout <= SPICON;
                    when b"01" =>
                        dout <= SPICLKDIV;
                    when b"10" =>
                        dout <= SPITX;
                    when b"11" =>
                        dout <= SPIRX;
                    when others =>
                        dout <= (others => '0');
                end case;
            end if;
        elsif (clk = '0') then
            -- FETCH STATE
            SPICON <= SPICON(7 downto 1) & spi_busy;
            SPIRX <= spi_rx;
        end if;
    end if;
end process;

spi_core : entity work.spi
    generic map(
        slaves => 1,
        d_width => 8
    )
    port map(
        clock => clk,
        reset_n => reset_n,
        enable => SPICON(4),
        cpol => SPICON(1),
        cpha => SPICON(2),
        cont => SPICON(3),
        clk_div => 0,
        addr => 0,
        tx_data => SPITX,
        miso => miso,
        sclk => sclk,
        ss_n => ss_n,
        mosi => mosi,
        busy => spi_busy,
        rx_data => spi_rx
    );

end Behavioral;
