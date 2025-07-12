library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_BIT.ALL;
use WORK.defs_pack.ALL;

entity reg_file is
    port (
        clk, rst : in bit;
        we, re   : in bit;
        w_addr, r_addr : in RegAddrType;
        w_data : in  DataType;
        r_data : out DataType
    );
end reg_file;

architecture Behavioral of reg_file is
    signal we_vector_sig : bit_vector(2**RegAddrSize-1 downto 0)
        := (others => '0');
    signal regs_in_sig   : RegType := (others => (others => '0'));
    signal r_data_sig    : DataType := (others => '0');
begin
    decoder: entity WORK.we_decoder(Behavioral)
        port map(
            we        => we,
            w_addr    => w_addr,
            we_vector => we_vector_sig
        );
        
    selector: entity WORK.reg_mux(Behavioral)
        port map (
            re      => re,
            r_addr  => r_addr,
            regs_in => regs_in_sig,
            d_out   => r_data_sig
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
    
    r_data <= r_data_sig;

end Behavioral;
