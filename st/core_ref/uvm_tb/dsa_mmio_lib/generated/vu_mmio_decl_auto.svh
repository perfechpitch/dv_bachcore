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
localparam bit [31:0] REG_FILE_ADDR_BASE_ADDR = 32'h00002000;
typedef struct packed {
    bit [13:0] reserved_31_18;
    bit [1:0] rf_sel;
    bit [15:0] rf_addr;
} reg_file_addr_field_s;
reg_file_addr_field_s reg_file_addr;
bit [31:0] reg_file_addr_val;
typedef enum bit {PARAM_STATIC, PARAM_DYNAMIC} param_src_e;
typedef struct {
    bit [15:0] vl;
    bit data_type;
    bit [2:0] round_mode;
    param_src_e src;
} type_vl_param_s;
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
    bit [7:0] vrf_wt_p0_src;
    bit [7:0] vrf_wt_p1_src;
    bit [7:0] mrf_wt_src;
    bit [7:0] srf_wt_en;
} prf_op_param_s;
typedef struct {
    bit [2:0] config_idx;
    type_vl_param_s type_vl;
    vrf_rd_index_param_s vrf_rd_index;
    vrf_wt_index_param_s vrf_wt_index;
    valu0_op_param_s valu0_op;
    valu1_op_param_s valu1_op;
    valu2_op_param_s valu2_op;
    prf_op_param_s prf_op;
} vu_exec_param_s;
vu_exec_param_s exec_param;
bit trigger_pending;
