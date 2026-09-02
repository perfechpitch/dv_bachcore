`define RR_SHIFT_INST(A,B,C,D,E,F) \
class ``A extends riscv_inst; \
    parameter CONST_MASK = ``D; \
    parameter CONST_VAL  = ``E; \
    function new(string name = ``B); \
        super.new(name); \
        `INST_NEW(``C, RV32I, ALU, CONST_MASK, CONST_VAL) \
    endfunction : new \
    `uvm_object_param_utils(``A) \
    function void inst_exe(`INST_EXE_PARAS); \
        int rs1_val,rs2_val; \
        rs1_val = `GPR(`RTYPE_RS1) ;rs2_val= `GPR(`RTYPE_RS2);\
        `GPR(`RTYPE_RD) = `GPR(`RTYPE_RS1) ``F `GPR(`RTYPE_RS2)[4:0]; \
        `PC_ADD \
        if(log_en) \
            $fwrite(inst_exe_log, (`R_TYPE_EXE_STRING), `R_TYPE_EXE_VAL); \
    endfunction : inst_exe \
endclass

`RR_SHIFT_INST(riscv_sll, "riscv_sll", "sll", 32'b1111111_00000_00000_111_00000_1111111, 32'b0000000_00000_00000_001_00000_0110011, <<)
`RR_SHIFT_INST(riscv_srl, "riscv_srl", "srl", 32'b1111111_00000_00000_111_00000_1111111, 32'b0000000_00000_00000_101_00000_0110011, >>)

`define RR_ARITHMETIC_SHIFT_INST(A,B,C,D,E,F) \
class ``A extends riscv_inst; \
    parameter CONST_MASK = ``D; \
    parameter CONST_VAL  = ``E; \
    function new(string name = ``B); \
        super.new(name); \
        `INST_NEW(``C, RV32I, ALU, CONST_MASK, CONST_VAL) \
    endfunction : new \
    `uvm_object_param_utils(``A) \
    function void inst_exe(`INST_EXE_PARAS); \
        int rs1_val,rs2_val; \
        rs1_val = `GPR(`RTYPE_RS1) ;rs2_val= `GPR(`RTYPE_RS2);\
        `GPR(`RTYPE_RD) = $signed(`GPR(`RTYPE_RS1)) ``F `GPR(`RTYPE_RS2)[4:0]; \
        `PC_ADD \
        if(log_en) \
            $fwrite(inst_exe_log, (`R_TYPE_EXE_STRING), `R_TYPE_EXE_VAL); \
    endfunction : inst_exe \
endclass

`RR_ARITHMETIC_SHIFT_INST(riscv_sra, "riscv_sra", "sra", 32'b1111111_00000_00000_111_00000_1111111, 32'b0100000_00000_00000_101_00000_0110011, >>>)

`define R_IMM_SHIFT_INST(A,B,C,D,E,F) \
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
        rs1_val = `GPR(`RTYPE_RS1);\
        `GPR(`ITYPE_RD) = `GPR(`ITYPE_RS1) ``F `ITYPE_SHAMT; \
        `PC_ADD \
        if(log_en) \
            $fwrite(inst_exe_log, (`I_TYPE_IMM_SHIFT_EXE_STRING), `I_TYPE_IMM_SHIFT_EXE_VAL); \
    endfunction : inst_exe \
endclass

`R_IMM_SHIFT_INST(riscv_slli, "riscv_slli", "slli", 32'b1111111_00000_00000_111_00000_1111111, 32'b0000000_00000_00000_001_00000_0010011, <<)
`R_IMM_SHIFT_INST(riscv_srli, "riscv_srli", "srli", 32'b1111111_00000_00000_111_00000_1111111, 32'b0000000_00000_00000_101_00000_0010011, >>)

`define R_IMM_ARITHMETIC_SHIFT_INST(A,B,C,D,E,F) \
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
        rs1_val = `GPR(`RTYPE_RS1);\
        `GPR(`ITYPE_RD) = $signed(`GPR(`ITYPE_RS1)) ``F `ITYPE_SHAMT; \
        `PC_ADD \
        if(log_en) \
            $fwrite(inst_exe_log, (`I_TYPE_IMM_SHIFT_EXE_STRING), `I_TYPE_IMM_SHIFT_EXE_VAL); \
    endfunction : inst_exe \
endclass

`R_IMM_ARITHMETIC_SHIFT_INST(riscv_srai, "riscv_srai", "srai", 32'b1111111_00000_00000_111_00000_1111111, 32'b0100000_00000_00000_101_00000_0010011, >>>)