library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity shift is
    Port (
        data_in  : in  DataType;
        opcode     : in  OpType;
        data_out : out DataType
    );
end shift;

architecture Behavioral of shift is
begin
    process(data_in, opcode)
        variable temp : DataType;
    begin
        case opcode is
            when Func7SLL =>
                temp := data_in sll 1;
            when Func7SRL => 
                temp := data_in srl 1;
            when Func7SRA => 
                temp := data_in sra 1;
            when others =>
                temp := (others => '0');
        end case;
        data_out <= temp;
    end process;
end Behavioral;
