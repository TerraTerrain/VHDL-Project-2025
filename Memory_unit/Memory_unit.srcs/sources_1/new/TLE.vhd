----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2025/05/07 09:53:02
-- Design Name: 
-- Module Name: TLE - Behavioral
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

entity TLE is
end TLE;

architecture Behavioral of TLE is
    component bit_MEM is
        port(w_en     : in bit;
             addr     : in bit_vector(11 downto 0);
             dataToMem  : in bit_vector(11 downto 0);
             dataFromMem1 : out bit_vector(11 downto 0));
    end component;
    
    component int_MEM is
        port(w_en     : in bit;
             addr     : in bit_vector(11 downto 0);
             dataToMem  : in bit_vector(11 downto 0);
             dataFromMem2 : out bit_vector(11 downto 0));
    end component;
    
    component memory_unit_testbench is
        port(w_en : out bit;
             addr : out bit_vector(11 downto 0);
             dataToMem : out bit_vector(11 downto 0);
             dataFromMem1 : in bit_vector(11 downto 0);
             dataFromMem2 : in bit_vector(11 downto 0)
             );
    end component;
    
    --signale:
    signal w_en_s : bit;
    signal addr_s , dataToMem_s , datafrommem1_s , datafrommem2_s : bit_vector(11 downto 0):=(others=>'0');
    
begin
    
    UUT1: bit_MEM port map(w_en_s,addr_s,dataToMem_s,dataFromMem1_s);
    UUT2: int_MEM port map(w_en_s,addr_s,dataToMem_s,datafromMem2_s);
    TB : memory_unit_testbench port map(w_en_s,addr_s,datatomem_s,datafrommem1_s,datafrommem2_s);
    
end Behavioral;

configuration TLE_config of TLE is
    for Behavioral
        for UUT1 : bit_MEM
            use entity work.bit_MEM(Behavioral);
        end for;
     
        for UUT2 : int_MEM
            use entity work.int_MEM(Behavioral);
        end for;
        
        for TB : memory_unit_testbench
            use entity work.memory_unit_testbench(TB);
        end for; 
    end for;
end TLE_config;