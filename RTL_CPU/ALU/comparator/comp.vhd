library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.cpu_defs_pack.all;

entity comparator is 
    Port (
        a, b             : in  data_type;
        func3            : in  Func3Type;
        out_comp         : out bit;
        branch_comp      : out bit
    );
end comparator;

architecture Behavioral of comparator is
begin
    process(a, b, func3)
    begin
        case func3 is
                out_comp <= '0';
                branch_comp <= '0';
            when Func3SLT =>
                out_comp <= '1' when signed(a) < signed(b) else '0';
            when Func3SLTU =>
                out_comp <= '1' when unsigned(a) < unsigned(b) else '0';
            when Func3BEQ =>
                branch_comp <= '1' when a = b else '0';
            when Func3BNE =>
                branch_comp <= '1' when a /= b else '0';
            when Func3BLT =>
                    branch_comp <= '1' when signed(a) < signed(b) else '0';
            when Func3BGE =>
                branch_comp <= '1' when signed(a) >= signed(b) else '0';   
            when Func3BLTU =>
                branch_comp <= '1' when unsigned(a) < unsigned(b) else '0'; 
            when Func3BGEU =>
                branch_comp <= '1' when unsigned(a) >= unsigned(b) else '0';    
            when others =>
                out_comp <= '0';
                branch_comp <= '0';
        end case;       

    end process;
end Behavioral;
