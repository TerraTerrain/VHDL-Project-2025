library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use WORK.defs_pack.all;

package conversion_pack is
    function bv2natural(input: bit_vector) return natural;
    function natural2bv(value: natural; length: natural) return bit_vector;

    function sign_extend(imm12 : bit_vector) return bit_vector; --transfer 12 bits to 32 bits for comparison

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
    
    function sign_extend(imm12 : bit_vector) return bit_vector is
        variable extended : bit_vector(31 downto 0);
        constant sign_bit : bit := imm12(11); --MSB of input(bit 11)
        
    begin
        --bit 31-12 : use MSB
        for i in 31 downto 12 loop
            extended(i) := sign_bit;
        end loop;
        --bit 11-0 : imm12
        for i in 11 downto 0 loop
            extended(i) := imm12(i);
        end loop;
        
        return extended;
    end function;

end conversion_pack;
