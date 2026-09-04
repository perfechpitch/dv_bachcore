//learn from dv define
// Shorthand for common foo.randomize() + fatal check
`define BOOT_PC   'h91040000
`define ITCM_SIZE 'h1000      // 4KB instruction TCM, fetch layout starts at PC='h0
`define DTCM_SIZE   'h1000    // 4KB per hart, same VA for MU/VU/DTE
`define SHARE_SIZE  'h8000    // 32KB
`define USER_STRIDE 'h800     // 2KB per user
`define HART_SLOT   'h2A0     // 672B per hart inside a user
`define DTCM_BASE   'h0
`define SHARE_BASE  'h8000
`define gfn get_full_name()
`define RANDOMIZE_CHECK(T_, MSG_="") \
    if (!(T_.randomize())) begin \
      `uvm_error(`gfn, $sformatf("Check failed (%s) %s ", `"T_`", MSG_)); \
      $finish;\
    end
`define RANDOMIZE_CHECK_WITH_C(T_, WITH_C_=, MSG_="") \
    if (!(T_.randomize()with{WITH_C_})) begin \
      `uvm_error(`gfn, $sformatf("Check failed (%s) %s ", `"T_`", MSG_)); \
      $finish;\
    end
//ABI define
`define zero 0
`define a0 10
`define a1 11
`define scause 'h142
`define mcause 'h342
`define sepc   'h141
`define mepc   'h341
`define stvec  'h105
`define mtvec  'h305
`define pma_attr_addr(A)    'hbc0+``A*4+0
`define pma_start_addr(A)   'hbc0+``A*4+1
`define pma_end_addr(A)     'hbc0+``A*4+2
`define INST_GEN_NEW(N,U,M,V,O,A) \
    inst_name = ``N; \
    inst_format = ``A; \
    exe_unit    = ``U; \
    const_ops_mask = ``M; \
    const_ops_val = ``V; \
    asm_name = ``O;
`define RAND_BASE_REG        reg_pool.get_base_reg()
`define RAND_LS_BASE_REG(A)    reg_pool.get_ls_base_reg(``A)
`define RAND_IMM_REG    reg_pool.get_imm_reg()
`define RAND_RD_GPR   reg_pool.get_gpr(1)
`define RAND_RS_GPR            reg_pool.get_gpr(0)
//`define RAND_GPR(A)    reg_pool.get_gpr(``A)
`define RAND_FPR    reg_pool.get_fpr()
//`define RAND_VPR(A,B)    reg_pool.get_vpr(``A,``B)
`define RAND_VD_VPR(A,B)    reg_pool.get_vpr(``A,``B)
`define RAND_VS_VPR(A)    reg_pool.get_vpr(``A,1)//vs is free for v0
`define R_TYPE_ASM_STRING ".insn 0x%h// %8s\tx%0d, x%0d, x%0d\n"
`define R_TYPE_ASM_VAL    inst,asm_name,inst[11:7], inst[19:15], inst[24:20]
`define I_TYPE_ASM_STRING ".insn 0x%h// %8s\tx%0d, x%0d, SEXT_IMM(0x%0h);\n"
`define I_TYPE_ASM_VAL    inst,asm_name,inst[11:7], inst[19:15], inst[31:20]
`define SHIFT_I_TYPE_ASM_STRING ".insn 0x%h// %8s\tx%0d, x%0d, 0x%0h;\n"
`define SHIFT_I_TYPE_ASM_VAL    inst,asm_name,inst[11:7], inst[19:15], inst[25:20]
`define U_TYPE_ASM_STRING ".insn 0x%h// %8s\tx%0d, 0x%0h\n"
`define U_TYPE_ASM_VAL    inst,asm_name,inst[11:7], inst[31:12]
`define B_TYPE_ASM_STRING ".insn 0x%h// %8s\tx%0d, x%0d, 0x%0h\n"
`define B_TYPE_ASM_VAL    inst,asm_name,inst[19:15], inst[24:20], {inst[31],inst[7],inst[30:25],inst[11:8],1'b0}
`define S_TYPE_ASM_STRING ".insn 0x%h// %8s\tx%0d, 0x%0h(x%0d)\n"
`define S_TYPE_ASM_VAL    inst,asm_name,inst[24:20], {inst[31:25],inst[11:7]}, inst[19:15]
`define LOAD_I_TYPE_ASM_STRING ".insn 0x%h// %8s\tx%0d, 0x%0h(x%0d)\n"
`define LOAD_I_TYPE_ASM_VAL    inst,asm_name,inst[11:7], inst[31:20], inst[19:15]
`define N_TYPE_ASM_STRING ".insn 0x%h// %8s\n"
`define N_TYPE_ASM_VAL    inst,asm_name
`define J_TYPE_ASM_STRING ".insn 0x%h// %8s\tx%0d, 0x%0h\n"
`define J_TYPE_ASM_VAL    inst,asm_name,inst[11:7], {inst[31],inst[19:12],inst[20],inst[30:21],1'b0}

`define FP_R_TYPE_ASM_STRING ".insn 0x%h// %8s\tf%0d, f%0d, f%0d, 0x%0h\n"
`define FP_R_TYPE_ASM_VAL    inst,asm_name,inst[11:7], inst[19:15], inst[24:20], inst[14:12]
`define FP_R4_TYPE_ASM_STRING ".insn 0x%h// %8s\tf%0d, f%0d, f%0d, f%0d, 0x%0h\n"
`define FP_R4_TYPE_ASM_VAL    inst,asm_name,inst[11:7], inst[19:15], inst[24:20], inst[31:27], inst[14:12]
`define FP_SR_TYPE_ASM_STRING ".insn 0x%h// %8s\tf%0d, f%0d, 0x%0h\n"
`define FP_SR_TYPE_ASM_VAL    inst,asm_name,inst[11:7], inst[19:15], inst[14:12]



`define INST_GEN_DECLARATION(N) \
    ``N   inst_``N;
//`define INST_GEN_CREATE(N,M) \
`define INST_GEN_CREATE(N) \
    inst_``N = ``N::type_id::create({"inst_",`"``N`"}); \
    inst_gen_queue.push_back(inst_``N); \
    inst_gen_cfg.support_inst_name.push_back(inst_``N.inst_name); \
    inst_``N.gen_file = gen_file;\
    inst_``N.reg_pool = reg_pool; \
    inst_``N.addr_space_gen = addr_space_gen; \
    inst_``N.ls_addr_gen = ls_addr_gen;
`define RV64ZIFENCEI_INST_CREATE\
    `INST_GEN_CREATE(fencei_gen     )
`define RV64ZICSR_INST_CREATE\
    `INST_GEN_CREATE(csrrc_gen  )\
    `INST_GEN_CREATE(csrrci_gen )\
    `INST_GEN_CREATE(csrrs_gen  )\
    `INST_GEN_CREATE(csrrsi_gen )\
    `INST_GEN_CREATE(csrrw_gen  )\
    `INST_GEN_CREATE(csrrwi_gen )
`define M_MODE_PRV_INST_CREATE\
    `INST_GEN_CREATE(mret_gen   )
`define S_MODE_PRV_INST_CREATE\
    `INST_GEN_CREATE(sret_gen   )
//TODO
`define RV64CBO_INST_CREATE
`define RVPREF_INST_CREATE \
    `INST_GEN_CREATE(invalid_pref_i_gen )\
    `INST_GEN_CREATE(invalid_pref_r_gen )\
    `INST_GEN_CREATE(invalid_pref_w_gen )\
    `INST_GEN_CREATE(pref_i_gen )\
    `INST_GEN_CREATE(pref_r_gen )\
    `INST_GEN_CREATE(pref_w_gen )
`define CUSTOM_INST_CREATE
// XLEN-filtered subsets. Legacy RV64 aggregate macros remain unchanged.
`define I_COMMON_ALU_CREATE \
 `INST_GEN_CREATE(addi_gen) `INST_GEN_CREATE(slti_gen) `INST_GEN_CREATE(sltiu_gen) `INST_GEN_CREATE(xori_gen) `INST_GEN_CREATE(ori_gen) `INST_GEN_CREATE(andi_gen) `INST_GEN_CREATE(slli_gen) `INST_GEN_CREATE(srli_gen) `INST_GEN_CREATE(srai_gen) `INST_GEN_CREATE(add_gen) `INST_GEN_CREATE(sub_gen) `INST_GEN_CREATE(sll_gen) `INST_GEN_CREATE(slt_gen) `INST_GEN_CREATE(sltu_gen) `INST_GEN_CREATE(xor_gen) `INST_GEN_CREATE(srl_gen) `INST_GEN_CREATE(sra_gen) `INST_GEN_CREATE(or_gen) `INST_GEN_CREATE(and_gen)
`define I_COMMON_CTRL_CREATE \
 `INST_GEN_CREATE(lui_gen) `INST_GEN_CREATE(auipc_gen) `INST_GEN_CREATE(jal_gen) `INST_GEN_CREATE(jalr_gen) `INST_GEN_CREATE(beq_gen) `INST_GEN_CREATE(bne_gen) `INST_GEN_CREATE(bge_gen) `INST_GEN_CREATE(blt_gen) `INST_GEN_CREATE(bgeu_gen) `INST_GEN_CREATE(bltu_gen) `INST_GEN_CREATE(ebreak_gen) `INST_GEN_CREATE(ecall_gen) `INST_GEN_CREATE(dret_gen) `INST_GEN_CREATE(wfi_gen) `INST_GEN_CREATE(fence_gen) `INST_GEN_CREATE(misalign_jal_gen) `INST_GEN_CREATE(misalign_beq_gen) `INST_GEN_CREATE(misalign_bne_gen) `INST_GEN_CREATE(misalign_bge_gen) `INST_GEN_CREATE(misalign_blt_gen) `INST_GEN_CREATE(misalign_bgeu_gen) `INST_GEN_CREATE(misalign_bltu_gen)
`define I_COMMON_LS_CREATE \
 `INST_GEN_CREATE(lb_gen) `INST_GEN_CREATE(lh_gen) `INST_GEN_CREATE(lw_gen) `INST_GEN_CREATE(lbu_gen) `INST_GEN_CREATE(lhu_gen) `INST_GEN_CREATE(sb_gen) `INST_GEN_CREATE(sh_gen) `INST_GEN_CREATE(sw_gen) `INST_GEN_CREATE(invalid_lb_gen) `INST_GEN_CREATE(invalid_lh_gen) `INST_GEN_CREATE(invalid_lw_gen) `INST_GEN_CREATE(invalid_lbu_gen) `INST_GEN_CREATE(invalid_lhu_gen) `INST_GEN_CREATE(invalid_sb_gen) `INST_GEN_CREATE(invalid_sh_gen) `INST_GEN_CREATE(invalid_sw_gen)
`define I_COMMON_INST_CREATE \
 `I_COMMON_ALU_CREATE `I_COMMON_CTRL_CREATE `I_COMMON_LS_CREATE
`define I_RV64_ONLY_INST_CREATE \
 `INST_GEN_CREATE(addiw_gen) `INST_GEN_CREATE(slliw_gen) `INST_GEN_CREATE(srliw_gen) `INST_GEN_CREATE(sraiw_gen) `INST_GEN_CREATE(addw_gen) `INST_GEN_CREATE(subw_gen) `INST_GEN_CREATE(sllw_gen) `INST_GEN_CREATE(srlw_gen) `INST_GEN_CREATE(sraw_gen) `INST_GEN_CREATE(ld_gen) `INST_GEN_CREATE(lwu_gen) `INST_GEN_CREATE(sd_gen) `INST_GEN_CREATE(invalid_ld_gen) `INST_GEN_CREATE(invalid_lwu_gen) `INST_GEN_CREATE(invalid_sd_gen)
`define M_COMMON_INST_CREATE \
 `INST_GEN_CREATE(mul_gen) `INST_GEN_CREATE(mulh_gen) `INST_GEN_CREATE(mulhsu_gen) `INST_GEN_CREATE(mulhu_gen) `INST_GEN_CREATE(div_gen) `INST_GEN_CREATE(divu_gen) `INST_GEN_CREATE(rem_gen) `INST_GEN_CREATE(remu_gen)
`define M_RV64_ONLY_INST_CREATE \
 `INST_GEN_CREATE(mulw_gen) `INST_GEN_CREATE(divw_gen) `INST_GEN_CREATE(divuw_gen) `INST_GEN_CREATE(remw_gen) `INST_GEN_CREATE(remuw_gen)
`define A_WORD_INST_CREATE \
 `INST_GEN_CREATE(lr_w_gen) `INST_GEN_CREATE(sc_w_gen) `INST_GEN_CREATE(invalid_lr_w_gen) `INST_GEN_CREATE(invalid_sc_w_gen) `INST_GEN_CREATE(amoswap_w_gen) `INST_GEN_CREATE(amoadd_w_gen) `INST_GEN_CREATE(amoxor_w_gen) `INST_GEN_CREATE(amoor_w_gen) `INST_GEN_CREATE(amoand_w_gen) `INST_GEN_CREATE(amomin_w_gen) `INST_GEN_CREATE(amomax_w_gen) `INST_GEN_CREATE(amominu_w_gen) `INST_GEN_CREATE(amomaxu_w_gen) `INST_GEN_CREATE(invalid_amoswap_w_gen) `INST_GEN_CREATE(invalid_amoadd_w_gen) `INST_GEN_CREATE(invalid_amoxor_w_gen) `INST_GEN_CREATE(invalid_amoor_w_gen) `INST_GEN_CREATE(invalid_amoand_w_gen) `INST_GEN_CREATE(invalid_amomin_w_gen) `INST_GEN_CREATE(invalid_amomax_w_gen) `INST_GEN_CREATE(invalid_amominu_w_gen) `INST_GEN_CREATE(invalid_amomaxu_w_gen)
`define A_RV64_ONLY_INST_CREATE \
 `INST_GEN_CREATE(lr_d_gen) `INST_GEN_CREATE(sc_d_gen) `INST_GEN_CREATE(invalid_lr_d_gen) `INST_GEN_CREATE(invalid_sc_d_gen) `INST_GEN_CREATE(amoswap_d_gen) `INST_GEN_CREATE(amoadd_d_gen) `INST_GEN_CREATE(amoxor_d_gen) `INST_GEN_CREATE(amoor_d_gen) `INST_GEN_CREATE(amoand_d_gen) `INST_GEN_CREATE(amomin_d_gen) `INST_GEN_CREATE(amomax_d_gen) `INST_GEN_CREATE(amominu_d_gen) `INST_GEN_CREATE(amomaxu_d_gen) `INST_GEN_CREATE(invalid_amoswap_d_gen) `INST_GEN_CREATE(invalid_amoadd_d_gen) `INST_GEN_CREATE(invalid_amoxor_d_gen) `INST_GEN_CREATE(invalid_amoor_d_gen) `INST_GEN_CREATE(invalid_amoand_d_gen) `INST_GEN_CREATE(invalid_amomin_d_gen) `INST_GEN_CREATE(invalid_amomax_d_gen) `INST_GEN_CREATE(invalid_amominu_d_gen) `INST_GEN_CREATE(invalid_amomaxu_d_gen)
`define RV32I_INST_CREATE `I_COMMON_INST_CREATE
`define RV64I_INST_CREATE `I_COMMON_INST_CREATE `I_RV64_ONLY_INST_CREATE
`define RV32M_INST_CREATE `M_COMMON_INST_CREATE
`define RV64M_INST_CREATE `M_COMMON_INST_CREATE `M_RV64_ONLY_INST_CREATE
`define RV32A_INST_CREATE `A_WORD_INST_CREATE
`define RV64A_INST_CREATE `A_WORD_INST_CREATE `A_RV64_ONLY_INST_CREATE
//`define FLOAT_INST_CREATE \
`define RV64F_INST_CREATE \
    `INST_GEN_CREATE(fmadd_s_gen    )\
    `INST_GEN_CREATE(fmsub_s_gen    )\
    `INST_GEN_CREATE(fnmadd_s_gen   )\
    `INST_GEN_CREATE(fnmsub_s_gen   )\
    `INST_GEN_CREATE(fadd_s_gen     )\
    `INST_GEN_CREATE(fsub_s_gen     )\
    `INST_GEN_CREATE(fmul_s_gen     )\
    `INST_GEN_CREATE(feq_s_gen      )\
    `INST_GEN_CREATE(flt_s_gen      )\
    `INST_GEN_CREATE(fle_s_gen      )\
    `INST_GEN_CREATE(fsgnj_s_gen    )\
    `INST_GEN_CREATE(fsgnjn_s_gen   )\
    `INST_GEN_CREATE(fsgnjx_s_gen   )\
    `INST_GEN_CREATE(fcvt_w_s_gen   )\
    `INST_GEN_CREATE(fcvt_wu_s_gen  )\
    `INST_GEN_CREATE(fcvt_s_w_gen   )\
    `INST_GEN_CREATE(fcvt_s_l_gen   )\
    `INST_GEN_CREATE(fcvt_l_s_gen   )\
    `INST_GEN_CREATE(fcvt_lu_s_gen  )\
    `INST_GEN_CREATE(fcvt_s_lu_gen  )\
    `INST_GEN_CREATE(fcvt_s_wu_gen  )\
    `INST_GEN_CREATE(fclass_s_gen   )\
    `INST_GEN_CREATE(fsqrt_s_gen    )\
`INST_GEN_CREATE(fmv_x_w_gen    )\
    `INST_GEN_CREATE(fmv_w_x_gen    )\
    `INST_GEN_CREATE(fmax_s_gen     )\
    `INST_GEN_CREATE(fmin_s_gen     )\
    `INST_GEN_CREATE(flw_gen        )\
    `INST_GEN_CREATE(invalid_flw_gen)\
    `INST_GEN_CREATE(fsw_gen        )\
    `INST_GEN_CREATE(invalid_fsw_gen)\
    `INST_GEN_CREATE(fdiv_s_gen     )
`define RV64D_INST_CREATE \
    `INST_GEN_CREATE(fmadd_d_gen    )\
    `INST_GEN_CREATE(fmsub_d_gen    )\
    `INST_GEN_CREATE(fnmadd_d_gen   )\
    `INST_GEN_CREATE(fnmsub_d_gen   )\
    `INST_GEN_CREATE(fadd_d_gen     )\
    `INST_GEN_CREATE(fsub_d_gen     )\
    `INST_GEN_CREATE(fmul_d_gen     )\
    `INST_GEN_CREATE(feq_d_gen      )\
    `INST_GEN_CREATE(flt_d_gen      )\
    `INST_GEN_CREATE(fle_d_gen      )\
    `INST_GEN_CREATE(fsgnj_d_gen    )\
    `INST_GEN_CREATE(fsgnjn_d_gen   )\
    `INST_GEN_CREATE(fsgnjx_d_gen   )\
    `INST_GEN_CREATE(fcvt_s_d_gen   )\
    `INST_GEN_CREATE(fcvt_d_s_gen   )\
    `INST_GEN_CREATE(fcvt_w_d_gen   )\
    `INST_GEN_CREATE(fcvt_d_w_gen   )\
    `INST_GEN_CREATE(fcvt_l_d_gen   )\
    `INST_GEN_CREATE(fcvt_d_l_gen   )\
    `INST_GEN_CREATE(fcvt_wu_d_gen  )\
    `INST_GEN_CREATE(fcvt_d_wu_gen  )\
    `INST_GEN_CREATE(fcvt_lu_d_gen  )\
    `INST_GEN_CREATE(fcvt_d_lu_gen  )\
    `INST_GEN_CREATE(fclass_d_gen   )\
    `INST_GEN_CREATE(fmv_x_d_gen    )\
    `INST_GEN_CREATE(fmv_d_x_gen    )\
    `INST_GEN_CREATE(fsqrt_d_gen    )\
    `INST_GEN_CREATE(fmax_d_gen     )\
    `INST_GEN_CREATE(fmin_d_gen     )\
    `INST_GEN_CREATE(fdiv_d_gen     )\
    `INST_GEN_CREATE(fld_gen        )\
    `INST_GEN_CREATE(invalid_fld_gen)\
    `INST_GEN_CREATE(fsd_gen        )\
    `INST_GEN_CREATE(invalid_fsd_gen)

`define SPECIFIED_R_TYPE_INST(N,A,B,C) \
//    $display("inst_name=%0s,rs1=%0d,rs2=%0d,rd=%0d",``N,``B,``C,``A);\
    inst_gen.get_specified_inst(``N,``B,``C,``A,0)  // A=B op C
`define SPECIFIED_I_TYPE_INST(N,A,B,C) \
    inst_gen.get_specified_inst(``N,``B,'d0,``A,``C)
`define SPECIFIED_S_TYPE_INST(N,A,B,C) \
    inst_gen.get_specified_inst(``N,``B,``A,'d0,``C)
`define SPECIFIED_U_TYPE_INST(N,A,C) \
    inst_gen.get_specified_inst(``N,'d0,'d0,``A,``C)
`define SPECIFIED_J_TYPE_INST(N,A,C) \
    inst_gen.get_specified_inst(``N,'d0,'d0,``A,``C)
`define SPECIFIED_B_TYPE_INST(N,A,B,C) \
    inst_gen.get_specified_inst(``N,``A,``B,0,``C >> 1)
`define SPECIFIED_N_TYPE_INST(N)\
    inst_gen.get_specified_inst(``N,0,0,0,0);
//`define SPECIFIED_LOAD_TYPE_INST(N,A,B,C) \
//    inst_gen.get_specified_inst(``N,```B,'d0,``A,``C)
`define mret inst_gen.get_specified_inst(MRET,0,0,0,0)
`define sret inst_gen.get_specified_inst(SRET,0,0,0,0)
`define beq(A,B,C) \
    `SPECIFIED_B_TYPE_INST(BEQ,``A,``B,``C)
`define bne(A,B,C) \
    `SPECIFIED_B_TYPE_INST(BNE,``A,``B,``C)
`define add(A,B,C) \
    `SPECIFIED_R_TYPE_INST(ADD,``A,``B,``C)
`define or(A,B,C) \
    `SPECIFIED_R_TYPE_INST(OR,``A,``B,``C)
`define div(A,B,C) \
    `SPECIFIED_R_TYPE_INST(DIV,``A,``B,``C)
`define mul(A,B,C) \
    `SPECIFIED_R_TYPE_INST(MUL,``A,``B,``C)
`define sub(A,B,C) \
    `SPECIFIED_R_TYPE_INST(SUB,``A,``B,``C)
`define addi(A,B,C) \
    `SPECIFIED_I_TYPE_INST(ADDI,``A,``B,``C)
`define xori(A,B,C) \
    `SPECIFIED_I_TYPE_INST(XORI,``A,``B,``C)
`define ori(A,B,C) \
    `SPECIFIED_I_TYPE_INST(ORI,``A,``B,``C)
`define addiw(A,B,C) \
    `SPECIFIED_I_TYPE_INST(ADDIW,``A,``B,``C)
`define srli(A,B,C) \
    `SPECIFIED_I_TYPE_INST(SRLI,``A,``B,``C)
`define slli(A,B,C) \
    `SPECIFIED_I_TYPE_INST(SLLI,``A,``B,``C)
`define lui(A,C) \
    `SPECIFIED_U_TYPE_INST(LUI,``A,``C)
`define auipc(A,C) \
    `SPECIFIED_U_TYPE_INST(AUIPC,``A,``C)
`define csrrw(A,B,C) \
    `SPECIFIED_I_TYPE_INST(CSRRW,``A,``B,``C)
`define csrrc(A,B,C) \
    `SPECIFIED_I_TYPE_INST(CSRRC,``A,``B,``C)
`define csrrs(A,B,C) \
    `SPECIFIED_I_TYPE_INST(CSRRS,``A,``B,``C)
`define fencei \
    `SPECIFIED_N_TYPE_INST(FENCEI)
`define jal(A,C) \
    `SPECIFIED_J_TYPE_INST(JAL,``A,``C)
`define jalr(A,B,C) \
    `SPECIFIED_I_TYPE_INST(JALR,``A,``B,``C)

`define lb(A,C,B) \
    `SPECIFIED_I_TYPE_INST(LB,``A,``B,``C)
`define lh(A,C,B) \
    `SPECIFIED_I_TYPE_INST(LH,``A,``B,``C)
`define lw(A,C,B) \
    `SPECIFIED_I_TYPE_INST(LW,``A,``B,``C)
`define ld(A,C,B) \
    `SPECIFIED_I_TYPE_INST(LD,``A,``B,``C)

`define sb(A,C,B) \
    `SPECIFIED_S_TYPE_INST(SB,``A,``B,``C)
`define sh(A,C,B) \
    `SPECIFIED_S_TYPE_INST(SH,``A,``B,``C)
`define sw(A,C,B) \
    `SPECIFIED_S_TYPE_INST(SW,``A,``B,``C)
`define sd(A,C,B) \
    `SPECIFIED_S_TYPE_INST(SD,``A,``B,``C)
