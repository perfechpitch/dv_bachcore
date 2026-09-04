class base_inst_sequence extends uvm_object;
//    inst_generator          inst_gen;
    addr_space_generator    addr_space_gen;
    register_pool           reg_pool;

    `uvm_object_utils_begin(base_inst_sequence)
    `uvm_object_utils_end
    // new - constructor
    function new (string name = "base_inst_sequence");
      super.new(name);
    endfunction : new

    virtual function inst_seq_info_item seq_gen();

    endfunction
    function void gen_rand_inst(inst_generator inst_gen,int inst_num,a,b,c,d,e,f);
        for(int i=0;i<inst_num;i++)begin
            randcase
                a:inst_gen.get_rand_inst(LS_INST);
                b:inst_gen.get_rand_inst(SAFE_INST);
                c:inst_gen.get_rand_inst(FLUSH_INST);
                d:inst_gen.get_rand_inst(EXCEPT_INST);
                e:inst_gen.get_rand_inst(BRANCH_INST);
                f:inst_gen.get_specified_rand_inst(WFI);
            endcase
        end
    endfunction
endclass 
