// ============================================================================
// Filename             : inst_gen_config.sv
// Author               : kippy
// Created On           : 2026-6-24 15:46
// Last Modified        :
// Update Count         :
// Description          :
// Source               : fixed template (auto-generated)
// Generator            : gen_inst_gen.py
// DO NOT EDIT          : re-run the generator after template updates.
// ============================================================================
`ifndef INST_GEN_CONFIG_SV
`define INST_GEN_CONFIG_SV
typedef class cross_1_config;
typedef class cross_2_config;
typedef class cross_3_config;
typedef class cross_4_config;
typedef class cross_5_config;
typedef class cross_6_config;
typedef class cross_7_config;
typedef class cross_8_config;
typedef class cross_9_config;
typedef class cross_10_config;
typedef class cross_11_config;

class inst_gen_config extends uvm_object;
    uvm_active_passive_enum is_active = UVM_ACTIVE;
    bit checks_enable   = 1;
    bit coverage_enable = 1;
    virtual inst_gen_if inst_gen_vif;
    // ===================== 指令序列长度控制 =====================
    int unsigned        inst_seq_length=100;
    int unsigned        exe_num;
    int unsigned        exp_exe_num = 10000;
    // ===================== 指令类型控制 =====================
    bit                 fix_inst_type_en=0;
    rand inst_type_e    inst_type;
    rand int unsigned   inst_type_dist[];
    bit                 fix_mu_inst_type_en=0;
    rand mu_inst_type_e mu_inst_type;
    rand int unsigned   mu_inst_type_dist[];
    bit                 fix_vu_inst_type_en=0;
    rand vu_inst_type_e vu_inst_type;
    rand int unsigned   vu_inst_type_dist[];
    // ===================== cross_inst 1~11 分层配置对象 =====================
    rand cross_1_config       cross_1_cfg;
    rand cross_2_config       cross_2_cfg;
    rand cross_3_config       cross_3_cfg;
    rand cross_4_config       cross_4_cfg;
    rand cross_5_config       cross_5_cfg;
    rand cross_6_config       cross_6_cfg;
    rand cross_7_config       cross_7_cfg;
    rand cross_8_config       cross_8_cfg;
    rand cross_9_config       cross_9_cfg;
    rand cross_10_config      cross_10_cfg;
    rand cross_11_config      cross_11_cfg;

    // ===================== VU class / cN_type dist 控制 =====================
    rand int unsigned   lu_class_dist[];
    rand int unsigned   lu_c1_type_dist[];
    rand int unsigned   lu_c2_type_dist[];
    rand int unsigned   lu_c3_type_dist[];
    rand int unsigned   su_class_dist[];
    rand int unsigned   su_c1_type_dist[];
    rand int unsigned   su_c2_type_dist[];
    rand int unsigned   su_c3_type_dist[];
    rand int unsigned   valu0_class_dist[];
    rand int unsigned   valu0_c1_type_dist[];
    rand int unsigned   valu0_c2_type_dist[];
    rand int unsigned   valu0_c3_type_dist[];
    rand int unsigned   valu0_c4_type_dist[];
    rand int unsigned   valu0_c5_type_dist[];
    rand int unsigned   valu0_c6_type_dist[];
    rand int unsigned   valu0_c7_type_dist[];
    rand int unsigned   valu0_c8_type_dist[];
    rand int unsigned   valu0_c9_type_dist[];
    rand int unsigned   valu1_class_dist[];
    rand int unsigned   valu1_c1_type_dist[];
    rand int unsigned   valu1_c2_type_dist[];
    rand int unsigned   valu1_c3_type_dist[];
    rand int unsigned   valu1_c4_type_dist[];
    rand int unsigned   valu1_c5_type_dist[];
    rand int unsigned   valu1_c6_type_dist[];
    rand int unsigned   valu2_class_dist[];
    rand int unsigned   valu2_c1_type_dist[];
    rand int unsigned   valu2_c2_type_dist[];
    rand int unsigned   valu2_c3_type_dist[];
    rand int unsigned   valu2_c4_type_dist[];
    rand int unsigned   valu2_c5_type_dist[];
    rand int unsigned   vsfu0_c1_type_dist[];
    rand int unsigned   vsfu1_c1_type_dist[];
    rand int unsigned   mexe_class_dist[];
    rand int unsigned   mexe_c1_type_dist[];
    rand int unsigned   mexe_c2_type_dist[];
    rand int unsigned   mexe_c3_type_dist[];
    rand int unsigned   mexe_c4_type_dist[];
    rand int unsigned   sexe0_class_dist[];
    rand int unsigned   sexe0_c1_type_dist[];
    rand int unsigned   sexe0_c2_type_dist[];
    rand int unsigned   sexe1_class_dist[];
    rand int unsigned   sexe1_c1_type_dist[];
    rand int unsigned   sexe1_c2_type_dist[];
    rand int unsigned   sexe2_class_dist[];
    rand int unsigned   sexe2_c1_type_dist[];
    rand int unsigned   sexe2_c2_type_dist[];
    // ===================== vd/md 写回来源 dist =====================
    rand int unsigned   vd_exe_type_dist[];
    rand int unsigned   md_exe_type_dist[];
    // ===================== VU 寄存器位域 fix（含 sheet 固定值字段） =====================
    bit                 fix_lu_op_stride_run_en=0;
    rand logic [7:0]      lu_op_stride_run;
    bit                 fix_lu_op_stride_skip_en=0;
    rand logic [7:0]      lu_op_stride_skip;
    bit                 fix_macro_inst_trigger_config_idx_en=0;
    rand logic [2:0]      macro_inst_trigger_config_idx;
    bit                 fix_macro_inst_trigger_data_broadcast_en=0;
    rand logic            macro_inst_trigger_data_broadcast;
    bit                 fix_macro_inst_trigger_event_en_en=0;
    rand logic            macro_inst_trigger_event_en;
    bit                 fix_macro_inst_trigger_macro_inst_fence_en=0;
    rand logic            macro_inst_trigger_macro_inst_fence;
    bit                 fix_macro_inst_trigger_static_dynamic_mask_en=0;
    rand logic [7:0]      macro_inst_trigger_static_dynamic_mask;
    bit                 fix_macro_inst_trigger_stream_id_en=0;
    rand logic [3:0]      macro_inst_trigger_stream_id;
    bit                 fix_macro_inst_trigger_stream_id_override_en=0;
    rand logic            macro_inst_trigger_stream_id_override;
    bit                 fix_mask_op_valu0_mask_sel_en=0;
    rand logic [7:0]      mask_op_valu0_mask_sel;
    bit                 fix_mask_op_valu1_mask_sel_en=0;
    rand logic [7:0]      mask_op_valu1_mask_sel;
    bit                 fix_mask_op_valu2_mask_sel_en=0;
    rand logic [7:0]      mask_op_valu2_mask_sel;
    bit                 fix_mexe_op_src1_sel_en=0;
    rand logic [7:0]      mexe_op_src1_sel;
    bit                 fix_mexe_op_src2_sel_en=0;
    rand logic [7:0]      mexe_op_src2_sel;
    bit                 fix_prf_op_mrf_wt_src_en=0;
    rand logic [7:0]      prf_op_mrf_wt_src;
    bit                 fix_prf_op_srf_wt_en_en=0;
    rand logic [7:0]      prf_op_srf_wt_en;
    bit                 fix_prf_op_vrf_wt_p0_src_en=0;
    rand logic [7:0]      prf_op_vrf_wt_p0_src;
    bit                 fix_prf_op_vrf_wt_p1_src_en=0;
    rand logic [7:0]      prf_op_vrf_wt_p1_src;
    bit                 fix_sexe0_op_src1_sel_en=0;
    rand logic [7:0]      sexe0_op_src1_sel;
    bit                 fix_sexe0_op_src2_sel_en=0;
    rand logic [7:0]      sexe0_op_src2_sel;
    bit                 fix_sexe1_op_src1_sel_en=0;
    rand logic [7:0]      sexe1_op_src1_sel;
    bit                 fix_sexe1_op_src2_sel_en=0;
    rand logic [7:0]      sexe1_op_src2_sel;
    bit                 fix_sexe2_op_src1_sel_en=0;
    rand logic [7:0]      sexe2_op_src1_sel;
    bit                 fix_sexe2_op_src2_sel_en=0;
    rand logic [7:0]      sexe2_op_src2_sel;
    bit                 fix_static_ld_addr_cm_addr_en=0;
    rand logic [31:0]     static_ld_addr_cm_addr;
    bit                 fix_static_mrf_rd_index_mrf_rd_p0_idx_en=0;
    rand logic [15:0]     static_mrf_rd_index_mrf_rd_p0_idx;
    bit                 fix_static_mrf_rd_index_mrf_rd_p1_idx_en=0;
    rand logic [15:0]     static_mrf_rd_index_mrf_rd_p1_idx;
    bit                 fix_static_mrf_wt_index_mrf_wt_idx_en=0;
    rand logic [15:0]     static_mrf_wt_index_mrf_wt_idx;
    bit                 fix_static_srf_rd_index_0_srf_rd_p0_idx_en=0;
    rand logic [7:0]      static_srf_rd_index_0_srf_rd_p0_idx;
    bit                 fix_static_srf_rd_index_0_srf_rd_p1_idx_en=0;
    rand logic [7:0]      static_srf_rd_index_0_srf_rd_p1_idx;
    bit                 fix_static_srf_rd_index_0_srf_rd_p2_idx_en=0;
    rand logic [7:0]      static_srf_rd_index_0_srf_rd_p2_idx;
    bit                 fix_static_srf_rd_index_0_srf_rd_p3_idx_en=0;
    rand logic [7:0]      static_srf_rd_index_0_srf_rd_p3_idx;
    bit                 fix_static_srf_rd_index_1_srf_rd_p4_idx_en=0;
    rand logic [7:0]      static_srf_rd_index_1_srf_rd_p4_idx;
    bit                 fix_static_srf_rd_index_1_srf_rd_p5_idx_en=0;
    rand logic [7:0]      static_srf_rd_index_1_srf_rd_p5_idx;
    bit                 fix_static_srf_rd_index_1_srf_rd_p6_idx_en=0;
    rand logic [7:0]      static_srf_rd_index_1_srf_rd_p6_idx;
    bit                 fix_static_srf_rd_index_1_srf_rd_p7_idx_en=0;
    rand logic [7:0]      static_srf_rd_index_1_srf_rd_p7_idx;
    bit                 fix_static_srf_wt_index_0_srf_wt_p0_idx_en=0;
    rand logic [7:0]      static_srf_wt_index_0_srf_wt_p0_idx;
    bit                 fix_static_srf_wt_index_0_srf_wt_p1_idx_en=0;
    rand logic [7:0]      static_srf_wt_index_0_srf_wt_p1_idx;
    bit                 fix_static_srf_wt_index_0_srf_wt_p2_idx_en=0;
    rand logic [7:0]      static_srf_wt_index_0_srf_wt_p2_idx;
    bit                 fix_static_srf_wt_index_0_srf_wt_p3_idx_en=0;
    rand logic [7:0]      static_srf_wt_index_0_srf_wt_p3_idx;
    bit                 fix_static_srf_wt_index_1_srf_wt_p4_idx_en=0;
    rand logic [7:0]      static_srf_wt_index_1_srf_wt_p4_idx;
    bit                 fix_static_srf_wt_index_1_srf_wt_p5_idx_en=0;
    rand logic [7:0]      static_srf_wt_index_1_srf_wt_p5_idx;
    bit                 fix_static_st_addr_cm_addr_en=0;
    rand logic [31:0]     static_st_addr_cm_addr;
    bit                 fix_static_type_vl_data_type_en=0;
    rand logic            static_type_vl_data_type;
    bit                 fix_static_type_vl_round_mode_en=0;
    rand logic [2:0]      static_type_vl_round_mode;
    bit                 fix_static_type_vl_vl_en=0;
    rand logic [15:0]     static_type_vl_vl;
    bit                 fix_static_vrf_rd_index_vrf_rd_p0_idx_en=0;
    rand logic [15:0]     static_vrf_rd_index_vrf_rd_p0_idx;
    bit                 fix_static_vrf_rd_index_vrf_rd_p1_idx_en=0;
    rand logic [15:0]     static_vrf_rd_index_vrf_rd_p1_idx;
    bit                 fix_static_vrf_wt_index_vrf_wt_p0_idx_en=0;
    rand logic [15:0]     static_vrf_wt_index_vrf_wt_p0_idx;
    bit                 fix_static_vrf_wt_index_vrf_wt_p1_idx_en=0;
    rand logic [15:0]     static_vrf_wt_index_vrf_wt_p1_idx;
    bit                 fix_su_op_mxfp8_scale_round_en=0;
    rand logic            su_op_mxfp8_scale_round;
    bit                 fix_su_op_src_sel_en=0;
    rand logic [7:0]      su_op_src_sel;
    bit                 fix_valu0_op_src1_sel_en=0;
    rand logic [7:0]      valu0_op_src1_sel;
    bit                 fix_valu0_op_src2_sel_en=0;
    rand logic [7:0]      valu0_op_src2_sel;
    bit                 fix_valu0_op_src3_sel_en=0;
    rand logic [7:0]      valu0_op_src3_sel;
    bit                 fix_valu1_op_src1_sel_en=0;
    rand logic [7:0]      valu1_op_src1_sel;
    bit                 fix_valu1_op_src2_sel_en=0;
    rand logic [7:0]      valu1_op_src2_sel;
    bit                 fix_valu1_op_src3_sel_en=0;
    rand logic [7:0]      valu1_op_src3_sel;
    bit                 fix_valu2_op_src1_sel_en=0;
    rand logic [7:0]      valu2_op_src1_sel;
    bit                 fix_valu2_op_src2_sel_en=0;
    rand logic [7:0]      valu2_op_src2_sel;
    bit                 fix_valu2_op_src3_sel_en=0;
    rand logic [7:0]      valu2_op_src3_sel;
    bit                 fix_vsfu_op_vsfu0_src1_sel_en=0;
    rand logic [7:0]      vsfu_op_vsfu0_src1_sel;
    bit                 fix_vsfu_op_vsfu1_src1_sel_en=0;
    rand logic [7:0]      vsfu_op_vsfu1_src1_sel;
    // ===================== RF 读写指针相等 fix =====================
    bit                 fix_vrf_rw_eq_0_en=0;
    rand logic [1:0]      vrf_rw_eq_0;
    bit                 fix_vrf_rw_eq_1_en=0;
    rand logic [1:0]      vrf_rw_eq_1;
    bit                 fix_mrf_rw_eq_0_en=0;
    rand logic            mrf_rw_eq_0;
    bit                 fix_mrf_rw_eq_1_en=0;
    rand logic            mrf_rw_eq_1;
    bit                 fix_srf_rw_eq_0_en=0;
    rand logic [5:0]      srf_rw_eq_0;
    bit                 fix_srf_rw_eq_1_en=0;
    rand logic [5:0]      srf_rw_eq_1;
    bit                 fix_srf_rw_eq_2_en=0;
    rand logic [5:0]      srf_rw_eq_2;
    bit                 fix_srf_rw_eq_3_en=0;
    rand logic [5:0]      srf_rw_eq_3;
    bit                 fix_srf_rw_eq_4_en=0;
    rand logic [5:0]      srf_rw_eq_4;
    bit                 fix_srf_rw_eq_5_en=0;
    rand logic [5:0]      srf_rw_eq_5;
    bit                 fix_srf_rw_eq_6_en=0;
    rand logic [5:0]      srf_rw_eq_6;
    bit                 fix_srf_rw_eq_7_en=0;
    rand logic [5:0]      srf_rw_eq_7;
    // ===================== VRF_WT P0/P1 配对分布 =====================
    rand int unsigned   prf_op_vrf_wt_pair_weight;
    // ===================== SRC/MASK 各执行单元 vs/ms/vm 配对分布（VALU vs 按槽位） =====================
    rand int unsigned   su_vs_sel_pair_weight;
    rand int unsigned   su_ms_sel_pair_weight;
    rand int unsigned   valu0_vs1_sel_pair_weight;
    rand int unsigned   valu0_vs2_sel_pair_weight;
    rand int unsigned   valu0_vs3_sel_pair_weight;
    rand int unsigned   valu1_vs1_sel_pair_weight;
    rand int unsigned   valu1_vs2_sel_pair_weight;
    rand int unsigned   valu2_vs1_sel_pair_weight;
    rand int unsigned   valu2_vs2_sel_pair_weight;
    rand int unsigned   vsfu0_vs_sel_pair_weight;
    rand int unsigned   vsfu1_vs_sel_pair_weight;
    rand int unsigned   mexe_ms_sel_pair_weight;
    rand int unsigned   mexe_vs_sel_pair_weight;
    rand int unsigned   valu0_vm_sel_pair_dist[];
    rand int unsigned   valu1_vm_sel_pair_dist[];
    rand int unsigned   valu2_vm_sel_pair_dist[];
    // ===================== VU 寄存器读地址分类控制 =====================
    bit                         fix_reg_read_addr_cat_en=0;
    rand vu_reg_read_addr_cat_e reg_read_addr_cat;
    rand int unsigned           reg_read_addr_cat_dist[];
    bit                         fix_reg_read_addr_en=0;
    rand logic [31:0]           reg_read_addr;
    bit                         fix_reg_read_static_idx_en=0;
    rand logic [2:0]            reg_read_static_idx;
    rand int unsigned           align_addr_weight;
    // ===================== DSA 寄存器访问指令控制 =====================
    bit                 fix_inst_en=0;
    rand inst_e         inst;
    rand int unsigned   inst_dist[];
    // ===================== rs1/rs2 源数据控制 =====================
    bit                 fix_rs1_data_en=0;
    rand int unsigned   rs1_data;
    bit                 fix_rs2_data_en=0;
    rand int unsigned   rs2_data;
    // ===================== 立即数控制 =====================
    bit                 fix_imm_en=0;
    rand int unsigned   imm;
    // ===================== 时序控制 =====================
    rand int unsigned   first_delay;
    bit                 fix_vld_delay_en=0;
    rand int unsigned   vld_delay;
    rand int unsigned   vld_delay_dist[];
    // ===================== SRC bypass 控制 =====================
    bit                 fix_src_bypass_en=0;
    rand bit            src_bypass;
    rand int unsigned   src_bypass_weight;
    // ===================== NOP src_sel 控制 =====================
    bit                 nop_rand=0;
    // ===================== 其他 cfg group 随机写入 =====================
    rand bit            rand_other_group=0;
    // ===================== TYPE_VL.DATA_TYPE 控制 =====================
    rand int unsigned   vl_data_type_weight;
    // ===================== static 合法场景控制 =====================
    rand bit            static_must_legal;
    // ===================== 场景类型控制 =====================
    rand int unsigned   case_type_dist[];

    `uvm_object_utils_begin(inst_gen_config)
        `uvm_field_enum         (uvm_active_passive_enum,   is_active,      UVM_DEFAULT)
        `uvm_field_int          (checks_enable,                             UVM_DEFAULT) 
        `uvm_field_int          (coverage_enable,                           UVM_DEFAULT)
        `uvm_field_int          (inst_seq_length,                           UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (exe_num,                                   UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (exp_exe_num,                               UVM_DEFAULT | UVM_DEC)
        `uvm_field_array_int    (case_type_dist,                            UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_inst_type_en,                          UVM_DEFAULT)
        `uvm_field_enum         (inst_type_e,           inst_type,          UVM_DEFAULT)
        `uvm_field_array_int    (inst_type_dist,                            UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_mu_inst_type_en,                       UVM_DEFAULT)
        `uvm_field_enum         (mu_inst_type_e,        mu_inst_type,       UVM_DEFAULT)
        `uvm_field_array_int    (mu_inst_type_dist,                         UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_vu_inst_type_en,                       UVM_DEFAULT)
        `uvm_field_enum         (vu_inst_type_e,        vu_inst_type,       UVM_DEFAULT)
        `uvm_field_array_int    (vu_inst_type_dist,                         UVM_DEFAULT | UVM_DEC)
        `uvm_field_object       (cross_1_cfg,                                UVM_DEFAULT | UVM_DEC)
        `uvm_field_object       (cross_2_cfg,                                UVM_DEFAULT | UVM_DEC)
        `uvm_field_object       (cross_3_cfg,                                UVM_DEFAULT | UVM_DEC)
        `uvm_field_object       (cross_4_cfg,                                UVM_DEFAULT | UVM_DEC)
        `uvm_field_object       (cross_5_cfg,                                UVM_DEFAULT | UVM_DEC)
        `uvm_field_object       (cross_6_cfg,                                UVM_DEFAULT | UVM_DEC)
        `uvm_field_object       (cross_7_cfg,                                UVM_DEFAULT | UVM_DEC)
        `uvm_field_object       (cross_8_cfg,                                UVM_DEFAULT | UVM_DEC)
        `uvm_field_object       (cross_9_cfg,                                UVM_DEFAULT | UVM_DEC)
        `uvm_field_object       (cross_10_cfg,                                UVM_DEFAULT | UVM_DEC)
        `uvm_field_object       (cross_11_cfg,                                UVM_DEFAULT | UVM_DEC)

        `uvm_field_array_int    (lu_class_dist,                         UVM_DEFAULT | UVM_DEC)
        `uvm_field_array_int    (lu_c1_type_dist,                         UVM_DEFAULT | UVM_DEC)
        `uvm_field_array_int    (lu_c2_type_dist,                         UVM_DEFAULT | UVM_DEC)
        `uvm_field_array_int    (lu_c3_type_dist,                         UVM_DEFAULT | UVM_DEC)
        `uvm_field_array_int    (su_class_dist,                         UVM_DEFAULT | UVM_DEC)
        `uvm_field_array_int    (su_c1_type_dist,                         UVM_DEFAULT | UVM_DEC)
        `uvm_field_array_int    (su_c2_type_dist,                         UVM_DEFAULT | UVM_DEC)
        `uvm_field_array_int    (su_c3_type_dist,                         UVM_DEFAULT | UVM_DEC)
        `uvm_field_array_int    (valu0_class_dist,                         UVM_DEFAULT | UVM_DEC)
        `uvm_field_array_int    (valu0_c1_type_dist,                         UVM_DEFAULT | UVM_DEC)
        `uvm_field_array_int    (valu0_c2_type_dist,                         UVM_DEFAULT | UVM_DEC)
        `uvm_field_array_int    (valu0_c3_type_dist,                         UVM_DEFAULT | UVM_DEC)
        `uvm_field_array_int    (valu0_c4_type_dist,                         UVM_DEFAULT | UVM_DEC)
        `uvm_field_array_int    (valu0_c5_type_dist,                         UVM_DEFAULT | UVM_DEC)
        `uvm_field_array_int    (valu0_c6_type_dist,                         UVM_DEFAULT | UVM_DEC)
        `uvm_field_array_int    (valu0_c7_type_dist,                         UVM_DEFAULT | UVM_DEC)
        `uvm_field_array_int    (valu0_c8_type_dist,                         UVM_DEFAULT | UVM_DEC)
        `uvm_field_array_int    (valu0_c9_type_dist,                         UVM_DEFAULT | UVM_DEC)
        `uvm_field_array_int    (valu1_class_dist,                         UVM_DEFAULT | UVM_DEC)
        `uvm_field_array_int    (valu1_c1_type_dist,                         UVM_DEFAULT | UVM_DEC)
        `uvm_field_array_int    (valu1_c2_type_dist,                         UVM_DEFAULT | UVM_DEC)
        `uvm_field_array_int    (valu1_c3_type_dist,                         UVM_DEFAULT | UVM_DEC)
        `uvm_field_array_int    (valu1_c4_type_dist,                         UVM_DEFAULT | UVM_DEC)
        `uvm_field_array_int    (valu1_c5_type_dist,                         UVM_DEFAULT | UVM_DEC)
        `uvm_field_array_int    (valu1_c6_type_dist,                         UVM_DEFAULT | UVM_DEC)
        `uvm_field_array_int    (valu2_class_dist,                         UVM_DEFAULT | UVM_DEC)
        `uvm_field_array_int    (valu2_c1_type_dist,                         UVM_DEFAULT | UVM_DEC)
        `uvm_field_array_int    (valu2_c2_type_dist,                         UVM_DEFAULT | UVM_DEC)
        `uvm_field_array_int    (valu2_c3_type_dist,                         UVM_DEFAULT | UVM_DEC)
        `uvm_field_array_int    (valu2_c4_type_dist,                         UVM_DEFAULT | UVM_DEC)
        `uvm_field_array_int    (valu2_c5_type_dist,                         UVM_DEFAULT | UVM_DEC)
        `uvm_field_array_int    (vsfu0_c1_type_dist,                         UVM_DEFAULT | UVM_DEC)
        `uvm_field_array_int    (vsfu1_c1_type_dist,                         UVM_DEFAULT | UVM_DEC)
        `uvm_field_array_int    (mexe_class_dist,                         UVM_DEFAULT | UVM_DEC)
        `uvm_field_array_int    (mexe_c1_type_dist,                         UVM_DEFAULT | UVM_DEC)
        `uvm_field_array_int    (mexe_c2_type_dist,                         UVM_DEFAULT | UVM_DEC)
        `uvm_field_array_int    (mexe_c3_type_dist,                         UVM_DEFAULT | UVM_DEC)
        `uvm_field_array_int    (mexe_c4_type_dist,                         UVM_DEFAULT | UVM_DEC)
        `uvm_field_array_int    (sexe0_class_dist,                         UVM_DEFAULT | UVM_DEC)
        `uvm_field_array_int    (sexe0_c1_type_dist,                         UVM_DEFAULT | UVM_DEC)
        `uvm_field_array_int    (sexe0_c2_type_dist,                         UVM_DEFAULT | UVM_DEC)
        `uvm_field_array_int    (sexe1_class_dist,                         UVM_DEFAULT | UVM_DEC)
        `uvm_field_array_int    (sexe1_c1_type_dist,                         UVM_DEFAULT | UVM_DEC)
        `uvm_field_array_int    (sexe1_c2_type_dist,                         UVM_DEFAULT | UVM_DEC)
        `uvm_field_array_int    (sexe2_class_dist,                         UVM_DEFAULT | UVM_DEC)
        `uvm_field_array_int    (sexe2_c1_type_dist,                         UVM_DEFAULT | UVM_DEC)
        `uvm_field_array_int    (sexe2_c2_type_dist,                         UVM_DEFAULT | UVM_DEC)
        `uvm_field_array_int    (vd_exe_type_dist,                         UVM_DEFAULT | UVM_DEC)
        `uvm_field_array_int    (md_exe_type_dist,                         UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_lu_op_stride_run_en,                               UVM_DEFAULT)
        `uvm_field_int          (lu_op_stride_run,                                  UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_lu_op_stride_skip_en,                               UVM_DEFAULT)
        `uvm_field_int          (lu_op_stride_skip,                                  UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_macro_inst_trigger_config_idx_en,                               UVM_DEFAULT)
        `uvm_field_int          (macro_inst_trigger_config_idx,                                  UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_macro_inst_trigger_data_broadcast_en,                               UVM_DEFAULT)
        `uvm_field_int          (macro_inst_trigger_data_broadcast,                                  UVM_DEFAULT)
        `uvm_field_int          (fix_macro_inst_trigger_event_en_en,                               UVM_DEFAULT)
        `uvm_field_int          (macro_inst_trigger_event_en,                                  UVM_DEFAULT)
        `uvm_field_int          (fix_macro_inst_trigger_macro_inst_fence_en,                               UVM_DEFAULT)
        `uvm_field_int          (macro_inst_trigger_macro_inst_fence,                                  UVM_DEFAULT)
        `uvm_field_int          (fix_macro_inst_trigger_static_dynamic_mask_en,                               UVM_DEFAULT)
        `uvm_field_int          (macro_inst_trigger_static_dynamic_mask,                                  UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_macro_inst_trigger_stream_id_en,                               UVM_DEFAULT)
        `uvm_field_int          (macro_inst_trigger_stream_id,                                  UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_macro_inst_trigger_stream_id_override_en,                               UVM_DEFAULT)
        `uvm_field_int          (macro_inst_trigger_stream_id_override,                                  UVM_DEFAULT)
        `uvm_field_int          (fix_mask_op_valu0_mask_sel_en,                               UVM_DEFAULT)
        `uvm_field_int          (mask_op_valu0_mask_sel,                                  UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_mask_op_valu1_mask_sel_en,                               UVM_DEFAULT)
        `uvm_field_int          (mask_op_valu1_mask_sel,                                  UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_mask_op_valu2_mask_sel_en,                               UVM_DEFAULT)
        `uvm_field_int          (mask_op_valu2_mask_sel,                                  UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_mexe_op_src1_sel_en,                               UVM_DEFAULT)
        `uvm_field_int          (mexe_op_src1_sel,                                  UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_mexe_op_src2_sel_en,                               UVM_DEFAULT)
        `uvm_field_int          (mexe_op_src2_sel,                                  UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_prf_op_mrf_wt_src_en,                               UVM_DEFAULT)
        `uvm_field_int          (prf_op_mrf_wt_src,                                  UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_prf_op_srf_wt_en_en,                               UVM_DEFAULT)
        `uvm_field_int          (prf_op_srf_wt_en,                                  UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_prf_op_vrf_wt_p0_src_en,                               UVM_DEFAULT)
        `uvm_field_int          (prf_op_vrf_wt_p0_src,                                  UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_prf_op_vrf_wt_p1_src_en,                               UVM_DEFAULT)
        `uvm_field_int          (prf_op_vrf_wt_p1_src,                                  UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_sexe0_op_src1_sel_en,                               UVM_DEFAULT)
        `uvm_field_int          (sexe0_op_src1_sel,                                  UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_sexe0_op_src2_sel_en,                               UVM_DEFAULT)
        `uvm_field_int          (sexe0_op_src2_sel,                                  UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_sexe1_op_src1_sel_en,                               UVM_DEFAULT)
        `uvm_field_int          (sexe1_op_src1_sel,                                  UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_sexe1_op_src2_sel_en,                               UVM_DEFAULT)
        `uvm_field_int          (sexe1_op_src2_sel,                                  UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_sexe2_op_src1_sel_en,                               UVM_DEFAULT)
        `uvm_field_int          (sexe2_op_src1_sel,                                  UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_sexe2_op_src2_sel_en,                               UVM_DEFAULT)
        `uvm_field_int          (sexe2_op_src2_sel,                                  UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_static_ld_addr_cm_addr_en,                               UVM_DEFAULT)
        `uvm_field_int          (static_ld_addr_cm_addr,                                  UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_static_mrf_rd_index_mrf_rd_p0_idx_en,                               UVM_DEFAULT)
        `uvm_field_int          (static_mrf_rd_index_mrf_rd_p0_idx,                                  UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_static_mrf_rd_index_mrf_rd_p1_idx_en,                               UVM_DEFAULT)
        `uvm_field_int          (static_mrf_rd_index_mrf_rd_p1_idx,                                  UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_static_mrf_wt_index_mrf_wt_idx_en,                               UVM_DEFAULT)
        `uvm_field_int          (static_mrf_wt_index_mrf_wt_idx,                                  UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_static_srf_rd_index_0_srf_rd_p0_idx_en,                               UVM_DEFAULT)
        `uvm_field_int          (static_srf_rd_index_0_srf_rd_p0_idx,                                  UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_static_srf_rd_index_0_srf_rd_p1_idx_en,                               UVM_DEFAULT)
        `uvm_field_int          (static_srf_rd_index_0_srf_rd_p1_idx,                                  UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_static_srf_rd_index_0_srf_rd_p2_idx_en,                               UVM_DEFAULT)
        `uvm_field_int          (static_srf_rd_index_0_srf_rd_p2_idx,                                  UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_static_srf_rd_index_0_srf_rd_p3_idx_en,                               UVM_DEFAULT)
        `uvm_field_int          (static_srf_rd_index_0_srf_rd_p3_idx,                                  UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_static_srf_rd_index_1_srf_rd_p4_idx_en,                               UVM_DEFAULT)
        `uvm_field_int          (static_srf_rd_index_1_srf_rd_p4_idx,                                  UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_static_srf_rd_index_1_srf_rd_p5_idx_en,                               UVM_DEFAULT)
        `uvm_field_int          (static_srf_rd_index_1_srf_rd_p5_idx,                                  UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_static_srf_rd_index_1_srf_rd_p6_idx_en,                               UVM_DEFAULT)
        `uvm_field_int          (static_srf_rd_index_1_srf_rd_p6_idx,                                  UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_static_srf_rd_index_1_srf_rd_p7_idx_en,                               UVM_DEFAULT)
        `uvm_field_int          (static_srf_rd_index_1_srf_rd_p7_idx,                                  UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_static_srf_wt_index_0_srf_wt_p0_idx_en,                               UVM_DEFAULT)
        `uvm_field_int          (static_srf_wt_index_0_srf_wt_p0_idx,                                  UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_static_srf_wt_index_0_srf_wt_p1_idx_en,                               UVM_DEFAULT)
        `uvm_field_int          (static_srf_wt_index_0_srf_wt_p1_idx,                                  UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_static_srf_wt_index_0_srf_wt_p2_idx_en,                               UVM_DEFAULT)
        `uvm_field_int          (static_srf_wt_index_0_srf_wt_p2_idx,                                  UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_static_srf_wt_index_0_srf_wt_p3_idx_en,                               UVM_DEFAULT)
        `uvm_field_int          (static_srf_wt_index_0_srf_wt_p3_idx,                                  UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_static_srf_wt_index_1_srf_wt_p4_idx_en,                               UVM_DEFAULT)
        `uvm_field_int          (static_srf_wt_index_1_srf_wt_p4_idx,                                  UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_static_srf_wt_index_1_srf_wt_p5_idx_en,                               UVM_DEFAULT)
        `uvm_field_int          (static_srf_wt_index_1_srf_wt_p5_idx,                                  UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_static_st_addr_cm_addr_en,                               UVM_DEFAULT)
        `uvm_field_int          (static_st_addr_cm_addr,                                  UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_static_type_vl_data_type_en,                               UVM_DEFAULT)
        `uvm_field_int          (static_type_vl_data_type,                                  UVM_DEFAULT)
        `uvm_field_int          (fix_static_type_vl_round_mode_en,                               UVM_DEFAULT)
        `uvm_field_int          (static_type_vl_round_mode,                                  UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_static_type_vl_vl_en,                               UVM_DEFAULT)
        `uvm_field_int          (static_type_vl_vl,                                  UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_static_vrf_rd_index_vrf_rd_p0_idx_en,                               UVM_DEFAULT)
        `uvm_field_int          (static_vrf_rd_index_vrf_rd_p0_idx,                                  UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_static_vrf_rd_index_vrf_rd_p1_idx_en,                               UVM_DEFAULT)
        `uvm_field_int          (static_vrf_rd_index_vrf_rd_p1_idx,                                  UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_static_vrf_wt_index_vrf_wt_p0_idx_en,                               UVM_DEFAULT)
        `uvm_field_int          (static_vrf_wt_index_vrf_wt_p0_idx,                                  UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_static_vrf_wt_index_vrf_wt_p1_idx_en,                               UVM_DEFAULT)
        `uvm_field_int          (static_vrf_wt_index_vrf_wt_p1_idx,                                  UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_su_op_mxfp8_scale_round_en,                               UVM_DEFAULT)
        `uvm_field_int          (su_op_mxfp8_scale_round,                                  UVM_DEFAULT)
        `uvm_field_int          (fix_su_op_src_sel_en,                               UVM_DEFAULT)
        `uvm_field_int          (su_op_src_sel,                                  UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_valu0_op_src1_sel_en,                               UVM_DEFAULT)
        `uvm_field_int          (valu0_op_src1_sel,                                  UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_valu0_op_src2_sel_en,                               UVM_DEFAULT)
        `uvm_field_int          (valu0_op_src2_sel,                                  UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_valu0_op_src3_sel_en,                               UVM_DEFAULT)
        `uvm_field_int          (valu0_op_src3_sel,                                  UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_valu1_op_src1_sel_en,                               UVM_DEFAULT)
        `uvm_field_int          (valu1_op_src1_sel,                                  UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_valu1_op_src2_sel_en,                               UVM_DEFAULT)
        `uvm_field_int          (valu1_op_src2_sel,                                  UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_valu1_op_src3_sel_en,                               UVM_DEFAULT)
        `uvm_field_int          (valu1_op_src3_sel,                                  UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_valu2_op_src1_sel_en,                               UVM_DEFAULT)
        `uvm_field_int          (valu2_op_src1_sel,                                  UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_valu2_op_src2_sel_en,                               UVM_DEFAULT)
        `uvm_field_int          (valu2_op_src2_sel,                                  UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_valu2_op_src3_sel_en,                               UVM_DEFAULT)
        `uvm_field_int          (valu2_op_src3_sel,                                  UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_vsfu_op_vsfu0_src1_sel_en,                               UVM_DEFAULT)
        `uvm_field_int          (vsfu_op_vsfu0_src1_sel,                                  UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_vsfu_op_vsfu1_src1_sel_en,                               UVM_DEFAULT)
        `uvm_field_int          (vsfu_op_vsfu1_src1_sel,                                  UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_vrf_rw_eq_0_en,                               UVM_DEFAULT)
        `uvm_field_int          (vrf_rw_eq_0,                                  UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_vrf_rw_eq_1_en,                               UVM_DEFAULT)
        `uvm_field_int          (vrf_rw_eq_1,                                  UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_mrf_rw_eq_0_en,                               UVM_DEFAULT)
        `uvm_field_int          (mrf_rw_eq_0,                                  UVM_DEFAULT)
        `uvm_field_int          (fix_mrf_rw_eq_1_en,                               UVM_DEFAULT)
        `uvm_field_int          (mrf_rw_eq_1,                                  UVM_DEFAULT)
        `uvm_field_int          (fix_srf_rw_eq_0_en,                               UVM_DEFAULT)
        `uvm_field_int          (srf_rw_eq_0,                                  UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_srf_rw_eq_1_en,                               UVM_DEFAULT)
        `uvm_field_int          (srf_rw_eq_1,                                  UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_srf_rw_eq_2_en,                               UVM_DEFAULT)
        `uvm_field_int          (srf_rw_eq_2,                                  UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_srf_rw_eq_3_en,                               UVM_DEFAULT)
        `uvm_field_int          (srf_rw_eq_3,                                  UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_srf_rw_eq_4_en,                               UVM_DEFAULT)
        `uvm_field_int          (srf_rw_eq_4,                                  UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_srf_rw_eq_5_en,                               UVM_DEFAULT)
        `uvm_field_int          (srf_rw_eq_5,                                  UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_srf_rw_eq_6_en,                               UVM_DEFAULT)
        `uvm_field_int          (srf_rw_eq_6,                                  UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_srf_rw_eq_7_en,                               UVM_DEFAULT)
        `uvm_field_int          (srf_rw_eq_7,                                  UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (prf_op_vrf_wt_pair_weight,                  UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (su_vs_sel_pair_weight,                            UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (su_ms_sel_pair_weight,                            UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (valu0_vs1_sel_pair_weight,                            UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (valu0_vs2_sel_pair_weight,                            UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (valu0_vs3_sel_pair_weight,                            UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (valu1_vs1_sel_pair_weight,                            UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (valu1_vs2_sel_pair_weight,                            UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (valu2_vs1_sel_pair_weight,                            UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (valu2_vs2_sel_pair_weight,                            UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (vsfu0_vs_sel_pair_weight,                            UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (vsfu1_vs_sel_pair_weight,                            UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (mexe_ms_sel_pair_weight,                            UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (mexe_vs_sel_pair_weight,                            UVM_DEFAULT | UVM_DEC)
        `uvm_field_array_int    (valu0_vm_sel_pair_dist,                         UVM_DEFAULT | UVM_DEC)
        `uvm_field_array_int    (valu1_vm_sel_pair_dist,                         UVM_DEFAULT | UVM_DEC)
        `uvm_field_array_int    (valu2_vm_sel_pair_dist,                         UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_reg_read_addr_cat_en,                  UVM_DEFAULT)
        `uvm_field_enum         (vu_reg_read_addr_cat_e, reg_read_addr_cat, UVM_DEFAULT)
        `uvm_field_array_int    (reg_read_addr_cat_dist,                   UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_reg_read_addr_en,                      UVM_DEFAULT)
        `uvm_field_int          (reg_read_addr,                             UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_reg_read_static_idx_en,                UVM_DEFAULT)
        `uvm_field_int          (reg_read_static_idx,                       UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (align_addr_weight,                         UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_inst_en,                               UVM_DEFAULT)
        `uvm_field_enum         (inst_e,                inst,               UVM_DEFAULT)
        `uvm_field_array_int    (inst_dist,                                 UVM_DEFAULT | UVM_DEC)

        `uvm_field_int          (fix_rs1_data_en,                           UVM_DEFAULT)
        `uvm_field_int          (rs1_data,                                  UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_rs2_data_en,                           UVM_DEFAULT)
        `uvm_field_int          (rs2_data,                                  UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_imm_en,                                UVM_DEFAULT)
        `uvm_field_int          (imm,                                       UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_vld_delay_en,                          UVM_DEFAULT)
        `uvm_field_int          (vld_delay,                                 UVM_DEFAULT | UVM_DEC)
        `uvm_field_array_int    (vld_delay_dist,                            UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_src_bypass_en,                         UVM_DEFAULT)
        `uvm_field_int          (src_bypass,                                UVM_DEFAULT)
        `uvm_field_int          (src_bypass_weight,                         UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (nop_rand,                                  UVM_DEFAULT)
        `uvm_field_int          (rand_other_group,                          UVM_DEFAULT)
        `uvm_field_int          (vl_data_type_weight,                       UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (static_must_legal,                         UVM_DEFAULT)
    `uvm_object_utils_end
    
    function new (string name = "inst_gen_config");
        super.new(name);
        cross_1_cfg = cross_1_config::type_id::create("cross_1_cfg");
        cross_2_cfg = cross_2_config::type_id::create("cross_2_cfg");
        cross_3_cfg = cross_3_config::type_id::create("cross_3_cfg");
        cross_4_cfg = cross_4_config::type_id::create("cross_4_cfg");
        cross_5_cfg = cross_5_config::type_id::create("cross_5_cfg");
        cross_6_cfg = cross_6_config::type_id::create("cross_6_cfg");
        cross_7_cfg = cross_7_config::type_id::create("cross_7_cfg");
        cross_8_cfg = cross_8_config::type_id::create("cross_8_cfg");
        cross_9_cfg = cross_9_config::type_id::create("cross_9_cfg");
        cross_10_cfg = cross_10_config::type_id::create("cross_10_cfg");
        cross_11_cfg = cross_11_config::type_id::create("cross_11_cfg");
    endfunction : new

    // ===================== case_cfg 场景配置 =====================
    function void only_one_cross(int cross_idx);
        foreach (vu_inst_type_dist[i])
            vu_inst_type_dist[i] = (cross_idx == i + 1) ? 100 : 0;
        if (cross_idx < 1 || cross_idx > VU_INST_END)
            `uvm_fatal("inst_gen_config", $sformatf("only_one_cross: invalid cross_idx=%0d (valid: 1~%0d)", cross_idx, VU_INST_END))
    endfunction : only_one_cross

    // cross_idx: 1~VU_INST_END，锁定单一 vu_inst_type；bypass: 0/1 控制 src_bypass_weight(0/100)
    function void set_vu_scene(int cross_idx, bit bypass);
        only_one_cross(cross_idx);
        // CROSS_INST_1 无 bypass；CROSS_INST_11 必须 bypass
        if (cross_idx == 1 && bypass)
            `uvm_fatal("inst_gen_config", "set_vu_scene: CROSS_INST_1 does not support bypass")
        if (cross_idx == 11 && !bypass)
            `uvm_fatal("inst_gen_config", "set_vu_scene: CROSS_INST_11 requires bypass")
        src_bypass_weight = bypass ? 100 : 0;
    endfunction : set_vu_scene

    // ===================== OPCODE plusarg → type_dist =====================
    // 用法：+lu_op_opcode=0x01 或 +lu_op_opcode=VU_LU_C1_LD_FP8E4M3_V
    // cfg.randomize() 后的 post_randomize 会调用 get_opcode()，
    // 若有 +set_vu_scene=<cross_idx>,<bypass> 再调用 set_vu_scene
    protected function string toupper_str(string s);
        string r;
        r = s;
        foreach (r[i])
            if (r[i] >= "a" && r[i] <= "z")
                r[i] = r[i] - 8'h20;
        return r;
    endfunction : toupper_str

    protected function void pin_dist(ref int unsigned weights[], input int unsigned sel, input int unsigned n);
        if (weights.size() != n)
            weights = new[n];
        foreach (weights[i])
            weights[i] = (i == sel) ? 100 : 0;
    endfunction : pin_dist

    protected function bit parse_opcode_u8(string s, output logic [7:0] opc);
        string t;
        int i;
        t = s;
        if (t.len() >= 3 && (t.substr(0, 2) == "8'h" || t.substr(0, 2) == "8'H"))
            t = t.substr(3, t.len() - 1);
        else if (t.len() >= 2 && (t.substr(0, 1) == "0x" || t.substr(0, 1) == "0X"))
            t = t.substr(2, t.len() - 1);
        if (t.len() == 0)
            return 0;
        for (i = 0; i < t.len(); i++)
            if (!((t[i] >= "0" && t[i] <= "9") ||
                  (t[i] >= "a" && t[i] <= "f") ||
                  (t[i] >= "A" && t[i] <= "F")))
                return 0;
        return $sscanf(t, "%h", opc) == 1;
    endfunction : parse_opcode_u8

    protected function void pin_lu_op_opcode(string s);
        logic [7:0] opc;
        bit matched;
        string key;
        matched = 0;
        if (parse_opcode_u8(s, opc)) begin
            case (opc)
            8'h01: begin pin_dist(lu_class_dist, VU_LU_1_VD_ADDR, VU_LU_CLASS_END); pin_dist(lu_c1_type_dist, VU_LU_C1_LD_FP8E4M3_V, VU_LU_C1_TYPE_END); matched = 1; end
            8'h02: begin pin_dist(lu_class_dist, VU_LU_1_VD_ADDR, VU_LU_CLASS_END); pin_dist(lu_c1_type_dist, VU_LU_C1_LD_MXFP8_V, VU_LU_C1_TYPE_END); matched = 1; end
            8'h03: begin pin_dist(lu_class_dist, VU_LU_1_VD_ADDR, VU_LU_CLASS_END); pin_dist(lu_c1_type_dist, VU_LU_C1_LD_BF16_V, VU_LU_C1_TYPE_END); matched = 1; end
            8'h04: begin pin_dist(lu_class_dist, VU_LU_1_VD_ADDR, VU_LU_CLASS_END); pin_dist(lu_c1_type_dist, VU_LU_C1_LD_FP32_V, VU_LU_C1_TYPE_END); matched = 1; end
            8'h05: begin pin_dist(lu_class_dist, VU_LU_2_MD_ADDR, VU_LU_CLASS_END); pin_dist(lu_c2_type_dist, VU_LU_C2_LD_MASK, VU_LU_C2_TYPE_END); matched = 1; end
            8'h06: begin pin_dist(lu_class_dist, VU_LU_3_FD_ADDR, VU_LU_CLASS_END); pin_dist(lu_c3_type_dist, VU_LU_C3_LD_S_FP32, VU_LU_C3_TYPE_END); matched = 1; end
            endcase
        end else begin
            key = toupper_str(s);
            if (key == "VU_LU_C1_LD_FP8E4M3_V" || key == "VU_LU_LD_FP8E4M3_V" || key == "LD.FP8E4M3.V" || key == "LD_FP8E4M3_V") begin
                pin_dist(lu_class_dist, VU_LU_1_VD_ADDR, VU_LU_CLASS_END); pin_dist(lu_c1_type_dist, VU_LU_C1_LD_FP8E4M3_V, VU_LU_C1_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_LU_C1_LD_MXFP8_V" || key == "VU_LU_LD_MXFP8_V" || key == "LD.MXFP8.V" || key == "LD_MXFP8_V") begin
                pin_dist(lu_class_dist, VU_LU_1_VD_ADDR, VU_LU_CLASS_END); pin_dist(lu_c1_type_dist, VU_LU_C1_LD_MXFP8_V, VU_LU_C1_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_LU_C1_LD_BF16_V" || key == "VU_LU_LD_BF16_V" || key == "LD.BF16.V" || key == "LD_BF16_V") begin
                pin_dist(lu_class_dist, VU_LU_1_VD_ADDR, VU_LU_CLASS_END); pin_dist(lu_c1_type_dist, VU_LU_C1_LD_BF16_V, VU_LU_C1_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_LU_C1_LD_FP32_V" || key == "VU_LU_LD_FP32_V" || key == "LD.FP32.V" || key == "LD_FP32_V") begin
                pin_dist(lu_class_dist, VU_LU_1_VD_ADDR, VU_LU_CLASS_END); pin_dist(lu_c1_type_dist, VU_LU_C1_LD_FP32_V, VU_LU_C1_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_LU_C2_LD_MASK" || key == "VU_LU_LD_MASK" || key == "LD.MASK" || key == "LD_MASK") begin
                pin_dist(lu_class_dist, VU_LU_2_MD_ADDR, VU_LU_CLASS_END); pin_dist(lu_c2_type_dist, VU_LU_C2_LD_MASK, VU_LU_C2_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_LU_C3_LD_S_FP32" || key == "VU_LU_LD_S_FP32" || key == "LD.S.FP32" || key == "LD_S_FP32") begin
                pin_dist(lu_class_dist, VU_LU_3_FD_ADDR, VU_LU_CLASS_END); pin_dist(lu_c3_type_dist, VU_LU_C3_LD_S_FP32, VU_LU_C3_TYPE_END);
                matched = 1;
            end
        end
        if (!matched)
            `uvm_fatal("inst_gen_config", $sformatf("get_opcode: unknown lu_op_opcode plusarg '%s'", s));
    endfunction : pin_lu_op_opcode

    protected function void pin_mexe_op_opcode(string s);
        logic [7:0] opc;
        bit matched;
        string key;
        matched = 0;
        if (parse_opcode_u8(s, opc)) begin
            case (opc)
            8'h01: begin pin_dist(mexe_class_dist, VU_MEXE_1_MD_MS2_MS1, VU_MEXE_CLASS_END); pin_dist(mexe_c1_type_dist, VU_MEXE_C1_VMAND_MM, VU_MEXE_C1_TYPE_END); matched = 1; end
            8'h02: begin pin_dist(mexe_class_dist, VU_MEXE_1_MD_MS2_MS1, VU_MEXE_CLASS_END); pin_dist(mexe_c1_type_dist, VU_MEXE_C1_VMNAND_MM, VU_MEXE_C1_TYPE_END); matched = 1; end
            8'h03: begin pin_dist(mexe_class_dist, VU_MEXE_1_MD_MS2_MS1, VU_MEXE_CLASS_END); pin_dist(mexe_c1_type_dist, VU_MEXE_C1_VMANDN_MM, VU_MEXE_C1_TYPE_END); matched = 1; end
            8'h04: begin pin_dist(mexe_class_dist, VU_MEXE_1_MD_MS2_MS1, VU_MEXE_CLASS_END); pin_dist(mexe_c1_type_dist, VU_MEXE_C1_VMXOR_MM, VU_MEXE_C1_TYPE_END); matched = 1; end
            8'h05: begin pin_dist(mexe_class_dist, VU_MEXE_1_MD_MS2_MS1, VU_MEXE_CLASS_END); pin_dist(mexe_c1_type_dist, VU_MEXE_C1_VMOR_MM, VU_MEXE_C1_TYPE_END); matched = 1; end
            8'h06: begin pin_dist(mexe_class_dist, VU_MEXE_1_MD_MS2_MS1, VU_MEXE_CLASS_END); pin_dist(mexe_c1_type_dist, VU_MEXE_C1_VMNOR_MM, VU_MEXE_C1_TYPE_END); matched = 1; end
            8'h07: begin pin_dist(mexe_class_dist, VU_MEXE_1_MD_MS2_MS1, VU_MEXE_CLASS_END); pin_dist(mexe_c1_type_dist, VU_MEXE_C1_VMORN_MM, VU_MEXE_C1_TYPE_END); matched = 1; end
            8'h08: begin pin_dist(mexe_class_dist, VU_MEXE_1_MD_MS2_MS1, VU_MEXE_CLASS_END); pin_dist(mexe_c1_type_dist, VU_MEXE_C1_VMXNOR_MM, VU_MEXE_C1_TYPE_END); matched = 1; end
            8'h10: begin pin_dist(mexe_class_dist, VU_MEXE_2_FD_MS1, VU_MEXE_CLASS_END); pin_dist(mexe_c2_type_dist, VU_MEXE_C2_VCPOP_M, VU_MEXE_C2_TYPE_END); matched = 1; end
            8'h11: begin pin_dist(mexe_class_dist, VU_MEXE_2_FD_MS1, VU_MEXE_CLASS_END); pin_dist(mexe_c2_type_dist, VU_MEXE_C2_VFIRST_M, VU_MEXE_C2_TYPE_END); matched = 1; end
            8'h12: begin pin_dist(mexe_class_dist, VU_MEXE_3_MD_MS1, VU_MEXE_CLASS_END); pin_dist(mexe_c3_type_dist, VU_MEXE_C3_VMSBF_M, VU_MEXE_C3_TYPE_END); matched = 1; end
            8'h13: begin pin_dist(mexe_class_dist, VU_MEXE_3_MD_MS1, VU_MEXE_CLASS_END); pin_dist(mexe_c3_type_dist, VU_MEXE_C3_VMSIF_M, VU_MEXE_C3_TYPE_END); matched = 1; end
            8'h14: begin pin_dist(mexe_class_dist, VU_MEXE_3_MD_MS1, VU_MEXE_CLASS_END); pin_dist(mexe_c3_type_dist, VU_MEXE_C3_VMSOF_M, VU_MEXE_C3_TYPE_END); matched = 1; end
            8'h15: begin pin_dist(mexe_class_dist, VU_MEXE_4_MD_MS1_VS2, VU_MEXE_CLASS_END); pin_dist(mexe_c4_type_dist, VU_MEXE_C4_VMIUSET_MV, VU_MEXE_C4_TYPE_END); matched = 1; end
            8'h16: begin pin_dist(mexe_class_dist, VU_MEXE_4_MD_MS1_VS2, VU_MEXE_CLASS_END); pin_dist(mexe_c4_type_dist, VU_MEXE_C4_VMISET_MV, VU_MEXE_C4_TYPE_END); matched = 1; end
            endcase
        end else begin
            key = toupper_str(s);
            if (key == "VU_MEXE_C1_VMAND_MM" || key == "VU_MEXE_VMAND_MM" || key == "VMAND.MM" || key == "VMAND_MM") begin
                pin_dist(mexe_class_dist, VU_MEXE_1_MD_MS2_MS1, VU_MEXE_CLASS_END); pin_dist(mexe_c1_type_dist, VU_MEXE_C1_VMAND_MM, VU_MEXE_C1_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_MEXE_C1_VMNAND_MM" || key == "VU_MEXE_VMNAND_MM" || key == "VMNAND.MM" || key == "VMNAND_MM") begin
                pin_dist(mexe_class_dist, VU_MEXE_1_MD_MS2_MS1, VU_MEXE_CLASS_END); pin_dist(mexe_c1_type_dist, VU_MEXE_C1_VMNAND_MM, VU_MEXE_C1_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_MEXE_C1_VMANDN_MM" || key == "VU_MEXE_VMANDN_MM" || key == "VMANDN.MM" || key == "VMANDN_MM") begin
                pin_dist(mexe_class_dist, VU_MEXE_1_MD_MS2_MS1, VU_MEXE_CLASS_END); pin_dist(mexe_c1_type_dist, VU_MEXE_C1_VMANDN_MM, VU_MEXE_C1_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_MEXE_C1_VMXOR_MM" || key == "VU_MEXE_VMXOR_MM" || key == "VMXOR.MM" || key == "VMXOR_MM") begin
                pin_dist(mexe_class_dist, VU_MEXE_1_MD_MS2_MS1, VU_MEXE_CLASS_END); pin_dist(mexe_c1_type_dist, VU_MEXE_C1_VMXOR_MM, VU_MEXE_C1_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_MEXE_C1_VMOR_MM" || key == "VU_MEXE_VMOR_MM" || key == "VMOR.MM" || key == "VMOR_MM") begin
                pin_dist(mexe_class_dist, VU_MEXE_1_MD_MS2_MS1, VU_MEXE_CLASS_END); pin_dist(mexe_c1_type_dist, VU_MEXE_C1_VMOR_MM, VU_MEXE_C1_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_MEXE_C1_VMNOR_MM" || key == "VU_MEXE_VMNOR_MM" || key == "VMNOR.MM" || key == "VMNOR_MM") begin
                pin_dist(mexe_class_dist, VU_MEXE_1_MD_MS2_MS1, VU_MEXE_CLASS_END); pin_dist(mexe_c1_type_dist, VU_MEXE_C1_VMNOR_MM, VU_MEXE_C1_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_MEXE_C1_VMORN_MM" || key == "VU_MEXE_VMORN_MM" || key == "VMORN.MM" || key == "VMORN_MM") begin
                pin_dist(mexe_class_dist, VU_MEXE_1_MD_MS2_MS1, VU_MEXE_CLASS_END); pin_dist(mexe_c1_type_dist, VU_MEXE_C1_VMORN_MM, VU_MEXE_C1_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_MEXE_C1_VMXNOR_MM" || key == "VU_MEXE_VMXNOR_MM" || key == "VMXNOR.MM" || key == "VMXNOR_MM") begin
                pin_dist(mexe_class_dist, VU_MEXE_1_MD_MS2_MS1, VU_MEXE_CLASS_END); pin_dist(mexe_c1_type_dist, VU_MEXE_C1_VMXNOR_MM, VU_MEXE_C1_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_MEXE_C2_VCPOP_M" || key == "VU_MEXE_VCPOP_M" || key == "VCPOP.M" || key == "VCPOP_M") begin
                pin_dist(mexe_class_dist, VU_MEXE_2_FD_MS1, VU_MEXE_CLASS_END); pin_dist(mexe_c2_type_dist, VU_MEXE_C2_VCPOP_M, VU_MEXE_C2_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_MEXE_C2_VFIRST_M" || key == "VU_MEXE_VFIRST_M" || key == "VFIRST.M" || key == "VFIRST_M") begin
                pin_dist(mexe_class_dist, VU_MEXE_2_FD_MS1, VU_MEXE_CLASS_END); pin_dist(mexe_c2_type_dist, VU_MEXE_C2_VFIRST_M, VU_MEXE_C2_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_MEXE_C3_VMSBF_M" || key == "VU_MEXE_VMSBF_M" || key == "VMSBF.M" || key == "VMSBF_M") begin
                pin_dist(mexe_class_dist, VU_MEXE_3_MD_MS1, VU_MEXE_CLASS_END); pin_dist(mexe_c3_type_dist, VU_MEXE_C3_VMSBF_M, VU_MEXE_C3_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_MEXE_C3_VMSIF_M" || key == "VU_MEXE_VMSIF_M" || key == "VMSIF.M" || key == "VMSIF_M") begin
                pin_dist(mexe_class_dist, VU_MEXE_3_MD_MS1, VU_MEXE_CLASS_END); pin_dist(mexe_c3_type_dist, VU_MEXE_C3_VMSIF_M, VU_MEXE_C3_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_MEXE_C3_VMSOF_M" || key == "VU_MEXE_VMSOF_M" || key == "VMSOF.M" || key == "VMSOF_M") begin
                pin_dist(mexe_class_dist, VU_MEXE_3_MD_MS1, VU_MEXE_CLASS_END); pin_dist(mexe_c3_type_dist, VU_MEXE_C3_VMSOF_M, VU_MEXE_C3_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_MEXE_C4_VMIUSET_MV" || key == "VU_MEXE_VMIUSET_MV" || key == "VMIUSET.MV" || key == "VMIUSET_MV") begin
                pin_dist(mexe_class_dist, VU_MEXE_4_MD_MS1_VS2, VU_MEXE_CLASS_END); pin_dist(mexe_c4_type_dist, VU_MEXE_C4_VMIUSET_MV, VU_MEXE_C4_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_MEXE_C4_VMISET_MV" || key == "VU_MEXE_VMISET_MV" || key == "VMISET.MV" || key == "VMISET_MV") begin
                pin_dist(mexe_class_dist, VU_MEXE_4_MD_MS1_VS2, VU_MEXE_CLASS_END); pin_dist(mexe_c4_type_dist, VU_MEXE_C4_VMISET_MV, VU_MEXE_C4_TYPE_END);
                matched = 1;
            end
        end
        if (!matched)
            `uvm_fatal("inst_gen_config", $sformatf("get_opcode: unknown mexe_op_opcode plusarg '%s'", s));
    endfunction : pin_mexe_op_opcode

    protected function void pin_sexe0_op_opcode(string s);
        logic [7:0] opc;
        bit matched;
        string key;
        matched = 0;
        if (parse_opcode_u8(s, opc)) begin
            case (opc)
            8'h01: begin pin_dist(sexe0_class_dist, VU_SEXE0_1_FD_FS1_FS2, VU_SEXE0_CLASS_END); pin_dist(sexe0_c1_type_dist, VU_SEXE0_C1_FADD_S, VU_SEXE0_C1_TYPE_END); matched = 1; end
            8'h02: begin pin_dist(sexe0_class_dist, VU_SEXE0_1_FD_FS1_FS2, VU_SEXE0_CLASS_END); pin_dist(sexe0_c1_type_dist, VU_SEXE0_C1_FSUB_S, VU_SEXE0_C1_TYPE_END); matched = 1; end
            8'h03: begin pin_dist(sexe0_class_dist, VU_SEXE0_1_FD_FS1_FS2, VU_SEXE0_CLASS_END); pin_dist(sexe0_c1_type_dist, VU_SEXE0_C1_FMUL_S, VU_SEXE0_C1_TYPE_END); matched = 1; end
            8'h04: begin pin_dist(sexe0_class_dist, VU_SEXE0_1_FD_FS1_FS2, VU_SEXE0_CLASS_END); pin_dist(sexe0_c1_type_dist, VU_SEXE0_C1_FDIV_S, VU_SEXE0_C1_TYPE_END); matched = 1; end
            8'h05: begin pin_dist(sexe0_class_dist, VU_SEXE0_2_FD_FS1, VU_SEXE0_CLASS_END); pin_dist(sexe0_c2_type_dist, VU_SEXE0_C2_FSQRT_S, VU_SEXE0_C2_TYPE_END); matched = 1; end
            8'h06: begin pin_dist(sexe0_class_dist, VU_SEXE0_2_FD_FS1, VU_SEXE0_CLASS_END); pin_dist(sexe0_c2_type_dist, VU_SEXE0_C2_FRSQRT_S, VU_SEXE0_C2_TYPE_END); matched = 1; end
            8'h07: begin pin_dist(sexe0_class_dist, VU_SEXE0_2_FD_FS1, VU_SEXE0_CLASS_END); pin_dist(sexe0_c2_type_dist, VU_SEXE0_C2_FRCP_S, VU_SEXE0_C2_TYPE_END); matched = 1; end
            endcase
        end else begin
            key = toupper_str(s);
            if (key == "VU_SEXE0_C1_FADD_S" || key == "VU_SEXE0_FADD_S" || key == "FADD.S" || key == "FADD_S") begin
                pin_dist(sexe0_class_dist, VU_SEXE0_1_FD_FS1_FS2, VU_SEXE0_CLASS_END); pin_dist(sexe0_c1_type_dist, VU_SEXE0_C1_FADD_S, VU_SEXE0_C1_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_SEXE0_C1_FSUB_S" || key == "VU_SEXE0_FSUB_S" || key == "FSUB.S" || key == "FSUB_S") begin
                pin_dist(sexe0_class_dist, VU_SEXE0_1_FD_FS1_FS2, VU_SEXE0_CLASS_END); pin_dist(sexe0_c1_type_dist, VU_SEXE0_C1_FSUB_S, VU_SEXE0_C1_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_SEXE0_C1_FMUL_S" || key == "VU_SEXE0_FMUL_S" || key == "FMUL.S" || key == "FMUL_S") begin
                pin_dist(sexe0_class_dist, VU_SEXE0_1_FD_FS1_FS2, VU_SEXE0_CLASS_END); pin_dist(sexe0_c1_type_dist, VU_SEXE0_C1_FMUL_S, VU_SEXE0_C1_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_SEXE0_C1_FDIV_S" || key == "VU_SEXE0_FDIV_S" || key == "FDIV.S" || key == "FDIV_S") begin
                pin_dist(sexe0_class_dist, VU_SEXE0_1_FD_FS1_FS2, VU_SEXE0_CLASS_END); pin_dist(sexe0_c1_type_dist, VU_SEXE0_C1_FDIV_S, VU_SEXE0_C1_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_SEXE0_C2_FSQRT_S" || key == "VU_SEXE0_FSQRT_S" || key == "FSQRT.S" || key == "FSQRT_S") begin
                pin_dist(sexe0_class_dist, VU_SEXE0_2_FD_FS1, VU_SEXE0_CLASS_END); pin_dist(sexe0_c2_type_dist, VU_SEXE0_C2_FSQRT_S, VU_SEXE0_C2_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_SEXE0_C2_FRSQRT_S" || key == "VU_SEXE0_FRSQRT_S" || key == "FRSQRT.S" || key == "FRSQRT_S") begin
                pin_dist(sexe0_class_dist, VU_SEXE0_2_FD_FS1, VU_SEXE0_CLASS_END); pin_dist(sexe0_c2_type_dist, VU_SEXE0_C2_FRSQRT_S, VU_SEXE0_C2_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_SEXE0_C2_FRCP_S" || key == "VU_SEXE0_FRCP_S" || key == "FRCP.S" || key == "FRCP_S") begin
                pin_dist(sexe0_class_dist, VU_SEXE0_2_FD_FS1, VU_SEXE0_CLASS_END); pin_dist(sexe0_c2_type_dist, VU_SEXE0_C2_FRCP_S, VU_SEXE0_C2_TYPE_END);
                matched = 1;
            end
        end
        if (!matched)
            `uvm_fatal("inst_gen_config", $sformatf("get_opcode: unknown sexe0_op_opcode plusarg '%s'", s));
    endfunction : pin_sexe0_op_opcode

    protected function void pin_sexe1_op_opcode(string s);
        logic [7:0] opc;
        bit matched;
        string key;
        matched = 0;
        if (parse_opcode_u8(s, opc)) begin
            case (opc)
            8'h01: begin pin_dist(sexe1_class_dist, VU_SEXE1_1_FD_FS1_FS2, VU_SEXE1_CLASS_END); pin_dist(sexe1_c1_type_dist, VU_SEXE1_C1_FADD_S, VU_SEXE1_C1_TYPE_END); matched = 1; end
            8'h02: begin pin_dist(sexe1_class_dist, VU_SEXE1_1_FD_FS1_FS2, VU_SEXE1_CLASS_END); pin_dist(sexe1_c1_type_dist, VU_SEXE1_C1_FSUB_S, VU_SEXE1_C1_TYPE_END); matched = 1; end
            8'h03: begin pin_dist(sexe1_class_dist, VU_SEXE1_1_FD_FS1_FS2, VU_SEXE1_CLASS_END); pin_dist(sexe1_c1_type_dist, VU_SEXE1_C1_FMUL_S, VU_SEXE1_C1_TYPE_END); matched = 1; end
            8'h04: begin pin_dist(sexe1_class_dist, VU_SEXE1_1_FD_FS1_FS2, VU_SEXE1_CLASS_END); pin_dist(sexe1_c1_type_dist, VU_SEXE1_C1_FDIV_S, VU_SEXE1_C1_TYPE_END); matched = 1; end
            8'h05: begin pin_dist(sexe1_class_dist, VU_SEXE1_2_FD_FS1, VU_SEXE1_CLASS_END); pin_dist(sexe1_c2_type_dist, VU_SEXE1_C2_FSQRT_S, VU_SEXE1_C2_TYPE_END); matched = 1; end
            8'h06: begin pin_dist(sexe1_class_dist, VU_SEXE1_2_FD_FS1, VU_SEXE1_CLASS_END); pin_dist(sexe1_c2_type_dist, VU_SEXE1_C2_FRSQRT_S, VU_SEXE1_C2_TYPE_END); matched = 1; end
            8'h07: begin pin_dist(sexe1_class_dist, VU_SEXE1_2_FD_FS1, VU_SEXE1_CLASS_END); pin_dist(sexe1_c2_type_dist, VU_SEXE1_C2_FRCP_S, VU_SEXE1_C2_TYPE_END); matched = 1; end
            endcase
        end else begin
            key = toupper_str(s);
            if (key == "VU_SEXE1_C1_FADD_S" || key == "VU_SEXE0_FADD_S" || key == "FADD.S" || key == "FADD_S") begin
                pin_dist(sexe1_class_dist, VU_SEXE1_1_FD_FS1_FS2, VU_SEXE1_CLASS_END); pin_dist(sexe1_c1_type_dist, VU_SEXE1_C1_FADD_S, VU_SEXE1_C1_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_SEXE1_C1_FSUB_S" || key == "VU_SEXE0_FSUB_S" || key == "FSUB.S" || key == "FSUB_S") begin
                pin_dist(sexe1_class_dist, VU_SEXE1_1_FD_FS1_FS2, VU_SEXE1_CLASS_END); pin_dist(sexe1_c1_type_dist, VU_SEXE1_C1_FSUB_S, VU_SEXE1_C1_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_SEXE1_C1_FMUL_S" || key == "VU_SEXE0_FMUL_S" || key == "FMUL.S" || key == "FMUL_S") begin
                pin_dist(sexe1_class_dist, VU_SEXE1_1_FD_FS1_FS2, VU_SEXE1_CLASS_END); pin_dist(sexe1_c1_type_dist, VU_SEXE1_C1_FMUL_S, VU_SEXE1_C1_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_SEXE1_C1_FDIV_S" || key == "VU_SEXE0_FDIV_S" || key == "FDIV.S" || key == "FDIV_S") begin
                pin_dist(sexe1_class_dist, VU_SEXE1_1_FD_FS1_FS2, VU_SEXE1_CLASS_END); pin_dist(sexe1_c1_type_dist, VU_SEXE1_C1_FDIV_S, VU_SEXE1_C1_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_SEXE1_C2_FSQRT_S" || key == "VU_SEXE0_FSQRT_S" || key == "FSQRT.S" || key == "FSQRT_S") begin
                pin_dist(sexe1_class_dist, VU_SEXE1_2_FD_FS1, VU_SEXE1_CLASS_END); pin_dist(sexe1_c2_type_dist, VU_SEXE1_C2_FSQRT_S, VU_SEXE1_C2_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_SEXE1_C2_FRSQRT_S" || key == "VU_SEXE0_FRSQRT_S" || key == "FRSQRT.S" || key == "FRSQRT_S") begin
                pin_dist(sexe1_class_dist, VU_SEXE1_2_FD_FS1, VU_SEXE1_CLASS_END); pin_dist(sexe1_c2_type_dist, VU_SEXE1_C2_FRSQRT_S, VU_SEXE1_C2_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_SEXE1_C2_FRCP_S" || key == "VU_SEXE0_FRCP_S" || key == "FRCP.S" || key == "FRCP_S") begin
                pin_dist(sexe1_class_dist, VU_SEXE1_2_FD_FS1, VU_SEXE1_CLASS_END); pin_dist(sexe1_c2_type_dist, VU_SEXE1_C2_FRCP_S, VU_SEXE1_C2_TYPE_END);
                matched = 1;
            end
        end
        if (!matched)
            `uvm_fatal("inst_gen_config", $sformatf("get_opcode: unknown sexe1_op_opcode plusarg '%s'", s));
    endfunction : pin_sexe1_op_opcode

    protected function void pin_sexe2_op_opcode(string s);
        logic [7:0] opc;
        bit matched;
        string key;
        matched = 0;
        if (parse_opcode_u8(s, opc)) begin
            case (opc)
            8'h01: begin pin_dist(sexe2_class_dist, VU_SEXE2_1_FD_FS1_FS2, VU_SEXE2_CLASS_END); pin_dist(sexe2_c1_type_dist, VU_SEXE2_C1_FADD_S, VU_SEXE2_C1_TYPE_END); matched = 1; end
            8'h02: begin pin_dist(sexe2_class_dist, VU_SEXE2_1_FD_FS1_FS2, VU_SEXE2_CLASS_END); pin_dist(sexe2_c1_type_dist, VU_SEXE2_C1_FSUB_S, VU_SEXE2_C1_TYPE_END); matched = 1; end
            8'h03: begin pin_dist(sexe2_class_dist, VU_SEXE2_1_FD_FS1_FS2, VU_SEXE2_CLASS_END); pin_dist(sexe2_c1_type_dist, VU_SEXE2_C1_FMUL_S, VU_SEXE2_C1_TYPE_END); matched = 1; end
            8'h04: begin pin_dist(sexe2_class_dist, VU_SEXE2_1_FD_FS1_FS2, VU_SEXE2_CLASS_END); pin_dist(sexe2_c1_type_dist, VU_SEXE2_C1_FDIV_S, VU_SEXE2_C1_TYPE_END); matched = 1; end
            8'h05: begin pin_dist(sexe2_class_dist, VU_SEXE2_2_FD_FS1, VU_SEXE2_CLASS_END); pin_dist(sexe2_c2_type_dist, VU_SEXE2_C2_FSQRT_S, VU_SEXE2_C2_TYPE_END); matched = 1; end
            8'h06: begin pin_dist(sexe2_class_dist, VU_SEXE2_2_FD_FS1, VU_SEXE2_CLASS_END); pin_dist(sexe2_c2_type_dist, VU_SEXE2_C2_FRSQRT_S, VU_SEXE2_C2_TYPE_END); matched = 1; end
            8'h07: begin pin_dist(sexe2_class_dist, VU_SEXE2_2_FD_FS1, VU_SEXE2_CLASS_END); pin_dist(sexe2_c2_type_dist, VU_SEXE2_C2_FRCP_S, VU_SEXE2_C2_TYPE_END); matched = 1; end
            endcase
        end else begin
            key = toupper_str(s);
            if (key == "VU_SEXE2_C1_FADD_S" || key == "VU_SEXE0_FADD_S" || key == "FADD.S" || key == "FADD_S") begin
                pin_dist(sexe2_class_dist, VU_SEXE2_1_FD_FS1_FS2, VU_SEXE2_CLASS_END); pin_dist(sexe2_c1_type_dist, VU_SEXE2_C1_FADD_S, VU_SEXE2_C1_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_SEXE2_C1_FSUB_S" || key == "VU_SEXE0_FSUB_S" || key == "FSUB.S" || key == "FSUB_S") begin
                pin_dist(sexe2_class_dist, VU_SEXE2_1_FD_FS1_FS2, VU_SEXE2_CLASS_END); pin_dist(sexe2_c1_type_dist, VU_SEXE2_C1_FSUB_S, VU_SEXE2_C1_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_SEXE2_C1_FMUL_S" || key == "VU_SEXE0_FMUL_S" || key == "FMUL.S" || key == "FMUL_S") begin
                pin_dist(sexe2_class_dist, VU_SEXE2_1_FD_FS1_FS2, VU_SEXE2_CLASS_END); pin_dist(sexe2_c1_type_dist, VU_SEXE2_C1_FMUL_S, VU_SEXE2_C1_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_SEXE2_C1_FDIV_S" || key == "VU_SEXE0_FDIV_S" || key == "FDIV.S" || key == "FDIV_S") begin
                pin_dist(sexe2_class_dist, VU_SEXE2_1_FD_FS1_FS2, VU_SEXE2_CLASS_END); pin_dist(sexe2_c1_type_dist, VU_SEXE2_C1_FDIV_S, VU_SEXE2_C1_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_SEXE2_C2_FSQRT_S" || key == "VU_SEXE0_FSQRT_S" || key == "FSQRT.S" || key == "FSQRT_S") begin
                pin_dist(sexe2_class_dist, VU_SEXE2_2_FD_FS1, VU_SEXE2_CLASS_END); pin_dist(sexe2_c2_type_dist, VU_SEXE2_C2_FSQRT_S, VU_SEXE2_C2_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_SEXE2_C2_FRSQRT_S" || key == "VU_SEXE0_FRSQRT_S" || key == "FRSQRT.S" || key == "FRSQRT_S") begin
                pin_dist(sexe2_class_dist, VU_SEXE2_2_FD_FS1, VU_SEXE2_CLASS_END); pin_dist(sexe2_c2_type_dist, VU_SEXE2_C2_FRSQRT_S, VU_SEXE2_C2_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_SEXE2_C2_FRCP_S" || key == "VU_SEXE0_FRCP_S" || key == "FRCP.S" || key == "FRCP_S") begin
                pin_dist(sexe2_class_dist, VU_SEXE2_2_FD_FS1, VU_SEXE2_CLASS_END); pin_dist(sexe2_c2_type_dist, VU_SEXE2_C2_FRCP_S, VU_SEXE2_C2_TYPE_END);
                matched = 1;
            end
        end
        if (!matched)
            `uvm_fatal("inst_gen_config", $sformatf("get_opcode: unknown sexe2_op_opcode plusarg '%s'", s));
    endfunction : pin_sexe2_op_opcode

    protected function void pin_su_op_opcode(string s);
        logic [7:0] opc;
        bit matched;
        string key;
        matched = 0;
        if (parse_opcode_u8(s, opc)) begin
            case (opc)
            8'h01: begin pin_dist(su_class_dist, VU_SU_1_VS_ADDR, VU_SU_CLASS_END); pin_dist(su_c1_type_dist, VU_SU_C1_ST_FP8E4M3_V, VU_SU_C1_TYPE_END); matched = 1; end
            8'h02: begin pin_dist(su_class_dist, VU_SU_1_VS_ADDR, VU_SU_CLASS_END); pin_dist(su_c1_type_dist, VU_SU_C1_ST_MXFP8_V, VU_SU_C1_TYPE_END); matched = 1; end
            8'h03: begin pin_dist(su_class_dist, VU_SU_1_VS_ADDR, VU_SU_CLASS_END); pin_dist(su_c1_type_dist, VU_SU_C1_ST_BF16_V, VU_SU_C1_TYPE_END); matched = 1; end
            8'h04: begin pin_dist(su_class_dist, VU_SU_1_VS_ADDR, VU_SU_CLASS_END); pin_dist(su_c1_type_dist, VU_SU_C1_ST_FP32_V, VU_SU_C1_TYPE_END); matched = 1; end
            8'h05: begin pin_dist(su_class_dist, VU_SU_2_MS_ADDR, VU_SU_CLASS_END); pin_dist(su_c2_type_dist, VU_SU_C2_ST_MASK, VU_SU_C2_TYPE_END); matched = 1; end
            8'h06: begin pin_dist(su_class_dist, VU_SU_3_FS_ADDR, VU_SU_CLASS_END); pin_dist(su_c3_type_dist, VU_SU_C3_ST_S_FP32, VU_SU_C3_TYPE_END); matched = 1; end
            endcase
        end else begin
            key = toupper_str(s);
            if (key == "VU_SU_C1_ST_FP8E4M3_V" || key == "VU_SU_ST_FP8E4M3_V" || key == "ST.FP8E4M3.V" || key == "ST_FP8E4M3_V") begin
                pin_dist(su_class_dist, VU_SU_1_VS_ADDR, VU_SU_CLASS_END); pin_dist(su_c1_type_dist, VU_SU_C1_ST_FP8E4M3_V, VU_SU_C1_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_SU_C1_ST_MXFP8_V" || key == "VU_SU_ST_MXFP8_V" || key == "ST.MXFP8.V" || key == "ST_MXFP8_V") begin
                pin_dist(su_class_dist, VU_SU_1_VS_ADDR, VU_SU_CLASS_END); pin_dist(su_c1_type_dist, VU_SU_C1_ST_MXFP8_V, VU_SU_C1_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_SU_C1_ST_BF16_V" || key == "VU_SU_ST_BF16_V" || key == "ST.BF16.V" || key == "ST_BF16_V") begin
                pin_dist(su_class_dist, VU_SU_1_VS_ADDR, VU_SU_CLASS_END); pin_dist(su_c1_type_dist, VU_SU_C1_ST_BF16_V, VU_SU_C1_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_SU_C1_ST_FP32_V" || key == "VU_SU_ST_FP32_V" || key == "ST.FP32.V" || key == "ST_FP32_V") begin
                pin_dist(su_class_dist, VU_SU_1_VS_ADDR, VU_SU_CLASS_END); pin_dist(su_c1_type_dist, VU_SU_C1_ST_FP32_V, VU_SU_C1_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_SU_C2_ST_MASK" || key == "VU_SU_ST_MASK" || key == "ST.MASK" || key == "ST_MASK") begin
                pin_dist(su_class_dist, VU_SU_2_MS_ADDR, VU_SU_CLASS_END); pin_dist(su_c2_type_dist, VU_SU_C2_ST_MASK, VU_SU_C2_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_SU_C3_ST_S_FP32" || key == "VU_SU_ST_S_FP32" || key == "ST.S.FP32" || key == "ST_S_FP32") begin
                pin_dist(su_class_dist, VU_SU_3_FS_ADDR, VU_SU_CLASS_END); pin_dist(su_c3_type_dist, VU_SU_C3_ST_S_FP32, VU_SU_C3_TYPE_END);
                matched = 1;
            end
        end
        if (!matched)
            `uvm_fatal("inst_gen_config", $sformatf("get_opcode: unknown su_op_opcode plusarg '%s'", s));
    endfunction : pin_su_op_opcode

    protected function void pin_valu0_op_opcode(string s);
        logic [7:0] opc;
        bit matched;
        string key;
        matched = 0;
        if (parse_opcode_u8(s, opc)) begin
            case (opc)
            8'h01: begin pin_dist(valu0_class_dist, VU_VALU0_1_VD_VS2_VS1_VM, VU_VALU0_CLASS_END); pin_dist(valu0_c1_type_dist, VU_VALU0_C1_VFADD_VV, VU_VALU0_C1_TYPE_END); matched = 1; end
            8'h03: begin pin_dist(valu0_class_dist, VU_VALU0_1_VD_VS2_VS1_VM, VU_VALU0_CLASS_END); pin_dist(valu0_c1_type_dist, VU_VALU0_C1_VFSUB_VV, VU_VALU0_C1_TYPE_END); matched = 1; end
            8'h06: begin pin_dist(valu0_class_dist, VU_VALU0_1_VD_VS2_VS1_VM, VU_VALU0_CLASS_END); pin_dist(valu0_c1_type_dist, VU_VALU0_C1_VFMUL_VV, VU_VALU0_C1_TYPE_END); matched = 1; end
            8'h08: begin pin_dist(valu0_class_dist, VU_VALU0_1_VD_VS2_VS1_VM, VU_VALU0_CLASS_END); pin_dist(valu0_c1_type_dist, VU_VALU0_C1_VFDIV_VV, VU_VALU0_C1_TYPE_END); matched = 1; end
            8'h10: begin pin_dist(valu0_class_dist, VU_VALU0_1_VD_VS2_VS1_VM, VU_VALU0_CLASS_END); pin_dist(valu0_c1_type_dist, VU_VALU0_C1_VFMIN_VV, VU_VALU0_C1_TYPE_END); matched = 1; end
            8'h12: begin pin_dist(valu0_class_dist, VU_VALU0_1_VD_VS2_VS1_VM, VU_VALU0_CLASS_END); pin_dist(valu0_c1_type_dist, VU_VALU0_C1_VFMAX_VV, VU_VALU0_C1_TYPE_END); matched = 1; end
            8'h40: begin pin_dist(valu0_class_dist, VU_VALU0_1_VD_VS2_VS1_VM, VU_VALU0_CLASS_END); pin_dist(valu0_c1_type_dist, VU_VALU0_C1_VFSGNJ_VV, VU_VALU0_C1_TYPE_END); matched = 1; end
            8'h42: begin pin_dist(valu0_class_dist, VU_VALU0_1_VD_VS2_VS1_VM, VU_VALU0_CLASS_END); pin_dist(valu0_c1_type_dist, VU_VALU0_C1_VFSGNJN_VV, VU_VALU0_C1_TYPE_END); matched = 1; end
            8'h44: begin pin_dist(valu0_class_dist, VU_VALU0_1_VD_VS2_VS1_VM, VU_VALU0_CLASS_END); pin_dist(valu0_c1_type_dist, VU_VALU0_C1_VFSGNJX_VV, VU_VALU0_C1_TYPE_END); matched = 1; end
            8'h62: begin pin_dist(valu0_class_dist, VU_VALU0_1_VD_VS2_VS1_VM, VU_VALU0_CLASS_END); pin_dist(valu0_c1_type_dist, VU_VALU0_C1_VFMERGE_VVM, VU_VALU0_C1_TYPE_END); matched = 1; end
            8'h02: begin pin_dist(valu0_class_dist, VU_VALU0_2_VD_VS2_FS1_VM, VU_VALU0_CLASS_END); pin_dist(valu0_c2_type_dist, VU_VALU0_C2_VFADD_VF, VU_VALU0_C2_TYPE_END); matched = 1; end
            8'h04: begin pin_dist(valu0_class_dist, VU_VALU0_2_VD_VS2_FS1_VM, VU_VALU0_CLASS_END); pin_dist(valu0_c2_type_dist, VU_VALU0_C2_VFSUB_VF, VU_VALU0_C2_TYPE_END); matched = 1; end
            8'h05: begin pin_dist(valu0_class_dist, VU_VALU0_2_VD_VS2_FS1_VM, VU_VALU0_CLASS_END); pin_dist(valu0_c2_type_dist, VU_VALU0_C2_VFRSUB_VF, VU_VALU0_C2_TYPE_END); matched = 1; end
            8'h07: begin pin_dist(valu0_class_dist, VU_VALU0_2_VD_VS2_FS1_VM, VU_VALU0_CLASS_END); pin_dist(valu0_c2_type_dist, VU_VALU0_C2_VFMUL_VF, VU_VALU0_C2_TYPE_END); matched = 1; end
            8'h11: begin pin_dist(valu0_class_dist, VU_VALU0_2_VD_VS2_FS1_VM, VU_VALU0_CLASS_END); pin_dist(valu0_c2_type_dist, VU_VALU0_C2_VFMIN_VF, VU_VALU0_C2_TYPE_END); matched = 1; end
            8'h13: begin pin_dist(valu0_class_dist, VU_VALU0_2_VD_VS2_FS1_VM, VU_VALU0_CLASS_END); pin_dist(valu0_c2_type_dist, VU_VALU0_C2_VFMAX_VF, VU_VALU0_C2_TYPE_END); matched = 1; end
            8'h41: begin pin_dist(valu0_class_dist, VU_VALU0_2_VD_VS2_FS1_VM, VU_VALU0_CLASS_END); pin_dist(valu0_c2_type_dist, VU_VALU0_C2_VFSGNJ_VF, VU_VALU0_C2_TYPE_END); matched = 1; end
            8'h43: begin pin_dist(valu0_class_dist, VU_VALU0_2_VD_VS2_FS1_VM, VU_VALU0_CLASS_END); pin_dist(valu0_c2_type_dist, VU_VALU0_C2_VFSGNJN_VF, VU_VALU0_C2_TYPE_END); matched = 1; end
            8'h45: begin pin_dist(valu0_class_dist, VU_VALU0_2_VD_VS2_FS1_VM, VU_VALU0_CLASS_END); pin_dist(valu0_c2_type_dist, VU_VALU0_C2_VFSGNJX_VF, VU_VALU0_C2_TYPE_END); matched = 1; end
            8'h61: begin pin_dist(valu0_class_dist, VU_VALU0_2_VD_VS2_FS1_VM, VU_VALU0_CLASS_END); pin_dist(valu0_c2_type_dist, VU_VALU0_C2_VFMERGE_VFM, VU_VALU0_C2_TYPE_END); matched = 1; end
            8'h20: begin pin_dist(valu0_class_dist, VU_VALU0_3_VD_FS1, VU_VALU0_CLASS_END); pin_dist(valu0_c3_type_dist, VU_VALU0_C3_VFMV_V_F, VU_VALU0_C3_TYPE_END); matched = 1; end
            8'h21: begin pin_dist(valu0_class_dist, VU_VALU0_4_VD_FS1_IMM, VU_VALU0_CLASS_END); pin_dist(valu0_c4_type_dist, VU_VALU0_C4_VFMV_S_F, VU_VALU0_C4_TYPE_END); matched = 1; end
            8'h30: begin pin_dist(valu0_class_dist, VU_VALU0_5_VD_VS3_VS1_VS2_VM, VU_VALU0_CLASS_END); pin_dist(valu0_c5_type_dist, VU_VALU0_C5_VFMACC_VV, VU_VALU0_C5_TYPE_END); matched = 1; end
            8'h32: begin pin_dist(valu0_class_dist, VU_VALU0_5_VD_VS3_VS1_VS2_VM, VU_VALU0_CLASS_END); pin_dist(valu0_c5_type_dist, VU_VALU0_C5_VFNMACC_VV, VU_VALU0_C5_TYPE_END); matched = 1; end
            8'h34: begin pin_dist(valu0_class_dist, VU_VALU0_5_VD_VS3_VS1_VS2_VM, VU_VALU0_CLASS_END); pin_dist(valu0_c5_type_dist, VU_VALU0_C5_VFMSAC_VV, VU_VALU0_C5_TYPE_END); matched = 1; end
            8'h36: begin pin_dist(valu0_class_dist, VU_VALU0_5_VD_VS3_VS1_VS2_VM, VU_VALU0_CLASS_END); pin_dist(valu0_c5_type_dist, VU_VALU0_C5_VFNMSAC_VV, VU_VALU0_C5_TYPE_END); matched = 1; end
            8'h31: begin pin_dist(valu0_class_dist, VU_VALU0_6_VD_VS3_FS1_VS2_VM, VU_VALU0_CLASS_END); pin_dist(valu0_c6_type_dist, VU_VALU0_C6_VFMACC_VF, VU_VALU0_C6_TYPE_END); matched = 1; end
            8'h33: begin pin_dist(valu0_class_dist, VU_VALU0_6_VD_VS3_FS1_VS2_VM, VU_VALU0_CLASS_END); pin_dist(valu0_c6_type_dist, VU_VALU0_C6_VFNMACC_VF, VU_VALU0_C6_TYPE_END); matched = 1; end
            8'h35: begin pin_dist(valu0_class_dist, VU_VALU0_6_VD_VS3_FS1_VS2_VM, VU_VALU0_CLASS_END); pin_dist(valu0_c6_type_dist, VU_VALU0_C6_VFMSAC_VF, VU_VALU0_C6_TYPE_END); matched = 1; end
            8'h37: begin pin_dist(valu0_class_dist, VU_VALU0_6_VD_VS3_FS1_VS2_VM, VU_VALU0_CLASS_END); pin_dist(valu0_c6_type_dist, VU_VALU0_C6_VFNMSAC_VF, VU_VALU0_C6_TYPE_END); matched = 1; end
            8'h50: begin pin_dist(valu0_class_dist, VU_VALU0_7_MD_VS2_VS1_VM, VU_VALU0_CLASS_END); pin_dist(valu0_c7_type_dist, VU_VALU0_C7_VMFEQ_VV, VU_VALU0_C7_TYPE_END); matched = 1; end
            8'h52: begin pin_dist(valu0_class_dist, VU_VALU0_7_MD_VS2_VS1_VM, VU_VALU0_CLASS_END); pin_dist(valu0_c7_type_dist, VU_VALU0_C7_VMFNE_VV, VU_VALU0_C7_TYPE_END); matched = 1; end
            8'h54: begin pin_dist(valu0_class_dist, VU_VALU0_7_MD_VS2_VS1_VM, VU_VALU0_CLASS_END); pin_dist(valu0_c7_type_dist, VU_VALU0_C7_VMFLT_VV, VU_VALU0_C7_TYPE_END); matched = 1; end
            8'h56: begin pin_dist(valu0_class_dist, VU_VALU0_7_MD_VS2_VS1_VM, VU_VALU0_CLASS_END); pin_dist(valu0_c7_type_dist, VU_VALU0_C7_VMFLE_VV, VU_VALU0_C7_TYPE_END); matched = 1; end
            8'h51: begin pin_dist(valu0_class_dist, VU_VALU0_8_MD_VS2_FS1_VM, VU_VALU0_CLASS_END); pin_dist(valu0_c8_type_dist, VU_VALU0_C8_VMFEQ_VF, VU_VALU0_C8_TYPE_END); matched = 1; end
            8'h53: begin pin_dist(valu0_class_dist, VU_VALU0_8_MD_VS2_FS1_VM, VU_VALU0_CLASS_END); pin_dist(valu0_c8_type_dist, VU_VALU0_C8_VMFNE_VF, VU_VALU0_C8_TYPE_END); matched = 1; end
            8'h55: begin pin_dist(valu0_class_dist, VU_VALU0_8_MD_VS2_FS1_VM, VU_VALU0_CLASS_END); pin_dist(valu0_c8_type_dist, VU_VALU0_C8_VMFLT_VF, VU_VALU0_C8_TYPE_END); matched = 1; end
            8'h57: begin pin_dist(valu0_class_dist, VU_VALU0_8_MD_VS2_FS1_VM, VU_VALU0_CLASS_END); pin_dist(valu0_c8_type_dist, VU_VALU0_C8_VMFLE_VF, VU_VALU0_C8_TYPE_END); matched = 1; end
            8'h58: begin pin_dist(valu0_class_dist, VU_VALU0_8_MD_VS2_FS1_VM, VU_VALU0_CLASS_END); pin_dist(valu0_c8_type_dist, VU_VALU0_C8_VMFGT_VF, VU_VALU0_C8_TYPE_END); matched = 1; end
            8'h59: begin pin_dist(valu0_class_dist, VU_VALU0_8_MD_VS2_FS1_VM, VU_VALU0_CLASS_END); pin_dist(valu0_c8_type_dist, VU_VALU0_C8_VMFGE_VF, VU_VALU0_C8_TYPE_END); matched = 1; end
            8'h60: begin pin_dist(valu0_class_dist, VU_VALU0_9_MD_VS1_VM_IMM, VU_VALU0_CLASS_END); pin_dist(valu0_c9_type_dist, VU_VALU0_C9_VFCLASS_MV, VU_VALU0_C9_TYPE_END); matched = 1; end
            endcase
        end else begin
            key = toupper_str(s);
            if (key == "VU_VALU0_C1_VFADD_VV" || key == "VU_VALU0_VFADD_VV" || key == "VFADD.VV" || key == "VFADD_VV") begin
                pin_dist(valu0_class_dist, VU_VALU0_1_VD_VS2_VS1_VM, VU_VALU0_CLASS_END); pin_dist(valu0_c1_type_dist, VU_VALU0_C1_VFADD_VV, VU_VALU0_C1_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_VALU0_C1_VFSUB_VV" || key == "VU_VALU0_VFSUB_VV" || key == "VFSUB.VV" || key == "VFSUB_VV") begin
                pin_dist(valu0_class_dist, VU_VALU0_1_VD_VS2_VS1_VM, VU_VALU0_CLASS_END); pin_dist(valu0_c1_type_dist, VU_VALU0_C1_VFSUB_VV, VU_VALU0_C1_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_VALU0_C1_VFMUL_VV" || key == "VU_VALU0_VFMUL_VV" || key == "VFMUL.VV" || key == "VFMUL_VV") begin
                pin_dist(valu0_class_dist, VU_VALU0_1_VD_VS2_VS1_VM, VU_VALU0_CLASS_END); pin_dist(valu0_c1_type_dist, VU_VALU0_C1_VFMUL_VV, VU_VALU0_C1_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_VALU0_C1_VFDIV_VV" || key == "VU_VALU0_VFDIV_VV" || key == "VFDIV.VV" || key == "VFDIV_VV") begin
                pin_dist(valu0_class_dist, VU_VALU0_1_VD_VS2_VS1_VM, VU_VALU0_CLASS_END); pin_dist(valu0_c1_type_dist, VU_VALU0_C1_VFDIV_VV, VU_VALU0_C1_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_VALU0_C1_VFMIN_VV" || key == "VU_VALU0_VFMIN_VV" || key == "VFMIN.VV" || key == "VFMIN_VV") begin
                pin_dist(valu0_class_dist, VU_VALU0_1_VD_VS2_VS1_VM, VU_VALU0_CLASS_END); pin_dist(valu0_c1_type_dist, VU_VALU0_C1_VFMIN_VV, VU_VALU0_C1_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_VALU0_C1_VFMAX_VV" || key == "VU_VALU0_VFMAX_VV" || key == "VFMAX.VV" || key == "VFMAX_VV") begin
                pin_dist(valu0_class_dist, VU_VALU0_1_VD_VS2_VS1_VM, VU_VALU0_CLASS_END); pin_dist(valu0_c1_type_dist, VU_VALU0_C1_VFMAX_VV, VU_VALU0_C1_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_VALU0_C1_VFSGNJ_VV" || key == "VU_VALU0_VFSGNJ_VV" || key == "VFSGNJ.VV" || key == "VFSGNJ_VV") begin
                pin_dist(valu0_class_dist, VU_VALU0_1_VD_VS2_VS1_VM, VU_VALU0_CLASS_END); pin_dist(valu0_c1_type_dist, VU_VALU0_C1_VFSGNJ_VV, VU_VALU0_C1_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_VALU0_C1_VFSGNJN_VV" || key == "VU_VALU0_VFSGNJN_VV" || key == "VFSGNJN.VV" || key == "VFSGNJN_VV") begin
                pin_dist(valu0_class_dist, VU_VALU0_1_VD_VS2_VS1_VM, VU_VALU0_CLASS_END); pin_dist(valu0_c1_type_dist, VU_VALU0_C1_VFSGNJN_VV, VU_VALU0_C1_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_VALU0_C1_VFSGNJX_VV" || key == "VU_VALU0_VFSGNJX_VV" || key == "VFSGNJX.VV" || key == "VFSGNJX_VV") begin
                pin_dist(valu0_class_dist, VU_VALU0_1_VD_VS2_VS1_VM, VU_VALU0_CLASS_END); pin_dist(valu0_c1_type_dist, VU_VALU0_C1_VFSGNJX_VV, VU_VALU0_C1_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_VALU0_C1_VFMERGE_VVM" || key == "VU_VALU0_VFMERGE_VVM" || key == "VFMERGE.VVM" || key == "VFMERGE_VVM") begin
                pin_dist(valu0_class_dist, VU_VALU0_1_VD_VS2_VS1_VM, VU_VALU0_CLASS_END); pin_dist(valu0_c1_type_dist, VU_VALU0_C1_VFMERGE_VVM, VU_VALU0_C1_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_VALU0_C2_VFADD_VF" || key == "VU_VALU0_VFADD_VF" || key == "VFADD.VF" || key == "VFADD_VF") begin
                pin_dist(valu0_class_dist, VU_VALU0_2_VD_VS2_FS1_VM, VU_VALU0_CLASS_END); pin_dist(valu0_c2_type_dist, VU_VALU0_C2_VFADD_VF, VU_VALU0_C2_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_VALU0_C2_VFSUB_VF" || key == "VU_VALU0_VFSUB_VF" || key == "VFSUB.VF" || key == "VFSUB_VF") begin
                pin_dist(valu0_class_dist, VU_VALU0_2_VD_VS2_FS1_VM, VU_VALU0_CLASS_END); pin_dist(valu0_c2_type_dist, VU_VALU0_C2_VFSUB_VF, VU_VALU0_C2_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_VALU0_C2_VFRSUB_VF" || key == "VU_VALU0_VFRSUB_VF" || key == "VFRSUB.VF" || key == "VFRSUB_VF") begin
                pin_dist(valu0_class_dist, VU_VALU0_2_VD_VS2_FS1_VM, VU_VALU0_CLASS_END); pin_dist(valu0_c2_type_dist, VU_VALU0_C2_VFRSUB_VF, VU_VALU0_C2_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_VALU0_C2_VFMUL_VF" || key == "VU_VALU0_VFMUL_VF" || key == "VFMUL.VF" || key == "VFMUL_VF") begin
                pin_dist(valu0_class_dist, VU_VALU0_2_VD_VS2_FS1_VM, VU_VALU0_CLASS_END); pin_dist(valu0_c2_type_dist, VU_VALU0_C2_VFMUL_VF, VU_VALU0_C2_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_VALU0_C2_VFMIN_VF" || key == "VU_VALU0_VFMIN_VF" || key == "VFMIN.VF" || key == "VFMIN_VF") begin
                pin_dist(valu0_class_dist, VU_VALU0_2_VD_VS2_FS1_VM, VU_VALU0_CLASS_END); pin_dist(valu0_c2_type_dist, VU_VALU0_C2_VFMIN_VF, VU_VALU0_C2_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_VALU0_C2_VFMAX_VF" || key == "VU_VALU0_VFMAX_VF" || key == "VFMAX.VF" || key == "VFMAX_VF") begin
                pin_dist(valu0_class_dist, VU_VALU0_2_VD_VS2_FS1_VM, VU_VALU0_CLASS_END); pin_dist(valu0_c2_type_dist, VU_VALU0_C2_VFMAX_VF, VU_VALU0_C2_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_VALU0_C2_VFSGNJ_VF" || key == "VU_VALU0_VFSGNJ_VF" || key == "VFSGNJ.VF" || key == "VFSGNJ_VF") begin
                pin_dist(valu0_class_dist, VU_VALU0_2_VD_VS2_FS1_VM, VU_VALU0_CLASS_END); pin_dist(valu0_c2_type_dist, VU_VALU0_C2_VFSGNJ_VF, VU_VALU0_C2_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_VALU0_C2_VFSGNJN_VF" || key == "VU_VALU0_VFSGNJN_VF" || key == "VFSGNJN.VF" || key == "VFSGNJN_VF") begin
                pin_dist(valu0_class_dist, VU_VALU0_2_VD_VS2_FS1_VM, VU_VALU0_CLASS_END); pin_dist(valu0_c2_type_dist, VU_VALU0_C2_VFSGNJN_VF, VU_VALU0_C2_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_VALU0_C2_VFSGNJX_VF" || key == "VU_VALU0_VFSGNJX_VF" || key == "VFSGNJX.VF" || key == "VFSGNJX_VF") begin
                pin_dist(valu0_class_dist, VU_VALU0_2_VD_VS2_FS1_VM, VU_VALU0_CLASS_END); pin_dist(valu0_c2_type_dist, VU_VALU0_C2_VFSGNJX_VF, VU_VALU0_C2_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_VALU0_C2_VFMERGE_VFM" || key == "VU_VALU0_VFMERGE_VFM" || key == "VFMERGE.VFM" || key == "VFMERGE_VFM") begin
                pin_dist(valu0_class_dist, VU_VALU0_2_VD_VS2_FS1_VM, VU_VALU0_CLASS_END); pin_dist(valu0_c2_type_dist, VU_VALU0_C2_VFMERGE_VFM, VU_VALU0_C2_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_VALU0_C3_VFMV_V_F" || key == "VU_VALU0_VFMV_V_F" || key == "VFMV.V.F" || key == "VFMV_V_F") begin
                pin_dist(valu0_class_dist, VU_VALU0_3_VD_FS1, VU_VALU0_CLASS_END); pin_dist(valu0_c3_type_dist, VU_VALU0_C3_VFMV_V_F, VU_VALU0_C3_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_VALU0_C4_VFMV_S_F" || key == "VU_VALU0_VFMV_S_F" || key == "VFMV.S.F" || key == "VFMV_S_F") begin
                pin_dist(valu0_class_dist, VU_VALU0_4_VD_FS1_IMM, VU_VALU0_CLASS_END); pin_dist(valu0_c4_type_dist, VU_VALU0_C4_VFMV_S_F, VU_VALU0_C4_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_VALU0_C5_VFMACC_VV" || key == "VU_VALU0_VFMACC_VV" || key == "VFMACC.VV" || key == "VFMACC_VV") begin
                pin_dist(valu0_class_dist, VU_VALU0_5_VD_VS3_VS1_VS2_VM, VU_VALU0_CLASS_END); pin_dist(valu0_c5_type_dist, VU_VALU0_C5_VFMACC_VV, VU_VALU0_C5_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_VALU0_C5_VFNMACC_VV" || key == "VU_VALU0_VFNMACC_VV" || key == "VFNMACC.VV" || key == "VFNMACC_VV") begin
                pin_dist(valu0_class_dist, VU_VALU0_5_VD_VS3_VS1_VS2_VM, VU_VALU0_CLASS_END); pin_dist(valu0_c5_type_dist, VU_VALU0_C5_VFNMACC_VV, VU_VALU0_C5_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_VALU0_C5_VFMSAC_VV" || key == "VU_VALU0_VFMSAC_VV" || key == "VFMSAC.VV" || key == "VFMSAC_VV") begin
                pin_dist(valu0_class_dist, VU_VALU0_5_VD_VS3_VS1_VS2_VM, VU_VALU0_CLASS_END); pin_dist(valu0_c5_type_dist, VU_VALU0_C5_VFMSAC_VV, VU_VALU0_C5_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_VALU0_C5_VFNMSAC_VV" || key == "VU_VALU0_VFNMSAC_VV" || key == "VFNMSAC.VV" || key == "VFNMSAC_VV") begin
                pin_dist(valu0_class_dist, VU_VALU0_5_VD_VS3_VS1_VS2_VM, VU_VALU0_CLASS_END); pin_dist(valu0_c5_type_dist, VU_VALU0_C5_VFNMSAC_VV, VU_VALU0_C5_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_VALU0_C6_VFMACC_VF" || key == "VU_VALU0_VFMACC_VF" || key == "VFMACC.VF" || key == "VFMACC_VF") begin
                pin_dist(valu0_class_dist, VU_VALU0_6_VD_VS3_FS1_VS2_VM, VU_VALU0_CLASS_END); pin_dist(valu0_c6_type_dist, VU_VALU0_C6_VFMACC_VF, VU_VALU0_C6_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_VALU0_C6_VFNMACC_VF" || key == "VU_VALU0_VFNMACC_VF" || key == "VFNMACC.VF" || key == "VFNMACC_VF") begin
                pin_dist(valu0_class_dist, VU_VALU0_6_VD_VS3_FS1_VS2_VM, VU_VALU0_CLASS_END); pin_dist(valu0_c6_type_dist, VU_VALU0_C6_VFNMACC_VF, VU_VALU0_C6_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_VALU0_C6_VFMSAC_VF" || key == "VU_VALU0_VFMSAC_VF" || key == "VFMSAC.VF" || key == "VFMSAC_VF") begin
                pin_dist(valu0_class_dist, VU_VALU0_6_VD_VS3_FS1_VS2_VM, VU_VALU0_CLASS_END); pin_dist(valu0_c6_type_dist, VU_VALU0_C6_VFMSAC_VF, VU_VALU0_C6_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_VALU0_C6_VFNMSAC_VF" || key == "VU_VALU0_VFNMSAC_VF" || key == "VFNMSAC.VF" || key == "VFNMSAC_VF") begin
                pin_dist(valu0_class_dist, VU_VALU0_6_VD_VS3_FS1_VS2_VM, VU_VALU0_CLASS_END); pin_dist(valu0_c6_type_dist, VU_VALU0_C6_VFNMSAC_VF, VU_VALU0_C6_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_VALU0_C7_VMFEQ_VV" || key == "VU_VALU0_VMFEQ_VV" || key == "VMFEQ.VV" || key == "VMFEQ_VV") begin
                pin_dist(valu0_class_dist, VU_VALU0_7_MD_VS2_VS1_VM, VU_VALU0_CLASS_END); pin_dist(valu0_c7_type_dist, VU_VALU0_C7_VMFEQ_VV, VU_VALU0_C7_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_VALU0_C7_VMFNE_VV" || key == "VU_VALU0_VMFNE_VV" || key == "VMFNE.VV" || key == "VMFNE_VV") begin
                pin_dist(valu0_class_dist, VU_VALU0_7_MD_VS2_VS1_VM, VU_VALU0_CLASS_END); pin_dist(valu0_c7_type_dist, VU_VALU0_C7_VMFNE_VV, VU_VALU0_C7_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_VALU0_C7_VMFLT_VV" || key == "VU_VALU0_VMFLT_VV" || key == "VMFLT.VV" || key == "VMFLT_VV") begin
                pin_dist(valu0_class_dist, VU_VALU0_7_MD_VS2_VS1_VM, VU_VALU0_CLASS_END); pin_dist(valu0_c7_type_dist, VU_VALU0_C7_VMFLT_VV, VU_VALU0_C7_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_VALU0_C7_VMFLE_VV" || key == "VU_VALU0_VMFLE_VV" || key == "VMFLE.VV" || key == "VMFLE_VV") begin
                pin_dist(valu0_class_dist, VU_VALU0_7_MD_VS2_VS1_VM, VU_VALU0_CLASS_END); pin_dist(valu0_c7_type_dist, VU_VALU0_C7_VMFLE_VV, VU_VALU0_C7_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_VALU0_C8_VMFEQ_VF" || key == "VU_VALU0_VMFEQ_VF" || key == "VMFEQ.VF" || key == "VMFEQ_VF") begin
                pin_dist(valu0_class_dist, VU_VALU0_8_MD_VS2_FS1_VM, VU_VALU0_CLASS_END); pin_dist(valu0_c8_type_dist, VU_VALU0_C8_VMFEQ_VF, VU_VALU0_C8_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_VALU0_C8_VMFNE_VF" || key == "VU_VALU0_VMFNE_VF" || key == "VMFNE.VF" || key == "VMFNE_VF") begin
                pin_dist(valu0_class_dist, VU_VALU0_8_MD_VS2_FS1_VM, VU_VALU0_CLASS_END); pin_dist(valu0_c8_type_dist, VU_VALU0_C8_VMFNE_VF, VU_VALU0_C8_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_VALU0_C8_VMFLT_VF" || key == "VU_VALU0_VMFLT_VF" || key == "VMFLT.VF" || key == "VMFLT_VF") begin
                pin_dist(valu0_class_dist, VU_VALU0_8_MD_VS2_FS1_VM, VU_VALU0_CLASS_END); pin_dist(valu0_c8_type_dist, VU_VALU0_C8_VMFLT_VF, VU_VALU0_C8_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_VALU0_C8_VMFLE_VF" || key == "VU_VALU0_VMFLE_VF" || key == "VMFLE.VF" || key == "VMFLE_VF") begin
                pin_dist(valu0_class_dist, VU_VALU0_8_MD_VS2_FS1_VM, VU_VALU0_CLASS_END); pin_dist(valu0_c8_type_dist, VU_VALU0_C8_VMFLE_VF, VU_VALU0_C8_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_VALU0_C8_VMFGT_VF" || key == "VU_VALU0_VMFGT_VF" || key == "VMFGT.VF" || key == "VMFGT_VF") begin
                pin_dist(valu0_class_dist, VU_VALU0_8_MD_VS2_FS1_VM, VU_VALU0_CLASS_END); pin_dist(valu0_c8_type_dist, VU_VALU0_C8_VMFGT_VF, VU_VALU0_C8_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_VALU0_C8_VMFGE_VF" || key == "VU_VALU0_VMFGE_VF" || key == "VMFGE.VF" || key == "VMFGE_VF") begin
                pin_dist(valu0_class_dist, VU_VALU0_8_MD_VS2_FS1_VM, VU_VALU0_CLASS_END); pin_dist(valu0_c8_type_dist, VU_VALU0_C8_VMFGE_VF, VU_VALU0_C8_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_VALU0_C9_VFCLASS_MV" || key == "VU_VALU0_VFCLASS_MV" || key == "VFCLASS.MV" || key == "VFCLASS_MV") begin
                pin_dist(valu0_class_dist, VU_VALU0_9_MD_VS1_VM_IMM, VU_VALU0_CLASS_END); pin_dist(valu0_c9_type_dist, VU_VALU0_C9_VFCLASS_MV, VU_VALU0_C9_TYPE_END);
                matched = 1;
            end
        end
        if (!matched)
            `uvm_fatal("inst_gen_config", $sformatf("get_opcode: unknown valu0_op_opcode plusarg '%s'", s));
    endfunction : pin_valu0_op_opcode

    protected function void pin_valu1_op_opcode(string s);
        logic [7:0] opc;
        bit matched;
        string key;
        matched = 0;
        if (parse_opcode_u8(s, opc)) begin
            case (opc)
            8'h01: begin pin_dist(valu1_class_dist, VU_VALU1_1_VD_VS2_VS1_VM, VU_VALU1_CLASS_END); pin_dist(valu1_c1_type_dist, VU_VALU1_C1_VFADD_VV, VU_VALU1_C1_TYPE_END); matched = 1; end
            8'h03: begin pin_dist(valu1_class_dist, VU_VALU1_1_VD_VS2_VS1_VM, VU_VALU1_CLASS_END); pin_dist(valu1_c1_type_dist, VU_VALU1_C1_VFSUB_VV, VU_VALU1_C1_TYPE_END); matched = 1; end
            8'h06: begin pin_dist(valu1_class_dist, VU_VALU1_1_VD_VS2_VS1_VM, VU_VALU1_CLASS_END); pin_dist(valu1_c1_type_dist, VU_VALU1_C1_VFMUL_VV, VU_VALU1_C1_TYPE_END); matched = 1; end
            8'h10: begin pin_dist(valu1_class_dist, VU_VALU1_1_VD_VS2_VS1_VM, VU_VALU1_CLASS_END); pin_dist(valu1_c1_type_dist, VU_VALU1_C1_VFMIN_VV, VU_VALU1_C1_TYPE_END); matched = 1; end
            8'h12: begin pin_dist(valu1_class_dist, VU_VALU1_1_VD_VS2_VS1_VM, VU_VALU1_CLASS_END); pin_dist(valu1_c1_type_dist, VU_VALU1_C1_VFMAX_VV, VU_VALU1_C1_TYPE_END); matched = 1; end
            8'h02: begin pin_dist(valu1_class_dist, VU_VALU1_2_VD_VS2_FS1_VM, VU_VALU1_CLASS_END); pin_dist(valu1_c2_type_dist, VU_VALU1_C2_VFADD_VF, VU_VALU1_C2_TYPE_END); matched = 1; end
            8'h04: begin pin_dist(valu1_class_dist, VU_VALU1_2_VD_VS2_FS1_VM, VU_VALU1_CLASS_END); pin_dist(valu1_c2_type_dist, VU_VALU1_C2_VFSUB_VF, VU_VALU1_C2_TYPE_END); matched = 1; end
            8'h05: begin pin_dist(valu1_class_dist, VU_VALU1_2_VD_VS2_FS1_VM, VU_VALU1_CLASS_END); pin_dist(valu1_c2_type_dist, VU_VALU1_C2_VFRSUB_VF, VU_VALU1_C2_TYPE_END); matched = 1; end
            8'h07: begin pin_dist(valu1_class_dist, VU_VALU1_2_VD_VS2_FS1_VM, VU_VALU1_CLASS_END); pin_dist(valu1_c2_type_dist, VU_VALU1_C2_VFMUL_VF, VU_VALU1_C2_TYPE_END); matched = 1; end
            8'h11: begin pin_dist(valu1_class_dist, VU_VALU1_2_VD_VS2_FS1_VM, VU_VALU1_CLASS_END); pin_dist(valu1_c2_type_dist, VU_VALU1_C2_VFMIN_VF, VU_VALU1_C2_TYPE_END); matched = 1; end
            8'h13: begin pin_dist(valu1_class_dist, VU_VALU1_2_VD_VS2_FS1_VM, VU_VALU1_CLASS_END); pin_dist(valu1_c2_type_dist, VU_VALU1_C2_VFMAX_VF, VU_VALU1_C2_TYPE_END); matched = 1; end
            8'h20: begin pin_dist(valu1_class_dist, VU_VALU1_3_VD_FS1, VU_VALU1_CLASS_END); pin_dist(valu1_c3_type_dist, VU_VALU1_C3_VFMV_V_F, VU_VALU1_C3_TYPE_END); matched = 1; end
            8'h22: begin pin_dist(valu1_class_dist, VU_VALU1_4_FD_VS1_IMM, VU_VALU1_CLASS_END); pin_dist(valu1_c4_type_dist, VU_VALU1_C4_VFMV_F_S, VU_VALU1_C4_TYPE_END); matched = 1; end
            8'h70: begin pin_dist(valu1_class_dist, VU_VALU1_5_FD_VS2_FS1_VM, VU_VALU1_CLASS_END); pin_dist(valu1_c5_type_dist, VU_VALU1_C5_VFREDUSUM_VS, VU_VALU1_C5_TYPE_END); matched = 1; end
            8'h71: begin pin_dist(valu1_class_dist, VU_VALU1_5_FD_VS2_FS1_VM, VU_VALU1_CLASS_END); pin_dist(valu1_c5_type_dist, VU_VALU1_C5_VFREDMAX_VS, VU_VALU1_C5_TYPE_END); matched = 1; end
            8'h72: begin pin_dist(valu1_class_dist, VU_VALU1_5_FD_VS2_FS1_VM, VU_VALU1_CLASS_END); pin_dist(valu1_c5_type_dist, VU_VALU1_C5_VFREDMIN_VS, VU_VALU1_C5_TYPE_END); matched = 1; end
            8'h73: begin pin_dist(valu1_class_dist, VU_VALU1_6_VD_VS1_VM, VU_VALU1_CLASS_END); pin_dist(valu1_c6_type_dist, VU_VALU1_C6_VSORTMAX16_V, VU_VALU1_C6_TYPE_END); matched = 1; end
            8'h74: begin pin_dist(valu1_class_dist, VU_VALU1_6_VD_VS1_VM, VU_VALU1_CLASS_END); pin_dist(valu1_c6_type_dist, VU_VALU1_C6_VSORTMIN16_V, VU_VALU1_C6_TYPE_END); matched = 1; end
            endcase
        end else begin
            key = toupper_str(s);
            if (key == "VU_VALU1_C1_VFADD_VV" || key == "VU_VALU1_VFADD_VV" || key == "VFADD.VV" || key == "VFADD_VV") begin
                pin_dist(valu1_class_dist, VU_VALU1_1_VD_VS2_VS1_VM, VU_VALU1_CLASS_END); pin_dist(valu1_c1_type_dist, VU_VALU1_C1_VFADD_VV, VU_VALU1_C1_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_VALU1_C1_VFSUB_VV" || key == "VU_VALU1_VFSUB_VV" || key == "VFSUB.VV" || key == "VFSUB_VV") begin
                pin_dist(valu1_class_dist, VU_VALU1_1_VD_VS2_VS1_VM, VU_VALU1_CLASS_END); pin_dist(valu1_c1_type_dist, VU_VALU1_C1_VFSUB_VV, VU_VALU1_C1_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_VALU1_C1_VFMUL_VV" || key == "VU_VALU1_VFMUL_VV" || key == "VFMUL.VV" || key == "VFMUL_VV") begin
                pin_dist(valu1_class_dist, VU_VALU1_1_VD_VS2_VS1_VM, VU_VALU1_CLASS_END); pin_dist(valu1_c1_type_dist, VU_VALU1_C1_VFMUL_VV, VU_VALU1_C1_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_VALU1_C1_VFMIN_VV" || key == "VU_VALU1_VFMIN_VV" || key == "VFMIN.VV" || key == "VFMIN_VV") begin
                pin_dist(valu1_class_dist, VU_VALU1_1_VD_VS2_VS1_VM, VU_VALU1_CLASS_END); pin_dist(valu1_c1_type_dist, VU_VALU1_C1_VFMIN_VV, VU_VALU1_C1_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_VALU1_C1_VFMAX_VV" || key == "VU_VALU1_VFMAX_VV" || key == "VFMAX.VV" || key == "VFMAX_VV") begin
                pin_dist(valu1_class_dist, VU_VALU1_1_VD_VS2_VS1_VM, VU_VALU1_CLASS_END); pin_dist(valu1_c1_type_dist, VU_VALU1_C1_VFMAX_VV, VU_VALU1_C1_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_VALU1_C2_VFADD_VF" || key == "VU_VALU1_VFADD_VF" || key == "VFADD.VF" || key == "VFADD_VF") begin
                pin_dist(valu1_class_dist, VU_VALU1_2_VD_VS2_FS1_VM, VU_VALU1_CLASS_END); pin_dist(valu1_c2_type_dist, VU_VALU1_C2_VFADD_VF, VU_VALU1_C2_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_VALU1_C2_VFSUB_VF" || key == "VU_VALU1_VFSUB_VF" || key == "VFSUB.VF" || key == "VFSUB_VF") begin
                pin_dist(valu1_class_dist, VU_VALU1_2_VD_VS2_FS1_VM, VU_VALU1_CLASS_END); pin_dist(valu1_c2_type_dist, VU_VALU1_C2_VFSUB_VF, VU_VALU1_C2_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_VALU1_C2_VFRSUB_VF" || key == "VU_VALU1_VFRSUB_VF" || key == "VFRSUB.VF" || key == "VFRSUB_VF") begin
                pin_dist(valu1_class_dist, VU_VALU1_2_VD_VS2_FS1_VM, VU_VALU1_CLASS_END); pin_dist(valu1_c2_type_dist, VU_VALU1_C2_VFRSUB_VF, VU_VALU1_C2_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_VALU1_C2_VFMUL_VF" || key == "VU_VALU1_VFMUL_VF" || key == "VFMUL.VF" || key == "VFMUL_VF") begin
                pin_dist(valu1_class_dist, VU_VALU1_2_VD_VS2_FS1_VM, VU_VALU1_CLASS_END); pin_dist(valu1_c2_type_dist, VU_VALU1_C2_VFMUL_VF, VU_VALU1_C2_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_VALU1_C2_VFMIN_VF" || key == "VU_VALU1_VFMIN_VF" || key == "VFMIN.VF" || key == "VFMIN_VF") begin
                pin_dist(valu1_class_dist, VU_VALU1_2_VD_VS2_FS1_VM, VU_VALU1_CLASS_END); pin_dist(valu1_c2_type_dist, VU_VALU1_C2_VFMIN_VF, VU_VALU1_C2_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_VALU1_C2_VFMAX_VF" || key == "VU_VALU1_VFMAX_VF" || key == "VFMAX.VF" || key == "VFMAX_VF") begin
                pin_dist(valu1_class_dist, VU_VALU1_2_VD_VS2_FS1_VM, VU_VALU1_CLASS_END); pin_dist(valu1_c2_type_dist, VU_VALU1_C2_VFMAX_VF, VU_VALU1_C2_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_VALU1_C3_VFMV_V_F" || key == "VU_VALU1_VFMV_V_F" || key == "VFMV.V.F" || key == "VFMV_V_F") begin
                pin_dist(valu1_class_dist, VU_VALU1_3_VD_FS1, VU_VALU1_CLASS_END); pin_dist(valu1_c3_type_dist, VU_VALU1_C3_VFMV_V_F, VU_VALU1_C3_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_VALU1_C4_VFMV_F_S" || key == "VU_VALU1_VFMV_F_S" || key == "VFMV.F.S" || key == "VFMV_F_S") begin
                pin_dist(valu1_class_dist, VU_VALU1_4_FD_VS1_IMM, VU_VALU1_CLASS_END); pin_dist(valu1_c4_type_dist, VU_VALU1_C4_VFMV_F_S, VU_VALU1_C4_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_VALU1_C5_VFREDUSUM_VS" || key == "VU_VALU1_VFREDUSUM_VS" || key == "VFREDUSUM.VS" || key == "VFREDUSUM_VS") begin
                pin_dist(valu1_class_dist, VU_VALU1_5_FD_VS2_FS1_VM, VU_VALU1_CLASS_END); pin_dist(valu1_c5_type_dist, VU_VALU1_C5_VFREDUSUM_VS, VU_VALU1_C5_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_VALU1_C5_VFREDMAX_VS" || key == "VU_VALU1_VFREDMAX_VS" || key == "VFREDMAX.VS" || key == "VFREDMAX_VS") begin
                pin_dist(valu1_class_dist, VU_VALU1_5_FD_VS2_FS1_VM, VU_VALU1_CLASS_END); pin_dist(valu1_c5_type_dist, VU_VALU1_C5_VFREDMAX_VS, VU_VALU1_C5_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_VALU1_C5_VFREDMIN_VS" || key == "VU_VALU1_VFREDMIN_VS" || key == "VFREDMIN.VS" || key == "VFREDMIN_VS") begin
                pin_dist(valu1_class_dist, VU_VALU1_5_FD_VS2_FS1_VM, VU_VALU1_CLASS_END); pin_dist(valu1_c5_type_dist, VU_VALU1_C5_VFREDMIN_VS, VU_VALU1_C5_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_VALU1_C6_VSORTMAX16_V" || key == "VU_VALU1_VSORTMAX16_V" || key == "VSORTMAX16.V" || key == "VSORTMAX16_V") begin
                pin_dist(valu1_class_dist, VU_VALU1_6_VD_VS1_VM, VU_VALU1_CLASS_END); pin_dist(valu1_c6_type_dist, VU_VALU1_C6_VSORTMAX16_V, VU_VALU1_C6_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_VALU1_C6_VSORTMIN16_V" || key == "VU_VALU1_VSORTMIN16_V" || key == "VSORTMIN16.V" || key == "VSORTMIN16_V") begin
                pin_dist(valu1_class_dist, VU_VALU1_6_VD_VS1_VM, VU_VALU1_CLASS_END); pin_dist(valu1_c6_type_dist, VU_VALU1_C6_VSORTMIN16_V, VU_VALU1_C6_TYPE_END);
                matched = 1;
            end
        end
        if (!matched)
            `uvm_fatal("inst_gen_config", $sformatf("get_opcode: unknown valu1_op_opcode plusarg '%s'", s));
    endfunction : pin_valu1_op_opcode

    protected function void pin_valu2_op_opcode(string s);
        logic [7:0] opc;
        bit matched;
        string key;
        matched = 0;
        if (parse_opcode_u8(s, opc)) begin
            case (opc)
            8'h01: begin pin_dist(valu2_class_dist, VU_VALU2_1_VD_VS2_VS1_VM, VU_VALU2_CLASS_END); pin_dist(valu2_c1_type_dist, VU_VALU2_C1_VFADD_VV, VU_VALU2_C1_TYPE_END); matched = 1; end
            8'h03: begin pin_dist(valu2_class_dist, VU_VALU2_1_VD_VS2_VS1_VM, VU_VALU2_CLASS_END); pin_dist(valu2_c1_type_dist, VU_VALU2_C1_VFSUB_VV, VU_VALU2_C1_TYPE_END); matched = 1; end
            8'h06: begin pin_dist(valu2_class_dist, VU_VALU2_1_VD_VS2_VS1_VM, VU_VALU2_CLASS_END); pin_dist(valu2_c1_type_dist, VU_VALU2_C1_VFMUL_VV, VU_VALU2_C1_TYPE_END); matched = 1; end
            8'h10: begin pin_dist(valu2_class_dist, VU_VALU2_1_VD_VS2_VS1_VM, VU_VALU2_CLASS_END); pin_dist(valu2_c1_type_dist, VU_VALU2_C1_VFMIN_VV, VU_VALU2_C1_TYPE_END); matched = 1; end
            8'h12: begin pin_dist(valu2_class_dist, VU_VALU2_1_VD_VS2_VS1_VM, VU_VALU2_CLASS_END); pin_dist(valu2_c1_type_dist, VU_VALU2_C1_VFMAX_VV, VU_VALU2_C1_TYPE_END); matched = 1; end
            8'h02: begin pin_dist(valu2_class_dist, VU_VALU2_2_VD_VS2_FS1_VM, VU_VALU2_CLASS_END); pin_dist(valu2_c2_type_dist, VU_VALU2_C2_VFADD_VF, VU_VALU2_C2_TYPE_END); matched = 1; end
            8'h04: begin pin_dist(valu2_class_dist, VU_VALU2_2_VD_VS2_FS1_VM, VU_VALU2_CLASS_END); pin_dist(valu2_c2_type_dist, VU_VALU2_C2_VFSUB_VF, VU_VALU2_C2_TYPE_END); matched = 1; end
            8'h05: begin pin_dist(valu2_class_dist, VU_VALU2_2_VD_VS2_FS1_VM, VU_VALU2_CLASS_END); pin_dist(valu2_c2_type_dist, VU_VALU2_C2_VFRSUB_VF, VU_VALU2_C2_TYPE_END); matched = 1; end
            8'h07: begin pin_dist(valu2_class_dist, VU_VALU2_2_VD_VS2_FS1_VM, VU_VALU2_CLASS_END); pin_dist(valu2_c2_type_dist, VU_VALU2_C2_VFMUL_VF, VU_VALU2_C2_TYPE_END); matched = 1; end
            8'h11: begin pin_dist(valu2_class_dist, VU_VALU2_2_VD_VS2_FS1_VM, VU_VALU2_CLASS_END); pin_dist(valu2_c2_type_dist, VU_VALU2_C2_VFMIN_VF, VU_VALU2_C2_TYPE_END); matched = 1; end
            8'h13: begin pin_dist(valu2_class_dist, VU_VALU2_2_VD_VS2_FS1_VM, VU_VALU2_CLASS_END); pin_dist(valu2_c2_type_dist, VU_VALU2_C2_VFMAX_VF, VU_VALU2_C2_TYPE_END); matched = 1; end
            8'h20: begin pin_dist(valu2_class_dist, VU_VALU2_3_VD_FS1, VU_VALU2_CLASS_END); pin_dist(valu2_c3_type_dist, VU_VALU2_C3_VFMV_V_F, VU_VALU2_C3_TYPE_END); matched = 1; end
            8'h23: begin pin_dist(valu2_class_dist, VU_VALU2_4_VD_VS1, VU_VALU2_CLASS_END); pin_dist(valu2_c4_type_dist, VU_VALU2_C4_VMV_V_V, VU_VALU2_C4_TYPE_END); matched = 1; end
            8'h24: begin pin_dist(valu2_class_dist, VU_VALU2_4_VD_VS1, VU_VALU2_CLASS_END); pin_dist(valu2_c4_type_dist, VU_VALU2_C4_VSWAP2_V, VU_VALU2_C4_TYPE_END); matched = 1; end
            8'h25: begin pin_dist(valu2_class_dist, VU_VALU2_5_VD_VS2_FS1, VU_VALU2_CLASS_END); pin_dist(valu2_c5_type_dist, VU_VALU2_C5_VFSLIDE1UP_VF, VU_VALU2_C5_TYPE_END); matched = 1; end
            8'h26: begin pin_dist(valu2_class_dist, VU_VALU2_5_VD_VS2_FS1, VU_VALU2_CLASS_END); pin_dist(valu2_c5_type_dist, VU_VALU2_C5_VFSLIDE1DOWN_VF, VU_VALU2_C5_TYPE_END); matched = 1; end
            endcase
        end else begin
            key = toupper_str(s);
            if (key == "VU_VALU2_C1_VFADD_VV" || key == "VU_VALU2_VFADD_VV" || key == "VFADD.VV" || key == "VFADD_VV") begin
                pin_dist(valu2_class_dist, VU_VALU2_1_VD_VS2_VS1_VM, VU_VALU2_CLASS_END); pin_dist(valu2_c1_type_dist, VU_VALU2_C1_VFADD_VV, VU_VALU2_C1_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_VALU2_C1_VFSUB_VV" || key == "VU_VALU2_VFSUB_VV" || key == "VFSUB.VV" || key == "VFSUB_VV") begin
                pin_dist(valu2_class_dist, VU_VALU2_1_VD_VS2_VS1_VM, VU_VALU2_CLASS_END); pin_dist(valu2_c1_type_dist, VU_VALU2_C1_VFSUB_VV, VU_VALU2_C1_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_VALU2_C1_VFMUL_VV" || key == "VU_VALU2_VFMUL_VV" || key == "VFMUL.VV" || key == "VFMUL_VV") begin
                pin_dist(valu2_class_dist, VU_VALU2_1_VD_VS2_VS1_VM, VU_VALU2_CLASS_END); pin_dist(valu2_c1_type_dist, VU_VALU2_C1_VFMUL_VV, VU_VALU2_C1_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_VALU2_C1_VFMIN_VV" || key == "VU_VALU2_VFMIN_VV" || key == "VFMIN.VV" || key == "VFMIN_VV") begin
                pin_dist(valu2_class_dist, VU_VALU2_1_VD_VS2_VS1_VM, VU_VALU2_CLASS_END); pin_dist(valu2_c1_type_dist, VU_VALU2_C1_VFMIN_VV, VU_VALU2_C1_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_VALU2_C1_VFMAX_VV" || key == "VU_VALU2_VFMAX_VV" || key == "VFMAX.VV" || key == "VFMAX_VV") begin
                pin_dist(valu2_class_dist, VU_VALU2_1_VD_VS2_VS1_VM, VU_VALU2_CLASS_END); pin_dist(valu2_c1_type_dist, VU_VALU2_C1_VFMAX_VV, VU_VALU2_C1_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_VALU2_C2_VFADD_VF" || key == "VU_VALU2_VFADD_VF" || key == "VFADD.VF" || key == "VFADD_VF") begin
                pin_dist(valu2_class_dist, VU_VALU2_2_VD_VS2_FS1_VM, VU_VALU2_CLASS_END); pin_dist(valu2_c2_type_dist, VU_VALU2_C2_VFADD_VF, VU_VALU2_C2_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_VALU2_C2_VFSUB_VF" || key == "VU_VALU2_VFSUB_VF" || key == "VFSUB.VF" || key == "VFSUB_VF") begin
                pin_dist(valu2_class_dist, VU_VALU2_2_VD_VS2_FS1_VM, VU_VALU2_CLASS_END); pin_dist(valu2_c2_type_dist, VU_VALU2_C2_VFSUB_VF, VU_VALU2_C2_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_VALU2_C2_VFRSUB_VF" || key == "VU_VALU2_VFRSUB_VF" || key == "VFRSUB.VF" || key == "VFRSUB_VF") begin
                pin_dist(valu2_class_dist, VU_VALU2_2_VD_VS2_FS1_VM, VU_VALU2_CLASS_END); pin_dist(valu2_c2_type_dist, VU_VALU2_C2_VFRSUB_VF, VU_VALU2_C2_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_VALU2_C2_VFMUL_VF" || key == "VU_VALU2_VFMUL_VF" || key == "VFMUL.VF" || key == "VFMUL_VF") begin
                pin_dist(valu2_class_dist, VU_VALU2_2_VD_VS2_FS1_VM, VU_VALU2_CLASS_END); pin_dist(valu2_c2_type_dist, VU_VALU2_C2_VFMUL_VF, VU_VALU2_C2_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_VALU2_C2_VFMIN_VF" || key == "VU_VALU2_VFMIN_VF" || key == "VFMIN.VF" || key == "VFMIN_VF") begin
                pin_dist(valu2_class_dist, VU_VALU2_2_VD_VS2_FS1_VM, VU_VALU2_CLASS_END); pin_dist(valu2_c2_type_dist, VU_VALU2_C2_VFMIN_VF, VU_VALU2_C2_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_VALU2_C2_VFMAX_VF" || key == "VU_VALU2_VFMAX_VF" || key == "VFMAX.VF" || key == "VFMAX_VF") begin
                pin_dist(valu2_class_dist, VU_VALU2_2_VD_VS2_FS1_VM, VU_VALU2_CLASS_END); pin_dist(valu2_c2_type_dist, VU_VALU2_C2_VFMAX_VF, VU_VALU2_C2_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_VALU2_C3_VFMV_V_F" || key == "VU_VALU2_VFMV_V_F" || key == "VFMV.V.F" || key == "VFMV_V_F") begin
                pin_dist(valu2_class_dist, VU_VALU2_3_VD_FS1, VU_VALU2_CLASS_END); pin_dist(valu2_c3_type_dist, VU_VALU2_C3_VFMV_V_F, VU_VALU2_C3_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_VALU2_C4_VMV_V_V" || key == "VU_VALU2_VMV_V_V" || key == "VMV.V.V" || key == "VMV_V_V") begin
                pin_dist(valu2_class_dist, VU_VALU2_4_VD_VS1, VU_VALU2_CLASS_END); pin_dist(valu2_c4_type_dist, VU_VALU2_C4_VMV_V_V, VU_VALU2_C4_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_VALU2_C4_VSWAP2_V" || key == "VU_VALU2_VSWAP2_V" || key == "VSWAP2.V" || key == "VSWAP2_V") begin
                pin_dist(valu2_class_dist, VU_VALU2_4_VD_VS1, VU_VALU2_CLASS_END); pin_dist(valu2_c4_type_dist, VU_VALU2_C4_VSWAP2_V, VU_VALU2_C4_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_VALU2_C5_VFSLIDE1UP_VF" || key == "VU_VALU2_VFSLIDE1UP_VF" || key == "VFSLIDE1UP.VF" || key == "VFSLIDE1UP_VF") begin
                pin_dist(valu2_class_dist, VU_VALU2_5_VD_VS2_FS1, VU_VALU2_CLASS_END); pin_dist(valu2_c5_type_dist, VU_VALU2_C5_VFSLIDE1UP_VF, VU_VALU2_C5_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_VALU2_C5_VFSLIDE1DOWN_VF" || key == "VU_VALU2_VFSLIDE1DOWN_VF" || key == "VFSLIDE1DOWN.VF" || key == "VFSLIDE1DOWN_VF") begin
                pin_dist(valu2_class_dist, VU_VALU2_5_VD_VS2_FS1, VU_VALU2_CLASS_END); pin_dist(valu2_c5_type_dist, VU_VALU2_C5_VFSLIDE1DOWN_VF, VU_VALU2_C5_TYPE_END);
                matched = 1;
            end
        end
        if (!matched)
            `uvm_fatal("inst_gen_config", $sformatf("get_opcode: unknown valu2_op_opcode plusarg '%s'", s));
    endfunction : pin_valu2_op_opcode

    protected function void pin_vsfu_op_vsfu0_opcode(string s);
        logic [7:0] opc;
        bit matched;
        string key;
        matched = 0;
        if (parse_opcode_u8(s, opc)) begin
            case (opc)
            8'h01: begin pin_dist(vsfu0_c1_type_dist, VU_VSFU0_C1_VFSIN_V, VU_VSFU0_C1_TYPE_END); matched = 1; end
            8'h02: begin pin_dist(vsfu0_c1_type_dist, VU_VSFU0_C1_VFCOS_V, VU_VSFU0_C1_TYPE_END); matched = 1; end
            8'h03: begin pin_dist(vsfu0_c1_type_dist, VU_VSFU0_C1_VFTANH_V, VU_VSFU0_C1_TYPE_END); matched = 1; end
            8'h04: begin pin_dist(vsfu0_c1_type_dist, VU_VSFU0_C1_VFSIGMOID_V, VU_VSFU0_C1_TYPE_END); matched = 1; end
            8'h05: begin pin_dist(vsfu0_c1_type_dist, VU_VSFU0_C1_VFEXP_V, VU_VSFU0_C1_TYPE_END); matched = 1; end
            8'h06: begin pin_dist(vsfu0_c1_type_dist, VU_VSFU0_C1_VFEXP2_V, VU_VSFU0_C1_TYPE_END); matched = 1; end
            8'h07: begin pin_dist(vsfu0_c1_type_dist, VU_VSFU0_C1_VFLN_V, VU_VSFU0_C1_TYPE_END); matched = 1; end
            8'h08: begin pin_dist(vsfu0_c1_type_dist, VU_VSFU0_C1_VFLOG2_V, VU_VSFU0_C1_TYPE_END); matched = 1; end
            8'h09: begin pin_dist(vsfu0_c1_type_dist, VU_VSFU0_C1_VFSQRT_V, VU_VSFU0_C1_TYPE_END); matched = 1; end
            8'h0A: begin pin_dist(vsfu0_c1_type_dist, VU_VSFU0_C1_VFRCP_V, VU_VSFU0_C1_TYPE_END); matched = 1; end
            8'h0B: begin pin_dist(vsfu0_c1_type_dist, VU_VSFU0_C1_VFRSQRT_V, VU_VSFU0_C1_TYPE_END); matched = 1; end
            8'h0C: begin pin_dist(vsfu0_c1_type_dist, VU_VSFU0_C1_CUSTOM_FIT, VU_VSFU0_C1_TYPE_END); matched = 1; end
            endcase
        end else begin
            key = toupper_str(s);
            if (key == "VU_VSFU0_C1_VFSIN_V" || key == "VU_VSFU_VFSIN_V" || key == "VFSIN.V" || key == "VFSIN_V") begin
                pin_dist(vsfu0_c1_type_dist, VU_VSFU0_C1_VFSIN_V, VU_VSFU0_C1_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_VSFU0_C1_VFCOS_V" || key == "VU_VSFU_VFCOS_V" || key == "VFCOS.V" || key == "VFCOS_V") begin
                pin_dist(vsfu0_c1_type_dist, VU_VSFU0_C1_VFCOS_V, VU_VSFU0_C1_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_VSFU0_C1_VFTANH_V" || key == "VU_VSFU_VFTANH_V" || key == "VFTANH.V" || key == "VFTANH_V") begin
                pin_dist(vsfu0_c1_type_dist, VU_VSFU0_C1_VFTANH_V, VU_VSFU0_C1_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_VSFU0_C1_VFSIGMOID_V" || key == "VU_VSFU_VFSIGMOID_V" || key == "VFSIGMOID.V" || key == "VFSIGMOID_V") begin
                pin_dist(vsfu0_c1_type_dist, VU_VSFU0_C1_VFSIGMOID_V, VU_VSFU0_C1_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_VSFU0_C1_VFEXP_V" || key == "VU_VSFU_VFEXP_V" || key == "VFEXP.V" || key == "VFEXP_V") begin
                pin_dist(vsfu0_c1_type_dist, VU_VSFU0_C1_VFEXP_V, VU_VSFU0_C1_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_VSFU0_C1_VFEXP2_V" || key == "VU_VSFU_VFEXP2_V" || key == "VFEXP2.V" || key == "VFEXP2_V") begin
                pin_dist(vsfu0_c1_type_dist, VU_VSFU0_C1_VFEXP2_V, VU_VSFU0_C1_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_VSFU0_C1_VFLN_V" || key == "VU_VSFU_VFLN_V" || key == "VFLN.V" || key == "VFLN_V") begin
                pin_dist(vsfu0_c1_type_dist, VU_VSFU0_C1_VFLN_V, VU_VSFU0_C1_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_VSFU0_C1_VFLOG2_V" || key == "VU_VSFU_VFLOG2_V" || key == "VFLOG2.V" || key == "VFLOG2_V") begin
                pin_dist(vsfu0_c1_type_dist, VU_VSFU0_C1_VFLOG2_V, VU_VSFU0_C1_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_VSFU0_C1_VFSQRT_V" || key == "VU_VSFU_VFSQRT_V" || key == "VFSQRT.V" || key == "VFSQRT_V") begin
                pin_dist(vsfu0_c1_type_dist, VU_VSFU0_C1_VFSQRT_V, VU_VSFU0_C1_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_VSFU0_C1_VFRCP_V" || key == "VU_VSFU_VFRCP_V" || key == "VFRCP.V" || key == "VFRCP_V") begin
                pin_dist(vsfu0_c1_type_dist, VU_VSFU0_C1_VFRCP_V, VU_VSFU0_C1_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_VSFU0_C1_VFRSQRT_V" || key == "VU_VSFU_VFRSQRT_V" || key == "VFRSQRT.V" || key == "VFRSQRT_V") begin
                pin_dist(vsfu0_c1_type_dist, VU_VSFU0_C1_VFRSQRT_V, VU_VSFU0_C1_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_VSFU0_C1_CUSTOM_FIT" || key == "VU_VSFU_CUSTOM_FIT" || key == "自定义拟合函数") begin
                pin_dist(vsfu0_c1_type_dist, VU_VSFU0_C1_CUSTOM_FIT, VU_VSFU0_C1_TYPE_END);
                matched = 1;
            end
        end
        if (!matched)
            `uvm_fatal("inst_gen_config", $sformatf("get_opcode: unknown vsfu_op_vsfu0_opcode plusarg '%s'", s));
    endfunction : pin_vsfu_op_vsfu0_opcode

    protected function void pin_vsfu_op_vsfu1_opcode(string s);
        logic [7:0] opc;
        bit matched;
        string key;
        matched = 0;
        if (parse_opcode_u8(s, opc)) begin
            case (opc)
            8'h01: begin pin_dist(vsfu1_c1_type_dist, VU_VSFU1_C1_VFSIN_V, VU_VSFU1_C1_TYPE_END); matched = 1; end
            8'h02: begin pin_dist(vsfu1_c1_type_dist, VU_VSFU1_C1_VFCOS_V, VU_VSFU1_C1_TYPE_END); matched = 1; end
            8'h03: begin pin_dist(vsfu1_c1_type_dist, VU_VSFU1_C1_VFTANH_V, VU_VSFU1_C1_TYPE_END); matched = 1; end
            8'h04: begin pin_dist(vsfu1_c1_type_dist, VU_VSFU1_C1_VFSIGMOID_V, VU_VSFU1_C1_TYPE_END); matched = 1; end
            8'h05: begin pin_dist(vsfu1_c1_type_dist, VU_VSFU1_C1_VFEXP_V, VU_VSFU1_C1_TYPE_END); matched = 1; end
            8'h06: begin pin_dist(vsfu1_c1_type_dist, VU_VSFU1_C1_VFEXP2_V, VU_VSFU1_C1_TYPE_END); matched = 1; end
            8'h07: begin pin_dist(vsfu1_c1_type_dist, VU_VSFU1_C1_VFLN_V, VU_VSFU1_C1_TYPE_END); matched = 1; end
            8'h08: begin pin_dist(vsfu1_c1_type_dist, VU_VSFU1_C1_VFLOG2_V, VU_VSFU1_C1_TYPE_END); matched = 1; end
            8'h09: begin pin_dist(vsfu1_c1_type_dist, VU_VSFU1_C1_VFSQRT_V, VU_VSFU1_C1_TYPE_END); matched = 1; end
            8'h0A: begin pin_dist(vsfu1_c1_type_dist, VU_VSFU1_C1_VFRCP_V, VU_VSFU1_C1_TYPE_END); matched = 1; end
            8'h0B: begin pin_dist(vsfu1_c1_type_dist, VU_VSFU1_C1_VFRSQRT_V, VU_VSFU1_C1_TYPE_END); matched = 1; end
            8'h0C: begin pin_dist(vsfu1_c1_type_dist, VU_VSFU1_C1_CUSTOM_FIT, VU_VSFU1_C1_TYPE_END); matched = 1; end
            endcase
        end else begin
            key = toupper_str(s);
            if (key == "VU_VSFU1_C1_VFSIN_V" || key == "VU_VSFU_VFSIN_V" || key == "VFSIN.V" || key == "VFSIN_V") begin
                pin_dist(vsfu1_c1_type_dist, VU_VSFU1_C1_VFSIN_V, VU_VSFU1_C1_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_VSFU1_C1_VFCOS_V" || key == "VU_VSFU_VFCOS_V" || key == "VFCOS.V" || key == "VFCOS_V") begin
                pin_dist(vsfu1_c1_type_dist, VU_VSFU1_C1_VFCOS_V, VU_VSFU1_C1_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_VSFU1_C1_VFTANH_V" || key == "VU_VSFU_VFTANH_V" || key == "VFTANH.V" || key == "VFTANH_V") begin
                pin_dist(vsfu1_c1_type_dist, VU_VSFU1_C1_VFTANH_V, VU_VSFU1_C1_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_VSFU1_C1_VFSIGMOID_V" || key == "VU_VSFU_VFSIGMOID_V" || key == "VFSIGMOID.V" || key == "VFSIGMOID_V") begin
                pin_dist(vsfu1_c1_type_dist, VU_VSFU1_C1_VFSIGMOID_V, VU_VSFU1_C1_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_VSFU1_C1_VFEXP_V" || key == "VU_VSFU_VFEXP_V" || key == "VFEXP.V" || key == "VFEXP_V") begin
                pin_dist(vsfu1_c1_type_dist, VU_VSFU1_C1_VFEXP_V, VU_VSFU1_C1_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_VSFU1_C1_VFEXP2_V" || key == "VU_VSFU_VFEXP2_V" || key == "VFEXP2.V" || key == "VFEXP2_V") begin
                pin_dist(vsfu1_c1_type_dist, VU_VSFU1_C1_VFEXP2_V, VU_VSFU1_C1_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_VSFU1_C1_VFLN_V" || key == "VU_VSFU_VFLN_V" || key == "VFLN.V" || key == "VFLN_V") begin
                pin_dist(vsfu1_c1_type_dist, VU_VSFU1_C1_VFLN_V, VU_VSFU1_C1_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_VSFU1_C1_VFLOG2_V" || key == "VU_VSFU_VFLOG2_V" || key == "VFLOG2.V" || key == "VFLOG2_V") begin
                pin_dist(vsfu1_c1_type_dist, VU_VSFU1_C1_VFLOG2_V, VU_VSFU1_C1_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_VSFU1_C1_VFSQRT_V" || key == "VU_VSFU_VFSQRT_V" || key == "VFSQRT.V" || key == "VFSQRT_V") begin
                pin_dist(vsfu1_c1_type_dist, VU_VSFU1_C1_VFSQRT_V, VU_VSFU1_C1_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_VSFU1_C1_VFRCP_V" || key == "VU_VSFU_VFRCP_V" || key == "VFRCP.V" || key == "VFRCP_V") begin
                pin_dist(vsfu1_c1_type_dist, VU_VSFU1_C1_VFRCP_V, VU_VSFU1_C1_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_VSFU1_C1_VFRSQRT_V" || key == "VU_VSFU_VFRSQRT_V" || key == "VFRSQRT.V" || key == "VFRSQRT_V") begin
                pin_dist(vsfu1_c1_type_dist, VU_VSFU1_C1_VFRSQRT_V, VU_VSFU1_C1_TYPE_END);
                matched = 1;
            end
            else if (key == "VU_VSFU1_C1_CUSTOM_FIT" || key == "VU_VSFU_CUSTOM_FIT" || key == "自定义拟合函数") begin
                pin_dist(vsfu1_c1_type_dist, VU_VSFU1_C1_CUSTOM_FIT, VU_VSFU1_C1_TYPE_END);
                matched = 1;
            end
        end
        if (!matched)
            `uvm_fatal("inst_gen_config", $sformatf("get_opcode: unknown vsfu_op_vsfu1_opcode plusarg '%s'", s));
    endfunction : pin_vsfu_op_vsfu1_opcode

    function void get_opcode();
        string s;
        if ($value$plusargs("lu_op_opcode=%s", s))
            pin_lu_op_opcode(s);
        if ($value$plusargs("mexe_op_opcode=%s", s))
            pin_mexe_op_opcode(s);
        if ($value$plusargs("sexe0_op_opcode=%s", s))
            pin_sexe0_op_opcode(s);
        if ($value$plusargs("sexe1_op_opcode=%s", s))
            pin_sexe1_op_opcode(s);
        if ($value$plusargs("sexe2_op_opcode=%s", s))
            pin_sexe2_op_opcode(s);
        if ($value$plusargs("su_op_opcode=%s", s))
            pin_su_op_opcode(s);
        if ($value$plusargs("valu0_op_opcode=%s", s))
            pin_valu0_op_opcode(s);
        if ($value$plusargs("valu1_op_opcode=%s", s))
            pin_valu1_op_opcode(s);
        if ($value$plusargs("valu2_op_opcode=%s", s))
            pin_valu2_op_opcode(s);
        if ($value$plusargs("vsfu_op_vsfu0_opcode=%s", s))
            pin_vsfu_op_vsfu0_opcode(s);
        if ($value$plusargs("vsfu_op_vsfu1_opcode=%s", s))
            pin_vsfu_op_vsfu1_opcode(s);
    endfunction : get_opcode

    // 用法：+set_vu_scene=1,0  （cross_idx,bypass；bypass 为 0/1）
    function void post_randomize();
        string s;
        int unsigned cross_idx;
        int unsigned bypass_i;
        get_opcode();
        if ($value$plusargs("set_vu_scene=%s", s)) begin
            if ($sscanf(s, "%d,%d", cross_idx, bypass_i) != 2)
                `uvm_fatal("inst_gen_config", 
                    $sformatf("set_vu_scene plusarg '%s' 须为 <cross_idx>,<bypass>，例如 1,0", s))
            set_vu_scene(cross_idx, bypass_i != 0);
        end
    endfunction : post_randomize

    constraint first_delay_c  {
        first_delay inside {[0:10]};
    }

    constraint vld_delay_dist_c  {
         vld_delay_dist.sum == 100;
         vld_delay_dist.size() == 4;
         foreach(vld_delay_dist[i])
             vld_delay_dist[i] inside {[1:100]};
    }

    constraint src_bypass_weight_c {
        src_bypass_weight inside {[1:100]};
    }

    constraint vl_data_type_weight_c {
        vl_data_type_weight inside {[1:100]};
    }

    constraint inst_type_dist_c {
        inst_type_dist.sum == 100;
        inst_type_dist.size()==INST_TYPE_END;
        foreach(inst_type_dist[i])
            inst_type_dist[i] inside {[1:100]};
    }

    constraint inst_dist_c {
        inst_dist.sum == 100;
        inst_dist.size() == INST_END;
        foreach(inst_dist[i])
            inst_dist[i] inside {[1:100]};
    }

    constraint mu_inst_type_dist_c {
        mu_inst_type_dist.sum == 100;
        mu_inst_type_dist.size()==MU_INST_END;
        foreach(mu_inst_type_dist[i])
            mu_inst_type_dist[i] inside {[1:100]};
    }

    constraint vu_inst_type_dist_c{
        vu_inst_type_dist.sum == 100;
        vu_inst_type_dist.size()==VU_INST_END;
        foreach(vu_inst_type_dist[i])
            vu_inst_type_dist[i] inside {[1:100]};
    }

    constraint lu_class_dist_c {
        lu_class_dist.sum == 100;
        lu_class_dist.size()==VU_LU_CLASS_END;
        foreach(lu_class_dist[i])
            lu_class_dist[i] inside {[1:100]};
    }

    constraint lu_c1_type_dist_c {
        lu_c1_type_dist.sum == 100;
        lu_c1_type_dist.size()==VU_LU_C1_TYPE_END;
        foreach(lu_c1_type_dist[i])
            lu_c1_type_dist[i] inside {[1:100]};
    }

    constraint lu_c2_type_dist_c {
        lu_c2_type_dist.sum == 100;
        lu_c2_type_dist.size()==VU_LU_C2_TYPE_END;
        foreach(lu_c2_type_dist[i])
            lu_c2_type_dist[i] inside {[1:100]};
    }

    constraint lu_c3_type_dist_c {
        lu_c3_type_dist.sum == 100;
        lu_c3_type_dist.size()==VU_LU_C3_TYPE_END;
        foreach(lu_c3_type_dist[i])
            lu_c3_type_dist[i] inside {[1:100]};
    }

    constraint su_class_dist_c {
        su_class_dist.sum == 100;
        su_class_dist.size()==VU_SU_CLASS_END;
        foreach(su_class_dist[i])
            su_class_dist[i] inside {[1:100]};
    }

    constraint su_c1_type_dist_c {
        su_c1_type_dist.sum == 100;
        su_c1_type_dist.size()==VU_SU_C1_TYPE_END;
        foreach(su_c1_type_dist[i])
            su_c1_type_dist[i] inside {[1:100]};
    }

    constraint su_c2_type_dist_c {
        su_c2_type_dist.sum == 100;
        su_c2_type_dist.size()==VU_SU_C2_TYPE_END;
        foreach(su_c2_type_dist[i])
            su_c2_type_dist[i] inside {[1:100]};
    }

    constraint su_c3_type_dist_c {
        su_c3_type_dist.sum == 100;
        su_c3_type_dist.size()==VU_SU_C3_TYPE_END;
        foreach(su_c3_type_dist[i])
            su_c3_type_dist[i] inside {[1:100]};
    }

    constraint valu0_class_dist_c {
        valu0_class_dist.sum == 100;
        valu0_class_dist.size()==VU_VALU0_CLASS_END;
        foreach(valu0_class_dist[i])
            valu0_class_dist[i] inside {[1:100]};
    }

    constraint valu0_c1_type_dist_c {
        valu0_c1_type_dist.sum == 100;
        valu0_c1_type_dist.size()==VU_VALU0_C1_TYPE_END;
        foreach(valu0_c1_type_dist[i])
            valu0_c1_type_dist[i] inside {[1:100]};
    }

    constraint valu0_c2_type_dist_c {
        valu0_c2_type_dist.sum == 100;
        valu0_c2_type_dist.size()==VU_VALU0_C2_TYPE_END;
        foreach(valu0_c2_type_dist[i])
            valu0_c2_type_dist[i] inside {[1:100]};
    }

    constraint valu0_c3_type_dist_c {
        valu0_c3_type_dist.sum == 100;
        valu0_c3_type_dist.size()==VU_VALU0_C3_TYPE_END;
        foreach(valu0_c3_type_dist[i])
            valu0_c3_type_dist[i] inside {[1:100]};
    }

    constraint valu0_c4_type_dist_c {
        valu0_c4_type_dist.sum == 100;
        valu0_c4_type_dist.size()==VU_VALU0_C4_TYPE_END;
        foreach(valu0_c4_type_dist[i])
            valu0_c4_type_dist[i] inside {[1:100]};
    }

    constraint valu0_c5_type_dist_c {
        valu0_c5_type_dist.sum == 100;
        valu0_c5_type_dist.size()==VU_VALU0_C5_TYPE_END;
        foreach(valu0_c5_type_dist[i])
            valu0_c5_type_dist[i] inside {[1:100]};
    }

    constraint valu0_c6_type_dist_c {
        valu0_c6_type_dist.sum == 100;
        valu0_c6_type_dist.size()==VU_VALU0_C6_TYPE_END;
        foreach(valu0_c6_type_dist[i])
            valu0_c6_type_dist[i] inside {[1:100]};
    }

    constraint valu0_c7_type_dist_c {
        valu0_c7_type_dist.sum == 100;
        valu0_c7_type_dist.size()==VU_VALU0_C7_TYPE_END;
        foreach(valu0_c7_type_dist[i])
            valu0_c7_type_dist[i] inside {[1:100]};
    }

    constraint valu0_c8_type_dist_c {
        valu0_c8_type_dist.sum == 100;
        valu0_c8_type_dist.size()==VU_VALU0_C8_TYPE_END;
        foreach(valu0_c8_type_dist[i])
            valu0_c8_type_dist[i] inside {[1:100]};
    }

    constraint valu0_c9_type_dist_c {
        valu0_c9_type_dist.sum == 100;
        valu0_c9_type_dist.size()==VU_VALU0_C9_TYPE_END;
        foreach(valu0_c9_type_dist[i])
            valu0_c9_type_dist[i] inside {[1:100]};
    }

    constraint valu1_class_dist_c {
        valu1_class_dist.sum == 100;
        valu1_class_dist.size()==VU_VALU1_CLASS_END;
        foreach(valu1_class_dist[i])
            valu1_class_dist[i] inside {[1:100]};
    }

    constraint valu1_c1_type_dist_c {
        valu1_c1_type_dist.sum == 100;
        valu1_c1_type_dist.size()==VU_VALU1_C1_TYPE_END;
        foreach(valu1_c1_type_dist[i])
            valu1_c1_type_dist[i] inside {[1:100]};
    }

    constraint valu1_c2_type_dist_c {
        valu1_c2_type_dist.sum == 100;
        valu1_c2_type_dist.size()==VU_VALU1_C2_TYPE_END;
        foreach(valu1_c2_type_dist[i])
            valu1_c2_type_dist[i] inside {[1:100]};
    }

    constraint valu1_c3_type_dist_c {
        valu1_c3_type_dist.sum == 100;
        valu1_c3_type_dist.size()==VU_VALU1_C3_TYPE_END;
        foreach(valu1_c3_type_dist[i])
            valu1_c3_type_dist[i] inside {[1:100]};
    }

    constraint valu1_c4_type_dist_c {
        valu1_c4_type_dist.sum == 100;
        valu1_c4_type_dist.size()==VU_VALU1_C4_TYPE_END;
        foreach(valu1_c4_type_dist[i])
            valu1_c4_type_dist[i] inside {[1:100]};
    }

    constraint valu1_c5_type_dist_c {
        valu1_c5_type_dist.sum == 100;
        valu1_c5_type_dist.size()==VU_VALU1_C5_TYPE_END;
        foreach(valu1_c5_type_dist[i])
            valu1_c5_type_dist[i] inside {[1:100]};
    }

    constraint valu1_c6_type_dist_c {
        valu1_c6_type_dist.sum == 100;
        valu1_c6_type_dist.size()==VU_VALU1_C6_TYPE_END;
        foreach(valu1_c6_type_dist[i])
            valu1_c6_type_dist[i] inside {[1:100]};
    }

    constraint valu2_class_dist_c {
        valu2_class_dist.sum == 100;
        valu2_class_dist.size()==VU_VALU2_CLASS_END;
        foreach(valu2_class_dist[i])
            valu2_class_dist[i] inside {[1:100]};
    }

    constraint valu2_c1_type_dist_c {
        valu2_c1_type_dist.sum == 100;
        valu2_c1_type_dist.size()==VU_VALU2_C1_TYPE_END;
        foreach(valu2_c1_type_dist[i])
            valu2_c1_type_dist[i] inside {[1:100]};
    }

    constraint valu2_c2_type_dist_c {
        valu2_c2_type_dist.sum == 100;
        valu2_c2_type_dist.size()==VU_VALU2_C2_TYPE_END;
        foreach(valu2_c2_type_dist[i])
            valu2_c2_type_dist[i] inside {[1:100]};
    }

    constraint valu2_c3_type_dist_c {
        valu2_c3_type_dist.sum == 100;
        valu2_c3_type_dist.size()==VU_VALU2_C3_TYPE_END;
        foreach(valu2_c3_type_dist[i])
            valu2_c3_type_dist[i] inside {[1:100]};
    }

    constraint valu2_c4_type_dist_c {
        valu2_c4_type_dist.sum == 100;
        valu2_c4_type_dist.size()==VU_VALU2_C4_TYPE_END;
        foreach(valu2_c4_type_dist[i])
            valu2_c4_type_dist[i] inside {[1:100]};
    }

    constraint valu2_c5_type_dist_c {
        valu2_c5_type_dist.sum == 100;
        valu2_c5_type_dist.size()==VU_VALU2_C5_TYPE_END;
        foreach(valu2_c5_type_dist[i])
            valu2_c5_type_dist[i] inside {[1:100]};
    }

    constraint vsfu0_c1_type_dist_c {
        vsfu0_c1_type_dist.sum == 100;
        vsfu0_c1_type_dist.size()==VU_VSFU0_C1_TYPE_END;
        foreach(vsfu0_c1_type_dist[i])
            vsfu0_c1_type_dist[i] inside {[1:100]};
    }

    constraint vsfu1_c1_type_dist_c {
        vsfu1_c1_type_dist.sum == 100;
        vsfu1_c1_type_dist.size()==VU_VSFU1_C1_TYPE_END;
        foreach(vsfu1_c1_type_dist[i])
            vsfu1_c1_type_dist[i] inside {[1:100]};
    }

    constraint mexe_class_dist_c {
        mexe_class_dist.sum == 100;
        mexe_class_dist.size()==VU_MEXE_CLASS_END;
        foreach(mexe_class_dist[i])
            mexe_class_dist[i] inside {[1:100]};
    }

    constraint mexe_c1_type_dist_c {
        mexe_c1_type_dist.sum == 100;
        mexe_c1_type_dist.size()==VU_MEXE_C1_TYPE_END;
        foreach(mexe_c1_type_dist[i])
            mexe_c1_type_dist[i] inside {[1:100]};
    }

    constraint mexe_c2_type_dist_c {
        mexe_c2_type_dist.sum == 100;
        mexe_c2_type_dist.size()==VU_MEXE_C2_TYPE_END;
        foreach(mexe_c2_type_dist[i])
            mexe_c2_type_dist[i] inside {[1:100]};
    }

    constraint mexe_c3_type_dist_c {
        mexe_c3_type_dist.sum == 100;
        mexe_c3_type_dist.size()==VU_MEXE_C3_TYPE_END;
        foreach(mexe_c3_type_dist[i])
            mexe_c3_type_dist[i] inside {[1:100]};
    }

    constraint mexe_c4_type_dist_c {
        mexe_c4_type_dist.sum == 100;
        mexe_c4_type_dist.size()==VU_MEXE_C4_TYPE_END;
        foreach(mexe_c4_type_dist[i])
            mexe_c4_type_dist[i] inside {[1:100]};
    }

    constraint sexe0_class_dist_c {
        sexe0_class_dist.sum == 100;
        sexe0_class_dist.size()==VU_SEXE0_CLASS_END;
        foreach(sexe0_class_dist[i])
            sexe0_class_dist[i] inside {[1:100]};
    }

    constraint sexe0_c1_type_dist_c {
        sexe0_c1_type_dist.sum == 100;
        sexe0_c1_type_dist.size()==VU_SEXE0_C1_TYPE_END;
        foreach(sexe0_c1_type_dist[i])
            sexe0_c1_type_dist[i] inside {[1:100]};
    }

    constraint sexe0_c2_type_dist_c {
        sexe0_c2_type_dist.sum == 100;
        sexe0_c2_type_dist.size()==VU_SEXE0_C2_TYPE_END;
        foreach(sexe0_c2_type_dist[i])
            sexe0_c2_type_dist[i] inside {[1:100]};
    }

    constraint sexe1_class_dist_c {
        sexe1_class_dist.sum == 100;
        sexe1_class_dist.size()==VU_SEXE1_CLASS_END;
        foreach(sexe1_class_dist[i])
            sexe1_class_dist[i] inside {[1:100]};
    }

    constraint sexe1_c1_type_dist_c {
        sexe1_c1_type_dist.sum == 100;
        sexe1_c1_type_dist.size()==VU_SEXE1_C1_TYPE_END;
        foreach(sexe1_c1_type_dist[i])
            sexe1_c1_type_dist[i] inside {[1:100]};
    }

    constraint sexe1_c2_type_dist_c {
        sexe1_c2_type_dist.sum == 100;
        sexe1_c2_type_dist.size()==VU_SEXE1_C2_TYPE_END;
        foreach(sexe1_c2_type_dist[i])
            sexe1_c2_type_dist[i] inside {[1:100]};
    }

    constraint sexe2_class_dist_c {
        sexe2_class_dist.sum == 100;
        sexe2_class_dist.size()==VU_SEXE2_CLASS_END;
        foreach(sexe2_class_dist[i])
            sexe2_class_dist[i] inside {[1:100]};
    }

    constraint sexe2_c1_type_dist_c {
        sexe2_c1_type_dist.sum == 100;
        sexe2_c1_type_dist.size()==VU_SEXE2_C1_TYPE_END;
        foreach(sexe2_c1_type_dist[i])
            sexe2_c1_type_dist[i] inside {[1:100]};
    }

    constraint sexe2_c2_type_dist_c {
        sexe2_c2_type_dist.sum == 100;
        sexe2_c2_type_dist.size()==VU_SEXE2_C2_TYPE_END;
        foreach(sexe2_c2_type_dist[i])
            sexe2_c2_type_dist[i] inside {[1:100]};
    }
    constraint vd_exe_type_dist_c {
        vd_exe_type_dist.sum == 100;
        vd_exe_type_dist.size()==VU_VD_EXE_END;
        foreach(vd_exe_type_dist[i])
            vd_exe_type_dist[i] inside {[1:100]};
    }

    constraint md_exe_type_dist_c {
        md_exe_type_dist.sum == 100;
        md_exe_type_dist.size()==VU_MD_EXE_END;
        foreach(md_exe_type_dist[i])
            md_exe_type_dist[i] inside {[1:100]};
    }
    constraint reg_read_addr_cat_dist_c {
        reg_read_addr_cat_dist.sum == 100;
        reg_read_addr_cat_dist.size() == VU_REG_READ_CAT_END;
        foreach (reg_read_addr_cat_dist[i])
            reg_read_addr_cat_dist[i] inside {[1:100]};
    }
    constraint align_addr_weight_c {
        align_addr_weight inside {[1:100]};
    }
    constraint prf_op_vrf_wt_pair_weight_c {
        prf_op_vrf_wt_pair_weight inside {[1:100]};
    }
    constraint su_vs_sel_pair_weight_c {
        su_vs_sel_pair_weight inside {[1:100]};
    }
    constraint su_ms_sel_pair_weight_c {
        su_ms_sel_pair_weight inside {[1:100]};
    }
    constraint valu0_vs1_sel_pair_weight_c {
        valu0_vs1_sel_pair_weight inside {[1:100]};
    }
    constraint valu0_vs2_sel_pair_weight_c {
        valu0_vs2_sel_pair_weight inside {[1:100]};
    }
    constraint valu0_vs3_sel_pair_weight_c {
        valu0_vs3_sel_pair_weight inside {[1:100]};
    }
    constraint valu1_vs1_sel_pair_weight_c {
        valu1_vs1_sel_pair_weight inside {[1:100]};
    }
    constraint valu1_vs2_sel_pair_weight_c {
        valu1_vs2_sel_pair_weight inside {[1:100]};
    }
    constraint valu2_vs1_sel_pair_weight_c {
        valu2_vs1_sel_pair_weight inside {[1:100]};
    }
    constraint valu2_vs2_sel_pair_weight_c {
        valu2_vs2_sel_pair_weight inside {[1:100]};
    }
    constraint vsfu0_vs_sel_pair_weight_c {
        vsfu0_vs_sel_pair_weight inside {[1:100]};
    }
    constraint vsfu1_vs_sel_pair_weight_c {
        vsfu1_vs_sel_pair_weight inside {[1:100]};
    }
    constraint mexe_ms_sel_pair_weight_c {
        mexe_ms_sel_pair_weight inside {[1:100]};
    }
    constraint mexe_vs_sel_pair_weight_c {
        mexe_vs_sel_pair_weight inside {[1:100]};
    }
    constraint valu0_vm_sel_pair_dist_c {
        valu0_vm_sel_pair_dist.sum == 100;
        valu0_vm_sel_pair_dist.size()==3;
        foreach(valu0_vm_sel_pair_dist[i])
            valu0_vm_sel_pair_dist[i] inside {[1:100]};
    }
    constraint valu1_vm_sel_pair_dist_c {
        valu1_vm_sel_pair_dist.sum == 100;
        valu1_vm_sel_pair_dist.size()==3;
        foreach(valu1_vm_sel_pair_dist[i])
            valu1_vm_sel_pair_dist[i] inside {[1:100]};
    }
    constraint valu2_vm_sel_pair_dist_c {
        valu2_vm_sel_pair_dist.sum == 100;
        valu2_vm_sel_pair_dist.size()==3;
        foreach(valu2_vm_sel_pair_dist[i])
            valu2_vm_sel_pair_dist[i] inside {[1:100]};
    }

    constraint  case_type_dist_c{
        case_type_dist.sum == 100;
        case_type_dist.size()==4;
        foreach(case_type_dist[i])
            case_type_dist[i] inside {[1:100]};
    }
endclass : inst_gen_config

class cross_1_config extends uvm_object;
    // ===================== cross_1_type 执行单元组合（src） =====================
    rand int unsigned   cross_1_type_dist[];

    `uvm_object_utils_begin(cross_1_config)
        `uvm_field_array_int    (cross_1_type_dist,                         UVM_DEFAULT | UVM_DEC)
    `uvm_object_utils_end

    function new (string name = "cross_1_config");
        super.new(name);
    endfunction : new

    constraint cross_1_type_dist_c {
        cross_1_type_dist.sum == 100;
        cross_1_type_dist.size()==VU_UNIT_END+1;
        foreach(cross_1_type_dist[i])
            cross_1_type_dist[i] inside {[1:100]};
    }

endclass : cross_1_config

class cross_2_config extends uvm_object;
    // ===================== cross_2_type 执行单元组合（src） =====================
    bit                 fix_cross_2_type_en=0;
    rand cross_2_type_e       cross_2_type;
    rand int unsigned   cross_2_type_dist[];

    // ===================== cross_2_bypass_type 执行单元组合（bypass） =====================
    bit                 fix_cross_2_bypass_type_en=0;
    rand cross_2_bypass_type_e cross_2_bypass_type;
    rand int unsigned   cross_2_bypass_type_dist[];

    `uvm_object_utils_begin(cross_2_config)
        `uvm_field_int          (fix_cross_2_type_en,                       UVM_DEFAULT)
        `uvm_field_enum         (cross_2_type_e,        cross_2_type,       UVM_DEFAULT)
        `uvm_field_array_int    (cross_2_type_dist,                         UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_cross_2_bypass_type_en,                       UVM_DEFAULT)
        `uvm_field_enum         (cross_2_bypass_type_e,        cross_2_bypass_type,       UVM_DEFAULT)
        `uvm_field_array_int    (cross_2_bypass_type_dist,                         UVM_DEFAULT | UVM_DEC)
    `uvm_object_utils_end

    function new (string name = "cross_2_config");
        super.new(name);
    endfunction : new

    constraint cross_2_type_dist_c {
        cross_2_type_dist.sum == 100;
        cross_2_type_dist.size()==CROSS_2_TYPE_END;
        foreach(cross_2_type_dist[i])
            cross_2_type_dist[i] inside {[1:100]};
    }
    constraint cross_2_bypass_type_dist_c {
        cross_2_bypass_type_dist.sum == 100;
        cross_2_bypass_type_dist.size()==CROSS_2_BYPASS_TYPE_END;
        foreach(cross_2_bypass_type_dist[i])
            cross_2_bypass_type_dist[i] inside {[1:100]};
    }

endclass : cross_2_config

class cross_3_config extends uvm_object;
    // ===================== cross_3_type 执行单元组合（src） =====================
    bit                 fix_cross_3_type_en=0;
    rand cross_3_type_e       cross_3_type;
    rand int unsigned   cross_3_type_dist[];

    // ===================== cross_3_bypass_type 执行单元组合（bypass） =====================
    bit                 fix_cross_3_bypass_type_en=0;
    rand cross_3_bypass_type_e cross_3_bypass_type;
    rand int unsigned   cross_3_bypass_type_dist[];

    `uvm_object_utils_begin(cross_3_config)
        `uvm_field_int          (fix_cross_3_type_en,                       UVM_DEFAULT)
        `uvm_field_enum         (cross_3_type_e,        cross_3_type,       UVM_DEFAULT)
        `uvm_field_array_int    (cross_3_type_dist,                         UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_cross_3_bypass_type_en,                       UVM_DEFAULT)
        `uvm_field_enum         (cross_3_bypass_type_e,        cross_3_bypass_type,       UVM_DEFAULT)
        `uvm_field_array_int    (cross_3_bypass_type_dist,                         UVM_DEFAULT | UVM_DEC)
    `uvm_object_utils_end

    function new (string name = "cross_3_config");
        super.new(name);
    endfunction : new

    constraint cross_3_type_dist_c {
        cross_3_type_dist.sum == 100;
        cross_3_type_dist.size()==CROSS_3_TYPE_END;
        foreach(cross_3_type_dist[i])
            cross_3_type_dist[i] inside {[1:100]};
    }
    constraint cross_3_bypass_type_dist_c {
        cross_3_bypass_type_dist.sum == 100;
        cross_3_bypass_type_dist.size()==CROSS_3_BYPASS_TYPE_END;
        foreach(cross_3_bypass_type_dist[i])
            cross_3_bypass_type_dist[i] inside {[1:100]};
    }

endclass : cross_3_config

class cross_4_config extends uvm_object;
    // ===================== cross_4_type 执行单元组合（src） =====================
    bit                 fix_cross_4_type_en=0;
    rand cross_4_type_e       cross_4_type;
    rand int unsigned   cross_4_type_dist[];

    // ===================== cross_4_bypass_type 执行单元组合（bypass） =====================
    bit                 fix_cross_4_bypass_type_en=0;
    rand cross_4_bypass_type_e cross_4_bypass_type;
    rand int unsigned   cross_4_bypass_type_dist[];

    `uvm_object_utils_begin(cross_4_config)
        `uvm_field_int          (fix_cross_4_type_en,                       UVM_DEFAULT)
        `uvm_field_enum         (cross_4_type_e,        cross_4_type,       UVM_DEFAULT)
        `uvm_field_array_int    (cross_4_type_dist,                         UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_cross_4_bypass_type_en,                       UVM_DEFAULT)
        `uvm_field_enum         (cross_4_bypass_type_e,        cross_4_bypass_type,       UVM_DEFAULT)
        `uvm_field_array_int    (cross_4_bypass_type_dist,                         UVM_DEFAULT | UVM_DEC)
    `uvm_object_utils_end

    function new (string name = "cross_4_config");
        super.new(name);
    endfunction : new

    constraint cross_4_type_dist_c {
        cross_4_type_dist.sum == 1000;
        cross_4_type_dist.size()==CROSS_4_TYPE_END;
        foreach(cross_4_type_dist[i])
            cross_4_type_dist[i] inside {[1:1000]};
    }
    constraint cross_4_bypass_type_dist_c {
        cross_4_bypass_type_dist.sum == 1000;
        cross_4_bypass_type_dist.size()==CROSS_4_BYPASS_TYPE_END;
        foreach(cross_4_bypass_type_dist[i])
            cross_4_bypass_type_dist[i] inside {[1:1000]};
    }

endclass : cross_4_config

class cross_5_config extends uvm_object;
    // ===================== cross_5_type 执行单元组合（src） =====================
    bit                 fix_cross_5_type_en=0;
    rand cross_5_type_e       cross_5_type;
    rand int unsigned   cross_5_type_dist[];

    // ===================== cross_5_bypass_type 执行单元组合（bypass） =====================
    bit                 fix_cross_5_bypass_type_en=0;
    rand cross_5_bypass_type_e cross_5_bypass_type;
    rand int unsigned   cross_5_bypass_type_dist[];

    `uvm_object_utils_begin(cross_5_config)
        `uvm_field_int          (fix_cross_5_type_en,                       UVM_DEFAULT)
        `uvm_field_enum         (cross_5_type_e,        cross_5_type,       UVM_DEFAULT)
        `uvm_field_array_int    (cross_5_type_dist,                         UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_cross_5_bypass_type_en,                       UVM_DEFAULT)
        `uvm_field_enum         (cross_5_bypass_type_e,        cross_5_bypass_type,       UVM_DEFAULT)
        `uvm_field_array_int    (cross_5_bypass_type_dist,                         UVM_DEFAULT | UVM_DEC)
    `uvm_object_utils_end

    function new (string name = "cross_5_config");
        super.new(name);
    endfunction : new

    constraint cross_5_type_dist_c {
        cross_5_type_dist.sum == 1000;
        cross_5_type_dist.size()==CROSS_5_TYPE_END;
        foreach(cross_5_type_dist[i])
            cross_5_type_dist[i] inside {[1:1000]};
    }
    constraint cross_5_bypass_type_dist_c {
        cross_5_bypass_type_dist.sum == 1000;
        cross_5_bypass_type_dist.size()==CROSS_5_BYPASS_TYPE_END;
        foreach(cross_5_bypass_type_dist[i])
            cross_5_bypass_type_dist[i] inside {[1:1000]};
    }

endclass : cross_5_config

class cross_6_config extends uvm_object;
    // ===================== cross_6_type 执行单元组合（src） =====================
    bit                 fix_cross_6_type_en=0;
    rand cross_6_type_e       cross_6_type;
    rand int unsigned   cross_6_type_dist[];

    // ===================== cross_6_bypass_type 执行单元组合（bypass） =====================
    bit                 fix_cross_6_bypass_type_en=0;
    rand cross_6_bypass_type_e cross_6_bypass_type;
    rand int unsigned   cross_6_bypass_type_dist[];

    `uvm_object_utils_begin(cross_6_config)
        `uvm_field_int          (fix_cross_6_type_en,                       UVM_DEFAULT)
        `uvm_field_enum         (cross_6_type_e,        cross_6_type,       UVM_DEFAULT)
        `uvm_field_array_int    (cross_6_type_dist,                         UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_cross_6_bypass_type_en,                       UVM_DEFAULT)
        `uvm_field_enum         (cross_6_bypass_type_e,        cross_6_bypass_type,       UVM_DEFAULT)
        `uvm_field_array_int    (cross_6_bypass_type_dist,                         UVM_DEFAULT | UVM_DEC)
    `uvm_object_utils_end

    function new (string name = "cross_6_config");
        super.new(name);
    endfunction : new

    constraint cross_6_type_dist_c {
        cross_6_type_dist.sum == 1000;
        cross_6_type_dist.size()==CROSS_6_TYPE_END;
        foreach(cross_6_type_dist[i])
            cross_6_type_dist[i] inside {[1:1000]};
    }
    constraint cross_6_bypass_type_dist_c {
        cross_6_bypass_type_dist.sum == 1000;
        cross_6_bypass_type_dist.size()==CROSS_6_BYPASS_TYPE_END;
        foreach(cross_6_bypass_type_dist[i])
            cross_6_bypass_type_dist[i] inside {[1:1000]};
    }

endclass : cross_6_config

class cross_7_config extends uvm_object;
    // ===================== cross_7_type 执行单元组合（src） =====================
    bit                 fix_cross_7_type_en=0;
    rand cross_7_type_e       cross_7_type;
    rand int unsigned   cross_7_type_dist[];

    // ===================== cross_7_bypass_type 执行单元组合（bypass） =====================
    bit                 fix_cross_7_bypass_type_en=0;
    rand cross_7_bypass_type_e cross_7_bypass_type;
    rand int unsigned   cross_7_bypass_type_dist[];

    `uvm_object_utils_begin(cross_7_config)
        `uvm_field_int          (fix_cross_7_type_en,                       UVM_DEFAULT)
        `uvm_field_enum         (cross_7_type_e,        cross_7_type,       UVM_DEFAULT)
        `uvm_field_array_int    (cross_7_type_dist,                         UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_cross_7_bypass_type_en,                       UVM_DEFAULT)
        `uvm_field_enum         (cross_7_bypass_type_e,        cross_7_bypass_type,       UVM_DEFAULT)
        `uvm_field_array_int    (cross_7_bypass_type_dist,                         UVM_DEFAULT | UVM_DEC)
    `uvm_object_utils_end

    function new (string name = "cross_7_config");
        super.new(name);
    endfunction : new

    constraint cross_7_type_dist_c {
        cross_7_type_dist.sum == 1000;
        cross_7_type_dist.size()==CROSS_7_TYPE_END;
        foreach(cross_7_type_dist[i])
            cross_7_type_dist[i] inside {[1:1000]};
    }
    constraint cross_7_bypass_type_dist_c {
        cross_7_bypass_type_dist.sum == 1000;
        cross_7_bypass_type_dist.size()==CROSS_7_BYPASS_TYPE_END;
        foreach(cross_7_bypass_type_dist[i])
            cross_7_bypass_type_dist[i] inside {[1:1000]};
    }

endclass : cross_7_config

class cross_8_config extends uvm_object;
    // ===================== cross_8_type 执行单元组合（src） =====================
    bit                 fix_cross_8_type_en=0;
    rand cross_8_type_e       cross_8_type;
    rand int unsigned   cross_8_type_dist[];

    // ===================== cross_8_bypass_type 执行单元组合（bypass） =====================
    bit                 fix_cross_8_bypass_type_en=0;
    rand cross_8_bypass_type_e cross_8_bypass_type;
    rand int unsigned   cross_8_bypass_type_dist[];

    `uvm_object_utils_begin(cross_8_config)
        `uvm_field_int          (fix_cross_8_type_en,                       UVM_DEFAULT)
        `uvm_field_enum         (cross_8_type_e,        cross_8_type,       UVM_DEFAULT)
        `uvm_field_array_int    (cross_8_type_dist,                         UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_cross_8_bypass_type_en,                       UVM_DEFAULT)
        `uvm_field_enum         (cross_8_bypass_type_e,        cross_8_bypass_type,       UVM_DEFAULT)
        `uvm_field_array_int    (cross_8_bypass_type_dist,                         UVM_DEFAULT | UVM_DEC)
    `uvm_object_utils_end

    function new (string name = "cross_8_config");
        super.new(name);
    endfunction : new

    constraint cross_8_type_dist_c {
        cross_8_type_dist.sum == 100;
        cross_8_type_dist.size()==CROSS_8_TYPE_END;
        foreach(cross_8_type_dist[i])
            cross_8_type_dist[i] inside {[1:100]};
    }
    constraint cross_8_bypass_type_dist_c {
        cross_8_bypass_type_dist.sum == 100;
        cross_8_bypass_type_dist.size()==CROSS_8_BYPASS_TYPE_END;
        foreach(cross_8_bypass_type_dist[i])
            cross_8_bypass_type_dist[i] inside {[1:100]};
    }

endclass : cross_8_config

class cross_9_config extends uvm_object;
    // ===================== cross_9_type 执行单元组合（src） =====================
    bit                 fix_cross_9_type_en=0;
    rand cross_9_type_e       cross_9_type;
    rand int unsigned   cross_9_type_dist[];

    // ===================== cross_9_bypass_type 执行单元组合（bypass） =====================
    bit                 fix_cross_9_bypass_type_en=0;
    rand cross_9_bypass_type_e cross_9_bypass_type;
    rand int unsigned   cross_9_bypass_type_dist[];

    `uvm_object_utils_begin(cross_9_config)
        `uvm_field_int          (fix_cross_9_type_en,                       UVM_DEFAULT)
        `uvm_field_enum         (cross_9_type_e,        cross_9_type,       UVM_DEFAULT)
        `uvm_field_array_int    (cross_9_type_dist,                         UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_cross_9_bypass_type_en,                       UVM_DEFAULT)
        `uvm_field_enum         (cross_9_bypass_type_e,        cross_9_bypass_type,       UVM_DEFAULT)
        `uvm_field_array_int    (cross_9_bypass_type_dist,                         UVM_DEFAULT | UVM_DEC)
    `uvm_object_utils_end

    function new (string name = "cross_9_config");
        super.new(name);
    endfunction : new

    constraint cross_9_type_dist_c {
        cross_9_type_dist.sum == 100;
        cross_9_type_dist.size()==CROSS_9_TYPE_END;
        foreach(cross_9_type_dist[i])
            cross_9_type_dist[i] inside {[1:100]};
    }
    constraint cross_9_bypass_type_dist_c {
        cross_9_bypass_type_dist.sum == 100;
        cross_9_bypass_type_dist.size()==CROSS_9_BYPASS_TYPE_END;
        foreach(cross_9_bypass_type_dist[i])
            cross_9_bypass_type_dist[i] inside {[1:100]};
    }

endclass : cross_9_config

class cross_10_config extends uvm_object;
    // ===================== cross_10_type 执行单元组合（src） =====================
    bit                 fix_cross_10_type_en=0;
    rand cross_10_type_e      cross_10_type;
    rand int unsigned   cross_10_type_dist[];

    // ===================== cross_10_bypass_type 执行单元组合（bypass） =====================
    bit                 fix_cross_10_bypass_type_en=0;
    rand cross_10_bypass_type_e cross_10_bypass_type;
    rand int unsigned   cross_10_bypass_type_dist[];

    `uvm_object_utils_begin(cross_10_config)
        `uvm_field_int          (fix_cross_10_type_en,                       UVM_DEFAULT)
        `uvm_field_enum         (cross_10_type_e,        cross_10_type,       UVM_DEFAULT)
        `uvm_field_array_int    (cross_10_type_dist,                         UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_cross_10_bypass_type_en,                       UVM_DEFAULT)
        `uvm_field_enum         (cross_10_bypass_type_e,        cross_10_bypass_type,       UVM_DEFAULT)
        `uvm_field_array_int    (cross_10_bypass_type_dist,                         UVM_DEFAULT | UVM_DEC)
    `uvm_object_utils_end

    function new (string name = "cross_10_config");
        super.new(name);
    endfunction : new

    constraint cross_10_type_dist_c {
        cross_10_type_dist.sum == 100;
        cross_10_type_dist.size()==CROSS_10_TYPE_END;
        foreach(cross_10_type_dist[i])
            cross_10_type_dist[i] inside {[1:100]};
    }
    constraint cross_10_bypass_type_dist_c {
        cross_10_bypass_type_dist.sum == 100;
        cross_10_bypass_type_dist.size()==CROSS_10_BYPASS_TYPE_END;
        foreach(cross_10_bypass_type_dist[i])
            cross_10_bypass_type_dist[i] inside {[1:100]};
    }

endclass : cross_10_config

class cross_11_config extends uvm_object;
    // ===================== cross_11_bypass_type 执行单元组合（bypass） =====================
    bit                 fix_cross_11_bypass_type_en=0;
    rand cross_11_bypass_type_e cross_11_bypass_type;
    rand int unsigned   cross_11_bypass_type_dist[];

    `uvm_object_utils_begin(cross_11_config)
        `uvm_field_int          (fix_cross_11_bypass_type_en,                       UVM_DEFAULT)
        `uvm_field_enum         (cross_11_bypass_type_e,        cross_11_bypass_type,       UVM_DEFAULT)
        `uvm_field_array_int    (cross_11_bypass_type_dist,                         UVM_DEFAULT | UVM_DEC)
    `uvm_object_utils_end

    function new (string name = "cross_11_config");
        super.new(name);
    endfunction : new

    constraint cross_11_bypass_type_dist_c {
        cross_11_bypass_type_dist.sum == 100;
        cross_11_bypass_type_dist.size()==CROSS_11_BYPASS_TYPE_END;
        foreach(cross_11_bypass_type_dist[i])
            cross_11_bypass_type_dist[i] inside {[1:100]};
    }

endclass : cross_11_config
`endif
