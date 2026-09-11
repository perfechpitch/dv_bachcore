class scenario_base_vsequence extends uvm_sequence;
    scenario_base_seq scenario;
    pass_quit_sequence pass_quit_seq;
    protected int task_log;
    protected int asm_file[3];
    protected int vmem_file[3];
    protected bit core_used[3];
    protected register_pool core_reg_pool[3];

    `uvm_object_utils(scenario_base_vsequence)
    `uvm_declare_p_sequencer(inst_gen_vsequencer)

    function new(string name = "scenario_base_vsequence");
        super.new(name);
        pass_quit_seq = new("pass_quit_seq");
    endfunction

    function string core_name(tcm_hart_e core);
        case(core)
            HART_MU : return "mu";
            HART_VU : return "vu";
            HART_DTE: return "dte";
            default : return "unknown";
        endcase
    endfunction

    // Scenario selection belongs to the common scenario executor. Testcases
    // only choose this virtual sequence as their default sequence.
    function scenario_base_seq select_scenario();
        string scenario_name;
        bit has_random_scenario;
        bit has_directed_scenario;
        random_scenario_registry   random_registry;
        directed_scenario_registry directed_registry;

        has_random_scenario = $value$plusargs("random_scenario_name=%s", scenario_name);
        if(has_random_scenario) begin
            if($test$plusargs("directed_seq_name="))
                `uvm_fatal("SCENARIO_SELECT",
                           "random_scenario_name and directed_seq_name cannot be used together")
            random_registry = new("random_scenario_registry");
            return random_registry.get(scenario_name);
        end

        has_directed_scenario = $value$plusargs("directed_seq_name=%s", scenario_name);
        if(has_directed_scenario) begin
            directed_registry = new("directed_scenario_registry");
            return directed_registry.get(scenario_name);
        end

        `uvm_fatal("SCENARIO_SELECT",
                   "need +random_scenario_name=<scenario> or +directed_seq_name=<scenario>")
        return null;
    endfunction

    function void bind_core_register_pool(int core_index);
        if(core_reg_pool[core_index] == null) begin
            core_reg_pool[core_index] = new($sformatf("%s_reg_pool", core_name(tcm_hart_e'(core_index))));
            core_reg_pool[core_index].csr_cfg      = p_sequencer.inst_gen.reg_pool.csr_cfg;
            core_reg_pool[core_index].inst_gen_cfg = p_sequencer.inst_gen.inst_gen_cfg;
            if(!core_reg_pool[core_index].randomize())
                `uvm_fatal("SCENARIO_REG_POOL", "core register pool randomize failed")
        end
        p_sequencer.inst_gen.reg_pool                    = core_reg_pool[core_index];
        // Instruction objects capture reg_pool when the queue is created.
        // Rebind them when switching to a per-core context as well.
        foreach(p_sequencer.inst_gen.inst_gen_queue[i])
            p_sequencer.inst_gen.inst_gen_queue[i].reg_pool = core_reg_pool[core_index];
        p_sequencer.inst_seq_gen.reg_pool                = core_reg_pool[core_index];
        p_sequencer.inst_seq_gen.safe_inst_seq.reg_pool   = core_reg_pool[core_index];
        p_sequencer.inst_seq_gen.flush_inst_seq.reg_pool  = core_reg_pool[core_index];
        p_sequencer.inst_seq_gen.except_inst_seq.reg_pool = core_reg_pool[core_index];
        p_sequencer.inst_seq_gen.branch_inst_seq.reg_pool = core_reg_pool[core_index];
        p_sequencer.inst_seq_gen.ls_inst_seq.reg_pool     = core_reg_pool[core_index];
    endfunction

    // AUTO preserves the platform-randomized weights. PLAN starts from those
    // same defaults and applies only the scenario's explicit overrides.
    function void run_random_task(scenario_task_info task_info);
        inst_seq_type_e seq_type;
        int unsigned    select_count[];

        p_sequencer.inst_gen_case_cfg.apply_scenario_seq_weights(task_info);
        p_sequencer.inst_gen_case_cfg.apply_scenario_subseq_weights(task_info);
        case(task_info.seq_select_mode)
            SCENARIO_SEQ_AUTO: begin
                repeat(task_info.seq_num) begin
                    if(!p_sequencer.inst_gen.fetch_space_avail())
                        break;
                    seq_type = p_sequencer.inst_seq_type_gen.get_seq_type();
                    p_sequencer.inst_seq_gen.rand_seq(seq_type);
                end
            end
            SCENARIO_SEQ_PLAN: begin
                select_count = new[task_info.seq_plan.size()];
                repeat(task_info.seq_num) begin
                    if(!p_sequencer.inst_gen.fetch_space_avail())
                        break;
                    seq_type = p_sequencer.inst_seq_type_gen.get_seq_type();
                    foreach(task_info.seq_plan[i]) begin
                        if(task_info.seq_plan[i].seq_type == seq_type)
                            select_count[i]++;
                    end
                    p_sequencer.inst_seq_gen.rand_seq(seq_type);
                end
                foreach(task_info.seq_plan[i]) begin
                    `uvm_info("SCENARIO_SEQ_RESULT",
                              $sformatf("task_id=%0d seq_type=%s preference=%s selected=%0d/%0d",
                                        task_info.task_id,
                                        task_info.seq_plan[i].seq_type.name(),
                                        task_info.seq_plan[i].weight.name(),
                                        select_count[i], task_info.seq_num), UVM_LOW)
                end
            end
            default:
                `uvm_fatal("SCENARIO_SEQ_PLAN",
                           $sformatf("task_id=%0d has invalid sequence selection mode",
                                     task_info.task_id))
        endcase
    endfunction

    // Execution policy lives in the virtual sequence. The selected scenario
    // only supplies the task plan and directed task contents.
    function void execute_scenario();
        scenario_task_info task_info;
        bit[63:0] task_pc;
        int unsigned history_start;
        int unsigned inst_num;

        scenario.build_task_plan(p_sequencer.inst_seq_gen.ls_seq_cfg.hart);
        task_log = $fopen("./log/task_info.log", "w");
        $fwrite(task_log, "# scenario task map; task IDs are globally unique\n");

        // Truncate all fixed outputs so stale per-core files cannot be reused.
        for(int core_index = 0; core_index < 3; core_index++) begin
            asm_file[core_index] = $fopen($sformatf("./%s_test.S",
                                                    core_name(tcm_hart_e'(core_index))), "w");
            vmem_file[core_index] = $fopen($sformatf("./%s_test.vmem",
                                                     core_name(tcm_hart_e'(core_index))), "w");
            if(!asm_file[core_index] || !vmem_file[core_index])
                `uvm_fatal("SCENARIO_FILE", "cannot open per-core output files")
        end

        // Static generation is grouped by core. Register state persists
        // between tasks on one core and is replaced when the core changes.
        for(int core_index = 0; core_index < 3; core_index++) begin
            core_used[core_index] = 1'b0;
            for(int i = 0; i < scenario.get_task_count(); i++) begin
                task_info = scenario.get_task(i);
                if(int'(task_info.rv_core) == core_index)
                    core_used[core_index] = 1'b1;
            end
            if(!core_used[core_index])
                continue;

            bind_core_register_pool(core_index);
            p_sequencer.inst_seq_gen.ls_seq_cfg.hart = tcm_hart_e'(core_index);
            p_sequencer.inst_seq_gen.ls_inst_seq.base_initial = 1'b0;
            p_sequencer.inst_gen.ls_addr_gen.hart = tcm_hart_e'(core_index);
            p_sequencer.inst_gen.ls_addr_gen.reset_bases();
            p_sequencer.inst_gen.begin_core_stream(asm_file[core_index], vmem_file[core_index],
                                                   tcm_hart_e'(core_index));
            p_sequencer.inst_seq_gen.gen_file = asm_file[core_index];

            for(int i = 0; i < scenario.get_task_count(); i++) begin
                task_info = scenario.get_task(i);
                if(int'(task_info.rv_core) != core_index)
                    continue;
                task_pc = task_info.use_start_pc ? task_info.start_pc : p_sequencer.inst_gen.inst_addr;
                p_sequencer.inst_gen.switch_task(task_info.task_id, 1'b1, task_pc);
                history_start = p_sequencer.inst_gen.inst_pc_history.size();

                if(task_info.kind == SCENARIO_RANDOM_TASK) begin
                    if(task_info.seq_num == SCENARIO_AUTO_SEQ_NUM)
                        task_info.seq_num = p_sequencer.inst_gen_case_cfg.seq_num;
                    run_random_task(task_info);
                end
                else begin
                    // Directed contents never inherit a preceding random task's
                    // scenario-specific sequence distribution.
                    p_sequencer.inst_gen_case_cfg.restore_default_seq_weights();
                    p_sequencer.inst_gen_case_cfg.restore_default_subseq_weights();
                    scenario.generate_task(task_info,
                                           p_sequencer.inst_gen,
                                           p_sequencer.inst_seq_gen,
                                           p_sequencer.inst_seq_type_gen);
                end

                if(p_sequencer.inst_gen.fetch_space_avail())
                    pass_quit_seq.seq_gen(p_sequencer.inst_gen);
                inst_num = p_sequencer.inst_gen.inst_pc_history.size() - history_start;
                $fwrite(task_log, "------------task_id : %0d----------\n", task_info.task_id);
                $fwrite(task_log, "task_id: %0d\n", task_info.task_id);
                $fwrite(task_log, "rv_core: %s\n", core_name(task_info.rv_core));
                $fwrite(task_log, "start_pc: 0x%016h\n", task_pc);
                if(task_info.kind == SCENARIO_RANDOM_TASK)
                    $fwrite(task_log, "seq_num: %0d\n", task_info.seq_num);
                $fwrite(task_log, "inst_num: %0d\n", inst_num);
                $fwrite(task_log, "end_pc: 0x%016h\n\n", p_sequencer.inst_gen.inst_addr);
                `uvm_info("SCENARIO_TASK",
                          $sformatf("core=%s task_id=%0d start_pc=0x%0h end_pc=0x%0h inst_num=%0d",
                                    core_name(task_info.rv_core), task_info.task_id, task_pc,
                                    p_sequencer.inst_gen.inst_addr, inst_num), UVM_LOW)
            end
        end

        for(int core_index = 0; core_index < 3; core_index++) begin
            if(core_used[core_index])
                p_sequencer.addr_space_gen.data_vmem_out(vmem_file[core_index]);
            $fclose(asm_file[core_index]);
            $fclose(vmem_file[core_index]);
        end
        $fwrite(task_log, "# done tasks=%0d\n", scenario.get_task_count());
        $fclose(task_log);
    endfunction

    virtual task body();
        scenario = select_scenario();
        execute_scenario();
    endtask

    virtual task post_body();
        // execute_scenario() emits per-core termination and data images.
    endtask
endclass
