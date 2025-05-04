----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/04/2025 03:30:22 PM
-- Design Name: 
-- Module Name: memory_unit_testbench - Behavioral
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
use IEEE.numeric_bit.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity memory_unit_testbench is
end memory_unit_testbench;

architecture TB of memory_unit_testbench is
  component bit_MEM
  port(
    w_en     : in bit;
    addr     : in bit_vector( 11 downto 0 );
    dataToMem  : in bit_vector( 11 downto 0);
    dataFromMem1 : out bit_vector( 11 downto 0 )
);
end component;
  component int_MEM
  port(
    w_en     : in bit;
    addr     : in bit_vector( 11 downto 0 );
    dataToMem  : in bit_vector( 11 downto 0);
    dataFromMem2 : out bit_vector( 11 downto 0 )
);
end component;
signal w_en: bit := '0';
signal addr, dataToMem, dataFromMem2, dataFromMem1:
                     bit_vector( 11 downto 0 );
begin
UUT1: bit_MEM
    port map( w_en, addr,dataToMem,DataFromMem1);
UUT: int_MEM
    port map( w_en, addr,dataToMem,DataFromMem1);
process
  begin
    for addr_v in 0 to 4095 loop
      addr <= bit_vector(TO_UNSIGNED(addr_v, 12));
      dataToMem <= bit_vector(TO_UNSIGNED(addr_v, 12));
      w_en <= '1'; wait for 1 ns;
      w_en <= '0'; wait for 1 ns;
    end loop;
    for addr_r in 0 to 4095 loop
      addr <= bit_vector(TO_UNSIGNED(addr_r, 12));
      assert dataFromMem1 = dataFromMem2;
      assert dataFromMem1 = bit_vector(TO_UNSIGNED(addr_r, 12));
    end loop;
    wait;
  end process;
end TB;
