library IEEE;
use IEEE.numeric_bit.ALL;
use work.defs_pack.all;
use work.conversion_pack.all;

package cpu_funcs_pack is
    procedure EXEC_OP_LOAD(constant Mem   : in MemType; 
                    constant func3  : in Func3Type; 
                    constant imm12  : in Imm12Type; 
                    constant rs1, rd : in RegAddrType;
                    constant RegIn  : in RegType;
                    variable RegOut : out RegType);
                    
    procedure EXEC_BEQ(constant rs1, rs2 : in RegAddrType;
                       constant Reg : in RegType;
                       constant bImm: in bit_vector;
                       constant PCIn: in AddrType;
                       variable PCOut: out AddrType);
    procedure EXEC_BNE(constant rs1, rs2 : in RegAddrType;
                       constant Reg : in RegType;
                       constant bImm: in bit_vector;
                       constant PCIn: in AddrType;
                       variable PCOut: out AddrType);
    procedure EXEC_BLT(constant rs1, rs2 : in RegAddrType;
                       constant Reg : in RegType;
                       constant bImm: in bit_vector;
                       constant PCIn: in AddrType;
                       variable PCOut: out AddrType);
    procedure EXEC_BLTU(constant rs1, rs2 : in RegAddrType;
                       constant Reg : in RegType;
                       constant bImm: in bit_vector;
                       constant PCIn: in AddrType;
                       variable PCOut: out AddrType);
    procedure EXEC_JAL(constant jimm20 : in bit_vector;
                       constant rd : in RegAddrType;
                       constant RegIn : in RegType;
                       variable RegOut : out RegType;
                       constant PCIn: in AddrType;
                       variable PCOut: out AddrType);
    procedure EXEC_JALR(constant imm12 : in bit_vector;
                       constant rd, rs1 : in RegAddrType;
                       constant RegIn : in RegType;
                       variable RegOut : out RegType;
                       constant PCIn: in AddrType;
                       variable PCOut: out AddrType);                             
end cpu_funcs_pack;

package body cpu_funcs_pack is
        procedure EXEC_OP_LOAD(constant Mem   : in MemType; 
                    constant func3  : in Func3Type; 
                    constant imm12  : in Imm12Type; 
                    constant rs1, rd : in RegAddrType;
                    constant RegIn  : in RegType;
                    variable RegOut : out RegType) is
    begin
        case func3 is
                    when Func3LB  => -- LB
                        RegOut(bv2natural(rd)) := sign_extend(Mem8( Mem, natural2bv( regAddImm(RegIn,rs1,imm12), AddrSize)));
                    when Func3LH  => -- LH
                        RegOut(bv2natural(rd)) := sign_extend(Mem16( Mem, natural2bv( regAddImm(RegIn,rs1,imm12), AddrSize)));
                    when Func3LW  => -- LW
                        RegOut(bv2natural(rd)) := Mem32( Mem, natural2bv( regAddImm(RegIn,rs1,imm12), AddrSize));
                    when Func3LBU => -- LBU
                        RegOut(bv2natural(rd)) := zero_extend(Mem8( Mem, natural2bv( regAddImm(RegIn,rs1,imm12), AddrSize)));
                    when Func3LHU => -- LHU
                        RegOut(bv2natural(rd)) := zero_extend(Mem16( Mem, natural2bv( regAddImm(RegIn,rs1,imm12), AddrSize)));
                    when others   =>
                        assert FALSE report "Illegal instruction" severity error;
                end case;
        end EXEC_OP_LOAD;
        
        procedure EXEC_BEQ(constant rs1, rs2 : in RegAddrType;
                       constant Reg : in RegType;
                       constant bImm: in bit_vector;
                       constant PCIn: in AddrType;
                       variable PCOut: out AddrType) is
            variable branch_temp  : bit_vector(12 downto 0);
     begin
            
            if Reg(bv2natural(rs1)) = Reg(bv2natural(rs2)) then
                        branch_temp := bImm & '0';                        
                        PCOut := natural2bv((to_integer(unsigned(PCIn)) + to_integer(signed(branch_temp))) mod (2**AddrSize),AddrSize);
                    else
                        PCOut := natural2bv((to_integer(unsigned(PCIn)) + 4) mod (2**AddrSize), AddrSize);
                    end if;
        end EXEC_BEQ;
        
        procedure EXEC_BNE(constant rs1, rs2 : in RegAddrType;
                       constant Reg : in RegType;
                       constant bImm: in bit_vector;
                       constant PCIn: in AddrType;
                       variable PCOut: out AddrType) is
            variable branch_temp  : bit_vector(12 downto 0);
     begin
            if Reg(bv2natural(rs1)) /= Reg(bv2natural(rs2)) then
                        branch_temp := bImm & '0';                        
                        PCOut := natural2bv((to_integer(unsigned(PCIn)) + to_integer(signed(branch_temp))) mod (2**AddrSize),AddrSize);
                    else
                        PCOut := natural2bv((to_integer(unsigned(PCIn)) + 4) mod (2**AddrSize), AddrSize);
                    end if;
        end EXEC_BNE;
             procedure EXEC_BLT(constant rs1, rs2 : in RegAddrType;
                       constant Reg : in RegType;
                       constant bImm: in bit_vector;
                       constant PCIn: in AddrType;
                       variable PCOut: out AddrType) is
            variable branch_temp  : bit_vector(12 downto 0);
     begin
            if signed(Reg(bv2natural(rs1))) < signed(Reg(bv2natural(rs2))) then
                        branch_temp := bImm & '0';                        
                        PCOut := natural2bv((to_integer(unsigned(PCIn)) + to_integer(signed(branch_temp))) mod (2**AddrSize),AddrSize);
                    else
                        PCOut := natural2bv((to_integer(unsigned(PCIn)) + 4) mod (2**AddrSize), AddrSize);
                    end if;
        end EXEC_BLT;
        
        procedure EXEC_BLTU(constant rs1, rs2 : in RegAddrType;
                       constant Reg : in RegType;
                       constant bImm: in bit_vector;
                       constant PCIn: in AddrType;
                       variable PCOut: out AddrType) is
            variable branch_temp  : bit_vector(12 downto 0);
     begin
            if unsigned(Reg(bv2natural(rs1))) < unsigned(Reg(bv2natural(rs2))) then
                        branch_temp := bImm & '0';                        
                        PCOut := natural2bv((to_integer(unsigned(PCIn)) + to_integer(signed(branch_temp))) mod (2**AddrSize),AddrSize);
                    else
                        PCOut := natural2bv((to_integer(unsigned(PCIn)) + 4) mod (2**AddrSize), AddrSize);
                    end if;
        end EXEC_BLTU;
 
        procedure EXEC_JAL(constant jimm20 : in bit_vector;
                       constant rd : in RegAddrType;
                       constant RegIn : in RegType;
                       variable RegOut : out RegType;
                       constant PCIn: in AddrType;
                       variable PCOut: out AddrType) is
            begin
            RegOut := RegIn;
            RegOut(bv2natural(rd)) := natural2bv((to_integer(unsigned(PCIn)) + 4) mod (2**AddrSize), AddrSize); 
            PCOut := natural2bv((to_integer(unsigned(PCIn)) + to_integer(signed(jimm20))) mod (2**AddrSize),AddrSize);   
            end EXEC_JAL;
            
        procedure EXEC_JALR(constant imm12 : in bit_vector;
                       constant rd, rs1 : in RegAddrType;
                       constant RegIn : in RegType;
                       variable RegOut : out RegType;
                       constant PCIn: in AddrType;
                       variable PCOut: out AddrType) is
            begin
            RegOut := RegIn;
            RegOut(bv2natural(rd)) := natural2bv((to_integer(unsigned(PCIn)) + 4) mod (2**AddrSize), AddrSize);
            PCOut := natural2bv((to_integer(unsigned(RegIn(bv2natural(rs1)))) + to_integer(signed(imm12))) mod (2**AddrSize),AddrSize);
            PCOut(0) := '0';  
            end EXEC_JALR;       
                            
end cpu_funcs_pack;