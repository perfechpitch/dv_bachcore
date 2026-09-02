typedef enum {RV32I, RV32M, RV32A, RV32C, CUSTOM, RI} inst_set_e;
typedef enum {ALU, LSU, BEU, MDU, ROB}  exe_unit_e;
`define GPR(A) gpr_s.reg_data[``A]

`define RTYPE_RS2 inst[24:20]
`define RTYPE_RS1 inst[19:15]
`define RTYPE_RD  inst[11:7]

`define ITYPE_RD        inst[11:7]
`define ITYPE_RS1       inst[19:15]
`define ITYPE_IMM       inst[31:20]
`define ITYPE_RS2_SHAMT inst[24:20]
`define ITYPE_SHAMT     inst[24:20]
`define ITYPE_IMM_SIGN_EXTEND32 {{20{inst[31]}}, inst[31:20]}

`define UTYPE_RD  inst[11:7]
`define UTYPE_IMM {inst[31:12], 12'b0}

`define BTYPE_RS1 inst[19:15]
`define BTYPE_RS2 inst[24:20]
`define BTYPE_IMM_SIGN_EXTEND32 {{19{inst[31]}}, inst[31], inst[7], inst[30:25], inst[11:8], 1'b0}

`define JTYPE_RD inst[11:7]
`define JTYPE_IMM_SIGN_EXTEND32 {{11{inst[31]}}, inst[31], inst[19:12], inst[20], inst[30:21], 1'b0}

`define STYPE_RS1 inst[19:15]
`define STYPE_RS2 inst[24:20]
`define STYPE_IMM_SIGN_EXTEND32 {{20{inst[31]}}, inst[31:25], inst[11:7]}

`define CR_TYPE_BASE_RS1 inst[11:7]
`define CR_TYPE_BASE_RS2 inst[6:2]
`define CR_TYPE_BASE_RD  inst[11:7]

`define CI_TYPE_BASE_RS1          inst[11:7]
`define CI_TYPE_BASE_RD           inst[11:7]
`define CI_TYPE_BASE_SHAMT        {inst[12], inst[6:2]}
`define CI_TYPE_BASE_IMM          {inst[12], inst[6:2]}
`define CI_TYPE_BASE_IMM_EXTEND32 {{14{inst[12]}}, inst[12], inst[6:2], 12'b0}
`define CI_TYPE_LUI_IMM_EXTEND32 {{14{inst[12]}}, inst[12], inst[6:2], 12'b0}

`define CI_TYPE_ADDI_LI_IMM_SIGN_EXTEND32 {{26{inst[12]}}, inst[12], inst[6:2]}

`define CI_TYPE_ADDI16SP_IMM          {inst[12], inst[4:3], inst[5], inst[2], inst[6]}
`define CI_TYPE_ADDI16SP_IMM_EXTEND32 {{22{inst[12]}}, inst[12], inst[4:3], inst[5], inst[2], inst[6], 4'b0}

`define CI_TYPE_LWSP_RS1          5'd2
`define CI_TYPE_LWSP_IMM          {inst[3:2], inst[12], inst[6:4]}
`define CI_TYPE_LWSP_IMM_EXTEND32 {24'b0, inst[3:2], inst[12], inst[6:4], 2'b0}

`define CSS_TYPE_BASE_RS1           5'd2
`define CSS_TYPE_BASE_RS2           inst[6:2]
`define CSS_TYPE_SWSP_IMM           {inst[8:7], inst[12:9]}
`define CSS_TYPE_SWSP_IMM_EXTEND32  {24'b0, inst[8:7], inst[12:9], 2'b0}

`define CIW_TYPE_BASE_RS1          5'd2
`define CIW_TYPE_BASE_RD           {2'b01, inst[4:2]}
`define CIW_TYPE_BASE_IMM          {inst[10:7], inst[12:11], inst[5], inst[6]}
`define CIW_TYPE_BASE_IMM_EXTEND32 {22'b0, inst[10:7], inst[12:11], inst[5], inst[6], 2'b0}

`define CL_CS_TYPE_BASE_RS1           {2'b01, inst[9:7]}
`define CL_CS_TYPE_BASE_RD_RS2        {2'b01, inst[4:2]}
`define CL_CS_TYPE_LW_SW_IMM          {inst[5], inst[12:10], inst[6]}
`define CL_CS_TYPE_LW_SW_IMM_EXTEND32 {25'b0, inst[5], inst[12:10], inst[6], 2'b0}

`define CA_TYPE_BASE_RS1 {2'b01, inst[9:7]}
`define CA_TYPE_BASE_RS2 {2'b01, inst[4:2]}
`define CA_TYPE_BASE_RD  {2'b01, inst[9:7]}

`define CB_TYPE_BASE_RS1          {2'b01, inst[9:7]}
`define CB_TYPE_BASE_RD           {2'b01, inst[9:7]}
`define CB_TYPE_BASE_SHAMT        {inst[12], inst[6:2]}
`define CB_TYPE_BASE_IMM          {inst[12], inst[6:5], inst[2], inst[11:10], inst[4:3]}
`define CB_TYPE_BASE_IMM_EXTEND32 {{23{inst[12]}}, inst[12], inst[6:5], inst[2], inst[11:10], inst[4:3], 1'b0}

`define CJ_TYPE_BASE_IMM          {inst[12], inst[8], inst[10:9], inst[6], inst[7], inst[2], inst[11], inst[5:3]}
`define CJ_TYPE_BASE_IMM_EXTEND32 {{20{inst[12]}}, inst[12], inst[8], inst[10:9], inst[6], inst[7], inst[2], inst[11], inst[5:3], 1'b0}

`define INST_EXE_PARAS \
    bit [31:0] inst, \
    ref csr_library csr_lib, \
    ref dsa_mmio_library dsa_mmio_lib, \
    ref reg_data_s gpr_s, \
    ref mem_library mem_lib, \
    ref core_state_s core_state

`define INST_DECLARATION(N) \
    riscv_``N inst_``N;


`define CUSTOM_INST_DECLARATION(N) \
    custom_inst_``N inst_``N;

`define CUSTOM_INST_CREATE(N,M) \
    inst_``N = custom_inst_``N::type_id::create({"inst_", ``M}); \
    inst_queue.push_back(inst_``N); \
    inst_``N.inst_exe_log = inst_exe_log;

`define INST_CREATE(N,M) \
    inst_``N = riscv_``N::type_id::create({"inst_", ``M}); \
    inst_queue.push_back(inst_``N); \
    inst_``N.inst_exe_log = inst_exe_log;

`define CUSTOM_INST_REF_CREATE \
    `CUSTOM_INST_CREATE(dsaw, "dsaw")  \
    `CUSTOM_INST_CREATE(dsawi, "dsawi")  \
    `CUSTOM_INST_CREATE(dsar, "dsar")  \
    `CUSTOM_INST_CREATE(dsari, "dsari")

`define RV32I_INST_REF_CREATE \
    `INST_CREATE(fence, "fence") \
    `INST_CREATE(ecall, "ecall") \
    `INST_CREATE(ebreak, "ebreak") \
    `INST_CREATE(add, "add") \
    `INST_CREATE(addi, "addi") \
    `INST_CREATE(and, "and") \
    `INST_CREATE(andi, "andi") \
    `INST_CREATE(auipc, "auipc") \
    `INST_CREATE(beq, "beq") \
    `INST_CREATE(bge, "bge") \
    `INST_CREATE(bgeu, "bgeu") \
    `INST_CREATE(blt, "blt") \
    `INST_CREATE(bltu, "bltu") \
    `INST_CREATE(bne, "bne") \
    `INST_CREATE(jal, "jal") \
    `INST_CREATE(jalr, "jalr") \
    `INST_CREATE(lui, "lui") \
    `INST_CREATE(ori, "ori") \
    `INST_CREATE(sll, "sll") \
    `INST_CREATE(slli, "slli") \
    `INST_CREATE(slt, "slt") \
    `INST_CREATE(sltu, "sltu") \
    `INST_CREATE(slti, "slti") \
    `INST_CREATE(sltiu, "sltiu") \
    `INST_CREATE(sra, "sra") \
    `INST_CREATE(srai, "srai") \
    `INST_CREATE(srl, "srl") \
    `INST_CREATE(srli, "srli") \
    `INST_CREATE(sub, "sub") \
    `INST_CREATE(xor, "xor") \
    `INST_CREATE(xori, "xori") \
    `INST_CREATE(or, "or") \
    `INST_CREATE(lb, "lb") \
    `INST_CREATE(lbu, "lbu") \
    `INST_CREATE(lh, "lh") \
    `INST_CREATE(lhu, "lhu") \
    `INST_CREATE(lw, "lw") \
    `INST_CREATE(sb, "sb") \
    `INST_CREATE(sh, "sh") \
    `INST_CREATE(sw, "sw")

`define RV32M_INST_REF_CREATE \
    `INST_CREATE(div, "div") \
    `INST_CREATE(divu, "divu") \
    `INST_CREATE(rem, "rem") \
    `INST_CREATE(remu, "remu") \
    `INST_CREATE(mul, "mul") \
    `INST_CREATE(mulh, "mulh") \
    `INST_CREATE(mulhu, "mulhu") \
    `INST_CREATE(mulhsu, "mulhsu")

`define RV32A_INST_REF_CREATE \
    `INST_CREATE(amoadd_w, "amoadd_w") \
    `INST_CREATE(amoand_w, "amoand_w") \
    `INST_CREATE(amoxor_w, "amoxor_w") \
    `INST_CREATE(amoor_w, "amoor_w") \
    `INST_CREATE(amomin_w, "amomin_w") \
    `INST_CREATE(amominu_w, "amominu_w") \
    `INST_CREATE(amomax_w, "amomax_w") \
    `INST_CREATE(amomaxu_w, "amomaxu_w") \
    `INST_CREATE(amoswap_w, "amoswap_w") \
    `INST_CREATE(lr_w, "lr_w") \
    `INST_CREATE(sc_w, "sc_w")

`define RV32C_INST_REF_CREATE \
    `INST_CREATE(c_addi4spn, "c_addi4spn") \
    `INST_CREATE(c_nop, "c_nop") \
    `INST_CREATE(c_addi, "c_addi") \
    `INST_CREATE(c_li, "c_li") \
    `INST_CREATE(c_addi16sp, "c_addi16sp") \
    `INST_CREATE(c_lui, "c_lui") \
    `INST_CREATE(c_srli, "c_srli") \
    `INST_CREATE(c_srai, "c_srai") \
    `INST_CREATE(c_andi, "c_andi") \
    `INST_CREATE(c_sub, "c_sub") \
    `INST_CREATE(c_xor, "c_xor") \
    `INST_CREATE(c_or, "c_or") \
    `INST_CREATE(c_and, "c_and") \
    `INST_CREATE(c_slli, "c_slli") \
    `INST_CREATE(c_j, "c_j") \
    `INST_CREATE(c_jal, "c_jal") \
    `INST_CREATE(c_beqz, "c_beqz") \
    `INST_CREATE(c_bnez, "c_bnez") \
    `INST_CREATE(c_lw, "c_lw") \
    `INST_CREATE(c_sw, "c_sw") \
    `INST_CREATE(c_lwsp, "c_lwsp") \
    `INST_CREATE(c_swsp, "c_swsp") \
    `INST_CREATE(c_jr, "c_jr") \
    `INST_CREATE(c_mv, "c_mv") \
    `INST_CREATE(c_ebreak, "c_ebreak") \
    `INST_CREATE(c_jalr, "c_jalr") \
    `INST_CREATE(c_add, "c_add")

// CSR support is pending. Keep the definition here but do not add it
// to inst_queue_gen() until the supported CSR instruction set is confirmed.
`define RV32ZICSR_INST_REF_CREATE \
    `INST_CREATE(csrrw, "csrrw") \
    `INST_CREATE(csrrs, "csrrs") \
    `INST_CREATE(csrrc, "csrrc") \
    `INST_CREATE(csrrwi, "csrrwi") \
    `INST_CREATE(csrrsi, "csrrsi") \
    `INST_CREATE(csrrci, "csrrci")

`define INST_NEW(N,S,U,M,V) \
    inst_name = ``N; \
    inst_set = ``S; \
    exe_unit = ``U; \
    const_ops_mask = ``M; \
    const_ops_val = ``V;

`define PC_ADD \
    core_state.pc = core_state.pc + 4;

`define C_PC_ADD \
    core_state.pc = core_state.pc + 2;

`define R_TYPE_EXE_STRING {"%8s", "\tx%0d[0x%08h], x%0d[0x%08h], x%0d[0x%08h]\n"}
`define R_TYPE_EXE_VAL \
    inst_name, \
    `RTYPE_RD, `GPR(`RTYPE_RD), \
    `RTYPE_RS1, rs1_val, \
    `RTYPE_RS2, rs2_val

`define S_TYPE_EXE_STRING {"%8s", "\tx%0d[0x%08h], 0x%08h(x%0d[0x%08h])\n"}
`define S_TYPE_EXE_VAL \
    inst_name, \
    `STYPE_RS2, rs2_val, \
    `STYPE_IMM_SIGN_EXTEND32, \
    `STYPE_RS1, rs1_val

`define I_TYPE_EXE_STRING {"%8s", "\tx%0d[0x%08h], 0x%08h(x%0d[0x%08h])\n"}
`define I_TYPE_EXE_VAL \
    inst_name, \
    `ITYPE_RD, `GPR(`ITYPE_RD), \
    `ITYPE_IMM_SIGN_EXTEND32, \
    `ITYPE_RS1, rs1_val

`define I_TYPE_IMM_SHIFT_EXE_STRING {"%8s", "\tx%0d[0x%08h], 0x%08h(x%0d[0x%08h])\n"}
`define I_TYPE_IMM_SHIFT_EXE_VAL \
    inst_name, \
    `ITYPE_RD, `GPR(`ITYPE_RD), \
    `ITYPE_SHAMT, \
    `ITYPE_RS1, rs1_val

`define U_TYPE_EXE_STRING {"%8s", "\tx%0d[0x%08h], 0x%08h\n"}
`define U_TYPE_EXE_VAL \
    inst_name, \
    `UTYPE_RD, `GPR(`UTYPE_RD), \
    `UTYPE_IMM

`define B_TYPE_EXE_STRING {"%8s", "\tx%0d[0x%08h], x%0d[0x%08h], 0x%08h\n"}
`define B_TYPE_EXE_VAL \
    inst_name, \
    `BTYPE_RS1, `GPR(`BTYPE_RS1), \
    `BTYPE_RS2, `GPR(`BTYPE_RS2), \
    core_state.pc

`define J_TYPE_EXE_STRING {"%8s", "\tx%0d[0x%08h], 0x%08h\n"}
`define J_TYPE_EXE_VAL \
    inst_name, \
    `JTYPE_RD, `GPR(`JTYPE_RD), \
    core_state.pc

`define NO_OPS_INST_EXE_STRING {inst_name, "\n"}


`define PRINT_RS1 \
    if(log_en) \
        $fwrite(inst_exe_log, "    rs1:x%0d=%08h\n", \
                `RTYPE_RS1, `GPR(`RTYPE_RS1));

`define PRINT_RD_BEFORE_EXE \
    if(log_en) \
        $fwrite(inst_exe_log, "    rd_before:x%0d=%08h\n", \
                `RTYPE_RD, `GPR(`RTYPE_RD));