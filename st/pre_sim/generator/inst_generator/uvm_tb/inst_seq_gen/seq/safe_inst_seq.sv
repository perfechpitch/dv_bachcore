class safe_inst_sequence extends base_inst_sequence;
    safe_seq_config     safe_seq_cfg;
    inst_seq_info_item  inst_seq_info;
    inst_generator      inst_gen;
    `uvm_object_utils_begin(safe_inst_sequence)
    `uvm_object_utils_end
    // new - constructor
    function new (string name = "safe_inst_sequence");
      super.new(name);
      inst_seq_info = new();
    endfunction : new

    virtual function inst_seq_info_item seq_gen();
        int seq_length;
        inst_seq_info.inst_seq_cfg = safe_seq_cfg;
        assert(inst_seq_info.randomize());
        seq_length = inst_seq_info.seq_length;

        inst_gen.safe_inst_gen.safe_int_cal_dist      = safe_seq_cfg.safe_int_cal_dist      ;
        inst_gen.safe_inst_gen.safe_float_cal_dist    = safe_seq_cfg.safe_float_cal_dist    ;
        inst_gen.safe_inst_gen.safe_branch_dist       = safe_seq_cfg.safe_branch_dist       ;
        inst_gen.safe_inst_gen.safe_int_ls_dist       = safe_seq_cfg.safe_int_ls_dist       ;


        $fwrite(inst_gen.gen_file,("// --------------  SAFE INST SEQ with %d safe insts\n"),seq_length);
        inst_gen.insert_inst(seq_length,SAFE_INST);
        $fwrite(inst_gen.gen_file,("// --------------  SAFE INST SEQ end!!\n"));
        return inst_seq_info;
    endfunction
endclass 
