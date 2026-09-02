`define CONDITION_BRANCH_INST(A,B,C,D,E,F) \
class ``A extends riscv_inst; \
    parameter CONST_MASK = ``D; \
    parameter CONST_VAL  = ``E; \
    function new(string name = ``B); \
        super.new(name); \
        `INST_NEW(``C, RV32I, BEU, CONST_MASK, CONST_VAL) \
    endfunction : new \
    `uvm_object_param_utils(``A) \
    function void inst_exe(`INST_EXE_PARAS); \
        if(`GPR(`BTYPE_RS1) ``F `GPR(`BTYPE_RS2)) \
            core_state.pc = core_state.pc + `BTYPE_IMM_SIGN_EXTEND32; \
        else \
            `PC_ADD \
        if(log_en) \
            $fwrite(inst_exe_log, (`B_TYPE_EXE_STRING), `B_TYPE_EXE_VAL); \
    endfunction : inst_exe \
endclass

`CONDITION_BRANCH_INST(
    riscv_beq,
    "riscv_beq",
    "beq",
    32'b0000000_00000_00000_111_00000_1111111,
    32'b0000000_00000_00000_000_00000_1100011,
    ==
)

`CONDITION_BRANCH_INST(
    riscv_bne,
    "riscv_bne",
    "bne",
    32'b0000000_00000_00000_111_00000_1111111,
    32'b0000000_00000_00000_001_00000_1100011,
    !=
)

`define SIGNED_CMP_CONDITION_BRANCH_INST(A,B,C,D,E,F) \
class ``A extends riscv_inst; \
    parameter CONST_MASK = ``D; \
    parameter CONST_VAL  = ``E; \
    function new(string name = ``B); \
        super.new(name); \
        `INST_NEW(``C, RV32I, BEU, CONST_MASK, CONST_VAL) \
    endfunction : new \
    `uvm_object_param_utils(``A) \
    function void inst_exe(`INST_EXE_PARAS); \
        if($signed(`GPR(`BTYPE_RS1)) ``F $signed(`GPR(`BTYPE_RS2))) \
            core_state.pc = core_state.pc + `BTYPE_IMM_SIGN_EXTEND32; \
        else \
            `PC_ADD \
        if(log_en) \
            $fwrite(inst_exe_log, (`B_TYPE_EXE_STRING), `B_TYPE_EXE_VAL); \
    endfunction : inst_exe \
endclass

`SIGNED_CMP_CONDITION_BRANCH_INST(
    riscv_bge,
    "riscv_bge",
    "bge",
    32'b0000000_00000_00000_111_00000_1111111,
    32'b0000000_00000_00000_101_00000_1100011,
    >=
)

`SIGNED_CMP_CONDITION_BRANCH_INST(
    riscv_blt,
    "riscv_blt",
    "blt",
    32'b0000000_00000_00000_111_00000_1111111,
    32'b0000000_00000_00000_100_00000_1100011,
    <
)

`define UNSIGNED_CMP_CONDITION_BRANCH_INST(A,B,C,D,E,F) \
class ``A extends riscv_inst; \
    parameter CONST_MASK = ``D; \
    parameter CONST_VAL  = ``E; \
    function new(string name = ``B); \
        super.new(name); \
        `INST_NEW(``C, RV32I, BEU, CONST_MASK, CONST_VAL) \
    endfunction : new \
    `uvm_object_param_utils(``A) \
    function void inst_exe(`INST_EXE_PARAS); \
        if(`GPR(`BTYPE_RS1) ``F `GPR(`BTYPE_RS2)) \
            core_state.pc = core_state.pc + `BTYPE_IMM_SIGN_EXTEND32; \
        else \
            `PC_ADD \
        if(log_en) \
            $fwrite(inst_exe_log, (`B_TYPE_EXE_STRING), `B_TYPE_EXE_VAL); \
    endfunction : inst_exe \
endclass

`UNSIGNED_CMP_CONDITION_BRANCH_INST(
    riscv_bgeu,
    "riscv_bgeu",
    "bgeu",
    32'b0000000_00000_00000_111_00000_1111111,
    32'b0000000_00000_00000_111_00000_1100011,
    >=
)

`UNSIGNED_CMP_CONDITION_BRANCH_INST(
    riscv_bltu,
    "riscv_bltu",
    "bltu",
    32'b0000000_00000_00000_111_00000_1111111,
    32'b0000000_00000_00000_110_00000_1100011,
    <
)