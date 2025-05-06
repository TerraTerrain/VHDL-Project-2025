----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/06/2025 10:22:09 PM
-- Design Name: 
-- Module Name: bit_MEM - Behavioral
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

entity bit_MEM is
  port(
    w_en     : in bit;
    addr     : in bit_vector(11 downto 0);
    dataToMem  : in bit_vector(11 downto 0);
    dataFromMem1 : out bit_vector(11 downto 0)
  );
end bit_MEM;

architecture Behavioral of bit_MEM is
  type mem_type is array (
    bit, bit, bit, bit, bit, bit,
    bit, bit, bit, bit, bit, bit
  ) of bit_vector(11 downto 0);
  variable Mem : mem_type;
begin
  process(w_en, addr, dataToMem)
  begin
    if w_en = '1' then
      Mem(addr(11), addr(10), addr(9), addr(8),
          addr(7), addr(6), addr(5), addr(4),
          addr(3), addr(2), addr(1), addr(0)) := dataToMem;
    end if;

    dataFromMem1 <= Mem(addr(11), addr(10), addr(9), addr(8),
                        addr(7), addr(6), addr(5), addr(4),
                        addr(3), addr(2), addr(1), addr(0));
  end process;
end Behavioral;