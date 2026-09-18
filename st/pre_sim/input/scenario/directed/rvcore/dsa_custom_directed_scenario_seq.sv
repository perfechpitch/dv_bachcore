class dsa_custom_directed_scenario_seq extends scenario_base_seq;
    `uvm_object_utils(dsa_custom_directed_scenario_seq)

    function new(string name = "dsa_custom_directed_scenario_seq");
        super.new(name);
    endfunction

    virtual function void configure_tasks();
        add_directed_task(50, HART_VU, 64'h0000);
    endfunction

    virtual function void generate_task(scenario_task_info     task_info,
                                        inst_generator          inst_gen,
                                        inst_seq_generator      inst_seq_gen,
                                        inst_seq_type_generator inst_seq_type_gen);
        // Keep the sequence task plan aligned with reference_single_task.json.
        if(task_info.task_id != 50 || task_info.rv_core != HART_VU ||
           task_info.start_pc != 64'h0000_0000)
            `uvm_fatal("DSA_CUSTOM_DIRECTED",
                       $sformatf("unexpected task: id=%0d core=%s pc=0x%0h",
                                 task_info.task_id, task_info.rv_core.name,
                                 task_info.start_pc))

        // Phase 1 only checks that every DSA custom opcode is emitted and can
        // execute in Core Ref. Keep register values deterministic; operand and
        // sequence randomization belongs to the later random-scenario phase.
        `addi(5, 0, 'h000);
        `addi(6, 0, 'h040);
        `dsaw(5, 6);
        `dsar(7, 5);
        `dsawi(5, 16'h1234);
        `dsari(8, 16'h0004);
    endfunction
endclass

`DIRECTED_SCENARIO_REGISTER(dsa_custom_directed_scenario_seq,
                            "dsa_custom_directed")
