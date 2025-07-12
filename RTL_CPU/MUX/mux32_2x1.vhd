library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use WORK.defs_pack.ALL;

entity mux32_2x1 is
    port(
        selector       : in  bit;
        d_in_a, d_in_b : in  DataType;
        d_out          : out DataType
    );
end mux32_2x1;

architecture RTL of mux32_2x1 is
begin
    with selector select
        d_out <= d_in_a when '0',
                 d_in_b when '1';
end RTL;
