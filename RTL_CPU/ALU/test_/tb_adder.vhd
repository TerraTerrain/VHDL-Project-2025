library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_BIT.ALL;
use WORK.defs_pack.ALL;

entity tb_adder is
--  Port ( );
end tb_adder;

architecture Behavioral of tb_adder is
constant period : time := 20 ns;

    signal a_s, b_s       : datatype := (others => '0');
    signal o_mode_s     : bit := '0';
    signal s_sig          : datatype;
    signal carry_out_s  : bit;
    signal overflow_s   : bit;

    --bit_vektor to string for output in tcl console
    function to_string(bv: bit_vector) return string is
        variable result : string(1 to bv'length);
        variable idx    : integer := 1;
    begin
        for i in bv'range loop  -- assuming datatype is (31 downto 0)
            result(idx) := character'VALUE(bit'image(bv(i)));
            idx := idx + 1;
        end loop;
        return result;
    end;

begin
    adder_test: entity work.adder(Behavioral)
    port map(
        a         => a_s,
        b         => b_s,
        o_mode    => o_mode_s,
        s         => s_sig,
        carry_out => carry_out_s,
        overflow  => overflow_s
    );

    stim: process
    begin
        --a + b
        a_s <= B"00000000000000000000000000000101"; --5
        b_s <= B"00000000000000000000000000000011"; --3
        o_mode_s <= '0'; --add
        wait for 0 ns;
        wait for 10 * period;
        report "ADD: a = " & to_string(a_s) & ", b = " & to_string(b_s);
        report "     s = " & to_string(s_sig) & ", carry = '" & bit'image(carry_out_s) & "', overflow = '" & bit'image(overflow_s) & "'";

        --a - b
        a_s <= B"00000000000000000000000000000101"; --5
        b_s <= B"00000000000000000000000000000101"; --5
        o_mode_s <= '1'; --sub
        wait for 0 ns;
        wait for 10 * period;
        report "SUB: a = " & to_string(a_s) & ", b = " & to_string(b_s);
        report "     s = " & to_string(s_sig) & ", carry = '" & bit'image(carry_out_s) & "', overflow = '" & bit'image(overflow_s) & "'";

        --overflow(p+p = n)
        a_s <= B"01111111111111111111111111111111"; -- +2^31 - 1
        b_s <= B"00000000000000000000000000000001"; -- +1
        o_mode_s <= '0'; 
        wait for 0 ns;
        wait for 10 * period;
        report "OVERFLOW TEST: a = " & to_string(a_s) & ", b = " & to_string(b_s);
        report "               s = " & to_string(s_sig) & ", carry = '" & bit'image(carry_out_s) & "', overflow = '" & bit'image(overflow_s) & "'";
        
        wait;
    end process;
end Behavioral; 
