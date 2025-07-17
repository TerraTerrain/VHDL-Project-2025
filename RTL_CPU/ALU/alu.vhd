library IEEE;
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
        carry_out => open,
        overflow => open
    );
    sub: entity work.adder(Behavioral)
    port map(
        a => operand1,
        b => operand2,
        o_mode => '1',
        s => out_sub,
        carry_out => open,
        overflow => open
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
    
    ALU: process(br,operand1, operand2, func3, func7, out_add, out_sub, out_shift, out_logic, out_comp)
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
                -- Also handle branch equal (same func3 value)
                branch <= br;
            when Func3SLT =>
                result <= (others => '0');
                result(0) <= out_comp;
            when Func3SLTU =>
                result <= (others => '0');
                result(0) <= out_comp;           
            when Func3XOR =>
                result <= out_logic;
                -- Also handle branch less than (same func3 value)
                branch <= br;
            when Func3OR =>
                result <= out_logic;
                -- Also handle branch less than unsigned (same func3 value)
                branch <= br;
            when Func3AND =>
                result <= out_logic;
                -- Also handle branch greater equal unsigned (same func3 value)
                branch <= br;
            when Func3SLL =>
                result <= out_shift;
                -- Also handle branch not equal (same func3 value)
                branch <= br;
            when Func3SRL_SRA =>
                result <= out_shift;
                -- Also handle branch greater equal (same func3 value)
                branch <= br;
            when others =>
                result <= (others => '0');
                branch <= '0';
        end case;
    end process;
end Behavioral;
