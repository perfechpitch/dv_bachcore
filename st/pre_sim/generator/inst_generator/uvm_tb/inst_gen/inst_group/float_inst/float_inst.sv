class fp_rr_type_inst extends base_inst;
    `uvm_object_param_utils(fp_rr_type_inst)
    function new (string name = "fp_rr_type_inst");
        super.new(name); 
    endfunction : new
    function bit[31:0] rand_ops_gen(ops_gen_config  ops_gen_cfg);
        bit[31:0] val; 
        bit[4:0] rs1,rs2,rd; 
        rd = `RAND_FPR; 
        if(ops_gen_cfg.rs1_eq_rd)  rs1 = rd; 
        else if(ops_gen_cfg.rs2_eq_rd) rs2 = rd; 

        if(!ops_gen_cfg.rs1_eq_rd) rs1 = `RAND_FPR;

        if(ops_gen_cfg.rs1_eq_rs2) rs2 = rs1;
        else rs2 = `RAND_FPR;
        val = {7'b0,rs2,rs1, ops_gen_cfg.round_mode,rd,7'b0};
        return val;
    endfunction 
endclass

`define FP_RR_INST(A,B,C,D,E,F,G,H)\
class ``A extends rr_type_inst;\        
    parameter CONST_MASK =``D; \
    parameter CONST_VAL  =``E; \
    // new - constructor \
    function new (string name = ``B); \
        super.new(name); \
        `INST_GEN_NEW(``C,``G,CONST_MASK,CONST_VAL,``F,``H); \
    endfunction : new \
    `uvm_object_param_utils(``A) \
    function void asm_print(); \
        $fwrite(gen_file,(`FP_R_TYPE_ASM_STRING),`FP_R_TYPE_ASM_VAL);\
    endfunction \
endclass 
`RR_INST(fadd_s_gen, "fadd_s_gen", FADD_S,32'b1111111_00000_00000_000_00000_1111111 ,32'b0000000_00000_00000_000_00000_1010011, "fadd.s", ALU, R_TYPE)
`RR_INST(fsub_s_gen, "fsub_s_gen", FSUB_S,32'b1111111_00000_00000_000_00000_1111111 ,32'b0000100_00000_00000_000_00000_1010011, "fsub.s", ALU, R_TYPE)
`RR_INST(fmul_s_gen, "fmul_s_gen", FMUL_S,32'b1111111_00000_00000_000_00000_1111111 ,32'b0001000_00000_00000_000_00000_1010011, "fmul.s", ALU, R_TYPE)
`RR_INST(fadd_d_gen, "fadd_d_gen", FADD_D,32'b1111111_00000_00000_000_00000_1111111 ,32'b0000001_00000_00000_000_00000_1010011, "fadd.d", ALU, R_TYPE)
`RR_INST(fsub_d_gen, "fsub_d_gen", FSUB_D,32'b1111111_00000_00000_000_00000_1111111 ,32'b0000101_00000_00000_000_00000_1010011, "fsub.d", ALU, R_TYPE)
`RR_INST(fmul_d_gen, "fmul_d_gen", FMUL_D,32'b1111111_00000_00000_000_00000_1111111 ,32'b0001001_00000_00000_000_00000_1010011, "fmul.d", ALU, R_TYPE)
`RR_INST(fdiv_s_gen, "fdiv_s_gen", FDIV_S,32'b1111111_00000_00000_000_00000_1111111 ,32'b0001100_00000_00000_000_00000_1010011, "fdiv.s", ALU, R_TYPE)
`RR_INST(fdiv_d_gen, "fdiv_d_gen", FDIV_D,32'b1111111_00000_00000_000_00000_1111111 ,32'b0001101_00000_00000_000_00000_1010011, "fdiv.d", ALU, R_TYPE)
`RR_INST(fmax_s_gen, "fmax_s_gen", FMAX_S,32'b1111111_00000_00000_111_00000_1111111 ,32'b0010100_00000_00000_001_00000_1010011, "fmax.s", ALU, R_TYPE)
`RR_INST(fmax_d_gen, "fmax_d_gen", FMAX_D,32'b1111111_00000_00000_111_00000_1111111 ,32'b0010101_00000_00000_001_00000_1010011, "fmax.d", ALU, R_TYPE)
`RR_INST(fmin_s_gen, "fmin_s_gen", FMIN_S,32'b1111111_00000_00000_111_00000_1111111 ,32'b0010100_00000_00000_000_00000_1010011, "fmin.s", ALU, R_TYPE)
`RR_INST(fmin_d_gen, "fmin_d_gen", FMIN_D,32'b1111111_00000_00000_111_00000_1111111 ,32'b0010101_00000_00000_000_00000_1010011, "fmin.d", ALU, R_TYPE)
`RR_INST(feq_s_gen, "feq_s_gen", FEQ_S,32'b1111111_00000_00000_111_00000_1111111 ,32'b1010000_00000_00000_010_00000_1010011, "feq.s", ALU, R_TYPE)
`RR_INST(feq_d_gen, "feq_d_gen", FEQ_D,32'b1111111_00000_00000_111_00000_1111111 ,32'b1010001_00000_00000_010_00000_1010011, "feq.d", ALU, R_TYPE)
`RR_INST(flt_s_gen, "flt_s_gen", FLT_S,32'b1111111_00000_00000_111_00000_1111111 ,32'b1010000_00000_00000_001_00000_1010011, "flt.s", ALU, R_TYPE)
`RR_INST(flt_d_gen, "flt_d_gen", FLT_D,32'b1111111_00000_00000_111_00000_1111111 ,32'b1010001_00000_00000_001_00000_1010011, "flt.d", ALU, R_TYPE)
`RR_INST(fle_s_gen, "fle_s_gen", FLE_S,32'b1111111_00000_00000_111_00000_1111111 ,32'b1010000_00000_00000_000_00000_1010011, "fle.s", ALU, R_TYPE)
`RR_INST(fle_d_gen, "fle_d_gen", FLE_D,32'b1111111_00000_00000_111_00000_1111111 ,32'b1010001_00000_00000_000_00000_1010011, "fle.d", ALU, R_TYPE)
`RR_INST(fsgnj_s_gen, "fsgnj_s_gen", FSGNJ_S,32'b1111111_00000_00000_111_00000_1111111 ,32'b0010000_00000_00000_000_00000_1010011, "fsgnj.s", ALU, R_TYPE)
`RR_INST(fsgnj_d_gen, "fsgnj_d_gen", FSGNJ_D,32'b1111111_00000_00000_111_00000_1111111 ,32'b0010001_00000_00000_000_00000_1010011, "fsgnj.d", ALU, R_TYPE)
`RR_INST(fsgnjn_s_gen, "fsgnjn_s_gen", FSGNJN_S,32'b1111111_00000_00000_111_00000_1111111 ,32'b0010000_00000_00000_001_00000_1010011, "fsgnjn.s", ALU, R_TYPE)
`RR_INST(fsgnjn_d_gen, "fsgnjn_d_gen", FSGNJN_D,32'b1111111_00000_00000_111_00000_1111111 ,32'b0010001_00000_00000_001_00000_1010011, "fsgnjn.d", ALU, R_TYPE)
`RR_INST(fsgnjx_s_gen, "fsgnjx_s_gen", FSGNJX_S,32'b1111111_00000_00000_111_00000_1111111 ,32'b0010000_00000_00000_010_00000_1010011, "fsgnjx.s", ALU, R_TYPE)
`RR_INST(fsgnjx_d_gen, "fsgnjx_d_gen", FSGNJX_D,32'b1111111_00000_00000_111_00000_1111111 ,32'b0010001_00000_00000_010_00000_1010011, "fsgnjx.d", ALU, R_TYPE)

`define FP_SR_INST(A,B,C,D,E,F,G,H)\
class ``A extends rr_type_inst;\
    parameter CONST_MASK =``D; \
    parameter CONST_VAL  =``E; \
    // new - constructor \
    function new (string name = ``B); \
        super.new(name); \
        `INST_GEN_NEW(``C,``G,CONST_MASK,CONST_VAL,``F,``H); \
    endfunction : new \
    `uvm_object_param_utils(``A) \
    function bit[31:0] rand_ops_gen(ops_gen_config  ops_gen_cfg); \
        bit[31:0] val;  \
        bit[4:0] rs1,rd;  \
        rd = `RAND_FPR;  \
        if(ops_gen_cfg.rs1_eq_rd)  rs1 = rd;  \
        else rs1 = `RAND_FPR;  \
        val = {7'b0,5'b0,rs1, ops_gen_cfg.round_mode,rd,7'b0};  \
        return val; \
    endfunction  \
    function void asm_print(); \
        $fwrite(gen_file,(`FP_SR_TYPE_ASM_STRING),`FP_SR_TYPE_ASM_VAL);\
    endfunction \
endclass

`FP_SR_INST(fsqrt_s_gen, "fsqrt_s_gen", FSQRT_S,32'b1111111_11111_00000_000_00000_1111111 ,32'b0101100_00000_00000_000_00000_1010011, "fsqrt.s", ALU, FP_SR_TYPE)
`FP_SR_INST(fsqrt_d_gen, "fsqrt_d_gen", FSQRT_D,32'b1111111_11111_00000_000_00000_1111111 ,32'b0101101_00000_00000_000_00000_1010011, "fsqrt.d", ALU, FP_SR_TYPE)
`FP_SR_INST(fcvt_w_s_gen, "fcvt_w_s_gen", FCVT_W_S,32'b1111111_11111_00000_000_00000_1111111 ,32'b1100000_00000_00000_000_00000_1010011, "fcvt.w.s", ALU, FP_SR_TYPE)
`FP_SR_INST(fcvt_wu_s_gen, "fcvt_wu_s_gen", FCVT_WU_S,32'b1111111_11111_00000_000_00000_1111111 ,32'b1100000_00001_00000_000_00000_1010011, "fcvt.wu.s", ALU, FP_SR_TYPE)
`FP_SR_INST(fcvt_w_d_gen, "fcvt_w_d_gen", FCVT_W_D,32'b1111111_11111_00000_000_00000_1111111 ,32'b1100001_00000_00000_000_00000_1010011, "fcvt.w.d", ALU, FP_SR_TYPE)
`FP_SR_INST(fcvt_wu_d_gen, "fcvt_wu_d_gen", FCVT_WU_D,32'b1111111_11111_00000_000_00000_1111111 ,32'b1100001_00001_00000_000_00000_1010011, "fcvt.wu.d", ALU, FP_SR_TYPE)
`FP_SR_INST(fcvt_s_w_gen, "fcvt_s_w_gen", FCVT_S_W,32'b1111111_11111_00000_000_00000_1111111 ,32'b1101000_00000_00000_000_00000_1010011, "fcvt.s.w", ALU, FP_SR_TYPE)
`FP_SR_INST(fcvt_s_wu_gen, "fcvt_s_wu_gen", FCVT_S_WU,32'b1111111_11111_00000_000_00000_1111111 ,32'b1101000_00001_00000_000_00000_1010011, "fcvt.s.wu", ALU, FP_SR_TYPE)
`FP_SR_INST(fcvt_d_w_gen, "fcvt_d_w_gen", FCVT_D_W,32'b1111111_11111_00000_000_00000_1111111 ,32'b1101001_00000_00000_000_00000_1010011, "fcvt.d.w", ALU, FP_SR_TYPE)
`FP_SR_INST(fcvt_d_wu_gen, "fcvt_d_wu_gen", FCVT_D_WU,32'b1111111_11111_00000_000_00000_1111111 ,32'b1101001_00001_00000_000_00000_1010011, "fcvt.d.wu", ALU, FP_SR_TYPE)
`FP_SR_INST(fcvt_l_s_gen, "fcvt_l_s_gen", FCVT_L_S,32'b1111111_11111_00000_000_00000_1111111 ,32'b1100000_00010_00000_000_00000_1010011, "fcvt.l.s", ALU, FP_SR_TYPE)
`FP_SR_INST(fcvt_lu_s_gen, "fcvt_lu_s_gen", FCVT_LU_S,32'b1111111_11111_00000_000_00000_1111111 ,32'b1100000_00011_00000_000_00000_1010011, "fcvt.lu.s", ALU, FP_SR_TYPE)
`FP_SR_INST(fcvt_l_d_gen, "fcvt_l_d_gen", FCVT_L_D,32'b1111111_11111_00000_000_00000_1111111 ,32'b1100001_00010_00000_000_00000_1010011, "fcvt.l.d", ALU, FP_SR_TYPE)
`FP_SR_INST(fcvt_lu_d_gen, "fcvt_lu_d_gen", FCVT_LU_D,32'b1111111_11111_00000_000_00000_1111111 ,32'b1100001_00011_00000_000_00000_1010011, "fcvt.lu.s", ALU, FP_SR_TYPE)
`FP_SR_INST(fcvt_s_l_gen, "fcvt_s_l_gen", FCVT_S_L,32'b1111111_11111_00000_000_00000_1111111 ,32'b1101000_00010_00000_000_00000_1010011, "fcvt.s.l", ALU, FP_SR_TYPE)
`FP_SR_INST(fcvt_s_lu_gen, "fcvt_s_lu_gen", FCVT_S_LU,32'b1111111_11111_00000_000_00000_1111111 ,32'b1101000_00011_00000_000_00000_1010011, "fcvt.s.lu", ALU, FP_SR_TYPE)
`FP_SR_INST(fcvt_d_l_gen, "fcvt_d_l_gen", FCVT_D_L,32'b1111111_11111_00000_000_00000_1111111 ,32'b1101001_00010_00000_000_00000_1010011, "fcvt.d.l", ALU, FP_SR_TYPE)
`FP_SR_INST(fcvt_d_lu_gen, "fcvt_d_lu_gen", FCVT_D_LU,32'b1111111_11111_00000_000_00000_1111111 ,32'b1101001_00011_00000_000_00000_1010011, "fcvt.d.lu", ALU, FP_SR_TYPE)
`FP_SR_INST(fcvt_s_d_gen, "fcvt_s_d_gen", FCVT_S_D,32'b1111111_11111_00000_000_00000_1111111 ,32'b0100000_00001_00000_000_00000_1010011, "fcvt.s.d", ALU, FP_SR_TYPE)
`FP_SR_INST(fcvt_d_s_gen, "fcvt_d_s_gen", FCVT_D_S,32'b1111111_11111_00000_000_00000_1111111 ,32'b0100001_00000_00000_000_00000_1010011, "fcvt.d.s", ALU, FP_SR_TYPE)
`FP_SR_INST(fclass_s_gen, "fclass_s_gen", FCLASS_S,32'b1111111_11111_00000_111_00000_1111111 ,32'b1110000_00000_00000_001_00000_1010011, "fclass.s", ALU, FP_SR_TYPE)
`FP_SR_INST(fclass_d_gen, "fclass_d_gen", FCLASS_D,32'b1111111_11111_00000_111_00000_1111111 ,32'b1110001_00000_00000_001_00000_1010011, "fclass.d", ALU, FP_SR_TYPE)
`FP_SR_INST(fmv_x_w_gen, "fmv_x_w_gen", FMV_X_W,32'b1111111_11111_00000_111_00000_1111111 ,32'b1110000_00000_00000_000_00000_1010011, "fmv.x.w", ALU, FP_SR_TYPE)
`FP_SR_INST(fmv_w_x_gen, "fmv_w_x_gen", FMV_W_X,32'b1111111_11111_00000_111_00000_1111111 ,32'b1111000_00000_00000_000_00000_1010011, "fmv.w.x", ALU, FP_SR_TYPE)
`FP_SR_INST(fmv_x_d_gen, "fmv_x_d_gen", FMV_X_D,32'b1111111_11111_00000_111_00000_1111111 ,32'b1110001_00000_00000_000_00000_1010011,"fmv.x.d", ALU, FP_SR_TYPE)
`FP_SR_INST(fmv_d_x_gen, "fmv_d_x_gen", FMV_D_X,32'b1111111_11111_00000_111_00000_1111111,32'b1111001_00000_00000_000_00000_1010011,"fmv.d.x", ALU, FP_SR_TYPE)
`define FP_R4_INST(A,B,C,D,E,F,G,H)\
class ``A extends rr_type_inst;\
    parameter CONST_MASK =``D; \
    parameter CONST_VAL  =``E; \
    // new - constructor \
    function new (string name = ``B); \
        super.new(name); \
        `INST_GEN_NEW(``C,``G,CONST_MASK,CONST_VAL,``F,``H); \
    endfunction : new \
    `uvm_object_param_utils(``A) \
    function bit[31:0] rand_ops_gen(ops_gen_config  ops_gen_cfg); \
        bit[31:0] val;  \
        bit[4:0] rs1,rs2,rs3,rd;  \
        rs3 = `RAND_FPR; \
        rd = `RAND_FPR;  \
        if(ops_gen_cfg.rs1_eq_rd)  rs1 = rd;  \
        else if(ops_gen_cfg.rs2_eq_rd) rs2 = rd;  \
        if(!ops_gen_cfg.rs1_eq_rd) rs1 = `RAND_FPR;  \
        if(ops_gen_cfg.rs1_eq_rs2) rs2 = rs1;  \
        else rs2 = `RAND_FPR;  \
        val = {rs3,2'b0,rs2,rs1, ops_gen_cfg.round_mode,rd,7'b0};  \
        return val; \
    endfunction  \
    function void asm_print(); \
        $fwrite(gen_file,(`FP_R4_TYPE_ASM_STRING),`FP_R4_TYPE_ASM_VAL);\
    endfunction \
endclass

`FP_R4_INST(fmadd_s_gen, "fmadd_s_gen", FMADD_S,32'b0000011_00000_00000_000_00000_1111111 ,32'b0000000_00000_00000_000_00000_1000011, "fmadd.s", ALU, FP_R4_TYPE)
`FP_R4_INST(fmsub_s_gen, "fmsub_s_gen", FMSUB_S,32'b0000011_00000_00000_000_00000_1111111 ,32'b0000000_00000_00000_000_00000_1000111, "fmsub.s", ALU, FP_R4_TYPE)
`FP_R4_INST(fnmadd_s_gen, "fnmadd_s_gen", FNMADD_S,32'b0000011_00000_00000_000_00000_1111111 ,32'b0000000_00000_00000_000_00000_1001111, "fnmadd.s", ALU, FP_R4_TYPE)
`FP_R4_INST(fnmsub_s_gen, "fnmsub_s_gen", FNMSUB_S,32'b0000011_00000_00000_000_00000_1111111 ,32'b0000000_00000_00000_000_00000_1001011, "fnmsub.s", ALU, FP_R4_TYPE)
`FP_R4_INST(fmadd_d_gen, "fmadd_d_gen", FMADD_D,32'b0000011_00000_00000_000_00000_1111111 ,32'b0000001_00000_00000_000_00000_1000011, "fmadd.d", ALU, FP_R4_TYPE)
`FP_R4_INST(fmsub_d_gen, "fmsub_d_gen", FMSUB_D,32'b0000011_00000_00000_000_00000_1111111 ,32'b0000001_00000_00000_000_00000_1000111, "fmsub.d", ALU, FP_R4_TYPE)
`FP_R4_INST(fnmadd_d_gen, "fnmadd_d_gen", FNMADD_D,32'b0000011_00000_00000_000_00000_1111111 ,32'b0000001_00000_00000_000_00000_1001111, "fnmadd.d", ALU, FP_R4_TYPE)
`FP_R4_INST(fnmsub_d_gen, "fnmsub_d_gen", FNMSUB_D,32'b0000011_00000_00000_000_00000_1111111 ,32'b0000001_00000_00000_000_00000_1001011, "fnmsub.d", ALU, FP_R4_TYPE)
