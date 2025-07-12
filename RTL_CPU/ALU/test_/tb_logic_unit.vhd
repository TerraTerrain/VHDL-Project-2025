library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_BIT.ALL;
use WORK.defs_pack.ALL;

entity tb_logic_unit is
--  Port ( );
end tb_logic_unit;

architecture Behavioral of tb_logic_unit is
    constant period : time := 20ns;
    
    signal a : datatype:=(others =>'0');
    signal b : datatype:=(others =>'1');
    signal out_signal : datatype:=(others =>'0');
    signal func3 : Func3Type;
    --
    function to_string(bv: bit_vector) return string is
        variable result : string(1 to bv'length);
        variable idx : integer := 1;
    begin
        for i in bv'range loop
            result(idx) := character'VALUE(bit'image(bv(i)));
            idx := idx + 1;
        end loop;
        return result;
    end;
    
begin
     logic_unit_test: entity work.logic_unit(Behavioral)
      port map(
        a => a,
        b => b,
        func3 => func3,
        s => out_signal
    );
    
    test : process
    begin
    
    a <= B"10101010101010101010101010101010";
    b <= B"11001100110011001100110011001100";
    
    wait for 0 ns;
    report "a: " & to_string(a);
    report "b: " & to_string(b); 
    
    func3 <= Func3AND;
    wait for 10*period;
    report "AND result: " & to_string(out_signal);
    func3 <= Func3OR;
    wait for 10*period;
    report "OR result:  " & to_string(out_signal);
    func3 <= Func3XOR;
    wait for 10*period;
    report "XOR result: " & to_string(out_signal);
    
    wait;
    end process;
end Behavioral;
