library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_BIT.ALL;
use work.defs_pack.all;


entity RISCV is
end RISCV;

architecture Functional of RISCV is
begin
    process
        variable PC           : AddrType    := X"0000";
        variable Instr      : InstrType :=(others=>'0');
        variable OP           : OpType      := (others=>'0');

        variable Reg          : RegType     := (others=>(others=>'0'));
        variable Mem          : MemType     := (others=>(others=>'0'));

    begin
    
        Instr := Mem(TO_INTEGER(unsigned(PC)));
    end process;
end Functional;
