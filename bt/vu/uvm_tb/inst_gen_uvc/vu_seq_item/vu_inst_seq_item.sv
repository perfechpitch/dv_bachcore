// ============================================================================
// Filename             : vu_inst_seq_item.sv
// Author               : kippy
// Created On           : 2026-6-24 15:46
// Last Modified        :
// Update Count         :
// Description          :
// Source               : vu_dsa.xlsx (auto-generated)
// Generator            : gen_inst_gen.py
// DO NOT EDIT          : re-run the generator after register-table updates.
// ============================================================================
`ifndef VU_INST_SEQ_ITEM_SV
`define VU_INST_SEQ_ITEM_SV
class vu_inst_seq_item extends uvm_sequence_item;
    // 寄存器位域 + pack；fix 位域约束见下方
    //----- 动态参数寄存器 : macro_inst_trigger -----
    rand logic [7:0]              macro_inst_trigger_static_dynamic_mask;
    rand logic [10:8]             macro_inst_trigger_config_idx;
    rand logic [16:16]            macro_inst_trigger_event_en;
    rand logic [17:17]            macro_inst_trigger_stream_id_override;
    rand logic [21:18]            macro_inst_trigger_stream_id;
    rand logic [24:24]            macro_inst_trigger_macro_inst_fence;
    rand logic [25:25]            macro_inst_trigger_data_broadcast;

    //----- TYPE_VL -----
    rand logic [15:0]             type_vl_vl;
    rand logic [16:16]            type_vl_data_type;
    rand logic [19:17]            type_vl_round_mode;
    rand logic [20:20]            type_vl_nan_inf_en;

    //----- LD_addr -----
    rand logic [31:0]             ld_addr_cm_addr;

    //----- ST_addr -----
    rand logic [31:0]             st_addr_cm_addr;

    //----- VRF_rd_index -----
    rand logic [15:0]             vrf_rd_index_vrf_rd_p0_idx;
    rand logic [31:16]            vrf_rd_index_vrf_rd_p1_idx;

    //----- VRF_wt_index -----
    rand logic [15:0]             vrf_wt_index_vrf_wt_p0_idx;
    rand logic [31:16]            vrf_wt_index_vrf_wt_p1_idx;

    //----- MRF_rd_index -----
    rand logic [15:0]             mrf_rd_index_mrf_rd_p0_idx;
    rand logic [31:16]            mrf_rd_index_mrf_rd_p1_idx;

    //----- MRF_wt_index -----
    rand logic [15:0]             mrf_wt_index_mrf_wt_idx;

    //----- SRF_rd_index_0 -----
    rand logic [7:0]              srf_rd_index_0_srf_rd_p0_idx;
    rand logic [15:8]             srf_rd_index_0_srf_rd_p1_idx;
    rand logic [23:16]            srf_rd_index_0_srf_rd_p2_idx;
    rand logic [31:24]            srf_rd_index_0_srf_rd_p3_idx;

    //----- SRF_rd_index_1 -----
    rand logic [7:0]              srf_rd_index_1_srf_rd_p4_idx;
    rand logic [15:8]             srf_rd_index_1_srf_rd_p5_idx;
    rand logic [23:16]            srf_rd_index_1_srf_rd_p6_idx;
    rand logic [31:24]            srf_rd_index_1_srf_rd_p7_idx;

    //----- SRF_wt_index_0 -----
    rand logic [7:0]              srf_wt_index_0_srf_wt_p0_idx;
    rand logic [15:8]             srf_wt_index_0_srf_wt_p1_idx;
    rand logic [23:16]            srf_wt_index_0_srf_wt_p2_idx;
    rand logic [31:24]            srf_wt_index_0_srf_wt_p3_idx;

    //----- SRF_wt_index_1 -----
    rand logic [7:0]              srf_wt_index_1_srf_wt_p4_idx;
    rand logic [15:8]             srf_wt_index_1_srf_wt_p5_idx;

    //----- 静态配置寄存器组 : LU_op -----
    rand logic [7:0]              lu_op_opcode;
    rand logic [15:8]             lu_op_stride_run;
    rand logic [23:16]            lu_op_stride_skip;

    //----- SU_op -----
    rand logic [7:0]              su_op_opcode;
    rand logic [15:8]             su_op_src_sel;
    rand logic [16:16]            su_op_mxfp8_scale_round;

    //----- VALU0_op -----
    rand logic [7:0]              valu0_op_opcode;
    rand logic [15:8]             valu0_op_src1_sel;
    rand logic [23:16]            valu0_op_src2_sel;
    rand logic [31:24]            valu0_op_src3_sel;

    //----- VALU1_op -----
    rand logic [7:0]              valu1_op_opcode;
    rand logic [15:8]             valu1_op_src1_sel;
    rand logic [23:16]            valu1_op_src2_sel;
    rand logic [31:24]            valu1_op_src3_sel;

    //----- VALU2_op -----
    rand logic [7:0]              valu2_op_opcode;
    rand logic [15:8]             valu2_op_src1_sel;
    rand logic [23:16]            valu2_op_src2_sel;
    rand logic [31:24]            valu2_op_src3_sel;

    //----- VSFU_op -----
    rand logic [7:0]              vsfu_op_vsfu0_opcode;
    rand logic [15:8]             vsfu_op_vsfu0_src1_sel;
    rand logic [23:16]            vsfu_op_vsfu1_opcode;
    rand logic [31:24]            vsfu_op_vsfu1_src1_sel;

    //----- MEXE_op -----
    rand logic [7:0]              mexe_op_opcode;
    rand logic [15:8]             mexe_op_src1_sel;
    rand logic [23:16]            mexe_op_src2_sel;

    //----- SEXE0_op -----
    rand logic [7:0]              sexe0_op_opcode;
    rand logic [15:8]             sexe0_op_src1_sel;
    rand logic [23:16]            sexe0_op_src2_sel;

    //----- SEXE1_op -----
    rand logic [7:0]              sexe1_op_opcode;
    rand logic [15:8]             sexe1_op_src1_sel;
    rand logic [23:16]            sexe1_op_src2_sel;

    //----- SEXE2_op -----
    rand logic [7:0]              sexe2_op_opcode;
    rand logic [15:8]             sexe2_op_src1_sel;
    rand logic [23:16]            sexe2_op_src2_sel;

    //----- mask_op -----
    rand logic [7:0]              mask_op_valu0_mask_sel;
    rand logic [15:8]             mask_op_valu1_mask_sel;
    rand logic [23:16]            mask_op_valu2_mask_sel;

    //----- PRF_op -----
    rand logic [7:0]              prf_op_vrf_wt_p0_src;
    rand logic [15:8]             prf_op_vrf_wt_p1_src;
    rand logic [23:16]            prf_op_mrf_wt_src;
    rand logic [31:24]            prf_op_srf_wt_en;

    //----- static_TYPE_VL -----
    rand logic [15:0]             static_type_vl_vl;
    rand logic [16:16]            static_type_vl_data_type;
    rand logic [19:17]            static_type_vl_round_mode;

    //----- static_LD_addr -----
    rand logic [31:0]             static_ld_addr_cm_addr;

    //----- static_ST_addr -----
    rand logic [31:0]             static_st_addr_cm_addr;

    //----- static_VRF_rd_index -----
    rand logic [15:0]             static_vrf_rd_index_vrf_rd_p0_idx;
    rand logic [31:16]            static_vrf_rd_index_vrf_rd_p1_idx;

    //----- static_VRF_wt_index -----
    rand logic [15:0]             static_vrf_wt_index_vrf_wt_p0_idx;
    rand logic [31:16]            static_vrf_wt_index_vrf_wt_p1_idx;

    //----- static_MRF_rd_index -----
    rand logic [15:0]             static_mrf_rd_index_mrf_rd_p0_idx;
    rand logic [31:16]            static_mrf_rd_index_mrf_rd_p1_idx;

    //----- static_MRF_wt_index -----
    rand logic [15:0]             static_mrf_wt_index_mrf_wt_idx;

    //----- static_SRF_rd_index_0 -----
    rand logic [7:0]              static_srf_rd_index_0_srf_rd_p0_idx;
    rand logic [15:8]             static_srf_rd_index_0_srf_rd_p1_idx;
    rand logic [23:16]            static_srf_rd_index_0_srf_rd_p2_idx;
    rand logic [31:24]            static_srf_rd_index_0_srf_rd_p3_idx;

    //----- static_SRF_rd_index_1 -----
    rand logic [7:0]              static_srf_rd_index_1_srf_rd_p4_idx;
    rand logic [15:8]             static_srf_rd_index_1_srf_rd_p5_idx;
    rand logic [23:16]            static_srf_rd_index_1_srf_rd_p6_idx;
    rand logic [31:24]            static_srf_rd_index_1_srf_rd_p7_idx;

    //----- static_SRF_wt_index_0 -----
    rand logic [7:0]              static_srf_wt_index_0_srf_wt_p0_idx;
    rand logic [15:8]             static_srf_wt_index_0_srf_wt_p1_idx;
    rand logic [23:16]            static_srf_wt_index_0_srf_wt_p2_idx;
    rand logic [31:24]            static_srf_wt_index_0_srf_wt_p3_idx;

    //----- static_SRF_wt_index_1 -----
    rand logic [7:0]              static_srf_wt_index_1_srf_wt_p4_idx;
    rand logic [15:8]             static_srf_wt_index_1_srf_wt_p5_idx;

    //----- INF_REPLACE_VALUE -----
    rand logic [31:0]             inf_replace_value_inf_replace_value;

    //----- NAN_REPLACE_VALUE -----
    rand logic [31:0]             nan_replace_value_nan_replace_value;


    inst_gen_config     inst_gen_cfg;

    `uvm_object_utils_begin(vu_inst_seq_item)
        `uvm_field_int          (macro_inst_trigger_static_dynamic_mask, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (macro_inst_trigger_config_idx, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (macro_inst_trigger_event_en, UVM_DEFAULT)
        `uvm_field_int          (macro_inst_trigger_stream_id_override, UVM_DEFAULT)
        `uvm_field_int          (macro_inst_trigger_stream_id, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (macro_inst_trigger_macro_inst_fence, UVM_DEFAULT)
        `uvm_field_int          (macro_inst_trigger_data_broadcast, UVM_DEFAULT)
        `uvm_field_int          (type_vl_vl, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (type_vl_data_type, UVM_DEFAULT)
        `uvm_field_int          (type_vl_round_mode, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (type_vl_nan_inf_en, UVM_DEFAULT)
        `uvm_field_int          (ld_addr_cm_addr, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (st_addr_cm_addr, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (vrf_rd_index_vrf_rd_p0_idx, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (vrf_rd_index_vrf_rd_p1_idx, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (vrf_wt_index_vrf_wt_p0_idx, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (vrf_wt_index_vrf_wt_p1_idx, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (mrf_rd_index_mrf_rd_p0_idx, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (mrf_rd_index_mrf_rd_p1_idx, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (mrf_wt_index_mrf_wt_idx, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (srf_rd_index_0_srf_rd_p0_idx, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (srf_rd_index_0_srf_rd_p1_idx, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (srf_rd_index_0_srf_rd_p2_idx, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (srf_rd_index_0_srf_rd_p3_idx, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (srf_rd_index_1_srf_rd_p4_idx, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (srf_rd_index_1_srf_rd_p5_idx, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (srf_rd_index_1_srf_rd_p6_idx, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (srf_rd_index_1_srf_rd_p7_idx, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (srf_wt_index_0_srf_wt_p0_idx, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (srf_wt_index_0_srf_wt_p1_idx, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (srf_wt_index_0_srf_wt_p2_idx, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (srf_wt_index_0_srf_wt_p3_idx, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (srf_wt_index_1_srf_wt_p4_idx, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (srf_wt_index_1_srf_wt_p5_idx, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (lu_op_opcode, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (lu_op_stride_run, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (lu_op_stride_skip, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (su_op_opcode, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (su_op_src_sel, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (su_op_mxfp8_scale_round, UVM_DEFAULT)
        `uvm_field_int          (valu0_op_opcode, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (valu0_op_src1_sel, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (valu0_op_src2_sel, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (valu0_op_src3_sel, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (valu1_op_opcode, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (valu1_op_src1_sel, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (valu1_op_src2_sel, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (valu1_op_src3_sel, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (valu2_op_opcode, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (valu2_op_src1_sel, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (valu2_op_src2_sel, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (valu2_op_src3_sel, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (vsfu_op_vsfu0_opcode, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (vsfu_op_vsfu0_src1_sel, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (vsfu_op_vsfu1_opcode, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (vsfu_op_vsfu1_src1_sel, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (mexe_op_opcode, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (mexe_op_src1_sel, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (mexe_op_src2_sel, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (sexe0_op_opcode, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (sexe0_op_src1_sel, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (sexe0_op_src2_sel, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (sexe1_op_opcode, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (sexe1_op_src1_sel, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (sexe1_op_src2_sel, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (sexe2_op_opcode, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (sexe2_op_src1_sel, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (sexe2_op_src2_sel, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (mask_op_valu0_mask_sel, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (mask_op_valu1_mask_sel, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (mask_op_valu2_mask_sel, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (prf_op_vrf_wt_p0_src, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (prf_op_vrf_wt_p1_src, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (prf_op_mrf_wt_src, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (prf_op_srf_wt_en, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (static_type_vl_vl, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (static_type_vl_data_type, UVM_DEFAULT)
        `uvm_field_int          (static_type_vl_round_mode, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (static_ld_addr_cm_addr, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (static_st_addr_cm_addr, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (static_vrf_rd_index_vrf_rd_p0_idx, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (static_vrf_rd_index_vrf_rd_p1_idx, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (static_vrf_wt_index_vrf_wt_p0_idx, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (static_vrf_wt_index_vrf_wt_p1_idx, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (static_mrf_rd_index_mrf_rd_p0_idx, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (static_mrf_rd_index_mrf_rd_p1_idx, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (static_mrf_wt_index_mrf_wt_idx, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (static_srf_rd_index_0_srf_rd_p0_idx, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (static_srf_rd_index_0_srf_rd_p1_idx, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (static_srf_rd_index_0_srf_rd_p2_idx, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (static_srf_rd_index_0_srf_rd_p3_idx, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (static_srf_rd_index_1_srf_rd_p4_idx, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (static_srf_rd_index_1_srf_rd_p5_idx, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (static_srf_rd_index_1_srf_rd_p6_idx, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (static_srf_rd_index_1_srf_rd_p7_idx, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (static_srf_wt_index_0_srf_wt_p0_idx, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (static_srf_wt_index_0_srf_wt_p1_idx, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (static_srf_wt_index_0_srf_wt_p2_idx, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (static_srf_wt_index_0_srf_wt_p3_idx, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (static_srf_wt_index_1_srf_wt_p4_idx, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (static_srf_wt_index_1_srf_wt_p5_idx, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (inf_replace_value_inf_replace_value, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (nan_replace_value_nan_replace_value, UVM_DEFAULT | UVM_DEC)
        `uvm_field_object       (inst_gen_cfg,        UVM_DEFAULT)
    `uvm_object_utils_end

    function new (string name = "vu_inst_seq_item");
        super.new(name);
    endfunction : new

    //----- 位域 fix 约束（inst_gen_cfg 固定值） -----
    constraint lu_op_stride_run_c {
        if (inst_gen_cfg.fix_lu_op_stride_run_en) {
            lu_op_stride_run == inst_gen_cfg.lu_op_stride_run;
        }
    }

    constraint lu_op_stride_skip_c {
        if (inst_gen_cfg.fix_lu_op_stride_skip_en) {
            lu_op_stride_skip == inst_gen_cfg.lu_op_stride_skip;
        }
    }

    constraint macro_inst_trigger_config_idx_c {
        if (inst_gen_cfg.fix_macro_inst_trigger_config_idx_en) {
            macro_inst_trigger_config_idx == inst_gen_cfg.macro_inst_trigger_config_idx;
        }
    }

    constraint macro_inst_trigger_data_broadcast_c {
        if (inst_gen_cfg.fix_macro_inst_trigger_data_broadcast_en) {
            macro_inst_trigger_data_broadcast == inst_gen_cfg.macro_inst_trigger_data_broadcast;
        }
    }

    constraint macro_inst_trigger_event_en_c {
        if (inst_gen_cfg.fix_macro_inst_trigger_event_en_en) {
            macro_inst_trigger_event_en == inst_gen_cfg.macro_inst_trigger_event_en;
        }
    }

    constraint macro_inst_trigger_macro_inst_fence_c {
        if (inst_gen_cfg.fix_macro_inst_trigger_macro_inst_fence_en) {
            macro_inst_trigger_macro_inst_fence == inst_gen_cfg.macro_inst_trigger_macro_inst_fence;
        }
    }

    constraint macro_inst_trigger_static_dynamic_mask_c {
        if (inst_gen_cfg.fix_macro_inst_trigger_static_dynamic_mask_en) {
            macro_inst_trigger_static_dynamic_mask == inst_gen_cfg.macro_inst_trigger_static_dynamic_mask;
        }
    }

    constraint macro_inst_trigger_stream_id_c {
        if (inst_gen_cfg.fix_macro_inst_trigger_stream_id_en) {
            macro_inst_trigger_stream_id == inst_gen_cfg.macro_inst_trigger_stream_id;
        }
    }

    constraint macro_inst_trigger_stream_id_override_c {
        if (inst_gen_cfg.fix_macro_inst_trigger_stream_id_override_en) {
            macro_inst_trigger_stream_id_override == inst_gen_cfg.macro_inst_trigger_stream_id_override;
        }
    }

    constraint static_ld_addr_cm_addr_c {
        if (inst_gen_cfg.fix_static_ld_addr_cm_addr_en) {
            static_ld_addr_cm_addr == inst_gen_cfg.static_ld_addr_cm_addr;
        }
    }

    constraint static_mrf_rd_index_mrf_rd_p0_idx_c {
        if (inst_gen_cfg.fix_static_mrf_rd_index_mrf_rd_p0_idx_en) {
            static_mrf_rd_index_mrf_rd_p0_idx == inst_gen_cfg.static_mrf_rd_index_mrf_rd_p0_idx;
        }
    }

    constraint static_mrf_rd_index_mrf_rd_p1_idx_c {
        if (inst_gen_cfg.fix_static_mrf_rd_index_mrf_rd_p1_idx_en) {
            static_mrf_rd_index_mrf_rd_p1_idx == inst_gen_cfg.static_mrf_rd_index_mrf_rd_p1_idx;
        }
    }

    constraint static_mrf_wt_index_mrf_wt_idx_c {
        if (inst_gen_cfg.fix_static_mrf_wt_index_mrf_wt_idx_en) {
            static_mrf_wt_index_mrf_wt_idx == inst_gen_cfg.static_mrf_wt_index_mrf_wt_idx;
        }
    }

    constraint static_srf_rd_index_0_srf_rd_p0_idx_c {
        if (inst_gen_cfg.fix_static_srf_rd_index_0_srf_rd_p0_idx_en) {
            static_srf_rd_index_0_srf_rd_p0_idx == inst_gen_cfg.static_srf_rd_index_0_srf_rd_p0_idx;
        }
    }

    constraint static_srf_rd_index_0_srf_rd_p1_idx_c {
        if (inst_gen_cfg.fix_static_srf_rd_index_0_srf_rd_p1_idx_en) {
            static_srf_rd_index_0_srf_rd_p1_idx == inst_gen_cfg.static_srf_rd_index_0_srf_rd_p1_idx;
        }
    }

    constraint static_srf_rd_index_0_srf_rd_p2_idx_c {
        if (inst_gen_cfg.fix_static_srf_rd_index_0_srf_rd_p2_idx_en) {
            static_srf_rd_index_0_srf_rd_p2_idx == inst_gen_cfg.static_srf_rd_index_0_srf_rd_p2_idx;
        }
    }

    constraint static_srf_rd_index_0_srf_rd_p3_idx_c {
        if (inst_gen_cfg.fix_static_srf_rd_index_0_srf_rd_p3_idx_en) {
            static_srf_rd_index_0_srf_rd_p3_idx == inst_gen_cfg.static_srf_rd_index_0_srf_rd_p3_idx;
        }
    }

    constraint static_srf_rd_index_1_srf_rd_p4_idx_c {
        if (inst_gen_cfg.fix_static_srf_rd_index_1_srf_rd_p4_idx_en) {
            static_srf_rd_index_1_srf_rd_p4_idx == inst_gen_cfg.static_srf_rd_index_1_srf_rd_p4_idx;
        }
    }

    constraint static_srf_rd_index_1_srf_rd_p5_idx_c {
        if (inst_gen_cfg.fix_static_srf_rd_index_1_srf_rd_p5_idx_en) {
            static_srf_rd_index_1_srf_rd_p5_idx == inst_gen_cfg.static_srf_rd_index_1_srf_rd_p5_idx;
        }
    }

    constraint static_srf_rd_index_1_srf_rd_p6_idx_c {
        if (inst_gen_cfg.fix_static_srf_rd_index_1_srf_rd_p6_idx_en) {
            static_srf_rd_index_1_srf_rd_p6_idx == inst_gen_cfg.static_srf_rd_index_1_srf_rd_p6_idx;
        }
    }

    constraint static_srf_rd_index_1_srf_rd_p7_idx_c {
        if (inst_gen_cfg.fix_static_srf_rd_index_1_srf_rd_p7_idx_en) {
            static_srf_rd_index_1_srf_rd_p7_idx == inst_gen_cfg.static_srf_rd_index_1_srf_rd_p7_idx;
        }
    }

    constraint static_srf_wt_index_0_srf_wt_p0_idx_c {
        if (inst_gen_cfg.fix_static_srf_wt_index_0_srf_wt_p0_idx_en) {
            static_srf_wt_index_0_srf_wt_p0_idx == inst_gen_cfg.static_srf_wt_index_0_srf_wt_p0_idx;
        }
    }

    constraint static_srf_wt_index_0_srf_wt_p1_idx_c {
        if (inst_gen_cfg.fix_static_srf_wt_index_0_srf_wt_p1_idx_en) {
            static_srf_wt_index_0_srf_wt_p1_idx == inst_gen_cfg.static_srf_wt_index_0_srf_wt_p1_idx;
        }
    }

    constraint static_srf_wt_index_0_srf_wt_p2_idx_c {
        if (inst_gen_cfg.fix_static_srf_wt_index_0_srf_wt_p2_idx_en) {
            static_srf_wt_index_0_srf_wt_p2_idx == inst_gen_cfg.static_srf_wt_index_0_srf_wt_p2_idx;
        }
    }

    constraint static_srf_wt_index_0_srf_wt_p3_idx_c {
        if (inst_gen_cfg.fix_static_srf_wt_index_0_srf_wt_p3_idx_en) {
            static_srf_wt_index_0_srf_wt_p3_idx == inst_gen_cfg.static_srf_wt_index_0_srf_wt_p3_idx;
        }
    }

    constraint static_srf_wt_index_1_srf_wt_p4_idx_c {
        if (inst_gen_cfg.fix_static_srf_wt_index_1_srf_wt_p4_idx_en) {
            static_srf_wt_index_1_srf_wt_p4_idx == inst_gen_cfg.static_srf_wt_index_1_srf_wt_p4_idx;
        }
    }

    constraint static_srf_wt_index_1_srf_wt_p5_idx_c {
        if (inst_gen_cfg.fix_static_srf_wt_index_1_srf_wt_p5_idx_en) {
            static_srf_wt_index_1_srf_wt_p5_idx == inst_gen_cfg.static_srf_wt_index_1_srf_wt_p5_idx;
        }
    }

    constraint static_st_addr_cm_addr_c {
        if (inst_gen_cfg.fix_static_st_addr_cm_addr_en) {
            static_st_addr_cm_addr == inst_gen_cfg.static_st_addr_cm_addr;
        }
    }

    constraint static_type_vl_round_mode_c {
        if (inst_gen_cfg.fix_static_type_vl_round_mode_en) {
            static_type_vl_round_mode == inst_gen_cfg.static_type_vl_round_mode;
        }
    }

    constraint static_type_vl_vl_c {
        if (inst_gen_cfg.fix_static_type_vl_vl_en) {
            static_type_vl_vl == inst_gen_cfg.static_type_vl_vl;
        }
    }

    constraint static_vrf_rd_index_vrf_rd_p0_idx_c {
        if (inst_gen_cfg.fix_static_vrf_rd_index_vrf_rd_p0_idx_en) {
            static_vrf_rd_index_vrf_rd_p0_idx == inst_gen_cfg.static_vrf_rd_index_vrf_rd_p0_idx;
        }
    }

    constraint static_vrf_rd_index_vrf_rd_p1_idx_c {
        if (inst_gen_cfg.fix_static_vrf_rd_index_vrf_rd_p1_idx_en) {
            static_vrf_rd_index_vrf_rd_p1_idx == inst_gen_cfg.static_vrf_rd_index_vrf_rd_p1_idx;
        }
    }

    constraint static_vrf_wt_index_vrf_wt_p0_idx_c {
        if (inst_gen_cfg.fix_static_vrf_wt_index_vrf_wt_p0_idx_en) {
            static_vrf_wt_index_vrf_wt_p0_idx == inst_gen_cfg.static_vrf_wt_index_vrf_wt_p0_idx;
        }
    }

    constraint static_vrf_wt_index_vrf_wt_p1_idx_c {
        if (inst_gen_cfg.fix_static_vrf_wt_index_vrf_wt_p1_idx_en) {
            static_vrf_wt_index_vrf_wt_p1_idx == inst_gen_cfg.static_vrf_wt_index_vrf_wt_p1_idx;
        }
    }

    constraint su_op_mxfp8_scale_round_c {
        if (inst_gen_cfg.fix_su_op_mxfp8_scale_round_en) {
            su_op_mxfp8_scale_round == inst_gen_cfg.su_op_mxfp8_scale_round;
        }
    }

    function automatic logic [31:0] pack_macro_inst_trigger_reg(input logic [31:0] data);
        logic [31:0] word;
        word = data;
        word[7:0] = macro_inst_trigger_static_dynamic_mask;
        word[10:8] = macro_inst_trigger_config_idx;
        word[16] = macro_inst_trigger_event_en;
        word[17] = macro_inst_trigger_stream_id_override;
        word[21:18] = macro_inst_trigger_stream_id;
        word[24] = macro_inst_trigger_macro_inst_fence;
        word[25] = macro_inst_trigger_data_broadcast;
        return word;
    endfunction

    // 反向：用 data 更新本 tr 对应位域信号
    function automatic void unpack_macro_inst_trigger_reg(input logic [31:0] data);
        macro_inst_trigger_static_dynamic_mask = data[7:0];
        macro_inst_trigger_config_idx = data[10:8];
        macro_inst_trigger_event_en = data[16];
        macro_inst_trigger_stream_id_override = data[17];
        macro_inst_trigger_stream_id = data[21:18];
        macro_inst_trigger_macro_inst_fence = data[24];
        macro_inst_trigger_data_broadcast = data[25];
    endfunction

    function automatic logic [31:0] pack_type_vl_reg(input logic [31:0] data);
        logic [31:0] word;
        word = data;
        word[15:0] = type_vl_vl;
        word[16] = type_vl_data_type;
        word[19:17] = type_vl_round_mode;
        word[20] = type_vl_nan_inf_en;
        return word;
    endfunction

    // 反向：用 data 更新本 tr 对应位域信号
    function automatic void unpack_type_vl_reg(input logic [31:0] data);
        type_vl_vl = data[15:0];
        type_vl_data_type = data[16];
        type_vl_round_mode = data[19:17];
        type_vl_nan_inf_en = data[20];
    endfunction

    function automatic logic [31:0] pack_ld_addr_reg(input logic [31:0] data);
        logic [31:0] word;
        word = data;
        word[31:0] = ld_addr_cm_addr;
        return word;
    endfunction

    // 反向：用 data 更新本 tr 对应位域信号
    function automatic void unpack_ld_addr_reg(input logic [31:0] data);
        ld_addr_cm_addr = data[31:0];
    endfunction

    function automatic logic [31:0] pack_st_addr_reg(input logic [31:0] data);
        logic [31:0] word;
        word = data;
        word[31:0] = st_addr_cm_addr;
        return word;
    endfunction

    // 反向：用 data 更新本 tr 对应位域信号
    function automatic void unpack_st_addr_reg(input logic [31:0] data);
        st_addr_cm_addr = data[31:0];
    endfunction

    function automatic logic [31:0] pack_vrf_rd_index_reg(input logic [31:0] data);
        logic [31:0] word;
        word = data;
        word[15:0] = vrf_rd_index_vrf_rd_p0_idx;
        word[31:16] = vrf_rd_index_vrf_rd_p1_idx;
        return word;
    endfunction

    // 反向：用 data 更新本 tr 对应位域信号
    function automatic void unpack_vrf_rd_index_reg(input logic [31:0] data);
        vrf_rd_index_vrf_rd_p0_idx = data[15:0];
        vrf_rd_index_vrf_rd_p1_idx = data[31:16];
    endfunction

    function automatic logic [31:0] pack_vrf_wt_index_reg(input logic [31:0] data);
        logic [31:0] word;
        word = data;
        word[15:0] = vrf_wt_index_vrf_wt_p0_idx;
        word[31:16] = vrf_wt_index_vrf_wt_p1_idx;
        return word;
    endfunction

    // 反向：用 data 更新本 tr 对应位域信号
    function automatic void unpack_vrf_wt_index_reg(input logic [31:0] data);
        vrf_wt_index_vrf_wt_p0_idx = data[15:0];
        vrf_wt_index_vrf_wt_p1_idx = data[31:16];
    endfunction

    function automatic logic [31:0] pack_mrf_rd_index_reg(input logic [31:0] data);
        logic [31:0] word;
        word = data;
        word[15:0] = mrf_rd_index_mrf_rd_p0_idx;
        word[31:16] = mrf_rd_index_mrf_rd_p1_idx;
        return word;
    endfunction

    // 反向：用 data 更新本 tr 对应位域信号
    function automatic void unpack_mrf_rd_index_reg(input logic [31:0] data);
        mrf_rd_index_mrf_rd_p0_idx = data[15:0];
        mrf_rd_index_mrf_rd_p1_idx = data[31:16];
    endfunction

    function automatic logic [31:0] pack_mrf_wt_index_reg(input logic [31:0] data);
        logic [31:0] word;
        word = data;
        word[15:0] = mrf_wt_index_mrf_wt_idx;
        return word;
    endfunction

    // 反向：用 data 更新本 tr 对应位域信号
    function automatic void unpack_mrf_wt_index_reg(input logic [31:0] data);
        mrf_wt_index_mrf_wt_idx = data[15:0];
    endfunction

    function automatic logic [31:0] pack_srf_rd_index_0_reg(input logic [31:0] data);
        logic [31:0] word;
        word = data;
        word[7:0] = srf_rd_index_0_srf_rd_p0_idx;
        word[15:8] = srf_rd_index_0_srf_rd_p1_idx;
        word[23:16] = srf_rd_index_0_srf_rd_p2_idx;
        word[31:24] = srf_rd_index_0_srf_rd_p3_idx;
        return word;
    endfunction

    // 反向：用 data 更新本 tr 对应位域信号
    function automatic void unpack_srf_rd_index_0_reg(input logic [31:0] data);
        srf_rd_index_0_srf_rd_p0_idx = data[7:0];
        srf_rd_index_0_srf_rd_p1_idx = data[15:8];
        srf_rd_index_0_srf_rd_p2_idx = data[23:16];
        srf_rd_index_0_srf_rd_p3_idx = data[31:24];
    endfunction

    function automatic logic [31:0] pack_srf_rd_index_1_reg(input logic [31:0] data);
        logic [31:0] word;
        word = data;
        word[7:0] = srf_rd_index_1_srf_rd_p4_idx;
        word[15:8] = srf_rd_index_1_srf_rd_p5_idx;
        word[23:16] = srf_rd_index_1_srf_rd_p6_idx;
        word[31:24] = srf_rd_index_1_srf_rd_p7_idx;
        return word;
    endfunction

    // 反向：用 data 更新本 tr 对应位域信号
    function automatic void unpack_srf_rd_index_1_reg(input logic [31:0] data);
        srf_rd_index_1_srf_rd_p4_idx = data[7:0];
        srf_rd_index_1_srf_rd_p5_idx = data[15:8];
        srf_rd_index_1_srf_rd_p6_idx = data[23:16];
        srf_rd_index_1_srf_rd_p7_idx = data[31:24];
    endfunction

    function automatic logic [31:0] pack_srf_wt_index_0_reg(input logic [31:0] data);
        logic [31:0] word;
        word = data;
        word[7:0] = srf_wt_index_0_srf_wt_p0_idx;
        word[15:8] = srf_wt_index_0_srf_wt_p1_idx;
        word[23:16] = srf_wt_index_0_srf_wt_p2_idx;
        word[31:24] = srf_wt_index_0_srf_wt_p3_idx;
        return word;
    endfunction

    // 反向：用 data 更新本 tr 对应位域信号
    function automatic void unpack_srf_wt_index_0_reg(input logic [31:0] data);
        srf_wt_index_0_srf_wt_p0_idx = data[7:0];
        srf_wt_index_0_srf_wt_p1_idx = data[15:8];
        srf_wt_index_0_srf_wt_p2_idx = data[23:16];
        srf_wt_index_0_srf_wt_p3_idx = data[31:24];
    endfunction

    function automatic logic [31:0] pack_srf_wt_index_1_reg(input logic [31:0] data);
        logic [31:0] word;
        word = data;
        word[7:0] = srf_wt_index_1_srf_wt_p4_idx;
        word[15:8] = srf_wt_index_1_srf_wt_p5_idx;
        return word;
    endfunction

    // 反向：用 data 更新本 tr 对应位域信号
    function automatic void unpack_srf_wt_index_1_reg(input logic [31:0] data);
        srf_wt_index_1_srf_wt_p4_idx = data[7:0];
        srf_wt_index_1_srf_wt_p5_idx = data[15:8];
    endfunction

    function automatic logic [31:0] pack_lu_op_reg(input logic [31:0] data);
        logic [31:0] word;
        word = data;
        word[7:0] = lu_op_opcode;
        word[15:8] = lu_op_stride_run;
        word[23:16] = lu_op_stride_skip;
        return word;
    endfunction

    // 反向：用 data 更新本 tr 对应位域信号
    function automatic void unpack_lu_op_reg(input logic [31:0] data);
        lu_op_opcode = data[7:0];
        lu_op_stride_run = data[15:8];
        lu_op_stride_skip = data[23:16];
    endfunction

    function automatic logic [31:0] pack_su_op_reg(input logic [31:0] data);
        logic [31:0] word;
        word = data;
        word[7:0] = su_op_opcode;
        word[15:8] = su_op_src_sel;
        word[16] = su_op_mxfp8_scale_round;
        return word;
    endfunction

    // 反向：用 data 更新本 tr 对应位域信号
    function automatic void unpack_su_op_reg(input logic [31:0] data);
        su_op_opcode = data[7:0];
        su_op_src_sel = data[15:8];
        su_op_mxfp8_scale_round = data[16];
    endfunction

    function automatic logic [31:0] pack_valu0_op_reg(input logic [31:0] data);
        logic [31:0] word;
        word = data;
        word[7:0] = valu0_op_opcode;
        word[15:8] = valu0_op_src1_sel;
        word[23:16] = valu0_op_src2_sel;
        word[31:24] = valu0_op_src3_sel;
        return word;
    endfunction

    // 反向：用 data 更新本 tr 对应位域信号
    function automatic void unpack_valu0_op_reg(input logic [31:0] data);
        valu0_op_opcode = data[7:0];
        valu0_op_src1_sel = data[15:8];
        valu0_op_src2_sel = data[23:16];
        valu0_op_src3_sel = data[31:24];
    endfunction

    function automatic logic [31:0] pack_valu1_op_reg(input logic [31:0] data);
        logic [31:0] word;
        word = data;
        word[7:0] = valu1_op_opcode;
        word[15:8] = valu1_op_src1_sel;
        word[23:16] = valu1_op_src2_sel;
        word[31:24] = valu1_op_src3_sel;
        return word;
    endfunction

    // 反向：用 data 更新本 tr 对应位域信号
    function automatic void unpack_valu1_op_reg(input logic [31:0] data);
        valu1_op_opcode = data[7:0];
        valu1_op_src1_sel = data[15:8];
        valu1_op_src2_sel = data[23:16];
        valu1_op_src3_sel = data[31:24];
    endfunction

    function automatic logic [31:0] pack_valu2_op_reg(input logic [31:0] data);
        logic [31:0] word;
        word = data;
        word[7:0] = valu2_op_opcode;
        word[15:8] = valu2_op_src1_sel;
        word[23:16] = valu2_op_src2_sel;
        word[31:24] = valu2_op_src3_sel;
        return word;
    endfunction

    // 反向：用 data 更新本 tr 对应位域信号
    function automatic void unpack_valu2_op_reg(input logic [31:0] data);
        valu2_op_opcode = data[7:0];
        valu2_op_src1_sel = data[15:8];
        valu2_op_src2_sel = data[23:16];
        valu2_op_src3_sel = data[31:24];
    endfunction

    function automatic logic [31:0] pack_vsfu_op_reg(input logic [31:0] data);
        logic [31:0] word;
        word = data;
        word[7:0] = vsfu_op_vsfu0_opcode;
        word[15:8] = vsfu_op_vsfu0_src1_sel;
        word[23:16] = vsfu_op_vsfu1_opcode;
        word[31:24] = vsfu_op_vsfu1_src1_sel;
        return word;
    endfunction

    // 反向：用 data 更新本 tr 对应位域信号
    function automatic void unpack_vsfu_op_reg(input logic [31:0] data);
        vsfu_op_vsfu0_opcode = data[7:0];
        vsfu_op_vsfu0_src1_sel = data[15:8];
        vsfu_op_vsfu1_opcode = data[23:16];
        vsfu_op_vsfu1_src1_sel = data[31:24];
    endfunction

    function automatic logic [31:0] pack_mexe_op_reg(input logic [31:0] data);
        logic [31:0] word;
        word = data;
        word[7:0] = mexe_op_opcode;
        word[15:8] = mexe_op_src1_sel;
        word[23:16] = mexe_op_src2_sel;
        return word;
    endfunction

    // 反向：用 data 更新本 tr 对应位域信号
    function automatic void unpack_mexe_op_reg(input logic [31:0] data);
        mexe_op_opcode = data[7:0];
        mexe_op_src1_sel = data[15:8];
        mexe_op_src2_sel = data[23:16];
    endfunction

    function automatic logic [31:0] pack_sexe0_op_reg(input logic [31:0] data);
        logic [31:0] word;
        word = data;
        word[7:0] = sexe0_op_opcode;
        word[15:8] = sexe0_op_src1_sel;
        word[23:16] = sexe0_op_src2_sel;
        return word;
    endfunction

    // 反向：用 data 更新本 tr 对应位域信号
    function automatic void unpack_sexe0_op_reg(input logic [31:0] data);
        sexe0_op_opcode = data[7:0];
        sexe0_op_src1_sel = data[15:8];
        sexe0_op_src2_sel = data[23:16];
    endfunction

    function automatic logic [31:0] pack_sexe1_op_reg(input logic [31:0] data);
        logic [31:0] word;
        word = data;
        word[7:0] = sexe1_op_opcode;
        word[15:8] = sexe1_op_src1_sel;
        word[23:16] = sexe1_op_src2_sel;
        return word;
    endfunction

    // 反向：用 data 更新本 tr 对应位域信号
    function automatic void unpack_sexe1_op_reg(input logic [31:0] data);
        sexe1_op_opcode = data[7:0];
        sexe1_op_src1_sel = data[15:8];
        sexe1_op_src2_sel = data[23:16];
    endfunction

    function automatic logic [31:0] pack_sexe2_op_reg(input logic [31:0] data);
        logic [31:0] word;
        word = data;
        word[7:0] = sexe2_op_opcode;
        word[15:8] = sexe2_op_src1_sel;
        word[23:16] = sexe2_op_src2_sel;
        return word;
    endfunction

    // 反向：用 data 更新本 tr 对应位域信号
    function automatic void unpack_sexe2_op_reg(input logic [31:0] data);
        sexe2_op_opcode = data[7:0];
        sexe2_op_src1_sel = data[15:8];
        sexe2_op_src2_sel = data[23:16];
    endfunction

    function automatic logic [31:0] pack_mask_op_reg(input logic [31:0] data);
        logic [31:0] word;
        word = data;
        word[7:0] = mask_op_valu0_mask_sel;
        word[15:8] = mask_op_valu1_mask_sel;
        word[23:16] = mask_op_valu2_mask_sel;
        return word;
    endfunction

    // 反向：用 data 更新本 tr 对应位域信号
    function automatic void unpack_mask_op_reg(input logic [31:0] data);
        mask_op_valu0_mask_sel = data[7:0];
        mask_op_valu1_mask_sel = data[15:8];
        mask_op_valu2_mask_sel = data[23:16];
    endfunction

    function automatic logic [31:0] pack_prf_op_reg(input logic [31:0] data);
        logic [31:0] word;
        word = data;
        word[7:0] = prf_op_vrf_wt_p0_src;
        word[15:8] = prf_op_vrf_wt_p1_src;
        word[23:16] = prf_op_mrf_wt_src;
        word[31:24] = prf_op_srf_wt_en;
        return word;
    endfunction

    // 反向：用 data 更新本 tr 对应位域信号
    function automatic void unpack_prf_op_reg(input logic [31:0] data);
        prf_op_vrf_wt_p0_src = data[7:0];
        prf_op_vrf_wt_p1_src = data[15:8];
        prf_op_mrf_wt_src = data[23:16];
        prf_op_srf_wt_en = data[31:24];
    endfunction

    function automatic logic [31:0] pack_static_type_vl_reg(input logic [31:0] data);
        logic [31:0] word;
        word = data;
        word[15:0] = static_type_vl_vl;
        word[16] = static_type_vl_data_type;
        word[19:17] = static_type_vl_round_mode;
        return word;
    endfunction

    // 反向：用 data 更新本 tr 对应位域信号
    function automatic void unpack_static_type_vl_reg(input logic [31:0] data);
        static_type_vl_vl = data[15:0];
        static_type_vl_data_type = data[16];
        static_type_vl_round_mode = data[19:17];
    endfunction

    function automatic logic [31:0] pack_static_ld_addr_reg(input logic [31:0] data);
        logic [31:0] word;
        word = data;
        word[31:0] = static_ld_addr_cm_addr;
        return word;
    endfunction

    // 反向：用 data 更新本 tr 对应位域信号
    function automatic void unpack_static_ld_addr_reg(input logic [31:0] data);
        static_ld_addr_cm_addr = data[31:0];
    endfunction

    function automatic logic [31:0] pack_static_st_addr_reg(input logic [31:0] data);
        logic [31:0] word;
        word = data;
        word[31:0] = static_st_addr_cm_addr;
        return word;
    endfunction

    // 反向：用 data 更新本 tr 对应位域信号
    function automatic void unpack_static_st_addr_reg(input logic [31:0] data);
        static_st_addr_cm_addr = data[31:0];
    endfunction

    function automatic logic [31:0] pack_static_vrf_rd_index_reg(input logic [31:0] data);
        logic [31:0] word;
        word = data;
        word[15:0] = static_vrf_rd_index_vrf_rd_p0_idx;
        word[31:16] = static_vrf_rd_index_vrf_rd_p1_idx;
        return word;
    endfunction

    // 反向：用 data 更新本 tr 对应位域信号
    function automatic void unpack_static_vrf_rd_index_reg(input logic [31:0] data);
        static_vrf_rd_index_vrf_rd_p0_idx = data[15:0];
        static_vrf_rd_index_vrf_rd_p1_idx = data[31:16];
    endfunction

    function automatic logic [31:0] pack_static_vrf_wt_index_reg(input logic [31:0] data);
        logic [31:0] word;
        word = data;
        word[15:0] = static_vrf_wt_index_vrf_wt_p0_idx;
        word[31:16] = static_vrf_wt_index_vrf_wt_p1_idx;
        return word;
    endfunction

    // 反向：用 data 更新本 tr 对应位域信号
    function automatic void unpack_static_vrf_wt_index_reg(input logic [31:0] data);
        static_vrf_wt_index_vrf_wt_p0_idx = data[15:0];
        static_vrf_wt_index_vrf_wt_p1_idx = data[31:16];
    endfunction

    function automatic logic [31:0] pack_static_mrf_rd_index_reg(input logic [31:0] data);
        logic [31:0] word;
        word = data;
        word[15:0] = static_mrf_rd_index_mrf_rd_p0_idx;
        word[31:16] = static_mrf_rd_index_mrf_rd_p1_idx;
        return word;
    endfunction

    // 反向：用 data 更新本 tr 对应位域信号
    function automatic void unpack_static_mrf_rd_index_reg(input logic [31:0] data);
        static_mrf_rd_index_mrf_rd_p0_idx = data[15:0];
        static_mrf_rd_index_mrf_rd_p1_idx = data[31:16];
    endfunction

    function automatic logic [31:0] pack_static_mrf_wt_index_reg(input logic [31:0] data);
        logic [31:0] word;
        word = data;
        word[15:0] = static_mrf_wt_index_mrf_wt_idx;
        return word;
    endfunction

    // 反向：用 data 更新本 tr 对应位域信号
    function automatic void unpack_static_mrf_wt_index_reg(input logic [31:0] data);
        static_mrf_wt_index_mrf_wt_idx = data[15:0];
    endfunction

    function automatic logic [31:0] pack_static_srf_rd_index_0_reg(input logic [31:0] data);
        logic [31:0] word;
        word = data;
        word[7:0] = static_srf_rd_index_0_srf_rd_p0_idx;
        word[15:8] = static_srf_rd_index_0_srf_rd_p1_idx;
        word[23:16] = static_srf_rd_index_0_srf_rd_p2_idx;
        word[31:24] = static_srf_rd_index_0_srf_rd_p3_idx;
        return word;
    endfunction

    // 反向：用 data 更新本 tr 对应位域信号
    function automatic void unpack_static_srf_rd_index_0_reg(input logic [31:0] data);
        static_srf_rd_index_0_srf_rd_p0_idx = data[7:0];
        static_srf_rd_index_0_srf_rd_p1_idx = data[15:8];
        static_srf_rd_index_0_srf_rd_p2_idx = data[23:16];
        static_srf_rd_index_0_srf_rd_p3_idx = data[31:24];
    endfunction

    function automatic logic [31:0] pack_static_srf_rd_index_1_reg(input logic [31:0] data);
        logic [31:0] word;
        word = data;
        word[7:0] = static_srf_rd_index_1_srf_rd_p4_idx;
        word[15:8] = static_srf_rd_index_1_srf_rd_p5_idx;
        word[23:16] = static_srf_rd_index_1_srf_rd_p6_idx;
        word[31:24] = static_srf_rd_index_1_srf_rd_p7_idx;
        return word;
    endfunction

    // 反向：用 data 更新本 tr 对应位域信号
    function automatic void unpack_static_srf_rd_index_1_reg(input logic [31:0] data);
        static_srf_rd_index_1_srf_rd_p4_idx = data[7:0];
        static_srf_rd_index_1_srf_rd_p5_idx = data[15:8];
        static_srf_rd_index_1_srf_rd_p6_idx = data[23:16];
        static_srf_rd_index_1_srf_rd_p7_idx = data[31:24];
    endfunction

    function automatic logic [31:0] pack_static_srf_wt_index_0_reg(input logic [31:0] data);
        logic [31:0] word;
        word = data;
        word[7:0] = static_srf_wt_index_0_srf_wt_p0_idx;
        word[15:8] = static_srf_wt_index_0_srf_wt_p1_idx;
        word[23:16] = static_srf_wt_index_0_srf_wt_p2_idx;
        word[31:24] = static_srf_wt_index_0_srf_wt_p3_idx;
        return word;
    endfunction

    // 反向：用 data 更新本 tr 对应位域信号
    function automatic void unpack_static_srf_wt_index_0_reg(input logic [31:0] data);
        static_srf_wt_index_0_srf_wt_p0_idx = data[7:0];
        static_srf_wt_index_0_srf_wt_p1_idx = data[15:8];
        static_srf_wt_index_0_srf_wt_p2_idx = data[23:16];
        static_srf_wt_index_0_srf_wt_p3_idx = data[31:24];
    endfunction

    function automatic logic [31:0] pack_static_srf_wt_index_1_reg(input logic [31:0] data);
        logic [31:0] word;
        word = data;
        word[7:0] = static_srf_wt_index_1_srf_wt_p4_idx;
        word[15:8] = static_srf_wt_index_1_srf_wt_p5_idx;
        return word;
    endfunction

    // 反向：用 data 更新本 tr 对应位域信号
    function automatic void unpack_static_srf_wt_index_1_reg(input logic [31:0] data);
        static_srf_wt_index_1_srf_wt_p4_idx = data[7:0];
        static_srf_wt_index_1_srf_wt_p5_idx = data[15:8];
    endfunction

    function automatic logic [31:0] pack_inf_replace_value_reg(input logic [31:0] data);
        logic [31:0] word;
        word = data;
        word[31:0] = inf_replace_value_inf_replace_value;
        return word;
    endfunction

    // 反向：用 data 更新本 tr 对应位域信号
    function automatic void unpack_inf_replace_value_reg(input logic [31:0] data);
        inf_replace_value_inf_replace_value = data[31:0];
    endfunction

endclass : vu_inst_seq_item

class vu_drv_seq_item extends vu_inst_seq_item;
    //----- 执行单元使能（按 vu_unit_e 索引） -----
    rand logic [VU_UNIT_END-1:0] active_exe;
    //----- 各执行单元 class -----
    rand vu_lu_class_e            lu_class;
    rand vu_su_class_e            su_class;
    rand vu_valu0_class_e         valu0_class;
    rand vu_valu1_class_e         valu1_class;
    rand vu_valu2_class_e         valu2_class;
    rand vu_vsfu0_class_e         vsfu0_class;
    rand vu_vsfu1_class_e         vsfu1_class;
    rand vu_mexe_class_e          mexe_class;
    rand vu_sexe0_class_e         sexe0_class;
    rand vu_sexe1_class_e         sexe1_class;
    rand vu_sexe2_class_e         sexe2_class;

    `uvm_object_utils_begin(vu_drv_seq_item)
        `uvm_field_int          (active_exe,                               UVM_DEFAULT)
        `uvm_field_enum         (vu_lu_class_e,        lu_class,       UVM_DEFAULT)
        `uvm_field_enum         (vu_su_class_e,        su_class,       UVM_DEFAULT)
        `uvm_field_enum         (vu_valu0_class_e,        valu0_class,       UVM_DEFAULT)
        `uvm_field_enum         (vu_valu1_class_e,        valu1_class,       UVM_DEFAULT)
        `uvm_field_enum         (vu_valu2_class_e,        valu2_class,       UVM_DEFAULT)
        `uvm_field_enum         (vu_vsfu0_class_e,        vsfu0_class,       UVM_DEFAULT)
        `uvm_field_enum         (vu_vsfu1_class_e,        vsfu1_class,       UVM_DEFAULT)
        `uvm_field_enum         (vu_mexe_class_e,        mexe_class,       UVM_DEFAULT)
        `uvm_field_enum         (vu_sexe0_class_e,        sexe0_class,       UVM_DEFAULT)
        `uvm_field_enum         (vu_sexe1_class_e,        sexe1_class,       UVM_DEFAULT)
        `uvm_field_enum         (vu_sexe2_class_e,        sexe2_class,       UVM_DEFAULT)
    `uvm_object_utils_end

    function new (string name = "vu_drv_seq_item");
        super.new(name);
    endfunction : new

    //----- 求解顺序：active_exe → class → opcode / type_vl_vl / ld_addr / st_addr / data_type -----
    constraint mac_solve_order_c {
        solve active_exe before lu_class;
        solve lu_class before lu_op_opcode;
        solve active_exe before su_class;
        solve su_class before su_op_opcode;
        solve active_exe before valu0_class;
        solve valu0_class before valu0_op_opcode;
        solve active_exe before valu1_class;
        solve valu1_class before valu1_op_opcode;
        solve active_exe before valu2_class;
        solve valu2_class before valu2_op_opcode;
        solve active_exe before vsfu0_class;
        solve vsfu0_class before vsfu_op_vsfu0_opcode;
        solve active_exe before vsfu1_class;
        solve vsfu1_class before vsfu_op_vsfu1_opcode;
        solve active_exe before mexe_class;
        solve mexe_class before mexe_op_opcode;
        solve active_exe before sexe0_class;
        solve sexe0_class before sexe0_op_opcode;
        solve active_exe before sexe1_class;
        solve sexe1_class before sexe1_op_opcode;
        solve active_exe before sexe2_class;
        solve sexe2_class before sexe2_op_opcode;
        solve macro_inst_trigger_static_dynamic_mask before type_vl_vl;
        solve macro_inst_trigger_static_dynamic_mask before static_type_vl_vl;
        solve macro_inst_trigger_static_dynamic_mask before ld_addr_cm_addr;
        solve macro_inst_trigger_static_dynamic_mask before static_ld_addr_cm_addr;
        solve macro_inst_trigger_static_dynamic_mask before st_addr_cm_addr;
        solve macro_inst_trigger_static_dynamic_mask before static_st_addr_cm_addr;
        solve macro_inst_trigger_static_dynamic_mask before type_vl_data_type;
        solve macro_inst_trigger_static_dynamic_mask before static_type_vl_data_type;
        solve lu_op_opcode before type_vl_vl;
        solve su_op_opcode before type_vl_vl;
        solve valu2_op_opcode before type_vl_vl;
        solve lu_op_stride_run before type_vl_vl;
        solve lu_op_stride_skip before type_vl_vl;
        solve lu_op_opcode before static_type_vl_vl;
        solve su_op_opcode before static_type_vl_vl;
        solve valu2_op_opcode before static_type_vl_vl;
        solve lu_op_stride_run before static_type_vl_vl;
        solve lu_op_stride_skip before static_type_vl_vl;
        solve lu_class before ld_addr_cm_addr;
        solve lu_class before static_ld_addr_cm_addr;
        solve su_class before st_addr_cm_addr;
        solve su_class before static_st_addr_cm_addr;
        solve vsfu1_class before type_vl_data_type;
        solve vsfu1_class before static_type_vl_data_type;
    }

    //----- active_exe → class（未激活 CLASS_END） -----
    constraint su_class_c {
        if (!active_exe[VU_SU]) {
            su_class == VU_SU_CLASS_END;
        } else {
            su_class dist {
                VU_SU_1_VS_ADDR          := inst_gen_cfg.su_class_dist[VU_SU_1_VS_ADDR],
                VU_SU_2_MS_ADDR          := inst_gen_cfg.su_class_dist[VU_SU_2_MS_ADDR],
                VU_SU_3_FS_ADDR          := inst_gen_cfg.su_class_dist[VU_SU_3_FS_ADDR]
            };
        }
    }

    constraint valu2_class_c {
        if (!active_exe[VU_VALU2]) {
            valu2_class == VU_VALU2_CLASS_END;
        } else {
            valu2_class dist {
                VU_VALU2_1_VD_VS2_VS1_VM := inst_gen_cfg.valu2_class_dist[VU_VALU2_1_VD_VS2_VS1_VM],
                VU_VALU2_2_VD_VS2_FS1_VM := inst_gen_cfg.valu2_class_dist[VU_VALU2_2_VD_VS2_FS1_VM],
                VU_VALU2_3_VD_FS1        := inst_gen_cfg.valu2_class_dist[VU_VALU2_3_VD_FS1],
                VU_VALU2_4_VD_VS1        := inst_gen_cfg.valu2_class_dist[VU_VALU2_4_VD_VS1],
                VU_VALU2_5_VD_VS2_FS1    := inst_gen_cfg.valu2_class_dist[VU_VALU2_5_VD_VS2_FS1]
            };
        }
    }

    constraint vsfu0_class_c {
        if (!active_exe[VU_VSFU0]) {
            vsfu0_class == VU_VSFU0_CLASS_END;
        } else {
            vsfu0_class == VU_VSFU0_1_VD_VS1;
        }
    }

    constraint vsfu1_class_c {
        if (!active_exe[VU_VSFU1]) {
            vsfu1_class == VU_VSFU1_CLASS_END;
        } else {
            vsfu1_class == VU_VSFU1_1_VD_VS1;
        }
    }

    constraint sexe0_class_c {
        if (!active_exe[VU_SEXE0]) {
            sexe0_class == VU_SEXE0_CLASS_END;
        } else {
            sexe0_class dist {
                VU_SEXE0_1_FD_FS1_FS2    := inst_gen_cfg.sexe0_class_dist[VU_SEXE0_1_FD_FS1_FS2],
                VU_SEXE0_2_FD_FS1        := inst_gen_cfg.sexe0_class_dist[VU_SEXE0_2_FD_FS1]
            };
        }
    }

    //----- class → OPCODE dist（权重来自 cN_type_dist） -----
    constraint lu_op_opcode_c {
        if (lu_class == VU_LU_1_VD_ADDR) {
            lu_op_opcode dist {
                8'h01 := inst_gen_cfg.lu_c1_type_dist[VU_LU_C1_LD_FP8E4M3_V],
                8'h02 := inst_gen_cfg.lu_c1_type_dist[VU_LU_C1_LD_MXFP8_V],
                8'h03 := inst_gen_cfg.lu_c1_type_dist[VU_LU_C1_LD_BF16_V],
                8'h04 := inst_gen_cfg.lu_c1_type_dist[VU_LU_C1_LD_FP32_V]
            };
        }
        else if (lu_class == VU_LU_2_MD_ADDR) {
            lu_op_opcode dist {
                8'h05 := inst_gen_cfg.lu_c2_type_dist[VU_LU_C2_LD_MASK]
            };
        }
        else if (lu_class == VU_LU_3_FD_ADDR) {
            lu_op_opcode dist {
                8'h06 := inst_gen_cfg.lu_c3_type_dist[VU_LU_C3_LD_S_FP32]
            };
        }
        else {
            lu_op_opcode inside {8'h00, [8'h07:8'hFF]};
        }
    }

    constraint mexe_op_opcode_c {
        if (mexe_class == VU_MEXE_1_MD_MS2_MS1) {
            mexe_op_opcode dist {
                8'h01 := inst_gen_cfg.mexe_c1_type_dist[VU_MEXE_C1_VMAND_MM],
                8'h02 := inst_gen_cfg.mexe_c1_type_dist[VU_MEXE_C1_VMNAND_MM],
                8'h03 := inst_gen_cfg.mexe_c1_type_dist[VU_MEXE_C1_VMANDN_MM],
                8'h04 := inst_gen_cfg.mexe_c1_type_dist[VU_MEXE_C1_VMXOR_MM],
                8'h05 := inst_gen_cfg.mexe_c1_type_dist[VU_MEXE_C1_VMOR_MM],
                8'h06 := inst_gen_cfg.mexe_c1_type_dist[VU_MEXE_C1_VMNOR_MM],
                8'h07 := inst_gen_cfg.mexe_c1_type_dist[VU_MEXE_C1_VMORN_MM],
                8'h08 := inst_gen_cfg.mexe_c1_type_dist[VU_MEXE_C1_VMXNOR_MM]
            };
        }
        else if (mexe_class == VU_MEXE_2_FD_MS1) {
            mexe_op_opcode dist {
                8'h10 := inst_gen_cfg.mexe_c2_type_dist[VU_MEXE_C2_VCPOP_M],
                8'h11 := inst_gen_cfg.mexe_c2_type_dist[VU_MEXE_C2_VFIRST_M]
            };
        }
        else if (mexe_class == VU_MEXE_3_MD_MS1) {
            mexe_op_opcode dist {
                8'h12 := inst_gen_cfg.mexe_c3_type_dist[VU_MEXE_C3_VMSBF_M],
                8'h13 := inst_gen_cfg.mexe_c3_type_dist[VU_MEXE_C3_VMSIF_M],
                8'h14 := inst_gen_cfg.mexe_c3_type_dist[VU_MEXE_C3_VMSOF_M]
            };
        }
        else if (mexe_class == VU_MEXE_4_MD_MS1_VS2) {
            mexe_op_opcode dist {
                8'h15 := inst_gen_cfg.mexe_c4_type_dist[VU_MEXE_C4_VMIUSET_MV],
                8'h16 := inst_gen_cfg.mexe_c4_type_dist[VU_MEXE_C4_VMISET_MV]
            };
        }
        else {
            mexe_op_opcode inside {8'h00, [8'h09:8'h0F], [8'h17:8'hFF]};
        }
    }

    constraint sexe0_op_opcode_c {
        if (sexe0_class == VU_SEXE0_1_FD_FS1_FS2) {
            sexe0_op_opcode dist {
                8'h01 := inst_gen_cfg.sexe0_c1_type_dist[VU_SEXE0_C1_FADD_S],
                8'h02 := inst_gen_cfg.sexe0_c1_type_dist[VU_SEXE0_C1_FSUB_S],
                8'h03 := inst_gen_cfg.sexe0_c1_type_dist[VU_SEXE0_C1_FMUL_S],
                8'h04 := inst_gen_cfg.sexe0_c1_type_dist[VU_SEXE0_C1_FDIV_S]
            };
        }
        else if (sexe0_class == VU_SEXE0_2_FD_FS1) {
            sexe0_op_opcode dist {
                8'h05 := inst_gen_cfg.sexe0_c2_type_dist[VU_SEXE0_C2_FSQRT_S],
                8'h06 := inst_gen_cfg.sexe0_c2_type_dist[VU_SEXE0_C2_FRSQRT_S],
                8'h07 := inst_gen_cfg.sexe0_c2_type_dist[VU_SEXE0_C2_FRCP_S]
            };
        }
        else {
            sexe0_op_opcode inside {8'h00, [8'h08:8'hFF]};
        }
    }

    constraint sexe1_op_opcode_c {
        if (sexe1_class == VU_SEXE1_1_FD_FS1_FS2) {
            sexe1_op_opcode dist {
                8'h01 := inst_gen_cfg.sexe1_c1_type_dist[VU_SEXE1_C1_FADD_S],
                8'h02 := inst_gen_cfg.sexe1_c1_type_dist[VU_SEXE1_C1_FSUB_S],
                8'h03 := inst_gen_cfg.sexe1_c1_type_dist[VU_SEXE1_C1_FMUL_S],
                8'h04 := inst_gen_cfg.sexe1_c1_type_dist[VU_SEXE1_C1_FDIV_S]
            };
        }
        else if (sexe1_class == VU_SEXE1_2_FD_FS1) {
            sexe1_op_opcode dist {
                8'h05 := inst_gen_cfg.sexe1_c2_type_dist[VU_SEXE1_C2_FSQRT_S],
                8'h06 := inst_gen_cfg.sexe1_c2_type_dist[VU_SEXE1_C2_FRSQRT_S],
                8'h07 := inst_gen_cfg.sexe1_c2_type_dist[VU_SEXE1_C2_FRCP_S]
            };
        }
        else {
            sexe1_op_opcode inside {8'h00, [8'h08:8'hFF]};
        }
    }

    constraint sexe2_op_opcode_c {
        if (sexe2_class == VU_SEXE2_1_FD_FS1_FS2) {
            sexe2_op_opcode dist {
                8'h01 := inst_gen_cfg.sexe2_c1_type_dist[VU_SEXE2_C1_FADD_S],
                8'h02 := inst_gen_cfg.sexe2_c1_type_dist[VU_SEXE2_C1_FSUB_S],
                8'h03 := inst_gen_cfg.sexe2_c1_type_dist[VU_SEXE2_C1_FMUL_S],
                8'h04 := inst_gen_cfg.sexe2_c1_type_dist[VU_SEXE2_C1_FDIV_S]
            };
        }
        else if (sexe2_class == VU_SEXE2_2_FD_FS1) {
            sexe2_op_opcode dist {
                8'h05 := inst_gen_cfg.sexe2_c2_type_dist[VU_SEXE2_C2_FSQRT_S],
                8'h06 := inst_gen_cfg.sexe2_c2_type_dist[VU_SEXE2_C2_FRSQRT_S],
                8'h07 := inst_gen_cfg.sexe2_c2_type_dist[VU_SEXE2_C2_FRCP_S]
            };
        }
        else {
            sexe2_op_opcode inside {8'h00, [8'h08:8'hFF]};
        }
    }

    constraint su_op_opcode_c {
        if (su_class == VU_SU_1_VS_ADDR) {
            su_op_opcode dist {
                8'h01 := inst_gen_cfg.su_c1_type_dist[VU_SU_C1_ST_FP8E4M3_V],
                8'h02 := inst_gen_cfg.su_c1_type_dist[VU_SU_C1_ST_MXFP8_V],
                8'h03 := inst_gen_cfg.su_c1_type_dist[VU_SU_C1_ST_BF16_V],
                8'h04 := inst_gen_cfg.su_c1_type_dist[VU_SU_C1_ST_FP32_V]
            };
        }
        else if (su_class == VU_SU_2_MS_ADDR) {
            su_op_opcode dist {
                8'h05 := inst_gen_cfg.su_c2_type_dist[VU_SU_C2_ST_MASK]
            };
        }
        else if (su_class == VU_SU_3_FS_ADDR) {
            su_op_opcode dist {
                8'h06 := inst_gen_cfg.su_c3_type_dist[VU_SU_C3_ST_S_FP32]
            };
        }
        else {
            su_op_opcode inside {8'h00, [8'h07:8'hFF]};
        }
    }

    constraint valu0_op_opcode_c {
        if (valu0_class == VU_VALU0_1_VD_VS2_VS1_VM) {
            valu0_op_opcode dist {
                8'h01 := inst_gen_cfg.valu0_c1_type_dist[VU_VALU0_C1_VFADD_VV],
                8'h03 := inst_gen_cfg.valu0_c1_type_dist[VU_VALU0_C1_VFSUB_VV],
                8'h06 := inst_gen_cfg.valu0_c1_type_dist[VU_VALU0_C1_VFMUL_VV],
                8'h08 := inst_gen_cfg.valu0_c1_type_dist[VU_VALU0_C1_VFDIV_VV],
                8'h10 := inst_gen_cfg.valu0_c1_type_dist[VU_VALU0_C1_VFMIN_VV],
                8'h12 := inst_gen_cfg.valu0_c1_type_dist[VU_VALU0_C1_VFMAX_VV],
                8'h40 := inst_gen_cfg.valu0_c1_type_dist[VU_VALU0_C1_VFSGNJ_VV],
                8'h42 := inst_gen_cfg.valu0_c1_type_dist[VU_VALU0_C1_VFSGNJN_VV],
                8'h44 := inst_gen_cfg.valu0_c1_type_dist[VU_VALU0_C1_VFSGNJX_VV],
                8'h62 := inst_gen_cfg.valu0_c1_type_dist[VU_VALU0_C1_VFMERGE_VVM]
            };
        }
        else if (valu0_class == VU_VALU0_2_VD_VS2_FS1_VM) {
            valu0_op_opcode dist {
                8'h02 := inst_gen_cfg.valu0_c2_type_dist[VU_VALU0_C2_VFADD_VF],
                8'h04 := inst_gen_cfg.valu0_c2_type_dist[VU_VALU0_C2_VFSUB_VF],
                8'h05 := inst_gen_cfg.valu0_c2_type_dist[VU_VALU0_C2_VFRSUB_VF],
                8'h07 := inst_gen_cfg.valu0_c2_type_dist[VU_VALU0_C2_VFMUL_VF],
                8'h11 := inst_gen_cfg.valu0_c2_type_dist[VU_VALU0_C2_VFMIN_VF],
                8'h13 := inst_gen_cfg.valu0_c2_type_dist[VU_VALU0_C2_VFMAX_VF],
                8'h41 := inst_gen_cfg.valu0_c2_type_dist[VU_VALU0_C2_VFSGNJ_VF],
                8'h43 := inst_gen_cfg.valu0_c2_type_dist[VU_VALU0_C2_VFSGNJN_VF],
                8'h45 := inst_gen_cfg.valu0_c2_type_dist[VU_VALU0_C2_VFSGNJX_VF],
                8'h61 := inst_gen_cfg.valu0_c2_type_dist[VU_VALU0_C2_VFMERGE_VFM]
            };
        }
        else if (valu0_class == VU_VALU0_3_VD_FS1) {
            valu0_op_opcode dist {
                8'h20 := inst_gen_cfg.valu0_c3_type_dist[VU_VALU0_C3_VFMV_V_F]
            };
        }
        else if (valu0_class == VU_VALU0_4_VD_FS1_IMM) {
            valu0_op_opcode dist {
                8'h21 := inst_gen_cfg.valu0_c4_type_dist[VU_VALU0_C4_VFMV_S_F]
            };
        }
        else if (valu0_class == VU_VALU0_5_VD_VS3_VS1_VS2_VM) {
            valu0_op_opcode dist {
                8'h30 := inst_gen_cfg.valu0_c5_type_dist[VU_VALU0_C5_VFMACC_VV],
                8'h32 := inst_gen_cfg.valu0_c5_type_dist[VU_VALU0_C5_VFNMACC_VV],
                8'h34 := inst_gen_cfg.valu0_c5_type_dist[VU_VALU0_C5_VFMSAC_VV],
                8'h36 := inst_gen_cfg.valu0_c5_type_dist[VU_VALU0_C5_VFNMSAC_VV]
            };
        }
        else if (valu0_class == VU_VALU0_6_VD_VS3_FS1_VS2_VM) {
            valu0_op_opcode dist {
                8'h31 := inst_gen_cfg.valu0_c6_type_dist[VU_VALU0_C6_VFMACC_VF],
                8'h33 := inst_gen_cfg.valu0_c6_type_dist[VU_VALU0_C6_VFNMACC_VF],
                8'h35 := inst_gen_cfg.valu0_c6_type_dist[VU_VALU0_C6_VFMSAC_VF],
                8'h37 := inst_gen_cfg.valu0_c6_type_dist[VU_VALU0_C6_VFNMSAC_VF]
            };
        }
        else if (valu0_class == VU_VALU0_7_MD_VS2_VS1_VM) {
            valu0_op_opcode dist {
                8'h50 := inst_gen_cfg.valu0_c7_type_dist[VU_VALU0_C7_VMFEQ_VV],
                8'h52 := inst_gen_cfg.valu0_c7_type_dist[VU_VALU0_C7_VMFNE_VV],
                8'h54 := inst_gen_cfg.valu0_c7_type_dist[VU_VALU0_C7_VMFLT_VV],
                8'h56 := inst_gen_cfg.valu0_c7_type_dist[VU_VALU0_C7_VMFLE_VV]
            };
        }
        else if (valu0_class == VU_VALU0_8_MD_VS2_FS1_VM) {
            valu0_op_opcode dist {
                8'h51 := inst_gen_cfg.valu0_c8_type_dist[VU_VALU0_C8_VMFEQ_VF],
                8'h53 := inst_gen_cfg.valu0_c8_type_dist[VU_VALU0_C8_VMFNE_VF],
                8'h55 := inst_gen_cfg.valu0_c8_type_dist[VU_VALU0_C8_VMFLT_VF],
                8'h57 := inst_gen_cfg.valu0_c8_type_dist[VU_VALU0_C8_VMFLE_VF],
                8'h58 := inst_gen_cfg.valu0_c8_type_dist[VU_VALU0_C8_VMFGT_VF],
                8'h59 := inst_gen_cfg.valu0_c8_type_dist[VU_VALU0_C8_VMFGE_VF]
            };
        }
        else if (valu0_class == VU_VALU0_9_MD_VS1_VM_IMM) {
            valu0_op_opcode dist {
                8'h60 := inst_gen_cfg.valu0_c9_type_dist[VU_VALU0_C9_VFCLASS_MV]
            };
        }
        else {
            valu0_op_opcode inside {8'h00, [8'h09:8'h0F], [8'h14:8'h1F], [8'h22:8'h2F], [8'h38:8'h3F], [8'h46:8'h4F], [8'h5A:8'h5F], [8'h63:8'hFF]};
        }
    }

    constraint valu1_op_opcode_c {
        if (valu1_class == VU_VALU1_1_VD_VS2_VS1_VM) {
            valu1_op_opcode dist {
                8'h01 := inst_gen_cfg.valu1_c1_type_dist[VU_VALU1_C1_VFADD_VV],
                8'h03 := inst_gen_cfg.valu1_c1_type_dist[VU_VALU1_C1_VFSUB_VV],
                8'h06 := inst_gen_cfg.valu1_c1_type_dist[VU_VALU1_C1_VFMUL_VV],
                8'h10 := inst_gen_cfg.valu1_c1_type_dist[VU_VALU1_C1_VFMIN_VV],
                8'h12 := inst_gen_cfg.valu1_c1_type_dist[VU_VALU1_C1_VFMAX_VV]
            };
        }
        else if (valu1_class == VU_VALU1_2_VD_VS2_FS1_VM) {
            valu1_op_opcode dist {
                8'h02 := inst_gen_cfg.valu1_c2_type_dist[VU_VALU1_C2_VFADD_VF],
                8'h04 := inst_gen_cfg.valu1_c2_type_dist[VU_VALU1_C2_VFSUB_VF],
                8'h05 := inst_gen_cfg.valu1_c2_type_dist[VU_VALU1_C2_VFRSUB_VF],
                8'h07 := inst_gen_cfg.valu1_c2_type_dist[VU_VALU1_C2_VFMUL_VF],
                8'h11 := inst_gen_cfg.valu1_c2_type_dist[VU_VALU1_C2_VFMIN_VF],
                8'h13 := inst_gen_cfg.valu1_c2_type_dist[VU_VALU1_C2_VFMAX_VF]
            };
        }
        else if (valu1_class == VU_VALU1_3_VD_FS1) {
            valu1_op_opcode dist {
                8'h20 := inst_gen_cfg.valu1_c3_type_dist[VU_VALU1_C3_VFMV_V_F]
            };
        }
        else if (valu1_class == VU_VALU1_4_FD_VS1_IMM) {
            valu1_op_opcode dist {
                8'h22 := inst_gen_cfg.valu1_c4_type_dist[VU_VALU1_C4_VFMV_F_S]
            };
        }
        else if (valu1_class == VU_VALU1_5_FD_VS2_FS1_VM) {
            valu1_op_opcode dist {
                8'h70 := inst_gen_cfg.valu1_c5_type_dist[VU_VALU1_C5_VFREDUSUM_VS],
                8'h71 := inst_gen_cfg.valu1_c5_type_dist[VU_VALU1_C5_VFREDMAX_VS],
                8'h72 := inst_gen_cfg.valu1_c5_type_dist[VU_VALU1_C5_VFREDMIN_VS]
            };
        }
        else if (valu1_class == VU_VALU1_6_VD_VS1_VM) {
            valu1_op_opcode dist {
                8'h73 := inst_gen_cfg.valu1_c6_type_dist[VU_VALU1_C6_VSORTMAX16_V],
                8'h74 := inst_gen_cfg.valu1_c6_type_dist[VU_VALU1_C6_VSORTMIN16_V]
            };
        }
        else {
            valu1_op_opcode inside {8'h00, [8'h08:8'h0F], [8'h14:8'h1F], 8'h21, [8'h23:8'h6F], [8'h75:8'hFF]};
        }
    }

    constraint valu2_op_opcode_c {
        if (valu2_class == VU_VALU2_1_VD_VS2_VS1_VM) {
            valu2_op_opcode dist {
                8'h01 := inst_gen_cfg.valu2_c1_type_dist[VU_VALU2_C1_VFADD_VV],
                8'h03 := inst_gen_cfg.valu2_c1_type_dist[VU_VALU2_C1_VFSUB_VV],
                8'h06 := inst_gen_cfg.valu2_c1_type_dist[VU_VALU2_C1_VFMUL_VV],
                8'h10 := inst_gen_cfg.valu2_c1_type_dist[VU_VALU2_C1_VFMIN_VV],
                8'h12 := inst_gen_cfg.valu2_c1_type_dist[VU_VALU2_C1_VFMAX_VV]
            };
        }
        else if (valu2_class == VU_VALU2_2_VD_VS2_FS1_VM) {
            valu2_op_opcode dist {
                8'h02 := inst_gen_cfg.valu2_c2_type_dist[VU_VALU2_C2_VFADD_VF],
                8'h04 := inst_gen_cfg.valu2_c2_type_dist[VU_VALU2_C2_VFSUB_VF],
                8'h05 := inst_gen_cfg.valu2_c2_type_dist[VU_VALU2_C2_VFRSUB_VF],
                8'h07 := inst_gen_cfg.valu2_c2_type_dist[VU_VALU2_C2_VFMUL_VF],
                8'h11 := inst_gen_cfg.valu2_c2_type_dist[VU_VALU2_C2_VFMIN_VF],
                8'h13 := inst_gen_cfg.valu2_c2_type_dist[VU_VALU2_C2_VFMAX_VF]
            };
        }
        else if (valu2_class == VU_VALU2_3_VD_FS1) {
            valu2_op_opcode dist {
                8'h20 := inst_gen_cfg.valu2_c3_type_dist[VU_VALU2_C3_VFMV_V_F]
            };
        }
        else if (valu2_class == VU_VALU2_4_VD_VS1) {
            valu2_op_opcode dist {
                8'h23 := inst_gen_cfg.valu2_c4_type_dist[VU_VALU2_C4_VMV_V_V],
                8'h24 := inst_gen_cfg.valu2_c4_type_dist[VU_VALU2_C4_VSWAP2_V]
            };
        }
        else if (valu2_class == VU_VALU2_5_VD_VS2_FS1) {
            valu2_op_opcode dist {
                8'h25 := inst_gen_cfg.valu2_c5_type_dist[VU_VALU2_C5_VFSLIDE1UP_VF],
                8'h26 := inst_gen_cfg.valu2_c5_type_dist[VU_VALU2_C5_VFSLIDE1DOWN_VF]
            };
        }
        else {
            valu2_op_opcode inside {8'h00, [8'h08:8'h0F], [8'h14:8'h1F], [8'h21:8'h22], [8'h27:8'hFF]};
        }
    }

    constraint vsfu_op_vsfu0_opcode_c {
        if (vsfu0_class == VU_VSFU0_1_VD_VS1) {
            vsfu_op_vsfu0_opcode dist {
                8'h01 := inst_gen_cfg.vsfu0_c1_type_dist[VU_VSFU0_C1_VFSIN_V],
                8'h02 := inst_gen_cfg.vsfu0_c1_type_dist[VU_VSFU0_C1_VFCOS_V],
                8'h03 := inst_gen_cfg.vsfu0_c1_type_dist[VU_VSFU0_C1_VFTANH_V],
                8'h04 := inst_gen_cfg.vsfu0_c1_type_dist[VU_VSFU0_C1_VFSIGMOID_V],
                8'h05 := inst_gen_cfg.vsfu0_c1_type_dist[VU_VSFU0_C1_VFEXP_V],
                8'h06 := inst_gen_cfg.vsfu0_c1_type_dist[VU_VSFU0_C1_VFEXP2_V],
                8'h07 := inst_gen_cfg.vsfu0_c1_type_dist[VU_VSFU0_C1_VFLN_V],
                8'h08 := inst_gen_cfg.vsfu0_c1_type_dist[VU_VSFU0_C1_VFLOG2_V],
                8'h09 := inst_gen_cfg.vsfu0_c1_type_dist[VU_VSFU0_C1_VFSQRT_V],
                8'h0A := inst_gen_cfg.vsfu0_c1_type_dist[VU_VSFU0_C1_VFRCP_V],
                8'h0B := inst_gen_cfg.vsfu0_c1_type_dist[VU_VSFU0_C1_VFRSQRT_V],
                8'h0C := inst_gen_cfg.vsfu0_c1_type_dist[VU_VSFU0_C1_CUSTOM_FIT]
            };
        }
        else {
            vsfu_op_vsfu0_opcode inside {8'h00, [8'h0D:8'hFF]};
        }
    }

    constraint vsfu_op_vsfu1_opcode_c {
        if (vsfu1_class == VU_VSFU1_1_VD_VS1) {
            vsfu_op_vsfu1_opcode dist {
                8'h01 := inst_gen_cfg.vsfu1_c1_type_dist[VU_VSFU1_C1_VFSIN_V],
                8'h02 := inst_gen_cfg.vsfu1_c1_type_dist[VU_VSFU1_C1_VFCOS_V],
                8'h03 := inst_gen_cfg.vsfu1_c1_type_dist[VU_VSFU1_C1_VFTANH_V],
                8'h04 := inst_gen_cfg.vsfu1_c1_type_dist[VU_VSFU1_C1_VFSIGMOID_V],
                8'h05 := inst_gen_cfg.vsfu1_c1_type_dist[VU_VSFU1_C1_VFEXP_V],
                8'h06 := inst_gen_cfg.vsfu1_c1_type_dist[VU_VSFU1_C1_VFEXP2_V],
                8'h07 := inst_gen_cfg.vsfu1_c1_type_dist[VU_VSFU1_C1_VFLN_V],
                8'h08 := inst_gen_cfg.vsfu1_c1_type_dist[VU_VSFU1_C1_VFLOG2_V],
                8'h09 := inst_gen_cfg.vsfu1_c1_type_dist[VU_VSFU1_C1_VFSQRT_V],
                8'h0A := inst_gen_cfg.vsfu1_c1_type_dist[VU_VSFU1_C1_VFRCP_V],
                8'h0B := inst_gen_cfg.vsfu1_c1_type_dist[VU_VSFU1_C1_VFRSQRT_V],
                8'h0C := inst_gen_cfg.vsfu1_c1_type_dist[VU_VSFU1_C1_CUSTOM_FIT]
            };
        }
        else {
            vsfu_op_vsfu1_opcode inside {8'h00, [8'h0D:8'hFF]};
        }
    }

    //----- TYPE_VL / static_TYPE_VL.VL：按对应 *_op_opcode 约束（独立 if，多单元取交集） -----
    constraint type_vl_vl_c {
        if (lu_op_opcode inside {8'h01, 8'h03, 8'h04}) {
            if (macro_inst_trigger_static_dynamic_mask[0]) {
                if (lu_op_stride_run != 0 && lu_op_stride_skip != 0) {
                    type_vl_vl[4:0] == 0;
                }
            }
            if (!macro_inst_trigger_static_dynamic_mask[0] | inst_gen_cfg.static_must_legal) {
                if (lu_op_stride_run != 0 && lu_op_stride_skip != 0) {
                    static_type_vl_vl[4:0] == 0;
                }
            }
        }
        if (lu_op_opcode == 8'h02) {
            if (macro_inst_trigger_static_dynamic_mask[0]) {
                type_vl_vl[4:0] == 0;
            }
            if (!macro_inst_trigger_static_dynamic_mask[0] | inst_gen_cfg.static_must_legal) {
                static_type_vl_vl[4:0] == 0;
            }
        }
        if (su_op_opcode == 8'h02) {
            if (macro_inst_trigger_static_dynamic_mask[0]) {
                type_vl_vl[4:0] == 0;
            }
            if (!macro_inst_trigger_static_dynamic_mask[0] | inst_gen_cfg.static_must_legal) {
                static_type_vl_vl[4:0] == 0;
            }
        }
        if (su_op_opcode == 8'h05) {
            if (macro_inst_trigger_static_dynamic_mask[0]) {
                type_vl_vl[2:0] == 0;
            }
            if (!macro_inst_trigger_static_dynamic_mask[0] | inst_gen_cfg.static_must_legal) {
                static_type_vl_vl[2:0] == 0;
            }
        }
        if (valu2_op_opcode == 8'h24) {
            if (macro_inst_trigger_static_dynamic_mask[0]) {
                type_vl_vl[0] == 0;
            }
            if (!macro_inst_trigger_static_dynamic_mask[0] | inst_gen_cfg.static_must_legal) {
                static_type_vl_vl[0] == 0;
            }
        }
    }

    //----- LD_addr / static_LD_addr.CM_ADDR：按 lu_class 对齐约束 -----
    constraint ld_addr_cm_addr_c {
        if (lu_class inside {VU_LU_1_VD_ADDR, VU_LU_2_MD_ADDR}) {
            if (macro_inst_trigger_static_dynamic_mask[1]) {
                ld_addr_cm_addr[4:0] == 0;
            }
            if (!macro_inst_trigger_static_dynamic_mask[1] | inst_gen_cfg.static_must_legal) {
                static_ld_addr_cm_addr[4:0] == 0;
            }
        }
        if (lu_class == VU_LU_3_FD_ADDR) {
            if (macro_inst_trigger_static_dynamic_mask[1]) {
                ld_addr_cm_addr[1:0] == 0;
            }
            if (!macro_inst_trigger_static_dynamic_mask[1] | inst_gen_cfg.static_must_legal) {
                static_ld_addr_cm_addr[1:0] == 0;
            }
        }
    }

    //----- ST_addr / static_ST_addr.CM_ADDR：按 su_class 对齐约束 -----
    constraint st_addr_cm_addr_c {
        if (su_class inside {VU_SU_1_VS_ADDR, VU_SU_2_MS_ADDR}) {
            if (macro_inst_trigger_static_dynamic_mask[2]) {
                st_addr_cm_addr[4:0] == 0;
            }
            if (!macro_inst_trigger_static_dynamic_mask[2] | inst_gen_cfg.static_must_legal) {
                static_st_addr_cm_addr[4:0] == 0;
            }
        }
        if (su_class == VU_SU_3_FS_ADDR) {
            if (macro_inst_trigger_static_dynamic_mask[2]) {
                st_addr_cm_addr[1:0] == 0;
            }
            if (!macro_inst_trigger_static_dynamic_mask[2] | inst_gen_cfg.static_must_legal) {
                static_st_addr_cm_addr[1:0] == 0;
            }
        }
    }

    //----- TYPE_VL / static_TYPE_VL.DATA_TYPE：weight 控 0/1，VSFU1 固定 FP32 -----
    constraint type_vl_data_type_c {
        if (macro_inst_trigger_static_dynamic_mask[0]) {
            if (vsfu1_class != VU_VSFU1_CLASS_END) {
                type_vl_data_type == 1'b0;
            } else {
                type_vl_data_type dist {
                    1'b0 := 100 - inst_gen_cfg.vl_data_type_weight,
                    1'b1 := inst_gen_cfg.vl_data_type_weight
                };
            }
        }
    }

    constraint static_type_vl_data_type_c {
        if (!macro_inst_trigger_static_dynamic_mask[0] | inst_gen_cfg.static_must_legal) {
            if (vsfu1_class != VU_VSFU1_CLASS_END) {
                static_type_vl_data_type == 1'b0;
            } else {
                static_type_vl_data_type dist {
                    1'b0 := 100 - inst_gen_cfg.vl_data_type_weight,
                    1'b1 := inst_gen_cfg.vl_data_type_weight
                };
            }
        }
    }

endclass : vu_drv_seq_item

class vu_reg_read_seq_item extends uvm_sequence_item;
    rand vu_reg_read_addr_cat_e   reg_read_addr_cat;
    rand logic [2:0]              reg_read_static_idx;
    rand logic [31:0]             reg_read_addr;

    inst_gen_config     inst_gen_cfg;

    function automatic bit vu_reg_read_hi14_legal(logic [13:0] hi14);
        return hi14 inside {[14'h0:14'hB], [14'h400:14'h418], [14'h440:14'h458], [14'h480:14'h498], [14'h4C0:14'h4D8], [14'h500:14'h518], [14'h540:14'h558], [14'h580:14'h598], [14'h5C0:14'h5D8], [14'h800:14'h801], [14'hC00:14'hC0B], 14'h1000, [14'h1002:14'h1041]};
    endfunction

    `uvm_object_utils_begin(vu_reg_read_seq_item)
        `uvm_field_enum         (vu_reg_read_addr_cat_e, reg_read_addr_cat, UVM_DEFAULT)
        `uvm_field_int          (reg_read_static_idx, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (reg_read_addr, UVM_DEFAULT | UVM_DEC)
        `uvm_field_object       (inst_gen_cfg, UVM_DEFAULT)
    `uvm_object_utils_end

    function new (string name = "vu_reg_read_seq_item");
        super.new(name);
    endfunction : new

    //----- 求解顺序 -----
    constraint solve_order_c {
        solve reg_read_addr_cat before reg_read_static_idx;
        solve reg_read_addr_cat before reg_read_addr;
        solve reg_read_static_idx before reg_read_addr;
    }

    constraint reg_read_addr_cat_c {
        if (inst_gen_cfg.fix_reg_read_addr_cat_en) {
            reg_read_addr_cat == inst_gen_cfg.reg_read_addr_cat;
        } else {
            reg_read_addr_cat dist {
                VU_REG_READ_CAT_DYN_PARAM    := inst_gen_cfg.reg_read_addr_cat_dist[VU_REG_READ_CAT_DYN_PARAM],
                VU_REG_READ_CAT_STATIC_CFG   := inst_gen_cfg.reg_read_addr_cat_dist[VU_REG_READ_CAT_STATIC_CFG],
                VU_REG_READ_CAT_DSA_RF       := inst_gen_cfg.reg_read_addr_cat_dist[VU_REG_READ_CAT_DSA_RF],
                VU_REG_READ_CAT_STATUS       := inst_gen_cfg.reg_read_addr_cat_dist[VU_REG_READ_CAT_STATUS],
                VU_REG_READ_CAT_PROFILE      := inst_gen_cfg.reg_read_addr_cat_dist[VU_REG_READ_CAT_PROFILE],
                VU_REG_READ_CAT_ILLEGAL      := inst_gen_cfg.reg_read_addr_cat_dist[VU_REG_READ_CAT_ILLEGAL]
            };
        }
    }

    constraint reg_read_static_idx_c {
        if (inst_gen_cfg.fix_reg_read_static_idx_en) {
            reg_read_static_idx == inst_gen_cfg.reg_read_static_idx;
        }
    }

    constraint reg_read_addr_align_c {
        if (!inst_gen_cfg.fix_reg_read_addr_en) {
            reg_read_addr[1:0] dist {
                2'b00              := inst_gen_cfg.align_addr_weight,
                [2'b01:2'b11]      := 100 - inst_gen_cfg.align_addr_weight
            };
        }
    }

    constraint reg_read_addr_c {
        if (inst_gen_cfg.fix_reg_read_addr_en) {
            reg_read_addr == inst_gen_cfg.reg_read_addr;
        }
        else if (reg_read_addr_cat == VU_REG_READ_CAT_ILLEGAL)
            !vu_reg_read_hi14_legal(reg_read_addr[15:2]);
        else if (reg_read_addr_cat == VU_REG_READ_CAT_DYN_PARAM)
            reg_read_addr[15:2] inside {[14'h0:14'hB]};
        else if (reg_read_addr_cat == VU_REG_READ_CAT_STATIC_CFG)
            (reg_read_addr[15:2] - (14'(reg_read_static_idx) * 14'h40)) inside {[14'h400:14'h418]};
        else if (reg_read_addr_cat == VU_REG_READ_CAT_DSA_RF)
            reg_read_addr[15:2] inside {[14'h800:14'h801]};
        else if (reg_read_addr_cat == VU_REG_READ_CAT_STATUS)
            reg_read_addr[15:2] inside {[14'hC00:14'hC0B]};
        else if (reg_read_addr_cat == VU_REG_READ_CAT_PROFILE)
            reg_read_addr[15:2] inside {14'h1000, [14'h1002:14'h1041]};
    }

endclass : vu_reg_read_seq_item

`endif
