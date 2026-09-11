// ============================================================================
// Filename             : inst_gen_enum.sv
// Author               : kippy
// Created On           : 2026-6-24 15:46
// Last Modified        :
// Update Count         :
// Description          : inst_gen 指令类型枚举
// Source               : fixed template (auto-generated)
// Generator            : gen_inst_gen.py
// DO NOT EDIT          : re-run the generator after enum updates.
// ============================================================================
`ifndef INST_GEN_ENUM_SV
`define INST_GEN_ENUM_SV
typedef enum {
    DSARI,
    DSAR,
    DSAWI,
    DSAW,
    INST_END
} inst_e;

typedef enum {
    MU_INST,
    VU_INST,
    INST_TYPE_END
} inst_type_e;

typedef enum {
    MU_INST_TYPE_NONE,
    MU_INST_TYPE_ADD,
    MU_INST_TYPE_SUB,
    MU_INST_TYPE_MUL,
    MU_INST_TYPE_DIV,
    MU_INST_TYPE_MOD,
    MU_INST_END
} mu_inst_type_e;

typedef enum {
    CROSS_INST_1,
    CROSS_INST_2,
    CROSS_INST_3,
    CROSS_INST_4,
    CROSS_INST_5,
    CROSS_INST_6,
    CROSS_INST_7,
    CROSS_INST_8,
    CROSS_INST_9,
    CROSS_INST_10,
    CROSS_INST_11,
    VU_INST_END
} vu_inst_type_e;

typedef enum {
    VU_NOP,
    VU_LU,
    VU_SU,
    VU_VALU0,
    VU_VALU1,
    VU_VALU2,
    VU_VSFU0,
    VU_VSFU1,
    VU_MEXE,
    VU_SEXE,
    CROSS_INST_1_OP_END
} cross_inst_1_op_e;

typedef enum {
    VU_LU_LD_FP8E4M3_V,
    VU_LU_LD_MXFP8_V,
    VU_LU_LD_BF16_V,
    VU_LU_LD_FP32_V,
    VU_LU_LD_MASK,
    VU_LU_LD_S_FP32,
    VU_LU_TYPE_END
} vu_lu_type_e;

typedef enum {
    VU_SU_ST_FP8E4M3_V,
    VU_SU_ST_MXFP8_V,
    VU_SU_ST_BF16_V,
    VU_SU_ST_FP32_V,
    VU_SU_ST_MASK,
    VU_SU_ST_S_FP32,
    VU_SU_TYPE_END
} vu_su_type_e;

typedef enum {
    VU_VALU0_VFADD_VV,
    VU_VALU0_VFADD_VF,
    VU_VALU0_VFSUB_VV,
    VU_VALU0_VFSUB_VF,
    VU_VALU0_VFRSUB_VF,
    VU_VALU0_VFMUL_VV,
    VU_VALU0_VFMUL_VF,
    VU_VALU0_VFDIV_VV,
    VU_VALU0_VFMIN_VV,
    VU_VALU0_VFMIN_VF,
    VU_VALU0_VFMAX_VV,
    VU_VALU0_VFMAX_VF,
    VU_VALU0_VFMV_V_F,
    VU_VALU0_VFMV_S_F,
    VU_VALU0_VFMACC_VV,
    VU_VALU0_VFMACC_VF,
    VU_VALU0_VFNMACC_VV,
    VU_VALU0_VFNMACC_VF,
    VU_VALU0_VFMSAC_VV,
    VU_VALU0_VFMSAC_VF,
    VU_VALU0_VFNMSAC_VV,
    VU_VALU0_VFNMSAC_VF,
    VU_VALU0_VFSGNJ_VV,
    VU_VALU0_VFSGNJ_VF,
    VU_VALU0_VFSGNJN_VV,
    VU_VALU0_VFSGNJN_VF,
    VU_VALU0_VFSGNJX_VV,
    VU_VALU0_VFSGNJX_VF,
    VU_VALU0_VMFEQ_VV,
    VU_VALU0_VMFEQ_VF,
    VU_VALU0_VMFNE_VV,
    VU_VALU0_VMFNE_VF,
    VU_VALU0_VMFLT_VV,
    VU_VALU0_VMFLT_VF,
    VU_VALU0_VMFLE_VV,
    VU_VALU0_VMFLE_VF,
    VU_VALU0_VMFGT_VF,
    VU_VALU0_VMFGE_VF,
    VU_VALU0_VFCLASS_MV,
    VU_VALU0_VFMERGE_VFM,
    VU_VALU0_VFMERGE_VVM,
    VU_VALU0_TYPE_END
} vu_valu0_type_e;

typedef enum {
    VU_VALU1_VFADD_VV,
    VU_VALU1_VFADD_VF,
    VU_VALU1_VFSUB_VV,
    VU_VALU1_VFSUB_VF,
    VU_VALU1_VFRSUB_VF,
    VU_VALU1_VFMUL_VV,
    VU_VALU1_VFMUL_VF,
    VU_VALU1_VFMIN_VV,
    VU_VALU1_VFMIN_VF,
    VU_VALU1_VFMAX_VV,
    VU_VALU1_VFMAX_VF,
    VU_VALU1_VFMV_V_F,
    VU_VALU1_VFMV_F_S,
    VU_VALU1_VFREDUSUM_VS,
    VU_VALU1_VFREDMAX_VS,
    VU_VALU1_VFREDMIN_VS,
    VU_VALU1_VSORTMAX16_V,
    VU_VALU1_VSORTMIN16_V,
    VU_VALU1_TYPE_END
} vu_valu1_type_e;

typedef enum {
    VU_VALU2_VFADD_VV,
    VU_VALU2_VFADD_VF,
    VU_VALU2_VFSUB_VV,
    VU_VALU2_VFSUB_VF,
    VU_VALU2_VFRSUB_VF,
    VU_VALU2_VFMUL_VV,
    VU_VALU2_VFMUL_VF,
    VU_VALU2_VFMIN_VV,
    VU_VALU2_VFMIN_VF,
    VU_VALU2_VFMAX_VV,
    VU_VALU2_VFMAX_VF,
    VU_VALU2_VFMV_V_F,
    VU_VALU2_VMV_V_V,
    VU_VALU2_VSWAP2_V,
    VU_VALU2_VFSLIDE1UP_VF,
    VU_VALU2_VFSLIDE1DOWN_VF,
    VU_VALU2_TYPE_END
} vu_valu2_type_e;

typedef enum {
    VU_VSFU_VFSIN_V,
    VU_VSFU_VFCOS_V,
    VU_VSFU_VFTANH_V,
    VU_VSFU_VFSIGMOID_V,
    VU_VSFU_VFEXP_V,
    VU_VSFU_VFEXP2_V,
    VU_VSFU_VFLN_V,
    VU_VSFU_VFLOG2_V,
    VU_VSFU_VFSQRT_V,
    VU_VSFU_VFRCP_V,
    VU_VSFU_VFRSQRT_V,
    VU_VSFU_CUSTOM_FIT,
    VU_VSFU_TYPE_END
} vu_vsfu_type_e;

typedef enum {
    VU_MEXE_VMAND_MM,
    VU_MEXE_VMNAND_MM,
    VU_MEXE_VMANDN_MM,
    VU_MEXE_VMXOR_MM,
    VU_MEXE_VMOR_MM,
    VU_MEXE_VMNOR_MM,
    VU_MEXE_VMORN_MM,
    VU_MEXE_VMXNOR_MM,
    VU_MEXE_VCPOP_M,
    VU_MEXE_VFIRST_M,
    VU_MEXE_VMSBF_M,
    VU_MEXE_VMSIF_M,
    VU_MEXE_VMSOF_M,
    VU_MEXE_VMIUSET_MV,
    VU_MEXE_VMISET_MV,
    VU_MEXE_TYPE_END
} vu_mexe_type_e;

typedef enum {
    VU_SEXE_FADD_S,
    VU_SEXE_FSUB_S,
    VU_SEXE_FMUL_S,
    VU_SEXE_FDIV_S,
    VU_SEXE_FSQRT_S,
    VU_SEXE_FRSQRT_S,
    VU_SEXE_FRCP_S,
    VU_SEXE_TYPE_END
} vu_sexe_type_e;

typedef enum {
    VU_CROSS_INST_2_NOP,
    CROSS_INST_2_TYPE_END
} cross_inst_2_type_e;

typedef enum {
    VU_CROSS_INST_3_NOP,
    CROSS_INST_3_TYPE_END
} cross_inst_3_type_e;

typedef enum {
    VU_CROSS_INST_4_NOP,
    CROSS_INST_4_TYPE_END
} cross_inst_4_type_e;

typedef enum {
    VU_CROSS_INST_5_NOP,
    CROSS_INST_5_TYPE_END
} cross_inst_5_type_e;

typedef enum {
    VU_CROSS_INST_6_NOP,
    CROSS_INST_6_TYPE_END
} cross_inst_6_type_e;

typedef enum {
    VU_CROSS_INST_7_NOP,
    CROSS_INST_7_TYPE_END
} cross_inst_7_type_e;

typedef enum {
    VU_CROSS_INST_8_NOP,
    CROSS_INST_8_TYPE_END
} cross_inst_8_type_e;

typedef enum {
    VU_CROSS_INST_9_NOP,
    CROSS_INST_9_TYPE_END
} cross_inst_9_type_e;

typedef enum {
    VU_CROSS_INST_10_NOP,
    CROSS_INST_10_TYPE_END
} cross_inst_10_type_e;

typedef enum {
    VU_CROSS_INST_11_NOP,
    CROSS_INST_11_TYPE_END
} cross_inst_11_type_e;

typedef enum {
    VU_REG_READ_CAT_DYN_PARAM,
    VU_REG_READ_CAT_STATIC_CFG,
    VU_REG_READ_CAT_DSA_RF,
    VU_REG_READ_CAT_STATUS,
    VU_REG_READ_CAT_PROFILE,
    VU_REG_READ_CAT_ILLEGAL,
    VU_REG_READ_CAT_END
} vu_reg_read_addr_cat_e;
`endif
