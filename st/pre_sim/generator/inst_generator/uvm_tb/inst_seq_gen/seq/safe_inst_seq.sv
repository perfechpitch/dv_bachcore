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
        inst_gen.safe_inst_gen.safe_custom_dsa_dist   = safe_seq_cfg.safe_custom_dsa_dist   ;


        $fwrite(inst_gen.gen_file,("// --------------  SAFE INST SEQ with %d safe insts\n"),seq_length);
        inst_gen.insert_inst(seq_length,SAFE_INST);
        $fwrite(inst_gen.gen_file,("// --------------  SAFE INST SEQ end!!\n"));
        return inst_seq_info;
    endfunction

    // Generate an exact number of fall-through integer calculation
    // instructions for dependency gaps.  Reuse the existing SAFE_INT_CAL
    // constraint set instead of maintaining a second instruction allow-list.
    // The safe instruction selector is shared, so restore every weight before
    // returning to avoid changing later normal SAFE sequences.
    virtual function void gen_int_cal_seq(int unsigned inst_num);
        int unsigned old_int_cal_dist;
        int unsigned old_float_cal_dist;
        int unsigned old_branch_dist;
        int unsigned old_int_ls_dist;
        int unsigned old_custom_dsa_dist;

        if(inst_num == 0)
            return;
        if(inst_gen == null)
            `uvm_fatal("GAP_SAFE_SEQ", "safe_inst_sequence has no inst_generator")

        old_int_cal_dist  = inst_gen.safe_inst_gen.safe_int_cal_dist;
        old_float_cal_dist = inst_gen.safe_inst_gen.safe_float_cal_dist;
        old_branch_dist   = inst_gen.safe_inst_gen.safe_branch_dist;
        old_int_ls_dist   = inst_gen.safe_inst_gen.safe_int_ls_dist;
        old_custom_dsa_dist = inst_gen.safe_inst_gen.safe_custom_dsa_dist;

        inst_gen.safe_inst_gen.safe_int_cal_dist    = 1;
        inst_gen.safe_inst_gen.safe_float_cal_dist  = 0;
        inst_gen.safe_inst_gen.safe_branch_dist     = 0;
        inst_gen.safe_inst_gen.safe_int_ls_dist     = 0;
        inst_gen.safe_inst_gen.safe_custom_dsa_dist = 0;

        $fwrite(inst_gen.gen_file,
                "//--- load-to-use gap: %0d SAFE_INT_CAL instructions\n",
                inst_num);
        inst_gen.insert_inst(inst_num, SAFE_INST);

        inst_gen.safe_inst_gen.safe_int_cal_dist    = old_int_cal_dist;
        inst_gen.safe_inst_gen.safe_float_cal_dist  = old_float_cal_dist;
        inst_gen.safe_inst_gen.safe_branch_dist     = old_branch_dist;
        inst_gen.safe_inst_gen.safe_int_ls_dist     = old_int_ls_dist;
        inst_gen.safe_inst_gen.safe_custom_dsa_dist = old_custom_dsa_dist;
    endfunction
endclass 
