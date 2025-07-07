library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_BIT.ALL;

entity full_adder is
    Port ( a : in bit;
           b : in bit;
           cin : in bit;
           sum : out bit;
           cout : out bit);
end full_adder;

architecture Behavioral of full_adder is
    signal g , p : bit;--g:generate,p:propagate
begin
    p <= a xor b;
    g <= a and b;
    
    sum <= p xor cin;
    cout <= g or (cin and p);
end Behavioral;
