class multicore_directed_scenario_seq extends scenario_base_seq;
    `uvm_object_utils(multicore_directed_scenario_seq)

    function new(string name = "multicore_directed_scenario_seq");
        super.new(name);
    endfunction

    virtual function void configure_tasks();
        // MU/VU/DTE own independent ITCMs, so each core may reuse the same
        // local start-PC layout. Task IDs remain globally unique.
        add_directed_task(10, HART_MU,  64'h0000);
        add_directed_task(11, HART_MU,  64'h0100);
        add_directed_task(20, HART_VU,  64'h0000);
        add_directed_task(21, HART_VU,  64'h0100);
        add_directed_task(30, HART_DTE, 64'h0000);
        add_directed_task(31, HART_DTE, 64'h0100);
    endfunction

    virtual function void generate_task(scenario_task_info     task_info,
                                        inst_generator          inst_gen,
                                        inst_seq_generator      inst_seq_gen,
                                        inst_seq_type_generator inst_seq_type_gen);
        case(task_info.task_id)
            // MU task 10: register-addressed DSA write/read plus integer ALU.
            10: begin
                `addi(5, 0, 'h100);
                `addi(6, 0, 'h040);
                `dsaw(5, 6);
                `dsar(7, 5);
                `add(8, 7, 6);
                `c_addi;
            end
            // MU task 11: immediate DSA write/read plus M/ALU operations.
            11: begin
                `addi(5, 0, 'h120);
                `addi(6, 0, 'h003);
                `dsawi(5, 16'h1234);
                `dsari(9, 16'h0020);
                `xori(10, 9, 'h055);
                `mul(11, 10, 6);
            end
            // VU task 20: an independent register-addressed DSA flow.
            20: begin
                `addi(12, 0, 'h200);
                `addi(13, 0, 'h080);
                `dsaw(12, 13);
                `dsar(14, 12);
                `or(15, 14, 13);
                `c_li;
            end
            // VU task 21: immediate DSA accesses mixed with shift/ALU.
            21: begin
                `addi(12, 0, 'h220);
                `dsawi(12, 16'h5678);
                `dsari(14, 16'h0040);
                `slli(15, 14, 2);
                `addi(16, 15, 1);
                `c_nop;
            end
            // DTE task 30: DSA register transfer plus arithmetic.
            30: begin
                `addi(17, 0, 'h300);
                `addi(18, 0, 'h0c0);
                `dsaw(17, 18);
                `dsar(19, 17);
                `sub(20, 19, 18);
                `c_addi;
            end
            // DTE task 31: immediate DSA accesses plus mixed-width ALU.
            31: begin
                `addi(17, 0, 'h320);
                `dsawi(17, 16'h9abc);
                `dsari(19, 16'h0060);
                `ori(20, 19, 'h00f);
                `add(21, 20, 17);
                `c_nop;
            end
            default:
                `uvm_fatal("MULTICORE_DSA",
                           $sformatf("unexpected directed task_id=%0d core=%s",
                                     task_info.task_id, task_info.rv_core.name()))
        endcase
    endfunction
endclass

`DIRECTED_SCENARIO_REGISTER(multicore_directed_scenario_seq, "multicore_directed")
