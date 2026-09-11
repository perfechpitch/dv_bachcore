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
                `c_addi;
                `c_addi;
                // Cover all DSA custom encodings with explicit operands.
                `dsaw(5, 6);
                `dsawi(5, 32'h0000_1234);
                `dsar(7, 5);
                `dsari(8, 32'h0000_abcd);
                // The public LOOP macro accepts a byte displacement.
                `loop(5, 6, 'h8);
            end
            HART_VU: begin
                `c_li;
            end
            HART_DTE: begin
                `c_nop;
                `c_addi;
            end
        endcase
    endfunction
endclass

`DIRECTED_SCENARIO_REGISTER(multicore_directed_scenario_seq, "multicore_directed")
