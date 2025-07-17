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
    process(Instr, BRANCH)
    begin
    -- default assignemnt
        CMD_CALC <= '0'; CMD_LOAD <= '0'; CMD_STORE <= '0'; CMD_STOP <= '0'; CMD_BRANCH <= '0';       
        RD <= (others => '0'); RS1 <= (others => '0'); RS2 <= (others => '0');
        PCSRC <= (others => '0'); REGSRC <= (others => '0');
        ALUSrc1 <= '0'; ALUSrc2 <= '0';
        MEMCODE <= INSTR(14 downto 12);
        IMM <= (others => '0');
        func3 <= (others => '0');
        func7 <= (others => '0');
        
        case INSTR(6 downto 0) is --opcode
        when OpImm => CMD_CALC <= '1'; ALUSrc2 <= '1'; RD <= INSTR(11 downto 7); RS1 <= INSTR(19 downto 15);
                func3 <= INSTR(14 downto 12);
                if INSTR(14 downto 12) = Func3SLL or INSTR(14 downto 12) = Func3SRL_SRA 
                        then IMM(4 downto 0) <= INSTR(24 downto 20);
                else                
                    IMM(11 downto 0) <= INSTR(31 downto 20);                
                    if INSTR(31) = '1' then IMM(31 downto 12) <= (others => '1'); end if;
                end if;
        when OpReg => CMD_CALC <= '1'; RD <= INSTR(11 downto 7); RS1 <= INSTR(19 downto 15); RS2 <= INSTR(24 downto 20);
                    func7 <= INSTR(31 downto 25);
                    func3 <= INSTR(14 downto 12);
                    
        
        when OpLUI => CMD_CALC <= '1'; ALUSrc2 <= '1'; RD <= INSTR(11 downto 7);
                   IMM(31 downto 12) <= INSTR(31 downto 12);
        when OpAUIPC => CMD_CALC <= '1'; ALUSrc2 <= '1'; ALUSrc1 <= '1'; RD <= INSTR(11 downto 7);
                   IMM(31 downto 12) <= INSTR(31 downto 12);
        
        when OpLoad => CMD_LOAD <= '1'; ALUSrc2 <= '1'; RD <= INSTR(11 downto 7); RS1 <= INSTR(19 downto 15); REGSRC <= "01";
                    IMM(11 downto 0) <= INSTR(31 downto 20);                
                    if INSTR(31) = '1' then IMM(31 downto 12) <= (others => '1'); end if;
                    
        
        when OpStore => CMD_STORE <='1'; ALUSrc2 <= '1'; RS1 <= INSTR(19 downto 15); RS2 <= INSTR(24 downto 20);
                    IMM(11 downto 5) <= INSTR(31 downto 25);    IMM(4 downto 0) <= INSTR(11 downto 7);            
                    if INSTR(31) = '1' then IMM(31 downto 12) <= (others => '1'); end if;
            
            
        when OpJump => ALUSrc2 <= '1'; ALUSrc1 <= '1'; RD <= INSTR(11 downto 7); REGSRC <= "10"; PCSRC <= "10";
                    CMD_CALC <= '1';
                    IMM(20) <= INSTR(31);    IMM(10 downto 1) <= INSTR(30 downto 21); IMM(11) <= INSTR(20);    IMM(19 downto 12) <= INSTR(19 downto 12);           
                    if INSTR(31) = '1' then IMM(31 downto 21) <= (others => '1'); end if;
                    
        when OpJumpReg =>  ALUSrc2 <= '1'; RD <= INSTR(11 downto 7); RS1 <= INSTR(19 downto 15); REGSRC <= "10"; PCSRC <= "10";
                    CMD_CALC <= '1';
                    IMM(11 downto 0) <= INSTR(31 downto 20);            
                    if INSTR(31) = '1' then IMM(31 downto 12) <= (others => '1'); end if;
        
        when OpBranch => RS1 <= INSTR(19 downto 15); RS2 <= INSTR(24 downto 20);
                        IMM(10 downto 5) <= INSTR(30 downto 25);    IMM(4 downto 1) <= INSTR(11 downto 8); 
                        IMM(12) <= INSTR(31); IMM(11) <= INSTR(07); 
                        CMD_BRANCH <= '1';
                        if BRANCH = '1' then PCSRC <= "01"; end if;
                        func3 <= INSTR(14 downto 12);
        when others => null;
        end case;
end process;
end RTL;
   
