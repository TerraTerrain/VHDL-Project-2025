library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use WORK.defs_pack.all;
use IEEE.numeric_bit.ALL;

package conversion_pack is
    function bv2str(bv : bit_vector) return string;
    function sign_extend(imm : bit_vector) return bit_vector;
    function zero_extend(imm : bit_vector) return bit_vector;
    function loadMem32(Mem: MemType; address: unsigned) return BusDataType;
    function loadMem16(Mem: MemType; address: unsigned) return bit_vector;
    function loadMem8 (Mem: MemType; address: unsigned) return bit_vector;
    procedure storeMem32(Mem: inout MemType; address: integer; Reg: RegType; rs2: integer);
    procedure storeMem16(Mem: inout MemType; address: integer; Reg: RegType; rs2: integer);
    procedure storeMem8 (Mem: inout MemType; address: integer; Reg: RegType; rs2: integer);
end conversion_pack;



package body conversion_pack is

    function bv2str(bv : bit_vector) return string is
        variable result : string(1 to bv'length);
    begin
        for i in 0 to bv'length - 1 loop
            result(i + 1) := character'value(bit'image(bv(bv'left - i)));
        end loop;
        return result;
    end function;
    
    function sign_extend(imm : bit_vector) return bit_vector is
        constant extend_length : integer := 32 - imm'length;
        variable extended_imm : bit_vector(31 downto 0);
    begin
        -- Extend with the MSB of the input
        extended_imm := (extend_length - 1 downto 0 => imm(imm'length - 1)) & imm;
        return extended_imm;
    end function;
    
    function zero_extend(imm : bit_vector) return bit_vector is
        constant extend_length : integer := 32 - imm'length;
        variable extended_imm : bit_vector(31 downto 0);
    begin
        -- Extend input with '0' bits
        extended_imm := (extend_length - 1 downto 0 => '0') & imm;
        return extended_imm;
    end function;
    
    function loadMem32(Mem: MemType; address: unsigned) return BusDataType is
        variable word_addr : integer     := to_integer( address(15 downto 2) ); -- Word address
        variable result    : BusDataType := (others => '0');
    begin
        result := Mem(word_addr); -- Directly load the 32-bit word
        return result;
    end function;
    
    function loadMem16(Mem: MemType; address: unsigned) return bit_vector is
        variable word_addr : integer     := to_integer( address(15 downto 2) ); -- Word address
        variable offset    : integer     := to_integer( address(1 downto 0) );  -- Byte offset
        variable word      : BusDataType := Mem(word_addr);
        variable result    : bit_vector(15 downto 0);
    begin
        case offset is
            when 0 => -- Lower half word
                result := word(15 downto 0);
            when 2 => -- Upper half word
                result := word(31 downto 16);
            when others =>
                assert FALSE report "Invalid offset" severity error;
        end case;
        return result;
    end function;
    
    function loadMem8(Mem: MemType; address: unsigned) return bit_vector is
        variable word_addr : integer     := to_integer( address(15 downto 2) ); -- Word address
        variable offset    : integer     := to_integer( address(1 downto 0) );  -- Byte offset
        variable word      : BusDataType := Mem(word_addr);
        variable result    : bit_vector(7 downto 0);
    begin
        case offset is
            when 0 => -- Byte 0 (least significant byte)
                result := word(7 downto 0);
            when 1 => -- Byte 1
                result := word(15 downto 8);
            when 2 => -- Byte 2
                result := word(23 downto 16);
            when 3 => -- Byte 3 (most significant byte)
                result := word(31 downto 24);
            when others =>
                assert FALSE report "Invalid offset" severity error;
        end case;
        return result;
    end function;
    
    procedure storeMem32(Mem: inout MemType; address: integer; Reg: RegType; rs2: integer) is
    begin
        case address mod 4 is -- check the last 2 bits of address
            when 0 =>
                Mem(address) := Reg(rs2);
            when others =>
                assert FALSE report "Unaligned address for SW" severity error;
        end case;
    end procedure;
    
    procedure storeMem16(Mem: inout MemType; address: integer; Reg: RegType; rs2: integer) is
    begin
        case address mod 4 is -- check the last 2 bits of address
            when 0 => -- Lower half-word
                Mem(address)(15 downto 0)  := Reg(rs2)(15 downto 0);
            when 2 => -- Upper half-word
                Mem(address)(31 downto 16) := Reg(rs2)(15 downto 0);
            when others =>
                assert FALSE report "Unaligned address for SH" severity error;
        end case;
    end procedure;

    procedure storeMem8 (Mem: inout MemType; address: integer; Reg: RegType; rs2: integer) is
    begin
        case address mod 4 is -- check the last 2 bits of address
            when 0 => -- Lower byte
                Mem(address)(7 downto 0)   := Reg(rs2)(7 downto 0);
            when 1 => -- Lower middle byte
                Mem(address)(15 downto 8)  := Reg(rs2)(7 downto 0);
            when 2 => -- Upper middle byte
                Mem(address)(23 downto 16) := Reg(rs2)(7 downto 0);
            when 3 => -- Upper byte
                Mem(address)(31 downto 24) := Reg(rs2)(7 downto 0);
            when others =>
                assert FALSE report "Unaligned address for SB" severity error;
        end case;
    end procedure;
end conversion_pack;
