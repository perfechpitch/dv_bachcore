
`define JAL_CONST_MASK 32'b0000000_00000_00000_000_00000_1111111
`define JAL_CONST_VAL  32'b0000000_00000_00000_000_00000_1101111

class riscv_jal extends riscv_inst;

    function new(string name = "riscv_jal");
        super.new(name);
        `INST_NEW("jal", RV32I, BEU, `JAL_CONST_MASK, `JAL_CONST_VAL)
    endfunction : new

    `uvm_object_param_utils(riscv_jal)

    function void inst_exe(`INST_EXE_PARAS);
        `GPR(`JTYPE_RD) = core_state.pc + 4;
        core_state.pc = core_state.pc + `JTYPE_IMM_SIGN_EXTEND32;

        if(log_en)
            $fwrite(inst_exe_log, (`J_TYPE_EXE_STRING), `J_TYPE_EXE_VAL);
    endfunction : inst_exe

endclass : riscv_jal

`define JALR_CONST_MASK 32'b0000000_00000_00000_111_00000_1111111
`define JALR_CONST_VAL  32'b0000000_00000_00000_000_00000_1100111

class riscv_jalr extends riscv_inst;

    function new(string name = "riscv_jalr");
        super.new(name);
        `INST_NEW("jalr", RV32I, BEU, `JALR_CONST_MASK, `JALR_CONST_VAL)
    endfunction : new

    `uvm_object_param_utils(riscv_jalr)

    function void inst_exe(`INST_EXE_PARAS);
        bit [31:0] rs1_data;

        rs1_data = `GPR(`ITYPE_RS1);
        `GPR(`ITYPE_RD) = core_state.pc + 4;
        core_state.pc = (rs1_data + `ITYPE_IMM_SIGN_EXTEND32) & 32'hffff_fffe;

        if(log_en)
            $fwrite(inst_exe_log, (`I_TYPE_EXE_STRING),
                    inst_name,
                    `ITYPE_RD, `GPR(`ITYPE_RD),
                    `ITYPE_IMM_SIGN_EXTEND32,
                    `ITYPE_RS1, rs1_data);
    endfunction : inst_exe

endclass : riscv_jalr
