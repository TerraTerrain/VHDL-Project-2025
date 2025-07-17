library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use WORK.defs_pack.ALL;

entity reg32 is
    port (
        clk, rst, en : in bit;
        d_in  : in  DataType;
        d_out : out DataType
    );
end reg32;


architecture Behavioral of reg32 is 
begin
    process (clk)
    begin
        if clk = '1' and clk'event then
            if rst = '1' then
                d_out <= (others => '0');
            elsif en = '1' then
                d_out <= d_in;
            end if;
        end if;
    end process;
end Behavioral;
