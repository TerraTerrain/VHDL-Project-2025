library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_BIT.ALL;
use WORK.defs_pack.ALL;

entity xor2 is
    Port ( a : in datatype;
           b : in datatype;
           c : out datatype);
end xor2;

architecture Behavioral of xor2 is

begin
    c <= a xor b;
end Behavioral;
