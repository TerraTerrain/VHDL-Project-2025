library IEEE; 
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_bit.all;
use std.textio.all;
use work.defs_pack.all;
use work.conversion_pack.all;

package trace_pack is 
    --procedures for tracing
    procedure print_header(variable f : out text);--done
    procedure print_tail(variable f : out text);--done
    procedure write_pc_cmd(variable l : inout line;
                            constant PC : in AddrType;
                            constant OP : in OpType;
                            constant func3 : in Func3Type;
                            constant func7 : in Func7Type;
                            constant rd,rs1,rs2 : in RegAddrType);--X:rd;Y:rs1;Z:rs2
                            
    procedure write_param(variable l : inout line;
                            constant param : in RegAddrType);
                            
    procedure write_no_param1(variable l : inout line);
                            
    procedure write_no_param2(variable l : inout line);
    procedure write_regs(variable l : inout line;
                            constant reg : in regtype);--stored value in registers
    
    --conversion functions for tracing
    function hex_image(d : natural) return string; 
    function bool_character(b : boolean) return character;
    function cmd_image(op : optype; func3 : Func3Type; func7 : Func7Type) return string; --op = cmd
    
end trace_pack;

package body trace_pack is
    
    --conversion functions
    --from bv to string
    function hex_image(d : natural) return string is
        constant hex_table : string(1 to 16) := "0123456789ABCDEF";
        variable result : string(1 to 3);
    begin
        result(3) := hex_table(d mod 16 + 1);
        result(2) := hex_table((d mod 16) mod 16 + 1);
        result(1) := hex_table(d mod 256 + 1);
        return result;
    end;
    
    function bool_character(b : boolean) return character is
    begin
        if b then return 'T';
            else return 'F';
        end if;
    end;
    
    function cmd_image(op : optype; func3 : Func3Type; func7 : Func7Type ) return string is
    begin
        --case op is 
            --when code_nop => return mnemonic_nop;
            --when code_stop => return mnemonic_stop;
            --other ops
            --when others => 
               --assert FALSE report "Illegal command in cmc_image"
                    --severity warning;
                --return "";
        --end case;
        
        case OP is
        when OpLoad   =>
            case func3 is
                    when Func3LB  => -- LB
                        --Reg(bv2natural(rd)) := sign_extend(Mem8( Mem, natural2bv( regAddImm(Reg,rs1,imm12), AddrSize)));
                        return "LB   ";
                    when Func3LH  => -- LH
                        --Reg(bv2natural(rd)) := sign_extend(Mem16( Mem, natural2bv( regAddImm(Reg,rs1,imm12), AddrSize)));
                        return "LH   ";
                    when Func3LW  => -- LW
                        --Reg(bv2natural(rd)) := Mem32( Mem, natural2bv( regAddImm(Reg,rs1,imm12), AddrSize));
                        return "LW   ";
                    when Func3LBU => -- LBU
                        --Reg(bv2natural(rd)) := zero_extend(Mem8( Mem, natural2bv( regAddImm(Reg,rs1,imm12), AddrSize)));
                        return "LBU  ";
                    when Func3LHU => -- LHU
                        --Reg(bv2natural(rd)) := zero_extend(Mem16( Mem, natural2bv( regAddImm(Reg,rs1,imm12), AddrSize)));
                        return "LHU  ";
                    when others   =>
                        assert FALSE report "Illegal instruction" severity error;
                        return "-----";
                end case;
        when OpStore  => 
                
                case func3 is
                    when Func3SB => -- SB
                        --case regAddImm(Reg,rs1,sImm) mod 4 is -- check the last 2 bits of address
                            --when 0 => -- Lower half-word (aligned)
                                --Mem( regAddImm(Reg,rs1,sImm) )(7 downto 0) := Reg(bv2natural(rs2))(7 downto 0);
                                --return "SB   ";
                            --when 1 => -- Upper half-word
                                --Mem( regAddImm(Reg,rs1,sImm) )(15 downto 8) := Reg(bv2natural(rs2))(7 downto 0);
                                --return "SB   ";
                            --when 2 => -- Lower half-word (aligned)
                                --Mem( regAddImm(Reg,rs1,sImm) )(23 downto 16) := Reg(bv2natural(rs2))(7 downto 0);
                                --return "SB   ";
                            --when 3 => -- Upper half-word
                                --Mem( regAddImm(Reg,rs1,sImm) )(31 downto 24) := Reg(bv2natural(rs2))(7 downto 0);
                                return "SB   ";
                            --when others =>
                                --assert FALSE report "Unaligned address for SB" severity error;
                        ---end case;
                    when Func3SH => -- SH
                        --case regAddImm(Reg,rs1,sImm) mod 4 is -- check the last 2 bits of address
                            --when 0 => -- Lower half-word (aligned)
                                --Mem( regAddImm(Reg,rs1,sImm) )(15 downto 0) := Reg(bv2natural(rs2))(15 downto 0);
                                --return "SH   ";
                            --when 2 => -- Upper half-word
                                --Mem( regAddImm(Reg,rs1,sImm) )(31 downto 16) := Reg(bv2natural(rs2))(15 downto 0);
                                return "SH   ";
                            --when others =>
                                --assert FALSE report "Unaligned address for SH" severity error;
                        --end case;
                    when Func3SW => -- SW
                        --case regAddImm(Reg,rs1,sImm) mod 4 is -- check the last 2 bits of address
                            --when 0 =>
                                --Mem( regAddImm(Reg,rs1,sImm) ) := Reg(bv2natural(rs2));
                                return "SW   ";
                            --when others =>
                                --assert FALSE report "Unaligned address for SW" severity error;
                        --end case;
                    when others  =>
                        assert FALSE report "Illegal instruction" severity error;
                        return "-----";
                end case;



        when OpImm =>
            case func3 is
                when Func3SLL =>
                    case func7 is
                        when Func7ShLog =>
                            --Reg(bv2natural(rd)) := Reg(bv2natural(rs1)) sll bv2natural(rs2);
                            return "SLLI ";
                        when others =>
                           assert FALSE report "Illegal instruction" severity error;
                    end case;
                when Func3SRLorSRA =>
                    case func7 is
                        when Func7ShLog =>
                            --Reg(bv2natural(rd)) := Reg(bv2natural(rs1)) srl bv2natural(rs2);
                            return "SRLI ";                           
                        when Func7ShArith =>
                            --Reg(bv2natural(rd)) := Reg(bv2natural(rs1)) sra bv2natural(rs2);
                            return "SRAI ";
                        when others =>
                            assert FALSE report "Illegal instruction" severity error;
                            return "-----";
                    end case;
                when Func3SLT => --SLTI
                    --if signed(Reg(bv2natural(rs1))) < signed(sign_extend(imm12)) then
                        --Reg(bv2natural(rd)) := "1";
                    --else Reg(bv2natural(rd)) := "0";
                    --end if;
                    return "SLTI ";
                when Func3SLTU => --SLTIU
                    --if unsigned(Reg(bv2natural(rs1))) < unsigned(sign_extend(imm12)) then
                        --Reg(bv2natural(rd)) := "1";
                    --else Reg(bv2natural(rd)) := "0";
                    --end if;
                    return "SLTIU";
                when Func3Arthm     =>
                    --Reg(int_rd) := bit_vector( signed(Reg(int_rs1)) + signed(sign_extend(imm12)) ); -- ADDI
                    return "ADDI ";
                when Func3XOR       =>
                    --Reg(int_rd) := Reg(int_rs1) xor sign_extend(imm12); -- XORI
                    return "XORI ";
                when Func3OR        =>
                    --Reg(int_rd) := Reg(int_rs1) or sign_extend(imm12); -- ORI
                    return "ORI  ";
                when Func3AND       =>
                    --Reg(int_rd) := Reg(int_rs1) and sign_extend(imm12); -- ANDI
                    return "ANDI ";
                when others =>
                    assert FALSE report "Illegal instruction" severity error;
                    return "-----";
            end case;
                    
                    
        when OpReg =>
            case func3 is
                when Func3SLL =>
                    case func7 is
                        when Func7ShLog =>
                            --Reg(bv2natural(rd)) := Reg(bv2natural(rs1)) sll bv2natural(Reg(bv2natural(rs2)));
                            return "SLL  ";
                        when others =>
                           assert FALSE report "Illegal instruction" severity error;
                           return "-----";
                    end case;
                when Func3SRLorSRA =>
                    case func7 is
                        when Func7ShLog =>
                            --Reg(bv2natural(rd)) := Reg(bv2natural(rs1)) srl bv2natural(Reg(bv2natural(rs2)));
                            return "SRL  ";
                        when Func7ShArith =>
                            --Reg(bv2natural(rd)) := Reg(bv2natural(rs1)) sra bv2natural(Reg(bv2natural(rs2)));
                            return "SRA  ";
                        when others =>
                            assert FALSE report "Illegal instruction" severity error;
                            return "-----";
                    end case;
                when Func3SLT => --SLT
                    case func7 is
                        when Func7Shift =>
                            --if signed(Reg(bv2natural(rs1))) < signed(Reg(bv2natural(rs2))) then
                                --Reg(bv2natural(rd)) := "1";
                            --else Reg(bv2natural(rd)) := "0";
                            --end if;
                            return "SLT  ";
                    end case;
                when Func3SLTU => --SLTU
                    case func7 is
                        when Func7Shift =>
                            --if unsigned(Reg(bv2natural(rs1))) < unsigned(Reg(bv2natural(rs2))) then
                              --  Reg(bv2natural(rd)) := "1";
                            --else Reg(bv2natural(rd)) := "0";
           
                            --end if;
                            return "SLTU ";
                        when others =>
                            assert FALSE report "Illegal instruction" severity error;
                            return "-----";
                    end case;
                when Func3Arthm => 
                    case func7 is
                        when Func7ADD =>
                            --Reg(int_rd) := bit_vector( signed(Reg(int_rs1)) + signed(Reg(int_rs2)) ); -- ADD
                            return "ADD  ";
                        when Func7SUB =>
                            --Reg(int_rd) := bit_vector( signed(Reg(int_rs1)) - signed(Reg(int_rs2)) ); -- SUB
                            return "SUB  ";
                        when others   =>
                            assert FALSE report "Illegal instruction" severity error;
                    end case;
                when Func3XOR  => 
                    case func7 is
                        when Func7Log =>
                            --Reg(int_rd) := Reg(int_rs1) xor Reg(int_rs2); -- XOR
                            return "XOR  ";
                        when others   =>
                            assert FALSE report "Illegal instruction" severity error;
                    end case;
                when Func3OR   => 
                    case func7 is
                        when Func7Log =>
                            --Reg(int_rd) := Reg(int_rs1) or Reg(int_rs2); -- OR
                            return "OR   ";
                        when others   =>
                            assert FALSE report "Illegal instruction" severity error;
                    end case;
                when Func3AND  => 
                    case func7 is
                        when Func7Log =>
                            --Reg(int_rd) := Reg(int_rs1) and Reg(int_rs2); -- AND
                            return "AND  ";
                        when others   =>
                            assert FALSE report "Illegal instruction" severity error;
                    end case;
            end case;
                           
                    
        when OpLUI    =>  -- LUI        
                 --Reg(int_rd) := imm20 & X"000";
                 return "LUI  ";
        when OpAUIPC  =>  -- AUIPC
                 -- Reg(int_rd) := (others => '0'); PROBLEM: [16 bit PC] + [32 bit imm20&X"000"]
                 return "AUIPC";
        when OpBranch =>
            case func3 is
                when Func3BEQ =>
                    --if Reg(bv2natural(rs1)) = Reg(bv2natural(rs2)) then
                      --  branch_temp := bImm & '0';                        
                        --PC := natural2bv((to_integer(unsigned(PC)) + to_integer(signed(branch_temp))) mod (2**AddrSize),AddrSize);
                    --else
                      --  PC := natural2bv((to_integer(unsigned(PC)) + 4) mod (2**AddrSize), AddrSize);
                    --end if;
                    return "BEQ  ";
                when Func3BNE =>
                    --if Reg(bv2natural(rs1)) /= Reg(bv2natural(rs2)) then
                      --  branch_temp := bImm & '0';                        
                        --PC := natural2bv((to_integer(unsigned(PC)) + to_integer(signed(branch_temp))) mod (2**AddrSize),AddrSize);
                    --else
                      --  PC := natural2bv((to_integer(unsigned(PC)) + 4) mod (2**AddrSize), AddrSize);
                    --end if;
                    return "BNE  ";
                when Func3BLT =>
                    --if signed(Reg(bv2natural(rs1))) < signed(Reg(bv2natural(rs2))) then
                      --  branch_temp := bImm & '0';                        
                        --PC := natural2bv((to_integer(unsigned(PC)) + to_integer(signed(branch_temp))) mod (2**AddrSize),AddrSize);
                    --else
                      --  PC := natural2bv((to_integer(unsigned(PC)) + 4) mod (2**AddrSize), AddrSize);
                    --end if;
                    return "BLT  ";
                when Func3BLTU =>
                    --if unsigned(Reg(bv2natural(rs1))) < unsigned(Reg(bv2natural(rs2))) then
                      --  branch_temp := bImm & '0';                        
                        --PC := natural2bv((to_integer(unsigned(PC)) + to_integer(signed(branch_temp))) mod (2**AddrSize),AddrSize);
                    --else
                      --  PC := natural2bv((to_integer(unsigned(PC)) + 4) mod (2**AddrSize), AddrSize);
                    --end if;
                    return "BLTU ";
                when Func3BGE =>
                    --if signed(Reg(bv2natural(rs1))) > signed(Reg(bv2natural(rs2))) then
                      --  branch_temp := bImm & '0';                        
                        --PC := natural2bv((to_integer(unsigned(PC)) + to_integer(signed(branch_temp))) mod (2**AddrSize),AddrSize);
                    --else
                      --  PC := natural2bv((to_integer(unsigned(PC)) + 4) mod (2**AddrSize), AddrSize);
                    --end if;
                    return "BGE  ";
                when Func3BGEU =>
                    --if unsigned(Reg(bv2natural(rs1))) > unsigned(Reg(bv2natural(rs2))) then
                      --  branch_temp := bImm & '0';                        
                        --PC := natural2bv((to_integer(unsigned(PC)) + to_integer(signed(branch_temp))) mod (2**AddrSize),AddrSize);
                    --else
                      --  PC := natural2bv((to_integer(unsigned(PC)) + 4) mod (2**AddrSize), AddrSize);
                    --end if;
                    return "BGEU ";
            end case;
        when OpJump =>
            --Reg(bv2natural(rd)) := natural2bv((to_integer(unsigned(PC)) + 4) mod (2**AddrSize), AddrSize); 
            --PC := natural2bv((to_integer(unsigned(PC)) + to_integer(signed(jimm20))) mod (2**AddrSize),AddrSize);
            return "JAL  ";
        when OpJumpReg =>
            --Reg(bv2natural(rd)) := natural2bv((to_integer(unsigned(PC)) + 4) mod (2**AddrSize), AddrSize);
            --PC := natural2bv((to_integer(unsigned(Reg(bv2natural(rs1)))) + to_integer(signed(imm12))) mod (2**AddrSize),AddrSize);
            --PC(0) := '0';
            return "JALR ";
        end case;
    end;
    
    --procedure print_header
    procedure print_header(variable f : out text) is
        variable l : line;
    begin
        write(l,string'("PC "),left,3);
        write(l,string'("|"));
        write(l,string'("CMD"),left,5);
        write(l,string'("|"));
        write(l,string'("rd"),left,3);
        write(l,string'("|"));
        write(l,string'("rs1"),left,3);
        write(l,string'("|"));
        write(l,string'("rs2"),left,3);
        write(l,string'("|"));
        write(l,string'("P1"),left,3);--first imm.part for branches and stores or imm.part for shift
        write(l,string'("|"));
        write(l,string'("P2"),left,3);--second imm.part for branches and stores
        write(l,string'("|"));
        write(l,string'("R0"),left,3);
        write(l,string'("|"));
        write(l,string'("R1"),left,3);
        write(l,string'("|"));
        write(l,string'("R2"),left,3);
        write(l,string'("|"));
        write(l,string'("R3"),left,3);

        writeline(f,l);
    end;

    --procedure print_tail
    procedure print_tail(variable f : out text) is
        variable l : line;
    begin
        write(l,string'("-----------------------------------------"));
        writeline(f,l);
    end;
    
    --procedure write_pc_cmd
    procedure write_pc_cmd(variable l : inout line;
                            constant PC : in AddrType;
                            constant OP : in OpType;
                            constant func3 : in Func3Type;
                            constant func7 : in Func7Type;
                            constant rd,rs1,rs2 : in RegAddrType) is
    begin
        write(l, hex_image(bv2natural(PC)), left, 3);--PC
        write(l, string'("|"));
        write(l, cmd_image(op,func3, func7), left, 5);--CMD
        write(l, string'("|"));
        write(l, rd, left, 3);
        write(l, string'("|"));
        write(l, rs1, left, 3);
        write(l, string'("|"));
        write(l, rs2, left, 3);
        write(l, string'("|"));
    end;
    
    --procedure write_param
    procedure write_param(variable l : inout line;
                          constant param : in RegAddrType) is
    begin
        write(l, hex_image(bv2natural(param)), left, 3);
        write(l, string'("|"));
    end;
    
    
    procedure write_no_param1(variable l : inout line) is
    begin
        write(l, string'("---|"));
    end;
    --procedure write_no_param2
    procedure write_no_param2(variable l : inout line) is
    begin
        write(l, string'("---|---|"));
    end;
    
    --procedure write_regs
    procedure write_regs(variable l : inout line;
                         constant Reg : in RegType) is
    begin
        for i in 0 to 3 loop
            write(l, hex_image(bv2natural(Reg(i))), left, 3);
            write(l, string'("|"));
        end loop;
    end;
     
end trace_pack;
