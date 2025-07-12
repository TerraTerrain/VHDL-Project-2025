library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_BIT.ALL;
use WORK.defs_pack.ALL;

entity reg_mux is
    port (
        re      : in  bit;
        r_addr  : in  RegAddrType;
        regs_in : in  RegType;
        d_out   : out DataType
    );
end reg_mux;

architecture Behavioral of reg_mux is
begin    
    d_out <= regs_in(TO_INTEGER(unsigned(r_addr))) when re = '1'
        else unaffected;
end Behavioral;
