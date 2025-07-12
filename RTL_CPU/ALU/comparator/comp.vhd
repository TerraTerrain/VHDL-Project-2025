library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.cpu_defs_pack.all;

entity comparator is 
    Port (
        data_in1    : in  data_type;
        data_in2    : in  data_type;
        opcode      : in  opcode_type;
        data_out    : out data_type
    );
end comparator;

architecture Behavioral of comparator is
begin
    process(data_in1, data_in2, opcode)
        variable temp : data_type := (others => '0');
    begin
        case opcode is
            when code_slt =>
                if signed(data_in1) < signed(data_in2) then
                    temp := (others => '1');
                else
                    temp := (others => '0');
                end if;
            when code_sltu => 
                if unsigned(data_in1) < unsigned(data_in2) then
                    temp := (others => '1');
                else
                    temp := (others => '0');
                end if;
            when others =>
                temp := (others => '0');
        end case;
        data_out <= temp;
    end process;
end Behavioral;
