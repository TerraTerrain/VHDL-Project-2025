library IEEE;
use IEEE.numeric_bit.ALL;
use work.defs_pack.all;
use work.conversion_pack.all;

entity RISCV is
end RISCV;

architecture Functional of RISCV is
begin
    process
        variable PC           : AddrType    := X"0000";
        variable Instr        : InstrType :=(others=>'0');
        variable OP           : OpType      := (others=>'0');
        variable func3        : Func3Type   := (others=>'0');
        variable func7        : Func7Type   := (others=>'0');
        variable rs1, rs2, rd : RegAddrType := (others=>'0');
        variable imm12        : Imm12Type   := (others=>'0');
        variable imm20        : Imm20Type   := (others=>'0');
        variable jimm20        : Imm20Type   := (others=>'0');
        variable bImm         : BImmType    := (others=>'0');
        variable branch_temp  : bit_vector(12 downto 0);
        variable Reg          : RegType     := (others=>(others=>'0'));
        variable Mem          : MemType     := (others=>(others=>'0'));
        

        begin
    
        Instr := Mem(TO_INTEGER(unsigned(PC)));
        OP := Instr (6 downto 0);
        func3 := Instr (14 downto 12);
        func7 := Instr (31 downto 25); -- also used as 1st immediate part for branches and stores
        rs1   := Instr (19 downto 15);
        rs2   := Instr (24 downto 20); -- also immediately used for shifts as shamt
        rd    := Instr (11 downto 7); -- also used as 2nd immediate part for branches and stores
        imm12 := Instr (31 downto 20);
        imm20 := Instr (31 downto 12);
        bImm := Instr(31)&Instr(7)&Instr(30 downto 25)&Instr(11 downto  8);
        jimm20 := Instr (31)&Instr(19 downto 12)&Instr(20)&Instr(30 downto 21)&'0';
        case OP is
        when OpLoad =>
            case func3 is
                when Func3Lb =>
                    Reg(bv2natural(rd)) := sign_extend(to_integer(signed(Mem(to_integer(signed(imm12))))(7 downto 0)), RegDataSize);
                    PC := natural2bv((to_integer(unsigned(PC)) + 4) mod (2**AddrSize), AddrSize);

                when Func3Lbu =>
                    Reg(bv2natural(rd)) := zero_extend(to_integer(unsigned(Mem(to_integer(signed(imm12)))(7 downto 0))), RegDataSize);
                    PC := natural2bv((to_integer(unsigned(PC)) + 4) mod (2**AddrSize), AddrSize);

                when Func3Lh =>
                    Reg(bv2natural(rd)) := sign_extend(to_integer(signed(Mem(to_integer(signed(imm12)))(15 downto 0))), RegDataSize);
                    PC := natural2bv((to_integer(unsigned(PC)) + 4) mod (2**AddrSize), AddrSize);

                when Func3Lhu =>
                    Reg(bv2natural(rd)) := zero_extend(to_integer(unsigned(Mem(to_integer(signed(imm12)))(15 downto 0))), RegDataSize);
                    PC := natural2bv((to_integer(unsigned(PC)) + 4) mod (2**AddrSize), AddrSize);

                when Func3Lw =>
                    Reg(bv2natural(rd)) := Mem(to_integer(signed(imm12)));
                    PC := natural2bv((to_integer(unsigned(PC)) + 4) mod (2**AddrSize), AddrSize);
            end case;

        when OpStore =>
            case Instr(14 downto 12) is
                when Func3Sb =>  -- Store Byte
                    case (to_integer(unsigned(RF(to_integer(unsigned(Instr(19 downto 15))))))
                        + to_integer(signed(sign_extend(Instr(31 downto 25) & Instr(11 downto 7))))) mod 4 is

                        when 0 =>
                            Mem((to_integer(unsigned(RF(to_integer(unsigned(Instr(19 downto 15))))))
                                + to_integer(signed(sign_extend(Instr(31 downto 25) & Instr(11 downto 7))))) / 4)(7 downto 0)
                                := RF(to_integer(unsigned(Instr(24 downto 20))))(7 downto 0);

                        when 1 =>
                            Mem((to_integer(unsigned(RF(to_integer(unsigned(Instr(19 downto 15))))))
                                + to_integer(signed(sign_extend(Instr(31 downto 25) & Instr(11 downto 7))))) / 4)(15 downto 8)
                                := RF(to_integer(unsigned(Instr(24 downto 20))))(7 downto 0);

                        when 2 =>
                            Mem((to_integer(unsigned(RF(to_integer(unsigned(Instr(19 downto 15))))))
                                + to_integer(signed(sign_extend(Instr(31 downto 25) & Instr(11 downto 7))))) / 4)(23 downto 16)
                                := RF(to_integer(unsigned(Instr(24 downto 20))))(7 downto 0);

                        when others =>
                            Mem((to_integer(unsigned(RF(to_integer(unsigned(Instr(19 downto 15))))))
                                + to_integer(signed(sign_extend(Instr(31 downto 25) & Instr(11 downto 7))))) / 4)(31 downto 24)
                                := RF(to_integer(unsigned(Instr(24 downto 20))))(7 downto 0);
                    end case;

                when Func3Sh =>  -- Store Half-word
                    if (to_integer(unsigned(RF(to_integer(unsigned(Instr(19 downto 15))))))
                        + to_integer(signed(sign_extend(Instr(31 downto 25) & Instr(11 downto 7))))) mod 4 = 0 then

                        Mem((to_integer(unsigned(RF(to_integer(unsigned(Instr(19 downto 15))))))
                            + to_integer(signed(sign_extend(Instr(31 downto 25) & Instr(11 downto 7))))) / 4)(15 downto 0)
                            := RF(to_integer(unsigned(Instr(24 downto 20))))(15 downto 0);

                    elsif (to_integer(unsigned(RF(to_integer(unsigned(Instr(19 downto 15))))))
                        + to_integer(signed(sign_extend(Instr(31 downto 25) & Instr(11 downto 7))))) mod 4 = 2 then

                        Mem((to_integer(unsigned(RF(to_integer(unsigned(Instr(19 downto 15))))))
                            + to_integer(signed(sign_extend(Instr(31 downto 25) & Instr(11 downto 7))))) / 4)(31 downto 16)
                            := RF(to_integer(unsigned(Instr(24 downto 20))))(15 downto 0);
                    end if;

                when Func3Sw =>  -- Store Word
                    Mem((to_integer(unsigned(RF(to_integer(unsigned(Instr(19 downto 15))))))
                        + to_integer(signed(sign_extend(Instr(31 downto 25) & Instr(11 downto 7))))) / 4)
                        := RF(to_integer(unsigned(Instr(24 downto 20))));
            end case;


        when OpBranch =>
            case func3 is
                when Func3BEQ =>
                    if Reg(bv2natural(rs1)) = Reg(bv2natural(rs2)) then
                        branch_temp := bImm & '0';                        
                        PC := natural2bv((to_integer(unsigned(PC)) + to_integer(signed(branch_temp))) mod (2**AddrSize),AddrSize);
                    else
                        PC := natural2bv((to_integer(unsigned(PC)) + 4) mod (2**AddrSize), AddrSize);
                    end if;
                when Func3BNE =>
                    if Reg(bv2natural(rs1)) /= Reg(bv2natural(rs2)) then
                        branch_temp := bImm & '0';                        
                        PC := natural2bv((to_integer(unsigned(PC)) + to_integer(signed(branch_temp))) mod (2**AddrSize),AddrSize);
                    else
                        PC := natural2bv((to_integer(unsigned(PC)) + 4) mod (2**AddrSize), AddrSize);
                    end if;
                when Func3BLT =>
                    if signed(Reg(bv2natural(rs1))) < signed(Reg(bv2natural(rs2))) then
                        branch_temp := bImm & '0';                        
                        PC := natural2bv((to_integer(unsigned(PC)) + to_integer(signed(branch_temp))) mod (2**AddrSize),AddrSize);
                    else
                        PC := natural2bv((to_integer(unsigned(PC)) + 4) mod (2**AddrSize), AddrSize);
                    end if;
                when Func3BLTU =>
                    if unsigned(Reg(bv2natural(rs1))) < unsigned(Reg(bv2natural(rs2))) then
                        branch_temp := bImm & '0';                        
                        PC := natural2bv((to_integer(unsigned(PC)) + to_integer(signed(branch_temp))) mod (2**AddrSize),AddrSize);
                    else
                        PC := natural2bv((to_integer(unsigned(PC)) + 4) mod (2**AddrSize), AddrSize);
                    end if;
                                when Func3BGE =>
                    if signed(Reg(bv2natural(rs1))) > signed(Reg(bv2natural(rs2))) then
                        branch_temp := bImm & '0';                        
                        PC := natural2bv((to_integer(unsigned(PC)) + to_integer(signed(branch_temp))) mod (2**AddrSize),AddrSize);
                    else
                        PC := natural2bv((to_integer(unsigned(PC)) + 4) mod (2**AddrSize), AddrSize);
                    end if;
                when Func3BGEU =>
                    if unsigned(Reg(bv2natural(rs1))) > unsigned(Reg(bv2natural(rs2))) then
                        branch_temp := bImm & '0';                        
                        PC := natural2bv((to_integer(unsigned(PC)) + to_integer(signed(branch_temp))) mod (2**AddrSize),AddrSize);
                    else
                        PC := natural2bv((to_integer(unsigned(PC)) + 4) mod (2**AddrSize), AddrSize);
                    end if;
            end case;
        when OpJump =>
            Reg(bv2natural(rd)) := natural2bv((to_integer(unsigned(PC)) + 4) mod (2**AddrSize), AddrSize); 
            PC := natural2bv((to_integer(unsigned(PC)) + to_integer(signed(jimm20))) mod (2**AddrSize),AddrSize);   
        when OpJumpReg =>
            Reg(bv2natural(rd)) := natural2bv((to_integer(unsigned(PC)) + 4) mod (2**AddrSize), AddrSize);
            PC := natural2bv((to_integer(unsigned(Reg(bv2natural(rs1)))) + to_integer(signed(imm12))) mod (2**AddrSize),AddrSize);
            PC(0) := '0';
        end case;
    end process;
end Functional;