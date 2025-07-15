library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use WORK.defs_pack.ALL;

entity TB_TLE is
end TB_TLE;

architecture Structural of TB_TLE is
    signal mem_data_sig, instr_sig, reg_data2_sig : DataType;
    signal clk_sig, rst_sig, w_en_sig, memsigned_sig : bit;
    signal memaccess_sig : bit_vector(1 downto 0);
    signal pc_sig, address_sig : bit_vector(15 downto 0);
begin
    clk_process : process
    begin
        while true loop
            clk_sig <= '0';
            wait for 5 ns;
            clk_sig <= '1';
            wait for 5 ns;
        end loop;
    end process clk_process;
    
    rst_process : process
    begin
        rst_sig <= '1';
        wait for 30 ns;
        rst_sig <= '0';
        wait;
    end process rst_process;

    UUT : entity WORK.TLE_RISCV(Structural)
        port map(
            clk => clk_sig,
            rst => rst_sig,
            mem_data  => mem_data_sig,
            pc        => pc_sig,
            instr     => instr_sig,
            reg_data2 => reg_data2_sig,
            w_en      => w_en_sig,
            memsigned => memsigned_sig,
            memaccess => memaccess_sig,
            address   => address_sig
        );

    TB : entity WORK.TB(Functional)
        port map(
            rdata => mem_data_sig,
            PC    => pc_sig,
            Instr => instr_sig,
            wdata => reg_data2_sig,
            rdwr  => w_en_sig,
            sign  => memsigned_sig,
            Acc   => memaccess_sig,
            addr  => address_sig
        );

end Structural;
