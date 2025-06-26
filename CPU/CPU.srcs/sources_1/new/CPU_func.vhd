
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_bit.ALL;
use work.defs_pack.all;
use work.conversion_pack.all;
use work.mem_pack.all;
use work.trace_pack.all;

entity RISCV is
end RISCV;

architecture Functional of RISCV is
begin
    process
        -- for tracing
        use std.textio.all;
        file TraceFile : Text is out "Trace";
        variable l : line;
        -- cpu objects
        variable PC           : AddrType    := X"0000";
        variable Instr        : InstrType   := (others=>'0');
        variable OP           : OpType      := (others=>'0');
        variable func3        : Func3Type   := (others=>'0');
        variable func7        : Func7Type   := (others=>'0');
        variable rs1, rs2, rd : RegAddrType := (others=>'0');
        variable int_rs1, int_rs2, int_rd
                              : natural     := 0;
        variable imm12        : Imm12Type   := (others=>'0');
        variable imm20        : Imm20Type   := (others=>'0');
        variable aImm         : bit_vector(15 downto 0);
--        variable jimm20       : Imm20Type   := (others=>'0');
        variable bImm         : Imm12Type   := (others=>'0');
        variable sImm         : Imm12Type   := (others=>'0');
        variable Reg          : RegType     := (others=>(others=>'0'));
        variable Mem          : MemType     := (others=>(others=>'0'));

        variable store_address: natural     := 0;
        variable load_address : AddrType    := (others=>'0');
        
    begin
        init_memory("D:\program.mem", Mem);
        print_header( TraceFile );
        loop
        --cmd fetch
        Instr  := Mem(TO_INTEGER(PC));
        OP     := Instr(6 downto 0);
        func3  := Instr(14 downto 12);
        func7  := Instr(31 downto 25);
        rs1    := Instr(19 downto 15);
        rs2    := Instr(24 downto 20); -- also immediately used for shifts as shamt
        rd     := Instr(11 downto 7);
        imm12  := Instr(31 downto 20);
        imm20  := Instr(31 downto 12);
        
        aImm   := imm20(3 downto 0) & X"000"; -- imm for AUIPC
        bImm   := Instr(31) & Instr(7) & Instr(30 downto 25) & Instr(11 downto  8);
                                                                 -- imm for branch
        sImm   := Instr(31 downto 25) & Instr(11 downto 7); -- imm for store
--        jimm20 := Instr(31) & Instr(19 downto 12) & Instr(20) & Instr(30 downto 21);
                                                                          -- imm for jump

        -- Reg is indexed with integers
        int_rs1 := TO_INTEGER(unsigned(rs1));
        int_rs2 := TO_INTEGER(unsigned(rs2));
        int_rd  := TO_INTEGER(unsigned(rd));

        write_pc_cmd(l , PC , OP , func3 , func7 , rd , rs1 , rs2);
        
        case OP is
            when OpEBREAK =>
                print_tail( TraceFile );
                wait;
            
            when OpLoad   =>
                load_address := TO_UNSIGNED( TO_INTEGER(unsigned(Reg(int_rs1)(15 downto 0))) 
                                           + TO_INTEGER(signed(imm12)), AddrSize );
                case func3 is
                    when Func3LB  => -- LB
                        Reg(int_rd) := sign_extend(loadMem8( Mem, load_address ));
                        write_param(l,imm12);
                        write_no_param1(l);
                    when Func3LH  => -- LH
                        Reg(int_rd) := sign_extend(loadMem16( Mem, load_address ));
                        write_param(l,imm12);
                        write_no_param1(l);
                    when Func3LW  => -- LW
                        Reg(int_rd) :=             loadMem32( Mem, load_address );
                        write_param(l,imm12);
                        write_no_param1(l);
                    when Func3LBU => -- LBU
                        Reg(int_rd) := zero_extend(loadMem8( Mem, load_address ));
                        write_param(l,imm12);
                        write_no_param1(l);
                    when Func3LHU => -- LHU
                        Reg(int_rd) := zero_extend(loadMem16( Mem, load_address ));
                        write_param(l,imm12);
                        write_no_param1(l);
                    when others   =>
                        assert FALSE report "Illegal instruction" severity error;
                        write_no_param2(l);
                end case;
                    
            when OpStore  =>
                store_address := TO_INTEGER( unsigned(Reg(int_rs1)(15 downto 0))) 
                               + TO_INTEGER( signed(sign_extend(sImm)));
                case func3 is
                    when Func3SB => -- SB
                        case store_address mod 4 is -- check the last 2 bits of address
                            when 0 => -- Lower byte
                                Mem(store_address)(7 downto 0)   := Reg(int_rs2)(7 downto 0);
                                write_param(l,func7);
                                write_param(l,rd);
                            when 1 => -- Lower middle byte
                                Mem(store_address)(15 downto 8)  := Reg(int_rs2)(7 downto 0);
                                write_param(l,func7);
                                write_param(l,rd);
                            when 2 => -- Upper middle byte 
                                Mem(store_address)(23 downto 16) := Reg(int_rs2)(7 downto 0);
                                write_param(l,func7);
                                write_param(l,rd);
                            when 3 => -- Upper byte
                                Mem(store_address)(31 downto 24) := Reg(int_rs2)(7 downto 0);
                                write_param(l,func7);
                                write_param(l,rd);
                            when others =>
                                assert FALSE report "Unaligned address for SB" severity error;
                                write_no_param2(l);
                        end case;
                    when Func3SH => -- SH
                        case store_address mod 4 is -- check the last 2 bits of address
                            when 0 => -- Lower half-word
                                Mem(store_address)(15 downto 0)  := Reg(int_rs2)(15 downto 0);
                                write_param(l,func7);
                                write_param(l,rd);
                            when 2 => -- Upper half-word
                                Mem(store_address)(31 downto 16) := Reg(int_rs2)(15 downto 0);
                                write_param(l,func7);
                                write_param(l,rd);
                            when others =>
                                assert FALSE report "Unaligned address for SH" severity error;
                                write_no_param2(l);
                        end case;
                    when Func3SW => -- SW
                        case store_address mod 4 is -- check the last 2 bits of address
                            when 0 =>
                                Mem(store_address) := Reg(int_rs2);
                                write_param(l,func7);
                                write_param(l,rd);
                            when others =>
                                assert FALSE report "Unaligned address for SW" severity error;
                                write_no_param2(l);
                        end case;
                    when others  =>
                        assert FALSE report "Illegal instruction" severity error;
                        write_no_param2(l);
                end case;



        when OpImm =>
            case func3 is
                when Func3SLL =>
                    case func7 is
                        when Func7ShLog =>
                            Reg(int_rd) := Reg(int_rs1) sll int_rs2;
                            write_param(l,rs2);
                            write_no_param1(l);
                        when others =>
                           assert FALSE report "Illegal instruction" severity error;
                           write_no_param2(l);
                    end case;
                when Func3SRL_SRA =>
                    case func7 is
                        when Func7ShLog =>
                            Reg(int_rd) := Reg(int_rs1) srl int_rs2;
                            write_param(l,rs2);
                            write_no_param1(l);
                        when Func7ShArthm =>
                            Reg(int_rd) := Reg(int_rs1) sra int_rs2;
                            write_param(l,rs2);
                            write_no_param1(l);
                        when others =>
                            assert FALSE report "Illegal instruction" severity error;
                            write_no_param2(l);
                    end case;
                when Func3SLT => --SLTI
                    if signed(Reg(int_rs1)) < signed(sign_extend(imm12)) then
                        Reg(int_rd) := X"00000001";
                    else
                        Reg(int_rd) := X"00000000";
                    end if;
                    write_param(l,rs2);
                    write_no_param1(l);
                when Func3SLTU => --SLTIU
                    if unsigned(Reg(int_rs1)) < unsigned(sign_extend(imm12)) then
                        Reg(int_rd) := X"00000001";
                    else
                        Reg(int_rd) := X"00000000";
                    end if;
                    write_param(l,rs2);
                    write_no_param1(l);
                when Func3Arthm     =>
                    Reg(int_rd) := bit_vector( signed(Reg(int_rs1)) + signed(sign_extend(imm12)) ); -- ADDI
                    write_param(l,imm12);
                    write_no_param1(l);
                when Func3XOR       =>
                    Reg(int_rd) := Reg(int_rs1) xor sign_extend(imm12); -- XORI
                    write_param(l,imm12);
                    write_no_param1(l);
                when Func3OR        =>
                    Reg(int_rd) := Reg(int_rs1) or sign_extend(imm12); -- ORI
                    write_param(l,imm12);
                    write_no_param1(l);
                when Func3AND       =>
                    Reg(int_rd) := Reg(int_rs1) and sign_extend(imm12); -- ANDI
                    write_param(l,imm12);
                    write_no_param1(l);
                when others =>
                    assert FALSE report "Illegal instruction" severity error;
                    write_no_param2(l);
            end case;
                    
        when OpReg =>
            case func3 is
                when Func3SLL =>
                    case func7 is
                        when Func7ShLog =>
                            Reg(int_rd) := Reg(int_rs1) sll bv2int(Reg(int_rs2));
                        when others =>
                            assert FALSE report "Illegal instruction" severity error;
                            write_no_param2(l);
                    end case;
                when Func3SRL_SRA =>
                    case func7 is
                        when Func7ShLog =>
                            Reg(int_rd) := Reg(int_rs1) srl bv2int(Reg(int_rs2));
                        when Func7ShArthm =>
                            Reg(int_rd) := Reg(int_rs1) sra bv2int(Reg(int_rs2));
                        when others =>
                            assert FALSE report "Illegal instruction" severity error;
                            write_no_param2(l);
                    end case;
                when Func3SLT => --SLT
                    case func7 is
                        when Func7Set =>
                            if signed(Reg(int_rs1)) < signed(Reg(int_rs2)) then
                                Reg(int_rd) := X"00000001";
                            else
                                Reg(int_rd) := X"00000000";
                            end if;
                        when others =>
                                assert FALSE report "Illegal instruction" severity error;
                                write_no_param2(l);
                    end case;
                when Func3SLTU => --SLTU
                    case func7 is
                        when Func7Set =>
                            if unsigned(Reg(int_rs1)) < unsigned(Reg(int_rs2)) then
                                Reg(int_rd) := X"00000001";
                            else
                                Reg(int_rd) := X"00000000";
                            end if;
                        when others =>
                            assert FALSE report "Illegal instruction" severity error;
                            write_no_param2(l);
                    end case;
                when Func3Arthm => 
                    case func7 is
                        when Func7ADD =>
                            Reg(int_rd) := bit_vector( signed(Reg(int_rs1)) + signed(Reg(int_rs2)) ); -- ADD
                        when Func7SUB =>
                            Reg(int_rd) := bit_vector( signed(Reg(int_rs1)) - signed(Reg(int_rs2)) ); -- SUB
                        when others   =>
                            assert FALSE report "Illegal instruction" severity error;
                            write_no_param2(l);
                    end case;
                when Func3XOR  => 
                    case func7 is
                        when Func7Log =>
                            Reg(int_rd) := Reg(int_rs1) xor Reg(int_rs2); -- XOR
                        when others   =>
                            assert FALSE report "Illegal instruction" severity error;
                            write_no_param2(l);
                    end case;
                when Func3OR   => 
                    case func7 is
                        when Func7Log =>
                            Reg(int_rd) := Reg(int_rs1) or Reg(int_rs2); -- OR
                        when others   =>
                            assert FALSE report "Illegal instruction" severity error;
                            write_no_param2(l);
                    end case;
                when Func3AND  => 
                    case func7 is
                        when Func7Log =>
                            Reg(int_rd) := Reg(int_rs1) and Reg(int_rs2); -- AND
                        when others   =>
                            assert FALSE report "Illegal instruction" severity error;
                            write_no_param2(l);
                    end case;
                when others =>
                    assert FALSE report "Illegal instruction" severity error;
                    write_no_param2(l);
            end case;                           
                    
        when OpLUI    =>  -- LUI        
                 Reg(int_rd) := imm20 & X"000";
                 write_param(l,imm20);
                 write_no_param1(l);
        when OpAUIPC  =>  -- AUIPC, R[rd] := PC + imm20 & X"000"
                 Reg(int_rd) := bit_vector( PC + unsigned(aImm) );
                 write_param(l,aImm); -- do we need to see all 20 bits?
                 write_no_param1(l);

        when OpBranch =>
            case func3 is
                when Func3BEQ =>
                    if Reg(int_rs1) = Reg(int_rs2) then                       
                        PC := TO_UNSIGNED( TO_INTEGER(PC) + TO_INTEGER(signed(bImm & '0')), AddrSize);
                    else
                        PC := PC + 4;
                    end if;
                    write_param(l,func7);
                    write_param(l,rd);
                when Func3BNE =>
                    if Reg(int_rs1) /= Reg(int_rs2) then
                        PC := TO_UNSIGNED( TO_INTEGER(PC) + TO_INTEGER(signed(bImm & '0')), AddrSize);
                    else
                        PC := PC + 4;
                    end if;
                    write_param(l,func7);
                    write_param(l,rd);
                when Func3BLT =>
                    if signed(Reg(int_rs1)) < signed(Reg(int_rs2)) then
                        PC := TO_UNSIGNED( TO_INTEGER(PC) + TO_INTEGER(signed(bImm & '0')), AddrSize);
                    else
                        PC := PC + 4;
                    end if;
                    write_param(l,func7);
                    write_param(l,rd);
                when Func3BLTU =>
                    if unsigned(Reg(int_rs1)) < unsigned(Reg(int_rs2)) then
                        PC := TO_UNSIGNED( TO_INTEGER(PC) + TO_INTEGER(signed(bImm & '0')), AddrSize);
                    else
                        PC := PC + 4;
                    end if;
                    write_param(l,func7);
                    write_param(l,rd);
                when Func3BGE =>
                    if signed(Reg(int_rs1)) >= signed(Reg(int_rs2)) then
                        PC := TO_UNSIGNED( TO_INTEGER(PC) + TO_INTEGER(signed(bImm & '0')), AddrSize);
                    else
                        PC := PC + 4;
                    end if;
                    write_param(l,func7);
                    write_param(l,rd);
                when Func3BGEU =>
                    if unsigned(Reg(int_rs1)) >= unsigned(Reg(int_rs2)) then
                        PC := TO_UNSIGNED( TO_INTEGER(PC) + TO_INTEGER(signed(bImm & '0')), AddrSize);
                    else
                        PC := PC + 4;
                    end if;
                    write_param(l,func7);
                    write_param(l,rd);
                when others   =>
                    assert FALSE report "Illegal instruction" severity error;
                    write_no_param2(l);
            end case;
        when OpJump =>
            Reg(int_rd) := bit_vector(PC + 4); 
            PC := TO_UNSIGNED( TO_INTEGER(PC) + TO_INTEGER(signed(imm20(15 downto 1)&'0')), AddrSize );  
            write_param(l,imm20);
            write_no_param1(l);
        when OpJumpReg =>
            Reg(int_rd) := bit_vector(unsigned(PC) + 4);
            PC := TO_UNSIGNED( TO_INTEGER(unsigned(Reg(int_rs1)(15 downto 0))) + TO_INTEGER(signed(imm20(15 downto 0))), AddrSize );
            PC(0) := '0';
            write_param(l,imm20);
            write_no_param1(l);
        when others   =>
            assert FALSE report "Illegal instruction" severity error;
            write_no_param2(l);
        end case;
        end loop;
    end process;
end Functional;
