library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_BIT.ALL;
use WORK.defs_pack.ALL;

entity logic_unit is
    Port ( 
            a	:	in	datatype;
            b   :   in  datatype;
            func3:	in	Func3Type;
            s	:	out	datatype
    );
end logic_unit;

architecture Behavioral of logic_unit is
    signal out_and : datatype;
    signal out_or : datatype;
    signal out_xor : datatype;
    signal out_not : datatype;
begin
    and2 : entity work.and2(Behavioral)
    port map (
        a => a,
        b => b,
        c => out_and
    );

    or2 : entity work.or2(Behavioral)
    port map (
        a => a,
        b => b,
        c => out_or
    );
    
    xor2 : entity work.xor2(Behavioral)
    port map(
        a => a,
        b => b,
        c => out_xor
    );
    
    not2 : entity work.not2(Behavioral)
    port map(
        a => a,
        b => out_not
    );
    
    process(func3)
    begin
    case func3 is
        when Func3XOR => s <= out_xor;
        when Func3OR => s <= out_or;
        when Func3AND => s <= out_and;
        when others => s <= (others => '0');
    end case;
    end process;
end Behavioral;
