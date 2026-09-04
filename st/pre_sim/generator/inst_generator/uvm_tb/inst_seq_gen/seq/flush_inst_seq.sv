class flush_inst_sequence extends base_inst_sequence;
    inst_seq_config     flush_seq_cfg;
    inst_seq_info_item  inst_seq_info;

    inst_generator      inst_gen;
    `uvm_object_utils_begin(flush_inst_sequence)
    `uvm_object_utils_end
    // new - constructor
    function new (string name = "flush_inst_sequence");
      super.new(name);
      inst_seq_info = new();
    endfunction : new

    virtual function inst_seq_info_item seq_gen();
        int seq_length;
        inst_seq_info.inst_seq_cfg = flush_seq_cfg;
        assert(inst_seq_info.randomize());
        inst_gen.insert_inst(inst_seq_info.seq_length,FLUSH_INST);
        return inst_seq_info;
    endfunction
endclass 
