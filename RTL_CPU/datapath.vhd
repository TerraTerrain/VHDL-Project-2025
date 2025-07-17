library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use WORK.defs_pack.ALL;

entity datapath is
    port(
        clk, rst           : in  bit;
        mem_data, imm      : in  DataType;
        inc_pc, pc         : in  AddrType;
        alu_src1, alu_src2 : in  bit;
        func3              : in  Func3Type;
        func7              : in  Func7Type;
        branch             : out bit;
        reg_src            : in  bit_vector(1 downto 0);
        rd, rs1, rs2       : in  RegAddrType;
        reg_en             : in  bit;
        alu_result         : out DataType;
        reg_data2          : out DataType
    );
end datapath;

architecture Structural of datapath is
    signal mux4x1_TO_rfin, r_data1_TO_mux2x1, r_data2_TO_mux2x1, 
           mux2x1_TO_alu1, mux2x1_TO_alu2, alu_result_sig :
           DataType := (others => '0');
    signal branch_sig : bit := '0';
begin
    reg_block : entity WORK.reg_file(Behavioral)
        port map (
            clk => clk,
            rst => rst,
            we  => reg_en,
            w_addr  => rd,
            w_data  => mux4x1_TO_rfin,
            r_addr1 => rs1,
            r_addr2 => rs2,
            r_data1 => r_data1_TO_mux2x1,
            r_data2 => r_data2_TO_mux2x1
        );
    reg_data2 <= r_data2_TO_mux2x1;
        
    mux2x1_alu1 : entity WORK.mux32_2x1(RTL)
        port map (
            selector => alu_src1,
            d_in_a   => r_data1_TO_mux2x1,
            d_in_b   => pc,
            d_out    => mux2x1_TO_alu1
        );
        
    mux2x1_alu2 : entity WORK.mux32_2x1(RTL)
        port map (
            selector => alu_src2,
            d_in_a   => r_data2_TO_mux2x1,
            d_in_b   => imm,
            d_out    => mux2x1_TO_alu2
        );
                
    alu_block : entity WORK.alu(Behavioral)
        port map (
            operand1 => mux2x1_TO_alu1,
            operand2 => mux2x1_TO_alu2,
            func3    => func3,
            func7    => func7,
            result   => alu_result_sig,
            branch   => branch_sig
        );
    alu_result <= alu_result_sig;
    branch     <= branch_sig;
    
    mux4x1_reg : entity WORK.mux32_4x1(RTL)
        port map (
            selector => reg_src,
            d_in_a   => alu_result_sig,
            d_in_b   => mem_data,
            d_in_c   => inc_pc,
            d_in_d   => (others => '0'),
            d_out    => mux4x1_TO_rfin
        );

end Structural;
