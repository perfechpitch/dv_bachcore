`define LUI_CONST_MASK 32'b0000000_00000_00000_000_00000_1111111
`define LUI_CONST_VAL  32'b0000000_00000_00000_000_00000_0110111

class riscv_lui extends riscv_inst;

    function new(string name = "riscv_lui");
        super.new(name);
        `INST_NEW("lui", RV32I, ALU, `LUI_CONST_MASK, `LUI_CONST_VAL)
    endfunction : new

    `uvm_object_param_utils(riscv_lui)

    function void inst_exe(`INST_EXE_PARAS);
        `GPR(`UTYPE_RD) = `UTYPE_IMM;
        `PC_ADD

        if(log_en)
            $fwrite(inst_exe_log, (`U_TYPE_EXE_STRING), `U_TYPE_EXE_VAL);
    endfunction : inst_exe

endclass : riscv_lui

`define SLT_CONST_MASK 32'b1111111_00000_00000_111_00000_1111111
`define SLT_CONST_VAL  32'b0000000_00000_00000_010_00000_0110011

class riscv_slt extends riscv_inst;

    function new(string name = "riscv_slt");
        super.new(name);
        `INST_NEW("slt", RV32I, ALU, `SLT_CONST_MASK, `SLT_CONST_VAL)
    endfunction : new

    `uvm_object_param_utils(riscv_slt)

    function void inst_exe(`INST_EXE_PARAS);
        int rs1_val,rs2_val;
        rs1_val = `GPR(`RTYPE_RS1);
        rs2_val = `GPR(`RTYPE_RS2);
        `GPR(`RTYPE_RD) = $signed(`GPR(`RTYPE_RS1)) < $signed(`GPR(`RTYPE_RS2));
        `PC_ADD

        if(log_en)
            $fwrite(inst_exe_log, (`R_TYPE_EXE_STRING), `R_TYPE_EXE_VAL);
    endfunction : inst_exe

endclass : riscv_slt

`define SLTU_CONST_MASK 32'b1111111_00000_00000_111_00000_1111111
`define SLTU_CONST_VAL  32'b0000000_00000_00000_011_00000_0110011

class riscv_sltu extends riscv_inst;

    function new(string name = "riscv_sltu");
        super.new(name);
        `INST_NEW("sltu", RV32I, ALU, `SLTU_CONST_MASK, `SLTU_CONST_VAL)
    endfunction : new

    `uvm_object_param_utils(riscv_sltu)

    function void inst_exe(`INST_EXE_PARAS);
        int rs1_val,rs2_val;
        rs1_val = `GPR(`RTYPE_RS1);
        rs2_val = `GPR(`RTYPE_RS2);
        `GPR(`RTYPE_RD) = `GPR(`RTYPE_RS1) < `GPR(`RTYPE_RS2);
        `PC_ADD

        if(log_en)
            $fwrite(inst_exe_log, (`R_TYPE_EXE_STRING), `R_TYPE_EXE_VAL);
    endfunction : inst_exe

endclass : riscv_sltu

`define SLTI_CONST_MASK 32'b0000000_00000_00000_111_00000_1111111
`define SLTI_CONST_VAL  32'b0000000_00000_00000_010_00000_0010011

class riscv_slti extends riscv_inst;

    function new(string name = "riscv_slti");
        super.new(name);
        `INST_NEW("slti", RV32I, ALU, `SLTI_CONST_MASK, `SLTI_CONST_VAL)
    endfunction : new

    `uvm_object_param_utils(riscv_slti)

    function void inst_exe(`INST_EXE_PARAS);
        int rs1_val;
        rs1_val =`GPR(`ITYPE_RS1);
        `GPR(`ITYPE_RD) = $signed(`GPR(`ITYPE_RS1)) < $signed(`ITYPE_IMM_SIGN_EXTEND32);
        `PC_ADD

        if(log_en)
            $fwrite(inst_exe_log, (`I_TYPE_EXE_STRING), `I_TYPE_EXE_VAL);
    endfunction : inst_exe

endclass : riscv_slti

`define SLTIU_CONST_MASK 32'b0000000_00000_00000_111_00000_1111111
`define SLTIU_CONST_VAL  32'b0000000_00000_00000_011_00000_0010011

class riscv_sltiu extends riscv_inst;

    function new(string name = "riscv_sltiu");
        super.new(name);
        `INST_NEW("sltiu", RV32I, ALU, `SLTIU_CONST_MASK, `SLTIU_CONST_VAL)
    endfunction : new

    `uvm_object_param_utils(riscv_sltiu)

    function void inst_exe(`INST_EXE_PARAS);
        int rs1_val;
        rs1_val =`GPR(`ITYPE_RS1);
        `GPR(`ITYPE_RD) = `GPR(`ITYPE_RS1) < $unsigned(`ITYPE_IMM_SIGN_EXTEND32);
        `PC_ADD

        if(log_en)
            $fwrite(inst_exe_log, (`I_TYPE_EXE_STRING), `I_TYPE_EXE_VAL);
    endfunction : inst_exe

endclass : riscv_sltiu

`define FENCE_CONST_MASK 32'b0000000_00000_00000_111_00000_1111111
`define FENCE_CONST_VAL  32'b0000000_00000_00000_000_00000_0001111

class riscv_fence extends riscv_inst;

    function new(string name = "riscv_fence");
        super.new(name);
        `INST_NEW("fence", RV32I, ROB, `FENCE_CONST_MASK, `FENCE_CONST_VAL)
    endfunction : new

    `uvm_object_param_utils(riscv_fence)

    function void inst_exe(`INST_EXE_PARAS);
        mem_lib.fence_exe();
        `PC_ADD

        if(log_en)
            $fwrite(inst_exe_log, (`NO_OPS_INST_EXE_STRING));
    endfunction : inst_exe

endclass : riscv_fence

`define ECALL_CONST_MASK 32'b1111111_11111_11111_111_11111_1111111
`define ECALL_CONST_VAL  32'b0000000_00000_00000_000_00000_1110011

class riscv_ecall extends riscv_inst;

    function new(string name = "riscv_ecall");
        super.new(name);
        `INST_NEW("ecall", RV32I, ROB, `ECALL_CONST_MASK, `ECALL_CONST_VAL)
    endfunction : new

    `uvm_object_param_utils(riscv_ecall)

    function void inst_exe(`INST_EXE_PARAS);
        core_state.except = M_ECALL;

        if(log_en)
            $fwrite(inst_exe_log, (`NO_OPS_INST_EXE_STRING));
    endfunction : inst_exe

endclass : riscv_ecall

`define EBREAK_CONST_MASK 32'b1111111_11111_11111_111_11111_1111111
`define EBREAK_CONST_VAL  32'b0000000_00001_00000_000_00000_1110011

class riscv_ebreak extends riscv_inst;

    function new(string name = "riscv_ebreak");
        super.new(name);
        `INST_NEW("ebreak", RV32I, ROB, `EBREAK_CONST_MASK, `EBREAK_CONST_VAL)
    endfunction : new

    `uvm_object_param_utils(riscv_ebreak)

    function void inst_exe(`INST_EXE_PARAS);
        core_state.except = BREAKPOINT;

        if(log_en)
            $fwrite(inst_exe_log, (`NO_OPS_INST_EXE_STRING));
    endfunction : inst_exe

endclass : riscv_ebreak