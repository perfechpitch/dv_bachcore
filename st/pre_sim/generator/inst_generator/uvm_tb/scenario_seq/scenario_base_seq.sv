typedef enum {SCENARIO_DIRECTED_TASK, SCENARIO_RANDOM_TASK} scenario_task_kind_e;

class scenario_task_info extends uvm_object;
    int unsigned         task_id;
    tcm_hart_e           rv_core;
    scenario_task_kind_e kind;
    bit                  use_start_pc;
    bit[63:0]            start_pc;
    int unsigned         seq_num;

    `uvm_object_utils(scenario_task_info)

    function new(string name = "scenario_task_info");
        super.new(name);
        kind         = SCENARIO_DIRECTED_TASK;
        use_start_pc = 1'b1;
        start_pc     = '0;
        seq_num      = 1;
    endfunction
endclass

// Scenario owns task layout and task contents. The virtual sequence only
// selects a scenario and calls run(); it does not know task IDs or PCs.
class scenario_base_seq extends uvm_object;
    typedef bit[63:0] task_pc_list_t[$];

    protected scenario_task_info task_plan[$];
    protected int task_log;
    protected int asm_file[3];
    protected int vmem_file[3];
    protected bit core_used[3];
    protected register_pool core_reg_pool[3];

    `uvm_object_utils(scenario_base_seq)

    function new(string name = "scenario_base_seq");
        super.new(name);
    endfunction

    virtual function void configure_tasks();
    endfunction

    function string core_name(tcm_hart_e core);
        case(core)
            HART_MU : return "mu";
            HART_VU : return "vu";
            HART_DTE: return "dte";
            default : return "unknown";
        endcase
    endfunction

    function void add_directed_task(int unsigned task_id,
                                    tcm_hart_e   rv_core,
                                    bit[63:0]    start_pc);
        scenario_task_info info;
        info = new($sformatf("directed_task_%0d", task_id));
        info.task_id      = task_id;
        info.rv_core      = rv_core;
        info.kind         = SCENARIO_DIRECTED_TASK;
        info.use_start_pc = 1'b1;
        info.start_pc     = start_pc;
        task_plan.push_back(info);
    endfunction

    function void add_random_task(int unsigned task_id,
                                  tcm_hart_e   rv_core,
                                  int unsigned seq_num = 1,
                                  bit          use_start_pc = 1'b0,
                                  bit[63:0]    start_pc = '0);
        scenario_task_info info;
        info = new($sformatf("random_task_%0d", task_id));
        info.task_id      = task_id;
        info.rv_core      = rv_core;
        info.kind         = SCENARIO_RANDOM_TASK;
        info.seq_num      = seq_num;
        info.use_start_pc = use_start_pc;
        info.start_pc     = start_pc;
        task_plan.push_back(info);
    endfunction

    // Compatibility helpers for existing single-core directed scenarios.
    function void set_task_layout(task_pc_list_t pc_list);
        task_plan.delete();
        foreach(pc_list[i])
            add_directed_task(i, HART_MU, pc_list[i]);
    endfunction

    function void add_task(bit[63:0] start_pc);
        add_directed_task(task_plan.size(), HART_MU, start_pc);
    endfunction

    function void validate_task_plan();
        foreach(task_plan[i]) begin
            if(task_plan[i].use_start_pc && task_plan[i].start_pc[0])
                `uvm_fatal("SCENARIO_TASK_CFG",
                           $sformatf("task_id=%0d start_pc=0x%0h is not 2-byte aligned",
                                     task_plan[i].task_id, task_plan[i].start_pc))
            foreach(task_plan[j]) begin
                if((j < i) && (task_plan[j].task_id == task_plan[i].task_id))
                    `uvm_fatal("SCENARIO_TASK_CFG",
                               $sformatf("duplicate global task_id=%0d", task_plan[i].task_id))
            end
        end
    endfunction

    function void bind_core_register_pool(int core_index,
                                          inst_generator inst_gen,
                                          inst_seq_generator inst_seq_gen);
        if(core_reg_pool[core_index] == null) begin
            core_reg_pool[core_index] = new($sformatf("%s_reg_pool", core_name(tcm_hart_e'(core_index))));
            core_reg_pool[core_index].csr_cfg       = inst_gen.reg_pool.csr_cfg;
            core_reg_pool[core_index].inst_gen_cfg  = inst_gen.inst_gen_cfg;
            if(!core_reg_pool[core_index].randomize())
                `uvm_fatal("SCENARIO_REG_POOL", "core register pool randomize failed")
        end
        inst_gen.reg_pool                    = core_reg_pool[core_index];
        inst_seq_gen.reg_pool                = core_reg_pool[core_index];
        inst_seq_gen.safe_inst_seq.reg_pool   = core_reg_pool[core_index];
        inst_seq_gen.flush_inst_seq.reg_pool  = core_reg_pool[core_index];
        inst_seq_gen.except_inst_seq.reg_pool = core_reg_pool[core_index];
        inst_seq_gen.branch_inst_seq.reg_pool = core_reg_pool[core_index];
        inst_seq_gen.ls_inst_seq.reg_pool     = core_reg_pool[core_index];
        inst_seq_gen.wfi_inst_seq.reg_pool    = core_reg_pool[core_index];
    endfunction

    virtual function void generate_task(scenario_task_info     task_info,
                                        inst_generator          inst_gen,
                                        inst_seq_generator      inst_seq_gen,
                                        inst_seq_type_generator inst_seq_type_gen);
        seq_gen(inst_gen, inst_seq_gen, inst_seq_type_gen);
    endfunction

    function void run(inst_generator          inst_gen,
                      inst_seq_generator      inst_seq_gen,
                      inst_seq_type_generator inst_seq_type_gen,
                      addr_space_generator    addr_space_gen);
        pass_quit_sequence pass_quit_seq;
        bit[63:0] task_pc;
        int unsigned history_start;
        int unsigned inst_num;
        inst_seq_type_e seq_type;

        configure_tasks();
        if(task_plan.size() == 0)
            add_directed_task(0, inst_seq_gen.ls_seq_cfg.hart, '0);
        validate_task_plan();
        pass_quit_seq = new("scenario_pass_quit_seq");
        task_log = $fopen("./log/task_info.log", "w");
        $fwrite(task_log, "# scenario task map; task IDs are globally unique\n");
        // Always truncate all fixed per-core outputs so a file left by an
        // earlier scenario can never be mistaken for this run's result.
        for(int core_index = 0; core_index < 3; core_index++) begin
            asm_file[core_index] = $fopen($sformatf("./%s_test.S",
                                                    core_name(tcm_hart_e'(core_index))), "w");
            vmem_file[core_index] = $fopen($sformatf("./%s_test.vmem",
                                                     core_name(tcm_hart_e'(core_index))), "w");
            if(!asm_file[core_index] || !vmem_file[core_index])
                `uvm_fatal("SCENARIO_FILE", "cannot open per-core output files")
        end

        // Static generation is grouped by core. State persists between tasks
        // of one core and is replaced before another core starts.
        for(int core_index = 0; core_index < 3; core_index++) begin
            core_used[core_index] = 1'b0;
            foreach(task_plan[i])
                if(int'(task_plan[i].rv_core) == core_index)
                    core_used[core_index] = 1'b1;
            if(!core_used[core_index])
                continue;

            bind_core_register_pool(core_index, inst_gen, inst_seq_gen);
            inst_seq_gen.ls_seq_cfg.hart = tcm_hart_e'(core_index);
            inst_seq_gen.ls_inst_seq.base_initial = 1'b0;
            inst_gen.ls_addr_gen.hart = tcm_hart_e'(core_index);
            inst_gen.ls_addr_gen.reset_bases();
            inst_gen.begin_core_stream(asm_file[core_index], vmem_file[core_index],
                                       tcm_hart_e'(core_index));
            inst_seq_gen.gen_file = asm_file[core_index];

            foreach(task_plan[i]) begin
                if(int'(task_plan[i].rv_core) != core_index)
                    continue;
                task_pc = task_plan[i].use_start_pc ? task_plan[i].start_pc : inst_gen.inst_addr;
                inst_gen.switch_task(task_plan[i].task_id, 1'b1, task_pc);
                history_start = inst_gen.inst_pc_history.size();

                if(task_plan[i].kind == SCENARIO_RANDOM_TASK) begin
                    repeat(task_plan[i].seq_num) begin
                        if(!inst_gen.fetch_space_avail())
                            break;
                        seq_type = inst_seq_type_gen.get_seq_type();
                        inst_seq_gen.rand_seq(seq_type);
                    end
                end
                else begin
                    generate_task(task_plan[i], inst_gen, inst_seq_gen, inst_seq_type_gen);
                end

                inst_num = inst_gen.inst_pc_history.size() - history_start;
                $fwrite(task_log, "------------task_id : %0d----------\n", task_plan[i].task_id);
                $fwrite(task_log, "task_id: %0d\n", task_plan[i].task_id);
                $fwrite(task_log, "rv_core: %s\n", core_name(task_plan[i].rv_core));
                $fwrite(task_log, "start_pc: 0x%016h\n", task_pc);
                $fwrite(task_log, "inst_num: %0d\n", inst_num);
                $fwrite(task_log, "end_pc: 0x%016h\n\n", inst_gen.inst_addr);
                `uvm_info("SCENARIO_TASK",
                          $sformatf("core=%s task_id=%0d start_pc=0x%0h end_pc=0x%0h inst_num=%0d",
                                    core_name(task_plan[i].rv_core), task_plan[i].task_id,
                                    task_pc, inst_gen.inst_addr, inst_num), UVM_LOW)
            end
            if(inst_gen.fetch_space_avail())
                pass_quit_seq.seq_gen(inst_gen);
        end

        // addr_space_gen is shared. Emit the complete data image into every
        // used core image only after all core instruction streams are done.
        for(int core_index = 0; core_index < 3; core_index++) begin
            if(core_used[core_index])
                addr_space_gen.data_vmem_out(vmem_file[core_index]);
            $fclose(asm_file[core_index]);
            $fclose(vmem_file[core_index]);
        end
        $fwrite(task_log, "# done tasks=%0d\n", task_plan.size());
        $fclose(task_log);
    endfunction

    virtual function void seq_gen(inst_generator          inst_gen,
                                  inst_seq_generator      inst_seq_gen,
                                  inst_seq_type_generator inst_seq_type_gen);
    endfunction
endclass
