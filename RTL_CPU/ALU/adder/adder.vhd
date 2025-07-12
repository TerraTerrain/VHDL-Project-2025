library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_BIT.ALL;
use WORK.defs_pack.ALL;

entity adder is
    port(
        a,b : in datatype;
        o_mode : in bit;--0:add;1:sub
        s : out datatype;
        carry_out : out bit;
        overflow: out bit
    );
end adder;

architecture Behavioral of adder is
    signal a_in : datatype;
    signal b_in : datatype;
    signal s_in : datatype;
    signal carry : bit_vector(datasize downto 0);--sub:1->a>=b;0->a<b
begin
    a_in <= a;

    --process: +b or -b decided by o_mode
    process(b, o_mode)
    begin
        if o_mode = '1' then
            b_in <= not b;-- -b
        else
            b_in <= b;-- +b
        end if;
    end process;
    carry(0) <= o_mode;--o_mode:0 -> add -> carry(0) = 0;o_mode:1 -> sub -> carry(0):1
    
    --generate all FAs 
    gen_fa : for i in 0 to datasize-1 generate
        fa: entity work.full_adder(Behavioral)
        port map(
                a => a_in(i),
                b => b_in(i),
                cin => carry(i),
                sum => s_in(i),
                cout => carry(i+1)
                );
    end generate;
    --outputs:
    s <= s_in;--32bits
    carry_out <= carry(datasize);--1 bit
    overflow  <= carry(datasize) xor carry(datasize - 1); --overflow = c32 xor c31; 1 bit
    
end Behavioral;