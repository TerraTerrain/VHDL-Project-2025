library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_BIT.ALL;
use WORK.defs_pack.ALL;
-- commented out line 34 in defs_pack.vhd for testing
entity tb_shift is
--  Port ( );
end tb_shift;

architecture Behavioral of tb_shift is
constant period : time := 20 ns;

    signal data_in_s    : datatype := (others => '0');
    signal func3_s      : Func3Type := (others => '0');
    signal func7_s      : Func7Type := (others => '0');
    signal out_shift_s  : datatype;

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
    shift_test: entity work.shift(Behavioral)
    port map(
        data_in   => data_in_s,
        func3     => func3_s,
        func7     => func7_s,
        out_shift => out_shift_s
    );

    stim: process
    begin
        -- SLL (Shift Left Logical) Test 1
        data_in_s <= B"00000000000000000000000000000001"; -- 1
        func3_s <= Func3SLL;              -- "001"
        func7_s <= Func7ShLog;            -- "0000000"
        wait for 0 ns;
        wait for 10 * period;
        report "SLL: data_in = " & to_string(data_in_s);
        report "     out_shift = " & to_string(out_shift_s);

        -- SLL Test 2 - larger value
        data_in_s <= B"00000000000000000000000000001000"; -- 8
        func3_s <= Func3SLL;
        func7_s <= Func7ShLog;
        wait for 0 ns;
        wait for 10 * period;
        report "SLL: data_in = " & to_string(data_in_s);
        report "     out_shift = " & to_string(out_shift_s);

        -- SRL (Shift Right Logical) Test 1
        data_in_s <= B"10000000000000000000000000000000"; -- MSB set
        func3_s <= Func3SRL_SRA;          -- "101"
        func7_s <= Func7ShLog;            -- "0000000"
        wait for 0 ns;
        wait for 10 * period;
        report "SRL: data_in = " & to_string(data_in_s);
        report "     out_shift = " & to_string(out_shift_s);

        -- SRL Test 2 - even number
        data_in_s <= B"00000000000000000000000000010000"; -- 16
        func3_s <= Func3SRL_SRA;
        func7_s <= Func7ShLog;
        wait for 0 ns;
        wait for 10 * period;
        report "SRL: data_in = " & to_string(data_in_s);
        report "     out_shift = " & to_string(out_shift_s);

        -- SRA (Shift Right Arithmetic) Test 1 - negative
        data_in_s <= B"11110000000000000000000000000000"; -- negative
        func3_s <= Func3SRL_SRA;          -- "101"
        func7_s <= Func7ShArthm;          -- "0100000"
        wait for 0 ns;
        wait for 10 * period;
        report "SRA: data_in = " & to_string(data_in_s) & " (negative)";
        report "     out_shift = " & to_string(out_shift_s);

        -- SRA Test 2 - positive
        data_in_s <= B"01110000000000000000000000000000"; -- positive
        func3_s <= Func3SRL_SRA;
        func7_s <= Func7ShArthm;
        wait for 0 ns;
        wait for 10 * period;
        report "SRA: data_in = " & to_string(data_in_s) & " (positive)";
        report "     out_shift = " & to_string(out_shift_s);

        -- Invalid func3 test
        data_in_s <= B"00010010001101000101011001111000"; -- 0x12345678
        func3_s <= "010";                 -- invalid
        func7_s <= Func7ShLog;
        wait for 0 ns;
        wait for 10 * period;
        report "INVALID FUNC3: data_in = " & to_string(data_in_s);
        report "               out_shift = " & to_string(out_shift_s);

        -- Invalid func7 test
        data_in_s <= B"10000111011001010100001100100001"; -- 0x87654321
        func3_s <= Func3SRL_SRA;
        func7_s <= "1111111";             -- invalid
        wait for 0 ns;
        wait for 10 * period;
        report "INVALID FUNC7: data_in = " & to_string(data_in_s);
        report "               out_shift = " & to_string(out_shift_s);
        
        wait;
    end process;
end Behavioral;
