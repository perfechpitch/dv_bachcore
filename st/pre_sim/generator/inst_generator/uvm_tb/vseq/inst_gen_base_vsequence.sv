class inst_gen_base_vsequence extends uvm_sequence;
    config_sequence             config_seq;
    pass_quit_sequence          pass_quit_seq;
    `uvm_object_utils(inst_gen_base_vsequence)
    `uvm_declare_p_sequencer(inst_gen_vsequencer)

    function new(string name = "inst_gen_base_vsequence");
        super.new(name);
        config_seq = new();
        pass_quit_seq = new();
    endfunction

    virtual task pre_body();
        //config_seq.seq_gen(p_sequencer.inst_gen_case_cfg.csr_cfg, p_sequencer.inst_gen,
        //                   p_sequencer.inst_gen_case_cfg.except_disable,
        //                   p_sequencer.inst_gen_case_cfg.int_ack_disable);
    endtask

    virtual task body();
        task_info_config task_info;
        inst_seq_type_e  seq_type;
        int              seq_num;

        task_info = p_sequencer.inst_gen_case_cfg.task_info;
        seq_num   = p_sequencer.inst_gen_case_cfg.seq_num;
        //只是生成特定RV core；3种RV core有需要一起生成的场景吗？toDO
        for(int t=0; t<task_info.task_num; t++)begin
            // ITCM 已满则不再开新 task
            if(!p_sequencer.inst_gen.fetch_space_avail())begin
                $fwrite(p_sequencer.inst_gen.gen_file,
                        ("// ITCM 4KB full, skip remaining tasks from task_id=%0d\n"), t);
                break;
            end
            p_sequencer.inst_gen.switch_task(t);
            task_info.record_start(t, p_sequencer.inst_gen.inst_addr);
            for(int i=0; i<seq_num; i++)begin
                // ITCM 已满则不再铺后续 seq
                if(!p_sequencer.inst_gen.fetch_space_avail())
                    break;
                seq_type = p_sequencer.inst_seq_type_gen.get_seq_type();
                p_sequencer.inst_seq_gen.rand_seq(seq_type);
            end
            task_info.record_end(t, p_sequencer.inst_gen.inst_addr);
        end
        task_info.finish_log();
    endtask

    virtual task post_body();
        // 截断路径已写过 pass_quit，这里只在仍有空间时补一条
        if(p_sequencer.inst_gen.fetch_space_avail())
            pass_quit_seq.seq_gen(p_sequencer.inst_gen);
        p_sequencer.addr_space_gen.data_vmem_out(p_sequencer.inst_gen.vmem_file);
    endtask
endclass : inst_gen_base_vsequence
