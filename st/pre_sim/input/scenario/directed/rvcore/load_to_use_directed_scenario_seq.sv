class load_to_use_directed_scenario_seq extends scenario_base_seq;
    `uvm_object_utils(load_to_use_directed_scenario_seq)

    function new(string name = "load_to_use_directed_scenario_seq");
        super.new(name);
    endfunction

    virtual function void configure_tasks();
        add_directed_task(40, HART_MU, 64'h0000);
    endfunction

    virtual function void generate_task(scenario_task_info     task_info,
                                        inst_generator          inst_gen,
                                        inst_seq_generator      inst_seq_gen,
                                        inst_seq_type_generator inst_seq_type_gen);
        load_to_use_request request;
        if(task_info.task_id != 40)
            `uvm_fatal("LOAD_TO_USE_DIRECTED",
                       $sformatf("unexpected task_id=%0d", task_info.task_id))

        request = new("lw_add_request");
        request.set_consumer(ADD);
        request.set_gap(0);
        request.set_load_data(32'h1234_5678);
        inst_seq_gen.gen_load_to_use(request);

        request = new("lw_addi_request");
        request.set_consumer(ADDI);
        request.set_gap(3);
        request.set_load_data(32'h89ab_cdef);
        inst_seq_gen.gen_load_to_use(request);
    endfunction
endclass

`DIRECTED_SCENARIO_REGISTER(load_to_use_directed_scenario_seq,
                            "load_to_use_directed")
