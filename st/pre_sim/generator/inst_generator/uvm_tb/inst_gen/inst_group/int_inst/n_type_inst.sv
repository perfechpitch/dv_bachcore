`define N_TYPE_INST(A,B,C,D,E,F,G,H)\
class ``A extends base_inst;\ 
    parameter CONST_MASK =``D; \
    parameter CONST_VAL  =``E; \
    // new - constructor \
    function new (string name = ``B); \
        super.new(name); \
        `INST_GEN_NEW(``C,``G,CONST_MASK,CONST_VAL,``F,``H); \
    endfunction : new \
    `uvm_object_param_utils(``A) \
    function bit[31:0] get_rand_inst(ref ops_gen_config ops_gen_cfg); \
        inst = const_ops_mask & const_ops_val | ~const_ops_mask & 32'hffffffff; \
        asm_print(); \
        return inst; \
    endfunction \
    function void asm_print(); \
        $fwrite(gen_file,`N_TYPE_ASM_STRING,`N_TYPE_ASM_VAL);\
    endfunction \
endclass
`N_TYPE_INST(ebreak_gen, "ebreak_gen",  EBREAK ,32'b1111111_11111_11111_111_11111_1111111 ,32'b0000000_00001_00000_000_00000_1110011,"ebreak" ,ALU,N_TYPE)
`N_TYPE_INST(ecall_gen, "ecall_gen",  ECALL ,32'b1111111_11111_11111_111_11111_1111111 ,32'b0000000_00000_00000_000_00000_1110011,"ecall" ,ALU,N_TYPE)
`N_TYPE_INST(sret_gen, "sret_gen",  SRET ,32'b1111111_11111_11111_111_11111_1111111 ,32'b0001000_00010_00000_000_00000_1110011,"sret" ,ALU,N_TYPE)
`N_TYPE_INST(mret_gen, "mret_gen",  MRET ,32'b1111111_11111_11111_111_11111_1111111 ,32'b0011000_00010_00000_000_00000_1110011,"mret" ,ALU,N_TYPE)
`N_TYPE_INST(dret_gen, "dret_gen",  DRET ,32'b1111111_11111_11111_111_11111_1111111 ,32'b0111101_10010_00000_000_00000_1110011,"dret" ,ALU,N_TYPE)
`N_TYPE_INST(wfi_gen, "wfi_gen",  WFI ,32'b1111111_11111_11111_111_11111_1111111 ,32'b0001000_00101_00000_000_00000_1110011,"wfi" ,ALU,N_TYPE)
`N_TYPE_INST(fencei_gen, "fencei_gen",  FENCEI ,32'b0000000_00000_00000_111_00000_1111111 ,32'b0000000_00000_00000_001_00000_0001111,"fencei" ,ALU,N_TYPE)
`N_TYPE_INST(fence_gen, "fence_gen",  FENCE ,32'b0000000_00000_00000_111_00000_1111111 ,32'b0000000_00000_00000_000_00000_0001111,"fence" ,ALU,N_TYPE)
