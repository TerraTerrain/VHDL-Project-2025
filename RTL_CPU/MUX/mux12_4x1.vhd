library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use WORK.defs_pack.ALL;

entity mux12_4x1 is
    port ( select_input : in bit_vector( 1 downto 0 );
        d_in_a, d_in_b  : in bit_vector( 11 downto 0 );
        d_in_c, d_in_d  : in bit_vector( 11 downto 0 );
        d_out           : out bit_vector( 11 downto 0 ) );
end mux12_4x1;

architecture RTL of mux12_4x1 is
    begin
        with select_input select
            d_out <= d_in_d when "11",
                    d_in_c when "10",
                    d_in_b when "01",
                    d_in_a when "00";
end RTL;