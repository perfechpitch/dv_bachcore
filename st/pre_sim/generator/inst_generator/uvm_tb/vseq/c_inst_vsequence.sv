class c_inst_vsequence extends inst_gen_base_vsequence;
    c_inst_sequence c_inst_seq;

    `uvm_object_utils(c_inst_vsequence)
    `uvm_declare_p_sequencer(inst_gen_vsequencer)

    function new(string name = "c_inst_vsequence");
        super.new(name);
        c_inst_seq = new();
    endfunction

    virtual task body();
        task_info_config task_info;
        int              seq_num;

        task_info = p_sequencer.inst_gen_case_cfg.task_info;
        seq_num   = p_sequencer.inst_gen_case_cfg.seq_num;
        c_inst_seq.inst_gen  = p_sequencer.inst_gen;
        c_inst_seq.c_seq_cfg = p_sequencer.inst_gen_case_cfg.safe_seq_cfg;

        for(int t = 0; t < task_info.task_num; t++) begin
            if(!p_sequencer.inst_gen.fetch_space_avail())
                break;
            p_sequencer.inst_gen.switch_task(t);
            task_info.record_start(t, p_sequencer.inst_gen.inst_addr);

            // C.ADDI4SPN/C.ADDI16SP and compressed LS need initialized x2
            // and bound windows. This setup is outside the C-only payload.
            p_sequencer.inst_seq_gen.ls_inst_seq.do_base_config();

            for(int i = 0; i < seq_num; i++) begin
                if(!p_sequencer.inst_gen.fetch_space_avail())
                    break;
                void'(c_inst_seq.seq_gen());
            end
            task_info.record_end(t, p_sequencer.inst_gen.inst_addr);
        end
        task_info.finish_log();
    endtask
endclass : c_inst_vsequence
