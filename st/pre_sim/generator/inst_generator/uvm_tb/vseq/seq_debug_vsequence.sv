class seq_debug_vsequence extends uvm_sequence;


    config_sequence             config_seq;
    ls_base_config_sequence     ls_base_config_seq;

    //debug seq 
    jalr_sequence               jalr_seq;
    //quit seq  
    pass_quit_sequence          pass_quit_seq;
    `uvm_object_utils(seq_debug_vsequence)
    `uvm_declare_p_sequencer(inst_gen_vsequencer)

    function new(string name = "seq_debug_vsequence");
        super.new(name);
        config_seq = new();
        ls_base_config_seq = new();
        pass_quit_seq = new();

    endfunction
    virtual task pre_body();
        //do csr cfg
        config_seq.seq_gen(p_sequencer.inst_gen_case_cfg.csr_cfg, p_sequencer.inst_gen,p_sequencer.inst_gen_case_cfg.except_disable,p_sequencer.inst_gen_case_cfg.int_ack_disable);

        //get base reg value no need
        if(!p_sequencer.inst_gen_case_cfg.global_disable_ls)begin
            //for no except ls inst
            ls_base_config_seq = new();
            ls_base_config_seq.seq_gen(p_sequencer.inst_gen_case_cfg.ls_seq_cfg,p_sequencer.inst_gen,p_sequencer.addr_space_gen);
        end
    endtask
 virtual task body();
        inst_seq_type_e seq_type;
        int seq_num;
        string debug_seq_name;
        if($value$plusargs("debug_seq_name=%s",debug_seq_name))begin
            for(int i=0; i<10;i++)begin
                case(debug_seq_name)
                    //branch seq
                    "jalr_seq"          : begin
                        jalr_seq = new();
                        jalr_seq.sub_seq_gen(p_sequencer.inst_gen_case_cfg.branch_seq_cfg,p_sequencer.inst_gen,p_sequencer.addr_space_gen,FETCH_VALID);
                    end
                    "branch_inst_seq"   : begin
                        p_sequencer.inst_seq_gen.branch_inst_seq.seq_gen();
                    end

                    //ls seq
                    "ls_base_config_seq": begin
                        ls_base_config_seq = new();
                        ls_base_config_seq.seq_gen(p_sequencer.inst_gen_case_cfg.ls_seq_cfg,p_sequencer.inst_gen,p_sequencer.addr_space_gen);
                    end

                    "ls_inst_seq"   : begin
                        p_sequencer.inst_seq_gen.ls_inst_seq.seq_gen();
                    end
                    "except_inst_seq":begin
                        //maybe ls except is random generator
                        ls_base_config_seq = new();
                        ls_base_config_seq.seq_gen(p_sequencer.inst_gen_case_cfg.ls_seq_cfg,p_sequencer.inst_gen,p_sequencer.addr_space_gen);
                    //$display("111111111111111");
                        p_sequencer.inst_seq_gen.except_inst_seq.seq_gen();
                    end

                endcase
            end
        end
        else begin
            seq_num = p_sequencer.inst_gen_case_cfg.seq_num;
            for(int i=0; i<seq_num; i++)begin
                if(!p_sequencer.inst_gen.fetch_space_avail())
                    break;
                seq_type = p_sequencer.inst_seq_type_gen.get_seq_type();
                p_sequencer.inst_seq_gen.rand_seq(seq_type);
            end
        end
    endtask
    virtual task post_body();
        if(p_sequencer.inst_gen.fetch_space_avail())
            pass_quit_seq.seq_gen(p_sequencer.inst_gen);

        p_sequencer.addr_space_gen.data_vmem_out(p_sequencer.inst_gen.vmem_file);
    endtask

endclass : seq_debug_vsequence
