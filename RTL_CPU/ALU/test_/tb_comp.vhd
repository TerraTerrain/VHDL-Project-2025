library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.defs_pack.all;

entity tb_comp is
--  Port ( );
end tb_comp;

architecture Behavioral of tb_comp is

    component comparator
        Port (
            a, b             : in  DataType;
            func3            : in  Func3Type;
            out_comp         : out bit;
            branch_comp      : out bit
        );
    end component;

    signal a, b : DataType := (others => '0');
    signal func3 : Func3Type;
    signal out_comp, branch_comp : bit;
    
    --bit to string for report
    function to_string(b : bit) return string is
        variable result : string(1 to 1);
    begin
            result(1) := character'value(bit'image(b));
        return result;
    end;
    
begin
    uut: comparator
        port map (
            a => a,
            b => b,
            func3 => func3,
            out_comp => out_comp,
            branch_comp => branch_comp
        );

    stim_proc: process
    begin
        -- Test SLT: -1 < 1 → '1'
        a <= "11111111111111111111111111111111"; -- -1
        b <= "00000000000000000000000000000001"; --  1
        func3 <= Func3SLT;
        wait for 10 ns;
        report "SLT result = " & to_string(out_comp);

        -- Test SLTU: 1 < 3 → '1'
        a <= "00000000000000000000000000000001";
        b <= "00000000000000000000000000000011";
        func3 <= Func3SLTU;
        wait for 10 ns;
        report "SLTU result = " & to_string(out_comp);

        -- Test BEQ: a = b → '1'
        a <= x"0000000A";
        b <= x"0000000A";
        func3 <= Func3BEQ;
        wait for 10 ns;
        report "BEQ result = " & to_string(branch_comp);

        -- Test BNE: a ≠ b → '1'
        a <= x"00000005";
        b <= x"00000006";
        func3 <= Func3BNE;
        wait for 10 ns;
        report "BNE result = " & to_string(branch_comp);

        -- Test BLT: -2 < 1 → '1'
        a <= x"FFFFFFFE"; -- -2
        b <= x"00000001";
        func3 <= Func3BLT;
        wait for 10 ns;
        report "BLT result = " & to_string(branch_comp);

        -- Test BGE: 5 >= 2 → '1'
        a <= x"00000005";
        b <= x"00000002";
        func3 <= Func3BGE;
        wait for 10 ns;
        report "BGE result = " & to_string(branch_comp);

        -- Test BLTU: 1 < 2 → '1'
        a <= x"00000001";
        b <= x"00000002";
        func3 <= Func3BLTU;
        wait for 10 ns;
        report "BLTU result = " & to_string(branch_comp);

        -- Test BGEU: 4 < 10 → '0'
        a <= x"00000002";
        b <= x"0000000A";
        func3 <= Func3BGEU;
        wait for 10 ns;
        report "BGEU result = " & to_string(branch_comp);

        report "Finished." severity note;
        wait;
    end process;

end Behavioral;
