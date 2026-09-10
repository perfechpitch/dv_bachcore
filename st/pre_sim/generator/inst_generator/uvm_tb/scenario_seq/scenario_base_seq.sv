typedef enum {SCENARIO_DIRECTED_TASK, SCENARIO_RANDOM_TASK} scenario_task_kind_e;
typedef enum {SCENARIO_SEQ_AUTO, SCENARIO_SEQ_PLAN} scenario_seq_select_mode_e;
typedef enum {WEIGHT_DISABLE, WEIGHT_LOW, WEIGHT_MEDIUM, WEIGHT_HIGH} scenario_weight_e;
localparam int unsigned SCENARIO_AUTO_TASK_ID = 32'hffff_ffff;
localparam int unsigned SCENARIO_AUTO_SEQ_NUM = 0;
typedef enum {
    SCENARIO_SAFE_INT_CAL,
    SCENARIO_SAFE_FLOAT_CAL,
    SCENARIO_SAFE_BRANCH,
    SCENARIO_SAFE_INT_LS,
    SCENARIO_SAFE_CUSTOM_DSA,
    SCENARIO_LS_RAND,
    SCENARIO_LS_LINEAR,
    SCENARIO_LS_MEMCPY,
    SCENARIO_BRANCH_SINGLE,
    SCENARIO_BRANCH_LOOP,
    SCENARIO_BRANCH_JALR
} scenario_subseq_type_e;

class scenario_seq_plan_item extends uvm_object;
    inst_seq_type_e seq_type;
    scenario_weight_e weight;

    `uvm_object_utils_begin(scenario_seq_plan_item)
        `uvm_field_enum(inst_seq_type_e, seq_type, UVM_DEFAULT)
        `uvm_field_enum(scenario_weight_e, weight, UVM_DEFAULT)
    `uvm_object_utils_end

    function new(string name = "scenario_seq_plan_item");
        super.new(name);
        weight = WEIGHT_MEDIUM;
    endfunction
endclass

class scenario_subseq_plan_item extends uvm_object;
    inst_seq_type_e       seq_type;
    scenario_subseq_type_e subseq_type;
    scenario_weight_e     weight;

    `uvm_object_utils_begin(scenario_subseq_plan_item)
        `uvm_field_enum(inst_seq_type_e, seq_type, UVM_DEFAULT)
        `uvm_field_enum(scenario_subseq_type_e, subseq_type, UVM_DEFAULT)
        `uvm_field_enum(scenario_weight_e, weight, UVM_DEFAULT)
    `uvm_object_utils_end

    function new(string name = "scenario_subseq_plan_item");
        super.new(name);
        weight = WEIGHT_MEDIUM;
    endfunction
endclass

class scenario_task_info extends uvm_object;
    int unsigned         task_id;
    tcm_hart_e           rv_core;
    scenario_task_kind_e kind;
    bit                  use_start_pc;
    bit[63:0]            start_pc;
    int unsigned         seq_num;
    scenario_seq_select_mode_e seq_select_mode;
    scenario_seq_plan_item     seq_plan[$];
    scenario_subseq_plan_item  subseq_plan[$];

    `uvm_object_utils(scenario_task_info)

    function new(string name = "scenario_task_info");
        super.new(name);
        kind         = SCENARIO_DIRECTED_TASK;
        use_start_pc = 1'b1;
        start_pc     = '0;
        seq_num      = SCENARIO_AUTO_SEQ_NUM;
        seq_select_mode = SCENARIO_SEQ_AUTO;
    endfunction
endclass

// Scenario is the only task planner. It describes task layout and directed
// task contents; the virtual sequence owns all execution mechanics.
class scenario_base_seq extends uvm_object;
    typedef bit[63:0] task_pc_list_t[$];

    protected scenario_task_info task_plan[$];

    `uvm_object_utils(scenario_base_seq)

    function new(string name = "scenario_base_seq");
        super.new(name);
    endfunction

    virtual function void configure_tasks();
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

    function int unsigned allocate_random_task_id();
        int unsigned candidate;
        bit          in_use;
        repeat(1000) begin
            candidate = $urandom_range(15, 0);
            in_use = 1'b0;
            foreach(task_plan[i]) begin
                if(task_plan[i].task_id == candidate)
                    in_use = 1'b1;
            end
            if(!in_use)
                return candidate;
        end
        `uvm_fatal("SCENARIO_TASK_CFG", "cannot allocate a unique random task_id")
        return SCENARIO_AUTO_TASK_ID;
    endfunction

    function int unsigned random_task_num();
        int unsigned task_num;
        if(!$value$plusargs("scenario_task_num=%d", task_num)) begin
            if(!std::randomize(task_num) with {task_num inside {[1:8]};})
                `uvm_fatal("SCENARIO_TASK_CFG", "task_num randomize failed")
        end
        if(!(task_num inside {[1:8]}))
            `uvm_fatal("SCENARIO_TASK_CFG",
                       $sformatf("scenario_task_num=%0d is illegal; valid range is [1:8]",
                                 task_num))
        return task_num;
    endfunction

    function int unsigned add_random_task(
                                  int unsigned task_id = SCENARIO_AUTO_TASK_ID,
                                  tcm_hart_e   rv_core = HART_MU,
                                  int unsigned seq_num = SCENARIO_AUTO_SEQ_NUM,
                                  bit          use_start_pc = 1'b0,
                                  bit[63:0]    start_pc = '0);
        scenario_task_info info;
        int unsigned resolved_task_id;
        resolved_task_id = (task_id == SCENARIO_AUTO_TASK_ID) ?
                           allocate_random_task_id() : task_id;
        info = new($sformatf("random_task_%0d", resolved_task_id));
        info.task_id      = resolved_task_id;
        info.rv_core      = rv_core;
        info.kind         = SCENARIO_RANDOM_TASK;
        info.seq_num      = seq_num;
        info.use_start_pc = use_start_pc;
        info.start_pc     = start_pc;
        task_plan.push_back(info);
        return resolved_task_id;
    endfunction

    // Configure one random-sequence category using a scenario-level preference.
    // Numeric weights and generator config ownership stay in inst_gen_case_config.
    function void set_task_seq_weight(int unsigned      task_id,
                                      inst_seq_type_e    seq_type,
                                      scenario_weight_e weight = WEIGHT_MEDIUM);
        scenario_seq_plan_item item;
        foreach(task_plan[i]) begin
            if(task_plan[i].task_id != task_id)
                continue;
            if(task_plan[i].kind != SCENARIO_RANDOM_TASK)
                `uvm_fatal("SCENARIO_SEQ_CFG",
                           $sformatf("task_id=%0d is not a random task", task_id))
            foreach(task_plan[i].seq_plan[j]) begin
                if(task_plan[i].seq_plan[j].seq_type == seq_type)
                    `uvm_fatal("SCENARIO_SEQ_CFG",
                               $sformatf("task_id=%0d has duplicate seq_type=%s",
                                         task_id, seq_type.name()))
            end
            item = new($sformatf("task_%0d_%s_%0d",
                                  task_id, seq_type.name(), task_plan[i].seq_plan.size()));
            item.seq_type  = seq_type;
            item.weight    = weight;
            task_plan[i].seq_select_mode = SCENARIO_SEQ_PLAN;
            task_plan[i].seq_plan.push_back(item);
            return;
        end
        `uvm_fatal("SCENARIO_SEQ_CFG",
                   $sformatf("cannot add seq_type=%s: task_id=%0d is not defined",
                             seq_type.name(), task_id))
    endfunction

    function bit subseq_matches_parent(inst_seq_type_e        seq_type,
                                       scenario_subseq_type_e subseq_type);
        case(seq_type)
            SAFE_INST_SEQ:
                return subseq_type inside {
                    SCENARIO_SAFE_INT_CAL, SCENARIO_SAFE_FLOAT_CAL,
                    SCENARIO_SAFE_BRANCH, SCENARIO_SAFE_INT_LS,
                    SCENARIO_SAFE_CUSTOM_DSA
                };
            LS_INST_SEQ:
                return subseq_type inside {
                    SCENARIO_LS_RAND, SCENARIO_LS_LINEAR,
                    SCENARIO_LS_MEMCPY
                };
            BRANCH_INST_SEQ:
                return subseq_type inside {
                    SCENARIO_BRANCH_SINGLE, SCENARIO_BRANCH_LOOP,
                    SCENARIO_BRANCH_JALR
                };
            default:
                return 1'b0;
        endcase
    endfunction

    // Configure the direct child selector of an enabled top-level sequence.
    // The scenario expresses only preference levels; inst_gen_case_config owns
    // numeric conversion, capability checks and runtime config updates.
    function void set_task_subseq_weight(int unsigned           task_id,
                                         inst_seq_type_e         seq_type,
                                         scenario_subseq_type_e subseq_type,
                                         scenario_weight_e      weight = WEIGHT_MEDIUM);
        scenario_subseq_plan_item item;
        bit parent_disabled;

        if(!subseq_matches_parent(seq_type, subseq_type))
            `uvm_fatal("SCENARIO_SUBSEQ_CFG",
                       $sformatf("subseq_type=%s is not a child of seq_type=%s",
                                 subseq_type.name(), seq_type.name()))

        foreach(task_plan[i]) begin
            if(task_plan[i].task_id != task_id)
                continue;
            if(task_plan[i].kind != SCENARIO_RANDOM_TASK)
                `uvm_fatal("SCENARIO_SUBSEQ_CFG",
                           $sformatf("task_id=%0d is not a random task", task_id))

            parent_disabled = 1'b0;
            foreach(task_plan[i].seq_plan[j]) begin
                if(task_plan[i].seq_plan[j].seq_type == seq_type &&
                   task_plan[i].seq_plan[j].weight == WEIGHT_DISABLE)
                    parent_disabled = 1'b1;
            end
            if(parent_disabled)
                `uvm_fatal("SCENARIO_SUBSEQ_CFG",
                           $sformatf("task_id=%0d explicitly disables parent seq_type=%s and cannot configure %s",
                                     task_id, seq_type.name(), subseq_type.name()))

            foreach(task_plan[i].subseq_plan[j]) begin
                if(task_plan[i].subseq_plan[j].subseq_type == subseq_type)
                    `uvm_fatal("SCENARIO_SUBSEQ_CFG",
                               $sformatf("task_id=%0d has duplicate subseq_type=%s",
                                         task_id, subseq_type.name()))
            end

            item = new($sformatf("task_%0d_%s", task_id, subseq_type.name()));
            item.seq_type   = seq_type;
            item.subseq_type = subseq_type;
            item.weight     = weight;
            task_plan[i].subseq_plan.push_back(item);
            return;
        end

        `uvm_fatal("SCENARIO_SUBSEQ_CFG",
                   $sformatf("cannot configure subseq_type=%s: task_id=%0d is not defined",
                             subseq_type.name(), task_id))
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

    // Called once by the executing virtual sequence. Keeping plan creation
    // here makes scenario the sole owner of task count, IDs, cores and PCs.
    function void build_task_plan(tcm_hart_e default_core);
        task_plan.delete();
        configure_tasks();
        if(task_plan.size() == 0)
            add_directed_task(0, default_core, '0);
        validate_task_plan();
    endfunction

    function int unsigned get_task_count();
        return task_plan.size();
    endfunction

    function scenario_task_info get_task(int unsigned index);
        if(index >= task_plan.size())
            `uvm_fatal("SCENARIO_TASK_CFG",
                       $sformatf("task index=%0d out of range, task_count=%0d",
                                 index, task_plan.size()))
        return task_plan[index];
    endfunction

    virtual function void generate_task(scenario_task_info     task_info,
                                        inst_generator          inst_gen,
                                        inst_seq_generator      inst_seq_gen,
                                        inst_seq_type_generator inst_seq_type_gen);
        seq_gen(inst_gen, inst_seq_gen, inst_seq_type_gen);
    endfunction

    virtual function void seq_gen(inst_generator          inst_gen,
                                  inst_seq_generator      inst_seq_gen,
                                  inst_seq_type_generator inst_seq_type_gen);
    endfunction
endclass
