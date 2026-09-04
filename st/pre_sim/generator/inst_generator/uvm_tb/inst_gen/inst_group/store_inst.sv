//class s_type_inst extends base_inst;
//    `uvm_object_param_utils(s_type_inst) 
//    function new (string name = "s_type_inst"); 
//        super.new(name); 
//    endfunction : new 
//    function void asm_print(); 
//        $fwrite(gen_file,(`S_TYPE_ASM_STRING),`S_TYPE_ASM_VAL);
//    endfunction 
//endclass

`define STORE_INST(A,B,C,D,E,F,G,H,I,J,K)\
class ``A extends base_inst;\        
    parameter CONST_MASK =``D; \
    parameter CONST_VAL  =``E; \
    addr_structure_s ls_s; \
    // new - constructor \
    function new (string name = ``B); \
        super.new(name); \
        `INST_GEN_NEW(``C,``G,CONST_MASK,CONST_VAL,``F,``H); \
    endfunction : new \
    `uvm_object_param_utils(``A) \
    function void ops_gen_cfg_rand(ref ops_gen_config   ops_gen_cfg); \
        `RANDOMIZE_CHECK_WITH_C(ops_gen_cfg,``I,"Error: store inst ops gen error")\
        //ops_gen_cfg.print();\
    endfunction \
    function bit[31:0] rand_ops_gen(ops_gen_config  ops_gen_cfg); \
        bit[31:0] val; \
        bit[11:0] imm;\
        bit[4:0] rs2,rs1;  \
        bit[1:0] near_addr_check; \
        ls_s.addr_type =``J; \
        if(ops_gen_cfg.ls_addr_misalign)begin \
            rs1 = `RAND_BASE_REG ; \
            ls_s = reg_pool.base_reg_gen.get_rand_reg_base_info(); \
            ls_s.addr_except = ADDR_MISALIGN;\
        end \
        else begin \
            rs1 = `RAND_LS_BASE_REG(ls_s); //get base reg num, base addr info \
        end \
        if(ops_gen_cfg.rs1_eq_rs2) rs2 = rs1; \
        else rs2 = ``K;  \
        \
        imm = ls_addr_gen.get_ls_imm(ls_s,ops_gen_cfg); \
        val = {imm[11:5],rs2,rs1,3'b0,imm[4:0],7'b0};  \
        return val; \
    endfunction  \
  function bit [31:0] override_rand_inst(ref ops_gen_config ops_gen_cfg,ref bit[31:0] imm); \
        bit[31:0] rand_ops; \
        bit imm_ok; \
        `RANDOMIZE_CHECK_WITH_C(ops_gen_cfg,``I,"Error: store inst ops gen error")\
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
    function void asm_print();  \
        $fwrite(gen_file,(`S_TYPE_ASM_STRING),`S_TYPE_ASM_VAL);\
    endfunction \
endclass
`STORE_INST(sb_gen, "sb_gen",  SB ,32'b0000000_00000_00000_111_00000_1111111 ,32'b0000000_00000_00000_000_00000_0100011,"sb" ,LSU,S_TYPE,ls_inst_unsigned == 0; ls_addr_misalign_en == 0; align_bytes == 1;, LS_VALID, `RAND_RS_GPR)
`STORE_INST(sh_gen, "sh_gen",  SH ,32'b0000000_00000_00000_111_00000_1111111 ,32'b0000000_00000_00000_001_00000_0100011,"sh" ,LSU,S_TYPE,ls_inst_unsigned == 0; ls_addr_misalign_en == 0; align_bytes == 2;, LS_VALID, `RAND_RS_GPR)
`STORE_INST(sw_gen, "sw_gen",  SW ,32'b0000000_00000_00000_111_00000_1111111 ,32'b0000000_00000_00000_010_00000_0100011,"sw" ,LSU,S_TYPE,ls_inst_unsigned == 0; ls_addr_misalign_en == 0; align_bytes == 4;, LS_VALID, `RAND_RS_GPR)
`STORE_INST(sd_gen, "sd_gen",  SD ,32'b0000000_00000_00000_111_00000_1111111 ,32'b0000000_00000_00000_011_00000_0100011,"sd" ,LSU,S_TYPE,ls_inst_unsigned == 0; ls_addr_misalign_en == 0; align_bytes == 8;, LS_VALID, `RAND_RS_GPR)
`STORE_INST(invalid_sb_gen, "invalid_sb_gen",  INVALID_SB ,32'b0000000_00000_00000_111_00000_1111111 ,32'b0000000_00000_00000_000_00000_0100011,"invalid_sb" ,LSU,S_TYPE,ls_inst_unsigned == 0; ls_addr_misalign_en == 0; align_bytes == 1;, LS_INVALID,`RAND_RS_GPR)
`STORE_INST(invalid_sh_gen, "invalid_sh_gen",  INVALID_SH ,32'b0000000_00000_00000_111_00000_1111111 ,32'b0000000_00000_00000_001_00000_0100011,"invalid_sh" ,LSU,S_TYPE,ls_inst_unsigned == 0; ls_addr_misalign_en == 1; align_bytes == 2;, LS_INVALID,`RAND_RS_GPR)
`STORE_INST(invalid_sw_gen, "invalid_sw_gen",  INVALID_SW ,32'b0000000_00000_00000_111_00000_1111111 ,32'b0000000_00000_00000_010_00000_0100011,"invalid_sw" ,LSU,S_TYPE,ls_inst_unsigned == 0; ls_addr_misalign_en == 1; align_bytes == 4;, LS_INVALID,`RAND_RS_GPR)
`STORE_INST(invalid_sd_gen, "invalid_sd_gen",  INVALID_SD ,32'b0000000_00000_00000_111_00000_1111111 ,32'b0000000_00000_00000_011_00000_0100011,"invalid_sd" ,LSU,S_TYPE,ls_inst_unsigned == 0; ls_addr_misalign_en == 1; align_bytes == 8;, LS_INVALID,`RAND_RS_GPR)

`STORE_INST(fsw_gen, "fsw_gen",  FSW ,32'b0000000_00000_00000_111_00000_1111111 ,32'b0000000_00000_00000_010_00000_0100111,"fsw" ,LSU,S_TYPE,ls_inst_unsigned == 0; ls_addr_misalign_en == 0; align_bytes == 4; ,LS_VALID, `RAND_FPR)
`STORE_INST(fsd_gen, "fsd_gen",  FSD ,32'b0000000_00000_00000_111_00000_1111111 ,32'b0000000_00000_00000_010_00000_0100111,"fsd" ,LSU,S_TYPE,ls_inst_unsigned == 0; ls_addr_misalign_en == 0; align_bytes == 8; ,LS_VALID, `RAND_FPR)
`STORE_INST(invalid_fsw_gen, "invalid_fsw_gen",  INVALID_FSW ,32'b0000000_00000_00000_111_00000_1111111 ,32'b0000000_00000_00000_010_00000_0000111,"invalid_fsw" ,LSU,S_TYPE,ls_inst_unsigned == 0; ls_addr_misalign_en == 1; align_bytes == 4; ,LS_INVALID, `RAND_FPR)
`STORE_INST(invalid_fsd_gen, "invalid_fsd_gen",  INVALID_FSD ,32'b0000000_00000_00000_111_00000_1111111 ,32'b0000000_00000_00000_011_00000_0000111,"invalid_fsd" ,LSU,S_TYPE,ls_inst_unsigned == 0; ls_addr_misalign_en == 1; align_bytes == 8; ,LS_INVALID, `RAND_FPR)
