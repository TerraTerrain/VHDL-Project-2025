library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.defs_pack.all;

entity comparator is 
    Port (
        a, b             : in  DataType;
        func3            : in  Func3Type;
        out_comp         : out bit;
        branch_comp      : out bit
    );
end comparator;

architecture Behavioral of comparator is    
    function signed_less_than(a, b : bit_vector) return bit is
        variable a_neg, b_neg : bit;
        variable result : bit;
    begin
        a_neg := a(a'left);  -- sign
        b_neg := b(b'left);  
        
        if a_neg = '1' and b_neg = '0' then
            result := '1'; -- neg < pos
        elsif a_neg = '0' and b_neg = '1' then
            result := '0'; -- pos >= neg
        elsif a_neg = '0' and b_neg = '0' then-- both pos
            if a < b then
                result := '1';
            else
                result := '0';
            end if;
        else --Both neg
            if a > b then
                result := '1';
            else
                result := '0';
            end if;
        end if;
        
        return result;
    end function;
    
    function unsigned_less_than(a, b : bit_vector) return bit is
        variable result : bit;
    begin
        if a < b then
            result := '1';
        else
            result := '0';
        end if;
        return result;
    end function;

begin
    process(a, b, func3)
    begin
        out_comp <= '0';
        branch_comp <= '0';
        case func3 is
            when Func3SLT =>
                out_comp <= signed_less_than(a, b);
            when Func3SLTU =>
                out_comp <= unsigned_less_than(a, b);
            when Func3BEQ =>
                if a = b then
                    branch_comp <= '1';
                else
                    branch_comp <= '0';
                end if;
            when Func3BNE =>
                if a /= b then
                    branch_comp <= '1';
                else
                    branch_comp <= '0';
                end if;
            when Func3BLT =>
                branch_comp <= signed_less_than(a, b);
            when Func3BGE =>
                if a /= b then
                    if signed_less_than(a, b) = '1' then
                        branch_comp <= '0';
                    else
                        branch_comp <= '1';
                    end if;
                else
                    branch_comp <= '1'; -- a = b, so >= b
                end if;
            when Func3BLTU =>
                branch_comp <= unsigned_less_than(a, b); 
            when Func3BGEU =>
                if a /= b then
                    if unsigned_less_than(a, b) = '1' then
                        branch_comp <= '0';
                    else
                        branch_comp <= '1';
                    end if;
                else
                    branch_comp <= '1'; -- a = b -> a >= b
                end if;
            when others =>
                out_comp <= '0';
                branch_comp <= '0';
        end case;       

    end process;
end Behavioral;