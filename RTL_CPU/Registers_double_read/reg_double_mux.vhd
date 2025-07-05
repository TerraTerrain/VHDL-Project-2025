library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_BIT.ALL;
use WORK.defs_pack.ALL;

entity reg_double_mux is
    port (
        regs_in : in  RegType;
        r_addr1 : in  RegAddrType;
        r_data1 : out DataType;
        r_addr2 : in  RegAddrType;
        r_data2 : out DataType
    );
end reg_double_mux;

architecture Behavioral of reg_double_mux is
begin    
    r_data1 <= regs_in(TO_INTEGER(unsigned(r_addr1)));
    r_data2 <= regs_in(TO_INTEGER(unsigned(r_addr2)));
end Behavioral;
