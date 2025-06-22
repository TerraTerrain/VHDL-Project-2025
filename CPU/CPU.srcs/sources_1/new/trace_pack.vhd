library IEEE; 
use IEEE.STD_LOGIC_1164.ALL;
--use ieee.numeric_bit.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use work.defs_pack.all;
use work.conversion_pack.all;

package trace_pack is 
    --procedures for tracing
    procedure print_header(variable f : out text);
    procedure print_tail(variable f : out text);
    procedure write_pc_cmd(variable l : inout line;
                            constant PC : in AddrType;
                            constant OP : in OpType;
                            constant func3 : in Func3Type;
                            constant func7 : in Func7Type;
                            constant rd,rs1,rs2 : in RegAddrType);--X:rd;Y:rs1;Z:rs2
                            
    procedure write_param(variable l : inout line;
                            constant param : in bit_vector);
                            
    procedure write_no_param1(variable l : inout line);
                            
    procedure write_no_param2(variable l : inout line);
    procedure write_regs(variable l : inout line;
                            constant reg : in regtype);--stored value in registers
    
    --conversion functions for tracing
    function bv2int(input: bit_vector) return integer;
    function bv2hex(bv : bit_vector) return string; --from bit_vector to hex
    function bool_character(b : boolean) return character;
    function cmd_image(op : optype; func3 : Func3Type; func7 : Func7Type) return string; --op = cmd
    
end trace_pack;

package body trace_pack is
    
    --conversion functions
    function bv2int(input: bit_vector) return integer is
        variable result : integer := 0;
        variable bit_length : integer := input'length;
    begin
        for i in input'range loop
            if input(i) = '1' then
                result := result + (2 ** (bit_length - 1 - i));
            end if;
        end loop;
    return result;
    end function;
    --from bv to string
    function bv2hex(bv : bit_vector) return string is
        constant hex_table : string := "0123456789ABCDEF";
        variable length_hex : integer := (bv'length+3)/4; --calculate how many hex do we need
        variable result : string(1 to length_hex);
        variable bv_4 : bit_vector(length_hex * 4 - 1 downto 0);        
       
    begin
        bv_4 := (others => '0');
        bv_4(bv_4'length-1 downto 0) := bv;
        for i in 0 to length_hex -1 loop
            result(i+1) := hex_table(bv2int(bv_4(4*i+3 downto 4*i))+1);
        end loop;
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
       
        case OP is
        when OpLoad   =>
            case func3 is
                    when Func3LB  => -- LB
                        return "LB   ";
                    when Func3LH  => -- LH
                        return "LH   ";
                    when Func3LW  => -- LW
                        return "LW   ";
                    when Func3LBU => -- LBU
                        return "LBU  ";
                    when Func3LHU => -- LHU
                        return "LHU  ";
                    when others   =>
                        assert FALSE report "Illegal instruction" severity error;
                        return "-----";
                end case;
        when OpStore  => 
                
                case func3 is
                    when Func3SB => -- SB
                                return "SB   ";
                    when Func3SH => -- SH
                                return "SH   ";
                    when Func3SW => 
                                return "SW   ";
                    when others  =>
                        assert FALSE report "Illegal instruction" severity error;
                        return "-----";
                end case;



        when OpImm =>
            case func3 is
                when Func3SLL =>
                    case func7 is
                        when Func7ShLog =>
                            return "SLLI ";
                        when others =>
                           assert FALSE report "Illegal instruction" severity error;
                    end case;
                when Func3SRL_SRA =>
                    case func7 is
                        when Func7ShLog =>
                            return "SRLI ";                           
                        when Func7ShArthm =>
                            return "SRAI ";
                        when others =>
                            assert FALSE report "Illegal instruction" severity error;
                            return "-----";
                    end case;
                when Func3SLT => --SLTI
                    return "SLTI ";
                when Func3SLTU => --SLTIU
                    return "SLTIU";
                when Func3Arthm     => -- ADDI
                    return "ADDI ";
                when Func3XOR       => -- XORI
                    return "XORI ";
                when Func3OR        => -- ORI
                    return "ORI  ";
                when Func3AND       => -- ANDI
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
                            return "SLL  ";
                        when others =>
                           assert FALSE report "Illegal instruction" severity error;
                           return "-----";
                    end case;
                when Func3SRL_SRA =>
                    case func7 is
                        when Func7ShLog =>
                            return "SRL  ";
                        when Func7ShArthm =>
                            return "SRA  ";
                        when others =>
                            assert FALSE report "Illegal instruction" severity error;
                            return "-----";
                    end case;
                when Func3SLT => --SLT
                    case func7 is
                        when Func7Set =>
                            return "SLT  ";
                    end case;
                when Func3SLTU => --SLTU
                    case func7 is
                        when Func7Set =>
                            return "SLTU ";
                        when others =>
                            assert FALSE report "Illegal instruction" severity error;
                            return "-----";
                    end case;
                when Func3Arthm => 
                    case func7 is
                        when Func7ADD => -- ADD
                            return "ADD  ";
                        when Func7SUB =>-- SUB
                            return "SUB  ";
                        when others   =>
                            assert FALSE report "Illegal instruction" severity error;
                    end case;
                when Func3XOR  => 
                    case func7 is
                        when Func7Log => -- XOR
                            return "XOR  ";
                        when others   =>
                            assert FALSE report "Illegal instruction" severity error;
                    end case;
                when Func3OR   => 
                    case func7 is
                        when Func7Log =>-- OR
                            return "OR   ";
                        when others   =>
                            assert FALSE report "Illegal instruction" severity error;
                    end case;
                when Func3AND  => 
                    case func7 is
                        when Func7Log =>-- AND
                            return "AND  ";
                        when others   =>
                            assert FALSE report "Illegal instruction" severity error;
                    end case;
            end case;
                           
                    
        when OpLUI    =>  -- LUI 
                 return "LUI  ";
        when OpAUIPC  =>  -- AUIPC
                 return "AUIPC";
        when OpBranch =>
            case func3 is
                when Func3BEQ =>
                    return "BEQ  ";
                when Func3BNE =>
                    return "BNE  ";
                when Func3BLT =>
                    return "BLT  ";
                when Func3BLTU =>
                    return "BLTU ";
                when Func3BGE =>
                    return "BGE  ";
                when Func3BGEU =>
                    return "BGEU ";
            end case;
        when OpJump =>
            return "JAL  ";
        when OpJumpReg =>
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
        write(l, bv2hex(bit_vector(PC)), left, 3);--PC
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
                          constant param : bit_vector) is
    begin
        write(l, bv2hex(param), left, 3);
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
            write(l, bv2hex(Reg(i)), left, 3);
            write(l, string'("|"));
        end loop;
    end;
     
end trace_pack;