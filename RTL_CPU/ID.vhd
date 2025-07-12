library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.defs_pack.ALL;

entity ID is
    port ( 
    INSTR    : in bit_vector(31 downto 0);
    
    BRANCH   : in bit;
    --- control signals for datapath
    func3       : out bit_vector(2 downto 0);
    func7       : out bit_vector(6 downto 0);
    IMM      : out bit_vector(31 downto 0);
    RD       : out bit_vector(4 downto 0);
    RS1      : out bit_vector(4 downto 0);
    RS2      : out bit_vector(4 downto 0);
    PCSRC    : out bit_vector(1 downto 0);
    REGSRC   : out bit_vector(1 downto 0);
    ALUSrc1  : out bit;
    ALUSrc2  : out bit;

    
        
    MEMCODE: out bit_vector(2 downto 0);


    --- control signals for FSM
    CMD_CALC  : out bit;
    CMD_LOAD  : out bit;
    CMD_STORE : out bit;
    CMD_BRANCH : out bit;
    CMD_STOP  : out bit
    );
    
    
end ID;
--RD <= INSTR(11 downto 7); RS1 <= INSTR(19 downto 15); RS2 <= INSTR(24 downto 20);

architecture RTL of ID is
begin
    process(Instr)
    begin
    -- default assignemnt
        CMD_CALC <= '0'; CMD_LOAD <= '0'; CMD_STORE <= '0'; CMD_STOP <= '0';        
        RD <= (others => '0'); RS1 <= (others => '0'); RS2 <= (others => '0');
        PCSRC <= (others => '0'); REGSRC <= (others => '0');
        ALUSrc1 <= '0'; ALUSrc2 <= '0';
        MEMCODE <= INSTR(14 downto 12);
        IMM <= (others => '0');
        
        case INSTR(6 downto 0) is --opcode
        when OpImm => CMD_CALC <= '1'; ALUSrc2 <= '1'; RD <= INSTR(11 downto 7); RS1 <= INSTR(19 downto 15);
        when OpReg => CMD_CALC <= '1'; RD <= INSTR(11 downto 7); RS1 <= INSTR(19 downto 15); RS2 <= INSTR(24 downto 20);
        
        when OpLUI => CMD_CALC <= '1'; ALUSrc2 <= '1'; RD <= INSTR(11 downto 7);
        when OpAUIPC => CMD_CALC <= '1'; ALUSrc2 <= '1'; ALUSrc1 <= '1'; RD <= INSTR(11 downto 7);
        
        when OpLoad => CMD_LOAD <= '1'; ALUSrc2 <= '1'; RD <= INSTR(11 downto 7); RS1 <= INSTR(19 downto 15); REGSRC <= "01";
        when OpStore => CMD_STORE <='1'; ALUSrc2 <= '1'; RS1 <= INSTR(19 downto 15); RS2 <= INSTR(24 downto 20);
            
            
        when OpJump => ALUSrc2 <= '1'; ALUSrc1 <= '1'; RD <= INSTR(11 downto 7); REGSRC <= "10"; PCSRC <= "10";
        when OpJumpReg =>  ALUSrc2 <= '1'; RD <= INSTR(11 downto 7); RS1 <= INSTR(19 downto 15); REGSRC <= "10"; PCSRC <= "10";
        
        when OpBranch => RS1 <= INSTR(19 downto 15); RS2 <= INSTR(24 downto 20);
                         if BRANCH = '1' then PCSRC <= "01"; end if;
        end case;
end process;
end RTL;
   
