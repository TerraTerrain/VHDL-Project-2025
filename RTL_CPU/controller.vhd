library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use WORK.defs_pack.ALL;

entity controller is
    port (
        clk, rst           : in  bit;
        mem_data           : in  DataType;
        imm                : out DataType;
        inc_pc, pc         : out AddrType;
        instr              : out DataType;
        alu_src1, alu_src2 : out bit;
        func3              : out Func3Type;
        func7              : out Func7Type;
        branch             : in  bit;
        reg_src            : out bit_vector(1 downto 0);
        rd, rs1, rs2       : out RegAddrType;
        reg_en             : out bit;
        alu_result         : in  DataType;
        w_en               : out bit;
        memsigned          : out bit;
        memaccess          : out bit_vector(1 downto 0);
        address            : out AddrType;
        Next_pc            : out AddrType
    );
end controller;

architecture Structural of controller is
    signal instr_out, imm_TO_add, add_TO_mux4x1, inc_out,
           mux4x1_TO_pc, pc_out : DataType := (others => '0');
    signal pcsrc_TO_mux4x1 : bit_vector(1 downto 0) := "00";
    signal instr_en_sig, pc_en_sig, addrsrc_sig, reg_en_sig,
           w_en_sig, memsigned_sig : bit := '0';
    signal memaccess_sig : bit_vector(1 downto 0) := "00";
    signal address_sig : DataType := (others => '0');
    
    signal imm_sig : DataType := (others => '0');
    signal alu_src1_sig, alu_src2_sig : bit := '0';
    signal func3_sig : Func3Type := (others => '0');
    signal func7_sig : Func7Type := (others => '0');
    signal reg_src_sig : bit_vector(1 downto 0) := "00";
    signal rd_sig, rs1_sig, rs2_sig : RegAddrType := (others => '0');
    signal CMD_CALC_sig, CMD_LOAD_sig, CMD_STORE_sig,
           CMD_BRANCH_sig, CMD_STOP_sig : bit := '0';
    signal MEMCODE_sig : bit_vector(2 downto 0) := "000";
    
begin
    inc_pc   <= inc_out; -- AddrType <= DataType; same subtype
    pc       <= pc_out;  -- AddrType <= DataType; same subtype
    
    id_block : entity WORK.ID(RTL)
        port map(
            INSTR      => instr_out,
            BRANCH     => branch,
            func3      => func3_sig,
            func7      => func7_sig,
            IMM        => imm_sig,
            RD         => rd_sig,
            RS1        => rs1_sig,
            RS2        => rs2_sig,
            PCSRC      => pcsrc_TO_mux4x1,
            REGSRC     => reg_src_sig,
            ALUSrc1    => alu_src1_sig,
            ALUSrc2    => alu_src2_sig,
            MEMCODE    => MEMCODE_sig,
            CMD_CALC   => CMD_CALC_sig,
            CMD_LOAD   => CMD_LOAD_sig,
            CMD_STORE  => CMD_STORE_sig,
            CMD_BRANCH => CMD_BRANCH_sig,
            CMD_STOP   => CMD_STOP_sig
        );
    imm      <= imm_sig;
    alu_src1 <= alu_src1_sig;
    alu_src2 <= alu_src2_sig;
    func3    <= func3_sig;
    func7    <= func7_sig;
    reg_src  <= reg_src_sig;
    rd       <= rd_sig;
    rs1      <= rs1_sig;
    rs2      <= rs2_sig;
        
    FSM_block : entity WORK.FSM(Behavioral)
        port map (
            clk => clk,
            rst => rst,
            MEMCODE    => MEMCODE_sig,
            CMD_CALC   => CMD_CALC_sig,
            CMD_LOAD   => CMD_LOAD_sig,
            CMD_STORE  => CMD_STORE_sig,
            CMD_BRANCH => CMD_BRANCH_sig,
            CMD_STOP   => CMD_STOP_sig,
            REG_EN     => reg_en_sig,
            INSTR_EN   => instr_en_sig,
            PC_EN      => pc_en_sig,
            ADDRSrc    => addrsrc_sig,
            WEN       => w_en_sig,
            MEMSIGNED  => memsigned_sig,
            MEMACCESS  => memaccess_sig
        );
    reg_en    <= reg_en_sig;
    w_en      <= w_en_sig;
    memsigned <= memsigned_sig;
    memaccess <= memaccess_sig;
    next_pc <=mux4x1_TO_pc; 
    instr_reg : entity WORK.reg32(Behavioral)
        port map (
            clk   => clk,
            rst   => rst,
            en    => instr_en_sig,
            d_in  => mem_data,
            d_out => instr_out
        );
    instr <= instr_out;
        
    pc_reg : entity WORK.reg32(Behavioral)
        port map (
            clk   => clk,
            rst   => rst,
            en    => pc_en_sig,
            d_in  => mux4x1_TO_pc,
            d_out => pc_out
        );
        
    pc_adder : entity WORK.adder(Behavioral)
        port map (
            a         => imm_sig,
            b         => pc_out,
            o_mode    => '0',
            s         => add_TO_mux4x1,
            carry_out => open,
            overflow  => open
        );
        
    pc_inc : entity WORK.adder(Behavioral)
        port map (
            a         => pc_out,
            b         => X"00000004",
            o_mode    => '0',
            s         => inc_out,
            carry_out => open,
            overflow  => open
        );

    mux4x1_pc : entity WORK.mux32_4x1(RTL)
        port map (
            selector => pcsrc_TO_mux4x1,
            d_in_a   => inc_out,
            d_in_b   => add_TO_mux4x1,
            d_in_c   => alu_result,
            d_in_d   => (others => '0'),
            d_out    => mux4x1_TO_pc
        );

    mux2x1_address : entity WORK.mux32_2x1(RTL)
        port map (
            selector => addrsrc_sig,
            d_in_a   => pc_out,
            d_in_b   => alu_result,
            d_out    => address_sig
        );
    address <= address_sig;

end Structural;
