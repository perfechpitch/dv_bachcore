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
class cross_1_config extends uvm_object;
    // ===================== cross_inst_1 分层控制（op 单元 + 子类型） =====================
    bit                 fix_cross_inst_1_op_en=0;
    rand cross_inst_1_op_e        cross_inst_1_op;
    rand int unsigned   cross_inst_1_op_dist[];
    bit                 fix_cross_inst_1_lu_type_en=0;
    rand vu_lu_type_e             cross_inst_1_lu_type;
    rand int unsigned   cross_inst_1_lu_type_dist[];
    bit                 fix_cross_inst_1_su_type_en=0;
    rand vu_su_type_e             cross_inst_1_su_type;
    rand int unsigned   cross_inst_1_su_type_dist[];
    bit                 fix_cross_inst_1_valu0_type_en=0;
    rand vu_valu0_type_e          cross_inst_1_valu0_type;
    rand int unsigned   cross_inst_1_valu0_type_dist[];
    bit                 fix_cross_inst_1_valu1_type_en=0;
    rand vu_valu1_type_e          cross_inst_1_valu1_type;
    rand int unsigned   cross_inst_1_valu1_type_dist[];
    bit                 fix_cross_inst_1_valu2_type_en=0;
    rand vu_valu2_type_e          cross_inst_1_valu2_type;
    rand int unsigned   cross_inst_1_valu2_type_dist[];
    bit                 fix_cross_inst_1_vsfu0_type_en=0;
    rand vu_vsfu_type_e           cross_inst_1_vsfu0_type;
    rand int unsigned   cross_inst_1_vsfu0_type_dist[];
    bit                 fix_cross_inst_1_vsfu1_type_en=0;
    rand vu_vsfu_type_e           cross_inst_1_vsfu1_type;
    rand int unsigned   cross_inst_1_vsfu1_type_dist[];
    bit                 fix_cross_inst_1_mexe_type_en=0;
    rand vu_mexe_type_e           cross_inst_1_mexe_type;
    rand int unsigned   cross_inst_1_mexe_type_dist[];
    bit                 fix_cross_inst_1_sexe_type_en=0;
    rand vu_sexe_type_e           cross_inst_1_sexe_type;
    rand int unsigned   cross_inst_1_sexe_type_dist[];

    `uvm_object_utils_begin(cross_1_config)
        `uvm_field_int          (fix_cross_inst_1_op_en,                  UVM_DEFAULT)
        `uvm_field_enum         (cross_inst_1_op_e,        cross_inst_1_op,       UVM_DEFAULT)
        `uvm_field_array_int    (cross_inst_1_op_dist,                    UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_cross_inst_1_lu_type_en,                       UVM_DEFAULT)
        `uvm_field_enum         (vu_lu_type_e,        cross_inst_1_lu_type,       UVM_DEFAULT)
        `uvm_field_array_int    (cross_inst_1_lu_type_dist,                         UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_cross_inst_1_su_type_en,                       UVM_DEFAULT)
        `uvm_field_enum         (vu_su_type_e,        cross_inst_1_su_type,       UVM_DEFAULT)
        `uvm_field_array_int    (cross_inst_1_su_type_dist,                         UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_cross_inst_1_valu0_type_en,                       UVM_DEFAULT)
        `uvm_field_enum         (vu_valu0_type_e,        cross_inst_1_valu0_type,       UVM_DEFAULT)
        `uvm_field_array_int    (cross_inst_1_valu0_type_dist,                         UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_cross_inst_1_valu1_type_en,                       UVM_DEFAULT)
        `uvm_field_enum         (vu_valu1_type_e,        cross_inst_1_valu1_type,       UVM_DEFAULT)
        `uvm_field_array_int    (cross_inst_1_valu1_type_dist,                         UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_cross_inst_1_valu2_type_en,                       UVM_DEFAULT)
        `uvm_field_enum         (vu_valu2_type_e,        cross_inst_1_valu2_type,       UVM_DEFAULT)
        `uvm_field_array_int    (cross_inst_1_valu2_type_dist,                         UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_cross_inst_1_vsfu0_type_en,                       UVM_DEFAULT)
        `uvm_field_enum         (vu_vsfu_type_e,        cross_inst_1_vsfu0_type,       UVM_DEFAULT)
        `uvm_field_array_int    (cross_inst_1_vsfu0_type_dist,                         UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_cross_inst_1_vsfu1_type_en,                       UVM_DEFAULT)
        `uvm_field_enum         (vu_vsfu_type_e,        cross_inst_1_vsfu1_type,       UVM_DEFAULT)
        `uvm_field_array_int    (cross_inst_1_vsfu1_type_dist,                         UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_cross_inst_1_mexe_type_en,                       UVM_DEFAULT)
        `uvm_field_enum         (vu_mexe_type_e,        cross_inst_1_mexe_type,       UVM_DEFAULT)
        `uvm_field_array_int    (cross_inst_1_mexe_type_dist,                         UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_cross_inst_1_sexe_type_en,                       UVM_DEFAULT)
        `uvm_field_enum         (vu_sexe_type_e,        cross_inst_1_sexe_type,       UVM_DEFAULT)
        `uvm_field_array_int    (cross_inst_1_sexe_type_dist,                         UVM_DEFAULT | UVM_DEC)
    `uvm_object_utils_end

    function new (string name = "cross_1_config");
        super.new(name);
    endfunction : new

    constraint cross_inst_1_op_dist_c {
        cross_inst_1_op_dist.sum == 100;
        cross_inst_1_op_dist.size()==CROSS_INST_1_OP_END;
        foreach(cross_inst_1_op_dist[i])
            cross_inst_1_op_dist[i] inside {[0:100]};
    }

    constraint cross_inst_1_lu_type_dist_c {
        cross_inst_1_lu_type_dist.sum == 100;
        cross_inst_1_lu_type_dist.size()==VU_LU_TYPE_END;
        foreach(cross_inst_1_lu_type_dist[i])
            cross_inst_1_lu_type_dist[i] inside {[0:100]};
    }

    constraint cross_inst_1_su_type_dist_c {
        cross_inst_1_su_type_dist.sum == 100;
        cross_inst_1_su_type_dist.size()==VU_SU_TYPE_END;
        foreach(cross_inst_1_su_type_dist[i])
            cross_inst_1_su_type_dist[i] inside {[0:100]};
    }

    constraint cross_inst_1_valu0_type_dist_c {
        cross_inst_1_valu0_type_dist.sum == 100;
        cross_inst_1_valu0_type_dist.size()==VU_VALU0_TYPE_END;
        foreach(cross_inst_1_valu0_type_dist[i])
            cross_inst_1_valu0_type_dist[i] inside {[0:100]};
    }

    constraint cross_inst_1_valu1_type_dist_c {
        cross_inst_1_valu1_type_dist.sum == 100;
        cross_inst_1_valu1_type_dist.size()==VU_VALU1_TYPE_END;
        foreach(cross_inst_1_valu1_type_dist[i])
            cross_inst_1_valu1_type_dist[i] inside {[0:100]};
    }

    constraint cross_inst_1_valu2_type_dist_c {
        cross_inst_1_valu2_type_dist.sum == 100;
        cross_inst_1_valu2_type_dist.size()==VU_VALU2_TYPE_END;
        foreach(cross_inst_1_valu2_type_dist[i])
            cross_inst_1_valu2_type_dist[i] inside {[0:100]};
    }

    constraint cross_inst_1_vsfu0_type_dist_c {
        cross_inst_1_vsfu0_type_dist.sum == 100;
        cross_inst_1_vsfu0_type_dist.size()==VU_VSFU_TYPE_END;
        foreach(cross_inst_1_vsfu0_type_dist[i])
            cross_inst_1_vsfu0_type_dist[i] inside {[0:100]};
    }

    constraint cross_inst_1_vsfu1_type_dist_c {
        cross_inst_1_vsfu1_type_dist.sum == 100;
        cross_inst_1_vsfu1_type_dist.size()==VU_VSFU_TYPE_END;
        foreach(cross_inst_1_vsfu1_type_dist[i])
            cross_inst_1_vsfu1_type_dist[i] inside {[0:100]};
    }

    constraint cross_inst_1_mexe_type_dist_c {
        cross_inst_1_mexe_type_dist.sum == 100;
        cross_inst_1_mexe_type_dist.size()==VU_MEXE_TYPE_END;
        foreach(cross_inst_1_mexe_type_dist[i])
            cross_inst_1_mexe_type_dist[i] inside {[0:100]};
    }

    constraint cross_inst_1_sexe_type_dist_c {
        cross_inst_1_sexe_type_dist.sum == 100;
        cross_inst_1_sexe_type_dist.size()==VU_SEXE_TYPE_END;
        foreach(cross_inst_1_sexe_type_dist[i])
            cross_inst_1_sexe_type_dist[i] inside {[0:100]};
    }

endclass : cross_1_config

class cross_2_config extends uvm_object;
    // ===================== cross_inst_2 子类型控制 =====================
    bit                 fix_cross_inst_2_type_en=0;
    rand cross_inst_2_type_e  cross_inst_2_type;
    rand int unsigned   cross_inst_2_type_dist[];

    `uvm_object_utils_begin(cross_2_config)
        `uvm_field_int          (fix_cross_inst_2_type_en,                       UVM_DEFAULT)
        `uvm_field_enum         (cross_inst_2_type_e,        cross_inst_2_type,       UVM_DEFAULT)
        `uvm_field_array_int    (cross_inst_2_type_dist,                         UVM_DEFAULT | UVM_DEC)
    `uvm_object_utils_end

    function new (string name = "cross_2_config");
        super.new(name);
    endfunction : new

    constraint cross_inst_2_type_dist_c {
        cross_inst_2_type_dist.sum == 100;
        cross_inst_2_type_dist.size()==CROSS_INST_2_TYPE_END;
        foreach(cross_inst_2_type_dist[i])
            cross_inst_2_type_dist[i] inside {[0:100]};
    }

endclass : cross_2_config

class cross_3_config extends uvm_object;
    // ===================== cross_inst_3 子类型控制 =====================
    bit                 fix_cross_inst_3_type_en=0;
    rand cross_inst_3_type_e  cross_inst_3_type;
    rand int unsigned   cross_inst_3_type_dist[];

    `uvm_object_utils_begin(cross_3_config)
        `uvm_field_int          (fix_cross_inst_3_type_en,                       UVM_DEFAULT)
        `uvm_field_enum         (cross_inst_3_type_e,        cross_inst_3_type,       UVM_DEFAULT)
        `uvm_field_array_int    (cross_inst_3_type_dist,                         UVM_DEFAULT | UVM_DEC)
    `uvm_object_utils_end

    function new (string name = "cross_3_config");
        super.new(name);
    endfunction : new

    constraint cross_inst_3_type_dist_c {
        cross_inst_3_type_dist.sum == 100;
        cross_inst_3_type_dist.size()==CROSS_INST_3_TYPE_END;
        foreach(cross_inst_3_type_dist[i])
            cross_inst_3_type_dist[i] inside {[0:100]};
    }

endclass : cross_3_config

class cross_4_config extends uvm_object;
    // ===================== cross_inst_4 子类型控制 =====================
    bit                 fix_cross_inst_4_type_en=0;
    rand cross_inst_4_type_e  cross_inst_4_type;
    rand int unsigned   cross_inst_4_type_dist[];

    `uvm_object_utils_begin(cross_4_config)
        `uvm_field_int          (fix_cross_inst_4_type_en,                       UVM_DEFAULT)
        `uvm_field_enum         (cross_inst_4_type_e,        cross_inst_4_type,       UVM_DEFAULT)
        `uvm_field_array_int    (cross_inst_4_type_dist,                         UVM_DEFAULT | UVM_DEC)
    `uvm_object_utils_end

    function new (string name = "cross_4_config");
        super.new(name);
    endfunction : new

    constraint cross_inst_4_type_dist_c {
        cross_inst_4_type_dist.sum == 100;
        cross_inst_4_type_dist.size()==CROSS_INST_4_TYPE_END;
        foreach(cross_inst_4_type_dist[i])
            cross_inst_4_type_dist[i] inside {[0:100]};
    }

endclass : cross_4_config

class cross_5_config extends uvm_object;
    // ===================== cross_inst_5 子类型控制 =====================
    bit                 fix_cross_inst_5_type_en=0;
    rand cross_inst_5_type_e  cross_inst_5_type;
    rand int unsigned   cross_inst_5_type_dist[];

    `uvm_object_utils_begin(cross_5_config)
        `uvm_field_int          (fix_cross_inst_5_type_en,                       UVM_DEFAULT)
        `uvm_field_enum         (cross_inst_5_type_e,        cross_inst_5_type,       UVM_DEFAULT)
        `uvm_field_array_int    (cross_inst_5_type_dist,                         UVM_DEFAULT | UVM_DEC)
    `uvm_object_utils_end

    function new (string name = "cross_5_config");
        super.new(name);
    endfunction : new

    constraint cross_inst_5_type_dist_c {
        cross_inst_5_type_dist.sum == 100;
        cross_inst_5_type_dist.size()==CROSS_INST_5_TYPE_END;
        foreach(cross_inst_5_type_dist[i])
            cross_inst_5_type_dist[i] inside {[0:100]};
    }

endclass : cross_5_config

class cross_6_config extends uvm_object;
    // ===================== cross_inst_6 子类型控制 =====================
    bit                 fix_cross_inst_6_type_en=0;
    rand cross_inst_6_type_e  cross_inst_6_type;
    rand int unsigned   cross_inst_6_type_dist[];

    `uvm_object_utils_begin(cross_6_config)
        `uvm_field_int          (fix_cross_inst_6_type_en,                       UVM_DEFAULT)
        `uvm_field_enum         (cross_inst_6_type_e,        cross_inst_6_type,       UVM_DEFAULT)
        `uvm_field_array_int    (cross_inst_6_type_dist,                         UVM_DEFAULT | UVM_DEC)
    `uvm_object_utils_end

    function new (string name = "cross_6_config");
        super.new(name);
    endfunction : new

    constraint cross_inst_6_type_dist_c {
        cross_inst_6_type_dist.sum == 100;
        cross_inst_6_type_dist.size()==CROSS_INST_6_TYPE_END;
        foreach(cross_inst_6_type_dist[i])
            cross_inst_6_type_dist[i] inside {[0:100]};
    }

endclass : cross_6_config

class cross_7_config extends uvm_object;
    // ===================== cross_inst_7 子类型控制 =====================
    bit                 fix_cross_inst_7_type_en=0;
    rand cross_inst_7_type_e  cross_inst_7_type;
    rand int unsigned   cross_inst_7_type_dist[];

    `uvm_object_utils_begin(cross_7_config)
        `uvm_field_int          (fix_cross_inst_7_type_en,                       UVM_DEFAULT)
        `uvm_field_enum         (cross_inst_7_type_e,        cross_inst_7_type,       UVM_DEFAULT)
        `uvm_field_array_int    (cross_inst_7_type_dist,                         UVM_DEFAULT | UVM_DEC)
    `uvm_object_utils_end

    function new (string name = "cross_7_config");
        super.new(name);
    endfunction : new

    constraint cross_inst_7_type_dist_c {
        cross_inst_7_type_dist.sum == 100;
        cross_inst_7_type_dist.size()==CROSS_INST_7_TYPE_END;
        foreach(cross_inst_7_type_dist[i])
            cross_inst_7_type_dist[i] inside {[0:100]};
    }

endclass : cross_7_config

class cross_8_config extends uvm_object;
    // ===================== cross_inst_8 子类型控制 =====================
    bit                 fix_cross_inst_8_type_en=0;
    rand cross_inst_8_type_e  cross_inst_8_type;
    rand int unsigned   cross_inst_8_type_dist[];

    `uvm_object_utils_begin(cross_8_config)
        `uvm_field_int          (fix_cross_inst_8_type_en,                       UVM_DEFAULT)
        `uvm_field_enum         (cross_inst_8_type_e,        cross_inst_8_type,       UVM_DEFAULT)
        `uvm_field_array_int    (cross_inst_8_type_dist,                         UVM_DEFAULT | UVM_DEC)
    `uvm_object_utils_end

    function new (string name = "cross_8_config");
        super.new(name);
    endfunction : new

    constraint cross_inst_8_type_dist_c {
        cross_inst_8_type_dist.sum == 100;
        cross_inst_8_type_dist.size()==CROSS_INST_8_TYPE_END;
        foreach(cross_inst_8_type_dist[i])
            cross_inst_8_type_dist[i] inside {[0:100]};
    }

endclass : cross_8_config

class cross_9_config extends uvm_object;
    // ===================== cross_inst_9 子类型控制 =====================
    bit                 fix_cross_inst_9_type_en=0;
    rand cross_inst_9_type_e  cross_inst_9_type;
    rand int unsigned   cross_inst_9_type_dist[];

    `uvm_object_utils_begin(cross_9_config)
        `uvm_field_int          (fix_cross_inst_9_type_en,                       UVM_DEFAULT)
        `uvm_field_enum         (cross_inst_9_type_e,        cross_inst_9_type,       UVM_DEFAULT)
        `uvm_field_array_int    (cross_inst_9_type_dist,                         UVM_DEFAULT | UVM_DEC)
    `uvm_object_utils_end

    function new (string name = "cross_9_config");
        super.new(name);
    endfunction : new

    constraint cross_inst_9_type_dist_c {
        cross_inst_9_type_dist.sum == 100;
        cross_inst_9_type_dist.size()==CROSS_INST_9_TYPE_END;
        foreach(cross_inst_9_type_dist[i])
            cross_inst_9_type_dist[i] inside {[0:100]};
    }

endclass : cross_9_config

class cross_10_config extends uvm_object;
    // ===================== cross_inst_10 子类型控制 =====================
    bit                 fix_cross_inst_10_type_en=0;
    rand cross_inst_10_type_e cross_inst_10_type;
    rand int unsigned   cross_inst_10_type_dist[];

    `uvm_object_utils_begin(cross_10_config)
        `uvm_field_int          (fix_cross_inst_10_type_en,                       UVM_DEFAULT)
        `uvm_field_enum         (cross_inst_10_type_e,        cross_inst_10_type,       UVM_DEFAULT)
        `uvm_field_array_int    (cross_inst_10_type_dist,                         UVM_DEFAULT | UVM_DEC)
    `uvm_object_utils_end

    function new (string name = "cross_10_config");
        super.new(name);
    endfunction : new

    constraint cross_inst_10_type_dist_c {
        cross_inst_10_type_dist.sum == 100;
        cross_inst_10_type_dist.size()==CROSS_INST_10_TYPE_END;
        foreach(cross_inst_10_type_dist[i])
            cross_inst_10_type_dist[i] inside {[0:100]};
    }

endclass : cross_10_config

class cross_11_config extends uvm_object;
    // ===================== cross_inst_11 子类型控制 =====================
    bit                 fix_cross_inst_11_type_en=0;
    rand cross_inst_11_type_e cross_inst_11_type;
    rand int unsigned   cross_inst_11_type_dist[];

    `uvm_object_utils_begin(cross_11_config)
        `uvm_field_int          (fix_cross_inst_11_type_en,                       UVM_DEFAULT)
        `uvm_field_enum         (cross_inst_11_type_e,        cross_inst_11_type,       UVM_DEFAULT)
        `uvm_field_array_int    (cross_inst_11_type_dist,                         UVM_DEFAULT | UVM_DEC)
    `uvm_object_utils_end

    function new (string name = "cross_11_config");
        super.new(name);
    endfunction : new

    constraint cross_inst_11_type_dist_c {
        cross_inst_11_type_dist.sum == 100;
        cross_inst_11_type_dist.size()==CROSS_INST_11_TYPE_END;
        foreach(cross_inst_11_type_dist[i])
            cross_inst_11_type_dist[i] inside {[0:100]};
    }

endclass : cross_11_config

class inst_gen_config extends uvm_object;
    uvm_active_passive_enum is_active = UVM_ACTIVE;
    bit checks_enable   = 1;
    bit coverage_enable = 1;
    // ===================== 指令序列长度控制 =====================
    int unsigned        inst_seq_length=100;
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
    cross_1_config       cross_1_cfg;
    cross_2_config       cross_2_cfg;
    cross_3_config       cross_3_cfg;
    cross_4_config       cross_4_cfg;
    cross_5_config       cross_5_cfg;
    cross_6_config       cross_6_cfg;
    cross_7_config       cross_7_cfg;
    cross_8_config       cross_8_cfg;
    cross_9_config       cross_9_cfg;
    cross_10_config      cross_10_cfg;
    cross_11_config      cross_11_cfg;
    // ===================== VU *_op.OPCODE 控制 =====================
    bit                 fix_lu_op_opcode_en=0;
    rand logic [7:0]    lu_op_opcode;
    bit                 fix_mexe_op_opcode_en=0;
    rand logic [7:0]    mexe_op_opcode;
    bit                 fix_sexe0_op_opcode_en=0;
    rand logic [7:0]    sexe0_op_opcode;
    bit                 fix_sexe1_op_opcode_en=0;
    rand logic [7:0]    sexe1_op_opcode;
    bit                 fix_sexe2_op_opcode_en=0;
    rand logic [7:0]    sexe2_op_opcode;
    bit                 fix_su_op_opcode_en=0;
    rand logic [7:0]    su_op_opcode;
    bit                 fix_valu0_op_opcode_en=0;
    rand logic [7:0]    valu0_op_opcode;
    bit                 fix_valu1_op_opcode_en=0;
    rand logic [7:0]    valu1_op_opcode;
    bit                 fix_valu2_op_opcode_en=0;
    rand logic [7:0]    valu2_op_opcode;
    bit                 fix_vsfu_op_vsfu0_opcode_en=0;
    rand logic [7:0]    vsfu_op_vsfu0_opcode;
    bit                 fix_vsfu_op_vsfu1_opcode_en=0;
    rand logic [7:0]    vsfu_op_vsfu1_opcode;
    // ===================== VU 寄存器位域 fix（含 sheet 固定值字段） =====================
    bit                 fix_inf_replace_value_inf_replace_value_en=0;
    rand logic [31:0]     inf_replace_value_inf_replace_value;
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
    bit                 fix_nan_replace_value_nan_replace_value_en=0;
    rand logic [31:0]     nan_replace_value_nan_replace_value;
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
    // ===================== VRF_WT P0/P1 配对分布 =====================
    rand int unsigned   prf_op_vrf_wt_pair_weight;
    // ===================== SRC/MASK 联合分布 =====================
    rand int unsigned   sel_pair_weight;
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
    // ===================== 场景类型控制 =====================
    rand int unsigned   case_type_dist[];

    `uvm_object_utils_begin(inst_gen_config)
        `uvm_field_enum         (uvm_active_passive_enum,   is_active,      UVM_DEFAULT)
        `uvm_field_int          (checks_enable,                             UVM_DEFAULT) 
        `uvm_field_int          (coverage_enable,                           UVM_DEFAULT)
        `uvm_field_int          (inst_seq_length,                           UVM_DEFAULT | UVM_DEC)
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
        `uvm_field_int          (fix_lu_op_opcode_en,                               UVM_DEFAULT)
        `uvm_field_int          (lu_op_opcode,                                  UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_mexe_op_opcode_en,                               UVM_DEFAULT)
        `uvm_field_int          (mexe_op_opcode,                                  UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_sexe0_op_opcode_en,                               UVM_DEFAULT)
        `uvm_field_int          (sexe0_op_opcode,                                  UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_sexe1_op_opcode_en,                               UVM_DEFAULT)
        `uvm_field_int          (sexe1_op_opcode,                                  UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_sexe2_op_opcode_en,                               UVM_DEFAULT)
        `uvm_field_int          (sexe2_op_opcode,                                  UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_su_op_opcode_en,                               UVM_DEFAULT)
        `uvm_field_int          (su_op_opcode,                                  UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_valu0_op_opcode_en,                               UVM_DEFAULT)
        `uvm_field_int          (valu0_op_opcode,                                  UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_valu1_op_opcode_en,                               UVM_DEFAULT)
        `uvm_field_int          (valu1_op_opcode,                                  UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_valu2_op_opcode_en,                               UVM_DEFAULT)
        `uvm_field_int          (valu2_op_opcode,                                  UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_vsfu_op_vsfu0_opcode_en,                               UVM_DEFAULT)
        `uvm_field_int          (vsfu_op_vsfu0_opcode,                                  UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_vsfu_op_vsfu1_opcode_en,                               UVM_DEFAULT)
        `uvm_field_int          (vsfu_op_vsfu1_opcode,                                  UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (fix_inf_replace_value_inf_replace_value_en,                               UVM_DEFAULT)
        `uvm_field_int          (inf_replace_value_inf_replace_value,                                  UVM_DEFAULT | UVM_DEC)
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
        `uvm_field_int          (fix_nan_replace_value_nan_replace_value_en,                               UVM_DEFAULT)
        `uvm_field_int          (nan_replace_value_nan_replace_value,                                  UVM_DEFAULT | UVM_DEC)
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
        `uvm_field_int          (prf_op_vrf_wt_pair_weight,                  UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (sel_pair_weight,                            UVM_DEFAULT | UVM_DEC)
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
        if (cross_idx > VU_INST_END)
            `uvm_fatal("inst_gen_config", $sformatf("only_one_cross: invalid cross_idx=%0d (valid: 1~%0d)", cross_idx, VU_INST_END))
    endfunction : only_one_cross

    constraint first_delay_c  {
        first_delay inside {[0:10]};
    }

    constraint vld_delay_dist_c  {
         vld_delay_dist.sum == 100;
         vld_delay_dist.size() == 4;
         foreach(vld_delay_dist[i])
             vld_delay_dist[i] inside {[0:100]};
    }

    constraint src_bypass_weight_c {
        src_bypass_weight inside {[0:100]};
    }

    constraint inst_type_dist_c {
        inst_type_dist.sum == 100;
        inst_type_dist.size()==INST_TYPE_END;
        foreach(inst_type_dist[i])
            inst_type_dist[i] inside {[0:100]};
    }

    constraint inst_dist_c {
        inst_dist.sum == 100;
        inst_dist.size() == INST_END;
        foreach(inst_dist[i])
            inst_dist[i] inside {[0:100]};
    }

    constraint mu_inst_type_dist_c {
        mu_inst_type_dist.sum == 100;
        mu_inst_type_dist.size()==MU_INST_END;
        foreach(mu_inst_type_dist[i])
            mu_inst_type_dist[i] inside {[0:100]};
    }

    constraint vu_inst_type_dist_c{
        vu_inst_type_dist.sum == 100;
        vu_inst_type_dist.size()==VU_INST_END;
        foreach(vu_inst_type_dist[i])
            vu_inst_type_dist[i] inside {[0:100]};
    }

    constraint reg_read_addr_cat_dist_c {
        reg_read_addr_cat_dist.sum == 100;
        reg_read_addr_cat_dist.size() == VU_REG_READ_CAT_END;
        foreach (reg_read_addr_cat_dist[i])
            reg_read_addr_cat_dist[i] inside {[0:100]};
    }
    constraint align_addr_weight_c {
        align_addr_weight inside {[0:100]};
    }
    constraint prf_op_vrf_wt_pair_weight_c {
        prf_op_vrf_wt_pair_weight inside {[0:100]};
    }
    constraint sel_pair_weight_c {
        sel_pair_weight inside {[0:100]};
    }

    constraint  case_type_dist_c{
        case_type_dist.sum == 100;
        case_type_dist.size()==4;
        foreach(case_type_dist[i])
            case_type_dist[i] inside {[0:100]};
    }
endclass
`endif
