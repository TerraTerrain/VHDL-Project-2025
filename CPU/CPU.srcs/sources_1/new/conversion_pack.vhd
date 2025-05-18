library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use WORK.defs_pack.all;

package conversion_pack is
    function bv2natural(input: bit_vector) return natural;
    function natural2bv(value: natural; length: natural) return bit_vector;
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
end conversion_pack;
