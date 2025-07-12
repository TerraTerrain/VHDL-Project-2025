library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_BIT.ALL;
use WORK.defs_pack.ALL;

entity or2 is
    Port ( a : in datatype;
           b : in datatype;
           c : out datatype);
end or2;

architecture Behavioral of or2 is

begin
   c <= a or b;

end Behavioral;
