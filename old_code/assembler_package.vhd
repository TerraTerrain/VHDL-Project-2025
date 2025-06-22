library IEEE;
use std.textio.all;
use IEEE.numeric_bit.all;
use WORK.definition_package.ALL;

package assembler_package is
    
    procedure init_memory(constant filename: in string; variable Mem: out MemType);
    
    -- Supportfunctions f�r init_memory
    function to_addr(constant addr_string: in string) return integer;
    function to_constant(constant imm_string: in string) return bit_vector;
    function to_reg(constant reg_string: in string) return bit_vector;
    function to_mnemonic(constant mnemonic_string: in string) return natural;
    function to_mem(constant mnemonic: in natural; constant rd: in bit_vector(RegAddrSize-1 downto 0); rs1: in bit_vector(RegAddrSize-1 downto 0); rs2: in bit_vector(RegAddrSize-1 downto 0); constant imm: in bit_vector(RegDataSize-1 downto 0)) return BusDataType;
    
    -- Hex-String ib Bitvektor umwandeln
    function hex_string_to_bit_vector(constant hex_string: in string) return bit_vector;
    
    
end assembler_package;


package body assembler_package is
 
 -- Assembler Struktur:
 -- Adressen beginnen mit '@', werden hexadezimal dargestellt und sind vier Stellen breit, z.B. @0x0100
 -- Konstanten beginnen werden mit dem Schl�sselwort VAL eingeleitet, beginnen dann mit '#', werden hexadezimal dargestellt 
 -- und k�nnen zwischen einer und acht Stellen breit sein, z.B. #A1F3
 -- Andere Befehle beginnen mit dem jeweiligen Mnemonic
 -- Register beginnen mit 'X' und werden danach nummeriert (0, 1,..., 31)
 -- Wichtig zu beachten ist, dass im txt-File alle Breiten genau eingehalten werden!!!
 -- Mnemonics sind immer sechs Stellen breit (evtl. mit Leerzeichen auff�llen), danach folgt ein weiteres Leerzeichen
 -- Register sind immer drei Stellen breit (das X und dann die Nummer -> evtl. mit Leerzeichen auff�llen)
 -- Vor jedem weiteren Bestandteil (Register oder Konstante) steht immer ein weiteres Leerzeichen
    
    
    procedure init_memory(constant filename: in string; variable Mem: out MemType) is
    
        file MemFile : Text open read_mode is filename;
        variable file_line: line;
        variable line_length : integer;
        variable v: string(1 to 25);
        variable rd, rs1, rs2: RegAddrType;
        variable i: integer := 0;
        variable mnemonic: natural;
        variable imm: bit_vector(RegDataSize-1 downto 0);

        
    begin
    
         while not endfile(MemFile) loop
         
                v := (others => ' ');
                readline (MemFile, file_line);
                line_length := file_line'length;
                v(1 to line_length) := file_line.all(1 to line_length);
                report v;
                if v(1) = '@' then
                        i := to_addr(v(4 to 7)) -1;
                else
                        mnemonic := to_mnemonic(v(1 to 6));
                        if mnemonic = 38 then
                            imm := to_constant(v(9 to 16));
                        end if;
                        if line_length > 6 then
                            if v(8) = 'X' and mnemonic < 31 and mnemonic /= 5 and mnemonic /= 6 and mnemonic /= 7 then
                                rd := to_reg(v(9 to 10));
                            end if;
                            if v(8) = 'X' and (mnemonic > 30 or mnemonic = 5 or mnemonic = 6 or mnemonic = 7) then
                                    rs1 := to_re+g(v(9 to 10));
                                end if;
                            if line_length > 10 then
                                if v(12) = 'X' and mnemonic < 31 and mnemonic /= 5 and mnemonic /= 6 and mnemonic /= 7 then
                                    rs1 := to_reg(v(13 to 14));
                                end if;
                                if v(12) = 'X' and (mnemonic > 30 or mnemonic = 5 or mnemonic = 6 or mnemonic = 7)then
                                    rs2 := to_reg(v(13 to 14));
                                end if;
                                if v(12) = '#' then
                                        imm := to_constant(v(13 to 20));
                                end if;
                                if line_length > 14 then
                                    if v(16) = 'X' then
                                        rs2 := to_reg(v(17 to 18));
                                    end if;
                                    if v(16) = '#' then
                                        imm := to_constant(v(17 to 24));
                                    end if;
                                end if; 
                            end if; 
                        end if; 
                        Mem(i) := to_mem(mnemonic, rd, rs1, rs2, imm);     
                    end if;
                exit when i = 2**MemoryAddrSize -1;
                i := i+1;      
            end loop;
    end init_memory;
    
    
    -- Addresse auslesen
    function to_addr(constant addr_string: in string) return integer is
    begin
        return to_integer(unsigned(hex_string_to_bit_vector(addr_string)));
    end to_addr;
    
    
    -- Konstante bzw. Immediate auslesen
    function to_constant(constant imm_string: in string) return bit_vector is
        variable imm_string_new: string (1 to 8) := imm_string;
        variable zero_string: string (1 to 8) := "00000000";
        variable len: natural := 0;
    begin
        -- L�nge der Konstante bestimmen und String ggf. mit Nullen auff�llen
        while not (imm_string_new(len+1) = ' ' or imm_string_new(len+1) = character'val(13) or imm_string_new(len+1) = character'val(10)) loop
            len := len + 1;
            exit when len = 8;
        end loop;
        if len > 0 and len < 8 then
            imm_string_new(9-len to 8) := imm_string_new(1 to len);
            imm_string_new(1 to 8-len) := zero_string(1 to 8-len); 
        end if;
        return bit_vector(unsigned(hex_string_to_bit_vector(imm_string_new)));
    end to_constant;
    
    
    -- Nummer der verwendeten Register auslesen
    function to_reg(constant reg_string: in string) return bit_vector is
        variable reg_num: natural;
        variable help_vector: bit_vector(7 downto 0);
        variable reg_string_new: string(1 to 2) := reg_string;
    begin
        -- �berpr�fen, ob Registernummer ein oder zwei Stellen breit und eventuell zu z.B. 01 erg�nzen -> einheitliche Verarbeitung
        if reg_string_new(2) = ' ' or reg_string_new(2) = character'val(13) or reg_string_new(2) = character'val(10) then 
            reg_string_new(2) := reg_string_new(1);
            reg_string_new(1) := '0';
        end if;
            help_vector := hex_string_to_bit_vector(reg_string_new);
            reg_num := 10*to_integer(unsigned(help_vector(7 downto 4))) + to_integer(unsigned(help_vector(3 downto 0)));
        return bit_vector(to_unsigned(reg_num,5));
    end to_reg;
    
    
    -- Mnemonic auslesen -> zugeh�rige(r) Zahl(enbereich) bestimmt das Ausleseverhalten der restlichen Zeile
    function to_mnemonic(constant mnemonic_string: in string) return natural is
    begin
        case mnemonic_string is
            when "LB    " => return 0;
            when "LH    " => return 1;
            when "LW    " => return 2;
            when "LBU   " => return 3;
            when "LHU   " => return 4;
            when "SB    " => return 5;
            when "SH    " => return 6;
            when "SW    " => return 7;
            when "JAL   " => return 8;
            when "JALR  " => return 9;
            when "LUI   " => return 10;
            when "AUIPC " => return 11;
            when "ADDI  " => return 12;
            when "ADD   " => return 13;
            when "SUB   " => return 14;
            when "XORI  " => return 15;
            when "ORI   " => return 16;
            when "ANDI  " => return 17;
            when "XOR   " => return 18;
            when "OR    " => return 19;
            when "AND   " => return 20;
            when "SLTI  " => return 21;
            when "SLTIU " => return 22;
            when "SLT   " => return 23;
            when "SLTU  " => return 24;
            when "SLLI  " => return 25;
            when "SRLI  " => return 26;
            when "SRAI  " => return 27;
            when "SLL   " => return 28;
            when "SRL   " => return 29;
            when "SRA   " => return 30;
            when "BEQ   " => return 31;
            when "BNE   " => return 32;
            when "BLT   " => return 33;
            when "BGE   " => return 34;
            when "BLTU  " => return 35;
            when "BGEU  " => return 36;
            when "EBREAK" => return 37;
            when "VAL   " => return 38;
            when others => assert false report "Illegal Operation" severity failure;
        end case;
    end to_mnemonic;
    
    
    -- Bitstream anhand der ausgelesenen Daten festlegen
    function to_mem(constant mnemonic: in natural; constant rd: in bit_vector(RegAddrSize-1 downto 0); rs1: in bit_vector(RegAddrSize-1 downto 0); rs2: in bit_vector(RegAddrSize-1 downto 0); constant imm: in bit_vector(RegDataSize-1 downto 0)) return BusDataType is
        variable memory_entry: BusDataType := (others => '0');
    begin
        case mnemonic is
        when 0 => memory_entry(6 downto 0) := OpCodeLoad; memory_entry(11 downto 7) := rd; memory_entry(14 downto 12) := Func3CodeLB; memory_entry(19 downto 15) := rs1; memory_entry(31 downto 20) := imm(11 downto 0);
        when 1 => memory_entry(6 downto 0) := OpCodeLoad; memory_entry(11 downto 7) := rd; memory_entry(14 downto 12) := Func3CodeLH; memory_entry(19 downto 15) := rs1; memory_entry(31 downto 20) := imm(11 downto 0);
        when 2 => memory_entry(6 downto 0) := OpCodeLoad; memory_entry(11 downto 7) := rd; memory_entry(14 downto 12) := Func3CodeLW; memory_entry(19 downto 15) := rs1; memory_entry(31 downto 20) := imm(11 downto 0);
        when 3 => memory_entry(6 downto 0) := OpCodeLoad; memory_entry(11 downto 7) := rd; memory_entry(14 downto 12) := Func3CodeLBU; memory_entry(19 downto 15) := rs1; memory_entry(31 downto 20) := imm(11 downto 0);
        when 4 => memory_entry(6 downto 0) := OpCodeLoad; memory_entry(11 downto 7) := rd; memory_entry(14 downto 12) := Func3CodeLHU; memory_entry(19 downto 15) := rs1; memory_entry(31 downto 20) := imm(11 downto 0);
        when 5 => memory_entry(6 downto 0) := OpCodeStore; memory_entry(11 downto 7) := imm(4 downto 0); memory_entry(14 downto 12) := Func3CodeSB; memory_entry(19 downto 15) := rs1; memory_entry(24 downto 20) := rs2; memory_entry(31 downto 25) := imm(11 downto 5);
        when 6 => memory_entry(6 downto 0) := OpCodeStore; memory_entry(11 downto 7) := imm(4 downto 0); memory_entry(14 downto 12) := Func3CodeSH; memory_entry(19 downto 15) := rs1; memory_entry(24 downto 20) := rs2; memory_entry(31 downto 25) := imm(11 downto 5);
        when 7 => memory_entry(6 downto 0) := OpCodeStore; memory_entry(11 downto 7) := imm(4 downto 0); memory_entry(14 downto 12) := Func3CodeSW; memory_entry(19 downto 15) := rs1; memory_entry(24 downto 20) := rs2; memory_entry(31 downto 25) := imm(11 downto 5);
        when 8 => memory_entry(6 downto 0) := OpCodeJAL; memory_entry(11 downto 7) := rd; memory_entry(19 downto 12) := imm(19 downto 12); memory_entry(20 downto 20) := imm(11 downto 11); memory_entry(30 downto 21) := imm(10 downto 1); memory_entry(31 downto 31) := imm(20 downto 20);
        when 9 => memory_entry(6 downto 0) := OpCodeJALR; memory_entry(11 downto 7) := rd; memory_entry(14 downto 12) := Func3CodeJALR; memory_entry(19 downto 15) := rs1; memory_entry(31 downto 20) := imm(11 downto 0);
        when 10 => memory_entry(6 downto 0) := OpCodeLUI; memory_entry(11 downto 7) := rd; memory_entry(31 downto 12) := imm(19 downto 0);
        when 11 => memory_entry(6 downto 0) := OpCodeAUIPC; memory_entry(11 downto 7) := rd; memory_entry(31 downto 12) := imm(19 downto 0);
        when 12 => memory_entry(6 downto 0) := OpCodeALUI; memory_entry(11 downto 7) := rd; memory_entry(14 downto 12) := Func3CodeADDI; memory_entry(19 downto 15) := rs1; memory_entry(31 downto 20) := imm(11 downto 0);
        when 13 => memory_entry(6 downto 0) := OpCodeALUR; memory_entry(11 downto 7) := rd; memory_entry(14 downto 12) := Func3CodeArithmeticR; memory_entry(19 downto 15) := rs1; memory_entry(24 downto 20) := rs2; memory_entry(31 downto 25) := Func7CodeADD;
        when 14 => memory_entry(6 downto 0) := OpCodeALUR; memory_entry(11 downto 7) := rd; memory_entry(14 downto 12) := Func3CodeArithmeticR; memory_entry(19 downto 15) := rs1; memory_entry(24 downto 20) := rs2; memory_entry(31 downto 25) := Func7CodeSUB;
        when 15 => memory_entry(6 downto 0) := OpCodeALUI; memory_entry(11 downto 7) := rd; memory_entry(14 downto 12) := Func3CodeXOR; memory_entry(19 downto 15) := rs1; memory_entry(31 downto 20) := imm(11 downto 0);
        when 16 => memory_entry(6 downto 0) := OpCodeALUI; memory_entry(11 downto 7) := rd; memory_entry(14 downto 12) := Func3CodeOR; memory_entry(19 downto 15) := rs1; memory_entry(31 downto 20) := imm(11 downto 0);
        when 17 => memory_entry(6 downto 0) := OpCodeALUI; memory_entry(11 downto 7) := rd; memory_entry(14 downto 12) := Func3CodeAND; memory_entry(19 downto 15) := rs1; memory_entry(31 downto 20) := imm(11 downto 0);
        when 18 => memory_entry(6 downto 0) := OpCodeALUR; memory_entry(11 downto 7) := rd; memory_entry(14 downto 12) := Func3CodeXOR; memory_entry(19 downto 15) := rs1; memory_entry(24 downto 20) := rs2; memory_entry(31 downto 25) := Func7CodeALUR;
        when 19 => memory_entry(6 downto 0) := OpCodeALUR; memory_entry(11 downto 7) := rd; memory_entry(14 downto 12) := Func3CodeOR; memory_entry(19 downto 15) := rs1; memory_entry(24 downto 20) := rs2; memory_entry(31 downto 25) := Func7CodeALUR;
        when 20 => memory_entry(6 downto 0) := OpCodeALUR; memory_entry(11 downto 7) := rd; memory_entry(14 downto 12) := Func3CodeAND; memory_entry(19 downto 15) := rs1; memory_entry(24 downto 20) := rs2; memory_entry(31 downto 25) := Func7CodeALUR;
        when 21 => memory_entry(6 downto 0) := OpCodeALUI; memory_entry(11 downto 7) := rd; memory_entry(14 downto 12) := Func3CodeSLT; memory_entry(19 downto 15) := rs1; memory_entry(31 downto 20) := imm(11 downto 0);
        when 22 => memory_entry(6 downto 0) := OpCodeALUI; memory_entry(11 downto 7) := rd; memory_entry(14 downto 12) := Func3CodeSLTU; memory_entry(19 downto 15) := rs1; memory_entry(31 downto 20) := imm(11 downto 0);
        when 23 => memory_entry(6 downto 0) := OpCodeALUR; memory_entry(11 downto 7) := rd; memory_entry(14 downto 12) := Func3CodeSLT; memory_entry(19 downto 15) := rs1; memory_entry(24 downto 20) := rs2; memory_entry(31 downto 25) := Func7CodeALUR;
        when 24 => memory_entry(6 downto 0) := OpCodeALUR; memory_entry(11 downto 7) := rd; memory_entry(14 downto 12) := Func3CodeSLTU; memory_entry(19 downto 15) := rs1; memory_entry(24 downto 20) := rs2; memory_entry(31 downto 25) := Func7CodeALUR;
        when 25 => memory_entry(6 downto 0) := OpCodeALUI; memory_entry(11 downto 7) := rd; memory_entry(14 downto 12) := Func3CodeSLL; memory_entry(19 downto 15) := rs1; memory_entry(24 downto 20) := imm(4 downto 0); memory_entry(31 downto 25) := Func7CodeSLL;
        when 26 => memory_entry(6 downto 0) := OpCodeALUI; memory_entry(11 downto 7) := rd; memory_entry(14 downto 12) := Func3CodeSR; memory_entry(19 downto 15) := rs1; memory_entry(24 downto 20) := imm(4 downto 0); memory_entry(31 downto 25) := Func7CodeSRL;
        when 27 => memory_entry(6 downto 0) := OpCodeALUI; memory_entry(11 downto 7) := rd; memory_entry(14 downto 12) := Func3CodeSR; memory_entry(19 downto 15) := rs1; memory_entry(24 downto 20) := imm(4 downto 0); memory_entry(31 downto 25) := Func7CodeSRA;
        when 28 => memory_entry(6 downto 0) := OpCodeALUR; memory_entry(11 downto 7) := rd; memory_entry(14 downto 12) := Func3CodeSLL; memory_entry(19 downto 15) := rs1; memory_entry(24 downto 20) := rs2; memory_entry(31 downto 25) := Func7CodeSLL;
        when 29 => memory_entry(6 downto 0) := OpCodeALUR; memory_entry(11 downto 7) := rd; memory_entry(14 downto 12) := Func3CodeSR; memory_entry(19 downto 15) := rs1; memory_entry(24 downto 20) := rs2; memory_entry(31 downto 25) := Func7CodeSRL;
        when 30 => memory_entry(6 downto 0) := OpCodeALUR; memory_entry(11 downto 7) := rd; memory_entry(14 downto 12) := Func3CodeSR; memory_entry(19 downto 15) := rs1; memory_entry(24 downto 20) := rs2; memory_entry(31 downto 25) := Func7CodeSRA;
        when 31 => memory_entry(6 downto 0) := OpCodeBranch; memory_entry(11 downto 7) := imm(4 downto 1) & imm(11 downto 11); memory_entry(14 downto 12) := Func3CodeBEQ; memory_entry(19 downto 15) := rs1; memory_entry(24 downto 20) := rs2; memory_entry(31 downto 25) := imm(12 downto 12) & imm(10 downto 5);
        when 32 => memory_entry(6 downto 0) := OpCodeBranch; memory_entry(11 downto 7) := imm(4 downto 1) & imm(11 downto 11); memory_entry(14 downto 12) := Func3CodeBNE; memory_entry(19 downto 15) := rs1; memory_entry(24 downto 20) := rs2; memory_entry(31 downto 25) := imm(12 downto 12) & imm(10 downto 5);
        when 33 => memory_entry(6 downto 0) := OpCodeBranch; memory_entry(11 downto 7) := imm(4 downto 1) & imm(11 downto 11); memory_entry(14 downto 12) := Func3CodeBLT; memory_entry(19 downto 15) := rs1; memory_entry(24 downto 20) := rs2; memory_entry(31 downto 25) := imm(12 downto 12) & imm(10 downto 5);
        when 34 => memory_entry(6 downto 0) := OpCodeBranch; memory_entry(11 downto 7) := imm(4 downto 1) & imm(11 downto 11); memory_entry(14 downto 12) := Func3CodeBGE; memory_entry(19 downto 15) := rs1; memory_entry(24 downto 20) := rs2; memory_entry(31 downto 25) := imm(12 downto 12) & imm(10 downto 5);
        when 35 => memory_entry(6 downto 0) := OpCodeBranch; memory_entry(11 downto 7) := imm(4 downto 1) & imm(11 downto 11); memory_entry(14 downto 12) := Func3CodeBLTU; memory_entry(19 downto 15) := rs1; memory_entry(24 downto 20) := rs2; memory_entry(31 downto 25) := imm(12 downto 12) & imm(10 downto 5);
        when 36 => memory_entry(6 downto 0) := OpCodeBranch; memory_entry(11 downto 7) := imm(4 downto 1) & imm(11 downto 11); memory_entry(14 downto 12) := Func3CodeBGEU; memory_entry(19 downto 15) := rs1; memory_entry(24 downto 20) := rs2; memory_entry(31 downto 25) := imm(12 downto 12) & imm(10 downto 5);
        when 37 => memory_entry(6 downto 0) := OpCodeEBreak;
        when 38 => memory_entry(31 downto 0) := imm(31 downto 0);
        when others => assert false report "Illegal Operation" severity failure;
        end case;
        return memory_entry;
    end to_mem;
    
    
    
    function hex_string_to_bit_vector(constant hex_string: in string) return bit_vector is
        variable upper_index: natural;
        variable lower_index: natural;
        variable len: natural := hex_string'length;
        variable hex_to_bit: bit_vector((4*len)-1 downto 0);
        variable hex_string_new: string(1 to len) := hex_string;
        
    begin
        
        for i in 0 to len-1 loop
            upper_index := (4*len)-(4*i)-1;
            lower_index :=( 4*len)-(4*i)-4;
            case hex_string_new(i+1 to i+1) is
                when "0" => hex_to_bit(upper_index downto lower_index) := "0000";
                when "1" => hex_to_bit(upper_index downto lower_index) := "0001";
                when "2" => hex_to_bit(upper_index downto lower_index) := "0010";
                when "3" => hex_to_bit(upper_index downto lower_index) := "0011";
                when "4" => hex_to_bit(upper_index downto lower_index) := "0100";
                when "5" => hex_to_bit(upper_index downto lower_index) := "0101";
                when "6" => hex_to_bit(upper_index downto lower_index) := "0110";
                when "7" => hex_to_bit(upper_index downto lower_index) := "0111";
                when "8" => hex_to_bit(upper_index downto lower_index) := "1000";
                when "9" => hex_to_bit(upper_index downto lower_index) := "1001";
                when "A" => hex_to_bit(upper_index downto lower_index) := "1010";
                when "B" => hex_to_bit(upper_index downto lower_index) := "1011";
                when "C" => hex_to_bit(upper_index downto lower_index) := "1100";
                when "D" => hex_to_bit(upper_index downto lower_index) := "1101";
                when "E" => hex_to_bit(upper_index downto lower_index) := "1110";
                when "F" => hex_to_bit(upper_index downto lower_index) := "1111";
                when others => assert false report "Illegal Operation" severity failure;
            end case;
        end loop;
        return hex_to_bit; 
        
    end hex_string_to_bit_vector;
    
end assembler_package;