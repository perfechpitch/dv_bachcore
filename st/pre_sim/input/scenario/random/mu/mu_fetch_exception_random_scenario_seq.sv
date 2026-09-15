class mu_fetch_exception_random_scenario_seq extends scenario_base_seq;
    `uvm_object_utils(mu_fetch_exception_random_scenario_seq)

    function new(string name = "mu_fetch_exception_random_scenario_seq");
        super.new(name);
    endfunction

    virtual function void configure_tasks();
        int unsigned task_id;
        task_id = add_random_task(.rv_core(HART_MU),
                                  .use_start_pc(1'b1),
                                  .start_pc('0));
        // This is only a capability gate.  Source/type/address stay random in
        // the lower-level fetch address generator.
        enable_task_fetch_exception(task_id);
    endfunction
endclass

`RANDOM_SCENARIO_REGISTER(mu_fetch_exception_random_scenario_seq,
                          "mu_fetch_exception_random")
