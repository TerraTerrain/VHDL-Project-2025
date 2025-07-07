library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use WORK.defs_pack.ALL;

entity mux32_2x1 is
    port ( select_input : in bit;
            d_in_a, d_in_b  : in DataType;
            d_out           : out DataType);
end mux32_2x1;

architecture RTL of mux32_2x1 is

begin

    process( d_in_a, d_in_b, select_input )
    
    begin
        if select_input = '0' then
            d_out <= d_in_a;
        else
            d_out <= d_in_b;
        end if;
    end process;
    
end RTL;

