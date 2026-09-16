class reference_multi_core_multi_task_scenario_seq extends scenario_base_seq;
    `uvm_object_utils(reference_multi_core_multi_task_scenario_seq)

    function new(string name = "reference_multi_core_multi_task_scenario_seq");
        super.new(name);
    endfunction

    virtual function void configure_tasks();
        add_directed_task(4, HART_VU,  64'h00000040);
        add_directed_task(2, HART_MU,  64'h00100000);
        add_directed_task(1, HART_VU,  64'h00000000);
        add_directed_task(3, HART_DTE, 64'h00110000);
    endfunction

    virtual function void generate_task(
        scenario_task_info      task_info,
        inst_generator          inst_gen,
        inst_seq_generator      inst_seq_gen,
        inst_seq_type_generator inst_seq_type_gen
    );
        inst_gen.get_specified_rand_inst(C_NOP);
    endfunction
endclass
`DIRECTED_SCENARIO_REGISTER(reference_multi_core_multi_task_scenario_seq, "reference_multi_core_multi_task")
