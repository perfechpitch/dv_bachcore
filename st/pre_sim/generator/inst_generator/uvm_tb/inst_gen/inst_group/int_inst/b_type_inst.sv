class b_type_inst extends base_inst;
    `uvm_object_param_utils(b_type_inst)
    function new (string name = "b_type_inst");
        super.new(name);
    endfunction : new 
    function bit[31:0] rand_ops_gen(ops_gen_config  ops_gen_cfg);
        bit[31:0] val; 
        bit[4:0]rs1,rs2;
        bit[11:0] rand_imm;
        rs1= `RAND_RS_GPR; 
        if(ops_gen_cfg.rs1_eq_rs2) rs2=rs1; 
        else  rs2 = `RAND_RS_GPR; 
        rand_imm = (ops_gen_cfg.rand_imm >> 1); 
        val = {rand_imm[11],rand_imm[9:4],rs2,rs1,3'b0,rand_imm[3:0],rand_imm[10],7'b0};
        return val; 
    endfunction 
    function bit [31:0] override_rand_inst(ref ops_gen_config ops_gen_cfg,ref bit[31:0] imm);
        bit[31:0] rand_ops;
        `RANDOMIZE_CHECK_WITH_C(ops_gen_cfg,rand_imm == imm;,"Error: branch override inst ops gen error")
        rand_ops = rand_ops_gen(ops_gen_cfg);
        inst = const_ops_mask & const_ops_val | ~const_ops_mask & rand_ops;
        asm_print(); 
        return inst;
    endfunction 
endclass 

`define BRANCH_INST(A,B,C,D,E,F,G,H,I)\
class ``A extends b_type_inst;\        
    parameter CONST_MASK =``D; \
    parameter CONST_VAL  =``E; \
    // new - constructor \
    function new (string name = ``B); \
        super.new(name); \
        `INST_GEN_NEW(``C,``G,CONST_MASK,CONST_VAL,``F,``H); \
    endfunction : new \
    `uvm_object_param_utils(``A) \
    function void ops_gen_cfg_rand(ref ops_gen_config   ops_gen_cfg); \
        `RANDOMIZE_CHECK_WITH_C(ops_gen_cfg,``I;,"Error: branch inst ops gen error")\
    endfunction \
    function void asm_print(); \
        $fwrite(gen_file,(`B_TYPE_ASM_STRING),`B_TYPE_ASM_VAL);\
    endfunction \
endclass 
`BRANCH_INST(beq_gen, "beq_gen", BEQ,32'b0000000_00000_00000_111_00000_1111111,32'b0000000_00000_00000_000_00000_1100011, "beq", ALU, B_TYPE,rand_imm == 4)
`BRANCH_INST(bne_gen, "bne_gen", BNE,32'b0000000_00000_00000_111_00000_1111111,32'b0000000_00000_00000_001_00000_1100011, "bne", ALU, B_TYPE,((rand_imm >>2 == 1 )|| rs1_eq_rs2==1))
`BRANCH_INST(bge_gen, "bge_gen", BGE,32'b0000000_00000_00000_111_00000_1111111,32'b0000000_00000_00000_101_00000_1100011, "bge", ALU, B_TYPE,rand_imm == 4)
`BRANCH_INST(blt_gen, "blt_gen", BLT,32'b0000000_00000_00000_111_00000_1111111,32'b0000000_00000_00000_100_00000_1100011, "blt", ALU, B_TYPE,rand_imm == 4)
`BRANCH_INST(bltu_gen, "bltu_gen", BLTU,32'b0000000_00000_00000_111_00000_1111111,32'b0000000_00000_00000_110_00000_1100011, "bltu", ALU, B_TYPE,rand_imm == 4)
`BRANCH_INST(bgeu_gen, "bgeu_gen", BGEU,32'b0000000_00000_00000_111_00000_1111111,32'b0000000_00000_00000_111_00000_1100011, "bgeu", ALU, B_TYPE,rand_imm == 4)


//add misalign branch with branch imm[1:0] = 1/2/3 but not 4
`BRANCH_INST(misalign_beq_gen , "misalign_beq_gen" , MISALIGN_BEQ ,32'b0000000_00000_00000_111_00000_1111111,32'b0000000_00000_00000_000_00000_1100011, "misalign_beq" , ALU, B_TYPE,rand_imm[1:0] !=0)
`BRANCH_INST(misalign_bne_gen , "misalign_bne_gen" , MISALIGN_BNE ,32'b0000000_00000_00000_111_00000_1111111,32'b0000000_00000_00000_001_00000_1100011, "misalign_bne" , ALU, B_TYPE,rand_imm[1:0] !=0)
`BRANCH_INST(misalign_bge_gen , "misalign_bge_gen" , MISALIGN_BGE ,32'b0000000_00000_00000_111_00000_1111111,32'b0000000_00000_00000_101_00000_1100011, "misalign_bge" , ALU, B_TYPE,rand_imm[1:0] !=0)
`BRANCH_INST(misalign_blt_gen , "misalign_blt_gen" , MISALIGN_BLT ,32'b0000000_00000_00000_111_00000_1111111,32'b0000000_00000_00000_100_00000_1100011, "misalign_blt" , ALU, B_TYPE,rand_imm[1:0] !=0)
`BRANCH_INST(misalign_bltu_gen, "misalign_bltu_gen", MISALIGN_BLTU,32'b0000000_00000_00000_111_00000_1111111,32'b0000000_00000_00000_110_00000_1100011, "misalign_bltu", ALU, B_TYPE,rand_imm[1:0] !=0)
`BRANCH_INST(misalign_bgeu_gen, "misalign_bgeu_gen", MISALIGN_BGEU,32'b0000000_00000_00000_111_00000_1111111,32'b0000000_00000_00000_111_00000_1100011, "misalign_bgeu", ALU, B_TYPE,rand_imm[1:0] !=0)
