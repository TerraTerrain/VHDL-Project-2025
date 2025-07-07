library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_BIT.ALL;
use WORK.defs_pack.ALL;

entity alu is
    Port (
            operand1       :       in      datatype;--a
            operand2       :       in      datatype;--b
            operation      :       in	   optype;--f
            result         :       out     datatype--output
     );
end alu;

architecture Behavioral of alu is
    signal out_add: datatype := (others =>'0');   
    signal out_sub: datatype := (others =>'0');   
    signal out_logic_unit: datatype := (others =>'0');
    signal out_shifter: datatype := (others =>'0');
    signal test_carryout : bit;
    signal test_overflow : bit;
begin
    add: entity work.adder(Behavioral)
    port map(
        a	=>	operand1,
        b	=>	operand2,
        o_mode	=>	'0',
        s	=>	out_add,
        carry_out => test_carryout,
        overflow => test_overflow
    );
    sub: entity work.adder(Behavioral)
    port map(
        a => operand1,
        b => operand2,
        o_mode => '1',
        s => out_sub,
        carry_out => test_carryout,
        overflow => test_overflow
        );
    
end Behavioral;
