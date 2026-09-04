// 一次抽取的结果。对照 inst_name_generator.inst_name，这里是 inst_seq_type。
class inst_seq_type_item extends uvm_object;
    inst_seq_type_config inst_seq_type_cfg;
    rand inst_seq_type_e inst_seq_type;

    `uvm_object_utils_begin(inst_seq_type_item)
        `uvm_field_enum(inst_seq_type_e, inst_seq_type, UVM_DEFAULT)
    `uvm_object_utils_end

    function new (string name = "inst_seq_type_item");
        super.new(name);
    endfunction : new

    constraint inst_seq_type_c{
        inst_seq_type dist{
            SAFE_INST_SEQ   := inst_seq_type_cfg.safe_seq_dist,
            LS_INST_SEQ     := inst_seq_type_cfg.ls_seq_dist,
            BRANCH_INST_SEQ := inst_seq_type_cfg.branch_seq_dist,
            FLUSH_INST_SEQ  := inst_seq_type_cfg.flush_seq_dist,
            EXCEPT_INST_SEQ := inst_seq_type_cfg.except_seq_dist,
            WFI_INST_SEQ    := inst_seq_type_cfg.wfi_seq_dist
        };
    }
endclass
