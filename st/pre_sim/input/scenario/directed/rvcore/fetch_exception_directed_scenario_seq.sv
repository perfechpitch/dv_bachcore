class fetch_exception_directed_scenario_seq extends scenario_base_seq;
    `uvm_object_utils(fetch_exception_directed_scenario_seq)

    function new(string name = "fetch_exception_directed_scenario_seq");
        super.new(name);
    endfunction

    virtual function void configure_tasks();
        // Task 0: the start PC itself is misaligned, so no task body is emitted.
        add_directed_task(0, HART_MU, 64'h0000);
        require_task_fetch_exception(0,
                                     FETCH_ADDR_ORIGIN_TASK_START,
                                     FETCH_ADDR_FAULT_MISALIGNED);

        // Task 1: the scenario supplies a JALR opportunity; fetch_addr_generator
        // supplies the directed out-of-ITCM target.
        add_directed_task(1, HART_MU, 64'h0100);
        require_task_fetch_exception(1,
                                     FETCH_ADDR_ORIGIN_CONTROL_TARGET,
                                     FETCH_ADDR_FAULT_OUT_OF_ITCM);

        // Task 2: two 32-bit instructions exactly fill the final eight ITCM
        // bytes, making the next sequential fetch cross the task/program end.
        add_directed_task(2, HART_MU, 64'h0ff8);
        require_task_fetch_exception(2,
                                     FETCH_ADDR_ORIGIN_TASK_END,
                                     FETCH_ADDR_FAULT_OUT_OF_ITCM);
    endfunction

    virtual function void generate_task(scenario_task_info     task_info,
                                        inst_generator          inst_gen,
                                        inst_seq_generator      inst_seq_gen,
                                        inst_seq_type_generator inst_seq_type_gen);
        case(task_info.task_id)
            1: begin
                inst_seq_gen.branch_inst_seq.jalr_seq.sub_seq_gen(
                    inst_seq_gen.branch_seq_cfg, inst_gen);
            end
            2: begin
                `addi(5, 0, 1);
                `addi(6, 5, 1);
            end
            default: begin
                // Task 0 has no body because its invalid start PC is the
                // complete fetch stimulus.
            end
        endcase
    endfunction
endclass

`DIRECTED_SCENARIO_REGISTER(fetch_exception_directed_scenario_seq,
                            "fetch_exception_directed")
