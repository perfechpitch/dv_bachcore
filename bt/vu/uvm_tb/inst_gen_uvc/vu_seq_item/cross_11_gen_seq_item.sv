// ============================================================================
// Filename             : cross_11_gen_seq_item.sv
// Author               : kippy
// Created On           : 2026-6-24 15:46
// Last Modified        :
// Update Count         :
// Description          : cross_11_bypass_gen_seq_item
// Source               : framework (auto-generated)
// Generator            : gen_inst_gen.py
// DO NOT EDIT          : re-run the generator after register-table updates.
// ============================================================================
`ifndef CROSS_11_GEN_SEQ_ITEM_SV
`define CROSS_11_GEN_SEQ_ITEM_SV
class cross_11_bypass_gen_seq_item extends cross_src_bypass_seq_item;
    //----- cross_11 激励生成控制字段（src_bypass） -----
    rand cross_11_bypass_type_e   cross_11_bypass_type;

    `uvm_object_utils_begin(cross_11_bypass_gen_seq_item)
        `uvm_field_enum         (cross_11_bypass_type_e,        cross_11_bypass_type,       UVM_DEFAULT)
    `uvm_object_utils_end

    function new (string name = "cross_11_bypass_gen_seq_item");
        super.new(name);
    endfunction : new

    //----- active_exe（cross场景汇总 执行单元组合 / cross_11_bypass_type_dist） -----
    constraint active_exe_c {
        // 来源：vu_cross_1_11inst_summary.xlsx cross场景汇总 打勾执行单元组合（src_bypass）
        active_exe dist {
                ((VU_UNIT_END'(1) << VU_LU) | (VU_UNIT_END'(1) << VU_SU) | (VU_UNIT_END'(1) << VU_VALU0) | (VU_UNIT_END'(1) << VU_VALU1) | (VU_UNIT_END'(1) << VU_VALU2) | (VU_UNIT_END'(1) << VU_VSFU0) | (VU_UNIT_END'(1) << VU_VSFU1) | (VU_UNIT_END'(1) << VU_MEXE) | (VU_UNIT_END'(1) << VU_SEXE0) | (VU_UNIT_END'(1) << VU_SEXE1) | (VU_UNIT_END'(1) << VU_SEXE2)) := inst_gen_cfg.cross_11_cfg.cross_11_bypass_type_dist[VU_CROSS_11_BYPASS_LU_SU_VALU0_VALU1_VALU2_VSFU0_VSFU1_MEXE_SEXE0_SEXE1_SEXE2]
        };
    }

    //----- LU/VALU0/VALU1/MEXE class（不在 vu_drv） -----
    constraint lu_class_c {
        if (!active_exe[VU_LU]) {
            lu_class == VU_LU_CLASS_END;
        } else {
            lu_class dist {
                VU_LU_1_VD_ADDR          := inst_gen_cfg.lu_class_dist[VU_LU_1_VD_ADDR],
                VU_LU_2_MD_ADDR          := inst_gen_cfg.lu_class_dist[VU_LU_2_MD_ADDR],
                VU_LU_3_FD_ADDR          := inst_gen_cfg.lu_class_dist[VU_LU_3_FD_ADDR]
            };
        }
    }

    constraint valu0_class_c {
        if (!active_exe[VU_VALU0]) {
            valu0_class == VU_VALU0_CLASS_END;
        } else {
            valu0_class dist {
                VU_VALU0_1_VD_VS2_VS1_VM := inst_gen_cfg.valu0_class_dist[VU_VALU0_1_VD_VS2_VS1_VM],
                VU_VALU0_2_VD_VS2_FS1_VM := inst_gen_cfg.valu0_class_dist[VU_VALU0_2_VD_VS2_FS1_VM],
                VU_VALU0_3_VD_FS1        := inst_gen_cfg.valu0_class_dist[VU_VALU0_3_VD_FS1],
                VU_VALU0_4_VD_FS1_IMM    := inst_gen_cfg.valu0_class_dist[VU_VALU0_4_VD_FS1_IMM],
                VU_VALU0_5_VD_VS3_VS1_VS2_VM := inst_gen_cfg.valu0_class_dist[VU_VALU0_5_VD_VS3_VS1_VS2_VM],
                VU_VALU0_6_VD_VS3_FS1_VS2_VM := inst_gen_cfg.valu0_class_dist[VU_VALU0_6_VD_VS3_FS1_VS2_VM],
                VU_VALU0_7_MD_VS2_VS1_VM := inst_gen_cfg.valu0_class_dist[VU_VALU0_7_MD_VS2_VS1_VM],
                VU_VALU0_8_MD_VS2_FS1_VM := inst_gen_cfg.valu0_class_dist[VU_VALU0_8_MD_VS2_FS1_VM],
                VU_VALU0_9_MD_VS1_VM_IMM := inst_gen_cfg.valu0_class_dist[VU_VALU0_9_MD_VS1_VM_IMM]
            };
        }
    }

    constraint valu1_class_c {
        if (!active_exe[VU_VALU1]) {
            valu1_class == VU_VALU1_CLASS_END;
        } else {
            valu1_class dist {
                VU_VALU1_1_VD_VS2_VS1_VM := inst_gen_cfg.valu1_class_dist[VU_VALU1_1_VD_VS2_VS1_VM],
                VU_VALU1_2_VD_VS2_FS1_VM := inst_gen_cfg.valu1_class_dist[VU_VALU1_2_VD_VS2_FS1_VM],
                VU_VALU1_3_VD_FS1        := inst_gen_cfg.valu1_class_dist[VU_VALU1_3_VD_FS1],
                VU_VALU1_4_FD_VS1_IMM    := inst_gen_cfg.valu1_class_dist[VU_VALU1_4_FD_VS1_IMM],
                VU_VALU1_5_FD_VS2_FS1_VM := inst_gen_cfg.valu1_class_dist[VU_VALU1_5_FD_VS2_FS1_VM],
                VU_VALU1_6_VD_VS1_VM     := inst_gen_cfg.valu1_class_dist[VU_VALU1_6_VD_VS1_VM]
            };
        }
    }

    constraint mexe_class_c {
        if (!active_exe[VU_MEXE]) {
            mexe_class == VU_MEXE_CLASS_END;
        } else {
            mexe_class dist {
                VU_MEXE_1_MD_MS2_MS1     := inst_gen_cfg.mexe_class_dist[VU_MEXE_1_MD_MS2_MS1],
                VU_MEXE_2_FD_MS1         := inst_gen_cfg.mexe_class_dist[VU_MEXE_2_FD_MS1],
                VU_MEXE_3_MD_MS1         := inst_gen_cfg.mexe_class_dist[VU_MEXE_3_MD_MS1],
                VU_MEXE_4_MD_MS1_VS2     := inst_gen_cfg.mexe_class_dist[VU_MEXE_4_MD_MS1_VS2]
            };
        }
    }

endclass : cross_11_bypass_gen_seq_item

`endif
