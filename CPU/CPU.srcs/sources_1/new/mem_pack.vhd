library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_BIT.ALL;
use WORK.defs_pack.all;
use WORK.conversion_pack.all;
use STD.TEXTIO.all;

--@0x0ff0
--ADD   X01 X02 X03
--SUB   X04 X05 X06
--ANDI  X07 X08 #12
--LB    X03 X04 #1F
--SLTIU X10 X11 X12

package mem_pack is
    function toAddrType  (hex_str: string)      return AddrType;
    function toConstant  (hex_str: string)      return integer;
    function toRegAddrType(decimal_str: string) return RegAddrType;
    function toMnemonic(mnemonic_str: string)   return MnemonicType;
    function toMemEntry (mn : MnemonicType; r1: RegAddrType; r2: RegAddrType; r3: RegAddrType; imm: integer)
        return BusDataType;
    impure function init_memory (filename: string) return MemType;
end mem_pack;



package body mem_pack is

    -- Function to convert a hex string to AddrType (16 bits)
    function toAddrType(hex_str: string) return AddrType is
        constant HEX_DIGITS: integer := 4; -- Expected number of hex digits
        variable clean_str: string(hex_str'range);
        variable addr_result: AddrType := (others => '0'); -- Initialize as 16 bits of '0'
        variable idx: integer := 0;
    begin
        -- Remove the "0x" prefix if it exists
        if hex_str'length >= 2 and hex_str(1) = '0' and (hex_str(2) = 'x' or hex_str(2) = 'X') then
            clean_str := hex_str(3 to hex_str'length);
        else
            clean_str := hex_str;
        end if;

        -- Check if the cleaned string length matches the expected number of hex digits
        if clean_str'length /= HEX_DIGITS then
            assert false report "Hex string must be exactly 4 hexadecimal digits." severity failure;
        end if;

        -- Convert each hex character into binary
        for i in clean_str'range loop
            case clean_str(i) is
                when '0'       => addr_result(idx + 3 downto idx) := "0000";
                when '1'       => addr_result(idx + 3 downto idx) := "0001";
                when '2'       => addr_result(idx + 3 downto idx) := "0010";
                when '3'       => addr_result(idx + 3 downto idx) := "0011";
                when '4'       => addr_result(idx + 3 downto idx) := "0100";
                when '5'       => addr_result(idx + 3 downto idx) := "0101";
                when '6'       => addr_result(idx + 3 downto idx) := "0110";
                when '7'       => addr_result(idx + 3 downto idx) := "0111";
                when '8'       => addr_result(idx + 3 downto idx) := "1000";
                when '9'       => addr_result(idx + 3 downto idx) := "1001";
                when 'A' | 'a' => addr_result(idx + 3 downto idx) := "1010";
                when 'B' | 'b' => addr_result(idx + 3 downto idx) := "1011";
                when 'C' | 'c' => addr_result(idx + 3 downto idx) := "1100";
                when 'D' | 'd' => addr_result(idx + 3 downto idx) := "1101";
                when 'E' | 'e' => addr_result(idx + 3 downto idx) := "1110";
                when 'F' | 'f' => addr_result(idx + 3 downto idx) := "1111";
                when others =>
                    assert false report "Invalid character in hex string: " & clean_str(i) severity failure;
            end case;
            idx := idx + 4; -- Move to the next set of 4 bits
        end loop;

        return addr_result;
    end toAddrType;
    
    
    
    -- Function to convert a hexadecimal string to an integer
    function toConstant(hex_str: string) return integer is
        variable result: integer := 0;
        variable hex_value: integer;
    begin
        -- Iterate through each character in the string
        for i in hex_str'range loop
            case hex_str(i) is
                when '0'       => hex_value := 0;
                when '1'       => hex_value := 1;
                when '2'       => hex_value := 2;
                when '3'       => hex_value := 3;
                when '4'       => hex_value := 4;
                when '5'       => hex_value := 5;
                when '6'       => hex_value := 6;
                when '7'       => hex_value := 7;
                when '8'       => hex_value := 8;
                when '9'       => hex_value := 9;
                when 'A' | 'a' => hex_value := 10;
                when 'B' | 'b' => hex_value := 11;
                when 'C' | 'c' => hex_value := 12;
                when 'D' | 'd' => hex_value := 13;
                when 'E' | 'e' => hex_value := 14;
                when 'F' | 'f' => hex_value := 15;
                when others =>
                    assert false report "Invalid character in hex string: " & hex_str(i) severity failure;
            end case;

            -- Shift the current result and add the new hex value
            result := result * 16 + hex_value;
        end loop;

        return result;
    end toConstant;
    
    
    
    -- Function to convert decimal string to RegAddrType (bit_vector size based on RegAddrSize)
    function toRegAddrType(decimal_str: string) return RegAddrType is
        variable result: RegAddrType := (others => '0');
        variable decimal_value: integer;
        constant MAX_VALUE: integer := (2 ** RegAddrSize) - 1;  -- Maximum value that fits in RegAddrSize bits
    begin
        -- Convert the string to an integer
        decimal_value := integer'VALUE(decimal_str);

        -- Check if the decimal value is within the valid range (0 to 2^RegAddrSize - 1)
        if decimal_value < 0 or decimal_value > MAX_VALUE then
            assert false report "Decimal value out of range (0 to " & integer'image(MAX_VALUE) & ")" severity failure;
        end if;

        -- Convert the integer to a RegAddrType (bit_vector with size RegAddrSize)
        result := RegAddrType(to_unsigned(decimal_value, RegAddrSize));

        return result;
    end toRegAddrType;



    function toMnemonic(mnemonic_str: string) return MnemonicType is
    begin
    case mnemonic_str is
        when "LB" => return LB;
        when "LBU" => return LBU;
        when "LH" => return LH;
        when "LHU" => return LHU;
        when "LW" => return LW;
        when "SB" => return SB;
        when "SH" => return SH;
        when "SW" => return SW;
        when "ADD" => return ADD;
        when "SUB" => return SUB;
        when "ADDI" => return ADDI;
        when "LUI" => return LUI;
        when "AUIPC" => return AUIPC;
        when "XOR" => return XORr;
        when "OR" => return ORr;
        when "AND" => return ANDr;
        when "XORI" => return XORI;
        when "ORI" => return ORI;
        when "ANDI" => return ANDI;
        when "SLL" => return SLLr;
        when "SRL" => return SRLr;
        when "SRA" => return SRAr;
        when "SLLI" => return SLLI;
        when "SRLI" => return SRLI;
        when "SRAI" => return SRAI;
        when "SLT" => return SLT;
        when "SLTU" => return SLTU;
        when "SLTI" => return SLTI;
        when "SLTIU" => return SLTIU;
        when "JAL" => return JAL;
        when "JALR" => return JALR;
        when "BEQ" => return BEQ;
        when "BNE" => return BNE;
        when "BLT" => return BLT;
        when "BLTU" => return BLTU;
        when "BGE" => return BGE;
        when "BGEU" => return BGEU;
        when others => assert false report "Invalid mnemonic: " & mnemonic_str severity failure;
    end case;
    end function;
    
    function toMemEntry (mn : MnemonicType; r1: RegAddrType; r2: RegAddrType; r3: RegAddrType; imm: integer)
        return BusDataType is
        variable result    : BusDataType := (others => '0');
        variable imm12     : bit_vector  := (others => '0');
        variable imm20     : bit_vector  := (others => '0');
        variable shamt     : bit_vector  := (others => '0');
    begin
        imm12 := bit_vector(TO_UNSIGNED(imm,12));
        imm20 := bit_vector(TO_UNSIGNED(imm,20));
        shamt := bit_vector(TO_UNSIGNED(imm,5));
        case mn is
            when EBREAK =>
                return X"000000" & '0' & OpEBREAK; -- 25 zeros and 7 bit opcode
            -- LOADs
            when LB => 
                return imm12 & r2 & Func3LB  & r1 & OpLoad;
            when LBU =>
                return imm12 & r2 & Func3LBU & r1 & OpLoad;
            when LH   =>
                return imm12 & r2 & Func3LH  & r1 & OpLoad;
            when LHU => 
                return imm12 & r2 & Func3LHU & r1 & OpLoad;
            when LW =>
                return imm12 & r2 & Func3LW  & r1 & OpLoad;
            -- STOREs
            when SB =>
                return imm12(11 downto 5) & r2 & r1 & Func3SB & imm12(4 downto 0) & OpStore;
            when SH =>
                return imm12(11 downto 5) & r2 & r1 & Func3SH & imm12(4 downto 0) & OpStore;
            when SW =>
                return imm12(11 downto 5) & r2 & r1 & Func3SW & imm12(4 downto 0) & OpStore;
            -- ARITHMETICAL
            when ADD => 
                return Func7ADD & r3 & r2 & Func3Arthm & r1 & OpReg;
            when SUB => 
                return Func7SUB & r3 & r2 & Func3Arthm & r1 & OpReg;
            when ADDI => 
                return         imm12 & r2 & Func3Arthm & r1 & OpImm;
            -- UPPER IMMEDIATE
            when LUI => 
                return imm20 & r1 & OpLUI;
            when AUIPC => 
                return imm20 & r1 & OpAUIPC;
            -- LOGICAL
            when XORr => 
                return Func7Log & r3 & r2 & Func3XOR & r1 & OpReg;
            when ORr => 
                return Func7Log & r3 & r2 & Func3OR  & r1 & OpReg;
            when ANDr =>    
                return Func7Log & r3 & r2 & Func3AND & r1 & OpReg;
            when XORI => 
                return imm12 & r2 & Func3XOR & r1 & OpImm;
            when ORI => 
                return imm12 & r2 & Func3OR  & r1 & OpImm;
            when ANDI => 
                return imm12 & r2 & Func3AND & r1 & OpImm;
            -- SHIFTs
            when SLLr => 
                return Func7ShLog   & r3 & r2 & Func3SLL     & r1 & OpReg;
            when SRLr => 
                return Func7ShLog   & r3 & r2 & Func3SRL_SRA & r1 & OpReg;            
            when SRAr => 
                return Func7ShArthm & r3 & r2 & Func3SRL_SRA & r1 & OpReg;            
            when SLLI => 
                return Func7ShLog   & shamt & r2 & Func3SLL     & r1 & OpImm;
            when SRLI => 
                return Func7ShLog   & shamt & r2 & Func3SRL_SRA & r1 & OpImm;
            when SRAI => 
                return Func7ShArthm & shamt & r2 & Func3SRL_SRA & r1 & OpImm;
            -- COMPAREs
            when SLT => 
                return Func7Set & r3 & r2 & Func3SLT  & r1 & OpReg;
            when SLTU => 
                return Func7Set & r3 & r2 & Func3SLTU & r1 & OpReg;
            when SLTI => 
                return         imm12 & r2 & Func3SLT  & r1 & OpImm;
            when SLTIU => 
                return         imm12 & r2 & Func3SLTU & r1 & OpImm;
            -- BRANCHes
            when BEQ =>
                return imm12(12) & imm12(10 downto 5) & r2 & r1 & Func3BEQ & imm12(4 downto 1) & imm12(11) & OpBranch;
            when BNE => 
                return imm12(12) & imm12(10 downto 5) & r2 & r1 & Func3BNE & imm12(4 downto 1) & imm12(11) & OpBranch;
            when BLT => 
                return imm12(12) & imm12(10 downto 5) & r2 & r1 & Func3BLT & imm12(4 downto 1) & imm12(11) & OpBranch;
            when BGE => 
                return imm12(12) & imm12(10 downto 5) & r2 & r1 & Func3BGE & imm12(4 downto 1) & imm12(11) & OpBranch;
            when BLTU => 
                return imm12(12) & imm12(10 downto 5) & r2 & r1 & Func3BLTU & imm12(4 downto 1) & imm12(11) & OpBranch;
            when BGEU => 
                return imm12(12) & imm12(10 downto 5) & r2 & r1 & Func3BGEU & imm12(4 downto 1) & imm12(11) & OpBranch;
            -- JUMPs
            when JAL => 
                return imm20 & r1 & OpJump;
            when JALR => 
                return imm12 & r2 & Func3JALR & r1 & OpJumpReg;
        end case;    
    end toMemEntry;        



    impure function init_memory (filename: string) return MemType is
        file     f        : text is in filename;
        variable l        : line;
        variable mem      : MemType;
        variable success  : boolean;
        variable addr     : AddrType := (others => '0');
        variable v        : string(1 to 6);
        --variable w        :
        variable r1,r2,r3 : RegAddrType := (others => '0');
        variable mnemonic : MnemonicType;
        variable imm      : integer;
        
        variable r1_set, r2_set : boolean := FALSE;
        variable addr_ptr : boolean := FALSE; -- check if the current line in file is of @-type
        
    begin
        line_loop: loop --read line by line
        exit when endfile (f);
        readline (f, l);
        
        if l'length = 0 then
            next; -- empty line
        end if;
        if l'length >= 2 then
            if l.all(1) = '-' and l.all(2) = '-' then
                next; -- comment line
            end if;
        end if;
        
        success := TRUE;--read values in each line
        word_loop: while success loop
            read(l, v, success);                
            if v(1) = '@' then
                addr := toAddrType(v(2 to v'right));
                addr_ptr := TRUE;
            elsif v(1) = '#' then
                imm := toConstant(v(2 to v'right));
            elsif v(1) = 'X' or v(1) = 'x' then
                if r1_set = true then
                    if r2_set = true then
                        r3 := toRegAddrType(v(2 to v'right));
                    else r2 := toRegAddrType(v(2 to v'right));
                    end if;
                else
                    r1 := toRegAddrType(v(2 to v'right));
                    r1_set := true;
                end if;
            else mnemonic := toMnemonic(v(1 to v'right));
            end if;
        end loop word_loop;
        
        -- check if the line is a CPU command
        if not(addr_ptr) then
            mem (to_integer(addr)):= toMemEntry(mnemonic, r1, r2, r3, imm);
            exit line_loop when addr = 2**MemoryAddrSize-1;
            addr := addr + 4;
            r1_set := FALSE;
            r2_set := FALSE;
        end if;
        addr_ptr := TRUE; -- reset the flag for the next line of file
        
        end loop line_loop;
    return mem;
    end init_memory;
end mem_pack;


