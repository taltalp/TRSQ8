----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2017/07/29 17:53:40
-- Design Name: 
-- Module Name: alu - Behavioral
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

entity alu is
    Port ( A_ip  : in STD_LOGIC_VECTOR(7 downto 0);  -- A
           B_ip  : in STD_LOGIC_VECTOR(7 downto 0);  -- B
           CF_ip : in STD_LOGIC;  -- Carry In
           SEL_ip : in STD_LOGIC_VECTOR(4 downto 0); -- Operation Select
           O_op : out STD_LOGIC_VECTOR(7 downto 0);  -- Output
           CF_op : out STD_LOGIC;  -- Carry Flag
           ZF_op : out STD_LOGIC   -- Zero Flag
           );
end alu;

architecture Behavioral of alu is
    signal alu_a_i : std_logic_vector(7 downto 0);
    signal alu_b_i : std_logic_vector(7 downto 0);
    signal alu_c_i : std_logic;
    signal alu_sel_i : std_logic_vector(4 downto 0);
    signal alu_o_i : std_logic_vector(7 downto 0);
    
    signal alu_sum_i : std_logic_vector(8 downto 0);
    signal alu_sub_i : std_logic_vector(8 downto 0);
    
    signal alu_and_i : std_logic_vector(7 downto 0);
    signal alu_or_i  : std_logic_vector(7 downto 0);
    signal alu_not_i : std_logic_vector(7 downto 0);
    signal alu_xor_i : std_logic_vector(7 downto 0);
    
    signal alu_bs_i : std_logic_vector(7 downto 0);
    signal alu_bc_i : std_logic_vector(7 downto 0);
begin
    alu_a_i <= A_ip;
    alu_b_i <= B_ip;
    O_op <= alu_o_i;

    alu_c_i   <= CF_ip;  -- Carry In
    alu_sel_i <= SEL_ip; -- Operation Select
    
    alu_sum_i <= ('0' & alu_a_i) + ('0' & alu_b_i) + ("0000000" & alu_c_i); -- ADD A + B + CF
    alu_sub_i <= ('0' & alu_a_i) - ('0' & alu_b_i) + ("0000000" & alu_c_i); -- SUB A - B + CF

    alu_and_i <= alu_a_i and alu_b_i; -- AND
    alu_or_i  <= alu_a_i or  alu_b_i; -- OR
    alu_not_i <= not alu_a_i;         -- NOT (A)
    alu_xor_i <= alu_a_i xor alu_b_i; -- XOR

    alu_bs_i <= alu_a_i and alu_b_i;       -- Bit Set A bit B
    alu_bc_i <= alu_a_i and (not alu_b_i); -- Bit Clear A bit B

    alu_o_i <= alu_sum_i(7 downto 0) when alu_sel_i = "00000" else
               alu_sub_i(7 downto 0) when alu_sel_i = "00001" else
               alu_and_i             when alu_sel_i = "00010" else
               alu_or_i              when alu_sel_i = "00011" else
               alu_not_i             when alu_sel_i = "00100" else
               alu_xor_i             when alu_sel_i = "00101" else
               alu_bs_i              when alu_sel_i = "00110" else
               alu_bc_i              when alu_sel_i = "00111" else
               alu_a_i               when alu_sel_i = "01000" else -- LD, LDL
               alu_b_i               when alu_sel_i = "01001" else -- ST
               x"00";

CF_op <= alu_sum_i(8) when alu_sel_i = "00000" else
         alu_sub_i(8) when alu_sel_i = "00001" else
         '0';
    
ZF_op <= '1' when alu_o_i = x"00" else '0';
end Behavioral;
