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

    stim: process
    begin
        report "=== Starting Comprehensive ALU Tests ===";
        
        -- ============ ADD Tests (3 cases) ============
        report "--- ADD Test 1: Small positive numbers ---";
        operand1_s <= B"00000000000000000000000000000101"; -- 5
        operand2_s <= B"00000000000000000000000000000011"; -- 3
        func3_s <= Func3Arthm;            -- "000"
        func7_s <= Func7ADD;              -- "0000000"
        wait for 0 ns;
        wait for 10 * period;
        report "ADD1: " & to_string(operand1_s) & " + " & to_string(operand2_s) & " = " & to_string(result_s) & " (expected: 8)";

        report "--- ADD Test 2: Large numbers ---";
        operand1_s <= B"00000000000000000000000001111111"; -- 127
        operand2_s <= B"00000000000000000000000000000001"; -- 1
        func3_s <= Func3Arthm;
        func7_s <= Func7ADD;
        wait for 0 ns;
        wait for 10 * period;
        report "ADD2: " & to_string(operand1_s) & " + " & to_string(operand2_s) & " = " & to_string(result_s) & " (expected: 128)";

        report "--- ADD Test 3: Zero and number ---";
        operand1_s <= B"00000000000000000000000000000000"; -- 0
        operand2_s <= B"00000000000000000000000000101010"; -- 42
        func3_s <= Func3Arthm;
        func7_s <= Func7ADD;
        wait for 0 ns;
        wait for 10 * period;
        report "ADD3: " & to_string(operand1_s) & " + " & to_string(operand2_s) & " = " & to_string(result_s) & " (expected: 42)";

        -- ============ SUB Tests (3 cases) ============
        report "--- SUB Test 1: Positive result ---";
        operand1_s <= B"00000000000000000000000000001010"; -- 10
        operand2_s <= B"00000000000000000000000000000011"; -- 3
        func3_s <= Func3Arthm;            -- "000"
        func7_s <= Func7SUB;              -- "0100000"
        wait for 0 ns;
        wait for 10 * period;
        report "SUB1: " & to_string(operand1_s) & " - " & to_string(operand2_s) & " = " & to_string(result_s) & " (expected: 7)";

        report "--- SUB Test 2: Negative result ---";
        operand1_s <= B"00000000000000000000000000000011"; -- 3
        operand2_s <= B"00000000000000000000000000001010"; -- 10
        func3_s <= Func3Arthm;
        func7_s <= Func7SUB;
        wait for 0 ns;
        wait for 10 * period;
        report "SUB2: " & to_string(operand1_s) & " - " & to_string(operand2_s) & " = " & to_string(result_s) & " (expected: -7)";

        report "--- SUB Test 3: Zero result ---";
        operand1_s <= B"00000000000000000000000000101010"; -- 42
        operand2_s <= B"00000000000000000000000000101010"; -- 42
        func3_s <= Func3Arthm;
        func7_s <= Func7SUB;
        wait for 0 ns;
        wait for 10 * period;
        report "SUB3: " & to_string(operand1_s) & " - " & to_string(operand2_s) & " = " & to_string(result_s) & " (expected: 0)";

        -- ============ XOR Tests (3 cases) ============
        report "--- XOR Test 1: Different bit patterns ---";
        operand1_s <= B"00000000000000000000000011110000"; -- 0xF0 = 240
        operand2_s <= B"00000000000000000000000010101010"; -- 0xAA = 170
        func3_s <= Func3XOR;              -- "100"
        func7_s <= Func7ADD;              -- don't care
        wait for 0 ns;
        wait for 10 * period;
        report "XOR1: " & to_string(operand1_s) & " XOR " & to_string(operand2_s) & " = " & to_string(result_s) & " (expected: 90)";

        report "--- XOR Test 2: All ones with pattern ---";
        operand1_s <= B"00000000000000000000000011111111"; -- 0xFF = 255
        operand2_s <= B"00000000000000000000000001010101"; -- 0x55 = 85
        func3_s <= Func3XOR;
        func7_s <= Func7ADD;
        wait for 0 ns;
        wait for 10 * period;
        report "XOR2: " & to_string(operand1_s) & " XOR " & to_string(operand2_s) & " = " & to_string(result_s) & " (expected: 170)";

        report "--- XOR Test 3: Same values (should be 0) ---";
        operand1_s <= B"00000000000000000000000011001100"; -- 0xCC = 204
        operand2_s <= B"00000000000000000000000011001100"; -- 0xCC = 204
        func3_s <= Func3XOR;
        func7_s <= Func7ADD;
        wait for 0 ns;
        wait for 10 * period;
        report "XOR3: " & to_string(operand1_s) & " XOR " & to_string(operand2_s) & " = " & to_string(result_s) & " (expected: 0)";

        -- ============ OR Tests (3 cases) ============
        report "--- OR Test 1: Non-overlapping bits ---";
        operand1_s <= B"00000000000000000000000011110000"; -- 0xF0 = 240
        operand2_s <= B"00000000000000000000000000001111"; -- 0x0F = 15
        func3_s <= Func3OR;               -- "110"
        func7_s <= Func7ADD;              -- don't care
        wait for 0 ns;
        wait for 10 * period;
        report "OR1:  " & to_string(operand1_s) & " OR " & to_string(operand2_s) & " = " & to_string(result_s) & " (expected: 255)";

        report "--- OR Test 2: Overlapping bits ---";
        operand1_s <= B"00000000000000000000000010101010"; -- 0xAA = 170
        operand2_s <= B"00000000000000000000000001010101"; -- 0x55 = 85
        func3_s <= Func3OR;
        func7_s <= Func7ADD;
        wait for 0 ns;
        wait for 10 * period;
        report "OR2:  " & to_string(operand1_s) & " OR " & to_string(operand2_s) & " = " & to_string(result_s) & " (expected: 255)";

        report "--- OR Test 3: One operand zero ---";
        operand1_s <= B"00000000000000000000000000000000"; -- 0
        operand2_s <= B"00000000000000000000000001111000"; -- 120
        func3_s <= Func3OR;
        func7_s <= Func7ADD;
        wait for 0 ns;
        wait for 10 * period;
        report "OR3:  " & to_string(operand1_s) & " OR " & to_string(operand2_s) & " = " & to_string(result_s) & " (expected: 120)";

        -- ============ AND Tests (3 cases) ============
        report "--- AND Test 1: Simple mask ---";
        operand1_s <= B"00000000000000000000000011111111"; -- 0xFF = 255
        operand2_s <= B"00000000000000000000000011110000"; -- 0xF0 = 240
        func3_s <= Func3AND;              -- "111"
        func7_s <= Func7ADD;              -- don't care
        wait for 0 ns;
        wait for 10 * period;
        report "AND1: " & to_string(operand1_s) & " AND " & to_string(operand2_s) & " = " & to_string(result_s) & " (expected: 240)";

        report "--- AND Test 2: Partial overlap ---";
        operand1_s <= B"00000000000000000000000010101010"; -- 0xAA = 170
        operand2_s <= B"00000000000000000000000001010101"; -- 0x55 = 85
        func3_s <= Func3AND;
        func7_s <= Func7ADD;
        wait for 0 ns;
        wait for 10 * period;
        report "AND2: " & to_string(operand1_s) & " AND " & to_string(operand2_s) & " = " & to_string(result_s) & " (expected: 0)";

        report "--- AND Test 3: Large numbers (from original test) ---";
        operand1_s <= B"00010010001101000101011001111000"; -- 0x12345678 = 305419896
        operand2_s <= B"10000111011001010100001100100001"; -- 0x87654321 = 2271560481 (signed: -2023406815)
        func3_s <= Func3AND;
        func7_s <= Func7ADD;
        wait for 0 ns;
        wait for 10 * period;
        report "AND3: " & to_string(operand1_s) & " AND " & to_string(operand2_s) & " = " & to_string(result_s) & " (expected: 35848736)";

        -- ============ SLT Tests (3 cases) ============
        report "--- SLT Test 1: First < Second ---";
        operand1_s <= B"00000000000000000000000000000101"; -- 5
        operand2_s <= B"00000000000000000000000000001010"; -- 10
        func3_s <= Func3SLT;              -- "010"
        func7_s <= Func7ADD;              -- don't care
        wait for 0 ns;
        wait for 10 * period;
        report "SLT1: " & to_string(operand1_s) & " < " & to_string(operand2_s) & " = " & to_string(result_s) & " (expected: 1)";

        report "--- SLT Test 2: First > Second ---";
        operand1_s <= B"00000000000000000000000000001010"; -- 10
        operand2_s <= B"00000000000000000000000000000101"; -- 5
        func3_s <= Func3SLT;
        func7_s <= Func7ADD;
        wait for 0 ns;
        wait for 10 * period;
        report "SLT2: " & to_string(operand1_s) & " < " & to_string(operand2_s) & " = " & to_string(result_s) & " (expected: 0)";

        report "--- SLT Test 3: Negative vs Positive ---";
        operand1_s <= B"11111111111111111111111111111111"; -- -1
        operand2_s <= B"00000000000000000000000000000001"; -- 1
        func3_s <= Func3SLT;
        func7_s <= Func7ADD;
        wait for 0 ns;
        wait for 10 * period;
        report "SLT3: " & to_string(operand1_s) & " < " & to_string(operand2_s) & " = " & to_string(result_s) & " (expected: 1)";

        -- ============ SLTU Tests (3 cases) ============
        report "--- SLTU Test 1: Small unsigned comparison ---";
        operand1_s <= B"00000000000000000000000000000101"; -- 5
        operand2_s <= B"00000000000000000000000000001010"; -- 10
        func3_s <= Func3SLTU;             -- "011"
        func7_s <= Func7ADD;
        wait for 0 ns;
        wait for 10 * period;
        report "SLTU1: " & to_string(operand1_s) & " <u " & to_string(operand2_s) & " = " & to_string(result_s) & " (expected: 1)";

        report "--- SLTU Test 2: Large unsigned vs small ---";
        operand1_s <= B"11111111111111111111111111111111"; -- 0xFFFFFFFF (large unsigned)
        operand2_s <= B"00000000000000000000000000000001"; -- 1
        func3_s <= Func3SLTU;
        func7_s <= Func7ADD;
        wait for 0 ns;
        wait for 10 * period;
        report "SLTU2: " & to_string(operand1_s) & " <u " & to_string(operand2_s) & " = " & to_string(result_s) & " (expected: 0)";

        report "--- SLTU Test 3: Equal values ---";
        operand1_s <= B"00000000000000000000000001111111"; -- 127
        operand2_s <= B"00000000000000000000000001111111"; -- 127
        func3_s <= Func3SLTU;
        func7_s <= Func7ADD;
        wait for 0 ns;
        wait for 10 * period;
        report "SLTU3: " & to_string(operand1_s) & " <u " & to_string(operand2_s) & " = " & to_string(result_s) & " (expected: 0)";

        -- ============ SLL Tests (3 cases) ============
        report "--- SLL Test 1: Shift 1 by 1 position ---";
        operand1_s <= B"00000000000000000000000000000001"; -- 1
        operand2_s <= B"00000000000000000000000000000000"; -- don't care for shift
        func3_s <= Func3SLL;              -- "001"
        func7_s <= Func7ShLog;            -- "0000000"
        wait for 0 ns;
        wait for 10 * period;
        report "SLL1: " & to_string(operand1_s) & " << 1 = " & to_string(result_s) & " (expected: 2)";

        report "--- SLL Test 2: Shift larger number ---";
        operand1_s <= B"00000000000000000000000000000011"; -- 3
        operand2_s <= B"00000000000000000000000000000000"; -- don't care
        func3_s <= Func3SLL;
        func7_s <= Func7ShLog;
        wait for 0 ns;
        wait for 10 * period;
        report "SLL2: " & to_string(operand1_s) & " << 1 = " & to_string(result_s) & " (expected: 6)";

        report "--- SLL Test 3: Shift zero ---";
        operand1_s <= B"00000000000000000000000000000000"; -- 0
        operand2_s <= B"00000000000000000000000000000000"; -- don't care
        func3_s <= Func3SLL;
        func7_s <= Func7ShLog;
        wait for 0 ns;
        wait for 10 * period;
        report "SLL3: " & to_string(operand1_s) & " << 1 = " & to_string(result_s) & " (expected: 0)";

        -- ============ SRL Tests (3 cases) ============
        report "--- SRL Test 1: Shift 16 right ---";
        operand1_s <= B"00000000000000000000000000010000"; -- 16
        operand2_s <= B"00000000000000000000000000000000"; -- don't care
        func3_s <= Func3SRL_SRA;          -- "101"
        func7_s <= Func7ShLog;            -- "0000000"
        wait for 0 ns;
        wait for 10 * period;
        report "SRL1: " & to_string(operand1_s) & " >> 1 = " & to_string(result_s) & " (expected: 8)";

        report "--- SRL Test 2: Shift larger number ---";
        operand1_s <= B"00000000000000000000000001000000"; -- 64
        operand2_s <= B"00000000000000000000000000000000"; -- don't care
        func3_s <= Func3SRL_SRA;
        func7_s <= Func7ShLog;
        wait for 0 ns;
        wait for 10 * period;
        report "SRL2: " & to_string(operand1_s) & " >> 1 = " & to_string(result_s) & " (expected: 32)";

        report "--- SRL Test 3: Shift odd number ---";
        operand1_s <= B"00000000000000000000000000000111"; -- 7
        operand2_s <= B"00000000000000000000000000000000"; -- don't care
        func3_s <= Func3SRL_SRA;
        func7_s <= Func7ShLog;
        wait for 0 ns;
        wait for 10 * period;
        report "SRL3: " & to_string(operand1_s) & " >> 1 = " & to_string(result_s) & " (expected: 3)";

        -- ============ SRA Tests (3 cases) ============
        report "--- SRA Test 1: Positive number ---";
        operand1_s <= B"00000000000000000000000001000000"; -- 64 (positive)
        operand2_s <= B"00000000000000000000000000000000"; -- don't care
        func3_s <= Func3SRL_SRA;          -- "101"
        func7_s <= Func7ShArthm;          -- "0100000"
        wait for 0 ns;
        wait for 10 * period;
        report "SRA1: " & to_string(operand1_s) & " >>> 1 = " & to_string(result_s) & " (expected: 32)";

        report "--- SRA Test 2: Negative number ---";
        operand1_s <= B"11110000000000000000000000000000"; -- negative
        operand2_s <= B"00000000000000000000000000000000"; -- don't care
        func3_s <= Func3SRL_SRA;
        func7_s <= Func7ShArthm;
        wait for 0 ns;
        wait for 10 * period;
        report "SRA2: " & to_string(operand1_s) & " >>> 1 = " & to_string(result_s) & " (expected: sign-extended)";

        report "--- SRA Test 3: -1 (all ones) ---";
        operand1_s <= B"11111111111111111111111111111111"; -- -1
        operand2_s <= B"00000000000000000000000000000000"; -- don't care
        func3_s <= Func3SRL_SRA;
        func7_s <= Func7ShArthm;
        wait for 0 ns;
        wait for 10 * period;
        report "SRA3: " & to_string(operand1_s) & " >>> 1 = " & to_string(result_s) & " (expected: -1)";

        -- ============ Branch Tests (BEQ) ============
        report "--- BEQ Test 1: Equal values ---";
        operand1_s <= B"00000000000000000000000000000101"; -- 5
        operand2_s <= B"00000000000000000000000000000101"; -- 5
        func3_s <= Func3BEQ;              -- "000"
        func7_s <= Func7ADD;              -- don't care
        wait for 0 ns;
        wait for 10 * period;
        report "BEQ1: " & to_string(operand1_s) & " == " & to_string(operand2_s) & " -> branch = " & bit'image(branch_s) & " (expected: 1)";

        report "--- BEQ Test 2: Not equal values ---";
        operand1_s <= B"00000000000000000000000000000101"; -- 5
        operand2_s <= B"00000000000000000000000000001010"; -- 10
        func3_s <= Func3BEQ;
        func7_s <= Func7ADD;
        wait for 0 ns;
        wait for 10 * period;
        report "BEQ2: " & to_string(operand1_s) & " == " & to_string(operand2_s) & " -> branch = " & bit'image(branch_s) & " (expected: 0)";

        report "--- BEQ Test 3: Zero values ---";
        operand1_s <= B"00000000000000000000000000000000"; -- 0
        operand2_s <= B"00000000000000000000000000000000"; -- 0
        func3_s <= Func3BEQ;
        func7_s <= Func7ADD;
        wait for 0 ns;
        wait for 10 * period;
        report "BEQ3: " & to_string(operand1_s) & " == " & to_string(operand2_s) & " -> branch = " & bit'image(branch_s) & " (expected: 1)";

        report "=== All ALU Tests Completed ===";
        
        wait;
    end process;
end Behavioral;
