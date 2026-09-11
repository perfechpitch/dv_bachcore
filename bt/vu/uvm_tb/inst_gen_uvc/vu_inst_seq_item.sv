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
    constraint inf_replace_value_inf_replace_value_c {
        if (inst_gen_cfg.fix_inf_replace_value_inf_replace_value_en) {
            inf_replace_value_inf_replace_value == inst_gen_cfg.inf_replace_value_inf_replace_value;
        }
    }

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

    constraint nan_replace_value_nan_replace_value_c {
        if (inst_gen_cfg.fix_nan_replace_value_nan_replace_value_en) {
            nan_replace_value_nan_replace_value == inst_gen_cfg.nan_replace_value_nan_replace_value;
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

    function automatic logic [31:0] pack_type_vl_reg(input logic [31:0] data);
        logic [31:0] word;
        word = data;
        word[15:0] = type_vl_vl;
        word[16] = type_vl_data_type;
        word[19:17] = type_vl_round_mode;
        word[20] = type_vl_nan_inf_en;
        return word;
    endfunction

    function automatic logic [31:0] pack_ld_addr_reg(input logic [31:0] data);
        logic [31:0] word;
        word = data;
        word[31:0] = ld_addr_cm_addr;
        return word;
    endfunction

    function automatic logic [31:0] pack_st_addr_reg(input logic [31:0] data);
        logic [31:0] word;
        word = data;
        word[31:0] = st_addr_cm_addr;
        return word;
    endfunction

    function automatic logic [31:0] pack_vrf_rd_index_reg(input logic [31:0] data);
        logic [31:0] word;
        word = data;
        word[15:0] = vrf_rd_index_vrf_rd_p0_idx;
        word[31:16] = vrf_rd_index_vrf_rd_p1_idx;
        return word;
    endfunction

    function automatic logic [31:0] pack_vrf_wt_index_reg(input logic [31:0] data);
        logic [31:0] word;
        word = data;
        word[15:0] = vrf_wt_index_vrf_wt_p0_idx;
        word[31:16] = vrf_wt_index_vrf_wt_p1_idx;
        return word;
    endfunction

    function automatic logic [31:0] pack_mrf_rd_index_reg(input logic [31:0] data);
        logic [31:0] word;
        word = data;
        word[15:0] = mrf_rd_index_mrf_rd_p0_idx;
        word[31:16] = mrf_rd_index_mrf_rd_p1_idx;
        return word;
    endfunction

    function automatic logic [31:0] pack_mrf_wt_index_reg(input logic [31:0] data);
        logic [31:0] word;
        word = data;
        word[15:0] = mrf_wt_index_mrf_wt_idx;
        return word;
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

    function automatic logic [31:0] pack_srf_rd_index_1_reg(input logic [31:0] data);
        logic [31:0] word;
        word = data;
        word[7:0] = srf_rd_index_1_srf_rd_p4_idx;
        word[15:8] = srf_rd_index_1_srf_rd_p5_idx;
        word[23:16] = srf_rd_index_1_srf_rd_p6_idx;
        word[31:24] = srf_rd_index_1_srf_rd_p7_idx;
        return word;
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

    function automatic logic [31:0] pack_srf_wt_index_1_reg(input logic [31:0] data);
        logic [31:0] word;
        word = data;
        word[7:0] = srf_wt_index_1_srf_wt_p4_idx;
        word[15:8] = srf_wt_index_1_srf_wt_p5_idx;
        return word;
    endfunction

    function automatic logic [31:0] pack_lu_op_reg(input logic [31:0] data);
        logic [31:0] word;
        word = data;
        word[7:0] = lu_op_opcode;
        word[15:8] = lu_op_stride_run;
        word[23:16] = lu_op_stride_skip;
        return word;
    endfunction

    function automatic logic [31:0] pack_su_op_reg(input logic [31:0] data);
        logic [31:0] word;
        word = data;
        word[7:0] = su_op_opcode;
        word[15:8] = su_op_src_sel;
        word[16] = su_op_mxfp8_scale_round;
        return word;
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

    function automatic logic [31:0] pack_valu1_op_reg(input logic [31:0] data);
        logic [31:0] word;
        word = data;
        word[7:0] = valu1_op_opcode;
        word[15:8] = valu1_op_src1_sel;
        word[23:16] = valu1_op_src2_sel;
        word[31:24] = valu1_op_src3_sel;
        return word;
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

    function automatic logic [31:0] pack_vsfu_op_reg(input logic [31:0] data);
        logic [31:0] word;
        word = data;
        word[7:0] = vsfu_op_vsfu0_opcode;
        word[15:8] = vsfu_op_vsfu0_src1_sel;
        word[23:16] = vsfu_op_vsfu1_opcode;
        word[31:24] = vsfu_op_vsfu1_src1_sel;
        return word;
    endfunction

    function automatic logic [31:0] pack_mexe_op_reg(input logic [31:0] data);
        logic [31:0] word;
        word = data;
        word[7:0] = mexe_op_opcode;
        word[15:8] = mexe_op_src1_sel;
        word[23:16] = mexe_op_src2_sel;
        return word;
    endfunction

    function automatic logic [31:0] pack_sexe0_op_reg(input logic [31:0] data);
        logic [31:0] word;
        word = data;
        word[7:0] = sexe0_op_opcode;
        word[15:8] = sexe0_op_src1_sel;
        word[23:16] = sexe0_op_src2_sel;
        return word;
    endfunction

    function automatic logic [31:0] pack_sexe1_op_reg(input logic [31:0] data);
        logic [31:0] word;
        word = data;
        word[7:0] = sexe1_op_opcode;
        word[15:8] = sexe1_op_src1_sel;
        word[23:16] = sexe1_op_src2_sel;
        return word;
    endfunction

    function automatic logic [31:0] pack_sexe2_op_reg(input logic [31:0] data);
        logic [31:0] word;
        word = data;
        word[7:0] = sexe2_op_opcode;
        word[15:8] = sexe2_op_src1_sel;
        word[23:16] = sexe2_op_src2_sel;
        return word;
    endfunction

    function automatic logic [31:0] pack_mask_op_reg(input logic [31:0] data);
        logic [31:0] word;
        word = data;
        word[7:0] = mask_op_valu0_mask_sel;
        word[15:8] = mask_op_valu1_mask_sel;
        word[23:16] = mask_op_valu2_mask_sel;
        return word;
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

    function automatic logic [31:0] pack_static_type_vl_reg(input logic [31:0] data);
        logic [31:0] word;
        word = data;
        word[15:0] = static_type_vl_vl;
        word[16] = static_type_vl_data_type;
        word[19:17] = static_type_vl_round_mode;
        return word;
    endfunction

    function automatic logic [31:0] pack_static_ld_addr_reg(input logic [31:0] data);
        logic [31:0] word;
        word = data;
        word[31:0] = static_ld_addr_cm_addr;
        return word;
    endfunction

    function automatic logic [31:0] pack_static_st_addr_reg(input logic [31:0] data);
        logic [31:0] word;
        word = data;
        word[31:0] = static_st_addr_cm_addr;
        return word;
    endfunction

    function automatic logic [31:0] pack_static_vrf_rd_index_reg(input logic [31:0] data);
        logic [31:0] word;
        word = data;
        word[15:0] = static_vrf_rd_index_vrf_rd_p0_idx;
        word[31:16] = static_vrf_rd_index_vrf_rd_p1_idx;
        return word;
    endfunction

    function automatic logic [31:0] pack_static_vrf_wt_index_reg(input logic [31:0] data);
        logic [31:0] word;
        word = data;
        word[15:0] = static_vrf_wt_index_vrf_wt_p0_idx;
        word[31:16] = static_vrf_wt_index_vrf_wt_p1_idx;
        return word;
    endfunction

    function automatic logic [31:0] pack_static_mrf_rd_index_reg(input logic [31:0] data);
        logic [31:0] word;
        word = data;
        word[15:0] = static_mrf_rd_index_mrf_rd_p0_idx;
        word[31:16] = static_mrf_rd_index_mrf_rd_p1_idx;
        return word;
    endfunction

    function automatic logic [31:0] pack_static_mrf_wt_index_reg(input logic [31:0] data);
        logic [31:0] word;
        word = data;
        word[15:0] = static_mrf_wt_index_mrf_wt_idx;
        return word;
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

    function automatic logic [31:0] pack_static_srf_rd_index_1_reg(input logic [31:0] data);
        logic [31:0] word;
        word = data;
        word[7:0] = static_srf_rd_index_1_srf_rd_p4_idx;
        word[15:8] = static_srf_rd_index_1_srf_rd_p5_idx;
        word[23:16] = static_srf_rd_index_1_srf_rd_p6_idx;
        word[31:24] = static_srf_rd_index_1_srf_rd_p7_idx;
        return word;
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

    function automatic logic [31:0] pack_static_srf_wt_index_1_reg(input logic [31:0] data);
        logic [31:0] word;
        word = data;
        word[7:0] = static_srf_wt_index_1_srf_wt_p4_idx;
        word[15:8] = static_srf_wt_index_1_srf_wt_p5_idx;
        return word;
    endfunction

    function automatic logic [31:0] pack_inf_replace_value_reg(input logic [31:0] data);
        logic [31:0] word;
        word = data;
        word[31:0] = inf_replace_value_inf_replace_value;
        return word;
    endfunction

endclass : vu_inst_seq_item

class vu_mac_inst_seq_item extends vu_inst_seq_item;
    //----- 各执行单元 type（由 cross_*_gen 驱动） -----
    rand vu_lu_type_e             lu_type;
    rand vu_su_type_e             su_type;
    rand vu_valu0_type_e          valu0_type;
    rand vu_valu1_type_e          valu1_type;
    rand vu_valu2_type_e          valu2_type;
    rand vu_vsfu_type_e           vsfu0_type;
    rand vu_vsfu_type_e           vsfu1_type;
    rand vu_mexe_type_e           mexe_type;
    rand vu_sexe_type_e           sexe0_type;
    rand vu_sexe_type_e           sexe1_type;
    rand vu_sexe_type_e           sexe2_type;

    `uvm_object_utils_begin(vu_mac_inst_seq_item)
        `uvm_field_enum         (vu_lu_type_e,        lu_type,       UVM_DEFAULT)
        `uvm_field_enum         (vu_su_type_e,        su_type,       UVM_DEFAULT)
        `uvm_field_enum         (vu_valu0_type_e,        valu0_type,       UVM_DEFAULT)
        `uvm_field_enum         (vu_valu1_type_e,        valu1_type,       UVM_DEFAULT)
        `uvm_field_enum         (vu_valu2_type_e,        valu2_type,       UVM_DEFAULT)
        `uvm_field_enum         (vu_vsfu_type_e,        vsfu0_type,       UVM_DEFAULT)
        `uvm_field_enum         (vu_vsfu_type_e,        vsfu1_type,       UVM_DEFAULT)
        `uvm_field_enum         (vu_mexe_type_e,        mexe_type,       UVM_DEFAULT)
        `uvm_field_enum         (vu_sexe_type_e,        sexe0_type,       UVM_DEFAULT)
        `uvm_field_enum         (vu_sexe_type_e,        sexe1_type,       UVM_DEFAULT)
        `uvm_field_enum         (vu_sexe_type_e,        sexe2_type,       UVM_DEFAULT)
    `uvm_object_utils_end

    function new (string name = "vu_mac_inst_seq_item");
        super.new(name);
    endfunction : new

    //----- 求解顺序：执行单元 type → opcode -----
    constraint mac_solve_order_c {
        solve lu_type before lu_op_opcode;
        solve su_type before su_op_opcode;
        solve valu0_type before valu0_op_opcode;
        solve valu1_type before valu1_op_opcode;
        solve valu2_type before valu2_op_opcode;
        solve vsfu0_type before vsfu_op_vsfu0_opcode;
        solve vsfu1_type before vsfu_op_vsfu1_opcode;
        solve mexe_type before mexe_op_opcode;
        solve sexe0_type before sexe0_op_opcode;
        solve sexe1_type before sexe1_op_opcode;
        solve sexe2_type before sexe2_op_opcode;
    }

    //----- 执行单元 type → OPCODE -----
    constraint lu_op_opcode_c {
        if (inst_gen_cfg.fix_lu_op_opcode_en) {
            lu_op_opcode == inst_gen_cfg.lu_op_opcode;
        } else {
            if (lu_type == VU_LU_LD_FP8E4M3_V) {
                lu_op_opcode == 8'h01;
            }
            else if (lu_type == VU_LU_LD_MXFP8_V) {
                lu_op_opcode == 8'h02;
            }
            else if (lu_type == VU_LU_LD_BF16_V) {
                lu_op_opcode == 8'h03;
            }
            else if (lu_type == VU_LU_LD_FP32_V) {
                lu_op_opcode == 8'h04;
            }
            else if (lu_type == VU_LU_LD_MASK) {
                lu_op_opcode == 8'h05;
            }
            else if (lu_type == VU_LU_LD_S_FP32) {
                lu_op_opcode == 8'h06;
            }
            else {
                lu_op_opcode inside {8'h00, [8'h07:8'hFF]};
            }
        }
    }

    constraint mexe_op_opcode_c {
        if (inst_gen_cfg.fix_mexe_op_opcode_en) {
            mexe_op_opcode == inst_gen_cfg.mexe_op_opcode;
        } else {
            if (mexe_type == VU_MEXE_VMAND_MM) {
                mexe_op_opcode == 8'h01;
            }
            else if (mexe_type == VU_MEXE_VMNAND_MM) {
                mexe_op_opcode == 8'h02;
            }
            else if (mexe_type == VU_MEXE_VMANDN_MM) {
                mexe_op_opcode == 8'h03;
            }
            else if (mexe_type == VU_MEXE_VMXOR_MM) {
                mexe_op_opcode == 8'h04;
            }
            else if (mexe_type == VU_MEXE_VMOR_MM) {
                mexe_op_opcode == 8'h05;
            }
            else if (mexe_type == VU_MEXE_VMNOR_MM) {
                mexe_op_opcode == 8'h06;
            }
            else if (mexe_type == VU_MEXE_VMORN_MM) {
                mexe_op_opcode == 8'h07;
            }
            else if (mexe_type == VU_MEXE_VMXNOR_MM) {
                mexe_op_opcode == 8'h08;
            }
            else if (mexe_type == VU_MEXE_VCPOP_M) {
                mexe_op_opcode == 8'h10;
            }
            else if (mexe_type == VU_MEXE_VFIRST_M) {
                mexe_op_opcode == 8'h11;
            }
            else if (mexe_type == VU_MEXE_VMSBF_M) {
                mexe_op_opcode == 8'h12;
            }
            else if (mexe_type == VU_MEXE_VMSIF_M) {
                mexe_op_opcode == 8'h13;
            }
            else if (mexe_type == VU_MEXE_VMSOF_M) {
                mexe_op_opcode == 8'h14;
            }
            else if (mexe_type == VU_MEXE_VMIUSET_MV) {
                mexe_op_opcode == 8'h15;
            }
            else if (mexe_type == VU_MEXE_VMISET_MV) {
                mexe_op_opcode == 8'h16;
            }
            else {
                mexe_op_opcode inside {8'h00, [8'h09:8'h0F], [8'h17:8'hFF]};
            }
        }
    }

    constraint sexe0_op_opcode_c {
        if (inst_gen_cfg.fix_sexe0_op_opcode_en) {
            sexe0_op_opcode == inst_gen_cfg.sexe0_op_opcode;
        } else {
            if (sexe0_type == VU_SEXE_FADD_S) {
                sexe0_op_opcode == 8'h01;
            }
            else if (sexe0_type == VU_SEXE_FSUB_S) {
                sexe0_op_opcode == 8'h02;
            }
            else if (sexe0_type == VU_SEXE_FMUL_S) {
                sexe0_op_opcode == 8'h03;
            }
            else if (sexe0_type == VU_SEXE_FDIV_S) {
                sexe0_op_opcode == 8'h04;
            }
            else if (sexe0_type == VU_SEXE_FSQRT_S) {
                sexe0_op_opcode == 8'h05;
            }
            else if (sexe0_type == VU_SEXE_FRSQRT_S) {
                sexe0_op_opcode == 8'h06;
            }
            else if (sexe0_type == VU_SEXE_FRCP_S) {
                sexe0_op_opcode == 8'h07;
            }
            else {
                sexe0_op_opcode inside {8'h00, [8'h08:8'hFF]};
            }
        }
    }

    constraint sexe1_op_opcode_c {
        if (inst_gen_cfg.fix_sexe1_op_opcode_en) {
            sexe1_op_opcode == inst_gen_cfg.sexe1_op_opcode;
        } else {
            if (sexe1_type == VU_SEXE_FADD_S) {
                sexe1_op_opcode == 8'h01;
            }
            else if (sexe1_type == VU_SEXE_FSUB_S) {
                sexe1_op_opcode == 8'h02;
            }
            else if (sexe1_type == VU_SEXE_FMUL_S) {
                sexe1_op_opcode == 8'h03;
            }
            else if (sexe1_type == VU_SEXE_FDIV_S) {
                sexe1_op_opcode == 8'h04;
            }
            else if (sexe1_type == VU_SEXE_FSQRT_S) {
                sexe1_op_opcode == 8'h05;
            }
            else if (sexe1_type == VU_SEXE_FRSQRT_S) {
                sexe1_op_opcode == 8'h06;
            }
            else if (sexe1_type == VU_SEXE_FRCP_S) {
                sexe1_op_opcode == 8'h07;
            }
            else {
                sexe1_op_opcode inside {8'h00, [8'h08:8'hFF]};
            }
        }
    }

    constraint sexe2_op_opcode_c {
        if (inst_gen_cfg.fix_sexe2_op_opcode_en) {
            sexe2_op_opcode == inst_gen_cfg.sexe2_op_opcode;
        } else {
            if (sexe2_type == VU_SEXE_FADD_S) {
                sexe2_op_opcode == 8'h01;
            }
            else if (sexe2_type == VU_SEXE_FSUB_S) {
                sexe2_op_opcode == 8'h02;
            }
            else if (sexe2_type == VU_SEXE_FMUL_S) {
                sexe2_op_opcode == 8'h03;
            }
            else if (sexe2_type == VU_SEXE_FDIV_S) {
                sexe2_op_opcode == 8'h04;
            }
            else if (sexe2_type == VU_SEXE_FSQRT_S) {
                sexe2_op_opcode == 8'h05;
            }
            else if (sexe2_type == VU_SEXE_FRSQRT_S) {
                sexe2_op_opcode == 8'h06;
            }
            else if (sexe2_type == VU_SEXE_FRCP_S) {
                sexe2_op_opcode == 8'h07;
            }
            else {
                sexe2_op_opcode inside {8'h00, [8'h08:8'hFF]};
            }
        }
    }

    constraint su_op_opcode_c {
        if (inst_gen_cfg.fix_su_op_opcode_en) {
            su_op_opcode == inst_gen_cfg.su_op_opcode;
        } else {
            if (su_type == VU_SU_ST_FP8E4M3_V) {
                su_op_opcode == 8'h01;
            }
            else if (su_type == VU_SU_ST_MXFP8_V) {
                su_op_opcode == 8'h02;
            }
            else if (su_type == VU_SU_ST_BF16_V) {
                su_op_opcode == 8'h03;
            }
            else if (su_type == VU_SU_ST_FP32_V) {
                su_op_opcode == 8'h04;
            }
            else if (su_type == VU_SU_ST_MASK) {
                su_op_opcode == 8'h05;
            }
            else if (su_type == VU_SU_ST_S_FP32) {
                su_op_opcode == 8'h06;
            }
            else {
                su_op_opcode inside {8'h00, [8'h07:8'hFF]};
            }
        }
    }

    constraint valu0_op_opcode_c {
        if (inst_gen_cfg.fix_valu0_op_opcode_en) {
            valu0_op_opcode == inst_gen_cfg.valu0_op_opcode;
        } else {
            if (valu0_type == VU_VALU0_VFADD_VV) {
                valu0_op_opcode == 8'h01;
            }
            else if (valu0_type == VU_VALU0_VFADD_VF) {
                valu0_op_opcode == 8'h02;
            }
            else if (valu0_type == VU_VALU0_VFSUB_VV) {
                valu0_op_opcode == 8'h03;
            }
            else if (valu0_type == VU_VALU0_VFSUB_VF) {
                valu0_op_opcode == 8'h04;
            }
            else if (valu0_type == VU_VALU0_VFRSUB_VF) {
                valu0_op_opcode == 8'h05;
            }
            else if (valu0_type == VU_VALU0_VFMUL_VV) {
                valu0_op_opcode == 8'h06;
            }
            else if (valu0_type == VU_VALU0_VFMUL_VF) {
                valu0_op_opcode == 8'h07;
            }
            else if (valu0_type == VU_VALU0_VFDIV_VV) {
                valu0_op_opcode == 8'h08;
            }
            else if (valu0_type == VU_VALU0_VFMIN_VV) {
                valu0_op_opcode == 8'h10;
            }
            else if (valu0_type == VU_VALU0_VFMIN_VF) {
                valu0_op_opcode == 8'h11;
            }
            else if (valu0_type == VU_VALU0_VFMAX_VV) {
                valu0_op_opcode == 8'h12;
            }
            else if (valu0_type == VU_VALU0_VFMAX_VF) {
                valu0_op_opcode == 8'h13;
            }
            else if (valu0_type == VU_VALU0_VFMV_V_F) {
                valu0_op_opcode == 8'h20;
            }
            else if (valu0_type == VU_VALU0_VFMV_S_F) {
                valu0_op_opcode == 8'h21;
            }
            else if (valu0_type == VU_VALU0_VFMACC_VF) {
                valu0_op_opcode == 8'h31;
            }
            else if (valu0_type == VU_VALU0_VFNMACC_VF) {
                valu0_op_opcode == 8'h33;
            }
            else if (valu0_type == VU_VALU0_VFMSAC_VF) {
                valu0_op_opcode == 8'h35;
            }
            else if (valu0_type == VU_VALU0_VFNMSAC_VF) {
                valu0_op_opcode == 8'h37;
            }
            else if (valu0_type == VU_VALU0_VFSGNJ_VV) {
                valu0_op_opcode == 8'h40;
            }
            else if (valu0_type == VU_VALU0_VFSGNJ_VF) {
                valu0_op_opcode == 8'h41;
            }
            else if (valu0_type == VU_VALU0_VFSGNJN_VV) {
                valu0_op_opcode == 8'h42;
            }
            else if (valu0_type == VU_VALU0_VFSGNJN_VF) {
                valu0_op_opcode == 8'h43;
            }
            else if (valu0_type == VU_VALU0_VFSGNJX_VV) {
                valu0_op_opcode == 8'h44;
            }
            else if (valu0_type == VU_VALU0_VFSGNJX_VF) {
                valu0_op_opcode == 8'h45;
            }
            else if (valu0_type == VU_VALU0_VMFEQ_VV) {
                valu0_op_opcode == 8'h50;
            }
            else if (valu0_type == VU_VALU0_VMFEQ_VF) {
                valu0_op_opcode == 8'h51;
            }
            else if (valu0_type == VU_VALU0_VMFNE_VV) {
                valu0_op_opcode == 8'h52;
            }
            else if (valu0_type == VU_VALU0_VMFNE_VF) {
                valu0_op_opcode == 8'h53;
            }
            else if (valu0_type == VU_VALU0_VMFLT_VV) {
                valu0_op_opcode == 8'h54;
            }
            else if (valu0_type == VU_VALU0_VMFLT_VF) {
                valu0_op_opcode == 8'h55;
            }
            else if (valu0_type == VU_VALU0_VMFLE_VV) {
                valu0_op_opcode == 8'h56;
            }
            else if (valu0_type == VU_VALU0_VMFLE_VF) {
                valu0_op_opcode == 8'h57;
            }
            else if (valu0_type == VU_VALU0_VMFGT_VF) {
                valu0_op_opcode == 8'h58;
            }
            else if (valu0_type == VU_VALU0_VMFGE_VF) {
                valu0_op_opcode == 8'h59;
            }
            else if (valu0_type == VU_VALU0_VFCLASS_MV) {
                valu0_op_opcode == 8'h60;
            }
            else if (valu0_type == VU_VALU0_VFMERGE_VFM) {
                valu0_op_opcode == 8'h61;
            }
            else if (valu0_type == VU_VALU0_VFMERGE_VVM) {
                valu0_op_opcode == 8'h62;
            }
            else {
                valu0_op_opcode inside {8'h00, [8'h09:8'h0F], [8'h14:8'h1F], [8'h22:8'h2F], [8'h38:8'h3F], [8'h46:8'h4F], [8'h5A:8'h5F], [8'h63:8'hFF]};
            }
        }
    }

    constraint valu1_op_opcode_c {
        if (inst_gen_cfg.fix_valu1_op_opcode_en) {
            valu1_op_opcode == inst_gen_cfg.valu1_op_opcode;
        } else {
            if (valu1_type == VU_VALU1_VFADD_VV) {
                valu1_op_opcode == 8'h01;
            }
            else if (valu1_type == VU_VALU1_VFADD_VF) {
                valu1_op_opcode == 8'h02;
            }
            else if (valu1_type == VU_VALU1_VFSUB_VV) {
                valu1_op_opcode == 8'h03;
            }
            else if (valu1_type == VU_VALU1_VFSUB_VF) {
                valu1_op_opcode == 8'h04;
            }
            else if (valu1_type == VU_VALU1_VFRSUB_VF) {
                valu1_op_opcode == 8'h05;
            }
            else if (valu1_type == VU_VALU1_VFMUL_VV) {
                valu1_op_opcode == 8'h06;
            }
            else if (valu1_type == VU_VALU1_VFMUL_VF) {
                valu1_op_opcode == 8'h07;
            }
            else if (valu1_type == VU_VALU1_VFMIN_VV) {
                valu1_op_opcode == 8'h10;
            }
            else if (valu1_type == VU_VALU1_VFMIN_VF) {
                valu1_op_opcode == 8'h11;
            }
            else if (valu1_type == VU_VALU1_VFMAX_VV) {
                valu1_op_opcode == 8'h12;
            }
            else if (valu1_type == VU_VALU1_VFMAX_VF) {
                valu1_op_opcode == 8'h13;
            }
            else if (valu1_type == VU_VALU1_VFMV_V_F) {
                valu1_op_opcode == 8'h20;
            }
            else if (valu1_type == VU_VALU1_VFMV_F_S) {
                valu1_op_opcode == 8'h22;
            }
            else if (valu1_type == VU_VALU1_VFREDUSUM_VS) {
                valu1_op_opcode == 8'h70;
            }
            else if (valu1_type == VU_VALU1_VFREDMAX_VS) {
                valu1_op_opcode == 8'h71;
            }
            else if (valu1_type == VU_VALU1_VFREDMIN_VS) {
                valu1_op_opcode == 8'h72;
            }
            else if (valu1_type == VU_VALU1_VSORTMAX16_V) {
                valu1_op_opcode == 8'h73;
            }
            else if (valu1_type == VU_VALU1_VSORTMIN16_V) {
                valu1_op_opcode == 8'h74;
            }
            else {
                valu1_op_opcode inside {8'h00, [8'h08:8'h0F], [8'h14:8'h1F], 8'h21, [8'h23:8'h6F], [8'h75:8'hFF]};
            }
        }
    }

    constraint valu2_op_opcode_c {
        if (inst_gen_cfg.fix_valu2_op_opcode_en) {
            valu2_op_opcode == inst_gen_cfg.valu2_op_opcode;
        } else {
            if (valu2_type == VU_VALU2_VFADD_VV) {
                valu2_op_opcode == 8'h01;
            }
            else if (valu2_type == VU_VALU2_VFADD_VF) {
                valu2_op_opcode == 8'h02;
            }
            else if (valu2_type == VU_VALU2_VFSUB_VV) {
                valu2_op_opcode == 8'h03;
            }
            else if (valu2_type == VU_VALU2_VFSUB_VF) {
                valu2_op_opcode == 8'h04;
            }
            else if (valu2_type == VU_VALU2_VFRSUB_VF) {
                valu2_op_opcode == 8'h05;
            }
            else if (valu2_type == VU_VALU2_VFMUL_VV) {
                valu2_op_opcode == 8'h06;
            }
            else if (valu2_type == VU_VALU2_VFMUL_VF) {
                valu2_op_opcode == 8'h07;
            }
            else if (valu2_type == VU_VALU2_VFMIN_VV) {
                valu2_op_opcode == 8'h10;
            }
            else if (valu2_type == VU_VALU2_VFMIN_VF) {
                valu2_op_opcode == 8'h11;
            }
            else if (valu2_type == VU_VALU2_VFMAX_VV) {
                valu2_op_opcode == 8'h12;
            }
            else if (valu2_type == VU_VALU2_VFMAX_VF) {
                valu2_op_opcode == 8'h13;
            }
            else if (valu2_type == VU_VALU2_VFMV_V_F) {
                valu2_op_opcode == 8'h20;
            }
            else if (valu2_type == VU_VALU2_VMV_V_V) {
                valu2_op_opcode == 8'h23;
            }
            else if (valu2_type == VU_VALU2_VSWAP2_V) {
                valu2_op_opcode == 8'h24;
            }
            else if (valu2_type == VU_VALU2_VFSLIDE1UP_VF) {
                valu2_op_opcode == 8'h25;
            }
            else if (valu2_type == VU_VALU2_VFSLIDE1DOWN_VF) {
                valu2_op_opcode == 8'h26;
            }
            else {
                valu2_op_opcode inside {8'h00, [8'h08:8'h0F], [8'h14:8'h1F], [8'h21:8'h22], [8'h27:8'hFF]};
            }
        }
    }

    constraint vsfu_op_vsfu0_opcode_c {
        if (inst_gen_cfg.fix_vsfu_op_vsfu0_opcode_en) {
            vsfu_op_vsfu0_opcode == inst_gen_cfg.vsfu_op_vsfu0_opcode;
        } else {
            if (vsfu0_type == VU_VSFU_VFSIN_V) {
                vsfu_op_vsfu0_opcode == 8'h01;
            }
            else if (vsfu0_type == VU_VSFU_VFCOS_V) {
                vsfu_op_vsfu0_opcode == 8'h02;
            }
            else if (vsfu0_type == VU_VSFU_VFTANH_V) {
                vsfu_op_vsfu0_opcode == 8'h03;
            }
            else if (vsfu0_type == VU_VSFU_VFSIGMOID_V) {
                vsfu_op_vsfu0_opcode == 8'h04;
            }
            else if (vsfu0_type == VU_VSFU_VFEXP_V) {
                vsfu_op_vsfu0_opcode == 8'h05;
            }
            else if (vsfu0_type == VU_VSFU_VFEXP2_V) {
                vsfu_op_vsfu0_opcode == 8'h06;
            }
            else if (vsfu0_type == VU_VSFU_VFLN_V) {
                vsfu_op_vsfu0_opcode == 8'h07;
            }
            else if (vsfu0_type == VU_VSFU_VFLOG2_V) {
                vsfu_op_vsfu0_opcode == 8'h08;
            }
            else if (vsfu0_type == VU_VSFU_VFSQRT_V) {
                vsfu_op_vsfu0_opcode == 8'h09;
            }
            else if (vsfu0_type == VU_VSFU_VFRCP_V) {
                vsfu_op_vsfu0_opcode == 8'h0A;
            }
            else if (vsfu0_type == VU_VSFU_VFRSQRT_V) {
                vsfu_op_vsfu0_opcode == 8'h0B;
            }
            else if (vsfu0_type == VU_VSFU_CUSTOM_FIT) {
                vsfu_op_vsfu0_opcode == 8'h0C;
            }
            else {
                vsfu_op_vsfu0_opcode inside {8'h00, [8'h0D:8'hFF]};
            }
        }
    }

    constraint vsfu_op_vsfu1_opcode_c {
        if (inst_gen_cfg.fix_vsfu_op_vsfu1_opcode_en) {
            vsfu_op_vsfu1_opcode == inst_gen_cfg.vsfu_op_vsfu1_opcode;
        } else {
            if (vsfu1_type == VU_VSFU_VFSIN_V) {
                vsfu_op_vsfu1_opcode == 8'h01;
            }
            else if (vsfu1_type == VU_VSFU_VFCOS_V) {
                vsfu_op_vsfu1_opcode == 8'h02;
            }
            else if (vsfu1_type == VU_VSFU_VFTANH_V) {
                vsfu_op_vsfu1_opcode == 8'h03;
            }
            else if (vsfu1_type == VU_VSFU_VFSIGMOID_V) {
                vsfu_op_vsfu1_opcode == 8'h04;
            }
            else if (vsfu1_type == VU_VSFU_VFEXP_V) {
                vsfu_op_vsfu1_opcode == 8'h05;
            }
            else if (vsfu1_type == VU_VSFU_VFEXP2_V) {
                vsfu_op_vsfu1_opcode == 8'h06;
            }
            else if (vsfu1_type == VU_VSFU_VFLN_V) {
                vsfu_op_vsfu1_opcode == 8'h07;
            }
            else if (vsfu1_type == VU_VSFU_VFLOG2_V) {
                vsfu_op_vsfu1_opcode == 8'h08;
            }
            else if (vsfu1_type == VU_VSFU_VFSQRT_V) {
                vsfu_op_vsfu1_opcode == 8'h09;
            }
            else if (vsfu1_type == VU_VSFU_VFRCP_V) {
                vsfu_op_vsfu1_opcode == 8'h0A;
            }
            else if (vsfu1_type == VU_VSFU_VFRSQRT_V) {
                vsfu_op_vsfu1_opcode == 8'h0B;
            }
            else if (vsfu1_type == VU_VSFU_CUSTOM_FIT) {
                vsfu_op_vsfu1_opcode == 8'h0C;
            }
            else {
                vsfu_op_vsfu1_opcode inside {8'h00, [8'h0D:8'hFF]};
            }
        }
    }

endclass : vu_mac_inst_seq_item

class cross_1_gen_seq_item extends vu_mac_inst_seq_item;
    //----- cross_inst_1 激励生成控制字段 -----
    rand cross_inst_1_op_e        cross_inst_1_op;
    rand vu_lu_type_e             cross_inst_1_lu_type;
    rand vu_su_type_e             cross_inst_1_su_type;
    rand vu_valu0_type_e          cross_inst_1_valu0_type;
    rand vu_valu1_type_e          cross_inst_1_valu1_type;
    rand vu_valu2_type_e          cross_inst_1_valu2_type;
    rand vu_vsfu_type_e           cross_inst_1_vsfu0_type;
    rand vu_vsfu_type_e           cross_inst_1_vsfu1_type;
    rand vu_mexe_type_e           cross_inst_1_mexe_type;
    rand vu_sexe_type_e           cross_inst_1_sexe_type;

    `uvm_object_utils_begin(cross_1_gen_seq_item)
        `uvm_field_enum         (cross_inst_1_op_e,        cross_inst_1_op,       UVM_DEFAULT)
        `uvm_field_enum         (vu_lu_type_e,        cross_inst_1_lu_type,       UVM_DEFAULT)
        `uvm_field_enum         (vu_su_type_e,        cross_inst_1_su_type,       UVM_DEFAULT)
        `uvm_field_enum         (vu_valu0_type_e,        cross_inst_1_valu0_type,       UVM_DEFAULT)
        `uvm_field_enum         (vu_valu1_type_e,        cross_inst_1_valu1_type,       UVM_DEFAULT)
        `uvm_field_enum         (vu_valu2_type_e,        cross_inst_1_valu2_type,       UVM_DEFAULT)
        `uvm_field_enum         (vu_vsfu_type_e,        cross_inst_1_vsfu0_type,       UVM_DEFAULT)
        `uvm_field_enum         (vu_vsfu_type_e,        cross_inst_1_vsfu1_type,       UVM_DEFAULT)
        `uvm_field_enum         (vu_mexe_type_e,        cross_inst_1_mexe_type,       UVM_DEFAULT)
        `uvm_field_enum         (vu_sexe_type_e,        cross_inst_1_sexe_type,       UVM_DEFAULT)
    `uvm_object_utils_end

    function new (string name = "cross_1_gen_seq_item");
        super.new(name);
    endfunction : new

    //----- 求解顺序 -----
    constraint cross_solve_order_c {
        solve cross_inst_1_op before cross_inst_1_lu_type;
        solve cross_inst_1_op before cross_inst_1_su_type;
        solve cross_inst_1_op before cross_inst_1_valu0_type;
        solve cross_inst_1_op before cross_inst_1_valu1_type;
        solve cross_inst_1_op before cross_inst_1_valu2_type;
        solve cross_inst_1_op before cross_inst_1_vsfu0_type;
        solve cross_inst_1_op before cross_inst_1_vsfu1_type;
        solve cross_inst_1_op before cross_inst_1_mexe_type;
        solve cross_inst_1_op before cross_inst_1_sexe_type;
        solve cross_inst_1_lu_type before lu_type;
        solve cross_inst_1_su_type before su_type;
        solve cross_inst_1_valu0_type before valu0_type;
        solve cross_inst_1_valu1_type before valu1_type;
        solve cross_inst_1_valu2_type before valu2_type;
        solve cross_inst_1_vsfu0_type before vsfu0_type;
        solve cross_inst_1_vsfu1_type before vsfu1_type;
        solve cross_inst_1_mexe_type before mexe_type;
        solve cross_inst_1_sexe_type before sexe0_type;
    }

    //----- cross_inst_1 约束 -----
    constraint cross_inst_1_op_c {
        if (inst_gen_cfg.cross_1_cfg.fix_cross_inst_1_op_en) {
            cross_inst_1_op == inst_gen_cfg.cross_1_cfg.cross_inst_1_op;
        } else {
            cross_inst_1_op dist {
                VU_NOP                   := inst_gen_cfg.cross_1_cfg.cross_inst_1_op_dist[VU_NOP],
                VU_LU                    := inst_gen_cfg.cross_1_cfg.cross_inst_1_op_dist[VU_LU],
                VU_SU                    := inst_gen_cfg.cross_1_cfg.cross_inst_1_op_dist[VU_SU],
                VU_VALU0                 := inst_gen_cfg.cross_1_cfg.cross_inst_1_op_dist[VU_VALU0],
                VU_VALU1                 := inst_gen_cfg.cross_1_cfg.cross_inst_1_op_dist[VU_VALU1],
                VU_VALU2                 := inst_gen_cfg.cross_1_cfg.cross_inst_1_op_dist[VU_VALU2],
                VU_VSFU0                 := inst_gen_cfg.cross_1_cfg.cross_inst_1_op_dist[VU_VSFU0],
                VU_VSFU1                 := inst_gen_cfg.cross_1_cfg.cross_inst_1_op_dist[VU_VSFU1],
                VU_MEXE                  := inst_gen_cfg.cross_1_cfg.cross_inst_1_op_dist[VU_MEXE],
                VU_SEXE                  := inst_gen_cfg.cross_1_cfg.cross_inst_1_op_dist[VU_SEXE]
            };
        }
    }

    constraint cross_inst_1_lu_type_c {
        if (inst_gen_cfg.cross_1_cfg.fix_cross_inst_1_lu_type_en) {
            cross_inst_1_lu_type == inst_gen_cfg.cross_1_cfg.cross_inst_1_lu_type;
        } else if (cross_inst_1_op == VU_LU) {
            cross_inst_1_lu_type dist {
                VU_LU_LD_FP8E4M3_V       := inst_gen_cfg.cross_1_cfg.cross_inst_1_lu_type_dist[VU_LU_LD_FP8E4M3_V],
                VU_LU_LD_MXFP8_V         := inst_gen_cfg.cross_1_cfg.cross_inst_1_lu_type_dist[VU_LU_LD_MXFP8_V],
                VU_LU_LD_BF16_V          := inst_gen_cfg.cross_1_cfg.cross_inst_1_lu_type_dist[VU_LU_LD_BF16_V],
                VU_LU_LD_FP32_V          := inst_gen_cfg.cross_1_cfg.cross_inst_1_lu_type_dist[VU_LU_LD_FP32_V],
                VU_LU_LD_MASK            := inst_gen_cfg.cross_1_cfg.cross_inst_1_lu_type_dist[VU_LU_LD_MASK],
                VU_LU_LD_S_FP32          := inst_gen_cfg.cross_1_cfg.cross_inst_1_lu_type_dist[VU_LU_LD_S_FP32]
            };
        }
    }

    constraint cross_inst_1_su_type_c {
        if (inst_gen_cfg.cross_1_cfg.fix_cross_inst_1_su_type_en) {
            cross_inst_1_su_type == inst_gen_cfg.cross_1_cfg.cross_inst_1_su_type;
        } else if (cross_inst_1_op == VU_SU) {
            cross_inst_1_su_type dist {
                VU_SU_ST_FP8E4M3_V       := inst_gen_cfg.cross_1_cfg.cross_inst_1_su_type_dist[VU_SU_ST_FP8E4M3_V],
                VU_SU_ST_MXFP8_V         := inst_gen_cfg.cross_1_cfg.cross_inst_1_su_type_dist[VU_SU_ST_MXFP8_V],
                VU_SU_ST_BF16_V          := inst_gen_cfg.cross_1_cfg.cross_inst_1_su_type_dist[VU_SU_ST_BF16_V],
                VU_SU_ST_FP32_V          := inst_gen_cfg.cross_1_cfg.cross_inst_1_su_type_dist[VU_SU_ST_FP32_V],
                VU_SU_ST_MASK            := inst_gen_cfg.cross_1_cfg.cross_inst_1_su_type_dist[VU_SU_ST_MASK],
                VU_SU_ST_S_FP32          := inst_gen_cfg.cross_1_cfg.cross_inst_1_su_type_dist[VU_SU_ST_S_FP32]
            };
        }
    }

    constraint cross_inst_1_valu0_type_c {
        if (inst_gen_cfg.cross_1_cfg.fix_cross_inst_1_valu0_type_en) {
            cross_inst_1_valu0_type == inst_gen_cfg.cross_1_cfg.cross_inst_1_valu0_type;
        } else if (cross_inst_1_op == VU_VALU0) {
            cross_inst_1_valu0_type dist {
                VU_VALU0_VFADD_VV        := inst_gen_cfg.cross_1_cfg.cross_inst_1_valu0_type_dist[VU_VALU0_VFADD_VV],
                VU_VALU0_VFADD_VF        := inst_gen_cfg.cross_1_cfg.cross_inst_1_valu0_type_dist[VU_VALU0_VFADD_VF],
                VU_VALU0_VFSUB_VV        := inst_gen_cfg.cross_1_cfg.cross_inst_1_valu0_type_dist[VU_VALU0_VFSUB_VV],
                VU_VALU0_VFSUB_VF        := inst_gen_cfg.cross_1_cfg.cross_inst_1_valu0_type_dist[VU_VALU0_VFSUB_VF],
                VU_VALU0_VFRSUB_VF       := inst_gen_cfg.cross_1_cfg.cross_inst_1_valu0_type_dist[VU_VALU0_VFRSUB_VF],
                VU_VALU0_VFMUL_VV        := inst_gen_cfg.cross_1_cfg.cross_inst_1_valu0_type_dist[VU_VALU0_VFMUL_VV],
                VU_VALU0_VFMUL_VF        := inst_gen_cfg.cross_1_cfg.cross_inst_1_valu0_type_dist[VU_VALU0_VFMUL_VF],
                VU_VALU0_VFDIV_VV        := inst_gen_cfg.cross_1_cfg.cross_inst_1_valu0_type_dist[VU_VALU0_VFDIV_VV],
                VU_VALU0_VFMIN_VV        := inst_gen_cfg.cross_1_cfg.cross_inst_1_valu0_type_dist[VU_VALU0_VFMIN_VV],
                VU_VALU0_VFMIN_VF        := inst_gen_cfg.cross_1_cfg.cross_inst_1_valu0_type_dist[VU_VALU0_VFMIN_VF],
                VU_VALU0_VFMAX_VV        := inst_gen_cfg.cross_1_cfg.cross_inst_1_valu0_type_dist[VU_VALU0_VFMAX_VV],
                VU_VALU0_VFMAX_VF        := inst_gen_cfg.cross_1_cfg.cross_inst_1_valu0_type_dist[VU_VALU0_VFMAX_VF],
                VU_VALU0_VFMV_V_F        := inst_gen_cfg.cross_1_cfg.cross_inst_1_valu0_type_dist[VU_VALU0_VFMV_V_F],
                VU_VALU0_VFMV_S_F        := inst_gen_cfg.cross_1_cfg.cross_inst_1_valu0_type_dist[VU_VALU0_VFMV_S_F],
                VU_VALU0_VFMACC_VF       := inst_gen_cfg.cross_1_cfg.cross_inst_1_valu0_type_dist[VU_VALU0_VFMACC_VF],
                VU_VALU0_VFNMACC_VF      := inst_gen_cfg.cross_1_cfg.cross_inst_1_valu0_type_dist[VU_VALU0_VFNMACC_VF],
                VU_VALU0_VFMSAC_VF       := inst_gen_cfg.cross_1_cfg.cross_inst_1_valu0_type_dist[VU_VALU0_VFMSAC_VF],
                VU_VALU0_VFNMSAC_VF      := inst_gen_cfg.cross_1_cfg.cross_inst_1_valu0_type_dist[VU_VALU0_VFNMSAC_VF],
                VU_VALU0_VFSGNJ_VV       := inst_gen_cfg.cross_1_cfg.cross_inst_1_valu0_type_dist[VU_VALU0_VFSGNJ_VV],
                VU_VALU0_VFSGNJ_VF       := inst_gen_cfg.cross_1_cfg.cross_inst_1_valu0_type_dist[VU_VALU0_VFSGNJ_VF],
                VU_VALU0_VFSGNJN_VV      := inst_gen_cfg.cross_1_cfg.cross_inst_1_valu0_type_dist[VU_VALU0_VFSGNJN_VV],
                VU_VALU0_VFSGNJN_VF      := inst_gen_cfg.cross_1_cfg.cross_inst_1_valu0_type_dist[VU_VALU0_VFSGNJN_VF],
                VU_VALU0_VFSGNJX_VV      := inst_gen_cfg.cross_1_cfg.cross_inst_1_valu0_type_dist[VU_VALU0_VFSGNJX_VV],
                VU_VALU0_VFSGNJX_VF      := inst_gen_cfg.cross_1_cfg.cross_inst_1_valu0_type_dist[VU_VALU0_VFSGNJX_VF],
                VU_VALU0_VMFEQ_VV        := inst_gen_cfg.cross_1_cfg.cross_inst_1_valu0_type_dist[VU_VALU0_VMFEQ_VV],
                VU_VALU0_VMFEQ_VF        := inst_gen_cfg.cross_1_cfg.cross_inst_1_valu0_type_dist[VU_VALU0_VMFEQ_VF],
                VU_VALU0_VMFNE_VV        := inst_gen_cfg.cross_1_cfg.cross_inst_1_valu0_type_dist[VU_VALU0_VMFNE_VV],
                VU_VALU0_VMFNE_VF        := inst_gen_cfg.cross_1_cfg.cross_inst_1_valu0_type_dist[VU_VALU0_VMFNE_VF],
                VU_VALU0_VMFLT_VV        := inst_gen_cfg.cross_1_cfg.cross_inst_1_valu0_type_dist[VU_VALU0_VMFLT_VV],
                VU_VALU0_VMFLT_VF        := inst_gen_cfg.cross_1_cfg.cross_inst_1_valu0_type_dist[VU_VALU0_VMFLT_VF],
                VU_VALU0_VMFLE_VV        := inst_gen_cfg.cross_1_cfg.cross_inst_1_valu0_type_dist[VU_VALU0_VMFLE_VV],
                VU_VALU0_VMFLE_VF        := inst_gen_cfg.cross_1_cfg.cross_inst_1_valu0_type_dist[VU_VALU0_VMFLE_VF],
                VU_VALU0_VMFGT_VF        := inst_gen_cfg.cross_1_cfg.cross_inst_1_valu0_type_dist[VU_VALU0_VMFGT_VF],
                VU_VALU0_VMFGE_VF        := inst_gen_cfg.cross_1_cfg.cross_inst_1_valu0_type_dist[VU_VALU0_VMFGE_VF],
                VU_VALU0_VFCLASS_MV      := inst_gen_cfg.cross_1_cfg.cross_inst_1_valu0_type_dist[VU_VALU0_VFCLASS_MV],
                VU_VALU0_VFMERGE_VFM     := inst_gen_cfg.cross_1_cfg.cross_inst_1_valu0_type_dist[VU_VALU0_VFMERGE_VFM],
                VU_VALU0_VFMERGE_VVM     := inst_gen_cfg.cross_1_cfg.cross_inst_1_valu0_type_dist[VU_VALU0_VFMERGE_VVM]
            };
        }
    }

    constraint cross_inst_1_valu1_type_c {
        if (inst_gen_cfg.cross_1_cfg.fix_cross_inst_1_valu1_type_en) {
            cross_inst_1_valu1_type == inst_gen_cfg.cross_1_cfg.cross_inst_1_valu1_type;
        } else if (cross_inst_1_op == VU_VALU1) {
            cross_inst_1_valu1_type dist {
                VU_VALU1_VFADD_VV        := inst_gen_cfg.cross_1_cfg.cross_inst_1_valu1_type_dist[VU_VALU1_VFADD_VV],
                VU_VALU1_VFADD_VF        := inst_gen_cfg.cross_1_cfg.cross_inst_1_valu1_type_dist[VU_VALU1_VFADD_VF],
                VU_VALU1_VFSUB_VV        := inst_gen_cfg.cross_1_cfg.cross_inst_1_valu1_type_dist[VU_VALU1_VFSUB_VV],
                VU_VALU1_VFSUB_VF        := inst_gen_cfg.cross_1_cfg.cross_inst_1_valu1_type_dist[VU_VALU1_VFSUB_VF],
                VU_VALU1_VFRSUB_VF       := inst_gen_cfg.cross_1_cfg.cross_inst_1_valu1_type_dist[VU_VALU1_VFRSUB_VF],
                VU_VALU1_VFMUL_VV        := inst_gen_cfg.cross_1_cfg.cross_inst_1_valu1_type_dist[VU_VALU1_VFMUL_VV],
                VU_VALU1_VFMUL_VF        := inst_gen_cfg.cross_1_cfg.cross_inst_1_valu1_type_dist[VU_VALU1_VFMUL_VF],
                VU_VALU1_VFMIN_VV        := inst_gen_cfg.cross_1_cfg.cross_inst_1_valu1_type_dist[VU_VALU1_VFMIN_VV],
                VU_VALU1_VFMIN_VF        := inst_gen_cfg.cross_1_cfg.cross_inst_1_valu1_type_dist[VU_VALU1_VFMIN_VF],
                VU_VALU1_VFMAX_VV        := inst_gen_cfg.cross_1_cfg.cross_inst_1_valu1_type_dist[VU_VALU1_VFMAX_VV],
                VU_VALU1_VFMAX_VF        := inst_gen_cfg.cross_1_cfg.cross_inst_1_valu1_type_dist[VU_VALU1_VFMAX_VF],
                VU_VALU1_VFMV_V_F        := inst_gen_cfg.cross_1_cfg.cross_inst_1_valu1_type_dist[VU_VALU1_VFMV_V_F],
                VU_VALU1_VFMV_F_S        := inst_gen_cfg.cross_1_cfg.cross_inst_1_valu1_type_dist[VU_VALU1_VFMV_F_S],
                VU_VALU1_VFREDUSUM_VS    := inst_gen_cfg.cross_1_cfg.cross_inst_1_valu1_type_dist[VU_VALU1_VFREDUSUM_VS],
                VU_VALU1_VFREDMAX_VS     := inst_gen_cfg.cross_1_cfg.cross_inst_1_valu1_type_dist[VU_VALU1_VFREDMAX_VS],
                VU_VALU1_VFREDMIN_VS     := inst_gen_cfg.cross_1_cfg.cross_inst_1_valu1_type_dist[VU_VALU1_VFREDMIN_VS],
                VU_VALU1_VSORTMAX16_V    := inst_gen_cfg.cross_1_cfg.cross_inst_1_valu1_type_dist[VU_VALU1_VSORTMAX16_V],
                VU_VALU1_VSORTMIN16_V    := inst_gen_cfg.cross_1_cfg.cross_inst_1_valu1_type_dist[VU_VALU1_VSORTMIN16_V]
            };
        }
    }

    constraint cross_inst_1_valu2_type_c {
        if (inst_gen_cfg.cross_1_cfg.fix_cross_inst_1_valu2_type_en) {
            cross_inst_1_valu2_type == inst_gen_cfg.cross_1_cfg.cross_inst_1_valu2_type;
        } else if (cross_inst_1_op == VU_VALU2) {
            cross_inst_1_valu2_type dist {
                VU_VALU2_VFADD_VV        := inst_gen_cfg.cross_1_cfg.cross_inst_1_valu2_type_dist[VU_VALU2_VFADD_VV],
                VU_VALU2_VFADD_VF        := inst_gen_cfg.cross_1_cfg.cross_inst_1_valu2_type_dist[VU_VALU2_VFADD_VF],
                VU_VALU2_VFSUB_VV        := inst_gen_cfg.cross_1_cfg.cross_inst_1_valu2_type_dist[VU_VALU2_VFSUB_VV],
                VU_VALU2_VFSUB_VF        := inst_gen_cfg.cross_1_cfg.cross_inst_1_valu2_type_dist[VU_VALU2_VFSUB_VF],
                VU_VALU2_VFRSUB_VF       := inst_gen_cfg.cross_1_cfg.cross_inst_1_valu2_type_dist[VU_VALU2_VFRSUB_VF],
                VU_VALU2_VFMUL_VV        := inst_gen_cfg.cross_1_cfg.cross_inst_1_valu2_type_dist[VU_VALU2_VFMUL_VV],
                VU_VALU2_VFMUL_VF        := inst_gen_cfg.cross_1_cfg.cross_inst_1_valu2_type_dist[VU_VALU2_VFMUL_VF],
                VU_VALU2_VFMIN_VV        := inst_gen_cfg.cross_1_cfg.cross_inst_1_valu2_type_dist[VU_VALU2_VFMIN_VV],
                VU_VALU2_VFMIN_VF        := inst_gen_cfg.cross_1_cfg.cross_inst_1_valu2_type_dist[VU_VALU2_VFMIN_VF],
                VU_VALU2_VFMAX_VV        := inst_gen_cfg.cross_1_cfg.cross_inst_1_valu2_type_dist[VU_VALU2_VFMAX_VV],
                VU_VALU2_VFMAX_VF        := inst_gen_cfg.cross_1_cfg.cross_inst_1_valu2_type_dist[VU_VALU2_VFMAX_VF],
                VU_VALU2_VFMV_V_F        := inst_gen_cfg.cross_1_cfg.cross_inst_1_valu2_type_dist[VU_VALU2_VFMV_V_F],
                VU_VALU2_VMV_V_V         := inst_gen_cfg.cross_1_cfg.cross_inst_1_valu2_type_dist[VU_VALU2_VMV_V_V],
                VU_VALU2_VSWAP2_V        := inst_gen_cfg.cross_1_cfg.cross_inst_1_valu2_type_dist[VU_VALU2_VSWAP2_V],
                VU_VALU2_VFSLIDE1UP_VF   := inst_gen_cfg.cross_1_cfg.cross_inst_1_valu2_type_dist[VU_VALU2_VFSLIDE1UP_VF],
                VU_VALU2_VFSLIDE1DOWN_VF := inst_gen_cfg.cross_1_cfg.cross_inst_1_valu2_type_dist[VU_VALU2_VFSLIDE1DOWN_VF]
            };
        }
    }

    constraint cross_inst_1_vsfu0_type_c {
        if (inst_gen_cfg.cross_1_cfg.fix_cross_inst_1_vsfu0_type_en) {
            cross_inst_1_vsfu0_type == inst_gen_cfg.cross_1_cfg.cross_inst_1_vsfu0_type;
        } else if (cross_inst_1_op == VU_VSFU0) {
            cross_inst_1_vsfu0_type dist {
                VU_VSFU_VFSIN_V          := inst_gen_cfg.cross_1_cfg.cross_inst_1_vsfu0_type_dist[VU_VSFU_VFSIN_V],
                VU_VSFU_VFCOS_V          := inst_gen_cfg.cross_1_cfg.cross_inst_1_vsfu0_type_dist[VU_VSFU_VFCOS_V],
                VU_VSFU_VFTANH_V         := inst_gen_cfg.cross_1_cfg.cross_inst_1_vsfu0_type_dist[VU_VSFU_VFTANH_V],
                VU_VSFU_VFSIGMOID_V      := inst_gen_cfg.cross_1_cfg.cross_inst_1_vsfu0_type_dist[VU_VSFU_VFSIGMOID_V],
                VU_VSFU_VFEXP_V          := inst_gen_cfg.cross_1_cfg.cross_inst_1_vsfu0_type_dist[VU_VSFU_VFEXP_V],
                VU_VSFU_VFEXP2_V         := inst_gen_cfg.cross_1_cfg.cross_inst_1_vsfu0_type_dist[VU_VSFU_VFEXP2_V],
                VU_VSFU_VFLN_V           := inst_gen_cfg.cross_1_cfg.cross_inst_1_vsfu0_type_dist[VU_VSFU_VFLN_V],
                VU_VSFU_VFLOG2_V         := inst_gen_cfg.cross_1_cfg.cross_inst_1_vsfu0_type_dist[VU_VSFU_VFLOG2_V],
                VU_VSFU_VFSQRT_V         := inst_gen_cfg.cross_1_cfg.cross_inst_1_vsfu0_type_dist[VU_VSFU_VFSQRT_V],
                VU_VSFU_VFRCP_V          := inst_gen_cfg.cross_1_cfg.cross_inst_1_vsfu0_type_dist[VU_VSFU_VFRCP_V],
                VU_VSFU_VFRSQRT_V        := inst_gen_cfg.cross_1_cfg.cross_inst_1_vsfu0_type_dist[VU_VSFU_VFRSQRT_V],
                VU_VSFU_CUSTOM_FIT       := inst_gen_cfg.cross_1_cfg.cross_inst_1_vsfu0_type_dist[VU_VSFU_CUSTOM_FIT]
            };
        }
    }

    constraint cross_inst_1_vsfu1_type_c {
        if (inst_gen_cfg.cross_1_cfg.fix_cross_inst_1_vsfu1_type_en) {
            cross_inst_1_vsfu1_type == inst_gen_cfg.cross_1_cfg.cross_inst_1_vsfu1_type;
        } else if (cross_inst_1_op == VU_VSFU1) {
            cross_inst_1_vsfu1_type dist {
                VU_VSFU_VFSIN_V          := inst_gen_cfg.cross_1_cfg.cross_inst_1_vsfu1_type_dist[VU_VSFU_VFSIN_V],
                VU_VSFU_VFCOS_V          := inst_gen_cfg.cross_1_cfg.cross_inst_1_vsfu1_type_dist[VU_VSFU_VFCOS_V],
                VU_VSFU_VFTANH_V         := inst_gen_cfg.cross_1_cfg.cross_inst_1_vsfu1_type_dist[VU_VSFU_VFTANH_V],
                VU_VSFU_VFSIGMOID_V      := inst_gen_cfg.cross_1_cfg.cross_inst_1_vsfu1_type_dist[VU_VSFU_VFSIGMOID_V],
                VU_VSFU_VFEXP_V          := inst_gen_cfg.cross_1_cfg.cross_inst_1_vsfu1_type_dist[VU_VSFU_VFEXP_V],
                VU_VSFU_VFEXP2_V         := inst_gen_cfg.cross_1_cfg.cross_inst_1_vsfu1_type_dist[VU_VSFU_VFEXP2_V],
                VU_VSFU_VFLN_V           := inst_gen_cfg.cross_1_cfg.cross_inst_1_vsfu1_type_dist[VU_VSFU_VFLN_V],
                VU_VSFU_VFLOG2_V         := inst_gen_cfg.cross_1_cfg.cross_inst_1_vsfu1_type_dist[VU_VSFU_VFLOG2_V],
                VU_VSFU_VFSQRT_V         := inst_gen_cfg.cross_1_cfg.cross_inst_1_vsfu1_type_dist[VU_VSFU_VFSQRT_V],
                VU_VSFU_VFRCP_V          := inst_gen_cfg.cross_1_cfg.cross_inst_1_vsfu1_type_dist[VU_VSFU_VFRCP_V],
                VU_VSFU_VFRSQRT_V        := inst_gen_cfg.cross_1_cfg.cross_inst_1_vsfu1_type_dist[VU_VSFU_VFRSQRT_V],
                VU_VSFU_CUSTOM_FIT       := inst_gen_cfg.cross_1_cfg.cross_inst_1_vsfu1_type_dist[VU_VSFU_CUSTOM_FIT]
            };
        }
    }

    constraint cross_inst_1_mexe_type_c {
        if (inst_gen_cfg.cross_1_cfg.fix_cross_inst_1_mexe_type_en) {
            cross_inst_1_mexe_type == inst_gen_cfg.cross_1_cfg.cross_inst_1_mexe_type;
        } else if (cross_inst_1_op == VU_MEXE) {
            cross_inst_1_mexe_type dist {
                VU_MEXE_VMAND_MM         := inst_gen_cfg.cross_1_cfg.cross_inst_1_mexe_type_dist[VU_MEXE_VMAND_MM],
                VU_MEXE_VMNAND_MM        := inst_gen_cfg.cross_1_cfg.cross_inst_1_mexe_type_dist[VU_MEXE_VMNAND_MM],
                VU_MEXE_VMANDN_MM        := inst_gen_cfg.cross_1_cfg.cross_inst_1_mexe_type_dist[VU_MEXE_VMANDN_MM],
                VU_MEXE_VMXOR_MM         := inst_gen_cfg.cross_1_cfg.cross_inst_1_mexe_type_dist[VU_MEXE_VMXOR_MM],
                VU_MEXE_VMOR_MM          := inst_gen_cfg.cross_1_cfg.cross_inst_1_mexe_type_dist[VU_MEXE_VMOR_MM],
                VU_MEXE_VMNOR_MM         := inst_gen_cfg.cross_1_cfg.cross_inst_1_mexe_type_dist[VU_MEXE_VMNOR_MM],
                VU_MEXE_VMORN_MM         := inst_gen_cfg.cross_1_cfg.cross_inst_1_mexe_type_dist[VU_MEXE_VMORN_MM],
                VU_MEXE_VMXNOR_MM        := inst_gen_cfg.cross_1_cfg.cross_inst_1_mexe_type_dist[VU_MEXE_VMXNOR_MM],
                VU_MEXE_VCPOP_M          := inst_gen_cfg.cross_1_cfg.cross_inst_1_mexe_type_dist[VU_MEXE_VCPOP_M],
                VU_MEXE_VFIRST_M         := inst_gen_cfg.cross_1_cfg.cross_inst_1_mexe_type_dist[VU_MEXE_VFIRST_M],
                VU_MEXE_VMSBF_M          := inst_gen_cfg.cross_1_cfg.cross_inst_1_mexe_type_dist[VU_MEXE_VMSBF_M],
                VU_MEXE_VMSIF_M          := inst_gen_cfg.cross_1_cfg.cross_inst_1_mexe_type_dist[VU_MEXE_VMSIF_M],
                VU_MEXE_VMSOF_M          := inst_gen_cfg.cross_1_cfg.cross_inst_1_mexe_type_dist[VU_MEXE_VMSOF_M],
                VU_MEXE_VMIUSET_MV       := inst_gen_cfg.cross_1_cfg.cross_inst_1_mexe_type_dist[VU_MEXE_VMIUSET_MV],
                VU_MEXE_VMISET_MV        := inst_gen_cfg.cross_1_cfg.cross_inst_1_mexe_type_dist[VU_MEXE_VMISET_MV]
            };
        }
    }

    constraint cross_inst_1_sexe_type_c {
        if (inst_gen_cfg.cross_1_cfg.fix_cross_inst_1_sexe_type_en) {
            cross_inst_1_sexe_type == inst_gen_cfg.cross_1_cfg.cross_inst_1_sexe_type;
        } else if (cross_inst_1_op == VU_SEXE) {
            cross_inst_1_sexe_type dist {
                VU_SEXE_FADD_S           := inst_gen_cfg.cross_1_cfg.cross_inst_1_sexe_type_dist[VU_SEXE_FADD_S],
                VU_SEXE_FSUB_S           := inst_gen_cfg.cross_1_cfg.cross_inst_1_sexe_type_dist[VU_SEXE_FSUB_S],
                VU_SEXE_FMUL_S           := inst_gen_cfg.cross_1_cfg.cross_inst_1_sexe_type_dist[VU_SEXE_FMUL_S],
                VU_SEXE_FDIV_S           := inst_gen_cfg.cross_1_cfg.cross_inst_1_sexe_type_dist[VU_SEXE_FDIV_S],
                VU_SEXE_FSQRT_S          := inst_gen_cfg.cross_1_cfg.cross_inst_1_sexe_type_dist[VU_SEXE_FSQRT_S],
                VU_SEXE_FRSQRT_S         := inst_gen_cfg.cross_1_cfg.cross_inst_1_sexe_type_dist[VU_SEXE_FRSQRT_S],
                VU_SEXE_FRCP_S           := inst_gen_cfg.cross_1_cfg.cross_inst_1_sexe_type_dist[VU_SEXE_FRCP_S]
            };
        }
    }

    //----- cross_inst_1_*_type → 执行单元 *_type -----
    constraint lu_type_from_cross_c {
        if (cross_inst_1_op == VU_LU) {
            lu_type == cross_inst_1_lu_type;
        } else {
            lu_type == VU_LU_TYPE_END;
        }
    }

    constraint su_type_from_cross_c {
        if (cross_inst_1_op == VU_SU) {
            su_type == cross_inst_1_su_type;
        } else {
            su_type == VU_SU_TYPE_END;
        }
    }

    constraint valu0_type_from_cross_c {
        if (cross_inst_1_op == VU_VALU0) {
            valu0_type == cross_inst_1_valu0_type;
        } else {
            valu0_type == VU_VALU0_TYPE_END;
        }
    }

    constraint valu1_type_from_cross_c {
        if (cross_inst_1_op == VU_VALU1) {
            valu1_type == cross_inst_1_valu1_type;
        } else {
            valu1_type == VU_VALU1_TYPE_END;
        }
    }

    constraint valu2_type_from_cross_c {
        if (cross_inst_1_op == VU_VALU2) {
            valu2_type == cross_inst_1_valu2_type;
        } else {
            valu2_type == VU_VALU2_TYPE_END;
        }
    }

    constraint vsfu0_type_from_cross_c {
        if (cross_inst_1_op == VU_VSFU0) {
            vsfu0_type == cross_inst_1_vsfu0_type;
        } else {
            vsfu0_type == VU_VSFU_TYPE_END;
        }
    }

    constraint vsfu1_type_from_cross_c {
        if (cross_inst_1_op == VU_VSFU1) {
            vsfu1_type == cross_inst_1_vsfu1_type;
        } else {
            vsfu1_type == VU_VSFU_TYPE_END;
        }
    }

    constraint mexe_type_from_cross_c {
        if (cross_inst_1_op == VU_MEXE) {
            mexe_type == cross_inst_1_mexe_type;
        } else {
            mexe_type == VU_MEXE_TYPE_END;
        }
    }

    constraint sexe0_type_from_cross_c {
        if (cross_inst_1_op == VU_SEXE) {
            sexe0_type == cross_inst_1_sexe_type;
        } else {
            sexe0_type == VU_SEXE_TYPE_END;
        }
    }

    constraint sexe1_type_from_cross_c {
        sexe1_type == VU_SEXE_TYPE_END;
    }

    constraint sexe2_type_from_cross_c {
        sexe2_type == VU_SEXE_TYPE_END;
    }

    //----- 寄存器位域固定值约束（来源：vu_cross_1inst.xlsx cross_1inst） -----
    constraint prf_op_mrf_wt_src_c {
        if (inst_gen_cfg.fix_prf_op_mrf_wt_src_en) {
            prf_op_mrf_wt_src == inst_gen_cfg.prf_op_mrf_wt_src;
        } else {
            if (cross_inst_1_op == VU_LU) {
                    if (cross_inst_1_lu_type == VU_LU_LD_MASK) {
                        prf_op_mrf_wt_src == 8'h01;
                    }
                    else {
                        prf_op_mrf_wt_src == 8'h00;
                    }
            }
            else if (cross_inst_1_op == VU_VALU0) {
                    if (cross_inst_1_valu0_type inside {VU_VALU0_VMFEQ_VV, VU_VALU0_VMFEQ_VF, VU_VALU0_VMFNE_VV, VU_VALU0_VMFNE_VF, VU_VALU0_VMFLT_VV, VU_VALU0_VMFLT_VF, VU_VALU0_VMFLE_VV, VU_VALU0_VMFLE_VF, VU_VALU0_VMFGT_VF, VU_VALU0_VMFGE_VF, VU_VALU0_VFCLASS_MV}) {
                        prf_op_mrf_wt_src == 8'h02;
                    }
                    else {
                        prf_op_mrf_wt_src == 8'h00;
                    }
            }
            else if (cross_inst_1_op == VU_MEXE) {
                    if (cross_inst_1_mexe_type inside {VU_MEXE_VMAND_MM, VU_MEXE_VMNAND_MM, VU_MEXE_VMANDN_MM, VU_MEXE_VMXOR_MM, VU_MEXE_VMOR_MM, VU_MEXE_VMNOR_MM, VU_MEXE_VMORN_MM, VU_MEXE_VMXNOR_MM, VU_MEXE_VMSBF_M, VU_MEXE_VMSIF_M, VU_MEXE_VMSOF_M, VU_MEXE_VMIUSET_MV, VU_MEXE_VMISET_MV}) {
                        prf_op_mrf_wt_src == 8'h10;
                    }
                    else {
                        prf_op_mrf_wt_src == 8'h00;
                    }
            }
            else {
                prf_op_mrf_wt_src == 8'h00;
            }
        }
    }

    constraint prf_op_srf_wt_en_c {
        if (inst_gen_cfg.fix_prf_op_srf_wt_en_en) {
            prf_op_srf_wt_en == inst_gen_cfg.prf_op_srf_wt_en;
        } else {
            if (cross_inst_1_op == VU_LU) {
                    if (cross_inst_1_lu_type == VU_LU_LD_S_FP32) {
                        prf_op_srf_wt_en == 8'h01;
                    }
                    else {
                        prf_op_srf_wt_en == 8'h00;
                    }
            }
            else if (cross_inst_1_op == VU_VALU1) {
                    if (cross_inst_1_valu1_type inside {VU_VALU1_VFMV_F_S, VU_VALU1_VFREDUSUM_VS, VU_VALU1_VFREDMAX_VS, VU_VALU1_VFREDMIN_VS}) {
                        prf_op_srf_wt_en == 8'h02;
                    }
                    else {
                        prf_op_srf_wt_en == 8'h00;
                    }
            }
            else if (cross_inst_1_op == VU_MEXE) {
                    if (cross_inst_1_mexe_type inside {VU_MEXE_VCPOP_M, VU_MEXE_VFIRST_M}) {
                        prf_op_srf_wt_en == 8'h04;
                    }
                    else {
                        prf_op_srf_wt_en == 8'h00;
                    }
            }
            else if (cross_inst_1_op == VU_SEXE) {
                    if (cross_inst_1_sexe_type inside {VU_SEXE_FADD_S, VU_SEXE_FSUB_S, VU_SEXE_FMUL_S, VU_SEXE_FDIV_S, VU_SEXE_FSQRT_S, VU_SEXE_FRSQRT_S, VU_SEXE_FRCP_S}) {
                        prf_op_srf_wt_en == 8'h08;
                    }
                    else {
                        prf_op_srf_wt_en == 8'h00;
                    }
            }
            else {
                prf_op_srf_wt_en == 8'h00;
            }
        }
    }

    constraint static_type_vl_data_type_c {
        if (inst_gen_cfg.fix_static_type_vl_data_type_en) {
            static_type_vl_data_type == inst_gen_cfg.static_type_vl_data_type;
        } else {
            if (cross_inst_1_op == VU_VSFU1) {
                static_type_vl_data_type == 1'b0;
            }
        }
    }

    constraint prf_op_vrf_wt_src_c {
        if (inst_gen_cfg.fix_prf_op_vrf_wt_p0_src_en) {
            prf_op_vrf_wt_p0_src == inst_gen_cfg.prf_op_vrf_wt_p0_src;
        }
        if (inst_gen_cfg.fix_prf_op_vrf_wt_p1_src_en) {
            prf_op_vrf_wt_p1_src == inst_gen_cfg.prf_op_vrf_wt_p1_src;
        }
        if (!inst_gen_cfg.fix_prf_op_vrf_wt_p0_src_en
            && !inst_gen_cfg.fix_prf_op_vrf_wt_p1_src_en) {
            if (cross_inst_1_op == VU_LU) {
                    if (cross_inst_1_lu_type inside {VU_LU_LD_FP8E4M3_V, VU_LU_LD_MXFP8_V, VU_LU_LD_BF16_V, VU_LU_LD_FP32_V}) {
                    {prf_op_vrf_wt_p0_src, prf_op_vrf_wt_p1_src} dist {
                        {8'h01, 8'h00} := inst_gen_cfg.prf_op_vrf_wt_pair_weight,
                        {8'h00, 8'h01} := 100 - inst_gen_cfg.prf_op_vrf_wt_pair_weight
                    };
                    }
                    else {
                        prf_op_vrf_wt_p0_src == 8'h00 && prf_op_vrf_wt_p1_src == 8'h00;
                    }
            }
            else if (cross_inst_1_op == VU_VALU0) {
                    if (cross_inst_1_valu0_type inside {VU_VALU0_VFADD_VV, VU_VALU0_VFADD_VF, VU_VALU0_VFSUB_VV, VU_VALU0_VFSUB_VF, VU_VALU0_VFRSUB_VF, VU_VALU0_VFMUL_VV, VU_VALU0_VFMUL_VF, VU_VALU0_VFDIV_VV, VU_VALU0_VFMIN_VV, VU_VALU0_VFMIN_VF, VU_VALU0_VFMAX_VV, VU_VALU0_VFMAX_VF, VU_VALU0_VFMV_V_F, VU_VALU0_VFMV_S_F, VU_VALU0_VFMACC_VF, VU_VALU0_VFNMACC_VF, VU_VALU0_VFMSAC_VF, VU_VALU0_VFNMSAC_VF, VU_VALU0_VFSGNJ_VV, VU_VALU0_VFSGNJ_VF, VU_VALU0_VFSGNJN_VV, VU_VALU0_VFSGNJN_VF, VU_VALU0_VFSGNJX_VV, VU_VALU0_VFSGNJX_VF, VU_VALU0_VFMERGE_VFM, VU_VALU0_VFMERGE_VVM}) {
                    {prf_op_vrf_wt_p0_src, prf_op_vrf_wt_p1_src} dist {
                        {8'h02, 8'h00} := inst_gen_cfg.prf_op_vrf_wt_pair_weight,
                        {8'h00, 8'h02} := 100 - inst_gen_cfg.prf_op_vrf_wt_pair_weight
                    };
                    }
                    else {
                        prf_op_vrf_wt_p0_src == 8'h00 && prf_op_vrf_wt_p1_src == 8'h00;
                    }
            }
            else if (cross_inst_1_op == VU_VALU1) {
                    if (cross_inst_1_valu1_type inside {VU_VALU1_VFADD_VV, VU_VALU1_VFADD_VF, VU_VALU1_VFSUB_VV, VU_VALU1_VFSUB_VF, VU_VALU1_VFRSUB_VF, VU_VALU1_VFMUL_VV, VU_VALU1_VFMUL_VF, VU_VALU1_VFMIN_VV, VU_VALU1_VFMIN_VF, VU_VALU1_VFMAX_VV, VU_VALU1_VFMAX_VF, VU_VALU1_VFMV_V_F, VU_VALU1_VSORTMAX16_V, VU_VALU1_VSORTMIN16_V}) {
                    {prf_op_vrf_wt_p0_src, prf_op_vrf_wt_p1_src} dist {
                        {8'h03, 8'h00} := inst_gen_cfg.prf_op_vrf_wt_pair_weight,
                        {8'h00, 8'h03} := 100 - inst_gen_cfg.prf_op_vrf_wt_pair_weight
                    };
                    }
                    else {
                        prf_op_vrf_wt_p0_src == 8'h00 && prf_op_vrf_wt_p1_src == 8'h00;
                    }
            }
            else if (cross_inst_1_op == VU_VALU2) {
                    if (cross_inst_1_valu2_type inside {VU_VALU2_VFADD_VV, VU_VALU2_VFADD_VF, VU_VALU2_VFSUB_VV, VU_VALU2_VFSUB_VF, VU_VALU2_VFRSUB_VF, VU_VALU2_VFMUL_VV, VU_VALU2_VFMUL_VF, VU_VALU2_VFMIN_VV, VU_VALU2_VFMIN_VF, VU_VALU2_VFMAX_VV, VU_VALU2_VFMAX_VF, VU_VALU2_VFMV_V_F, VU_VALU2_VMV_V_V, VU_VALU2_VSWAP2_V, VU_VALU2_VFSLIDE1UP_VF, VU_VALU2_VFSLIDE1DOWN_VF}) {
                    {prf_op_vrf_wt_p0_src, prf_op_vrf_wt_p1_src} dist {
                        {8'h04, 8'h00} := inst_gen_cfg.prf_op_vrf_wt_pair_weight,
                        {8'h00, 8'h04} := 100 - inst_gen_cfg.prf_op_vrf_wt_pair_weight
                    };
                    }
                    else {
                        prf_op_vrf_wt_p0_src == 8'h00 && prf_op_vrf_wt_p1_src == 8'h00;
                    }
            }
            else if (cross_inst_1_op == VU_VSFU0) {
                    if (cross_inst_1_vsfu0_type inside {VU_VSFU_VFSIN_V, VU_VSFU_VFCOS_V, VU_VSFU_VFTANH_V, VU_VSFU_VFSIGMOID_V, VU_VSFU_VFEXP_V, VU_VSFU_VFEXP2_V, VU_VSFU_VFLN_V, VU_VSFU_VFLOG2_V, VU_VSFU_VFSQRT_V, VU_VSFU_VFRCP_V, VU_VSFU_VFRSQRT_V, VU_VSFU_CUSTOM_FIT}) {
                    {prf_op_vrf_wt_p0_src, prf_op_vrf_wt_p1_src} dist {
                        {8'h05, 8'h00} := inst_gen_cfg.prf_op_vrf_wt_pair_weight,
                        {8'h00, 8'h05} := 100 - inst_gen_cfg.prf_op_vrf_wt_pair_weight
                    };
                    }
                    else {
                        prf_op_vrf_wt_p0_src == 8'h00 && prf_op_vrf_wt_p1_src == 8'h00;
                    }
            }
            else if (cross_inst_1_op == VU_VSFU1) {
                    if (cross_inst_1_vsfu1_type inside {VU_VSFU_VFSIN_V, VU_VSFU_VFCOS_V, VU_VSFU_VFTANH_V, VU_VSFU_VFSIGMOID_V, VU_VSFU_VFEXP_V, VU_VSFU_VFEXP2_V, VU_VSFU_VFLN_V, VU_VSFU_VFLOG2_V, VU_VSFU_VFSQRT_V, VU_VSFU_VFRCP_V, VU_VSFU_VFRSQRT_V, VU_VSFU_CUSTOM_FIT}) {
                    {prf_op_vrf_wt_p0_src, prf_op_vrf_wt_p1_src} dist {
                        {8'h06, 8'h00} := inst_gen_cfg.prf_op_vrf_wt_pair_weight,
                        {8'h00, 8'h06} := 100 - inst_gen_cfg.prf_op_vrf_wt_pair_weight
                    };
                    }
                    else {
                        prf_op_vrf_wt_p0_src == 8'h00 && prf_op_vrf_wt_p1_src == 8'h00;
                    }
            }
            else {
                prf_op_vrf_wt_p0_src == 8'h00;
                prf_op_vrf_wt_p1_src == 8'h00;
            }
        }
    }

    //----- SRC*_SEL / MASK_SEL：按执行单元独立约束（'/' 分段联合 dist） -----

    constraint su_src_sel_c {
        if (!inst_gen_cfg.fix_su_op_src_sel_en) {
            if (cross_inst_1_op == VU_SU) {
                    if (cross_inst_1_su_type inside {VU_SU_ST_FP8E4M3_V, VU_SU_ST_MXFP8_V, VU_SU_ST_BF16_V, VU_SU_ST_FP32_V}) {
                        su_op_src_sel inside {[8'h30:8'h31]};
                    }
                    else if (cross_inst_1_su_type == VU_SU_ST_MASK) {
                        su_op_src_sel inside {[8'h40:8'h41]};
                    }
                    else if (cross_inst_1_su_type == VU_SU_ST_S_FP32) {
                        su_op_src_sel == 8'h50;
                    }
                    else {
                                                su_op_src_sel == 8'h00;
                    }
            }
            else {
                su_op_src_sel == 8'h00;
            }
        }
    }

    constraint valu0_src_mask_sel_c {
        if (!inst_gen_cfg.fix_valu0_op_src1_sel_en &&
            !inst_gen_cfg.fix_valu0_op_src2_sel_en &&
            !inst_gen_cfg.fix_valu0_op_src3_sel_en &&
            !inst_gen_cfg.fix_mask_op_valu0_mask_sel_en) {
            if (cross_inst_1_op == VU_VALU0) {
                    if (cross_inst_1_valu0_type inside {VU_VALU0_VFADD_VV, VU_VALU0_VFSUB_VV, VU_VALU0_VFMUL_VV, VU_VALU0_VFDIV_VV, VU_VALU0_VFMIN_VV, VU_VALU0_VFMAX_VV, VU_VALU0_VFSGNJ_VV, VU_VALU0_VFSGNJN_VV, VU_VALU0_VFSGNJX_VV, VU_VALU0_VMFEQ_VV, VU_VALU0_VMFNE_VV, VU_VALU0_VMFLT_VV, VU_VALU0_VMFLE_VV, VU_VALU0_VFMERGE_VVM}) {
                    {valu0_op_src1_sel, valu0_op_src2_sel, valu0_op_src3_sel, mask_op_valu0_mask_sel} dist {
                        {8'h30, 8'h31, 8'h00, 8'h00} := inst_gen_cfg.sel_pair_weight,
                        {8'h31, 8'h30, 8'h00, 8'h00} := 100 - inst_gen_cfg.sel_pair_weight
                    };
                    }
                    else if (cross_inst_1_valu0_type inside {VU_VALU0_VFADD_VF, VU_VALU0_VFSUB_VF, VU_VALU0_VFRSUB_VF, VU_VALU0_VFMUL_VF, VU_VALU0_VFMIN_VF, VU_VALU0_VFMAX_VF, VU_VALU0_VFSGNJ_VF, VU_VALU0_VFSGNJN_VF, VU_VALU0_VFSGNJX_VF, VU_VALU0_VMFEQ_VF, VU_VALU0_VMFNE_VF, VU_VALU0_VMFLT_VF, VU_VALU0_VMFLE_VF, VU_VALU0_VMFGT_VF, VU_VALU0_VMFGE_VF, VU_VALU0_VFMERGE_VFM}) {
                    {valu0_op_src1_sel, valu0_op_src2_sel, valu0_op_src3_sel, mask_op_valu0_mask_sel} dist {
                        {8'h51, 8'h30, 8'h00, 8'h40} := inst_gen_cfg.sel_pair_weight,
                        {8'h51, 8'h31, 8'h00, 8'h41} := 100 - inst_gen_cfg.sel_pair_weight
                    };
                    }
                    else if (cross_inst_1_valu0_type == VU_VALU0_VFMV_V_F) {
                        valu0_op_src1_sel == 8'h51 && valu0_op_src2_sel == 8'h00 && valu0_op_src3_sel == 8'h00 && mask_op_valu0_mask_sel == 8'h00;
                    }
                    else if (cross_inst_1_valu0_type == VU_VALU0_VFMV_S_F) {
                        valu0_op_src1_sel == 8'h51 && valu0_op_src3_sel == 8'h00 && mask_op_valu0_mask_sel == 8'h00;
                    }
                    else if (cross_inst_1_valu0_type inside {VU_VALU0_VFMACC_VF, VU_VALU0_VFNMACC_VF, VU_VALU0_VFMSAC_VF, VU_VALU0_VFNMSAC_VF}) {
                    {valu0_op_src1_sel, valu0_op_src2_sel, valu0_op_src3_sel, mask_op_valu0_mask_sel} dist {
                        {8'h51, 8'h30, 8'h31, 8'h00} := inst_gen_cfg.sel_pair_weight,
                        {8'h51, 8'h31, 8'h30, 8'h00} := 100 - inst_gen_cfg.sel_pair_weight
                    };
                    }
                    else if (cross_inst_1_valu0_type == VU_VALU0_VFCLASS_MV) {
                    {valu0_op_src1_sel, mask_op_valu0_mask_sel} dist {
                        {8'h30, 8'h40} := inst_gen_cfg.sel_pair_weight,
                        {8'h31, 8'h41} := 100 - inst_gen_cfg.sel_pair_weight
                    };
                    }
                    else {
                        valu0_op_src1_sel == 8'h00;
                        valu0_op_src2_sel == 8'h00;
                        valu0_op_src3_sel == 8'h00;
                        mask_op_valu0_mask_sel == 8'h00;
                    }
            }
            else {
                valu0_op_src1_sel == 8'h00;
                valu0_op_src2_sel == 8'h00;
                valu0_op_src3_sel == 8'h00;
                mask_op_valu0_mask_sel == 8'h00;
            }
        }
    }

    constraint valu1_src_mask_sel_c {
        if (!inst_gen_cfg.fix_valu1_op_src1_sel_en &&
            !inst_gen_cfg.fix_valu1_op_src2_sel_en &&
            !inst_gen_cfg.fix_valu1_op_src3_sel_en &&
            !inst_gen_cfg.fix_mask_op_valu1_mask_sel_en) {
            if (cross_inst_1_op == VU_VALU1) {
                    if (cross_inst_1_valu1_type inside {VU_VALU1_VFADD_VV, VU_VALU1_VFSUB_VV, VU_VALU1_VFMUL_VV, VU_VALU1_VFMIN_VV, VU_VALU1_VFMAX_VV}) {
                    {valu1_op_src1_sel, valu1_op_src2_sel, valu1_op_src3_sel, mask_op_valu1_mask_sel} dist {
                        {8'h30, 8'h31, 8'h00, 8'h00} := inst_gen_cfg.sel_pair_weight,
                        {8'h31, 8'h30, 8'h00, 8'h00} := 100 - inst_gen_cfg.sel_pair_weight
                    };
                    }
                    else if (cross_inst_1_valu1_type inside {VU_VALU1_VFADD_VF, VU_VALU1_VFSUB_VF, VU_VALU1_VFRSUB_VF, VU_VALU1_VFMUL_VF, VU_VALU1_VFMIN_VF, VU_VALU1_VFMAX_VF, VU_VALU1_VFREDUSUM_VS, VU_VALU1_VFREDMAX_VS, VU_VALU1_VFREDMIN_VS}) {
                    {valu1_op_src1_sel, valu1_op_src2_sel, valu1_op_src3_sel, mask_op_valu1_mask_sel} dist {
                        {8'h52, 8'h30, 8'h00, 8'h40} := inst_gen_cfg.sel_pair_weight,
                        {8'h52, 8'h31, 8'h00, 8'h41} := 100 - inst_gen_cfg.sel_pair_weight
                    };
                    }
                    else if (cross_inst_1_valu1_type == VU_VALU1_VFMV_V_F) {
                        valu1_op_src1_sel == 8'h52 && valu1_op_src2_sel == 8'h00 && valu1_op_src3_sel == 8'h00 && mask_op_valu1_mask_sel == 8'h00;
                    }
                    else if (cross_inst_1_valu1_type == VU_VALU1_VFMV_F_S) {
                    {valu1_op_src1_sel, valu1_op_src3_sel, mask_op_valu1_mask_sel} dist {
                        {8'h30, 8'h00, 8'h00} := inst_gen_cfg.sel_pair_weight,
                        {8'h31, 8'h00, 8'h00} := 100 - inst_gen_cfg.sel_pair_weight
                    };
                    }
                    else if (cross_inst_1_valu1_type inside {VU_VALU1_VSORTMAX16_V, VU_VALU1_VSORTMIN16_V}) {
                    {valu1_op_src1_sel, valu1_op_src2_sel, valu1_op_src3_sel, mask_op_valu1_mask_sel} dist {
                        {8'h30, 8'h00, 8'h00, 8'h40} := inst_gen_cfg.sel_pair_weight,
                        {8'h31, 8'h00, 8'h00, 8'h41} := 100 - inst_gen_cfg.sel_pair_weight
                    };
                    }
                    else {
                        valu1_op_src1_sel == 8'h00;
                        valu1_op_src2_sel == 8'h00;
                        valu1_op_src3_sel == 8'h00;
                        mask_op_valu1_mask_sel == 8'h00;
                    }
            }
            else {
                valu1_op_src1_sel == 8'h00;
                valu1_op_src2_sel == 8'h00;
                valu1_op_src3_sel == 8'h00;
                mask_op_valu1_mask_sel == 8'h00;
            }
        }
    }

    constraint valu2_src_mask_sel_c {
        if (!inst_gen_cfg.fix_valu2_op_src1_sel_en &&
            !inst_gen_cfg.fix_valu2_op_src2_sel_en &&
            !inst_gen_cfg.fix_valu2_op_src3_sel_en &&
            !inst_gen_cfg.fix_mask_op_valu2_mask_sel_en) {
            if (cross_inst_1_op == VU_VALU2) {
                    if (cross_inst_1_valu2_type inside {VU_VALU2_VFADD_VV, VU_VALU2_VFSUB_VV, VU_VALU2_VFMUL_VV, VU_VALU2_VFMIN_VV, VU_VALU2_VFMAX_VV}) {
                    {valu2_op_src1_sel, valu2_op_src2_sel, valu2_op_src3_sel, mask_op_valu2_mask_sel} dist {
                        {8'h30, 8'h31, 8'h00, 8'h00} := inst_gen_cfg.sel_pair_weight,
                        {8'h31, 8'h30, 8'h00, 8'h00} := 100 - inst_gen_cfg.sel_pair_weight
                    };
                    }
                    else if (cross_inst_1_valu2_type inside {VU_VALU2_VFADD_VF, VU_VALU2_VFSUB_VF, VU_VALU2_VFRSUB_VF, VU_VALU2_VFMUL_VF, VU_VALU2_VFMIN_VF, VU_VALU2_VFMAX_VF}) {
                    {valu2_op_src1_sel, valu2_op_src2_sel, valu2_op_src3_sel, mask_op_valu2_mask_sel} dist {
                        {8'h53, 8'h30, 8'h00, 8'h40} := inst_gen_cfg.sel_pair_weight,
                        {8'h53, 8'h31, 8'h00, 8'h41} := 100 - inst_gen_cfg.sel_pair_weight
                    };
                    }
                    else if (cross_inst_1_valu2_type == VU_VALU2_VFMV_V_F) {
                        valu2_op_src1_sel == 8'h53 && valu2_op_src2_sel == 8'h00 && valu2_op_src3_sel == 8'h00 && mask_op_valu2_mask_sel == 8'h00;
                    }
                    else if (cross_inst_1_valu2_type inside {VU_VALU2_VMV_V_V, VU_VALU2_VSWAP2_V}) {
                    {valu2_op_src1_sel, valu2_op_src2_sel, valu2_op_src3_sel, mask_op_valu2_mask_sel} dist {
                        {8'h30, 8'h00, 8'h00, 8'h00} := inst_gen_cfg.sel_pair_weight,
                        {8'h31, 8'h00, 8'h00, 8'h00} := 100 - inst_gen_cfg.sel_pair_weight
                    };
                    }
                    else if (cross_inst_1_valu2_type inside {VU_VALU2_VFSLIDE1UP_VF, VU_VALU2_VFSLIDE1DOWN_VF}) {
                    {valu2_op_src1_sel, valu2_op_src2_sel, valu2_op_src3_sel, mask_op_valu2_mask_sel} dist {
                        {8'h53, 8'h30, 8'h00, 8'h00} := inst_gen_cfg.sel_pair_weight,
                        {8'h53, 8'h31, 8'h00, 8'h00} := 100 - inst_gen_cfg.sel_pair_weight
                    };
                    }
                    else {
                        valu2_op_src1_sel == 8'h00;
                        valu2_op_src2_sel == 8'h00;
                        valu2_op_src3_sel == 8'h00;
                        mask_op_valu2_mask_sel == 8'h00;
                    }
            }
            else {
                valu2_op_src1_sel == 8'h00;
                valu2_op_src2_sel == 8'h00;
                valu2_op_src3_sel == 8'h00;
                mask_op_valu2_mask_sel == 8'h00;
            }
        }
    }

    constraint vsfu0_src_sel_c {
        if (!inst_gen_cfg.fix_vsfu_op_vsfu0_src1_sel_en) {
            if (cross_inst_1_op == VU_VSFU0) {
                    if (cross_inst_1_vsfu0_type inside {VU_VSFU_VFSIN_V, VU_VSFU_VFCOS_V, VU_VSFU_VFTANH_V, VU_VSFU_VFSIGMOID_V, VU_VSFU_VFEXP_V, VU_VSFU_VFEXP2_V, VU_VSFU_VFLN_V, VU_VSFU_VFLOG2_V, VU_VSFU_VFSQRT_V, VU_VSFU_VFRCP_V, VU_VSFU_VFRSQRT_V, VU_VSFU_CUSTOM_FIT}) {
                        vsfu_op_vsfu0_src1_sel inside {[8'h30:8'h31]};
                    }
                    else {
                                                vsfu_op_vsfu0_src1_sel == 8'h00;
                    }
            }
            else {
                vsfu_op_vsfu0_src1_sel == 8'h00;
            }
        }
    }

    constraint vsfu1_src_sel_c {
        if (!inst_gen_cfg.fix_vsfu_op_vsfu1_src1_sel_en) {
            if (cross_inst_1_op == VU_VSFU1) {
                    if (cross_inst_1_vsfu1_type inside {VU_VSFU_VFSIN_V, VU_VSFU_VFCOS_V, VU_VSFU_VFTANH_V, VU_VSFU_VFSIGMOID_V, VU_VSFU_VFEXP_V, VU_VSFU_VFEXP2_V, VU_VSFU_VFLN_V, VU_VSFU_VFLOG2_V, VU_VSFU_VFSQRT_V, VU_VSFU_VFRCP_V, VU_VSFU_VFRSQRT_V, VU_VSFU_CUSTOM_FIT}) {
                        vsfu_op_vsfu1_src1_sel inside {[8'h30:8'h31]};
                    }
                    else {
                                                vsfu_op_vsfu1_src1_sel == 8'h00;
                    }
            }
            else {
                vsfu_op_vsfu1_src1_sel == 8'h00;
            }
        }
    }

    constraint mexe_src_sel_c {
        if (!inst_gen_cfg.fix_mexe_op_src1_sel_en &&
            !inst_gen_cfg.fix_mexe_op_src2_sel_en) {
            if (cross_inst_1_op == VU_MEXE) {
                    if (cross_inst_1_mexe_type inside {VU_MEXE_VMAND_MM, VU_MEXE_VMNAND_MM, VU_MEXE_VMANDN_MM, VU_MEXE_VMXOR_MM, VU_MEXE_VMOR_MM, VU_MEXE_VMNOR_MM, VU_MEXE_VMORN_MM, VU_MEXE_VMXNOR_MM}) {
                    {mexe_op_src1_sel, mexe_op_src2_sel} dist {
                        {8'h40, 8'h41} := inst_gen_cfg.sel_pair_weight,
                        {8'h41, 8'h40} := 100 - inst_gen_cfg.sel_pair_weight
                    };
                    }
                    else if (cross_inst_1_mexe_type inside {VU_MEXE_VCPOP_M, VU_MEXE_VFIRST_M, VU_MEXE_VMSBF_M, VU_MEXE_VMSIF_M, VU_MEXE_VMSOF_M}) {
                    {mexe_op_src1_sel, mexe_op_src2_sel} dist {
                        {8'h40, 8'h00} := inst_gen_cfg.sel_pair_weight,
                        {8'h41, 8'h00} := 100 - inst_gen_cfg.sel_pair_weight
                    };
                    }
                    else if (cross_inst_1_mexe_type inside {VU_MEXE_VMIUSET_MV, VU_MEXE_VMISET_MV}) {
                    {mexe_op_src1_sel, mexe_op_src2_sel} dist {
                        {8'h40, 8'h30} := inst_gen_cfg.sel_pair_weight,
                        {8'h41, 8'h31} := 100 - inst_gen_cfg.sel_pair_weight
                    };
                    }
                    else {
                        mexe_op_src1_sel == 8'h00;
                        mexe_op_src2_sel == 8'h00;
                    }
            }
            else {
                mexe_op_src1_sel == 8'h00;
                mexe_op_src2_sel == 8'h00;
            }
        }
    }

    constraint sexe_src_sel_c {
        if (!inst_gen_cfg.fix_sexe0_op_src1_sel_en &&
            !inst_gen_cfg.fix_sexe0_op_src2_sel_en) {
            if (cross_inst_1_op == VU_SEXE) {
                    if (cross_inst_1_sexe_type inside {VU_SEXE_FADD_S, VU_SEXE_FSUB_S, VU_SEXE_FMUL_S, VU_SEXE_FDIV_S}) {
                        sexe0_op_src1_sel == 8'h54 && sexe0_op_src2_sel == 8'h55;
                    }
                    else if (cross_inst_1_sexe_type inside {VU_SEXE_FSQRT_S, VU_SEXE_FRSQRT_S, VU_SEXE_FRCP_S}) {
                        sexe0_op_src1_sel == 8'h54 && sexe0_op_src2_sel == 8'h00;
                    }
                    else {
                        sexe0_op_src1_sel == 8'h00;
                        sexe0_op_src2_sel == 8'h00;
                    }
            }
            else {
                sexe0_op_src1_sel == 8'h00;
                sexe0_op_src2_sel == 8'h00;
            }
        }
    }

endclass : cross_1_gen_seq_item

class cross_2_gen_seq_item extends vu_mac_inst_seq_item;
    //----- cross_inst_2 激励生成控制字段（src_reg） -----
    rand cross_inst_2_type_e      cross_inst_2_type;

    `uvm_object_utils_begin(cross_2_gen_seq_item)
        `uvm_field_enum         (cross_inst_2_type_e,        cross_inst_2_type,       UVM_DEFAULT)
    `uvm_object_utils_end

    function new (string name = "cross_2_gen_seq_item");
        super.new(name);
    endfunction : new

    constraint cross_inst_2_type_c {
        if (inst_gen_cfg.cross_2_cfg.fix_cross_inst_2_type_en) {
            cross_inst_2_type == inst_gen_cfg.cross_2_cfg.cross_inst_2_type;
        } else {
            cross_inst_2_type dist {
                VU_CROSS_INST_2_NOP      := inst_gen_cfg.cross_2_cfg.cross_inst_2_type_dist[VU_CROSS_INST_2_NOP]
            };
        }
    }

endclass : cross_2_gen_seq_item

class cross_2_bypass_gen_seq_item extends vu_mac_inst_seq_item;
    //----- cross_inst_2 激励生成控制字段（src_bypass） -----
    // TODO: 位域约束来源 cross_Ninst_all.xlsx cross_bypass（当前仅类型随机模板）
    rand cross_inst_2_type_e      cross_inst_2_type;

    `uvm_object_utils_begin(cross_2_bypass_gen_seq_item)
        `uvm_field_enum         (cross_inst_2_type_e,        cross_inst_2_type,       UVM_DEFAULT)
    `uvm_object_utils_end

    function new (string name = "cross_2_bypass_gen_seq_item");
        super.new(name);
    endfunction : new

    constraint cross_inst_2_type_c {
        if (inst_gen_cfg.cross_2_cfg.fix_cross_inst_2_type_en) {
            cross_inst_2_type == inst_gen_cfg.cross_2_cfg.cross_inst_2_type;
        } else {
            cross_inst_2_type dist {
                VU_CROSS_INST_2_NOP      := inst_gen_cfg.cross_2_cfg.cross_inst_2_type_dist[VU_CROSS_INST_2_NOP]
            };
        }
    }

endclass : cross_2_bypass_gen_seq_item

class cross_3_gen_seq_item extends vu_mac_inst_seq_item;
    //----- cross_inst_3 激励生成控制字段（src_reg） -----
    rand cross_inst_3_type_e      cross_inst_3_type;

    `uvm_object_utils_begin(cross_3_gen_seq_item)
        `uvm_field_enum         (cross_inst_3_type_e,        cross_inst_3_type,       UVM_DEFAULT)
    `uvm_object_utils_end

    function new (string name = "cross_3_gen_seq_item");
        super.new(name);
    endfunction : new

    constraint cross_inst_3_type_c {
        if (inst_gen_cfg.cross_3_cfg.fix_cross_inst_3_type_en) {
            cross_inst_3_type == inst_gen_cfg.cross_3_cfg.cross_inst_3_type;
        } else {
            cross_inst_3_type dist {
                VU_CROSS_INST_3_NOP      := inst_gen_cfg.cross_3_cfg.cross_inst_3_type_dist[VU_CROSS_INST_3_NOP]
            };
        }
    }

endclass : cross_3_gen_seq_item

class cross_3_bypass_gen_seq_item extends vu_mac_inst_seq_item;
    //----- cross_inst_3 激励生成控制字段（src_bypass） -----
    // TODO: 位域约束来源 cross_Ninst_all.xlsx cross_bypass（当前仅类型随机模板）
    rand cross_inst_3_type_e      cross_inst_3_type;

    `uvm_object_utils_begin(cross_3_bypass_gen_seq_item)
        `uvm_field_enum         (cross_inst_3_type_e,        cross_inst_3_type,       UVM_DEFAULT)
    `uvm_object_utils_end

    function new (string name = "cross_3_bypass_gen_seq_item");
        super.new(name);
    endfunction : new

    constraint cross_inst_3_type_c {
        if (inst_gen_cfg.cross_3_cfg.fix_cross_inst_3_type_en) {
            cross_inst_3_type == inst_gen_cfg.cross_3_cfg.cross_inst_3_type;
        } else {
            cross_inst_3_type dist {
                VU_CROSS_INST_3_NOP      := inst_gen_cfg.cross_3_cfg.cross_inst_3_type_dist[VU_CROSS_INST_3_NOP]
            };
        }
    }

endclass : cross_3_bypass_gen_seq_item

class cross_4_gen_seq_item extends vu_mac_inst_seq_item;
    //----- cross_inst_4 激励生成控制字段（src_reg） -----
    rand cross_inst_4_type_e      cross_inst_4_type;

    `uvm_object_utils_begin(cross_4_gen_seq_item)
        `uvm_field_enum         (cross_inst_4_type_e,        cross_inst_4_type,       UVM_DEFAULT)
    `uvm_object_utils_end

    function new (string name = "cross_4_gen_seq_item");
        super.new(name);
    endfunction : new

    constraint cross_inst_4_type_c {
        if (inst_gen_cfg.cross_4_cfg.fix_cross_inst_4_type_en) {
            cross_inst_4_type == inst_gen_cfg.cross_4_cfg.cross_inst_4_type;
        } else {
            cross_inst_4_type dist {
                VU_CROSS_INST_4_NOP      := inst_gen_cfg.cross_4_cfg.cross_inst_4_type_dist[VU_CROSS_INST_4_NOP]
            };
        }
    }

endclass : cross_4_gen_seq_item

class cross_4_bypass_gen_seq_item extends vu_mac_inst_seq_item;
    //----- cross_inst_4 激励生成控制字段（src_bypass） -----
    // TODO: 位域约束来源 cross_Ninst_all.xlsx cross_bypass（当前仅类型随机模板）
    rand cross_inst_4_type_e      cross_inst_4_type;

    `uvm_object_utils_begin(cross_4_bypass_gen_seq_item)
        `uvm_field_enum         (cross_inst_4_type_e,        cross_inst_4_type,       UVM_DEFAULT)
    `uvm_object_utils_end

    function new (string name = "cross_4_bypass_gen_seq_item");
        super.new(name);
    endfunction : new

    constraint cross_inst_4_type_c {
        if (inst_gen_cfg.cross_4_cfg.fix_cross_inst_4_type_en) {
            cross_inst_4_type == inst_gen_cfg.cross_4_cfg.cross_inst_4_type;
        } else {
            cross_inst_4_type dist {
                VU_CROSS_INST_4_NOP      := inst_gen_cfg.cross_4_cfg.cross_inst_4_type_dist[VU_CROSS_INST_4_NOP]
            };
        }
    }

endclass : cross_4_bypass_gen_seq_item

class cross_5_gen_seq_item extends vu_mac_inst_seq_item;
    //----- cross_inst_5 激励生成控制字段（src_reg） -----
    rand cross_inst_5_type_e      cross_inst_5_type;

    `uvm_object_utils_begin(cross_5_gen_seq_item)
        `uvm_field_enum         (cross_inst_5_type_e,        cross_inst_5_type,       UVM_DEFAULT)
    `uvm_object_utils_end

    function new (string name = "cross_5_gen_seq_item");
        super.new(name);
    endfunction : new

    constraint cross_inst_5_type_c {
        if (inst_gen_cfg.cross_5_cfg.fix_cross_inst_5_type_en) {
            cross_inst_5_type == inst_gen_cfg.cross_5_cfg.cross_inst_5_type;
        } else {
            cross_inst_5_type dist {
                VU_CROSS_INST_5_NOP      := inst_gen_cfg.cross_5_cfg.cross_inst_5_type_dist[VU_CROSS_INST_5_NOP]
            };
        }
    }

endclass : cross_5_gen_seq_item

class cross_5_bypass_gen_seq_item extends vu_mac_inst_seq_item;
    //----- cross_inst_5 激励生成控制字段（src_bypass） -----
    // TODO: 位域约束来源 cross_Ninst_all.xlsx cross_bypass（当前仅类型随机模板）
    rand cross_inst_5_type_e      cross_inst_5_type;

    `uvm_object_utils_begin(cross_5_bypass_gen_seq_item)
        `uvm_field_enum         (cross_inst_5_type_e,        cross_inst_5_type,       UVM_DEFAULT)
    `uvm_object_utils_end

    function new (string name = "cross_5_bypass_gen_seq_item");
        super.new(name);
    endfunction : new

    constraint cross_inst_5_type_c {
        if (inst_gen_cfg.cross_5_cfg.fix_cross_inst_5_type_en) {
            cross_inst_5_type == inst_gen_cfg.cross_5_cfg.cross_inst_5_type;
        } else {
            cross_inst_5_type dist {
                VU_CROSS_INST_5_NOP      := inst_gen_cfg.cross_5_cfg.cross_inst_5_type_dist[VU_CROSS_INST_5_NOP]
            };
        }
    }

endclass : cross_5_bypass_gen_seq_item

class cross_6_gen_seq_item extends vu_mac_inst_seq_item;
    //----- cross_inst_6 激励生成控制字段（src_reg） -----
    rand cross_inst_6_type_e      cross_inst_6_type;

    `uvm_object_utils_begin(cross_6_gen_seq_item)
        `uvm_field_enum         (cross_inst_6_type_e,        cross_inst_6_type,       UVM_DEFAULT)
    `uvm_object_utils_end

    function new (string name = "cross_6_gen_seq_item");
        super.new(name);
    endfunction : new

    constraint cross_inst_6_type_c {
        if (inst_gen_cfg.cross_6_cfg.fix_cross_inst_6_type_en) {
            cross_inst_6_type == inst_gen_cfg.cross_6_cfg.cross_inst_6_type;
        } else {
            cross_inst_6_type dist {
                VU_CROSS_INST_6_NOP      := inst_gen_cfg.cross_6_cfg.cross_inst_6_type_dist[VU_CROSS_INST_6_NOP]
            };
        }
    }

endclass : cross_6_gen_seq_item

class cross_6_bypass_gen_seq_item extends vu_mac_inst_seq_item;
    //----- cross_inst_6 激励生成控制字段（src_bypass） -----
    // TODO: 位域约束来源 cross_Ninst_all.xlsx cross_bypass（当前仅类型随机模板）
    rand cross_inst_6_type_e      cross_inst_6_type;

    `uvm_object_utils_begin(cross_6_bypass_gen_seq_item)
        `uvm_field_enum         (cross_inst_6_type_e,        cross_inst_6_type,       UVM_DEFAULT)
    `uvm_object_utils_end

    function new (string name = "cross_6_bypass_gen_seq_item");
        super.new(name);
    endfunction : new

    constraint cross_inst_6_type_c {
        if (inst_gen_cfg.cross_6_cfg.fix_cross_inst_6_type_en) {
            cross_inst_6_type == inst_gen_cfg.cross_6_cfg.cross_inst_6_type;
        } else {
            cross_inst_6_type dist {
                VU_CROSS_INST_6_NOP      := inst_gen_cfg.cross_6_cfg.cross_inst_6_type_dist[VU_CROSS_INST_6_NOP]
            };
        }
    }

endclass : cross_6_bypass_gen_seq_item

class cross_7_gen_seq_item extends vu_mac_inst_seq_item;
    //----- cross_inst_7 激励生成控制字段（src_reg） -----
    rand cross_inst_7_type_e      cross_inst_7_type;

    `uvm_object_utils_begin(cross_7_gen_seq_item)
        `uvm_field_enum         (cross_inst_7_type_e,        cross_inst_7_type,       UVM_DEFAULT)
    `uvm_object_utils_end

    function new (string name = "cross_7_gen_seq_item");
        super.new(name);
    endfunction : new

    constraint cross_inst_7_type_c {
        if (inst_gen_cfg.cross_7_cfg.fix_cross_inst_7_type_en) {
            cross_inst_7_type == inst_gen_cfg.cross_7_cfg.cross_inst_7_type;
        } else {
            cross_inst_7_type dist {
                VU_CROSS_INST_7_NOP      := inst_gen_cfg.cross_7_cfg.cross_inst_7_type_dist[VU_CROSS_INST_7_NOP]
            };
        }
    }

endclass : cross_7_gen_seq_item

class cross_7_bypass_gen_seq_item extends vu_mac_inst_seq_item;
    //----- cross_inst_7 激励生成控制字段（src_bypass） -----
    // TODO: 位域约束来源 cross_Ninst_all.xlsx cross_bypass（当前仅类型随机模板）
    rand cross_inst_7_type_e      cross_inst_7_type;

    `uvm_object_utils_begin(cross_7_bypass_gen_seq_item)
        `uvm_field_enum         (cross_inst_7_type_e,        cross_inst_7_type,       UVM_DEFAULT)
    `uvm_object_utils_end

    function new (string name = "cross_7_bypass_gen_seq_item");
        super.new(name);
    endfunction : new

    constraint cross_inst_7_type_c {
        if (inst_gen_cfg.cross_7_cfg.fix_cross_inst_7_type_en) {
            cross_inst_7_type == inst_gen_cfg.cross_7_cfg.cross_inst_7_type;
        } else {
            cross_inst_7_type dist {
                VU_CROSS_INST_7_NOP      := inst_gen_cfg.cross_7_cfg.cross_inst_7_type_dist[VU_CROSS_INST_7_NOP]
            };
        }
    }

endclass : cross_7_bypass_gen_seq_item

class cross_8_gen_seq_item extends vu_mac_inst_seq_item;
    //----- cross_inst_8 激励生成控制字段（src_reg） -----
    rand cross_inst_8_type_e      cross_inst_8_type;

    `uvm_object_utils_begin(cross_8_gen_seq_item)
        `uvm_field_enum         (cross_inst_8_type_e,        cross_inst_8_type,       UVM_DEFAULT)
    `uvm_object_utils_end

    function new (string name = "cross_8_gen_seq_item");
        super.new(name);
    endfunction : new

    constraint cross_inst_8_type_c {
        if (inst_gen_cfg.cross_8_cfg.fix_cross_inst_8_type_en) {
            cross_inst_8_type == inst_gen_cfg.cross_8_cfg.cross_inst_8_type;
        } else {
            cross_inst_8_type dist {
                VU_CROSS_INST_8_NOP      := inst_gen_cfg.cross_8_cfg.cross_inst_8_type_dist[VU_CROSS_INST_8_NOP]
            };
        }
    }

endclass : cross_8_gen_seq_item

class cross_8_bypass_gen_seq_item extends vu_mac_inst_seq_item;
    //----- cross_inst_8 激励生成控制字段（src_bypass） -----
    // TODO: 位域约束来源 cross_Ninst_all.xlsx cross_bypass（当前仅类型随机模板）
    rand cross_inst_8_type_e      cross_inst_8_type;

    `uvm_object_utils_begin(cross_8_bypass_gen_seq_item)
        `uvm_field_enum         (cross_inst_8_type_e,        cross_inst_8_type,       UVM_DEFAULT)
    `uvm_object_utils_end

    function new (string name = "cross_8_bypass_gen_seq_item");
        super.new(name);
    endfunction : new

    constraint cross_inst_8_type_c {
        if (inst_gen_cfg.cross_8_cfg.fix_cross_inst_8_type_en) {
            cross_inst_8_type == inst_gen_cfg.cross_8_cfg.cross_inst_8_type;
        } else {
            cross_inst_8_type dist {
                VU_CROSS_INST_8_NOP      := inst_gen_cfg.cross_8_cfg.cross_inst_8_type_dist[VU_CROSS_INST_8_NOP]
            };
        }
    }

endclass : cross_8_bypass_gen_seq_item

class cross_9_gen_seq_item extends vu_mac_inst_seq_item;
    //----- cross_inst_9 激励生成控制字段（src_reg） -----
    rand cross_inst_9_type_e      cross_inst_9_type;

    `uvm_object_utils_begin(cross_9_gen_seq_item)
        `uvm_field_enum         (cross_inst_9_type_e,        cross_inst_9_type,       UVM_DEFAULT)
    `uvm_object_utils_end

    function new (string name = "cross_9_gen_seq_item");
        super.new(name);
    endfunction : new

    constraint cross_inst_9_type_c {
        if (inst_gen_cfg.cross_9_cfg.fix_cross_inst_9_type_en) {
            cross_inst_9_type == inst_gen_cfg.cross_9_cfg.cross_inst_9_type;
        } else {
            cross_inst_9_type dist {
                VU_CROSS_INST_9_NOP      := inst_gen_cfg.cross_9_cfg.cross_inst_9_type_dist[VU_CROSS_INST_9_NOP]
            };
        }
    }

endclass : cross_9_gen_seq_item

class cross_9_bypass_gen_seq_item extends vu_mac_inst_seq_item;
    //----- cross_inst_9 激励生成控制字段（src_bypass） -----
    // TODO: 位域约束来源 cross_Ninst_all.xlsx cross_bypass（当前仅类型随机模板）
    rand cross_inst_9_type_e      cross_inst_9_type;

    `uvm_object_utils_begin(cross_9_bypass_gen_seq_item)
        `uvm_field_enum         (cross_inst_9_type_e,        cross_inst_9_type,       UVM_DEFAULT)
    `uvm_object_utils_end

    function new (string name = "cross_9_bypass_gen_seq_item");
        super.new(name);
    endfunction : new

    constraint cross_inst_9_type_c {
        if (inst_gen_cfg.cross_9_cfg.fix_cross_inst_9_type_en) {
            cross_inst_9_type == inst_gen_cfg.cross_9_cfg.cross_inst_9_type;
        } else {
            cross_inst_9_type dist {
                VU_CROSS_INST_9_NOP      := inst_gen_cfg.cross_9_cfg.cross_inst_9_type_dist[VU_CROSS_INST_9_NOP]
            };
        }
    }

endclass : cross_9_bypass_gen_seq_item

class cross_10_gen_seq_item extends vu_mac_inst_seq_item;
    //----- cross_inst_10 激励生成控制字段（src_reg） -----
    rand cross_inst_10_type_e     cross_inst_10_type;

    `uvm_object_utils_begin(cross_10_gen_seq_item)
        `uvm_field_enum         (cross_inst_10_type_e,        cross_inst_10_type,       UVM_DEFAULT)
    `uvm_object_utils_end

    function new (string name = "cross_10_gen_seq_item");
        super.new(name);
    endfunction : new

    constraint cross_inst_10_type_c {
        if (inst_gen_cfg.cross_10_cfg.fix_cross_inst_10_type_en) {
            cross_inst_10_type == inst_gen_cfg.cross_10_cfg.cross_inst_10_type;
        } else {
            cross_inst_10_type dist {
                VU_CROSS_INST_10_NOP     := inst_gen_cfg.cross_10_cfg.cross_inst_10_type_dist[VU_CROSS_INST_10_NOP]
            };
        }
    }

endclass : cross_10_gen_seq_item

class cross_10_bypass_gen_seq_item extends vu_mac_inst_seq_item;
    //----- cross_inst_10 激励生成控制字段（src_bypass） -----
    // TODO: 位域约束来源 cross_Ninst_all.xlsx cross_bypass（当前仅类型随机模板）
    rand cross_inst_10_type_e     cross_inst_10_type;

    `uvm_object_utils_begin(cross_10_bypass_gen_seq_item)
        `uvm_field_enum         (cross_inst_10_type_e,        cross_inst_10_type,       UVM_DEFAULT)
    `uvm_object_utils_end

    function new (string name = "cross_10_bypass_gen_seq_item");
        super.new(name);
    endfunction : new

    constraint cross_inst_10_type_c {
        if (inst_gen_cfg.cross_10_cfg.fix_cross_inst_10_type_en) {
            cross_inst_10_type == inst_gen_cfg.cross_10_cfg.cross_inst_10_type;
        } else {
            cross_inst_10_type dist {
                VU_CROSS_INST_10_NOP     := inst_gen_cfg.cross_10_cfg.cross_inst_10_type_dist[VU_CROSS_INST_10_NOP]
            };
        }
    }

endclass : cross_10_bypass_gen_seq_item

class cross_11_gen_seq_item extends vu_mac_inst_seq_item;
    //----- cross_inst_11 激励生成控制字段（src_reg） -----
    rand cross_inst_11_type_e     cross_inst_11_type;

    `uvm_object_utils_begin(cross_11_gen_seq_item)
        `uvm_field_enum         (cross_inst_11_type_e,        cross_inst_11_type,       UVM_DEFAULT)
    `uvm_object_utils_end

    function new (string name = "cross_11_gen_seq_item");
        super.new(name);
    endfunction : new

    constraint cross_inst_11_type_c {
        if (inst_gen_cfg.cross_11_cfg.fix_cross_inst_11_type_en) {
            cross_inst_11_type == inst_gen_cfg.cross_11_cfg.cross_inst_11_type;
        } else {
            cross_inst_11_type dist {
                VU_CROSS_INST_11_NOP     := inst_gen_cfg.cross_11_cfg.cross_inst_11_type_dist[VU_CROSS_INST_11_NOP]
            };
        }
    }

endclass : cross_11_gen_seq_item

class cross_11_bypass_gen_seq_item extends vu_mac_inst_seq_item;
    //----- cross_inst_11 激励生成控制字段（src_bypass） -----
    // TODO: 位域约束来源 cross_Ninst_all.xlsx cross_bypass（当前仅类型随机模板）
    rand cross_inst_11_type_e     cross_inst_11_type;

    `uvm_object_utils_begin(cross_11_bypass_gen_seq_item)
        `uvm_field_enum         (cross_inst_11_type_e,        cross_inst_11_type,       UVM_DEFAULT)
    `uvm_object_utils_end

    function new (string name = "cross_11_bypass_gen_seq_item");
        super.new(name);
    endfunction : new

    constraint cross_inst_11_type_c {
        if (inst_gen_cfg.cross_11_cfg.fix_cross_inst_11_type_en) {
            cross_inst_11_type == inst_gen_cfg.cross_11_cfg.cross_inst_11_type;
        } else {
            cross_inst_11_type dist {
                VU_CROSS_INST_11_NOP     := inst_gen_cfg.cross_11_cfg.cross_inst_11_type_dist[VU_CROSS_INST_11_NOP]
            };
        }
    }

endclass : cross_11_bypass_gen_seq_item
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
