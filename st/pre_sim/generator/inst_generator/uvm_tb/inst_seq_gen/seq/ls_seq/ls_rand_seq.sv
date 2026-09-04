class ls_rand_seq extends base_inst_sequence;
    ls_seq_info_item    ls_seq_info;
    `uvm_object_utils_begin(ls_rand_seq)
    `uvm_object_utils_end
    // new - constructor
    function new (string name = "ls_rand_seq");
      super.new(name);
      ls_seq_info = new();
    endfunction : new

    virtual function void sub_seq_gen(ls_seq_info_item ls_seq_info,inst_generator inst_gen);
        int seq_length;
        seq_length = ls_seq_info.seq_length;


        $fwrite(inst_gen.gen_file,("//--- ls rand seq start  : seq_length = %0d\n"),seq_length);
        gen_rand_inst(inst_gen,seq_length,ls_seq_info.ls_inst_dist,ls_seq_info.safe_inst_dist,ls_seq_info.flush_inst_dist,ls_seq_info.except_inst_dist,'d0,ls_seq_info.wfi_inst_dist);
        $fwrite(inst_gen.gen_file,("//--- ls rand seq end   \n"));


    endfunction
endclass 