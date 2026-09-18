// ============================================================================
// Filename             : cross_src_reg_seq_item.sv
// Author               : kippy
// Created On           : 2026-6-24 15:46
// Last Modified        :
// Update Count         :
// Description          : cross_src_reg_seq_item / cross_3_src_reg_seq_item
// Source               : vu_cross.xlsx *_op (auto-generated)
// Generator            : gen_inst_gen.py
// DO NOT EDIT          : re-run the generator after register-table updates.
// ============================================================================
`ifndef CROSS_SRC_REG_SEQ_ITEM_SV
`define CROSS_SRC_REG_SEQ_ITEM_SV
class cross_src_reg_seq_item extends vu_drv_seq_item;
    `uvm_object_utils(cross_src_reg_seq_item)

    function new (string name = "cross_src_reg_seq_item");
        super.new(name);
    endfunction : new

    //----- 求解顺序：class → wt_src / SRC_SEL；su_class → mexe src_sel → valu0~2 mask_sel；VRF P0 → P1 -----
    constraint src_reg_solve_order_c {
        solve lu_class before prf_op_mrf_wt_src;
        solve valu0_class before prf_op_mrf_wt_src;
        solve mexe_class before prf_op_mrf_wt_src;
        solve lu_class before prf_op_vrf_wt_p0_src;
        solve lu_class before prf_op_vrf_wt_p1_src;
        solve valu0_class before prf_op_vrf_wt_p0_src;
        solve valu0_class before prf_op_vrf_wt_p1_src;
        solve valu1_class before prf_op_vrf_wt_p0_src;
        solve valu1_class before prf_op_vrf_wt_p1_src;
        solve valu2_class before prf_op_vrf_wt_p0_src;
        solve valu2_class before prf_op_vrf_wt_p1_src;
        solve vsfu0_class before prf_op_vrf_wt_p0_src;
        solve vsfu0_class before prf_op_vrf_wt_p1_src;
        solve vsfu1_class before prf_op_vrf_wt_p0_src;
        solve vsfu1_class before prf_op_vrf_wt_p1_src;
        solve prf_op_vrf_wt_p0_src before prf_op_vrf_wt_p1_src;
        solve su_class before su_op_src_sel;
        solve valu0_class before valu0_op_src1_sel;
        solve valu0_class before valu0_op_src2_sel;
        solve valu0_class before valu0_op_src3_sel;
        solve valu0_class before mask_op_valu0_mask_sel;
        solve valu1_class before valu1_op_src1_sel;
        solve valu1_class before valu1_op_src2_sel;
        solve valu1_class before valu1_op_src3_sel;
        solve valu1_class before mask_op_valu1_mask_sel;
        solve valu2_class before valu2_op_src1_sel;
        solve valu2_class before valu2_op_src2_sel;
        solve valu2_class before valu2_op_src3_sel;
        solve valu2_class before mask_op_valu2_mask_sel;
        solve vsfu0_class before vsfu_op_vsfu0_src1_sel;
        solve vsfu1_class before vsfu_op_vsfu1_src1_sel;
        solve mexe_class before mexe_op_src1_sel;
        solve mexe_class before mexe_op_src2_sel;
        solve su_class before mexe_op_src1_sel;
        solve su_class before mexe_op_src2_sel;
        solve su_op_src_sel before mexe_op_src1_sel;
        solve su_op_src_sel before mexe_op_src2_sel;
        solve sexe0_class before sexe0_op_src1_sel;
        solve sexe0_class before sexe0_op_src2_sel;
        solve sexe1_class before sexe1_op_src1_sel;
        solve sexe1_class before sexe1_op_src2_sel;
        solve sexe2_class before sexe2_op_src1_sel;
        solve sexe2_class before sexe2_op_src2_sel;
        solve su_class before mask_op_valu0_mask_sel;
        solve su_class before mask_op_valu1_mask_sel;
        solve su_class before mask_op_valu2_mask_sel;
        solve mexe_class before mask_op_valu0_mask_sel;
        solve mexe_class before mask_op_valu1_mask_sel;
        solve mexe_class before mask_op_valu2_mask_sel;
        solve mexe_op_src1_sel before mask_op_valu0_mask_sel;
        solve mexe_op_src1_sel before mask_op_valu1_mask_sel;
        solve mexe_op_src1_sel before mask_op_valu2_mask_sel;
        solve mexe_op_src2_sel before mask_op_valu0_mask_sel;
        solve mexe_op_src2_sel before mask_op_valu1_mask_sel;
        solve mexe_op_src2_sel before mask_op_valu2_mask_sel;
        solve su_op_src_sel before mask_op_valu0_mask_sel;
        solve su_op_src_sel before mask_op_valu1_mask_sel;
        solve su_op_src_sel before mask_op_valu2_mask_sel;
    }

    //----- SEXE1/SEXE2 class：未激活 CLASS_END；src_reg 激活仅单读口 -----
    constraint sexe1_class_c {
        if (!active_exe[VU_SEXE1]) {
            sexe1_class == VU_SEXE1_CLASS_END;
        } else {
            sexe1_class == VU_SEXE1_2_FD_FS1;
        }
    }

    constraint sexe2_class_c {
        if (!active_exe[VU_SEXE2]) {
            sexe2_class == VU_SEXE2_CLASS_END;
        } else {
            sexe2_class == VU_SEXE2_2_FD_FS1;
        }
    }

    //----- 寄存器位域固定值约束（来源：vu_cross.xlsx *_op；按具体 *_class，其余走 else） -----
    constraint prf_op_mrf_wt_src_c {
        prf_op_mrf_wt_src dist {
            8'h01 := (lu_class == VU_LU_2_MD_ADDR) ? inst_gen_cfg.md_exe_type_dist[VU_MD_EXE_LU] : 0,
            8'h02 := (valu0_class inside {VU_VALU0_7_MD_VS2_VS1_VM, VU_VALU0_8_MD_VS2_FS1_VM, VU_VALU0_9_MD_VS1_VM_IMM}) ? inst_gen_cfg.md_exe_type_dist[VU_MD_EXE_VALU0] : 0,
            8'h10 := (mexe_class inside {VU_MEXE_1_MD_MS2_MS1, VU_MEXE_3_MD_MS1, VU_MEXE_4_MD_MS1_VS2}) ? inst_gen_cfg.md_exe_type_dist[VU_MD_EXE_MEXE] : 0,
            8'h00 := (lu_class != VU_LU_2_MD_ADDR && !(valu0_class inside {VU_VALU0_7_MD_VS2_VS1_VM, VU_VALU0_8_MD_VS2_FS1_VM, VU_VALU0_9_MD_VS1_VM_IMM}) && !(mexe_class inside {VU_MEXE_1_MD_MS2_MS1, VU_MEXE_3_MD_MS1, VU_MEXE_4_MD_MS1_VS2})) ? 100 : 0
        };
    }

    constraint prf_op_srf_wt_en_bit0_c {
        if (lu_class == VU_LU_3_FD_ADDR) {
            prf_op_srf_wt_en[24] == 1'b1;
        }
        else {
            prf_op_srf_wt_en[24] == 1'b0;
        }
    }

    constraint prf_op_srf_wt_en_bit1_c {
        if (valu1_class inside {VU_VALU1_4_FD_VS1_IMM, VU_VALU1_5_FD_VS2_FS1_VM}) {
            prf_op_srf_wt_en[25] == 1'b1;
        }
        else {
            prf_op_srf_wt_en[25] == 1'b0;
        }
    }

    constraint prf_op_srf_wt_en_bit2_c {
        if (mexe_class == VU_MEXE_2_FD_MS1) {
            prf_op_srf_wt_en[26] == 1'b1;
        }
        else {
            prf_op_srf_wt_en[26] == 1'b0;
        }
    }

    constraint prf_op_srf_wt_en_bit3_c {
        if (sexe0_class inside {VU_SEXE0_1_FD_FS1_FS2, VU_SEXE0_2_FD_FS1}) {
            prf_op_srf_wt_en[27] == 1'b1;
        }
        else {
            prf_op_srf_wt_en[27] == 1'b0;
        }
    }

    constraint prf_op_srf_wt_en_bit4_c {
        if (sexe1_class inside {VU_SEXE1_1_FD_FS1_FS2, VU_SEXE1_2_FD_FS1}) {
            prf_op_srf_wt_en[28] == 1'b1;
        }
        else {
            prf_op_srf_wt_en[28] == 1'b0;
        }
    }

    constraint prf_op_srf_wt_en_bit5_c {
        if (sexe2_class inside {VU_SEXE2_1_FD_FS1_FS2, VU_SEXE2_2_FD_FS1}) {
            prf_op_srf_wt_en[29] == 1'b1;
        }
        else {
            prf_op_srf_wt_en[29] == 1'b0;
        }
    }

    constraint prf_op_vrf_wt_src_c {
        prf_op_vrf_wt_p0_src dist {
            8'h01 := (lu_class == VU_LU_1_VD_ADDR) ? inst_gen_cfg.vd_exe_type_dist[VU_VD_EXE_LU] : 0,
            8'h02 := (valu0_class inside {VU_VALU0_1_VD_VS2_VS1_VM, VU_VALU0_2_VD_VS2_FS1_VM, VU_VALU0_3_VD_FS1, VU_VALU0_4_VD_FS1_IMM, VU_VALU0_5_VD_VS3_VS1_VS2_VM, VU_VALU0_6_VD_VS3_FS1_VS2_VM}) ? inst_gen_cfg.vd_exe_type_dist[VU_VD_EXE_VALU0] : 0,
            8'h03 := (valu1_class inside {VU_VALU1_1_VD_VS2_VS1_VM, VU_VALU1_2_VD_VS2_FS1_VM, VU_VALU1_3_VD_FS1, VU_VALU1_6_VD_VS1_VM}) ? inst_gen_cfg.vd_exe_type_dist[VU_VD_EXE_VALU1] : 0,
            8'h04 := (valu2_class inside {VU_VALU2_1_VD_VS2_VS1_VM, VU_VALU2_2_VD_VS2_FS1_VM, VU_VALU2_3_VD_FS1, VU_VALU2_4_VD_VS1, VU_VALU2_5_VD_VS2_FS1}) ? inst_gen_cfg.vd_exe_type_dist[VU_VD_EXE_VALU2] : 0,
            8'h05 := (vsfu0_class == VU_VSFU0_1_VD_VS1) ? inst_gen_cfg.vd_exe_type_dist[VU_VD_EXE_VSFU0] : 0,
            8'h06 := (vsfu1_class == VU_VSFU1_1_VD_VS1) ? inst_gen_cfg.vd_exe_type_dist[VU_VD_EXE_VSFU1] : 0,
            8'h00 := (lu_class != VU_LU_1_VD_ADDR && !(valu0_class inside {VU_VALU0_1_VD_VS2_VS1_VM, VU_VALU0_2_VD_VS2_FS1_VM, VU_VALU0_3_VD_FS1, VU_VALU0_4_VD_FS1_IMM, VU_VALU0_5_VD_VS3_VS1_VS2_VM, VU_VALU0_6_VD_VS3_FS1_VS2_VM}) && !(valu1_class inside {VU_VALU1_1_VD_VS2_VS1_VM, VU_VALU1_2_VD_VS2_FS1_VM, VU_VALU1_3_VD_FS1, VU_VALU1_6_VD_VS1_VM}) && !(valu2_class inside {VU_VALU2_1_VD_VS2_VS1_VM, VU_VALU2_2_VD_VS2_FS1_VM, VU_VALU2_3_VD_FS1, VU_VALU2_4_VD_VS1, VU_VALU2_5_VD_VS2_FS1}) && vsfu0_class != VU_VSFU0_1_VD_VS1 && vsfu1_class != VU_VSFU1_1_VD_VS1) ? 100 : 0
        };
        prf_op_vrf_wt_p1_src dist {
            8'h01 := ((lu_class == VU_LU_1_VD_ADDR) && prf_op_vrf_wt_p0_src != 8'h01) ? inst_gen_cfg.vd_exe_type_dist[VU_VD_EXE_LU] : 0,
            8'h02 := ((valu0_class inside {VU_VALU0_1_VD_VS2_VS1_VM, VU_VALU0_2_VD_VS2_FS1_VM, VU_VALU0_3_VD_FS1, VU_VALU0_4_VD_FS1_IMM, VU_VALU0_5_VD_VS3_VS1_VS2_VM, VU_VALU0_6_VD_VS3_FS1_VS2_VM}) && prf_op_vrf_wt_p0_src != 8'h02) ? inst_gen_cfg.vd_exe_type_dist[VU_VD_EXE_VALU0] : 0,
            8'h03 := ((valu1_class inside {VU_VALU1_1_VD_VS2_VS1_VM, VU_VALU1_2_VD_VS2_FS1_VM, VU_VALU1_3_VD_FS1, VU_VALU1_6_VD_VS1_VM}) && prf_op_vrf_wt_p0_src != 8'h03) ? inst_gen_cfg.vd_exe_type_dist[VU_VD_EXE_VALU1] : 0,
            8'h04 := ((valu2_class inside {VU_VALU2_1_VD_VS2_VS1_VM, VU_VALU2_2_VD_VS2_FS1_VM, VU_VALU2_3_VD_FS1, VU_VALU2_4_VD_VS1, VU_VALU2_5_VD_VS2_FS1}) && prf_op_vrf_wt_p0_src != 8'h04) ? inst_gen_cfg.vd_exe_type_dist[VU_VD_EXE_VALU2] : 0,
            8'h05 := ((vsfu0_class == VU_VSFU0_1_VD_VS1) && prf_op_vrf_wt_p0_src != 8'h05) ? inst_gen_cfg.vd_exe_type_dist[VU_VD_EXE_VSFU0] : 0,
            8'h06 := ((vsfu1_class == VU_VSFU1_1_VD_VS1) && prf_op_vrf_wt_p0_src != 8'h06) ? inst_gen_cfg.vd_exe_type_dist[VU_VD_EXE_VSFU1] : 0,
            8'h00 := ((lu_class != VU_LU_1_VD_ADDR || prf_op_vrf_wt_p0_src == 8'h01) && (!(valu0_class inside {VU_VALU0_1_VD_VS2_VS1_VM, VU_VALU0_2_VD_VS2_FS1_VM, VU_VALU0_3_VD_FS1, VU_VALU0_4_VD_FS1_IMM, VU_VALU0_5_VD_VS3_VS1_VS2_VM, VU_VALU0_6_VD_VS3_FS1_VS2_VM}) || prf_op_vrf_wt_p0_src == 8'h02) && (!(valu1_class inside {VU_VALU1_1_VD_VS2_VS1_VM, VU_VALU1_2_VD_VS2_FS1_VM, VU_VALU1_3_VD_FS1, VU_VALU1_6_VD_VS1_VM}) || prf_op_vrf_wt_p0_src == 8'h03) && (!(valu2_class inside {VU_VALU2_1_VD_VS2_VS1_VM, VU_VALU2_2_VD_VS2_FS1_VM, VU_VALU2_3_VD_FS1, VU_VALU2_4_VD_VS1, VU_VALU2_5_VD_VS2_FS1}) || prf_op_vrf_wt_p0_src == 8'h04) && (vsfu0_class != VU_VSFU0_1_VD_VS1 || prf_op_vrf_wt_p0_src == 8'h05) && (vsfu1_class != VU_VSFU1_1_VD_VS1 || prf_op_vrf_wt_p0_src == 8'h06)) ? 100 : 0
        };
    }

    //----- SRC*_SEL / MASK_SEL：按执行单元独立约束（'/' 分段联合 dist） -----
    //----- CLASS_END：src_sel / mask_sel 由 inst_gen_cfg.nop_rand 决定固定 0 或随机 -----
    //----- VALU0/1/2：MASK_SEL 合约束 valu_mask_sel_c（SU/MEXE MS 占用） -----

    constraint su_src_sel_c {
        if (su_class == VU_SU_CLASS_END) {
            if (!inst_gen_cfg.nop_rand) {
                su_op_src_sel == 8'h00;
            }
        }
        else if (su_class == VU_SU_1_VS_ADDR) {
            su_op_src_sel dist {
                8'h30 := inst_gen_cfg.su_vs_sel_pair_weight,
                8'h31 := 100 - inst_gen_cfg.su_vs_sel_pair_weight
            };
        }
        else if (su_class == VU_SU_2_MS_ADDR) {
            su_op_src_sel dist {
                8'h40 := inst_gen_cfg.su_ms_sel_pair_weight,
                8'h41 := 100 - inst_gen_cfg.su_ms_sel_pair_weight
            };
        }
        else if (su_class == VU_SU_3_FS_ADDR) {
            su_op_src_sel == 8'h50;
        }
    }

    constraint valu0_src_sel_c {
        if (valu0_class == VU_VALU0_CLASS_END) {
            if (!inst_gen_cfg.nop_rand) {
                valu0_op_src1_sel == 8'h00;
                valu0_op_src2_sel == 8'h00;
                valu0_op_src3_sel == 8'h00;
            }
        }
        else if (valu0_class inside {VU_VALU0_1_VD_VS2_VS1_VM, VU_VALU0_7_MD_VS2_VS1_VM}) {
            valu0_op_src1_sel dist {
                8'h30 := inst_gen_cfg.valu0_vs1_sel_pair_weight,
                8'h31 := 100 - inst_gen_cfg.valu0_vs1_sel_pair_weight
            };
            valu0_op_src2_sel dist {
                8'h30 := inst_gen_cfg.valu0_vs2_sel_pair_weight,
                8'h31 := 100 - inst_gen_cfg.valu0_vs2_sel_pair_weight
            };
            valu0_op_src3_sel == 8'h00;
        }
        else if (valu0_class inside {VU_VALU0_2_VD_VS2_FS1_VM, VU_VALU0_8_MD_VS2_FS1_VM}) {
            valu0_op_src1_sel == 8'h51;
            valu0_op_src3_sel == 8'h00;
            valu0_op_src2_sel dist {
                8'h30 := inst_gen_cfg.valu0_vs2_sel_pair_weight,
                8'h31 := 100 - inst_gen_cfg.valu0_vs2_sel_pair_weight
            };
        }
        else if (valu0_class == VU_VALU0_3_VD_FS1) {
            valu0_op_src1_sel == 8'h51;
            valu0_op_src2_sel == 8'h00 && valu0_op_src3_sel == 8'h00;
        }
        else if (valu0_class == VU_VALU0_4_VD_FS1_IMM) {
            valu0_op_src1_sel == 8'h51;
            valu0_op_src3_sel == 8'h00;
        }
        else if (valu0_class == VU_VALU0_5_VD_VS3_VS1_VS2_VM) {
            valu0_op_src1_sel dist {
                8'h30 := inst_gen_cfg.valu0_vs1_sel_pair_weight,
                8'h31 := 100 - inst_gen_cfg.valu0_vs1_sel_pair_weight
            };
            valu0_op_src2_sel dist {
                8'h30 := inst_gen_cfg.valu0_vs2_sel_pair_weight,
                8'h31 := 100 - inst_gen_cfg.valu0_vs2_sel_pair_weight
            };
            valu0_op_src3_sel dist {
                8'h30 := inst_gen_cfg.valu0_vs3_sel_pair_weight,
                8'h31 := 100 - inst_gen_cfg.valu0_vs3_sel_pair_weight
            };
        }
        else if (valu0_class == VU_VALU0_6_VD_VS3_FS1_VS2_VM) {
            valu0_op_src1_sel == 8'h51;
            valu0_op_src2_sel dist {
                8'h30 := inst_gen_cfg.valu0_vs2_sel_pair_weight,
                8'h31 := 100 - inst_gen_cfg.valu0_vs2_sel_pair_weight
            };
            valu0_op_src3_sel dist {
                8'h30 := inst_gen_cfg.valu0_vs3_sel_pair_weight,
                8'h31 := 100 - inst_gen_cfg.valu0_vs3_sel_pair_weight
            };
        }
        else if (valu0_class == VU_VALU0_9_MD_VS1_VM_IMM) {
            valu0_op_src1_sel dist {
                8'h30 := inst_gen_cfg.valu0_vs1_sel_pair_weight,
                8'h31 := 100 - inst_gen_cfg.valu0_vs1_sel_pair_weight
            };
        }
    }

    constraint valu1_src_sel_c {
        if (valu1_class == VU_VALU1_CLASS_END) {
            if (!inst_gen_cfg.nop_rand) {
                valu1_op_src1_sel == 8'h00;
                valu1_op_src2_sel == 8'h00;
                valu1_op_src3_sel == 8'h00;
            }
        }
        else if (valu1_class == VU_VALU1_1_VD_VS2_VS1_VM) {
            valu1_op_src1_sel dist {
                8'h30 := inst_gen_cfg.valu1_vs1_sel_pair_weight,
                8'h31 := 100 - inst_gen_cfg.valu1_vs1_sel_pair_weight
            };
            valu1_op_src2_sel dist {
                8'h30 := inst_gen_cfg.valu1_vs2_sel_pair_weight,
                8'h31 := 100 - inst_gen_cfg.valu1_vs2_sel_pair_weight
            };
            valu1_op_src3_sel == 8'h00;
        }
        else if (valu1_class inside {VU_VALU1_2_VD_VS2_FS1_VM, VU_VALU1_5_FD_VS2_FS1_VM}) {
            valu1_op_src1_sel == 8'h52;
            valu1_op_src3_sel == 8'h00;
            valu1_op_src2_sel dist {
                8'h30 := inst_gen_cfg.valu1_vs2_sel_pair_weight,
                8'h31 := 100 - inst_gen_cfg.valu1_vs2_sel_pair_weight
            };
        }
        else if (valu1_class == VU_VALU1_3_VD_FS1) {
            valu1_op_src1_sel == 8'h52;
            valu1_op_src2_sel == 8'h00 && valu1_op_src3_sel == 8'h00;
        }
        else if (valu1_class == VU_VALU1_4_FD_VS1_IMM) {
            valu1_op_src1_sel dist {
                8'h30 := inst_gen_cfg.valu1_vs1_sel_pair_weight,
                8'h31 := 100 - inst_gen_cfg.valu1_vs1_sel_pair_weight
            };
            valu1_op_src3_sel == 8'h00;
        }
        else if (valu1_class == VU_VALU1_6_VD_VS1_VM) {
            valu1_op_src1_sel dist {
                8'h30 := inst_gen_cfg.valu1_vs1_sel_pair_weight,
                8'h31 := 100 - inst_gen_cfg.valu1_vs1_sel_pair_weight
            };
            valu1_op_src2_sel == 8'h00 && valu1_op_src3_sel == 8'h00;
        }
    }

    constraint valu2_src_sel_c {
        if (valu2_class == VU_VALU2_CLASS_END) {
            if (!inst_gen_cfg.nop_rand) {
                valu2_op_src1_sel == 8'h00;
                valu2_op_src2_sel == 8'h00;
                valu2_op_src3_sel == 8'h00;
            }
        }
        else if (valu2_class == VU_VALU2_1_VD_VS2_VS1_VM) {
            valu2_op_src1_sel dist {
                8'h30 := inst_gen_cfg.valu2_vs1_sel_pair_weight,
                8'h31 := 100 - inst_gen_cfg.valu2_vs1_sel_pair_weight
            };
            valu2_op_src2_sel dist {
                8'h30 := inst_gen_cfg.valu2_vs2_sel_pair_weight,
                8'h31 := 100 - inst_gen_cfg.valu2_vs2_sel_pair_weight
            };
            valu2_op_src3_sel == 8'h00;
        }
        else if (valu2_class inside {VU_VALU2_2_VD_VS2_FS1_VM, VU_VALU2_5_VD_VS2_FS1}) {
            valu2_op_src1_sel == 8'h53;
            valu2_op_src3_sel == 8'h00;
            valu2_op_src2_sel dist {
                8'h30 := inst_gen_cfg.valu2_vs2_sel_pair_weight,
                8'h31 := 100 - inst_gen_cfg.valu2_vs2_sel_pair_weight
            };
        }
        else if (valu2_class == VU_VALU2_3_VD_FS1) {
            valu2_op_src1_sel == 8'h53;
            valu2_op_src2_sel == 8'h00 && valu2_op_src3_sel == 8'h00;
        }
        else if (valu2_class == VU_VALU2_4_VD_VS1) {
            valu2_op_src1_sel dist {
                8'h30 := inst_gen_cfg.valu2_vs1_sel_pair_weight,
                8'h31 := 100 - inst_gen_cfg.valu2_vs1_sel_pair_weight
            };
            valu2_op_src2_sel == 8'h00 && valu2_op_src3_sel == 8'h00;
        }
    }

    constraint valu_mask_sel_c {
        if (valu0_class == VU_VALU0_CLASS_END) {
            if (!inst_gen_cfg.nop_rand) {
                mask_op_valu0_mask_sel == 8'h00;
            }
        }
        else if (valu0_class inside {VU_VALU0_1_VD_VS2_VS1_VM, VU_VALU0_2_VD_VS2_FS1_VM, VU_VALU0_5_VD_VS3_VS1_VS2_VM, VU_VALU0_6_VD_VS3_FS1_VS2_VM, VU_VALU0_7_MD_VS2_VS1_VM, VU_VALU0_8_MD_VS2_FS1_VM, VU_VALU0_9_MD_VS1_VM_IMM}) {
            mask_op_valu0_mask_sel dist {
                8'h00 := inst_gen_cfg.valu0_vm_sel_pair_dist[0],
                8'h40 := inst_gen_cfg.valu0_vm_sel_pair_dist[1],
                8'h41 := inst_gen_cfg.valu0_vm_sel_pair_dist[2]
            };
        }
        else if (valu0_class inside {VU_VALU0_3_VD_FS1, VU_VALU0_4_VD_FS1_IMM}) {
            mask_op_valu0_mask_sel == 8'h00;
        }

        if (valu1_class == VU_VALU1_CLASS_END) {
            if (!inst_gen_cfg.nop_rand) {
                mask_op_valu1_mask_sel == 8'h00;
            }
        }
        else if (valu1_class inside {VU_VALU1_1_VD_VS2_VS1_VM, VU_VALU1_2_VD_VS2_FS1_VM, VU_VALU1_5_FD_VS2_FS1_VM, VU_VALU1_6_VD_VS1_VM}) {
            mask_op_valu1_mask_sel dist {
                8'h00 := inst_gen_cfg.valu1_vm_sel_pair_dist[0],
                8'h40 := inst_gen_cfg.valu1_vm_sel_pair_dist[1],
                8'h41 := inst_gen_cfg.valu1_vm_sel_pair_dist[2]
            };
        }
        else if (valu1_class inside {VU_VALU1_3_VD_FS1, VU_VALU1_4_FD_VS1_IMM}) {
            mask_op_valu1_mask_sel == 8'h00;
        }

        if (valu2_class == VU_VALU2_CLASS_END) {
            if (!inst_gen_cfg.nop_rand) {
                mask_op_valu2_mask_sel == 8'h00;
            }
        }
        else if (valu2_class inside {VU_VALU2_1_VD_VS2_VS1_VM, VU_VALU2_2_VD_VS2_FS1_VM}) {
            mask_op_valu2_mask_sel dist {
                8'h00 := inst_gen_cfg.valu2_vm_sel_pair_dist[0],
                8'h40 := inst_gen_cfg.valu2_vm_sel_pair_dist[1],
                8'h41 := inst_gen_cfg.valu2_vm_sel_pair_dist[2]
            };
        }
        else if (valu2_class inside {VU_VALU2_3_VD_FS1, VU_VALU2_4_VD_VS1, VU_VALU2_5_VD_VS2_FS1}) {
            mask_op_valu2_mask_sel == 8'h00;
        }

        // 求解顺序：su_class → mexe src_sel → valu0~2 mask_sel
        // SU 用 MS 时 MEXE src_sel 只能用另一口（mexe_src_sel_c）
        // 有 vm：SU/MEXE 已占用的 0x40/0x41 不得再选；未占用口至多各用 1 次
        if (su_class == VU_SU_2_MS_ADDR) {
            if (valu0_class inside {VU_VALU0_1_VD_VS2_VS1_VM, VU_VALU0_2_VD_VS2_FS1_VM, VU_VALU0_5_VD_VS3_VS1_VS2_VM, VU_VALU0_6_VD_VS3_FS1_VS2_VM, VU_VALU0_7_MD_VS2_VS1_VM, VU_VALU0_8_MD_VS2_FS1_VM, VU_VALU0_9_MD_VS1_VM_IMM}) {
                mask_op_valu0_mask_sel != su_op_src_sel;
            }
            if (valu1_class inside {VU_VALU1_1_VD_VS2_VS1_VM, VU_VALU1_2_VD_VS2_FS1_VM, VU_VALU1_5_FD_VS2_FS1_VM, VU_VALU1_6_VD_VS1_VM}) {
                mask_op_valu1_mask_sel != su_op_src_sel;
            }
            if (valu2_class inside {VU_VALU2_1_VD_VS2_VS1_VM, VU_VALU2_2_VD_VS2_FS1_VM}) {
                mask_op_valu2_mask_sel != su_op_src_sel;
            }
        }
        if (mexe_class != VU_MEXE_CLASS_END) {
            if (valu0_class inside {VU_VALU0_1_VD_VS2_VS1_VM, VU_VALU0_2_VD_VS2_FS1_VM, VU_VALU0_5_VD_VS3_VS1_VS2_VM, VU_VALU0_6_VD_VS3_FS1_VS2_VM, VU_VALU0_7_MD_VS2_VS1_VM, VU_VALU0_8_MD_VS2_FS1_VM, VU_VALU0_9_MD_VS1_VM_IMM}) {
                mask_op_valu0_mask_sel != mexe_op_src1_sel;
            }
            if (valu1_class inside {VU_VALU1_1_VD_VS2_VS1_VM, VU_VALU1_2_VD_VS2_FS1_VM, VU_VALU1_5_FD_VS2_FS1_VM, VU_VALU1_6_VD_VS1_VM}) {
                mask_op_valu1_mask_sel != mexe_op_src1_sel;
            }
            if (valu2_class inside {VU_VALU2_1_VD_VS2_VS1_VM, VU_VALU2_2_VD_VS2_FS1_VM}) {
                mask_op_valu2_mask_sel != mexe_op_src1_sel;
            }
            if ((mexe_class == VU_MEXE_1_MD_MS2_MS1) && (mexe_op_src1_sel != mexe_op_src2_sel)) {
                if (valu0_class inside {VU_VALU0_1_VD_VS2_VS1_VM, VU_VALU0_2_VD_VS2_FS1_VM, VU_VALU0_5_VD_VS3_VS1_VS2_VM, VU_VALU0_6_VD_VS3_FS1_VS2_VM, VU_VALU0_7_MD_VS2_VS1_VM, VU_VALU0_8_MD_VS2_FS1_VM, VU_VALU0_9_MD_VS1_VM_IMM}) {
                    mask_op_valu0_mask_sel != mexe_op_src2_sel;
                }
                if (valu1_class inside {VU_VALU1_1_VD_VS2_VS1_VM, VU_VALU1_2_VD_VS2_FS1_VM, VU_VALU1_5_FD_VS2_FS1_VM, VU_VALU1_6_VD_VS1_VM}) {
                    mask_op_valu1_mask_sel != mexe_op_src2_sel;
                }
                if (valu2_class inside {VU_VALU2_1_VD_VS2_VS1_VM, VU_VALU2_2_VD_VS2_FS1_VM}) {
                    mask_op_valu2_mask_sel != mexe_op_src2_sel;
                }
            }
        }
        (
              ((valu0_class inside {VU_VALU0_1_VD_VS2_VS1_VM, VU_VALU0_2_VD_VS2_FS1_VM, VU_VALU0_5_VD_VS3_VS1_VS2_VM, VU_VALU0_6_VD_VS3_FS1_VS2_VM, VU_VALU0_7_MD_VS2_VS1_VM, VU_VALU0_8_MD_VS2_FS1_VM, VU_VALU0_9_MD_VS1_VM_IMM}) && (mask_op_valu0_mask_sel == 8'h40))
            + ((valu1_class inside {VU_VALU1_1_VD_VS2_VS1_VM, VU_VALU1_2_VD_VS2_FS1_VM, VU_VALU1_5_FD_VS2_FS1_VM, VU_VALU1_6_VD_VS1_VM}) && (mask_op_valu1_mask_sel == 8'h40))
            + ((valu2_class inside {VU_VALU2_1_VD_VS2_VS1_VM, VU_VALU2_2_VD_VS2_FS1_VM}) && (mask_op_valu2_mask_sel == 8'h40))
        ) <= 1;
        (
              ((valu0_class inside {VU_VALU0_1_VD_VS2_VS1_VM, VU_VALU0_2_VD_VS2_FS1_VM, VU_VALU0_5_VD_VS3_VS1_VS2_VM, VU_VALU0_6_VD_VS3_FS1_VS2_VM, VU_VALU0_7_MD_VS2_VS1_VM, VU_VALU0_8_MD_VS2_FS1_VM, VU_VALU0_9_MD_VS1_VM_IMM}) && (mask_op_valu0_mask_sel == 8'h41))
            + ((valu1_class inside {VU_VALU1_1_VD_VS2_VS1_VM, VU_VALU1_2_VD_VS2_FS1_VM, VU_VALU1_5_FD_VS2_FS1_VM, VU_VALU1_6_VD_VS1_VM}) && (mask_op_valu1_mask_sel == 8'h41))
            + ((valu2_class inside {VU_VALU2_1_VD_VS2_VS1_VM, VU_VALU2_2_VD_VS2_FS1_VM}) && (mask_op_valu2_mask_sel == 8'h41))
        ) <= 1;
    }

    constraint vsfu0_src_sel_c {
        if (vsfu0_class == VU_VSFU0_CLASS_END) {
            if (!inst_gen_cfg.nop_rand) {
                vsfu_op_vsfu0_src1_sel == 8'h00;
            }
        }
        else if (vsfu0_class == VU_VSFU0_1_VD_VS1) {
            vsfu_op_vsfu0_src1_sel dist {
                8'h30 := inst_gen_cfg.vsfu0_vs_sel_pair_weight,
                8'h31 := 100 - inst_gen_cfg.vsfu0_vs_sel_pair_weight
            };
        }
    }

    constraint vsfu1_src_sel_c {
        if (vsfu1_class == VU_VSFU1_CLASS_END) {
            if (!inst_gen_cfg.nop_rand) {
                vsfu_op_vsfu1_src1_sel == 8'h00;
            }
        }
        else if (vsfu1_class == VU_VSFU1_1_VD_VS1) {
            vsfu_op_vsfu1_src1_sel dist {
                8'h30 := inst_gen_cfg.vsfu1_vs_sel_pair_weight,
                8'h31 := 100 - inst_gen_cfg.vsfu1_vs_sel_pair_weight
            };
        }
    }

    constraint mexe_src_sel_c {
        if (mexe_class == VU_MEXE_CLASS_END) {
            if (!inst_gen_cfg.nop_rand) {
                mexe_op_src1_sel == 8'h00;
                mexe_op_src2_sel == 8'h00;
            }
        }
        else if (mexe_class == VU_MEXE_1_MD_MS2_MS1) {
            if (su_class == VU_SU_2_MS_ADDR && su_op_src_sel == 8'h40) {
                mexe_op_src1_sel == 8'h41;
                mexe_op_src2_sel == 8'h41;
            } else if (su_class == VU_SU_2_MS_ADDR && su_op_src_sel == 8'h41) {
                mexe_op_src1_sel == 8'h40;
                mexe_op_src2_sel == 8'h40;
            } else {
                mexe_op_src1_sel dist {
                    8'h40 := inst_gen_cfg.mexe_ms1_sel_pair_weight,
                    8'h41 := 100 - inst_gen_cfg.mexe_ms1_sel_pair_weight
                };
                mexe_op_src2_sel dist {
                    8'h40 := inst_gen_cfg.mexe_ms2_sel_pair_weight,
                    8'h41 := 100 - inst_gen_cfg.mexe_ms2_sel_pair_weight
                };
            }
        }
        else if (mexe_class inside {VU_MEXE_2_FD_MS1, VU_MEXE_3_MD_MS1}) {
            if (su_class == VU_SU_2_MS_ADDR && su_op_src_sel == 8'h40) {
                mexe_op_src1_sel == 8'h41;
            } else if (su_class == VU_SU_2_MS_ADDR && su_op_src_sel == 8'h41) {
                mexe_op_src1_sel == 8'h40;
            } else {
                mexe_op_src1_sel dist {
                    8'h40 := inst_gen_cfg.mexe_ms1_sel_pair_weight,
                    8'h41 := 100 - inst_gen_cfg.mexe_ms1_sel_pair_weight
                };
            }
            mexe_op_src2_sel == 8'h00;
        }
        else if (mexe_class == VU_MEXE_4_MD_MS1_VS2) {
            if (su_class == VU_SU_2_MS_ADDR && su_op_src_sel == 8'h40) {
                mexe_op_src1_sel == 8'h41;
            } else if (su_class == VU_SU_2_MS_ADDR && su_op_src_sel == 8'h41) {
                mexe_op_src1_sel == 8'h40;
            } else {
                mexe_op_src1_sel dist {
                    8'h40 := inst_gen_cfg.mexe_ms1_sel_pair_weight,
                    8'h41 := 100 - inst_gen_cfg.mexe_ms1_sel_pair_weight
                };
            }
            mexe_op_src2_sel dist {
                8'h30 := inst_gen_cfg.mexe_vs_sel_pair_weight,
                8'h31 := 100 - inst_gen_cfg.mexe_vs_sel_pair_weight
            };
        }
    }

    constraint sexe0_src_sel_c {
        if (sexe0_class == VU_SEXE0_CLASS_END) {
            if (!inst_gen_cfg.nop_rand) {
                sexe0_op_src1_sel == 8'h00;
                sexe0_op_src2_sel == 8'h00;
            }
        }
        else if (sexe0_class == VU_SEXE0_1_FD_FS1_FS2) {
            sexe0_op_src1_sel == 8'h54 && sexe0_op_src2_sel == 8'h55;
        }
        else if (sexe0_class == VU_SEXE0_2_FD_FS1) {
            sexe0_op_src1_sel == 8'h54;
            sexe0_op_src2_sel == 8'h00;
        }
    }

    constraint sexe1_src_sel_c {
        if (sexe1_class == VU_SEXE1_CLASS_END) {
            if (!inst_gen_cfg.nop_rand) {
                sexe1_op_src1_sel == 8'h00;
                sexe1_op_src2_sel == 8'h00;
            }
        }
        else if (sexe1_class == VU_SEXE1_2_FD_FS1) {
            sexe1_op_src1_sel == 8'h56;
            sexe1_op_src2_sel == 8'h00;
        }
    }

    constraint sexe2_src_sel_c {
        if (sexe2_class == VU_SEXE2_CLASS_END) {
            if (!inst_gen_cfg.nop_rand) {
                sexe2_op_src1_sel == 8'h00;
                sexe2_op_src2_sel == 8'h00;
            }
        }
        else if (sexe2_class == VU_SEXE2_2_FD_FS1) {
            sexe2_op_src1_sel == 8'h57;
            sexe2_op_src2_sel == 8'h00;
        }
    }

endclass : cross_src_reg_seq_item

class cross_3_src_reg_seq_item extends cross_src_reg_seq_item;
    `uvm_object_utils(cross_3_src_reg_seq_item)

    function new (string name = "cross_3_src_reg_seq_item");
        super.new(name);
    endfunction : new

    //----- 求解顺序：VALU0 → VALU1 → LU；VALU0 → MEXE → LU -----
    constraint gen_sel_solve_order_c {
        solve valu0_class before mexe_class;
        solve mexe_class before lu_class;
        solve valu0_class before valu1_class;
        solve valu1_class before lu_class;
    }

    //----- LU/VALU0/VALU1/MEXE class：MD 写口互斥；VD 仅 2 写口（VALU2/VSFU 占 2 口时 LU/VALU0/VALU1 不得写 VD；占 1 口时 VALU0→VALU1→LU 抢剩余 1 口；占 0 口时 VALU0+VALU1 占满则 LU 不得写 VD） -----
    constraint lu_class_c {
        if (!active_exe[VU_LU]) {
            lu_class == VU_LU_CLASS_END;
        } else if ({active_exe[VU_VALU2], active_exe[VU_VSFU0], active_exe[VU_VSFU1]} inside {3'd3, 3'd5, 3'd6} && (valu0_class inside {VU_VALU0_7_MD_VS2_VS1_VM, VU_VALU0_8_MD_VS2_FS1_VM, VU_VALU0_9_MD_VS1_VM_IMM} || mexe_class inside {VU_MEXE_1_MD_MS2_MS1, VU_MEXE_3_MD_MS1, VU_MEXE_4_MD_MS1_VS2})) {
            lu_class == VU_LU_3_FD_ADDR;
        } else if ({active_exe[VU_VALU2], active_exe[VU_VSFU0], active_exe[VU_VSFU1]} inside {3'd3, 3'd5, 3'd6}) {
            lu_class dist {
                VU_LU_2_MD_ADDR          := inst_gen_cfg.lu_class_dist[VU_LU_2_MD_ADDR],
                VU_LU_3_FD_ADDR          := inst_gen_cfg.lu_class_dist[VU_LU_3_FD_ADDR]
            };
        } else if ({active_exe[VU_VALU2], active_exe[VU_VSFU0], active_exe[VU_VSFU1]} inside {3'd1, 3'd2, 3'd4} && (valu0_class inside {VU_VALU0_1_VD_VS2_VS1_VM, VU_VALU0_2_VD_VS2_FS1_VM, VU_VALU0_3_VD_FS1, VU_VALU0_4_VD_FS1_IMM, VU_VALU0_5_VD_VS3_VS1_VS2_VM, VU_VALU0_6_VD_VS3_FS1_VS2_VM} || valu1_class inside {VU_VALU1_1_VD_VS2_VS1_VM, VU_VALU1_2_VD_VS2_FS1_VM, VU_VALU1_3_VD_FS1, VU_VALU1_6_VD_VS1_VM}) && (valu0_class inside {VU_VALU0_7_MD_VS2_VS1_VM, VU_VALU0_8_MD_VS2_FS1_VM, VU_VALU0_9_MD_VS1_VM_IMM} || mexe_class inside {VU_MEXE_1_MD_MS2_MS1, VU_MEXE_3_MD_MS1, VU_MEXE_4_MD_MS1_VS2})) {
            lu_class == VU_LU_3_FD_ADDR;
        } else if ({active_exe[VU_VALU2], active_exe[VU_VSFU0], active_exe[VU_VSFU1]} inside {3'd1, 3'd2, 3'd4} && (valu0_class inside {VU_VALU0_1_VD_VS2_VS1_VM, VU_VALU0_2_VD_VS2_FS1_VM, VU_VALU0_3_VD_FS1, VU_VALU0_4_VD_FS1_IMM, VU_VALU0_5_VD_VS3_VS1_VS2_VM, VU_VALU0_6_VD_VS3_FS1_VS2_VM} || valu1_class inside {VU_VALU1_1_VD_VS2_VS1_VM, VU_VALU1_2_VD_VS2_FS1_VM, VU_VALU1_3_VD_FS1, VU_VALU1_6_VD_VS1_VM})) {
            lu_class dist {
                VU_LU_2_MD_ADDR          := inst_gen_cfg.lu_class_dist[VU_LU_2_MD_ADDR],
                VU_LU_3_FD_ADDR          := inst_gen_cfg.lu_class_dist[VU_LU_3_FD_ADDR]
            };
        } else if ({active_exe[VU_VALU2], active_exe[VU_VSFU0], active_exe[VU_VSFU1]} == 3'd0 && (valu0_class inside {VU_VALU0_1_VD_VS2_VS1_VM, VU_VALU0_2_VD_VS2_FS1_VM, VU_VALU0_3_VD_FS1, VU_VALU0_4_VD_FS1_IMM, VU_VALU0_5_VD_VS3_VS1_VS2_VM, VU_VALU0_6_VD_VS3_FS1_VS2_VM}) && (valu1_class inside {VU_VALU1_1_VD_VS2_VS1_VM, VU_VALU1_2_VD_VS2_FS1_VM, VU_VALU1_3_VD_FS1, VU_VALU1_6_VD_VS1_VM}) && (valu0_class inside {VU_VALU0_7_MD_VS2_VS1_VM, VU_VALU0_8_MD_VS2_FS1_VM, VU_VALU0_9_MD_VS1_VM_IMM} || mexe_class inside {VU_MEXE_1_MD_MS2_MS1, VU_MEXE_3_MD_MS1, VU_MEXE_4_MD_MS1_VS2})) {
            lu_class == VU_LU_3_FD_ADDR;
        } else if ({active_exe[VU_VALU2], active_exe[VU_VSFU0], active_exe[VU_VSFU1]} == 3'd0 && (valu0_class inside {VU_VALU0_1_VD_VS2_VS1_VM, VU_VALU0_2_VD_VS2_FS1_VM, VU_VALU0_3_VD_FS1, VU_VALU0_4_VD_FS1_IMM, VU_VALU0_5_VD_VS3_VS1_VS2_VM, VU_VALU0_6_VD_VS3_FS1_VS2_VM}) && (valu1_class inside {VU_VALU1_1_VD_VS2_VS1_VM, VU_VALU1_2_VD_VS2_FS1_VM, VU_VALU1_3_VD_FS1, VU_VALU1_6_VD_VS1_VM})) {
            lu_class dist {
                VU_LU_2_MD_ADDR          := inst_gen_cfg.lu_class_dist[VU_LU_2_MD_ADDR],
                VU_LU_3_FD_ADDR          := inst_gen_cfg.lu_class_dist[VU_LU_3_FD_ADDR]
            };
        } else if (valu0_class inside {VU_VALU0_7_MD_VS2_VS1_VM, VU_VALU0_8_MD_VS2_FS1_VM, VU_VALU0_9_MD_VS1_VM_IMM} || mexe_class inside {VU_MEXE_1_MD_MS2_MS1, VU_MEXE_3_MD_MS1, VU_MEXE_4_MD_MS1_VS2}) {
            lu_class dist {
                VU_LU_1_VD_ADDR          := inst_gen_cfg.lu_class_dist[VU_LU_1_VD_ADDR],
                VU_LU_3_FD_ADDR          := inst_gen_cfg.lu_class_dist[VU_LU_3_FD_ADDR]
            };
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
        } else if ({active_exe[VU_VALU2], active_exe[VU_VSFU0], active_exe[VU_VSFU1]} inside {3'd3, 3'd5, 3'd6}) {
            valu0_class dist {
                VU_VALU0_7_MD_VS2_VS1_VM := inst_gen_cfg.valu0_class_dist[VU_VALU0_7_MD_VS2_VS1_VM],
                VU_VALU0_8_MD_VS2_FS1_VM := inst_gen_cfg.valu0_class_dist[VU_VALU0_8_MD_VS2_FS1_VM],
                VU_VALU0_9_MD_VS1_VM_IMM := inst_gen_cfg.valu0_class_dist[VU_VALU0_9_MD_VS1_VM_IMM]
            };
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
        } else if ({active_exe[VU_VALU2], active_exe[VU_VSFU0], active_exe[VU_VSFU1]} inside {3'd3, 3'd5, 3'd6}) {
            valu1_class dist {
                VU_VALU1_4_FD_VS1_IMM    := inst_gen_cfg.valu1_class_dist[VU_VALU1_4_FD_VS1_IMM],
                VU_VALU1_5_FD_VS2_FS1_VM := inst_gen_cfg.valu1_class_dist[VU_VALU1_5_FD_VS2_FS1_VM]
            };
        } else if ({active_exe[VU_VALU2], active_exe[VU_VSFU0], active_exe[VU_VSFU1]} inside {3'd1, 3'd2, 3'd4} && (valu0_class inside {VU_VALU0_1_VD_VS2_VS1_VM, VU_VALU0_2_VD_VS2_FS1_VM, VU_VALU0_3_VD_FS1, VU_VALU0_4_VD_FS1_IMM, VU_VALU0_5_VD_VS3_VS1_VS2_VM, VU_VALU0_6_VD_VS3_FS1_VS2_VM})) {
            valu1_class dist {
                VU_VALU1_4_FD_VS1_IMM    := inst_gen_cfg.valu1_class_dist[VU_VALU1_4_FD_VS1_IMM],
                VU_VALU1_5_FD_VS2_FS1_VM := inst_gen_cfg.valu1_class_dist[VU_VALU1_5_FD_VS2_FS1_VM]
            };
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
        } else if (valu0_class inside {VU_VALU0_7_MD_VS2_VS1_VM, VU_VALU0_8_MD_VS2_FS1_VM, VU_VALU0_9_MD_VS1_VM_IMM}) {
            mexe_class == VU_MEXE_2_FD_MS1;
        } else {
            mexe_class dist {
                VU_MEXE_1_MD_MS2_MS1     := inst_gen_cfg.mexe_class_dist[VU_MEXE_1_MD_MS2_MS1],
                VU_MEXE_2_FD_MS1         := inst_gen_cfg.mexe_class_dist[VU_MEXE_2_FD_MS1],
                VU_MEXE_3_MD_MS1         := inst_gen_cfg.mexe_class_dist[VU_MEXE_3_MD_MS1],
                VU_MEXE_4_MD_MS1_VS2     := inst_gen_cfg.mexe_class_dist[VU_MEXE_4_MD_MS1_VS2]
            };
        }
    }

endclass : cross_3_src_reg_seq_item

`endif
