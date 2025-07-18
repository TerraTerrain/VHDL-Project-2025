library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use WORK.defs_pack.ALL;

entity TLE_RISCV is
    port (
        clk, rst  : in  bit;
        mem_data  : in  DataType;
        reg_data2 : out DataType;
        w_en      : out bit;
        memsigned : out bit;
        memaccess : out bit_vector(1 downto 0);
        address   : out bit_vector(15 downto 0);
        
        pc        : out bit_vector(15 downto 0);
        inc_pc    : out bit_vector(15 downto 0);
        next_pc    : out bit_vector(15 downto 0);
        instr     : out DataType;
        ALU       : out DataType
        
    );
end TLE_RISCV;

architecture Structural of TLE_RISCV is
    signal imm_sig, alu_result_sig, reg_data2_sig,
           instr_sig : DataType := (others => '0');
    signal next_pc_sig, inc_pc_sig, pc_sig : AddrType := (others => '0');
    signal alu_src1_sig, alu_src2_sig, branch_sig, reg_en_sig : bit := '0';
    signal func3_sig : Func3Type := (others => '0');
    signal func7_sig : Func7Type := (others => '0');
    signal reg_src_sig : bit_vector(1 downto 0) := "00";
    signal rd_sig, rs1_sig, rs2_sig : RegAddrType := (others => '0');
    
    signal w_en_sig, memsigned_sig : bit := '0';
    signal memaccess_sig : bit_vector(1 downto 0) := "00";
    signal address_sig : AddrType := (others => '0');
begin
    datapath_block : entity WORK.datapath(Structural)
        port map (
            clk        => clk,
            rst        => rst,
            mem_data   => mem_data,
            imm        => imm_sig,
            inc_pc     => inc_pc_sig,
            pc         => pc_sig,
            alu_src1   => alu_src1_sig,
            alu_src2   => alu_src2_sig,
            func3      => func3_sig,
            func7      => func7_sig,
            branch     => branch_sig,
            reg_src    => reg_src_sig,
            rd         => rd_sig,
            rs1        => rs1_sig,
            rs2        => rs2_sig,
            reg_en     => reg_en_sig,
            alu_result => alu_result_sig,
            reg_data2  => reg_data2_sig
        );
    reg_data2 <= reg_data2_sig;
    pc <= pc_sig(15 downto 0);
    instr <= instr_sig;

    
    
    controller_block : entity WORK.controller(Structural)
        port map (
            clk        => clk,
            rst        => rst,
            mem_data   => mem_data,
            imm        => imm_sig,
            inc_pc     => inc_pc_sig,
            pc         => pc_sig,
            instr      => instr_sig,
            alu_src1   => alu_src1_sig,
            alu_src2   => alu_src2_sig,
            func3      => func3_sig,
            func7      => func7_sig,
            branch     => branch_sig,
            reg_src    => reg_src_sig,
            rd         => rd_sig,
            rs1        => rs1_sig,
            rs2        => rs2_sig,
            reg_en     => reg_en_sig,
            alu_result => alu_result_sig,
                              
            w_en       => w_en_sig,
            memsigned  => memsigned_sig,
            memaccess  => memaccess_sig,
            address    => address_sig,
            next_pc    => next_pc_sig
        );
    w_en      <= w_en_sig;
    memsigned <= memsigned_sig;
    memaccess <= memaccess_sig;
    address   <= address_sig(15 downto 0); -- trimming for the TB memory
    ALU       <= alu_result_sig;
    next_pc   <= next_pc_sig(15 downto 0);
    inc_pc    <= inc_pc_sig(15 downto 0);

end Structural;
