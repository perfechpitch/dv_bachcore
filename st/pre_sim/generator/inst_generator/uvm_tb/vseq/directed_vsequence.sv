// 定向 program：按 +directed_seq_name= 从仓库取场景再发。不改 seq_debug_vsequence。
class directed_vsequence extends inst_gen_base_vsequence;
    directed_seq            dir_seq;
    directed_scenario_seq   scenario;
    `uvm_object_utils(directed_vsequence)
    `uvm_declare_p_sequencer(inst_gen_vsequencer)

    function new(string name = "directed_vsequence");
        super.new(name);
        dir_seq = new();
    endfunction

    virtual task body();
        task_info_config task_info;
        string           seq_name;
        int              seq_num;

        if(!$value$plusargs("directed_seq_name=%s", seq_name))
            `uvm_fatal("DIRECTED_VSEQ", "need +directed_seq_name=<scenario>")
        scenario = dir_seq.get(seq_name);

        task_info = p_sequencer.inst_gen_case_cfg.task_info;
        seq_num   = p_sequencer.inst_gen_case_cfg.seq_num;

        for(int t=0; t<task_info.task_num; t++)begin
            if(!p_sequencer.inst_gen.fetch_space_avail())begin
                $fwrite(p_sequencer.inst_gen.gen_file,
                        ("// ITCM 4KB full, skip remaining tasks from task_id=%0d\n"), t);
                break;
            end
            p_sequencer.inst_gen.switch_task(t);
            task_info.record_start(t, p_sequencer.inst_gen.inst_addr);
            for(int i=0; i<seq_num; i++)begin
                if(!p_sequencer.inst_gen.fetch_space_avail())
                    break;
                scenario.seq_gen(p_sequencer);
            end
            task_info.record_end(t, p_sequencer.inst_gen.inst_addr);
        end
        task_info.finish_log();
    endtask
endclass : directed_vsequence
