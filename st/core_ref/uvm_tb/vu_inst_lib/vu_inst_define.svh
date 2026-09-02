`ifndef VU_INST_DEFINE_SVH
`define VU_INST_DEFINE_SVH
`define VU_VRF_ENTRY_W 1024
`define VU_VRF_ENTRY_NUM 512
`define VU_FP32_ELEMS_PER_ENTRY 32
`define VU_MAX_VL 16384
`define VU_OPCODE_NOP 8'h00
`define VU_OPCODE_VADD_VV 8'h01
`define VU_SRC_LU 8'h01
`define VU_SRC_VALU0 8'h02
`define VU_SRC_VALU1 8'h03
`define VU_SRC_VALU2 8'h04
`define VU_SRC_VSFU0 8'h05
`define VU_SRC_VSFU1 8'h06
`define VU_SRC_VRF_P0 8'h30
`define VU_SRC_VRF_P1 8'h31
`endif
