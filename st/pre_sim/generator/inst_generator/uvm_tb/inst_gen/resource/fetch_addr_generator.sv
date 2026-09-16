// Single fetch-address algorithm shared by all RV cores.  Per-core state is
// stored in core_context_pool and selected by scenario_base_vsequence.
class fetch_addr_generator extends uvm_object;
    core_context_pool context_pool;
    fetch_addr_config  cfg;

    `uvm_object_utils(fetch_addr_generator)

    function new(string name = "fetch_addr_generator");
        super.new(name);
    endfunction

    function fetch_context get_context();
        if(context_pool == null)
            `uvm_fatal("FETCH_ADDR_CFG", "core_context_pool has not been bound")
        return context_pool.get_fetch_context();
    endfunction

    function void configure_active_context();
        fetch_context ctx;
        int unsigned core_index;
        if(cfg == null)
            `uvm_fatal("FETCH_ADDR_CFG", "fetch_addr_config has not been bound")
        ctx = get_context();
        core_index       = context_pool.get_active_context().core_index;
        ctx.itcm_start   = cfg.itcm_start[core_index];
        ctx.itcm_end     = cfg.itcm_start[core_index] + cfg.itcm_size[core_index];
        ctx.ialign_bytes = cfg.ialign_bytes;
    endfunction

    function void begin_core_stream();
        fetch_context ctx;
        configure_active_context();
        ctx = get_context();
        ctx.reset_stream();
    endfunction

    function bit random_hit(int unsigned percentage);
        if(percentage == 0)
            return 1'b0;
        if(percentage >= 100)
            return 1'b1;
        return ($urandom_range(99, 0) < percentage);
    endfunction

    function void begin_task(bit allow_exception);
        fetch_context ctx;
        ctx = get_context();
        ctx.reset_task();
        ctx.exception_enable = allow_exception;
    endfunction

    // Returns 0 when the task start PC is intentionally invalid.  In that
    // case the start address itself is the complete stimulus and no body is
    // emitted.
    function bit get_task_start_pc(bit [63:0] normal_start_pc,
                                   output bit [63:0] selected_start_pc);
        fetch_context ctx;
        ctx = get_context();
        selected_start_pc    = normal_start_pc;
        ctx.effective_start_pc = normal_start_pc;
        if(!cfg.allow_exception || !ctx.exception_enable ||
           !random_hit(cfg.start_exception_pct))
            return 1'b1;

        ctx.fault_origin = FETCH_ADDR_ORIGIN_TASK_START;
        if($urandom_range(1, 0)) begin
            selected_start_pc = ctx.itcm_end;
            ctx.fault_type = FETCH_ADDR_FAULT_OUT_OF_ITCM;
        end
        else begin
            selected_start_pc = ((normal_start_pc >= ctx.itcm_end - 1) ?
                                 ctx.itcm_start : normal_start_pc) | 64'h1;
            ctx.fault_type = FETCH_ADDR_FAULT_MISALIGNED;
        end
        ctx.effective_start_pc = selected_start_pc;
        ctx.fault_pc           = selected_start_pc;
        ctx.exception_injected = 1'b1;
        return 1'b0;
    endfunction

    function bit start_task(bit use_configured_start_pc,
                            bit [63:0] configured_start_pc,
                            bit allow_exception,
                            output bit [63:0] selected_start_pc);
        fetch_context ctx;
        bit [63:0] normal_start_pc;
        ctx = get_context();
        if(!ctx.stream_initialized)
            ctx.reset_stream();
        begin_task(allow_exception);
        normal_start_pc = use_configured_start_pc ? configured_start_pc :
                          ctx.current_pc;
        if(normal_start_pc[63:32] != '0)
            `uvm_fatal("FETCH_ADDR_CFG",
                       $sformatf("task start PC 0x%016h exceeds 32-bit address space",
                                 normal_start_pc))
        ctx.task_body_enable = get_task_start_pc(normal_start_pc,
                                                 selected_start_pc);
        ctx.task_start_pc = selected_start_pc;
        ctx.task_inst_history_start = ctx.inst_pc_history.size();
        if(!ctx.task_body_enable)
            return 1'b0;
        if(use_configured_start_pc)
            set_current_pc(configured_start_pc, configured_start_pc[31:0]);
        ctx.task_start_pc = ctx.current_pc;
        return 1'b1;
    endfunction

    function void set_current_pc(bit [63:0] vaddr, bit [31:0] paddr);
        fetch_context ctx;
        ctx = get_context();
        ctx.current_pc    = vaddr;
        ctx.current_paddr = paddr;
    endfunction

    function bit [63:0] current_pc();
        return get_context().current_pc;
    endfunction

    function bit [31:0] current_paddr();
        return get_context().current_paddr;
    endfunction

    function bit fetch_space_avail();
        fetch_context ctx;
        ctx = get_context();
        if(ctx.exception_injected)
            return 1'b0;
        if(ctx.current_pc > ctx.itcm_end)
            return 1'b1;
        if(ctx.current_pc + 'h8 <= ctx.itcm_end)
            return 1'b1;
        if(allow_end_overflow(ctx.current_pc)) begin
            if(ctx.current_pc < ctx.itcm_end)
                return 1'b1;
            commit_end_fault(ctx.current_pc, ctx.current_pc);
        end
        return 1'b0;
    endfunction

    function bit fetch_space_avail_for(int unsigned inst_bytes);
        fetch_context ctx;
        ctx = get_context();
        if(ctx.exception_injected)
            return 1'b0;
        if(ctx.current_pc > ctx.itcm_end)
            return 1'b1;
        if(ctx.end_fault_armed) begin
            if(ctx.current_pc + inst_bytes <= ctx.itcm_end)
                return 1'b1;
            commit_end_fault(ctx.current_pc, ctx.itcm_end);
            return 1'b0;
        end
        return (ctx.current_pc + inst_bytes + 'h4 <= ctx.itcm_end);
    endfunction

    function void commit_inst(int unsigned inst_bytes);
        fetch_context ctx;
        ctx = get_context();
        ctx.inst_pc_history.push_back(ctx.current_pc);
        ctx.current_pc    += inst_bytes;
        ctx.current_paddr += inst_bytes;
    endfunction

    function void force_advance(int unsigned inst_bytes);
        fetch_context ctx;
        ctx = get_context();
        ctx.current_pc    += inst_bytes;
        ctx.current_paddr += inst_bytes;
    endfunction

    function bit [63:0] random_pc_in_current_task();
        fetch_context ctx;
        int unsigned index;
        ctx = get_context();
        if(ctx.inst_pc_history.size() <= ctx.task_inst_history_start)
            return ctx.task_start_pc;
        index = $urandom_range(ctx.inst_pc_history.size() - 1,
                               ctx.task_inst_history_start);
        return ctx.inst_pc_history[index];
    endfunction

    function bit [63:0] last_inst_pc();
        fetch_context ctx;
        ctx = get_context();
        if(ctx.inst_pc_history.size() == 0)
            return ctx.current_pc;
        return ctx.inst_pc_history[$];
    endfunction

    function int unsigned task_inst_count();
        fetch_context ctx;
        ctx = get_context();
        return ctx.inst_pc_history.size() - ctx.task_inst_history_start;
    endfunction

    // Called only when an existing indirect-jump path requests its target.
    function bit get_control_fault_target(output bit [63:0] target_pc);
        fetch_context ctx;
        ctx = get_context();
        target_pc = ctx.itcm_end;
        if(!ctx.exception_enable || ctx.exception_injected ||
           ctx.control_fault_pending || !random_hit(cfg.control_exception_pct))
            return 1'b0;
        ctx.control_fault_pending = 1'b1;
        return 1'b1;
    endfunction

    function void commit_control_fault(bit [63:0] source_pc,
                                       bit [63:0] target_pc);
        fetch_context ctx;
        ctx = get_context();
        if(!ctx.control_fault_pending)
            return;
        ctx.control_fault_pending = 1'b0;
        ctx.exception_injected = 1'b1;
        ctx.fault_origin = FETCH_ADDR_ORIGIN_CONTROL_TARGET;
        ctx.fault_type = FETCH_ADDR_FAULT_OUT_OF_ITCM;
        ctx.fault_source_pc = source_pc;
        ctx.fault_pc = target_pc;
    endfunction

    function bit allow_end_overflow(bit [63:0] current_pc_arg);
        fetch_context ctx;
        ctx = get_context();
        if(ctx.end_fault_armed)
            return 1'b1;
        if(!ctx.exception_enable || ctx.exception_injected ||
           !random_hit(cfg.end_exception_pct))
            return 1'b0;
        ctx.end_fault_armed = 1'b1;
        return 1'b1;
    endfunction

    function void commit_end_fault(bit [63:0] source_pc,
                                   bit [63:0] target_pc);
        fetch_context ctx;
        ctx = get_context();
        ctx.exception_injected = 1'b1;
        ctx.fault_origin = FETCH_ADDR_ORIGIN_TASK_END;
        ctx.fault_type = FETCH_ADDR_FAULT_OUT_OF_ITCM;
        ctx.fault_source_pc = source_pc;
        ctx.fault_pc = target_pc;
    endfunction
endclass
