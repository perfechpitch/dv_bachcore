class mu_random_scenario_seq extends scenario_base_seq;
    `uvm_object_utils(mu_random_scenario_seq)

    function new(string name = "mu_random_scenario_seq");
        super.new(name);
    endfunction

    virtual function void configure_tasks();
        int unsigned task_num;
        int unsigned task_id;
        task_num = random_task_num();
        for(int i = 0; i < task_num; i++) begin
            // Omitted task_id is allocated uniquely by scenario_base_seq.
            // Omitted seq_num is resolved from inst_gen_case_config at runtime.
            task_id = add_random_task(.rv_core(HART_MU),
                                      .use_start_pc(i == 0),
                                      .start_pc('0));
            // No top-level override: use all platform-enabled random seq types.
            // Optional top/sub-sequence overrides can be enabled when needed:
            //set_task_seq_weight(task_id, SAFE_INST_SEQ,   WEIGHT_HIGH);
            //set_task_seq_weight(task_id, LS_INST_SEQ,     WEIGHT_MEDIUM);
            //set_task_seq_weight(task_id, BRANCH_INST_SEQ, WEIGHT_LOW);
            //set_task_subseq_weight(task_id, SAFE_INST_SEQ,
            //                       SCENARIO_SAFE_INT_CAL, WEIGHT_HIGH);
            //set_task_subseq_weight(task_id, SAFE_INST_SEQ,
            //                       SCENARIO_SAFE_CUSTOM_DSA, WEIGHT_LOW);
            //set_task_subseq_weight(task_id, LS_INST_SEQ,
            //                       SCENARIO_LS_RAND, WEIGHT_HIGH);
            //set_task_subseq_weight(task_id, LS_INST_SEQ,
            //                       SCENARIO_LS_LINEAR, WEIGHT_LOW);
            //set_task_subseq_weight(task_id, BRANCH_INST_SEQ,
            //                       SCENARIO_BRANCH_SINGLE, WEIGHT_HIGH);
            //set_task_subseq_weight(task_id, BRANCH_INST_SEQ,
            //                       SCENARIO_BRANCH_LOOP, WEIGHT_LOW);
        end
    endfunction
endclass

`RANDOM_SCENARIO_REGISTER(mu_random_scenario_seq, "mu_random")
