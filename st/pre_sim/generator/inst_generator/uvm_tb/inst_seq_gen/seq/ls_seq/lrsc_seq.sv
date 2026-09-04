class lrsc_seq extends base_inst_sequence;
    ls_seq_config   ls_seq_cfg;
    `uvm_object_utils_begin(lrsc_seq)
    `uvm_object_utils_end
    // new - constructor
    function new (string name = "lrsc_seq");
      super.new(name);
    endfunction : new

    virtual function void sub_seq_gen(inst_generator inst_gen);
        bit lrsc_w;
        lrsc_w = $random();
        if(lrsc_w)begin
            inst_gen.get_specified_rand_inst(LR_W);
            inst_gen.get_specified_rand_inst(SC_W);
        end
        else begin
            inst_gen.get_specified_rand_inst(LR_D);
            inst_gen.get_specified_rand_inst(SC_D);
        end
    endfunction
endclass 
