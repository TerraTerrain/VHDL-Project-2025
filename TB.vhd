library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.defs_pack.ALL;
use IEEE.numeric_bit.ALL;

entity TB is
  Port(
  PC    : in  bit_vector (15 downto 0);
  Instr : in  InstrType;  
  addr  : in  bit_vector (15 downto 0);
  wdata : in  BusDataType;
  rdwr  : in  bit;
  Acc  : in bit_vector(1 downto 0);
  sign : in bit;
  
  rdata : out BusDataType );
end TB;

architecture Functional of TB is
begin
    process(PC, addr, wdata, rdwr)
        variable Mem          : MemType     := (others=>(others=>'0'));
        variable wordaddr     : integer := 0;
    begin
    rdata <= (others => '0');
    wordaddr := TO_INTEGER(unsigned(addr and "00"));
    if rdwr = '1' then
        case Acc is
            when "00" =>  --byte access
            case addr(1 downto 0) is -- check the last 2 bits of address
                            when "00" => -- Lower byte
                                Mem(wordaddr)(7 downto 0)   := wdata(7 downto 0);
                            when "01" => -- Lower middle byte
                                Mem(wordaddr)(15 downto 8)  :=  wdata(7 downto 0);

                            when "10" => -- Upper middle byte 
                                Mem(wordaddr)(23 downto 16) :=  wdata(7 downto 0);

                            when "11" => -- Upper byte
                                Mem(wordaddr)(31 downto 24) :=  wdata(7 downto 0);

                            when others =>
                                assert FALSE report "Unaligned address for SB" severity error;
                            end case;
            when "01" => --halfword
            case addr(1 downto 0) is -- check the last 2 bits of address
                            when "00" => -- Lower half-word
                                Mem(wordaddr)(15 downto 0)  := wdata(15 downto 0);

                            when "10" => -- Upper half-word
                                Mem(wordaddr)(31 downto 16) := wdata(15 downto 0);

                            when others =>
                                assert FALSE report "Unaligned address for SH" severity error;
                            end case;
            when "10" =>
                    Mem(wordaddr) := wdata; 
            end case;       
    else 
        case Acc is
            when "00" =>  --byte access
            case addr(1 downto 0) is -- check the last 2 bits of address
                            when "00" => -- Lower byte
                                rdata(7 downto 0) <= Mem(wordaddr)(7 downto 0);
                                if sign = '1' and Mem(wordaddr)(7) = '1' then rdata(31 downto 8) <= (others => '1'); end if;
                            when "01" => -- Lower middle byte
                                rdata(7 downto 0) <= Mem(wordaddr)(15 downto 8);
                                if sign = '1' and Mem(wordaddr)(15) = '1' then rdata(31 downto 8) <= (others => '1'); end if;
                            when "10" => -- Upper middle byte 
                                rdata(7 downto 0) <= Mem(wordaddr)(23 downto 16);
                                if sign = '1' and Mem(wordaddr)(23) = '1' then rdata(31 downto 8) <= (others => '1'); end if;

                            when "11" => -- Upper byte
                                rdata(7 downto 0) <= Mem(wordaddr)(31 downto 24);
                                if sign = '1' and Mem(wordaddr)(31) = '1' then rdata(31 downto 8) <= (others => '1'); end if;

                            when others =>
                                assert FALSE report "Unaligned address for SB" severity error;
                            end case;
            when "01" =>
            case addr(1 downto 0) is -- check the last 2 bits of address
                            when "00" => -- Lower half-word
                                rdata(15 downto 0) <= Mem(wordaddr)(15 downto 0);
                                if sign = '1' and Mem(wordaddr)(15) = '1' then rdata(31 downto 16) <= (others => '1'); end if;

                            when "10" => -- Upper half-word
                                rdata(15 downto 0) <= Mem(wordaddr)(31 downto 16);
                                if sign = '1' and Mem(wordaddr)(15) = '1' then rdata(31 downto 16) <= (others => '1'); end if;
                            when others =>
                                assert FALSE report "Unaligned address for SH" severity error;
                            end case;
            when "10" =>
                    rdata <= Mem(wordaddr);
            end case;     
    end if;

    end process;
end Functional;
