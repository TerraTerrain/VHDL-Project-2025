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
    
    comp: entity work.comparator(Behavioral)
    port map(
        data_in1 => operand1,
        data_in2 => operand2,
        opcode => operation,
        data_out => result
    );
    
    shift: entity work.shift(Behavioral)
    port map(  
        data_in => operand1,
        opcode => operation,
        data_out => out_shifter
    );      
    
    ALU: process(operation, out_add, out_sub, out_logic_unit, out_shifter)
    case operation is
        when OpAdd =>
            result <= out_add;
        when OpSub =>
            result <= out_sub;
        when Func3XOR or Func3OR or Func3AND =>
            result <= out_logic_unit;
        when Func7SLL or Func7SRL or Func7SRA =>
            result <= out_shifter;
        when others =>
            result <= (others => '0');
    end case;
end Behavioral;
