`define RR_ARITHMETIC_INST(A,B,C,D,E,F) \
class ``A extends riscv_inst; \
    parameter CONST_MASK = ``D; \
    parameter CONST_VAL  = ``E; \
    function new(string name = ``B); \
        super.new(name); \
        `INST_NEW(``C, RV32I, ALU, CONST_MASK, CONST_VAL) \
    endfunction : new \
    `uvm_object_param_utils(``A) \
    function void inst_exe(`INST_EXE_PARAS); \
        int rs1_val, rs2_val; \
        rs1_val = `GPR(`RTYPE_RS1); rs2_val = `GPR(`RTYPE_RS2); \
        `GPR(`RTYPE_RD) = `GPR(`RTYPE_RS1) ``F `GPR(`RTYPE_RS2); \
        `PC_ADD \
        if(log_en) \
            $fwrite(inst_exe_log, (`R_TYPE_EXE_STRING), `R_TYPE_EXE_VAL); \
    endfunction : inst_exe \
endclass

`RR_ARITHMETIC_INST(riscv_add, "riscv_add", "add",
                    32'b1111111_00000_00000_111_00000_1111111,
                    32'b0000000_00000_00000_000_00000_0110011, +)

`RR_ARITHMETIC_INST(riscv_and, "riscv_and", "and",
                    32'b1111111_00000_00000_111_00000_1111111,
                    32'b0000000_00000_00000_111_00000_0110011, &)

`RR_ARITHMETIC_INST(riscv_sub, "riscv_sub", "sub",
                    32'b1111111_00000_00000_111_00000_1111111,
                    32'b0100000_00000_00000_000_00000_0110011, -)

`RR_ARITHMETIC_INST(riscv_xor, "riscv_xor", "xor",
                    32'b1111111_00000_00000_111_00000_1111111,
                    32'b0000000_00000_00000_100_00000_0110011, ^)

`RR_ARITHMETIC_INST(riscv_or, "riscv_or", "or",
                    32'b1111111_00000_00000_111_00000_1111111,
                    32'b0000000_00000_00000_110_00000_0110011, |)

`define R_IMM_ARITHMETIC_INST(A,B,C,D,E,F) \
class ``A extends riscv_inst; \
    parameter CONST_MASK = ``D; \
    parameter CONST_VAL  = ``E; \
    function new(string name = ``B); \
        super.new(name); \
        `INST_NEW(``C, RV32I, ALU, CONST_MASK, CONST_VAL) \
    endfunction : new \
    `uvm_object_param_utils(``A) \
    function void inst_exe(`INST_EXE_PARAS); \
        int rs1_val; \
        rs1_val = `GPR(`ITYPE_RS1); \
        `GPR(`ITYPE_RD) = `GPR(`ITYPE_RS1) ``F `ITYPE_IMM_SIGN_EXTEND32; \
        `PC_ADD \
        if(log_en) \
            $fwrite(inst_exe_log, (`I_TYPE_EXE_STRING), `I_TYPE_EXE_VAL); \
    endfunction : inst_exe \
endclass

`R_IMM_ARITHMETIC_INST(riscv_addi, "riscv_addi", "addi",
                       32'b0000000_00000_00000_111_00000_1111111,
                       32'b0000000_00000_00000_000_00000_0010011, +)

`R_IMM_ARITHMETIC_INST(riscv_andi, "riscv_andi", "andi",
                       32'b0000000_00000_00000_111_00000_1111111,
                       32'b0000000_00000_00000_111_00000_0010011, &)

`R_IMM_ARITHMETIC_INST(riscv_ori, "riscv_ori", "ori",
                       32'b0000000_00000_00000_111_00000_1111111,
                       32'b0000000_00000_00000_110_00000_0010011, |)

`R_IMM_ARITHMETIC_INST(riscv_xori, "riscv_xori", "xori",
                       32'b0000000_00000_00000_111_00000_1111111,
                       32'b0000000_00000_00000_100_00000_0010011, ^)