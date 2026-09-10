class mu_safe_random_scenario_seq extends scenario_base_seq;
    `uvm_object_utils(mu_safe_random_scenario_seq)

    function new(string name = "mu_safe_random_scenario_seq");
        super.new(name);
    endfunction

    virtual function void configure_tasks();
        int unsigned task_num;
        int unsigned task_id;
        task_num = random_task_num();

        for(int i = 0; i < task_num; i++) begin
            task_id = add_random_task(.rv_core(HART_MU),
                                      .use_start_pc(i == 0),
                                      .start_pc('0));
            set_task_seq_weight(task_id, SAFE_INST_SEQ,   WEIGHT_HIGH);
            set_task_seq_weight(task_id, LS_INST_SEQ,     WEIGHT_DISABLE);
            set_task_seq_weight(task_id, BRANCH_INST_SEQ, WEIGHT_DISABLE);
            set_task_seq_weight(task_id, FLUSH_INST_SEQ,  WEIGHT_DISABLE);
            set_task_seq_weight(task_id, EXCEPT_INST_SEQ, WEIGHT_DISABLE);
            set_task_seq_weight(task_id, C_INST_SEQ,      WEIGHT_DISABLE);
            // set_task_subseq_weight(task_id, SAFE_INST_SEQ,
            //                        SCENARIO_SAFE_INT_CAL, WEIGHT_HIGH);
        end
    endfunction
endclass

`RANDOM_SCENARIO_REGISTER(mu_safe_random_scenario_seq, "mu_safe_random")
