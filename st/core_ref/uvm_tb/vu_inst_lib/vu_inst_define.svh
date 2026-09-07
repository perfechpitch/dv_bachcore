`ifndef VU_INST_DEFINE_SVH
`define VU_INST_DEFINE_SVH

`define VU_VRF_ENTRY_W 1024
`define VU_VRF_ENTRY_NUM 512
`define VU_MRF_ENTRY_W 64
`define VU_MRF_ENTRY_NUM 512
`define VU_SRF_ENTRY_NUM 64
`define VU_FP32_ELEMS_PER_ENTRY 32
`define VU_BF16_ELEMS_PER_ENTRY 64
`define VU_MAX_VL 16384
`define VU_MAX_VEC_CHUNKS 512

// LU/SU opcodes (the two spaces are independent but intentionally aligned).
`define VU_OPCODE_LDST_FP8E4M3 8'h01
`define VU_OPCODE_LDST_MXFP8   8'h02
`define VU_OPCODE_LDST_BF16    8'h03
`define VU_OPCODE_LDST_FP32    8'h04
`define VU_OPCODE_LDST_MASK    8'h05
`define VU_OPCODE_LDST_SCALAR  8'h06

// VALU opcodes. VALU0/1/2 share this encoding space.
`define VU_OPCODE_NOP          8'h00
`define VU_OPCODE_VFADD_VV     8'h01
`define VU_OPCODE_VFADD_VF     8'h02
`define VU_OPCODE_VFSUB_VV     8'h03
`define VU_OPCODE_VFSUB_VF     8'h04
`define VU_OPCODE_VFRSUB_VF    8'h05
`define VU_OPCODE_VFMUL_VV     8'h06
`define VU_OPCODE_VFMUL_VF     8'h07
`define VU_OPCODE_VFDIV_VV     8'h08
`define VU_OPCODE_VFMIN_VV     8'h10
`define VU_OPCODE_VFMIN_VF     8'h11
`define VU_OPCODE_VFMAX_VV     8'h12
`define VU_OPCODE_VFMAX_VF     8'h13
`define VU_OPCODE_VFMV_V_F     8'h20
`define VU_OPCODE_VFMV_S_F     8'h21
`define VU_OPCODE_VFMV_F_S     8'h22
`define VU_OPCODE_VMV_V_V      8'h23
`define VU_OPCODE_VFMACC_VV    8'h30
`define VU_OPCODE_VFMACC_VF    8'h31
`define VU_OPCODE_VFNMACC_VV   8'h32
`define VU_OPCODE_VFNMACC_VF   8'h33
`define VU_OPCODE_VFMSAC_VV    8'h34
`define VU_OPCODE_VFMSAC_VF    8'h35
`define VU_OPCODE_VFNMSAC_VV   8'h36
`define VU_OPCODE_VFNMSAC_VF   8'h37
`define VU_OPCODE_VFSGNJ_VV    8'h40
`define VU_OPCODE_VFSGNJ_VF    8'h41
`define VU_OPCODE_VFSGNJN_VV   8'h42
`define VU_OPCODE_VFSGNJN_VF   8'h43
`define VU_OPCODE_VFSGNJX_VV   8'h44
`define VU_OPCODE_VFSGNJX_VF   8'h45
`define VU_OPCODE_VMFEQ_VV     8'h50
`define VU_OPCODE_VMFEQ_VF     8'h51
`define VU_OPCODE_VMFNE_VV     8'h52
`define VU_OPCODE_VMFNE_VF     8'h53
`define VU_OPCODE_VMFLT_VV     8'h54
`define VU_OPCODE_VMFLT_VF     8'h55
`define VU_OPCODE_VMFLE_VV     8'h56
`define VU_OPCODE_VMFLE_VF     8'h57
`define VU_OPCODE_VMFGT_VF     8'h58
`define VU_OPCODE_VMFGE_VF     8'h59
`define VU_OPCODE_VFCLASS_MV   8'h60
`define VU_OPCODE_VFMERGE_VFM  8'h61
`define VU_OPCODE_VFMERGE_VVM  8'h62
`define VU_OPCODE_VFREDUSUM_VS 8'h70
`define VU_OPCODE_VFREDMAX_VS  8'h71
`define VU_OPCODE_VFREDMIN_VS  8'h72
`define VU_OPCODE_VSORTMAX16_V 8'h73
`define VU_OPCODE_VSORTMIN16_V 8'h74

// Compatibility aliases used by the original two-op implementation.
`define VU_OPCODE_VADD_VV `VU_OPCODE_VFADD_VV
`define VU_OPCODE_VMIN_VV `VU_OPCODE_VFMIN_VV

// VSFU opcodes.
`define VU_OPCODE_VFSIN_V       8'h01
`define VU_OPCODE_VFCOS_V       8'h02
`define VU_OPCODE_VFTANH_V      8'h03
`define VU_OPCODE_VFSIGMOID_V   8'h04
`define VU_OPCODE_VFEXP_V       8'h05
`define VU_OPCODE_VFEXP2_V      8'h06
`define VU_OPCODE_VFLN_V        8'h07
`define VU_OPCODE_VFLOG2_V      8'h08
`define VU_OPCODE_VFSQRT_V      8'h09
`define VU_OPCODE_VFRCP_V       8'h0a
`define VU_OPCODE_VFRSQRT_V     8'h0b
`define VU_OPCODE_VFCUSTOM_V    8'h0c

// MEXE opcodes.
`define VU_OPCODE_VMAND_MM      8'h01
`define VU_OPCODE_VMNAND_MM     8'h02
`define VU_OPCODE_VMANDN_MM     8'h03
`define VU_OPCODE_VMXOR_MM      8'h04
`define VU_OPCODE_VMOR_MM       8'h05
`define VU_OPCODE_VMNOR_MM      8'h06
`define VU_OPCODE_VMORN_MM      8'h07
`define VU_OPCODE_VMXNOR_MM     8'h08
`define VU_OPCODE_VCPOP_M       8'h10
`define VU_OPCODE_VFIRST_M      8'h11
`define VU_OPCODE_VMSBF_M       8'h12
`define VU_OPCODE_VMSIF_M       8'h13
`define VU_OPCODE_VMSOF_M       8'h14
`define VU_OPCODE_VMIUSET_MV    8'h15
`define VU_OPCODE_VMISET_MV     8'h16

// SEXE opcodes.
`define VU_OPCODE_FADD_S        8'h01
`define VU_OPCODE_FSUB_S        8'h02
`define VU_OPCODE_FMUL_S        8'h03
`define VU_OPCODE_FDIV_S        8'h04
`define VU_OPCODE_FSQRT_S       8'h05
`define VU_OPCODE_FRSQRT_S      8'h06
`define VU_OPCODE_FRCP_S        8'h07

// Global source-select encoding.
`define VU_SRC_NONE   8'h00
`define VU_SRC_LU     8'h01
`define VU_SRC_VALU0  8'h02
`define VU_SRC_VALU1  8'h03
`define VU_SRC_VALU2  8'h04
`define VU_SRC_VSFU0  8'h05
`define VU_SRC_VSFU1  8'h06
`define VU_SRC_MEXE   8'h10
`define VU_SRC_SEXE0  8'h20
`define VU_SRC_SEXE1  8'h21
`define VU_SRC_SEXE2  8'h22
`define VU_SRC_VRF_P0 8'h30
`define VU_SRC_VRF_P1 8'h31
`define VU_SRC_MRF_P0 8'h40
`define VU_SRC_MRF_P1 8'h41
`define VU_SRC_SRF_P0 8'h50
`define VU_SRC_SRF_P1 8'h51
`define VU_SRC_SRF_P2 8'h52
`define VU_SRC_SRF_P3 8'h53
`define VU_SRC_SRF_P4 8'h54
`define VU_SRC_SRF_P5 8'h55
`define VU_SRC_SRF_P6 8'h56
`define VU_SRC_SRF_P7 8'h57

`endif
