library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_BIT.ALL;
use WORK.defs_pack.ALL;

entity alu is
    Port (
            operand1       :       in      datatype;--a
            operand2       :       in      datatype;--b
            func3          :       in	   Func3Type;
            func7          :       in      Func7Type;
            result         :       out     datatype;
            branch         :       out     bit
     );
end alu;

architecture Behavioral of alu is
    signal out_add, out_sub, out_shift, out_logic : datatype := (others => '0');
    signal test_carryout, test_overflow : bit;
    signal out_comp  : bit := '0';
    signal br       : bit := '0';
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
    
    logic_unit: entity work.logic_unit(Behavioral)
        port map(
            a     => operand1,
            b     => operand2,
            func3 => func3,
            s     => out_logic
        );
    
    comp: entity work.comparator(Behavioral)
    port map(
        a => operand1,
        b => operand2,
        func3 => func3,
        out_comp => out_comp,
        branch_comp => br
    );
    
    shift: entity work.shift(Behavioral)
    port map(  
        data_in => operand1,
        func3 => func3,
        func7 => func7,
        out_shift => out_shift
    );      
    
    ALU: process(operand1, operand2, out_add, out_sub, out_logic, out_shift, br)
    begin
        result <= (others => '0');
        branch <= '0';

        case func3 is
            when Func3Arthm =>
                if func7 = Func7SUB then
                    result <= out_sub;
                else
                    result <= out_add;
                end if;
            when Func3SLT =>
                result <= (others => '0');
                result(0) <= out_comp;
            when Func3SLTU =>
                result <= (others => '0');
                result(0) <= out_comp;           
            when Func3XOR =>
                result <= out_logic;
            when Func3or =>
                result <= out_logic;
            when Func3AND =>
                result <= out_logic;
            when Func3SLL =>
                result <= out_shift;
            when func3srl_sra =>
                result <= out_shift;
            when Func3BEQ =>
                branch <= br;
            when Func3BNE => 
                branch <= br;
            when Func3BLT => 
                branch <= br;
            when Func3BGE => 
                branch <= br;
            when Func3BLTU =>
                branch <= br;
            when Func3BGEU =>
                branch <= br;
            when others =>
                result <= (others => '0');
                branch <= '0';
        end case;
    end process;
end Behavioral;
