

`define STORE_INST_GEN(A,B,C,D,E,F) \
class ``A extends riscv_inst; \
    parameter CONST_MASK = ``D; \
    parameter CONST_VAL  = ``E; \
    function new(string name = ``B); \
        super.new(name); \
        `INST_NEW(``C, RV32I, LSU, CONST_MASK, CONST_VAL) \
    endfunction : new \
    `uvm_object_param_utils(``A) \
    function void inst_exe(`INST_EXE_PARAS); \
        bit [31:0] wdata; \
        addr_state_s addr_state; \
        int rs1_val,rs2_val;\
        rs1_val = `GPR(`STYPE_RS1); \
        wdata = `GPR(`STYPE_RS2); rs2_val = wdata;\
        addr_state.addr = `GPR(`STYPE_RS1) + `STYPE_IMM_SIGN_EXTEND32; \
        addr_state.acc_type = STORE; \
        addr_state.size = ``F; \
        mem_lib.write_mem(wdata, core_state, addr_state); \
        if(core_state.except == NONE_EXCEPT) \
            `PC_ADD \
        if(log_en) \
            $fwrite(inst_exe_log, (`S_TYPE_EXE_STRING), `S_TYPE_EXE_VAL); \
    endfunction : inst_exe \
endclass

`STORE_INST_GEN(riscv_sb, "riscv_sb", "sb", 32'b0000000_00000_00000_111_00000_1111111, 32'b0000000_00000_00000_000_00000_0100011, 2'd0)
`STORE_INST_GEN(riscv_sh, "riscv_sh", "sh", 32'b0000000_00000_00000_111_00000_1111111, 32'b0000000_00000_00000_001_00000_0100011, 2'd1)
`STORE_INST_GEN(riscv_sw, "riscv_sw", "sw", 32'b0000000_00000_00000_111_00000_1111111, 32'b0000000_00000_00000_010_00000_0100011, 2'd2)