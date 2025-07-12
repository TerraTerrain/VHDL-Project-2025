
library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_bit.all;

package defs_pack is
-- Basic constants and types
    constant AddrSize       : natural  := 32; -- PC
    constant ByteAddrSize   : natural := 2; -- offset
    constant MemoryAddrSize : natural := AddrSize - ByteAddrSize;
  
    constant InstrSize : natural := 32;
    constant OpSize    : natural := 7;
    
    -- bus, memory and register width
    constant DataSize : natural := 32;
    
    -- registers amount
    constant RegAddrSize: natural := 5;
    
    subtype AddrType  is bit_vector (AddrSize-1 downto 0); 
    subtype InstrType is bit_vector (InstrSize-1 downto 0);
    
    subtype OpType    is bit_vector (OpSize-1 downto 0);
    subtype Func3Type is bit_vector (2 downto 0);
    subtype Func7Type is bit_vector (6 downto 0);
    subtype Imm12Type is bit_vector (11 downto 0);
    subtype Imm20Type is bit_vector (19 downto 0);
    
    subtype DataType is bit_vector (DataSize-1 downto 0);
    subtype RegAddrType is bit_vector (RegAddrSize-1 downto 0);

    type RegType is array (integer range 0 to 2**RegAddrSize-1) of DataType;
    type MemType is array (integer range 0 to 2**AddrSize-1) of DataType;
    
    type MnemonicType is (
        ADD,SUB,SLLr,SRLr,SRAr,XORr,ORr,ANDr,SLT,SLTU,
        ADDI,SLLI,SRLI,SRAI,XORI,ORI,ANDI,SLTI,SLTIU,
                     JALR,LB,LBU,LH,LHU,LW, SB,SH,SW,
        BEQ,BNE,BLT,BLTU,BGE,BGEU,
        LUI,AUIPC,
        JAL,
        EBREAK                                                                        
    ); -- R-Type(0 to 9),I+S-Type(10 to 27),B-Type(28 to 33)
       -- U+J-Type(34 to 36),EBREAK(37)

-- Instruction constants
    -- EBREAK
    constant OpEBREAK : OpType := "1111111";
    
    -- Imm/Reg Opcode
    constant OpImm : OpType := "0010011";
    constant OpReg : OpType := "0110011";

    -- Load instructions
    constant OpLoad   : OpType    := "0000011";
    constant Func3LB  : Func3Type := "000";
    constant Func3LH  : Func3Type := "001";
    constant Func3LW  : Func3Type := "010";
    constant Func3LBU : Func3Type := "100";
    constant Func3LHU : Func3Type := "101";
    
    constant OpLUI    : OpType    := "0110111";
    constant OpAUIPC  : OpType    := "0010111";
    
    -- Store instructions
    constant OpStore  : OpType    := "0100011";
    constant Func3SB  : Func3Type := "000";
    constant Func3SH  : Func3Type := "001";
    constant Func3SW  : Func3Type := "010";
    
    -- Arithmetic instructions
    constant Func7ADD   : Func7Type := "0000000";
    constant Func7SUB   : Func7Type := "0100000";
    constant Func3Arthm : Func3Type := "000";
    
    -- Logical instructions
    constant Func3XOR : Func3Type := "100";
    constant Func3OR  : Func3Type := "110";
    constant Func3AND : Func3Type := "111";
    constant Func7Log : Func7Type := "0000000";
    
    -- Shift instructions
    constant Func3SLL     : Func3Type := "001";
    constant Func3SRL_SRA : Func3Type := "101";
    constant Func7ShLog   : Func7Type := "0000000"; 
    constant Func7ShArthm : Func7Type := "0100000";  
    
    -- Compare instructions
    constant Func3SLT  : Func3Type := "010";
    constant Func3SLTU : Func3Type := "011";
    constant Func7Set  : Func7Type := "0000000";
        
    -- Branch instructions
    constant OpBranch  : OpType    := "1100011";
    constant Func3BEQ  : Func3Type := "000";
    constant Func3BNE  : Func3Type := "001";
    constant Func3BLT  : Func3Type := "100";
    constant Func3BGE  : Func3Type := "101";
    constant Func3BLTU : Func3Type := "110";
    constant Func3BGEU : Func3Type := "111";
        
    -- Jump/Link instructions
    constant OpJump    : OpType    := "1101111";
    constant OpJumpReg : OpType    := "1100111";
    constant Func3JALR : Func3Type := "000";

end package;
