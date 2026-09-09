class multicore_directed_scenario_seq extends scenario_base_seq;
    `uvm_object_utils(multicore_directed_scenario_seq)

    function new(string name = "multicore_directed_scenario_seq");
        super.new(name);
    endfunction

    virtual function void configure_tasks();
        add_directed_task(10, HART_MU,  64'h0000);
        add_directed_task(20, HART_VU,  64'h0100);
        add_directed_task(30, HART_DTE, 64'h0200);
    endfunction

    virtual function void generate_task(scenario_task_info     task_info,
                                        inst_generator          inst_gen,
                                        inst_seq_generator      inst_seq_gen,
                                        inst_seq_type_generator inst_seq_type_gen);
        case(task_info.rv_core)
            HART_MU: begin
                inst_gen.get_specified_rand_inst(C_ADDI);
                inst_gen.get_specified_rand_inst(C_ADDI);
            end
            HART_VU: begin
                inst_gen.get_specified_rand_inst(C_LI);
            end
            HART_DTE: begin
                inst_gen.get_specified_rand_inst(C_NOP);
                inst_gen.get_specified_rand_inst(C_ADDI);
            end
        endcase
    endfunction
endclass

`DIRECTED_SCENARIO_REGISTER(multicore_directed_scenario_seq, "multicore_directed")
