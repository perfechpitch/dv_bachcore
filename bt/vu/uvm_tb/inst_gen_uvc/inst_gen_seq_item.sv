// ============================================================================
// Filename             : inst_gen_seq_item.sv
// Author               : kippy
// Created On           : 2026-6-24 15:46
// Last Modified        :
// Update Count         :
// Description          :
// ============================================================================
`ifndef INST_GEN_SEQ_ITEM_SV
`define INST_GEN_SEQ_ITEM_SV     
class inst_gen_base_seq_item extends uvm_sequence_item;                                  
    rand logic [`REG_WIDTH-1:0]  rs1_data;
    rand logic [`REG_WIDTH-1:0]  rs2_data;
    rand logic [`IMM_WIDTH-1:0]  imm;
    rand inst_e                   inst;

    inst_gen_config     inst_gen_cfg;

    `uvm_object_utils_begin(inst_gen_base_seq_item)
        `uvm_field_int          (rs1_data,                                  UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (rs2_data,                                  UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (imm,                                       UVM_DEFAULT | UVM_DEC)  
        `uvm_field_enum         (inst_e,                inst,               UVM_DEFAULT)
    `uvm_object_utils_end
    
    function new (string name = "inst_gen_base_seq_item");
        super.new(name);
    endfunction : new

    constraint rs1_data_c {
        if(inst_gen_cfg.fix_rs1_data_en) {
            rs1_data == inst_gen_cfg.rs1_data;
        }
    }
    constraint rs2_data_c {
        if(inst_gen_cfg.fix_rs2_data_en) {
            rs2_data == inst_gen_cfg.rs2_data;
        }
    }
    constraint imm_c {
        if(inst_gen_cfg.fix_imm_en) {
            imm == inst_gen_cfg.imm;
        }
    }
    constraint inst_c {
        if(inst_gen_cfg.fix_inst_en) {
            inst == inst_gen_cfg.inst;
        } else {
            inst dist {
                DSARI := inst_gen_cfg.inst_dist[DSARI],
                DSAR  := inst_gen_cfg.inst_dist[DSAR],
                DSAWI := inst_gen_cfg.inst_dist[DSAWI],
                DSAW  := inst_gen_cfg.inst_dist[DSAW]
            };
        }
    }
endclass : inst_gen_base_seq_item

class inst_gen_seq_item extends inst_gen_base_seq_item;                                  
    rand inst_type_e             inst_type;
    rand mu_inst_type_e          mu_inst_type;
    rand vu_inst_type_e          vu_inst_type;
    rand logic [31:0]            vinst;
    rand logic [31:0]            minst;
    rand int                    vld_delay;
    rand bit                    src_bypass;

    `uvm_object_utils_begin(inst_gen_seq_item)
        `uvm_field_enum         (inst_type_e,           inst_type,          UVM_DEFAULT)
        `uvm_field_enum         (mu_inst_type_e,        mu_inst_type,       UVM_DEFAULT)
        `uvm_field_enum         (vu_inst_type_e,        vu_inst_type,       UVM_DEFAULT)
        `uvm_field_int          (vinst,                                     UVM_DEFAULT)
        `uvm_field_int          (minst,                                     UVM_DEFAULT)
        `uvm_field_int          (vld_delay,                                 UVM_DEFAULT | UVM_DEC)
        `uvm_field_int          (src_bypass,                                UVM_DEFAULT)
    `uvm_object_utils_end
    
    function new (string name = "inst_gen_seq_item");
        super.new(name);
    endfunction : new

    constraint inst_type_c {
        if(inst_gen_cfg.fix_inst_type_en) {
            inst_type == inst_gen_cfg.inst_type;
        } else {
            inst_type dist {
                MU_INST := inst_gen_cfg.inst_type_dist[MU_INST],
                VU_INST := inst_gen_cfg.inst_type_dist[VU_INST]
            };
        }
    }
    constraint mu_inst_type_c {
        if(inst_gen_cfg.fix_mu_inst_type_en) {
            mu_inst_type == inst_gen_cfg.mu_inst_type;
        } else {
            mu_inst_type dist {
                MU_INST_TYPE_NONE := inst_gen_cfg.mu_inst_type_dist[MU_INST_TYPE_NONE],
                MU_INST_TYPE_ADD  := inst_gen_cfg.mu_inst_type_dist[MU_INST_TYPE_ADD],
                MU_INST_TYPE_SUB  := inst_gen_cfg.mu_inst_type_dist[MU_INST_TYPE_SUB],
                MU_INST_TYPE_MUL  := inst_gen_cfg.mu_inst_type_dist[MU_INST_TYPE_MUL],
                MU_INST_TYPE_DIV  := inst_gen_cfg.mu_inst_type_dist[MU_INST_TYPE_DIV],
                MU_INST_TYPE_MOD  := inst_gen_cfg.mu_inst_type_dist[MU_INST_TYPE_MOD]
            };
        }
    }
    constraint vu_inst_type_c {
        if (inst_gen_cfg.fix_vu_inst_type_en) {
            vu_inst_type == inst_gen_cfg.vu_inst_type;
        } else {
            vu_inst_type dist {
                CROSS_INST_1             := inst_gen_cfg.vu_inst_type_dist[CROSS_INST_1],
                CROSS_INST_2             := inst_gen_cfg.vu_inst_type_dist[CROSS_INST_2],
                CROSS_INST_3             := inst_gen_cfg.vu_inst_type_dist[CROSS_INST_3],
                CROSS_INST_4             := inst_gen_cfg.vu_inst_type_dist[CROSS_INST_4],
                CROSS_INST_5             := inst_gen_cfg.vu_inst_type_dist[CROSS_INST_5],
                CROSS_INST_6             := inst_gen_cfg.vu_inst_type_dist[CROSS_INST_6],
                CROSS_INST_7             := inst_gen_cfg.vu_inst_type_dist[CROSS_INST_7],
                CROSS_INST_8             := inst_gen_cfg.vu_inst_type_dist[CROSS_INST_8],
                CROSS_INST_9             := inst_gen_cfg.vu_inst_type_dist[CROSS_INST_9],
                CROSS_INST_10            := inst_gen_cfg.vu_inst_type_dist[CROSS_INST_10],
                CROSS_INST_11            := inst_gen_cfg.vu_inst_type_dist[CROSS_INST_11]
            };
        }
    }
    constraint vld_delay_c {
        if(inst_gen_cfg.fix_vld_delay_en) {
            vld_delay == inst_gen_cfg.vld_delay;
        } else {
            vld_delay dist {              
                0        := inst_gen_cfg.vld_delay_dist[0],
                [1:10]   := inst_gen_cfg.vld_delay_dist[1],
                [11:50]  := inst_gen_cfg.vld_delay_dist[2],
                [51:100] := inst_gen_cfg.vld_delay_dist[3]
            };
        }
    }
    constraint src_bypass_c {
        // cross_1 无 bypass；仅 cross_2~11 可选 cross_N_gen / cross_N_bypass_gen
        if (vu_inst_type == CROSS_INST_1) {
            src_bypass == 1'b0;
        } else if(inst_gen_cfg.fix_src_bypass_en) {
            src_bypass == inst_gen_cfg.src_bypass;
        } else {
            src_bypass dist {
                1 := inst_gen_cfg.src_bypass_weight,
                0 := 100 - inst_gen_cfg.src_bypass_weight
            };
        }
    }
endclass : inst_gen_seq_item

class case_type_seq_item extends uvm_sequence_item;                                  
    rand int            case_type;
    inst_gen_config     inst_gen_cfg;

    `uvm_object_utils_begin(case_type_seq_item)
        `uvm_field_int          (case_type,                                 UVM_DEFAULT | UVM_DEC)
    `uvm_object_utils_end
    
    function new (string name = "case_type_seq_item");
        super.new(name);
    endfunction : new

    constraint case_type_c {
            case_type dist {
                0       := inst_gen_cfg.case_type_dist[0],
                1       := inst_gen_cfg.case_type_dist[1],
                2       := inst_gen_cfg.case_type_dist[2],
                3       := inst_gen_cfg.case_type_dist[3]
            };
    }
endclass : case_type_seq_item
`endif
