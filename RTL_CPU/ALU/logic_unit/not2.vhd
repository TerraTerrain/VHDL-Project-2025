library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_BIT.ALL;
use WORK.defs_pack.ALL;

entity not2 is
    Port ( a : in datatype;
           b : out datatype);
end not2;

architecture Behavioral of not2 is

begin
    b <= not a;
end Behavioral;
