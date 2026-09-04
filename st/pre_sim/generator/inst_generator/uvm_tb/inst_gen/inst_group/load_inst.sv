`define LOAD_INST(A,B,C,D,E,F,G,H,I,J,K)\
class ``A extends ri_type_inst;\
    addr_structure_s    ls_s;\
    parameter CONST_MASK =``D; \
    parameter CONST_VAL  =``E; \
    // new - constructor \
    function new (string name = ``B); \
        super.new(name); \
        `INST_GEN_NEW(``C,``G,CONST_MASK,CONST_VAL,``F,``H); \
    endfunction : new \
    `uvm_object_param_utils(``A) \
    function void ops_gen_cfg_rand(ref ops_gen_config   ops_gen_cfg); \
        `RANDOMIZE_CHECK_WITH_C(ops_gen_cfg,``I,"Error: load inst ops gen error")\
//        ops_gen_cfg.print();\
    endfunction \
    function bit[31:0] rand_ops_gen(ops_gen_config  ops_gen_cfg); \
        bit[31:0] val;  \
        bit[4:0] rs1,rd; \
        bit [11:0] imm; \
        bit [1:0]  near_addr_check; \
        rd = ``K; \
        ls_s.addr_type =``J; \
        if(ops_gen_cfg.ls_addr_misalign)begin \
            rs1 = `RAND_BASE_REG ; \
            ls_s = reg_pool.base_reg_gen.get_rand_reg_base_info(); \
            ls_s.addr_except = ADDR_MISALIGN; \
        end \
        else begin \
            rs1 = `RAND_LS_BASE_REG(ls_s); //get base reg num, base addr info \
        end \
        imm = ls_addr_gen.get_ls_imm(ls_s,ops_gen_cfg); \
        //$display("ls_imm = %0h",imm);\
        val = {imm[11:0],rs1,3'b0,rd,7'b0};\
        return val; \
    endfunction  \
   function bit [31:0] override_rand_inst(ref ops_gen_config ops_gen_cfg,ref bit[31:0] imm); //set imm not random,also can set sepcial ops_gen_cfg\
        bit[31:0] rand_ops; \
        bit imm_ok; \
        `RANDOMIZE_CHECK_WITH_C(ops_gen_cfg,``I,"Error: load inst ops gen error")\
        rand_ops = rand_ops_gen(ops_gen_cfg); \
        if(!ops_gen_cfg.ls_addr_misalign) \
        imm = imm- (ls_s.vaddr + imm)%ops_gen_cfg.align_bytes ;\
        // what if input imm miss in seg(seg extend) or illegal in seg \
        imm_ok = ls_addr_gen.ls_imm_fix(imm,ls_s);\
        if(!imm_ok) imm = ls_addr_gen.get_ls_imm(ls_s,ops_gen_cfg);\
        rand_ops[31:20] = imm; //override imm \
        inst = const_ops_mask & const_ops_val | ~const_ops_mask & rand_ops; \
        asm_print(); \
        return inst;\
    endfunction \
    function void asm_print(); \
        $fwrite(gen_file,(`LOAD_I_TYPE_ASM_STRING),`LOAD_I_TYPE_ASM_VAL);\
    endfunction \
endclass
`LOAD_INST(lb_gen, "lb_gen",  LB ,32'b0000000_00000_00000_111_00000_1111111 ,32'b0000000_00000_00000_000_00000_0000011,"lb" ,LSU,I_TYPE,ls_inst_unsigned == 0;ls_addr_misalign_en ==0; align_bytes == 1;rs1_eq_rd == 0;,LOAD_VALID, `RAND_RD_GPR)
`LOAD_INST(lh_gen, "lh_gen",  LH ,32'b0000000_00000_00000_111_00000_1111111 ,32'b0000000_00000_00000_001_00000_0000011,"lh" ,LSU,I_TYPE,ls_inst_unsigned == 0;ls_addr_misalign_en ==0; align_bytes == 2;rs1_eq_rd == 0;,LOAD_VALID, `RAND_RD_GPR)
`LOAD_INST(lw_gen, "lw_gen",  LW ,32'b0000000_00000_00000_111_00000_1111111 ,32'b0000000_00000_00000_010_00000_0000011,"lw" ,LSU,I_TYPE,ls_inst_unsigned == 0;ls_addr_misalign_en ==0; align_bytes == 4;rs1_eq_rd == 0;,LOAD_VALID, `RAND_RD_GPR)
`LOAD_INST(ld_gen, "ld_gen",  LD ,32'b0000000_00000_00000_111_00000_1111111 ,32'b0000000_00000_00000_011_00000_0000011,"ld" ,LSU,I_TYPE,ls_inst_unsigned == 0;ls_addr_misalign_en ==0; align_bytes == 8;rs1_eq_rd == 0;,LOAD_VALID, `RAND_RD_GPR)
`LOAD_INST(lbu_gen, "lbu_gen",  LBU ,32'b0000000_00000_00000_111_00000_1111111 ,32'b0000000_00000_00000_100_00000_0000011,"lbu" ,LSU,I_TYPE,ls_inst_unsigned == 1;ls_addr_misalign_en == 0; align_bytes == 1;rs1_eq_rd == 0;,LOAD_VALID, `RAND_RD_GPR)
`LOAD_INST(lhu_gen, "lhu_gen",  LHU ,32'b0000000_00000_00000_111_00000_1111111 ,32'b0000000_00000_00000_101_00000_0000011,"lhu" ,LSU,I_TYPE,ls_inst_unsigned == 1;ls_addr_misalign_en == 0; align_bytes == 2;rs1_eq_rd == 0;,LOAD_VALID, `RAND_RD_GPR)
`LOAD_INST(lwu_gen, "lwu_gen",  LWU ,32'b0000000_00000_00000_111_00000_1111111 ,32'b0000000_00000_00000_110_00000_0000011,"lwu" ,LSU,I_TYPE,ls_inst_unsigned == 1;ls_addr_misalign_en == 0; align_bytes == 4;rs1_eq_rd == 0;,LOAD_VALID, `RAND_RD_GPR)
`LOAD_INST(pref_i_gen, "pref_i_gen",  PREF_I ,32'b0000000_11111_00000_111_11111_1111111 ,32'b0000000_00000_00000_110_00000_0010011,"pref_i" ,LSU,I_TYPE,ls_addr_misalign_en == 0;align_bytes == 1; rs1_eq_rd == 0;,LOAD_VALID, `RAND_RD_GPR)
`LOAD_INST(pref_r_gen, "pref_r_gen",  PREF_R ,32'b0000000_11111_00000_111_11111_1111111 ,32'b0000000_00001_00000_110_00000_0010011,"pref_r" ,LSU,I_TYPE,ls_addr_misalign_en == 0;align_bytes == 1; rs1_eq_rd == 0;,LOAD_VALID, `RAND_RD_GPR)
`LOAD_INST(pref_w_gen, "pref_w_gen",  PREF_W ,32'b0000000_11111_00000_111_11111_1111111 ,32'b0000000_00011_00000_110_00000_0010011,"pref_w" ,LSU,I_TYPE,ls_addr_misalign_en == 0;align_bytes == 1; rs1_eq_rd == 0;,LOAD_VALID, `RAND_RD_GPR)

`LOAD_INST(invalid_lb_gen , "invalid_lb_gen",   INVALID_LB  ,32'b0000000_00000_00000_111_00000_1111111 ,32'b0000000_00000_00000_000_00000_0000011,"invalid_lb"  ,LSU,I_TYPE,ls_inst_unsigned == 0;ls_addr_misalign_en == 0; align_bytes == 1;,LOAD_INVALID, `RAND_RS_GPR)
`LOAD_INST(invalid_lh_gen , "invalid_lh_gen",   INVALID_LH  ,32'b0000000_00000_00000_111_00000_1111111 ,32'b0000000_00000_00000_001_00000_0000011,"invalid_lh"  ,LSU,I_TYPE,ls_inst_unsigned == 0;ls_addr_misalign_en == 1; align_bytes == 2;,LOAD_INVALID, `RAND_RS_GPR)
`LOAD_INST(invalid_lw_gen , "invalid_lw_gen",   INVALID_LW  ,32'b0000000_00000_00000_111_00000_1111111 ,32'b0000000_00000_00000_010_00000_0000011,"invalid_lw"  ,LSU,I_TYPE,ls_inst_unsigned == 0;ls_addr_misalign_en == 1; align_bytes == 4;,LOAD_INVALID, `RAND_RS_GPR)
`LOAD_INST(invalid_ld_gen , "invalid_ld_gen",   INVALID_LD  ,32'b0000000_00000_00000_111_00000_1111111 ,32'b0000000_00000_00000_011_00000_0000011,"invalid_ld"  ,LSU,I_TYPE,ls_inst_unsigned == 0;ls_addr_misalign_en == 1; align_bytes == 8;,LOAD_INVALID, `RAND_RS_GPR)
`LOAD_INST(invalid_lbu_gen, "invalid_lbu_gen",  INVALID_LBU ,32'b0000000_00000_00000_111_00000_1111111 ,32'b0000000_00000_00000_100_00000_0000011,"invalid_lbu" ,LSU,I_TYPE,ls_inst_unsigned == 1;ls_addr_misalign_en == 0; align_bytes == 1;,LOAD_INVALID, `RAND_RS_GPR)
`LOAD_INST(invalid_lhu_gen, "invalid_lhu_gen",  INVALID_LHU ,32'b0000000_00000_00000_111_00000_1111111 ,32'b0000000_00000_00000_101_00000_0000011,"invalid_lhu" ,LSU,I_TYPE,ls_inst_unsigned == 1;ls_addr_misalign_en == 1; align_bytes == 2;,LOAD_INVALID, `RAND_RS_GPR)
`LOAD_INST(invalid_lwu_gen, "invalid_lwu_gen",  INVALID_LWU ,32'b0000000_00000_00000_111_00000_1111111 ,32'b0000000_00000_00000_110_00000_0000011,"invalid_lwu" ,LSU,I_TYPE,ls_inst_unsigned == 1;ls_addr_misalign_en == 1; align_bytes == 4;,LOAD_INVALID, `RAND_RS_GPR)
`LOAD_INST(invalid_pref_i_gen, "invalid_pref_i_gen",  INVALID_PREF_I ,32'b0000000_11111_00000_111_11111_1111111 ,32'b0000000_00000_00000_110_00000_0010011,"invalid_pref_i" ,LSU,I_TYPE,ls_addr_misalign_en == 1;align_bytes == 1;,AMO_INVALID, `RAND_RS_GPR)
`LOAD_INST(invalid_pref_r_gen, "invalid_pref_r_gen",  INVALID_PREF_R ,32'b0000000_11111_00000_111_11111_1111111 ,32'b0000000_00001_00000_110_00000_0010011,"invalid_pref_r" ,LSU,I_TYPE,ls_addr_misalign_en == 1;align_bytes == 1;,AMO_INVALID, `RAND_RS_GPR)
`LOAD_INST(invalid_pref_w_gen, "invalid_pref_w_gen",  INVALID_PREF_W ,32'b0000000_11111_00000_111_11111_1111111 ,32'b0000000_00011_00000_110_00000_0010011,"invalid_pref_w" ,LSU,I_TYPE,ls_addr_misalign_en == 1;align_bytes == 1;,AMO_INVALID, `RAND_RS_GPR)
`LOAD_INST(flw_gen, "flw_gen",  FLW ,32'b0000000_00000_00000_111_00000_1111111 ,32'b0000000_00000_00000_010_00000_0000111,"flw" ,LSU,I_TYPE,ls_addr_misalign_en == 0 ; align_bytes == 4;, LOAD_VALID, `RAND_FPR)
`LOAD_INST(fld_gen, "fld_gen",  FLD ,32'b0000000_00000_00000_111_00000_1111111 ,32'b0000000_00000_00000_011_00000_0000111,"fld" ,LSU,I_TYPE,ls_addr_misalign_en == 0 ; align_bytes == 8;, LOAD_VALID, `RAND_FPR)
`LOAD_INST(invalid_flw_gen, "invalid_flw_gen",  INVALID_FLW ,32'b0000000_00000_00000_111_00000_1111111 ,32'b0000000_00000_00000_010_00000_0000111,"invalid_flw" ,LSU,I_TYPE, ls_addr_misalign_en == 1; align_bytes == 4;,LOAD_INVALID, `RAND_FPR)
`LOAD_INST(invalid_fld_gen, "invalid_fld_gen",  INVALID_FLD ,32'b0000000_00000_00000_111_00000_1111111 ,32'b0000000_00000_00000_011_00000_0000111,"invalid_fld" ,LSU,I_TYPE, ls_addr_misalign_en == 1; align_bytes == 8;,LOAD_INVALID, `RAND_FPR)

