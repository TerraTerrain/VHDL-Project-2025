library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_BIT.ALL;
use WORK.defs_pack.ALL;

entity reg_file is
    port (
        clk,rst,we : in bit;
        w_addr : in RegAddrType;
        w_data : in DataType;
        r_addr1,r_addr2 : in RegAddrType;
        r_data1,r_data2 : out DataType
    );
end reg_file;

architecture Behavioral of reg_file is
    signal we_vector_sig : bit_vector(2**RegAddrSize-1 downto 0)
        := (others => '0');
    signal regs_in_sig   : RegType := (others => (others => '0'));
    signal r_data_sig1   : DataType := (others => '0');
    signal r_data_sig2   : DataType := (others => '0');
begin
    decoder: entity WORK.we_decoder(Behavioral)
        port map(
            we        => we,
            w_addr    => w_addr,
            we_vector => we_vector_sig
        );
        
    selector: entity WORK.reg_double_mux(Behavioral)
        port map (
            regs_in => regs_in_sig,
            r_addr1  => r_addr1,
            r_data1  => r_data_sig1,
            r_addr2  => r_addr2,
            r_data2  => r_data_sig2
        );
    
    reg_array: for i in 0 to 2**RegAddrSize-1 generate
        reg_i: entity WORK.reg32(Behavioral)
            port map (
                clk   => clk,
                rst   => rst,
                en    => we_vector_sig(i),
                d_in  => w_data,
                d_out => regs_in_sig(i)
            );
    end generate reg_array;
    
    r_data1 <= r_data_sig1;
    r_data2 <= r_data_sig2;

end Behavioral;
