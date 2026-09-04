class wfi_inst_sequence extends base_inst_sequence;
    inst_seq_info_item  inst_seq_info;

    inst_generator      inst_gen;
    `uvm_object_utils_begin(wfi_inst_sequence)
    `uvm_object_utils_end
    // new - constructor
    function new (string name = "wfi_inst_sequence");
      super.new(name);
      inst_seq_info = new();
    endfunction : new

    virtual function inst_seq_info_item seq_gen();
        inst_gen.get_specified_rand_inst(WFI);
        inst_seq_info.seq_length = 1;
        inst_seq_info.seq_length_type = inst_seq_info_item::MIN;
        return inst_seq_info;
    endfunction
endclass
