class mu_random_scenario_seq extends scenario_base_seq;
    `uvm_object_utils(mu_random_scenario_seq)

    function new(string name = "mu_random_scenario_seq");
        super.new(name);
    endfunction

    virtual function void configure_tasks();
        int unsigned task_num;
        int unsigned seq_num;
        task_num = 2;
        seq_num  = 1;
        void'($value$plusargs("scenario_task_num=%d", task_num));
        void'($value$plusargs("scenario_seq_num=%d", seq_num));
        if(!(task_num inside {[1:8]}) || seq_num == 0)
            `uvm_fatal("RANDOM_SCENARIO", "scenario_task_num must be 1..8 and scenario_seq_num must be nonzero")
        for(int i = 0; i < task_num; i++)
            add_random_task(100 + i, HART_MU, seq_num, (i == 0), '0);
    endfunction
endclass

`RANDOM_SCENARIO_REGISTER(mu_random_scenario_seq, "mu_random")
