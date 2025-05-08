----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/06/2025 10:22:09 PM
-- Design Name: 
-- Module Name: int_MEM - Behavioral
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
use IEEE.numeric_bit.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity int_MEM is
  port(
    w_en     : in bit;
    addr     : in bit_vector(11 downto 0);
    dataToMem  : in bit_vector(11 downto 0);
    dataFromMem2 : out bit_vector(11 downto 0)
  );
end int_MEM;

architecture Behavioral of int_MEM is
  type mem_type is array (0 to 4095) of bit_vector(11 downto 0);
  signal Mem : mem_type;
begin
  process(w_en, addr, dataToMem)
    variable addr_int : integer;
  begin
    addr_int := TO_INTEGER(UNSIGNED(addr));

    if w_en = '1' then
      Mem(addr_int) <= dataToMem;
    end if;

    dataFromMem2 <= Mem(addr_int);
  end process;
end Behavioral;
