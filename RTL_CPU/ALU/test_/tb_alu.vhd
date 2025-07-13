library IEEE;
use IEEE.NUMERIC_BIT.ALL;
use WORK.defs_pack.ALL;
-- commented out line 34 in defs_pack.vhd for testing

entity tb_alu is
--  Port ( );
end tb_alu;

architecture Behavioral of tb_alu is
constant period : time := 20 ns;

    signal operand1_s   : datatype := (others => '0');
    signal operand2_s   : datatype := (others => '0');
    signal func3_s      : Func3Type := (others => '0');
    signal func7_s      : Func7Type := (others => '0');
    signal result_s     : datatype;
    signal branch_s     : bit;

    -- Debug signals for direct adder testing
    signal debug_a, debug_b : datatype := (others => '0');
    signal debug_o_mode : bit := '0';
    signal debug_s : datatype;
    signal debug_carry_out, debug_overflow : bit;

    --bit_vector to string for output in tcl console
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
    alu_test: entity work.alu(Behavioral)
    port map(
        operand1 => operand1_s,
        operand2 => operand2_s,
        func3    => func3_s,
        func7    => func7_s,
        result   => result_s,
        branch   => branch_s
    );

    -- Direct adder test for debugging
    debug_adder: entity work.adder(Behavioral)
    port map(
        a => debug_a,
        b => debug_b,
        o_mode => debug_o_mode,
        s => debug_s,
        carry_out => debug_carry_out,
        overflow => debug_overflow
    );

    stim: process
    begin
        -- ADD Test 1
        operand1_s <= B"00000000000000000000000000000101"; -- 5
        operand2_s <= B"00000000000000000000000000000011"; -- 3
        func3_s <= Func3Arthm;            -- "000"
        func7_s <= Func7ADD;              -- "0000000"
        wait for 0 ns;
        wait for 10 * period;
        report "ADD: operand1 = " & to_string(operand1_s) & " (5)";
        report "     operand2 = " & to_string(operand2_s) & " (3)";
        report "     result   = " & to_string(result_s) & " (expected: 8)";
        report "     branch   = " & bit'image(branch_s);

        -- ADD Test 2 - larger values
        operand1_s <= B"00000000000000000000000001111111"; -- 127
        operand2_s <= B"00000000000000000000000000000001"; -- 1
        func3_s <= Func3Arthm;
        func7_s <= Func7ADD;
        wait for 0 ns;
        wait for 10 * period;
        report "ADD: operand1 = " & to_string(operand1_s) & " (127)";
        report "     operand2 = " & to_string(operand2_s) & " (1)";
        report "     result   = " & to_string(result_s) & " (expected: 128)";

        -- DIRECT ADDER DEBUG TEST: 3 - 10
        report "=== DIRECT ADDER DEBUG TEST ===";
        debug_a <= B"00000000000000000000000000000011"; -- 3
        debug_b <= B"00000000000000000000000000001010"; -- 10
        debug_o_mode <= '1'; -- subtraction
        wait for 0 ns;
        wait for 10 * period;
        report "DIRECT ADDER: a = " & to_string(debug_a) & " (3)";
        report "              b = " & to_string(debug_b) & " (10)";
        report "              o_mode = " & bit'image(debug_o_mode) & " (1=sub)";
        report "              result = " & to_string(debug_s) & " (expected: -7)";
        report "              carry_out = " & bit'image(debug_carry_out);
        report "=== END DIRECT ADDER DEBUG ===";

        -- SUB Test 1
        operand1_s <= B"00000000000000000000000000001010"; -- 10
        operand2_s <= B"00000000000000000000000000000011"; -- 3
        func3_s <= Func3Arthm;            -- "000"
        func7_s <= Func7SUB;              -- "0100000"
        wait for 0 ns;
        wait for 10 * period;
        report "SUB: operand1 = " & to_string(operand1_s) & " (10)";
        report "     operand2 = " & to_string(operand2_s) & " (3)";
        report "     result   = " & to_string(result_s) & " (expected: 7)";

        -- SUB Test 2 - negative result
        operand1_s <= B"00000000000000000000000000000011"; -- 3
        operand2_s <= B"00000000000000000000000000001010"; -- 10
        func3_s <= Func3Arthm;
        func7_s <= Func7SUB;
        wait for 0 ns;
        wait for 10 * period;
        report "SUB: operand1 = " & to_string(operand1_s) & " (3)";
        report "     operand2 = " & to_string(operand2_s) & " (10)";
        report "     result   = " & to_string(result_s) & " (expected: -7)";

        -- XOR Test
        operand1_s <= B"00000000000000000000000011110000"; -- 0xF0
        operand2_s <= B"00000000000000000000000010101010"; -- 0xAA
        func3_s <= Func3XOR;              -- "100"
        func7_s <= Func7ADD;              -- don't care
        wait for 0 ns;
        wait for 10 * period;
        report "XOR: operand1 = " & to_string(operand1_s) & " (240)";
        report "     operand2 = " & to_string(operand2_s) & " (170)";
        report "     result   = " & to_string(result_s) & " (expected: 90)";

        -- OR Test
        operand1_s <= B"00000000000000000000000011110000"; -- 0xF0
        operand2_s <= B"00000000000000000000000000001111"; -- 0x0F
        func3_s <= Func3OR;               -- "110"
        func7_s <= Func7ADD;              -- don't care
        wait for 0 ns;
        wait for 10 * period;
        report "OR:  operand1 = " & to_string(operand1_s) & " (240)";
        report "     operand2 = " & to_string(operand2_s) & " (15)";
        report "     result   = " & to_string(result_s) & " (expected: 255)";

        -- AND Test
        operand1_s <= B"00000000000000000000000011111111"; -- 0xFF
        operand2_s <= B"00000000000000000000000011110000"; -- 0xF0
        func3_s <= Func3AND;              -- "111"
        func7_s <= Func7ADD;              -- don't care
        wait for 0 ns;
        wait for 10 * period;
        report "AND: operand1 = " & to_string(operand1_s) & " (255)";
        report "     operand2 = " & to_string(operand2_s) & " (240)";
        report "     result   = " & to_string(result_s) & " (expected: 240)";

        -- SLT Test 1 - operand1 < operand2
        operand1_s <= B"00000000000000000000000000000101"; -- 5
        operand2_s <= B"00000000000000000000000000001010"; -- 10
        func3_s <= Func3SLT;              -- "010"
        func7_s <= Func7ADD;              -- don't care
        wait for 0 ns;
        wait for 10 * period;
        report "SLT: operand1 = " & to_string(operand1_s) & " (5)";
        report "     operand2 = " & to_string(operand2_s) & " (10)";
        report "     result   = " & to_string(result_s) & " (expected: 1)";

        -- SLT Test 2 - operand1 > operand2
        operand1_s <= B"00000000000000000000000000001010"; -- 10
        operand2_s <= B"00000000000000000000000000000101"; -- 5
        func3_s <= Func3SLT;
        func7_s <= Func7ADD;
        wait for 0 ns;
        wait for 10 * period;
        report "SLT: operand1 = " & to_string(operand1_s) & " (10)";
        report "     operand2 = " & to_string(operand2_s) & " (5)";
        report "     result   = " & to_string(result_s) & " (expected: 0)";

        -- SLTU Test - unsigned comparison
        operand1_s <= B"11111111111111111111111111111111"; -- 0xFFFFFFFF (large unsigned)
        operand2_s <= B"00000000000000000000000000000001"; -- 1
        func3_s <= Func3SLTU;             -- "011"
        func7_s <= Func7ADD;
        wait for 0 ns;
        wait for 10 * period;
        report "SLTU: operand1 = " & to_string(operand1_s) & " (4294967295)";
        report "      operand2 = " & to_string(operand2_s) & " (1)";
        report "      result   = " & to_string(result_s) & " (expected: 0)";

        -- SLL Test
        operand1_s <= B"00000000000000000000000000000001"; -- 1
        operand2_s <= B"00000000000000000000000000000000"; -- don't care for shift
        func3_s <= Func3SLL;              -- "001"
        func7_s <= Func7ShLog;            -- "0000000"
        wait for 0 ns;
        wait for 10 * period;
        report "SLL: operand1 = " & to_string(operand1_s) & " (1)";
        report "     result   = " & to_string(result_s) & " (expected: 2)";

        -- SRL Test
        operand1_s <= B"00000000000000000000000000010000"; -- 16
        operand2_s <= B"00000000000000000000000000000000"; -- don't care
        func3_s <= Func3SRL_SRA;          -- "101"
        func7_s <= Func7ShLog;            -- "0000000"
        wait for 0 ns;
        wait for 10 * period;
        report "SRL: operand1 = " & to_string(operand1_s) & " (16)";
        report "     result   = " & to_string(result_s) & " (expected: 8)";

        -- SRA Test
        operand1_s <= B"11110000000000000000000000000000"; -- negative
        operand2_s <= B"00000000000000000000000000000000"; -- don't care
        func3_s <= Func3SRL_SRA;          -- "101"
        func7_s <= Func7ShArthm;          -- "0100000"
        wait for 0 ns;
        wait for 10 * period;
        report "SRA: operand1 = " & to_string(operand1_s) & " (negative)";
        report "     result   = " & to_string(result_s) & " (expected: sign-extended)";

        -- BEQ Test 1 - equal values
        operand1_s <= B"00000000000000000000000000000101"; -- 5
        operand2_s <= B"00000000000000000000000000000101"; -- 5
        func3_s <= Func3BEQ;              -- "000"
        func7_s <= Func7ADD;              -- don't care
        wait for 0 ns;
        wait for 10 * period;
        report "BEQ: operand1 = " & to_string(operand1_s) & " (5)";
        report "     operand2 = " & to_string(operand2_s) & " (5)";
        report "     result   = " & to_string(result_s);
        report "     branch   = " & bit'image(branch_s) & " (expected: 1)";

        -- BEQ Test 2 - not equal values
        operand1_s <= B"00000000000000000000000000000101"; -- 5
        operand2_s <= B"00000000000000000000000000001010"; -- 10
        func3_s <= Func3BEQ;
        func7_s <= Func7ADD;
        wait for 0 ns;
        wait for 10 * period;
        report "BEQ: operand1 = " & to_string(operand1_s) & " (5)";
        report "     operand2 = " & to_string(operand2_s) & " (10)";
        report "     result   = " & to_string(result_s);
        report "     branch   = " & bit'image(branch_s) & " (expected: 0)";

        -- Invalid func3 test
        operand1_s <= B"00010010001101000101011001111000"; -- 0x12345678
        operand2_s <= B"10000111011001010100001100100001"; -- 0x87654321
        func3_s <= "111";                 -- might conflict with AND, but test edge case
        func7_s <= "1111111";             -- invalid func7
        wait for 0 ns;
        wait for 10 * period;
        report "EDGE: operand1 = " & to_string(operand1_s);
        report "      operand2 = " & to_string(operand2_s);
        report "      result   = " & to_string(result_s);
        report "      branch   = " & bit'image(branch_s);
        
        wait;
    end process;
end Behavioral;
