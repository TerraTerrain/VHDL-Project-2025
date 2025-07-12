library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_BIT.ALL;
use WORK.defs_pack.ALL;

entity we_decoder is
    port (
        we        : in bit;
        w_addr    : in RegAddrType;
        we_vector : out bit_vector(2**RegAddrSize-1 downto 0)
    );
end we_decoder;

architecture Behavioral of we_decoder is
begin
    process(we, w_addr)
        variable tmp : bit_vector(2**RegAddrSize-1 downto 0);
    begin
        tmp := (others => '0');
        tmp(TO_INTEGER(unsigned(w_addr))) := we;
        we_vector <= tmp;
    end process;
end Behavioral;
