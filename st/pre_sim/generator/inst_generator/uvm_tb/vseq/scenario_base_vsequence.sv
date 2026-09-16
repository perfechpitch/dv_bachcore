class scenario_base_vsequence extends uvm_sequence;
    scenario_base_seq scenario;
    pass_quit_sequence pass_quit_seq;
    protected int task_log;
    protected int asm_file;
    protected int vmem_file;
    protected bit core_used[3];

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

    function bit [31:0] core_itcm_rv_base(tcm_hart_e core);
        case(core)
            HART_MU : return `MU_ITCM_RV_BASE;
            HART_VU : return `VU_ITCM_RV_BASE;
            HART_DTE: return `DTE_ITCM_RV_BASE;
            default : `uvm_fatal("SCENARIO_CORE", "invalid RV core for ITCM RV base")
        endcase
        return '0;
    endfunction

    function bit [31:0] core_itcm_global_base(tcm_hart_e core);
        case(core)
            HART_MU : return `MU_ITCM_GLOBAL_BASE;
            HART_VU : return `VU_ITCM_GLOBAL_BASE;
            HART_DTE: return `DTE_ITCM_GLOBAL_BASE;
            default : `uvm_fatal("SCENARIO_CORE", "invalid RV core for ITCM global base")
        endcase
        return '0;
    endfunction

    function bit [31:0] core_global_pc(tcm_hart_e core, bit [63:0] rv_pc);
        bit [31:0] rv_base;
        rv_base = core_itcm_rv_base(core);
        if(rv_pc[63:32] != '0)
            `uvm_fatal("SCENARIO_CORE",
                       $sformatf("core=%s RV PC 0x%016h exceeds 32-bit address space",
                                 core_name(core), rv_pc))
        if(rv_pc[31:0] < rv_base)
            `uvm_fatal("SCENARIO_CORE",
                       $sformatf("core=%s RV PC 0x%08h is below ITCM base 0x%08h",
                                 core_name(core), rv_pc[31:0], rv_base))
        return core_itcm_global_base(core) + (rv_pc[31:0] - rv_base);
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
        bit[63:0] task_end_pc;
        int unsigned inst_num;
        fetch_context fetch_ctx;

        scenario.build_task_plan(p_sequencer.inst_gen_case_cfg.default_core);
        task_log = $fopen("./log/task_info.log", "w");
        $fwrite(task_log, "# scenario task map; task IDs are globally unique\n");

        // The testcase owns one assembly file and one memory image for the
        // whole scenario. Core-local ITCM addresses are translated only while
        // writing test.vmem.
        asm_file  = p_sequencer.inst_gen_case_cfg.gen_file;
        vmem_file = p_sequencer.inst_gen_case_cfg.vmem_file;
        if(!asm_file ||
           (p_sequencer.inst_gen.inst_gen_cfg.vmem_file_gen && !vmem_file))
            `uvm_fatal("SCENARIO_FILE", "cannot open unified test.S/test.vmem")
        p_sequencer.inst_gen.reset_output_stream();

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

            // Select state only. All generator/resource object bindings are
            // fixed once by inst_gen_environment.
            p_sequencer.core_ctx_pool.select_core(tcm_hart_e'(core_index));
            p_sequencer.inst_gen.reg_pool.select_active_context();
            p_sequencer.inst_gen.ls_addr_gen.select_active_context();
            p_sequencer.inst_seq_gen.ls_inst_seq.base_initial = 1'b0;
            p_sequencer.inst_gen.ls_addr_gen.reset_bases();
            $fwrite(asm_file,
                    "\n//================ CORE[%s] rv_itcm=0x%08h global_itcm=0x%08h ================\n",
                    core_name(tcm_hart_e'(core_index)),
                    core_itcm_rv_base(tcm_hart_e'(core_index)),
                    core_itcm_global_base(tcm_hart_e'(core_index)));
            p_sequencer.inst_gen.begin_core_stream(
                asm_file, vmem_file,
                core_itcm_rv_base(tcm_hart_e'(core_index)),
                core_itcm_global_base(tcm_hart_e'(core_index)));
            p_sequencer.inst_seq_gen.gen_file = asm_file;

            for(int i = 0; i < scenario.get_task_count(); i++) begin
                task_info = scenario.get_task(i);
                if(int'(task_info.rv_core) != core_index)
                    continue;
                task_pc = task_info.use_start_pc ? task_info.start_pc :
                          p_sequencer.inst_gen.get_inst_addr();
                p_sequencer.inst_gen.switch_task(
                    task_info.task_id, 1'b1, task_pc,
                    task_info.fetch_exception_enable);
                fetch_ctx = p_sequencer.core_ctx_pool.get_fetch_context();

                if(!fetch_ctx.task_body_enable) begin
                    $fwrite(p_sequencer.inst_gen.gen_file,
                            "//========== TASK[%0d] fetch start fault PC=%16h type=%s ==========\n",
                            task_info.task_id,
                            fetch_ctx.task_start_pc,
                            fetch_ctx.fault_type.name());
                    `uvm_info("FETCH_ADDR_EXCEPTION",
                              $sformatf("core=%s task_id=%0d origin=%s type=%s fault_pc=0x%0h",
                                        core_name(task_info.rv_core),
                                        task_info.task_id,
                                        fetch_ctx.fault_origin.name(),
                                        fetch_ctx.fault_type.name(),
                                        fetch_ctx.task_start_pc), UVM_LOW)
                end

                if(!fetch_ctx.task_body_enable) begin
                    // Invalid task start is the complete stimulus.  Do not emit
                    // a program image or TASK_DONE for an unfetchable task.
                end
                else if(task_info.kind == SCENARIO_RANDOM_TASK) begin
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

                if(fetch_ctx.task_body_enable &&
                   !fetch_ctx.exception_injected &&
                   p_sequencer.inst_gen.fetch_space_avail())
                    pass_quit_seq.seq_gen(p_sequencer.inst_gen);
                task_end_pc = fetch_ctx.task_body_enable ?
                              fetch_ctx.current_pc : fetch_ctx.task_start_pc;
                inst_num = p_sequencer.inst_gen.get_task_inst_count();
                $fwrite(task_log, "------------task_id : %0d----------\n", task_info.task_id);
                $fwrite(task_log, "task_id: %0d\n", task_info.task_id);
                $fwrite(task_log, "rv_core: %s\n", core_name(task_info.rv_core));
                $fwrite(task_log, "start_pc: 0x%08h\n",
                        fetch_ctx.task_start_pc[31:0]);
                $fwrite(task_log, "global_start_pc: 0x%08h\n",
                        core_global_pc(task_info.rv_core,
                                       fetch_ctx.task_start_pc));
                $fwrite(task_log, "fetch_exception_enable: %0d\n",
                        task_info.fetch_exception_enable);
                $fwrite(task_log, "fetch_exception_injected: %0d\n",
                        fetch_ctx.exception_injected);
                if(fetch_ctx.exception_injected) begin
                    $fwrite(task_log, "fetch_fault_origin: %s\n",
                            fetch_ctx.fault_origin.name());
                    $fwrite(task_log, "fetch_fault_type: %s\n",
                            fetch_ctx.fault_type.name());
                    $fwrite(task_log, "fetch_fault_pc: 0x%08h\n",
                            fetch_ctx.fault_pc[31:0]);
                end
                if(task_info.kind == SCENARIO_RANDOM_TASK)
                    $fwrite(task_log, "seq_num: %0d\n", task_info.seq_num);
                $fwrite(task_log, "inst_num: %0d\n", inst_num);
                $fwrite(task_log, "end_pc: 0x%08h\n", task_end_pc[31:0]);
                $fwrite(task_log, "global_end_pc: 0x%08h\n\n",
                        core_global_pc(task_info.rv_core, task_end_pc));
                `uvm_info("SCENARIO_TASK",
                          $sformatf("core=%s task_id=%0d start_pc=0x%0h end_pc=0x%0h inst_num=%0d",
                                    core_name(task_info.rv_core), task_info.task_id,
                                    fetch_ctx.task_start_pc,
                                    task_end_pc, inst_num), UVM_LOW)
                p_sequencer.inst_gen.reg_pool.sync_active_context();
            end
        end

        if(p_sequencer.inst_gen.inst_gen_cfg.vmem_file_gen)
            p_sequencer.addr_space_gen.data_vmem_out(vmem_file);
        $fclose(asm_file);
        if(vmem_file)
            $fclose(vmem_file);
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
