class reference_single_task_scenario_seq extends scenario_base_seq;
    `uvm_object_utils(reference_single_task_scenario_seq)

    function new(string name = "reference_single_task_scenario_seq");
        super.new(name);
    endfunction

    virtual function void configure_tasks();
        add_directed_task(1, HART_VU, 64'h00000000);
    endfunction

    virtual function void generate_task(
        scenario_task_info      task_info,
        inst_generator          inst_gen,
        inst_seq_generator      inst_seq_gen,
        inst_seq_type_generator inst_seq_type_gen
    );
        inst_gen.get_specified_inst(DSAWI, 0, 0, 0, 32'h1234);
        inst_gen.get_specified_inst(DSARI, 0, 0, 8, 32'habcd);
    endfunction
endclass
`DIRECTED_SCENARIO_REGISTER(reference_single_task_scenario_seq, "reference_single_task")
