library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_bit.all;
use WORK.defs_pack.all;

package conversion_pack is
    function bv2natural(input: bit_vector) return natural;
    function natural2bv(value: natural; length: natural) return bit_vector;
    function sign_extend(imm12 : bit_vector) return bit_vector; --transfer 12 bits to 32 bits for comparison
    function bv2signed(bv : bit_vector) return signed;
    function signed2bv(s : signed) return bit_vector;
end conversion_pack;



package body conversion_pack is
    function bv2natural(input: bit_vector) return natural is
        variable result : natural := 0;
        variable bit_length : natural := input'length;
    begin
       for i in input'left downto 0 loop
            result := result * 2 + bit'pos(input(i));
        end loop;
    return result;
    end function;
    
    function natural2bv(value: natural; length: natural) return bit_vector is
        variable result : bit_vector(length-1 downto 0) := (others => '0');
        variable tmp : natural := value;
    begin
        for i in 0 to length-1 loop
     result(i) := bit'val(tmp mod 2);
tmp := tmp / 2;
end loop;

        return result;
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
    
    function bv2signed(bv : bit_vector) return signed is
        variable result : signed(bv'range);
    begin
        for i in bv'range loop
            result(i) := bv(i);
        end loop;
        return result;
    end function;
    
    function signed2bv(s : signed) return bit_vector is 
        variable result : bit_vector(s'range);
    begin
        for i in s'range loop
            result(i) := s(i);
        end loop;
        return result;
    end function;
    
    
end conversion_pack;
