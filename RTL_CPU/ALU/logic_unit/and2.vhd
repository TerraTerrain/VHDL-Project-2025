library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_BIT.ALL;
use WORK.defs_pack.ALL;

entity and2 is
    Port ( a : in datatype;
           b : in datatype;
           c : out datatype);
end and2;

architecture Behavioral of and2 is

begin
    c <= a and b;

end Behavioral;
