library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

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
    
    subtype AddrType  is bit_vector (AddrSize-1 downto 0); 
    subtype InstrType is bit_vector (InstrSize-1 downto 0);
    
    subtype OpType    is bit_vector (OpSize-1 downto 0);
    subtype Func3Type is bit_vector (2 downto 0);
    subtype Func7Type is bit_vector (6 downto 0);
    subtype Imm12Type is bit_vector (11 downto 0);
    subtype Imm20Type is bit_vector (19 downto 0);
    subtype BImmType is bit_vector (11 downto 0);
    
    subtype BusDataType is bit_vector (BusDataSize-1 downto 0);
    subtype RegDataType is bit_vector (RegDataSize-1 downto 0);
    subtype RegAddrType is bit_vector (0 to 2**RegAddrSize-1);

    type RegType is array (integer range 2**RegAddrSize-1    downto 0) of RegDataType;
    type MemType is array (integer range 2**MemoryAddrSize-1 downto 0) of BusDataType;
    
    
    -- Op Codes
    constant OpImm : OpType := "0010011";
    constant OpReg : OpType := "0110011";
    constant OpLoad   : OpType    := "0000011";
    constant OpLUI    : OpType    := "0110111";
    constant OpAUIPC  : OpType    := "0010111";
    constant OpStore  : OpType    := "0100011";
    constant OpBranch  : OpType    := "1100011";
    constant OpJump    : OpType    := "1101111";
    constant OpJumpReg : OpType    := "1100111";
    
        -- Branch instructions
    constant Func3BEQ  : Func3Type := "000";
    constant Func3BNE  : Func3Type := "001";
    constant Func3BLT  : Func3Type := "100";
    constant Func3BGE  : Func3Type := "101";
    constant Func3BLTU : Func3Type := "110";
    constant Func3BGEU : Func3Type := "111";
end package;