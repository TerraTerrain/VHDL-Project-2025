library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use WORK.defs_pack.all;

package conversion_pack is
    function sign_extend(imm : bit_vector) return bit_vector;
    function zero_extend(imm : bit_vector) return bit_vector;
end conversion_pack;



package body conversion_pack is
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
end conversion_pack;
