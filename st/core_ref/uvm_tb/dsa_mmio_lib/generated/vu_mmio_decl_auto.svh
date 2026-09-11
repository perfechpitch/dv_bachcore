// AUTO-GENERATED from vu_mmio.json. DO NOT EDIT.

bit [1023:0] vrf[512];
bit [63:0] mrf[512];
bit [31:0] srf[64];
bit [1023:0] lu_bypass;
bit [1023:0] valu0_bypass;
bit [1023:0] valu1_bypass;
bit [1023:0] valu2_bypass;
bit [1023:0] vsfu0_bypass;
bit [1023:0] vsfu1_bypass;
localparam bit [31:0] REG_FILE_DATA_BASE_ADDR = 32'h00002004;
localparam bit [31:0] MACRO_INST_TRIGGER_BASE_ADDR = 32'h00000000;
typedef struct packed {
    bit [5:0] reserved_31_26;
    bit data_broadcast;
    bit macro_inst_fence;
    bit [1:0] reserved_23_22;
    bit [3:0] stream_id;
    bit stream_id_override;
    bit event_en;
    bit [4:0] reserved_15_11;
    bit [2:0] config_idx;
    bit [7:0] static_dynamic_mask;
} macro_inst_trigger_field_s;
macro_inst_trigger_field_s macro_inst_trigger;
bit [31:0] macro_inst_trigger_val;
localparam bit [31:0] TYPE_VL_BASE_ADDR = 32'h00000004;
typedef struct packed {
    bit [11:0] reserved_31_20;
    bit [2:0] round_mode;
    bit data_type;
    bit [15:0] vl;
} type_vl_field_s;
type_vl_field_s type_vl;
bit [31:0] type_vl_val;
localparam bit [31:0] LD_ADDR_BASE_ADDR = 32'h00000008;
typedef struct packed {
    bit [31:0] cm_addr;
} ld_addr_field_s;
ld_addr_field_s ld_addr;
bit [31:0] ld_addr_val;
localparam bit [31:0] ST_ADDR_BASE_ADDR = 32'h0000000C;
typedef struct packed {
    bit [31:0] cm_addr;
} st_addr_field_s;
st_addr_field_s st_addr;
bit [31:0] st_addr_val;
localparam bit [31:0] VRF_RD_INDEX_BASE_ADDR = 32'h00000010;
typedef struct packed {
    bit [15:0] vrf_rd_p1_idx;
    bit [15:0] vrf_rd_p0_idx;
} vrf_rd_index_field_s;
vrf_rd_index_field_s vrf_rd_index;
bit [31:0] vrf_rd_index_val;
localparam bit [31:0] VRF_WT_INDEX_BASE_ADDR = 32'h00000014;
typedef struct packed {
    bit [15:0] vrf_wt_p1_idx;
    bit [15:0] vrf_wt_p0_idx;
} vrf_wt_index_field_s;
vrf_wt_index_field_s vrf_wt_index;
bit [31:0] vrf_wt_index_val;
localparam bit [31:0] MRF_RD_INDEX_BASE_ADDR = 32'h00000018;
typedef struct packed {
    bit [15:0] mrf_rd_p1_idx;
    bit [15:0] mrf_rd_p0_idx;
} mrf_rd_index_field_s;
mrf_rd_index_field_s mrf_rd_index;
bit [31:0] mrf_rd_index_val;
localparam bit [31:0] MRF_WT_INDEX_BASE_ADDR = 32'h0000001C;
typedef struct packed {
    bit [15:0] reserved_31_16;
    bit [15:0] mrf_wt_idx;
} mrf_wt_index_field_s;
mrf_wt_index_field_s mrf_wt_index;
bit [31:0] mrf_wt_index_val;
localparam bit [31:0] SRF_RD_INDEX_0_BASE_ADDR = 32'h00000020;
typedef struct packed {
    bit [7:0] srf_rd_p3_idx;
    bit [7:0] srf_rd_p2_idx;
    bit [7:0] srf_rd_p1_idx;
    bit [7:0] srf_rd_p0_idx;
} srf_rd_index_0_field_s;
srf_rd_index_0_field_s srf_rd_index_0;
bit [31:0] srf_rd_index_0_val;
localparam bit [31:0] SRF_RD_INDEX_1_BASE_ADDR = 32'h00000024;
typedef struct packed {
    bit [7:0] srf_rd_p7_idx;
    bit [7:0] srf_rd_p6_idx;
    bit [7:0] srf_rd_p5_idx;
    bit [7:0] srf_rd_p4_idx;
} srf_rd_index_1_field_s;
srf_rd_index_1_field_s srf_rd_index_1;
bit [31:0] srf_rd_index_1_val;
localparam bit [31:0] SRF_WT_INDEX_0_BASE_ADDR = 32'h00000028;
typedef struct packed {
    bit [7:0] srf_wt_p3_idx;
    bit [7:0] srf_wt_p2_idx;
    bit [7:0] srf_wt_p1_idx;
    bit [7:0] srf_wt_p0_idx;
} srf_wt_index_0_field_s;
srf_wt_index_0_field_s srf_wt_index_0;
bit [31:0] srf_wt_index_0_val;
localparam bit [31:0] SRF_WT_INDEX_1_BASE_ADDR = 32'h0000002C;
typedef struct packed {
    bit [15:0] reserved_31_16;
    bit [7:0] srf_wt_p5_idx;
    bit [7:0] srf_wt_p4_idx;
} srf_wt_index_1_field_s;
srf_wt_index_1_field_s srf_wt_index_1;
bit [31:0] srf_wt_index_1_val;
localparam bit [31:0] LU_OP_BASE_ADDR = 32'h00001000;
localparam int LU_OP_COUNT = 8;
localparam bit [31:0] LU_OP_STRIDE = 32'h00000100;
localparam bit [31:0] LU_OP_END_ADDR = 32'h00001700;
typedef struct packed {
    bit [7:0] reserved_31_24;
    bit [7:0] stride_skip;
    bit [7:0] stride_run;
    bit [7:0] opcode;
} lu_op_field_s;
lu_op_field_s lu_op[8];
bit [31:0] lu_op_val[8];
localparam bit [31:0] SU_OP_BASE_ADDR = 32'h00001004;
localparam int SU_OP_COUNT = 8;
localparam bit [31:0] SU_OP_STRIDE = 32'h00000100;
localparam bit [31:0] SU_OP_END_ADDR = 32'h00001704;
typedef struct packed {
    bit [14:0] reserved_31_17;
    bit mxfp8_scale_round;
    bit [7:0] src_sel;
    bit [7:0] opcode;
} su_op_field_s;
su_op_field_s su_op[8];
bit [31:0] su_op_val[8];
localparam bit [31:0] VALU0_OP_BASE_ADDR = 32'h00001008;
localparam int VALU0_OP_COUNT = 8;
localparam bit [31:0] VALU0_OP_STRIDE = 32'h00000100;
localparam bit [31:0] VALU0_OP_END_ADDR = 32'h00001708;
typedef struct packed {
    bit [7:0] src3_sel;
    bit [7:0] src2_sel;
    bit [7:0] src1_sel;
    bit [7:0] opcode;
} valu0_op_field_s;
valu0_op_field_s valu0_op[8];
bit [31:0] valu0_op_val[8];
localparam bit [31:0] VALU1_OP_BASE_ADDR = 32'h0000100C;
localparam int VALU1_OP_COUNT = 8;
localparam bit [31:0] VALU1_OP_STRIDE = 32'h00000100;
localparam bit [31:0] VALU1_OP_END_ADDR = 32'h0000170C;
typedef struct packed {
    bit [7:0] src3_sel;
    bit [7:0] src2_sel;
    bit [7:0] src1_sel;
    bit [7:0] opcode;
} valu1_op_field_s;
valu1_op_field_s valu1_op[8];
bit [31:0] valu1_op_val[8];
localparam bit [31:0] VALU2_OP_BASE_ADDR = 32'h00001010;
localparam int VALU2_OP_COUNT = 8;
localparam bit [31:0] VALU2_OP_STRIDE = 32'h00000100;
localparam bit [31:0] VALU2_OP_END_ADDR = 32'h00001710;
typedef struct packed {
    bit [7:0] src3_sel;
    bit [7:0] src2_sel;
    bit [7:0] src1_sel;
    bit [7:0] opcode;
} valu2_op_field_s;
valu2_op_field_s valu2_op[8];
bit [31:0] valu2_op_val[8];
localparam bit [31:0] VSFU_OP_BASE_ADDR = 32'h00001014;
localparam int VSFU_OP_COUNT = 8;
localparam bit [31:0] VSFU_OP_STRIDE = 32'h00000100;
localparam bit [31:0] VSFU_OP_END_ADDR = 32'h00001714;
typedef struct packed {
    bit [7:0] vsfu1_src1_sel;
    bit [7:0] vsfu1_opcode;
    bit [7:0] vsfu0_src1_sel;
    bit [7:0] vsfu0_opcode;
} vsfu_op_field_s;
vsfu_op_field_s vsfu_op[8];
bit [31:0] vsfu_op_val[8];
localparam bit [31:0] MEXE_OP_BASE_ADDR = 32'h00001018;
localparam int MEXE_OP_COUNT = 8;
localparam bit [31:0] MEXE_OP_STRIDE = 32'h00000100;
localparam bit [31:0] MEXE_OP_END_ADDR = 32'h00001718;
typedef struct packed {
    bit [7:0] reserved_31_24;
    bit [7:0] src2_sel;
    bit [7:0] src1_sel;
    bit [7:0] opcode;
} mexe_op_field_s;
mexe_op_field_s mexe_op[8];
bit [31:0] mexe_op_val[8];
localparam bit [31:0] SEXE0_OP_BASE_ADDR = 32'h0000101C;
localparam int SEXE0_OP_COUNT = 8;
localparam bit [31:0] SEXE0_OP_STRIDE = 32'h00000100;
localparam bit [31:0] SEXE0_OP_END_ADDR = 32'h0000171C;
typedef struct packed {
    bit [7:0] reserved_31_24;
    bit [7:0] src2_sel;
    bit [7:0] src1_sel;
    bit [7:0] opcode;
} sexe0_op_field_s;
sexe0_op_field_s sexe0_op[8];
bit [31:0] sexe0_op_val[8];
localparam bit [31:0] SEXE1_OP_BASE_ADDR = 32'h00001020;
localparam int SEXE1_OP_COUNT = 8;
localparam bit [31:0] SEXE1_OP_STRIDE = 32'h00000100;
localparam bit [31:0] SEXE1_OP_END_ADDR = 32'h00001720;
typedef struct packed {
    bit [7:0] reserved_31_24;
    bit [7:0] src2_sel;
    bit [7:0] src1_sel;
    bit [7:0] opcode;
} sexe1_op_field_s;
sexe1_op_field_s sexe1_op[8];
bit [31:0] sexe1_op_val[8];
localparam bit [31:0] SEXE2_OP_BASE_ADDR = 32'h00001024;
localparam int SEXE2_OP_COUNT = 8;
localparam bit [31:0] SEXE2_OP_STRIDE = 32'h00000100;
localparam bit [31:0] SEXE2_OP_END_ADDR = 32'h00001724;
typedef struct packed {
    bit [7:0] reserved_31_24;
    bit [7:0] src2_sel;
    bit [7:0] src1_sel;
    bit [7:0] opcode;
} sexe2_op_field_s;
sexe2_op_field_s sexe2_op[8];
bit [31:0] sexe2_op_val[8];
localparam bit [31:0] MASK_OP_BASE_ADDR = 32'h00001028;
localparam int MASK_OP_COUNT = 8;
localparam bit [31:0] MASK_OP_STRIDE = 32'h00000100;
localparam bit [31:0] MASK_OP_END_ADDR = 32'h00001728;
typedef struct packed {
    bit [7:0] reserved_31_24;
    bit [7:0] valu2_mask_sel;
    bit [7:0] valu1_mask_sel;
    bit [7:0] valu0_mask_sel;
} mask_op_field_s;
mask_op_field_s mask_op[8];
bit [31:0] mask_op_val[8];
localparam bit [31:0] PRF_OP_BASE_ADDR = 32'h0000102C;
localparam int PRF_OP_COUNT = 8;
localparam bit [31:0] PRF_OP_STRIDE = 32'h00000100;
localparam bit [31:0] PRF_OP_END_ADDR = 32'h0000172C;
typedef struct packed {
    bit [7:0] srf_wt_en;
    bit [7:0] mrf_wt_src;
    bit [7:0] vrf_wt_p1_src;
    bit [7:0] vrf_wt_p0_src;
} prf_op_field_s;
prf_op_field_s prf_op[8];
bit [31:0] prf_op_val[8];
localparam bit [31:0] STATIC_TYPE_VL_BASE_ADDR = 32'h00001030;
localparam int STATIC_TYPE_VL_COUNT = 8;
localparam bit [31:0] STATIC_TYPE_VL_STRIDE = 32'h00000100;
localparam bit [31:0] STATIC_TYPE_VL_END_ADDR = 32'h00001730;
typedef struct packed {
    bit [11:0] reserved_31_20;
    bit [2:0] round_mode;
    bit data_type;
    bit [15:0] vl;
} static_type_vl_field_s;
static_type_vl_field_s static_type_vl[8];
bit [31:0] static_type_vl_val[8];
localparam bit [31:0] STATIC_LD_ADDR_BASE_ADDR = 32'h00001034;
localparam int STATIC_LD_ADDR_COUNT = 8;
localparam bit [31:0] STATIC_LD_ADDR_STRIDE = 32'h00000100;
localparam bit [31:0] STATIC_LD_ADDR_END_ADDR = 32'h00001734;
typedef struct packed {
    bit [31:0] cm_addr;
} static_ld_addr_field_s;
static_ld_addr_field_s static_ld_addr[8];
bit [31:0] static_ld_addr_val[8];
localparam bit [31:0] STATIC_ST_ADDR_BASE_ADDR = 32'h00001038;
localparam int STATIC_ST_ADDR_COUNT = 8;
localparam bit [31:0] STATIC_ST_ADDR_STRIDE = 32'h00000100;
localparam bit [31:0] STATIC_ST_ADDR_END_ADDR = 32'h00001738;
typedef struct packed {
    bit [31:0] cm_addr;
} static_st_addr_field_s;
static_st_addr_field_s static_st_addr[8];
bit [31:0] static_st_addr_val[8];
localparam bit [31:0] STATIC_VRF_RD_INDEX_BASE_ADDR = 32'h0000103C;
localparam int STATIC_VRF_RD_INDEX_COUNT = 8;
localparam bit [31:0] STATIC_VRF_RD_INDEX_STRIDE = 32'h00000100;
localparam bit [31:0] STATIC_VRF_RD_INDEX_END_ADDR = 32'h0000173C;
typedef struct packed {
    bit [15:0] vrf_rd_p1_idx;
    bit [15:0] vrf_rd_p0_idx;
} static_vrf_rd_index_field_s;
static_vrf_rd_index_field_s static_vrf_rd_index[8];
bit [31:0] static_vrf_rd_index_val[8];
localparam bit [31:0] STATIC_VRF_WT_INDEX_BASE_ADDR = 32'h00001040;
localparam int STATIC_VRF_WT_INDEX_COUNT = 8;
localparam bit [31:0] STATIC_VRF_WT_INDEX_STRIDE = 32'h00000100;
localparam bit [31:0] STATIC_VRF_WT_INDEX_END_ADDR = 32'h00001740;
typedef struct packed {
    bit [15:0] vrf_wt_p1_idx;
    bit [15:0] vrf_wt_p0_idx;
} static_vrf_wt_index_field_s;
static_vrf_wt_index_field_s static_vrf_wt_index[8];
bit [31:0] static_vrf_wt_index_val[8];
localparam bit [31:0] STATIC_MRF_RD_INDEX_BASE_ADDR = 32'h00001044;
localparam int STATIC_MRF_RD_INDEX_COUNT = 8;
localparam bit [31:0] STATIC_MRF_RD_INDEX_STRIDE = 32'h00000100;
localparam bit [31:0] STATIC_MRF_RD_INDEX_END_ADDR = 32'h00001744;
typedef struct packed {
    bit [15:0] mrf_rd_p1_idx;
    bit [15:0] mrf_rd_p0_idx;
} static_mrf_rd_index_field_s;
static_mrf_rd_index_field_s static_mrf_rd_index[8];
bit [31:0] static_mrf_rd_index_val[8];
localparam bit [31:0] STATIC_MRF_WT_INDEX_BASE_ADDR = 32'h00001048;
localparam int STATIC_MRF_WT_INDEX_COUNT = 8;
localparam bit [31:0] STATIC_MRF_WT_INDEX_STRIDE = 32'h00000100;
localparam bit [31:0] STATIC_MRF_WT_INDEX_END_ADDR = 32'h00001748;
typedef struct packed {
    bit [15:0] reserved_31_16;
    bit [15:0] mrf_wt_idx;
} static_mrf_wt_index_field_s;
static_mrf_wt_index_field_s static_mrf_wt_index[8];
bit [31:0] static_mrf_wt_index_val[8];
localparam bit [31:0] STATIC_SRF_RD_INDEX_0_BASE_ADDR = 32'h0000104C;
localparam int STATIC_SRF_RD_INDEX_0_COUNT = 8;
localparam bit [31:0] STATIC_SRF_RD_INDEX_0_STRIDE = 32'h00000100;
localparam bit [31:0] STATIC_SRF_RD_INDEX_0_END_ADDR = 32'h0000174C;
typedef struct packed {
    bit [7:0] srf_rd_p3_idx;
    bit [7:0] srf_rd_p2_idx;
    bit [7:0] srf_rd_p1_idx;
    bit [7:0] srf_rd_p0_idx;
} static_srf_rd_index_0_field_s;
static_srf_rd_index_0_field_s static_srf_rd_index_0[8];
bit [31:0] static_srf_rd_index_0_val[8];
localparam bit [31:0] STATIC_SRF_RD_INDEX_1_BASE_ADDR = 32'h00001050;
localparam int STATIC_SRF_RD_INDEX_1_COUNT = 8;
localparam bit [31:0] STATIC_SRF_RD_INDEX_1_STRIDE = 32'h00000100;
localparam bit [31:0] STATIC_SRF_RD_INDEX_1_END_ADDR = 32'h00001750;
typedef struct packed {
    bit [7:0] srf_rd_p7_idx;
    bit [7:0] srf_rd_p6_idx;
    bit [7:0] srf_rd_p5_idx;
    bit [7:0] srf_rd_p4_idx;
} static_srf_rd_index_1_field_s;
static_srf_rd_index_1_field_s static_srf_rd_index_1[8];
bit [31:0] static_srf_rd_index_1_val[8];
localparam bit [31:0] STATIC_SRF_WT_INDEX_0_BASE_ADDR = 32'h00001054;
localparam int STATIC_SRF_WT_INDEX_0_COUNT = 8;
localparam bit [31:0] STATIC_SRF_WT_INDEX_0_STRIDE = 32'h00000100;
localparam bit [31:0] STATIC_SRF_WT_INDEX_0_END_ADDR = 32'h00001754;
typedef struct packed {
    bit [7:0] srf_wt_p3_idx;
    bit [7:0] srf_wt_p2_idx;
    bit [7:0] srf_wt_p1_idx;
    bit [7:0] srf_wt_p0_idx;
} static_srf_wt_index_0_field_s;
static_srf_wt_index_0_field_s static_srf_wt_index_0[8];
bit [31:0] static_srf_wt_index_0_val[8];
localparam bit [31:0] STATIC_SRF_WT_INDEX_1_BASE_ADDR = 32'h00001058;
localparam int STATIC_SRF_WT_INDEX_1_COUNT = 8;
localparam bit [31:0] STATIC_SRF_WT_INDEX_1_STRIDE = 32'h00000100;
localparam bit [31:0] STATIC_SRF_WT_INDEX_1_END_ADDR = 32'h00001758;
typedef struct packed {
    bit [15:0] reserved_31_16;
    bit [7:0] srf_wt_p5_idx;
    bit [7:0] srf_wt_p4_idx;
} static_srf_wt_index_1_field_s;
static_srf_wt_index_1_field_s static_srf_wt_index_1[8];
bit [31:0] static_srf_wt_index_1_val[8];
localparam bit [31:0] REG_FILE_ADDR_BASE_ADDR = 32'h00002000;
typedef struct packed {
    bit [13:0] reserved_31_18;
    bit [1:0] rf_sel;
    bit [15:0] rf_addr;
} reg_file_addr_field_s;
reg_file_addr_field_s reg_file_addr;
bit [31:0] reg_file_addr_val;
localparam bit [31:0] MACRO_INST_LEFT_BASE_ADDR = 32'h00003000;
typedef struct packed {
    bit [31:0] macro_inst_left;
} macro_inst_left_field_s;
macro_inst_left_field_s macro_inst_left;
bit [31:0] macro_inst_left_val;
localparam bit [31:0] STATUS_BASE_ADDR = 32'h00003004;
typedef struct packed {
    bit [27:0] reserved_31_4;
    bit error_flag;
    bit isq_empty;
    bit isq_full;
    bit busy;
} status_field_s;
status_field_s status;
bit [31:0] status_val;
localparam bit [31:0] ERROR_CODE_BASE_ADDR = 32'h00003008;
typedef struct packed {
    bit [24:0] reserved_31_7;
    bit data_cvt_error;
    bit cm_resp_error;
    bit cm_addr_error;
    bit rf_idx_error;
    bit cfg_error;
    bit reserved_1_1;
    bit reg_addr_error;
} error_code_field_s;
error_code_field_s error_code;
bit [31:0] error_code_val;
localparam bit [31:0] ERROR_INFO_BASE_ADDR = 32'h0000300C;
typedef struct packed {
    bit [11:0] reserved_31_20;
    bit valid;
    bit [2:0] first_err;
    bit [3:0] err_unit;
    bit reserved_11_11;
    bit [2:0] config_idx;
    bit [7:0] static_dynamic_mask;
} error_info_field_s;
error_info_field_s error_info;
bit [31:0] error_info_val;
localparam bit [31:0] SNAPSHOT_ADDR_BASE_ADDR = 32'h00003010;
typedef struct packed {
    bit [19:0] reserved_31_12;
    bit [7:0] snap_sel;
    bit [3:0] snap_idx;
} snapshot_addr_field_s;
snapshot_addr_field_s snapshot_addr;
bit [31:0] snapshot_addr_val;
localparam bit [31:0] SNAPSHOT_DATA_BASE_ADDR = 32'h00003014;
typedef struct packed {
    bit [31:0] snap_data;
} snapshot_data_field_s;
snapshot_data_field_s snapshot_data;
bit [31:0] snapshot_data_val;
localparam bit [31:0] PROFILE_CTRL_BASE_ADDR = 32'h00004000;
typedef struct packed {
    bit [29:0] reserved_31_2;
    bit clear;
    bit run;
} profile_ctrl_field_s;
profile_ctrl_field_s profile_ctrl;
bit [31:0] profile_ctrl_val;
localparam bit [31:0] PROF_RUN_CYCLE_LO_BASE_ADDR = 32'h00004008;
typedef struct packed {
    bit [31:0] count;
} prof_run_cycle_lo_field_s;
prof_run_cycle_lo_field_s prof_run_cycle_lo;
bit [31:0] prof_run_cycle_lo_val;
localparam bit [31:0] PROF_RUN_CYCLE_HI_BASE_ADDR = 32'h0000400C;
typedef struct packed {
    bit [31:0] count;
} prof_run_cycle_hi_field_s;
prof_run_cycle_hi_field_s prof_run_cycle_hi;
bit [31:0] prof_run_cycle_hi_val;
localparam bit [31:0] TOTAL_BUSY_CYCLE_LO_BASE_ADDR = 32'h00004010;
typedef struct packed {
    bit [31:0] count;
} total_busy_cycle_lo_field_s;
total_busy_cycle_lo_field_s total_busy_cycle_lo;
bit [31:0] total_busy_cycle_lo_val;
localparam bit [31:0] TOTAL_BUSY_CYCLE_HI_BASE_ADDR = 32'h00004014;
typedef struct packed {
    bit [31:0] count;
} total_busy_cycle_hi_field_s;
total_busy_cycle_hi_field_s total_busy_cycle_hi;
bit [31:0] total_busy_cycle_hi_val;
localparam bit [31:0] CFG_WR_NUM_LO_BASE_ADDR = 32'h00004018;
typedef struct packed {
    bit [31:0] count;
} cfg_wr_num_lo_field_s;
cfg_wr_num_lo_field_s cfg_wr_num_lo;
bit [31:0] cfg_wr_num_lo_val;
localparam bit [31:0] CFG_WR_NUM_HI_BASE_ADDR = 32'h0000401C;
typedef struct packed {
    bit [31:0] count;
} cfg_wr_num_hi_field_s;
cfg_wr_num_hi_field_s cfg_wr_num_hi;
bit [31:0] cfg_wr_num_hi_val;
localparam bit [31:0] CFG_WR_STALL_CYCLE_LO_BASE_ADDR = 32'h00004020;
typedef struct packed {
    bit [31:0] count;
} cfg_wr_stall_cycle_lo_field_s;
cfg_wr_stall_cycle_lo_field_s cfg_wr_stall_cycle_lo;
bit [31:0] cfg_wr_stall_cycle_lo_val;
localparam bit [31:0] CFG_WR_STALL_CYCLE_HI_BASE_ADDR = 32'h00004024;
typedef struct packed {
    bit [31:0] count;
} cfg_wr_stall_cycle_hi_field_s;
cfg_wr_stall_cycle_hi_field_s cfg_wr_stall_cycle_hi;
bit [31:0] cfg_wr_stall_cycle_hi_val;
localparam bit [31:0] MACRO_INST_TOTAL_NUM_LO_BASE_ADDR = 32'h00004028;
typedef struct packed {
    bit [31:0] count;
} macro_inst_total_num_lo_field_s;
macro_inst_total_num_lo_field_s macro_inst_total_num_lo;
bit [31:0] macro_inst_total_num_lo_val;
localparam bit [31:0] MACRO_INST_TOTAL_NUM_HI_BASE_ADDR = 32'h0000402C;
typedef struct packed {
    bit [31:0] count;
} macro_inst_total_num_hi_field_s;
macro_inst_total_num_hi_field_s macro_inst_total_num_hi;
bit [31:0] macro_inst_total_num_hi_val;
localparam bit [31:0] MACRO_INST_RETIRE_NUM_LO_BASE_ADDR = 32'h00004030;
typedef struct packed {
    bit [31:0] count;
} macro_inst_retire_num_lo_field_s;
macro_inst_retire_num_lo_field_s macro_inst_retire_num_lo;
bit [31:0] macro_inst_retire_num_lo_val;
localparam bit [31:0] MACRO_INST_RETIRE_NUM_HI_BASE_ADDR = 32'h00004034;
typedef struct packed {
    bit [31:0] count;
} macro_inst_retire_num_hi_field_s;
macro_inst_retire_num_hi_field_s macro_inst_retire_num_hi;
bit [31:0] macro_inst_retire_num_hi_val;
localparam bit [31:0] ISQ_FULL_CYCLE_LO_BASE_ADDR = 32'h00004038;
typedef struct packed {
    bit [31:0] count;
} isq_full_cycle_lo_field_s;
isq_full_cycle_lo_field_s isq_full_cycle_lo;
bit [31:0] isq_full_cycle_lo_val;
localparam bit [31:0] ISQ_FULL_CYCLE_HI_BASE_ADDR = 32'h0000403C;
typedef struct packed {
    bit [31:0] count;
} isq_full_cycle_hi_field_s;
isq_full_cycle_hi_field_s isq_full_cycle_hi;
bit [31:0] isq_full_cycle_hi_val;
localparam bit [31:0] ISSUE_STALL_FENCE_CYCLE_LO_BASE_ADDR = 32'h00004040;
typedef struct packed {
    bit [31:0] count;
} issue_stall_fence_cycle_lo_field_s;
issue_stall_fence_cycle_lo_field_s issue_stall_fence_cycle_lo;
bit [31:0] issue_stall_fence_cycle_lo_val;
localparam bit [31:0] ISSUE_STALL_FENCE_CYCLE_HI_BASE_ADDR = 32'h00004044;
typedef struct packed {
    bit [31:0] count;
} issue_stall_fence_cycle_hi_field_s;
issue_stall_fence_cycle_hi_field_s issue_stall_fence_cycle_hi;
bit [31:0] issue_stall_fence_cycle_hi_val;
localparam bit [31:0] ISSUE_STALL_BCAST_CYCLE_LO_BASE_ADDR = 32'h00004048;
typedef struct packed {
    bit [31:0] count;
} issue_stall_bcast_cycle_lo_field_s;
issue_stall_bcast_cycle_lo_field_s issue_stall_bcast_cycle_lo;
bit [31:0] issue_stall_bcast_cycle_lo_val;
localparam bit [31:0] ISSUE_STALL_BCAST_CYCLE_HI_BASE_ADDR = 32'h0000404C;
typedef struct packed {
    bit [31:0] count;
} issue_stall_bcast_cycle_hi_field_s;
issue_stall_bcast_cycle_hi_field_s issue_stall_bcast_cycle_hi;
bit [31:0] issue_stall_bcast_cycle_hi_val;
localparam bit [31:0] ISSUE_STALL_DEP_CYCLE_LO_BASE_ADDR = 32'h00004050;
typedef struct packed {
    bit [31:0] count;
} issue_stall_dep_cycle_lo_field_s;
issue_stall_dep_cycle_lo_field_s issue_stall_dep_cycle_lo;
bit [31:0] issue_stall_dep_cycle_lo_val;
localparam bit [31:0] ISSUE_STALL_DEP_CYCLE_HI_BASE_ADDR = 32'h00004054;
typedef struct packed {
    bit [31:0] count;
} issue_stall_dep_cycle_hi_field_s;
issue_stall_dep_cycle_hi_field_s issue_stall_dep_cycle_hi;
bit [31:0] issue_stall_dep_cycle_hi_val;
localparam bit [31:0] ISSUE_STALL_EU_CYCLE_LO_BASE_ADDR = 32'h00004058;
typedef struct packed {
    bit [31:0] count;
} issue_stall_eu_cycle_lo_field_s;
issue_stall_eu_cycle_lo_field_s issue_stall_eu_cycle_lo;
bit [31:0] issue_stall_eu_cycle_lo_val;
localparam bit [31:0] ISSUE_STALL_EU_CYCLE_HI_BASE_ADDR = 32'h0000405C;
typedef struct packed {
    bit [31:0] count;
} issue_stall_eu_cycle_hi_field_s;
issue_stall_eu_cycle_hi_field_s issue_stall_eu_cycle_hi;
bit [31:0] issue_stall_eu_cycle_hi_val;
localparam bit [31:0] ISSUE_STARVE_CYCLE_LO_BASE_ADDR = 32'h00004060;
typedef struct packed {
    bit [31:0] count;
} issue_starve_cycle_lo_field_s;
issue_starve_cycle_lo_field_s issue_starve_cycle_lo;
bit [31:0] issue_starve_cycle_lo_val;
localparam bit [31:0] ISSUE_STARVE_CYCLE_HI_BASE_ADDR = 32'h00004064;
typedef struct packed {
    bit [31:0] count;
} issue_starve_cycle_hi_field_s;
issue_starve_cycle_hi_field_s issue_starve_cycle_hi;
bit [31:0] issue_starve_cycle_hi_val;
localparam bit [31:0] LU_BUSY_CYCLE_LO_BASE_ADDR = 32'h00004068;
typedef struct packed {
    bit [31:0] count;
} lu_busy_cycle_lo_field_s;
lu_busy_cycle_lo_field_s lu_busy_cycle_lo;
bit [31:0] lu_busy_cycle_lo_val;
localparam bit [31:0] LU_BUSY_CYCLE_HI_BASE_ADDR = 32'h0000406C;
typedef struct packed {
    bit [31:0] count;
} lu_busy_cycle_hi_field_s;
lu_busy_cycle_hi_field_s lu_busy_cycle_hi;
bit [31:0] lu_busy_cycle_hi_val;
localparam bit [31:0] CM_LD_REQ_NUM_LO_BASE_ADDR = 32'h00004070;
typedef struct packed {
    bit [31:0] count;
} cm_ld_req_num_lo_field_s;
cm_ld_req_num_lo_field_s cm_ld_req_num_lo;
bit [31:0] cm_ld_req_num_lo_val;
localparam bit [31:0] CM_LD_REQ_NUM_HI_BASE_ADDR = 32'h00004074;
typedef struct packed {
    bit [31:0] count;
} cm_ld_req_num_hi_field_s;
cm_ld_req_num_hi_field_s cm_ld_req_num_hi;
bit [31:0] cm_ld_req_num_hi_val;
localparam bit [31:0] CM_LD_STALL_CYCLE_LO_BASE_ADDR = 32'h00004078;
typedef struct packed {
    bit [31:0] count;
} cm_ld_stall_cycle_lo_field_s;
cm_ld_stall_cycle_lo_field_s cm_ld_stall_cycle_lo;
bit [31:0] cm_ld_stall_cycle_lo_val;
localparam bit [31:0] CM_LD_STALL_CYCLE_HI_BASE_ADDR = 32'h0000407C;
typedef struct packed {
    bit [31:0] count;
} cm_ld_stall_cycle_hi_field_s;
cm_ld_stall_cycle_hi_field_s cm_ld_stall_cycle_hi;
bit [31:0] cm_ld_stall_cycle_hi_val;
localparam bit [31:0] SU_BUSY_CYCLE_LO_BASE_ADDR = 32'h00004080;
typedef struct packed {
    bit [31:0] count;
} su_busy_cycle_lo_field_s;
su_busy_cycle_lo_field_s su_busy_cycle_lo;
bit [31:0] su_busy_cycle_lo_val;
localparam bit [31:0] SU_BUSY_CYCLE_HI_BASE_ADDR = 32'h00004084;
typedef struct packed {
    bit [31:0] count;
} su_busy_cycle_hi_field_s;
su_busy_cycle_hi_field_s su_busy_cycle_hi;
bit [31:0] su_busy_cycle_hi_val;
localparam bit [31:0] CM_ST_REQ_NUM_LO_BASE_ADDR = 32'h00004088;
typedef struct packed {
    bit [31:0] count;
} cm_st_req_num_lo_field_s;
cm_st_req_num_lo_field_s cm_st_req_num_lo;
bit [31:0] cm_st_req_num_lo_val;
localparam bit [31:0] CM_ST_REQ_NUM_HI_BASE_ADDR = 32'h0000408C;
typedef struct packed {
    bit [31:0] count;
} cm_st_req_num_hi_field_s;
cm_st_req_num_hi_field_s cm_st_req_num_hi;
bit [31:0] cm_st_req_num_hi_val;
localparam bit [31:0] CM_ST_STALL_CYCLE_LO_BASE_ADDR = 32'h00004090;
typedef struct packed {
    bit [31:0] count;
} cm_st_stall_cycle_lo_field_s;
cm_st_stall_cycle_lo_field_s cm_st_stall_cycle_lo;
bit [31:0] cm_st_stall_cycle_lo_val;
localparam bit [31:0] CM_ST_STALL_CYCLE_HI_BASE_ADDR = 32'h00004094;
typedef struct packed {
    bit [31:0] count;
} cm_st_stall_cycle_hi_field_s;
cm_st_stall_cycle_hi_field_s cm_st_stall_cycle_hi;
bit [31:0] cm_st_stall_cycle_hi_val;
localparam bit [31:0] VALU0_BUSY_CYCLE_LO_BASE_ADDR = 32'h00004098;
typedef struct packed {
    bit [31:0] count;
} valu0_busy_cycle_lo_field_s;
valu0_busy_cycle_lo_field_s valu0_busy_cycle_lo;
bit [31:0] valu0_busy_cycle_lo_val;
localparam bit [31:0] VALU0_BUSY_CYCLE_HI_BASE_ADDR = 32'h0000409C;
typedef struct packed {
    bit [31:0] count;
} valu0_busy_cycle_hi_field_s;
valu0_busy_cycle_hi_field_s valu0_busy_cycle_hi;
bit [31:0] valu0_busy_cycle_hi_val;
localparam bit [31:0] VALU1_BUSY_CYCLE_LO_BASE_ADDR = 32'h000040A0;
typedef struct packed {
    bit [31:0] count;
} valu1_busy_cycle_lo_field_s;
valu1_busy_cycle_lo_field_s valu1_busy_cycle_lo;
bit [31:0] valu1_busy_cycle_lo_val;
localparam bit [31:0] VALU1_BUSY_CYCLE_HI_BASE_ADDR = 32'h000040A4;
typedef struct packed {
    bit [31:0] count;
} valu1_busy_cycle_hi_field_s;
valu1_busy_cycle_hi_field_s valu1_busy_cycle_hi;
bit [31:0] valu1_busy_cycle_hi_val;
localparam bit [31:0] VALU2_BUSY_CYCLE_LO_BASE_ADDR = 32'h000040A8;
typedef struct packed {
    bit [31:0] count;
} valu2_busy_cycle_lo_field_s;
valu2_busy_cycle_lo_field_s valu2_busy_cycle_lo;
bit [31:0] valu2_busy_cycle_lo_val;
localparam bit [31:0] VALU2_BUSY_CYCLE_HI_BASE_ADDR = 32'h000040AC;
typedef struct packed {
    bit [31:0] count;
} valu2_busy_cycle_hi_field_s;
valu2_busy_cycle_hi_field_s valu2_busy_cycle_hi;
bit [31:0] valu2_busy_cycle_hi_val;
localparam bit [31:0] VSFU0_BUSY_CYCLE_LO_BASE_ADDR = 32'h000040B0;
typedef struct packed {
    bit [31:0] count;
} vsfu0_busy_cycle_lo_field_s;
vsfu0_busy_cycle_lo_field_s vsfu0_busy_cycle_lo;
bit [31:0] vsfu0_busy_cycle_lo_val;
localparam bit [31:0] VSFU0_BUSY_CYCLE_HI_BASE_ADDR = 32'h000040B4;
typedef struct packed {
    bit [31:0] count;
} vsfu0_busy_cycle_hi_field_s;
vsfu0_busy_cycle_hi_field_s vsfu0_busy_cycle_hi;
bit [31:0] vsfu0_busy_cycle_hi_val;
localparam bit [31:0] VSFU1_BUSY_CYCLE_LO_BASE_ADDR = 32'h000040B8;
typedef struct packed {
    bit [31:0] count;
} vsfu1_busy_cycle_lo_field_s;
vsfu1_busy_cycle_lo_field_s vsfu1_busy_cycle_lo;
bit [31:0] vsfu1_busy_cycle_lo_val;
localparam bit [31:0] VSFU1_BUSY_CYCLE_HI_BASE_ADDR = 32'h000040BC;
typedef struct packed {
    bit [31:0] count;
} vsfu1_busy_cycle_hi_field_s;
vsfu1_busy_cycle_hi_field_s vsfu1_busy_cycle_hi;
bit [31:0] vsfu1_busy_cycle_hi_val;
localparam bit [31:0] MEXE_BUSY_CYCLE_LO_BASE_ADDR = 32'h000040C0;
typedef struct packed {
    bit [31:0] count;
} mexe_busy_cycle_lo_field_s;
mexe_busy_cycle_lo_field_s mexe_busy_cycle_lo;
bit [31:0] mexe_busy_cycle_lo_val;
localparam bit [31:0] MEXE_BUSY_CYCLE_HI_BASE_ADDR = 32'h000040C4;
typedef struct packed {
    bit [31:0] count;
} mexe_busy_cycle_hi_field_s;
mexe_busy_cycle_hi_field_s mexe_busy_cycle_hi;
bit [31:0] mexe_busy_cycle_hi_val;
localparam bit [31:0] SEXE_BUSY_CYCLE_LO_BASE_ADDR = 32'h000040C8;
typedef struct packed {
    bit [31:0] count;
} sexe_busy_cycle_lo_field_s;
sexe_busy_cycle_lo_field_s sexe_busy_cycle_lo;
bit [31:0] sexe_busy_cycle_lo_val;
localparam bit [31:0] SEXE_BUSY_CYCLE_HI_BASE_ADDR = 32'h000040CC;
typedef struct packed {
    bit [31:0] count;
} sexe_busy_cycle_hi_field_s;
sexe_busy_cycle_hi_field_s sexe_busy_cycle_hi;
bit [31:0] sexe_busy_cycle_hi_val;
localparam bit [31:0] VRF_RD_P0_BUSY_CYCLE_LO_BASE_ADDR = 32'h000040D0;
typedef struct packed {
    bit [31:0] count;
} vrf_rd_p0_busy_cycle_lo_field_s;
vrf_rd_p0_busy_cycle_lo_field_s vrf_rd_p0_busy_cycle_lo;
bit [31:0] vrf_rd_p0_busy_cycle_lo_val;
localparam bit [31:0] VRF_RD_P0_BUSY_CYCLE_HI_BASE_ADDR = 32'h000040D4;
typedef struct packed {
    bit [31:0] count;
} vrf_rd_p0_busy_cycle_hi_field_s;
vrf_rd_p0_busy_cycle_hi_field_s vrf_rd_p0_busy_cycle_hi;
bit [31:0] vrf_rd_p0_busy_cycle_hi_val;
localparam bit [31:0] VRF_RD_P1_BUSY_CYCLE_LO_BASE_ADDR = 32'h000040D8;
typedef struct packed {
    bit [31:0] count;
} vrf_rd_p1_busy_cycle_lo_field_s;
vrf_rd_p1_busy_cycle_lo_field_s vrf_rd_p1_busy_cycle_lo;
bit [31:0] vrf_rd_p1_busy_cycle_lo_val;
localparam bit [31:0] VRF_RD_P1_BUSY_CYCLE_HI_BASE_ADDR = 32'h000040DC;
typedef struct packed {
    bit [31:0] count;
} vrf_rd_p1_busy_cycle_hi_field_s;
vrf_rd_p1_busy_cycle_hi_field_s vrf_rd_p1_busy_cycle_hi;
bit [31:0] vrf_rd_p1_busy_cycle_hi_val;
localparam bit [31:0] VRF_WT_P0_BUSY_CYCLE_LO_BASE_ADDR = 32'h000040E0;
typedef struct packed {
    bit [31:0] count;
} vrf_wt_p0_busy_cycle_lo_field_s;
vrf_wt_p0_busy_cycle_lo_field_s vrf_wt_p0_busy_cycle_lo;
bit [31:0] vrf_wt_p0_busy_cycle_lo_val;
localparam bit [31:0] VRF_WT_P0_BUSY_CYCLE_HI_BASE_ADDR = 32'h000040E4;
typedef struct packed {
    bit [31:0] count;
} vrf_wt_p0_busy_cycle_hi_field_s;
vrf_wt_p0_busy_cycle_hi_field_s vrf_wt_p0_busy_cycle_hi;
bit [31:0] vrf_wt_p0_busy_cycle_hi_val;
localparam bit [31:0] VRF_WT_P1_BUSY_CYCLE_LO_BASE_ADDR = 32'h000040E8;
typedef struct packed {
    bit [31:0] count;
} vrf_wt_p1_busy_cycle_lo_field_s;
vrf_wt_p1_busy_cycle_lo_field_s vrf_wt_p1_busy_cycle_lo;
bit [31:0] vrf_wt_p1_busy_cycle_lo_val;
localparam bit [31:0] VRF_WT_P1_BUSY_CYCLE_HI_BASE_ADDR = 32'h000040EC;
typedef struct packed {
    bit [31:0] count;
} vrf_wt_p1_busy_cycle_hi_field_s;
vrf_wt_p1_busy_cycle_hi_field_s vrf_wt_p1_busy_cycle_hi;
bit [31:0] vrf_wt_p1_busy_cycle_hi_val;
localparam bit [31:0] MRF_WT_BUSY_CYCLE_LO_BASE_ADDR = 32'h000040F0;
typedef struct packed {
    bit [31:0] count;
} mrf_wt_busy_cycle_lo_field_s;
mrf_wt_busy_cycle_lo_field_s mrf_wt_busy_cycle_lo;
bit [31:0] mrf_wt_busy_cycle_lo_val;
localparam bit [31:0] MRF_WT_BUSY_CYCLE_HI_BASE_ADDR = 32'h000040F4;
typedef struct packed {
    bit [31:0] count;
} mrf_wt_busy_cycle_hi_field_s;
mrf_wt_busy_cycle_hi_field_s mrf_wt_busy_cycle_hi;
bit [31:0] mrf_wt_busy_cycle_hi_val;
typedef enum bit {PARAM_STATIC, PARAM_DYNAMIC} param_src_e;
typedef struct {
    bit [15:0] vl;
    bit data_type;
    bit [2:0] round_mode;
    param_src_e src;
} type_vl_param_s;
typedef struct {
    bit [31:0] cm_addr;
    param_src_e src;
} ld_addr_param_s;
typedef struct {
    bit [31:0] cm_addr;
    param_src_e src;
} st_addr_param_s;
typedef struct {
    bit [15:0] vrf_rd_p0_idx;
    bit [15:0] vrf_rd_p1_idx;
    param_src_e src;
} vrf_rd_index_param_s;
typedef struct {
    bit [15:0] vrf_wt_p0_idx;
    bit [15:0] vrf_wt_p1_idx;
    param_src_e src;
} vrf_wt_index_param_s;
typedef struct {
    bit [15:0] mrf_rd_p0_idx;
    bit [15:0] mrf_rd_p1_idx;
    param_src_e src;
} mrf_rd_index_param_s;
typedef struct {
    bit [15:0] mrf_wt_idx;
    param_src_e src;
} mrf_wt_index_param_s;
typedef struct {
    bit [7:0] srf_rd_p0_idx;
    bit [7:0] srf_rd_p1_idx;
    bit [7:0] srf_rd_p2_idx;
    bit [7:0] srf_rd_p3_idx;
    param_src_e src;
} srf_rd_index_0_param_s;
typedef struct {
    bit [7:0] srf_rd_p4_idx;
    bit [7:0] srf_rd_p5_idx;
    bit [7:0] srf_rd_p6_idx;
    bit [7:0] srf_rd_p7_idx;
    param_src_e src;
} srf_rd_index_1_param_s;
typedef struct {
    bit [7:0] srf_wt_p0_idx;
    bit [7:0] srf_wt_p1_idx;
    bit [7:0] srf_wt_p2_idx;
    bit [7:0] srf_wt_p3_idx;
    param_src_e src;
} srf_wt_index_0_param_s;
typedef struct {
    bit [7:0] srf_wt_p4_idx;
    bit [7:0] srf_wt_p5_idx;
    param_src_e src;
} srf_wt_index_1_param_s;
typedef struct {
    bit [7:0] opcode;
    bit [7:0] stride_run;
    bit [7:0] stride_skip;
} lu_op_param_s;
typedef struct {
    bit [7:0] opcode;
    bit [7:0] src_sel;
    bit mxfp8_scale_round;
} su_op_param_s;
typedef struct {
    bit [7:0] opcode;
    bit [7:0] src1_sel;
    bit [7:0] src2_sel;
    bit [7:0] src3_sel;
} valu0_op_param_s;
typedef struct {
    bit [7:0] opcode;
    bit [7:0] src1_sel;
    bit [7:0] src2_sel;
    bit [7:0] src3_sel;
} valu1_op_param_s;
typedef struct {
    bit [7:0] opcode;
    bit [7:0] src1_sel;
    bit [7:0] src2_sel;
    bit [7:0] src3_sel;
} valu2_op_param_s;
typedef struct {
    bit [7:0] vsfu0_opcode;
    bit [7:0] vsfu0_src1_sel;
    bit [7:0] vsfu1_opcode;
    bit [7:0] vsfu1_src1_sel;
} vsfu_op_param_s;
typedef struct {
    bit [7:0] opcode;
    bit [7:0] src1_sel;
    bit [7:0] src2_sel;
} mexe_op_param_s;
typedef struct {
    bit [7:0] opcode;
    bit [7:0] src1_sel;
    bit [7:0] src2_sel;
} sexe0_op_param_s;
typedef struct {
    bit [7:0] opcode;
    bit [7:0] src1_sel;
    bit [7:0] src2_sel;
} sexe1_op_param_s;
typedef struct {
    bit [7:0] opcode;
    bit [7:0] src1_sel;
    bit [7:0] src2_sel;
} sexe2_op_param_s;
typedef struct {
    bit [7:0] valu0_mask_sel;
    bit [7:0] valu1_mask_sel;
    bit [7:0] valu2_mask_sel;
} mask_op_param_s;
typedef struct {
    bit [7:0] vrf_wt_p0_src;
    bit [7:0] vrf_wt_p1_src;
    bit [7:0] mrf_wt_src;
    bit [7:0] srf_wt_en;
} prf_op_param_s;
typedef struct {
    bit [2:0] config_idx;
    type_vl_param_s type_vl;
    ld_addr_param_s ld_addr;
    st_addr_param_s st_addr;
    vrf_rd_index_param_s vrf_rd_index;
    vrf_wt_index_param_s vrf_wt_index;
    mrf_rd_index_param_s mrf_rd_index;
    mrf_wt_index_param_s mrf_wt_index;
    srf_rd_index_0_param_s srf_rd_index_0;
    srf_rd_index_1_param_s srf_rd_index_1;
    srf_wt_index_0_param_s srf_wt_index_0;
    srf_wt_index_1_param_s srf_wt_index_1;
    lu_op_param_s lu_op;
    su_op_param_s su_op;
    valu0_op_param_s valu0_op;
    valu1_op_param_s valu1_op;
    valu2_op_param_s valu2_op;
    vsfu_op_param_s vsfu_op;
    mexe_op_param_s mexe_op;
    sexe0_op_param_s sexe0_op;
    sexe1_op_param_s sexe1_op;
    sexe2_op_param_s sexe2_op;
    mask_op_param_s mask_op;
    prf_op_param_s prf_op;
} vu_exec_param_s;
vu_exec_param_s exec_param;
bit trigger_pending;
