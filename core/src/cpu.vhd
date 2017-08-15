----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2017/07/29 18:13:12
-- Design Name: 
-- Module Name: cpu - Behavioral
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity cpu is
    Port ( CLK_ip : in STD_LOGIC;
           reset_n_ip : in STD_LOGIC;
           
           -- program rom
           prom_addr  : out std_logic_vector(12 downto 0);
           prom_data  : in  std_logic_vector(14 downto 0);
           
           -- peripheral bus
           addr       : out std_logic_vector(7 downto 0);
           data_in    : in std_logic_vector(7 downto 0);
           data_out   : out std_logic_vector(7 downto 0);
           
           -- interruputs
           irq_ip : in STD_LOGIC);
end cpu;

architecture Behavioral of cpu is
    signal reset : std_logic;

    -- PROM
    signal prom_addr_s : std_logic_vector(12 downto 0);
    signal prom_stack : std_logic_vector(12 downto 0);

    -- ALU
    signal alu_in_a : std_logic_vector(7 downto 0); 
    signal alu_in_b : std_logic_vector(7 downto 0); 
    signal alu_in_cf : std_logic;
    signal alu_in_sel : std_logic_vector(4 downto 0);
    signal alu_out : std_logic_vector(7 downto 0);
    signal alu_out_cf : std_logic;
    signal alu_out_cf_r : std_logic;
    signal alu_out_zf : std_logic;
    
    signal alu_out_r : std_logic_vector(7 downto 0);
    signal alu_out_stack : std_logic_vector(7 downto 0);
    
    -- MUX
    signal muxa_sel : std_logic;
    signal muxb_sel : std_logic;
    
    -- SRAM
    type ram_t is array (0 to 255) of std_logic_vector(7 downto 0);
    signal ram_i : ram_t;
        
    signal ram_addr : std_logic_vector(7 downto 0);
    signal ram_dout : std_logic_vector(7 downto 0);
    signal ram_ld : std_logic;
    signal ram_st : std_logic;
    
    signal nop_i  : std_logic;
    signal halt_i : std_logic;
    signal sk_i : std_logic;
    signal sk_sel : std_logic_vector(1 downto 0);
    
    -- IRQ
    signal irq_i : std_logic;
    signal irq_pre0_i : std_logic;
    signal irq_pre_i : std_logic;
    signal irq_r : std_logic_vector(7 downto 0) := (others => '0');
    signal return_i : std_logic;
    
    -- registers
    signal status_r : std_logic_vector(7 downto 0);
    signal jmp_i : std_logic;
    signal halt_r : std_logic;
    
    -- FLAGS
    signal ZF_s : std_logic;
    signal CF_s : std_logic;
    
    function decode3to8 (data_ip : std_logic_vector(2 downto 0)) 
    return std_logic_vector is
        variable data_op : std_logic_vector(7 downto 0);
    begin
        case (data_ip) is
            when "000" => data_op := x"01";
            when "001" => data_op := x"02";
            when "010" => data_op := x"04";
            when "011" => data_op := x"08";
            when "100" => data_op := x"10";
            when "101" => data_op := x"20";
            when "110" => data_op := x"40";
            when "111" => data_op := x"80";
            when others => null;
        end case;
        return data_op;
    end decode3to8;
    
begin

    reset <= not reset_n_ip;

DECODER_INST : entity work.decoder
    port map(
        data_ip => prom_data,
        alu_sel_op => alu_in_sel,
        sk_sel_op  => sk_sel,
        muxa_sel_op => muxa_sel,
        muxb_sel_op => muxb_sel,
        sram_addr_op => ram_addr,
        sram_ld_op => ram_ld,
        sram_st_op => ram_st,
        nop_op     => nop_i,
        halt_op    => halt_i,
        jump_op    => jmp_i,
        return_op  => return_i
    );

ALU_INST : entity work.alu
    port map(
        A_ip   => alu_in_a,
        B_ip   => alu_in_b,
        CF_ip  => CF_s,
        SEL_ip => alu_in_sel,
        O_op   => alu_out,
        CF_op  => alu_out_cf,
        ZF_op  => open
    );

    -- STATUS REGISTER
    process (CLK_ip) begin
        if (rising_edge(CLK_ip)) then
            status_r <= "000000" & alu_out_zf & alu_out_cf_r;
        end if;
    end process;
    CF_s <= status_r(0);
    ZF_s <= status_r(1);

    -- MUX A
    alu_in_a <= prom_data(7 downto 0) when muxa_sel = '1' else
                ram_dout;
    -- MUX B
    alu_in_b <= decode3to8(prom_data(10 downto 8)) when muxb_sel = '1' else
                alu_out_r;

    -- W Register
    process (CLK_ip) begin
        if (rising_edge(CLK_ip)) then
            if (reset = '1') then
                alu_out_r <= (others => '0');
                alu_out_cf_r <= '0';
            elsif (nop_i = '1' or halt_i = '1' or jmp_i = '1' or sk_sel /= "00") then
                alu_out_r <= alu_out_r;
                alu_out_cf_r <= alu_out_cf_r;
            elsif (irq_i = '1' and irq_pre_i = '0') then
                alu_out_stack <= alu_out_r;
                alu_out_r <= alu_out;
--                irq_pre_i <= '1';
            elsif (return_i = '1') then
                alu_out_r <= alu_out_stack;
            else
--                irq_pre_i <= '0';
                alu_out_r <= alu_out;
                alu_out_cf_r <= alu_out_cf;
            end if;
        end if;
    end process;

    alu_out_zf <= '1' when alu_out_r = x"00" else '0';

    -- RAM
    process (CLK_ip) begin
        if (rising_edge(CLK_ip)) then
            if (reset = '1') then
                ram_i <= (others => x"00");
            else
                ram_i(0) <= status_r;
                
                if (ram_st = '1') then
                    if (ram_addr /= x"00") then
                        ram_i(conv_integer(ram_addr)) <= alu_out_r;
                    end if;
                end if;
            end if;
        end if;
    end process;

    ram_dout <= ram_i(conv_integer(ram_addr));

    -- PC
    process (CLK_ip) begin
        if (falling_edge(CLK_ip)) then
            if (reset = '1') then
                prom_addr_s <= (others => '0');
            elsif (halt_i = '1') then
                prom_addr_s <= prom_addr_s;
            else
                if (jmp_i = '1') then
                    prom_addr_s <= prom_data(12 downto 0);
                elsif (sk_i ='1') then
                    prom_addr_s <= prom_addr_s + 2;
                elsif (irq_i = '1' and irq_pre_i = '0') then
                    prom_addr_s <= conv_std_logic_vector(4, 13);
                    irq_pre_i <= '1';
                    prom_stack <= prom_addr_s;
                elsif (return_i = '1') then
                    prom_addr_s <= prom_stack;
                else
                    irq_pre_i <= '0';
                    prom_addr_s <= prom_addr_s + 1;
                end if;
            end if;
        end if;
    end process;

    prom_addr <= prom_addr_s;

    -- SKIP
    sk_i <= (sk_sel(0) and ZF_s) or (sk_sel(1) and CF_s);

    -- STATUS
    process (CLK_ip) begin
        if (rising_edge(CLK_ip)) then
            if (reset = '1') then
                halt_r <= '0';
            else
                halt_r <= halt_i;
            end if;
        end if;
    end process;

    -- IRQ
    process (CLK_ip, irq_ip) begin
        if (irq_ip = '1') then
            irq_r(1) <= '1';
        elsif (rising_edge(CLK_ip)) then
            if (ram_addr = x"03") then
                irq_r <= alu_out_r;
            end if;
        end if;
    end process;

    irq_i <= irq_r(1) and irq_r(0); -- IRQ & IRQ_EN 
end Behavioral;