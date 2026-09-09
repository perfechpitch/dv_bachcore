// ============================================================================
// Filename             : inst_gen_seq_lib.sv
// Author               : kippy
// Created On           : 2026-6-25
// Last Modified        :
// Update Count         :
// Description          : inst_gen sequence library，用户自定义模式按 case_type_dist 选 seq
// ============================================================================
`ifndef INST_GEN_SEQ_LIB_SV
`define INST_GEN_SEQ_LIB_SV
class inst_gen_seq_lib extends uvm_sequence_library #(inst_gen_seq_item);
    `uvm_object_utils(inst_gen_seq_lib)
    `uvm_sequence_library_utils(inst_gen_seq_lib)
    `uvm_declare_p_sequencer(inst_gen_sequencer)

    function new(string name = "inst_gen_seq_lib");
        super.new(name);
        init_sequence_library();
        selection_mode    = UVM_SEQ_LIB_USER;
        min_random_count  = 10;
        max_random_count  = 10;
    endfunction

    function void pre_randomize();
        if (p_sequencer != null && p_sequencer.inst_gen_cfg != null) begin
            min_random_count = p_sequencer.inst_gen_cfg.inst_seq_length;
            max_random_count = p_sequencer.inst_gen_cfg.inst_seq_length;
        end
    endfunction

    virtual function int unsigned select_sequence(int unsigned max);
        case_type_seq_item case_item;

        case_item = case_type_seq_item::type_id::create("case_item");
        case_item.inst_gen_cfg = p_sequencer.inst_gen_cfg;
        if (!case_item.randomize()) begin
            `uvm_fatal(get_type_name(), "Failed to randomize case_type_seq_item")
        end

        if (case_item.case_type > max) begin
            `uvm_error(get_type_name(),$sformatf("case_type %0d out of range [0:%0d], use 0",case_item.case_type, max))
            select_sequence = 0;
        end else begin
            select_sequence = case_item.case_type;
        end

        `uvm_info(get_type_name(),
            $sformatf("select case_type %0d -> sequence[%0d]",
                      case_item.case_type, select_sequence),
            UVM_HIGH)
    endfunction
endclass : inst_gen_seq_lib
`endif
