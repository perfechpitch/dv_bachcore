class ls_inst_sequence extends base_inst_sequence;
    ls_seq_config   ls_seq_cfg;
    ls_seq_info_item  ls_seq_info;
    ls_base_config_sequence ls_base_config_seq;

    ls_rand_seq     rand_ls_seq;
    ls_linear_seq   linear_ls_seq;
    ls_memcpy_seq   memcpy_ls_seq;
    lrsc_seq        lrsc_seq;

    inst_generator  inst_gen;
    addr_space_generator    addr_space_gen;
    bit base_initial;
    `uvm_object_utils_begin(ls_inst_sequence)
    `uvm_object_utils_end
    // new - constructor
    function new (string name = "ls_inst_sequence");
      super.new(name);
      ls_seq_info = new();
      ls_base_config_seq = new();

      rand_ls_seq = new();
      linear_ls_seq = new();
      lrsc_seq = new();
      memcpy_ls_seq = new();


      base_initial = 0;
    endfunction : new

    virtual function do_base_config();
        ls_base_config_seq.seq_gen(ls_seq_cfg,inst_gen,addr_space_gen);
        base_initial = 1;
    endfunction
    virtual function ls_seq_info_item seq_gen();
        ls_seq_info.inst_seq_cfg = ls_seq_cfg;
        assert(ls_seq_info.randomize());
        if(ls_seq_info.base_change)begin
            ls_base_config_seq.seq_gen(ls_seq_cfg,inst_gen,addr_space_gen);
        end
 inst_gen.ls_inst_gen.pref_dist  = ls_seq_info.pref_dist;
        inst_gen.ls_inst_gen.load_dist  = ls_seq_info.load_dist;
        inst_gen.ls_inst_gen.store_dist = ls_seq_info.store_dist;
        inst_gen.ls_inst_gen.amo_dist   = ls_seq_info.amo_dist;
        inst_gen.ls_inst_gen.fence_dist = ls_seq_info.fence_dist;
        inst_gen.ls_inst_gen.fp_load_dist = ls_seq_info.fp_load_dist;
        inst_gen.ls_inst_gen.fp_store_dist = ls_seq_info.fp_store_dist;
        //test
        //if other ls seq , there can be randcase work.

        $fwrite(inst_gen.gen_file,("//--- ls seq type: %s \n"),ls_seq_info.ls_seq_type);
        case(ls_seq_info.ls_seq_type)
            RAND_LS     : begin
                rand_ls_seq.sub_seq_gen(ls_seq_info,inst_gen);
            end
            LINEAR_LS   : begin
                linear_ls_seq.sub_seq_gen(ls_seq_info, inst_gen);
            end
            LRSC_LS     : begin
                ls_seq_info.seq_length = 2;
                lrsc_seq.sub_seq_gen(inst_gen);
            end
            MEMCPY_LS     : begin
                memcpy_ls_seq.sub_seq_gen(ls_seq_info,inst_gen);
            end
        endcase
        $fwrite(inst_gen.gen_file,("//--- ls seq end     \n"));


//        ls_seq_info.print();
        return ls_seq_info;
    endfunction
endclass
                                            
