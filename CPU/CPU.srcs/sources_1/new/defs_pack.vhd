library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_bit.all;

package defs_pack is
-- Basic constants and types
    --PC, addr wire of bus, memory depth
    constant AddrSize       : integer := 16;
    constant ByteAddrSize   : integer := 2;
    constant MemoryAddrSize : integer := AddrSize - ByteAddrSize;
  

    --instruction, opcode size
    constant InstrSize : integer := 32;
    constant OpSize    : integer := 7;
    
    --data wire of bus, memory width
    constant BusDataSize : integer := 32;
    
    --register sizes
    constant RegDataSize: integer := 32;
    constant RegAddrSize: integer := 5;
    
    subtype AddrType  is unsigned   (AddrSize-1 downto 0); 
    subtype InstrType is bit_vector (InstrSize-1 downto 0);
    
    subtype OpType    is bit_vector (OpSize-1 downto 0);
    subtype Func3Type is bit_vector (2 downto 0);
    subtype Func7Type is bit_vector (6 downto 0);
    subtype Imm12Type is bit_vector (11 downto 0);
    subtype Imm20Type is bit_vector (19 downto 0);
    
    subtype BusDataType is bit_vector (BusDataSize-1 downto 0);
    subtype RegDataType is bit_vector (RegDataSize-1 downto 0);
    subtype RegAddrType is bit_vector (0 to RegAddrSize-1);

    type RegType is array (integer range 2**RegAddrSize-1    downto 0) of RegDataType;
    type MemType is array (integer range 2**MemoryAddrSize-1 downto 0) of BusDataType;
    
    type MnemonicType is (LB, LBU, LH, LHU, LW, SB, SH, SW, LUI, AUIPC,
                          ADD, SUB, ADDI, XORr, ORr, ANDr, XORI, ORI, ANDI,
                          SLLr, SRLr, SRAr, SLLI, SRLI, SRAI,
                          SLT, SLTU, SLTI, SLTIU, JAL, JALR,
                          BEQ, BNE, BLT, BLTU, BGE, BGEU);

-- Instruction constants
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
    
    constant NOP : OpType := "0000000";

end package;
