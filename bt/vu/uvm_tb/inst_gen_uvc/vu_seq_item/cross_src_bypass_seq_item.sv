// ============================================================================
// Filename             : cross_src_bypass_seq_item.sv
// Author               : kippy
// Created On           : 2026-6-24 15:46
// Last Modified        :
// Update Count         :
// Description          : cross_src_bypass_seq_item
// Source               : inherits cross_src_reg_seq_item (auto-generated)
// Generator            : gen_inst_gen.py
// DO NOT EDIT          : re-run the generator after register-table updates.
// ============================================================================
`ifndef CROSS_SRC_BYPASS_SEQ_ITEM_SV
`define CROSS_SRC_BYPASS_SEQ_ITEM_SV
class cross_src_bypass_seq_item extends cross_src_reg_seq_item;
    `uvm_object_utils(cross_src_bypass_seq_item)

    function new (string name = "cross_src_bypass_seq_item");
        super.new(name);
    endfunction : new

    //----- 覆盖 src_reg：SEXE1/SEXE2 激活可双读口 -----
    constraint sexe1_class_c {
        if (!active_exe[VU_SEXE1]) {
            sexe1_class == VU_SEXE1_CLASS_END;
        } else {
            sexe1_class dist {
                VU_SEXE1_1_FD_FS1_FS2    := inst_gen_cfg.sexe1_class_dist[VU_SEXE1_1_FD_FS1_FS2],
                VU_SEXE1_2_FD_FS1        := inst_gen_cfg.sexe1_class_dist[VU_SEXE1_2_FD_FS1]
            };
        }
    }

    constraint sexe2_class_c {
        if (!active_exe[VU_SEXE2]) {
            sexe2_class == VU_SEXE2_CLASS_END;
        } else {
            sexe2_class dist {
                VU_SEXE2_1_FD_FS1_FS2    := inst_gen_cfg.sexe2_class_dist[VU_SEXE2_1_FD_FS1_FS2],
                VU_SEXE2_2_FD_FS1        := inst_gen_cfg.sexe2_class_dist[VU_SEXE2_2_FD_FS1]
            };
        }
    }

    //----- 覆盖 src_reg：双源 SRC1=本口 SRC2=前级 bypass -----
    constraint sexe1_src_sel_c {
        if (sexe1_class == VU_SEXE1_CLASS_END) {
            if (!inst_gen_cfg.nop_rand) {
                sexe1_op_src1_sel == 8'h00;
                sexe1_op_src2_sel == 8'h00;
            }
        }
        else if (sexe1_class == VU_SEXE1_1_FD_FS1_FS2) {
            sexe1_op_src1_sel == 8'h56 && sexe1_op_src2_sel inside {8'h01, 8'h20};
        }
        else if (sexe1_class == VU_SEXE1_2_FD_FS1) {
            sexe1_op_src1_sel == 8'h56 && sexe1_op_src2_sel == 8'h00;
        }
    }

    constraint sexe2_src_sel_c {
        if (sexe2_class == VU_SEXE2_CLASS_END) {
            if (!inst_gen_cfg.nop_rand) {
                sexe2_op_src1_sel == 8'h00;
                sexe2_op_src2_sel == 8'h00;
            }
        }
        else if (sexe2_class == VU_SEXE2_1_FD_FS1_FS2) {
            sexe2_op_src1_sel == 8'h57 && sexe2_op_src2_sel inside {8'h01, 8'h21};
        }
        else if (sexe2_class == VU_SEXE2_2_FD_FS1) {
            sexe2_op_src1_sel == 8'h57 && sexe2_op_src2_sel == 8'h00;
        }
    }

    //----- 覆盖 src_reg：md 多源 dist 选 wt_src，bypass 可 0x00 不写 -----
    constraint prf_op_mrf_wt_src_c {
        prf_op_mrf_wt_src dist {
            8'h01 := (lu_class == VU_LU_2_MD_ADDR) ? inst_gen_cfg.md_exe_type_dist[VU_MD_EXE_LU] : 0,
            8'h02 := (valu0_class inside {VU_VALU0_7_MD_VS2_VS1_VM, VU_VALU0_8_MD_VS2_FS1_VM, VU_VALU0_9_MD_VS1_VM_IMM}) ? inst_gen_cfg.md_exe_type_dist[VU_MD_EXE_VALU0] : 0,
            8'h10 := (mexe_class inside {VU_MEXE_1_MD_MS2_MS1, VU_MEXE_3_MD_MS1, VU_MEXE_4_MD_MS1_VS2}) ? inst_gen_cfg.md_exe_type_dist[VU_MD_EXE_MEXE] : 0,
            8'h00 := (lu_class != VU_LU_2_MD_ADDR && !(valu0_class inside {VU_VALU0_7_MD_VS2_VS1_VM, VU_VALU0_8_MD_VS2_FS1_VM, VU_VALU0_9_MD_VS1_VM_IMM}) && !(mexe_class inside {VU_MEXE_1_MD_MS2_MS1, VU_MEXE_3_MD_MS1, VU_MEXE_4_MD_MS1_VS2})) ? 100 : 1
        };
    }

    //----- 覆盖 src_reg：vd 多源 dist 选 P0/P1，bypass 可 0x00 不写 -----
    constraint prf_op_vrf_wt_src_c {
        prf_op_vrf_wt_p0_src dist {
            8'h01 := (lu_class == VU_LU_1_VD_ADDR) ? inst_gen_cfg.vd_exe_type_dist[VU_VD_EXE_LU] : 0,
            8'h02 := (valu0_class inside {VU_VALU0_1_VD_VS2_VS1_VM, VU_VALU0_2_VD_VS2_FS1_VM, VU_VALU0_3_VD_FS1, VU_VALU0_4_VD_FS1_IMM, VU_VALU0_5_VD_VS3_VS1_VS2_VM, VU_VALU0_6_VD_VS3_FS1_VS2_VM}) ? inst_gen_cfg.vd_exe_type_dist[VU_VD_EXE_VALU0] : 0,
            8'h03 := (valu1_class inside {VU_VALU1_1_VD_VS2_VS1_VM, VU_VALU1_2_VD_VS2_FS1_VM, VU_VALU1_3_VD_FS1, VU_VALU1_6_VD_VS1_VM}) ? inst_gen_cfg.vd_exe_type_dist[VU_VD_EXE_VALU1] : 0,
            8'h04 := (valu2_class inside {VU_VALU2_1_VD_VS2_VS1_VM, VU_VALU2_2_VD_VS2_FS1_VM, VU_VALU2_3_VD_FS1, VU_VALU2_4_VD_VS1, VU_VALU2_5_VD_VS2_FS1}) ? inst_gen_cfg.vd_exe_type_dist[VU_VD_EXE_VALU2] : 0,
            8'h05 := (vsfu0_class == VU_VSFU0_1_VD_VS1) ? inst_gen_cfg.vd_exe_type_dist[VU_VD_EXE_VSFU0] : 0,
            8'h06 := (vsfu1_class == VU_VSFU1_1_VD_VS1) ? inst_gen_cfg.vd_exe_type_dist[VU_VD_EXE_VSFU1] : 0,
            8'h00 := (lu_class != VU_LU_1_VD_ADDR && !(valu0_class inside {VU_VALU0_1_VD_VS2_VS1_VM, VU_VALU0_2_VD_VS2_FS1_VM, VU_VALU0_3_VD_FS1, VU_VALU0_4_VD_FS1_IMM, VU_VALU0_5_VD_VS3_VS1_VS2_VM, VU_VALU0_6_VD_VS3_FS1_VS2_VM}) && !(valu1_class inside {VU_VALU1_1_VD_VS2_VS1_VM, VU_VALU1_2_VD_VS2_FS1_VM, VU_VALU1_3_VD_FS1, VU_VALU1_6_VD_VS1_VM}) && !(valu2_class inside {VU_VALU2_1_VD_VS2_VS1_VM, VU_VALU2_2_VD_VS2_FS1_VM, VU_VALU2_3_VD_FS1, VU_VALU2_4_VD_VS1, VU_VALU2_5_VD_VS2_FS1}) && vsfu0_class != VU_VSFU0_1_VD_VS1 && vsfu1_class != VU_VSFU1_1_VD_VS1) ? 100 : 1
        };
        prf_op_vrf_wt_p1_src dist {
            8'h01 := ((lu_class == VU_LU_1_VD_ADDR) && prf_op_vrf_wt_p0_src != 8'h01) ? inst_gen_cfg.vd_exe_type_dist[VU_VD_EXE_LU] : 0,
            8'h02 := ((valu0_class inside {VU_VALU0_1_VD_VS2_VS1_VM, VU_VALU0_2_VD_VS2_FS1_VM, VU_VALU0_3_VD_FS1, VU_VALU0_4_VD_FS1_IMM, VU_VALU0_5_VD_VS3_VS1_VS2_VM, VU_VALU0_6_VD_VS3_FS1_VS2_VM}) && prf_op_vrf_wt_p0_src != 8'h02) ? inst_gen_cfg.vd_exe_type_dist[VU_VD_EXE_VALU0] : 0,
            8'h03 := ((valu1_class inside {VU_VALU1_1_VD_VS2_VS1_VM, VU_VALU1_2_VD_VS2_FS1_VM, VU_VALU1_3_VD_FS1, VU_VALU1_6_VD_VS1_VM}) && prf_op_vrf_wt_p0_src != 8'h03) ? inst_gen_cfg.vd_exe_type_dist[VU_VD_EXE_VALU1] : 0,
            8'h04 := ((valu2_class inside {VU_VALU2_1_VD_VS2_VS1_VM, VU_VALU2_2_VD_VS2_FS1_VM, VU_VALU2_3_VD_FS1, VU_VALU2_4_VD_VS1, VU_VALU2_5_VD_VS2_FS1}) && prf_op_vrf_wt_p0_src != 8'h04) ? inst_gen_cfg.vd_exe_type_dist[VU_VD_EXE_VALU2] : 0,
            8'h05 := ((vsfu0_class == VU_VSFU0_1_VD_VS1) && prf_op_vrf_wt_p0_src != 8'h05) ? inst_gen_cfg.vd_exe_type_dist[VU_VD_EXE_VSFU0] : 0,
            8'h06 := ((vsfu1_class == VU_VSFU1_1_VD_VS1) && prf_op_vrf_wt_p0_src != 8'h06) ? inst_gen_cfg.vd_exe_type_dist[VU_VD_EXE_VSFU1] : 0,
            8'h00 := ((lu_class != VU_LU_1_VD_ADDR || prf_op_vrf_wt_p0_src == 8'h01) && (!(valu0_class inside {VU_VALU0_1_VD_VS2_VS1_VM, VU_VALU0_2_VD_VS2_FS1_VM, VU_VALU0_3_VD_FS1, VU_VALU0_4_VD_FS1_IMM, VU_VALU0_5_VD_VS3_VS1_VS2_VM, VU_VALU0_6_VD_VS3_FS1_VS2_VM}) || prf_op_vrf_wt_p0_src == 8'h02) && (!(valu1_class inside {VU_VALU1_1_VD_VS2_VS1_VM, VU_VALU1_2_VD_VS2_FS1_VM, VU_VALU1_3_VD_FS1, VU_VALU1_6_VD_VS1_VM}) || prf_op_vrf_wt_p0_src == 8'h03) && (!(valu2_class inside {VU_VALU2_1_VD_VS2_VS1_VM, VU_VALU2_2_VD_VS2_FS1_VM, VU_VALU2_3_VD_FS1, VU_VALU2_4_VD_VS1, VU_VALU2_5_VD_VS2_FS1}) || prf_op_vrf_wt_p0_src == 8'h04) && (vsfu0_class != VU_VSFU0_1_VD_VS1 || prf_op_vrf_wt_p0_src == 8'h05) && (vsfu1_class != VU_VSFU1_1_VD_VS1 || prf_op_vrf_wt_p0_src == 8'h06)) ? 100 : 1
        };
    }

endclass : cross_src_bypass_seq_item

`endif
