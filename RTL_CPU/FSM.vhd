library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity FSM is
    Port (CLK          : in bit;
          RST          : in bit;
          CMD_STOP     : in bit;
          CMD_CALC     : in bit;
          CMD_LOAD     : in bit;
          CMD_STORE    : in bit;
          CMD_BRANCH   : in bit;
          MEMCODE      : in bit_vector(2 downto 0);
          
          REG_EN       : out bit;
          INSTR_EN     : out bit;
          PC_EN        : out bit;
          ADDRSrc      : out bit;
          WEN          : out bit;
          MEMSIGNED    : out bit;
          MEMACCESS    : out bit_vector(1 downto 0)
          );
end FSM;

architecture Behavioral of FSM is
    type state_type is (s_IF, s_PFEX, s_MEM, s_STOP);
    signal state : state_type;
begin
nextstate_proc: process (CLK, RST) begin
    if RST = '0' then
        state <= s_IF;
    elsif CLK = '1' and CLK'event then
        case state is
            when s_IF => state <= s_PFEX;
            when s_PFEX =>
                if CMD_LOAD = '1' or CMD_STORE = '1' then state <= s_MEM;
                elsif CMD_STOP = '1' then state <= s_STOP;
                else state <= s_IF;
            end if;
            when s_MEM => state <= s_IF;
            when s_STOP => state <= s_STOP;
        end case;
    end if;
end process;

output_proc: process (state, CMD_STOP, CMD_CALC, CMD_LOAD, CMD_STORE, CMD_BRANCH)

begin
    REG_EN <= '0'; INSTR_EN <= '0'; PC_EN <= '0'; ADDRSrc <= '0';
    WEN <= '0'; MEMACCESS <= "10"; MEMSIGNED <= '0';
    case state is
    when S_IF =>  INSTR_EN <= '1';    
    when s_PFEX => PC_EN <= '1'; 
                   if CMD_CALC = '1' then REG_EN <= '1'; end if;
                   if CMD_LOAD = '1' or CMD_STORE ='1' then ADDRSrc <= '1'; end if;
    when s_MEM => ADDRSrc <= '1';
                   if CMD_LOAD = '1' then REG_EN <= '1'; end if;
                   if CMD_STORE= '1' then WEN <= '1'; end if;
                   MEMSIGNED <= MEMCODE(2);
                   MEMACCESS <= MEMCODE(1 downto 9);
                   
    end case;
end process;
end Behavioral;
