library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use WORK.defs_pack.ALL;

entity shift is
    Port (
        data_in   : in  DataType;
        func3     : in  Func3Type;
        func7     : in  Func7Type;
        out_shift : out DataType
    );
end shift;

architecture Behavioral of shift is
begin
    process(data_in, func3, func7)
        variable temp : DataType;
    begin
        case func7 is
            when Func7ShLog =>
                case func3 is
                    when Func3SLL => 
                        temp := data_in sll 1;
                    when Func3SRL_SRA => 
                        temp := data_in srl 1;                
                    when others =>
                        temp := (others => '0');
                end case;
            when Func7ShArthm =>
                case func3 is
                    when Func3SRL_SRA => 
                        temp := data_in sra 1;              
                    when others =>
                        temp := (others => '0');
                end case;
            when others =>
                temp := (others => '0'); -- Default
        end case;
        out_shift <= temp;
    end process;
end Behavioral;
