typedef enum {
    FETCH_ADDR_FAULT_NONE,
    FETCH_ADDR_FAULT_MISALIGNED,
    FETCH_ADDR_FAULT_OUT_OF_ITCM
} fetch_addr_fault_e;

typedef enum {
    FETCH_ADDR_ORIGIN_NONE,
    FETCH_ADDR_ORIGIN_TASK_START,
    FETCH_ADDR_ORIGIN_TASK_END,
    FETCH_ADDR_ORIGIN_CONTROL_TARGET
} fetch_addr_fault_origin_e;

// Fetch-address policy helper owned by inst_generator.  Scenario only gates
// whether faults are allowed; each real address-generation point randomizes
// valid versus invalid behavior independently.
class fetch_addr_generator extends uvm_object;
    tcm_hart_e                rv_core;
    bit [63:0]                itcm_start;
    bit [63:0]                itcm_end;
    int unsigned              ialign_bytes;

    bit                       exception_enable;
    bit                       exception_injected;
    bit                       control_fault_pending;
    bit                       end_fault_armed;
    fetch_addr_fault_e        fault_type;
    fetch_addr_fault_origin_e fault_origin;
    bit [63:0]                effective_start_pc;
    bit [63:0]                fault_source_pc;
    bit [63:0]                fault_pc;

    int unsigned start_exception_pct   = 10;
    int unsigned control_exception_pct = 10;
    int unsigned end_exception_pct     = 10;

    `uvm_object_utils(fetch_addr_generator)

    function new(string name = "fetch_addr_generator");
        int unsigned value;
        super.new(name);
        if($value$plusargs("fetch_start_exception_pct=%d", value))
            start_exception_pct = value;
        if($value$plusargs("fetch_control_exception_pct=%d", value))
            control_exception_pct = value;
        if($value$plusargs("fetch_end_exception_pct=%d", value))
            end_exception_pct = value;
        if(start_exception_pct > 100 || control_exception_pct > 100 ||
           end_exception_pct > 100)
            `uvm_fatal("FETCH_ADDR_CFG", "fetch exception percentages must be in [0:100]")
    endfunction

    function void configure_core(tcm_hart_e core, bit support_rvc);
        rv_core      = core;
        itcm_start   = 'h0;
        itcm_end     = `ITCM_SIZE;
        ialign_bytes = support_rvc ? 2 : 4;
    endfunction

    function bit random_hit(int unsigned percentage);
        if(percentage == 0)
            return 1'b0;
        if(percentage >= 100)
            return 1'b1;
        return ($urandom_range(99, 0) < percentage);
    endfunction

    function void begin_task(bit allow_exception);
        exception_enable     = allow_exception;
        exception_injected   = 1'b0;
        control_fault_pending = 1'b0;
        end_fault_armed      = 1'b0;
        fault_type           = FETCH_ADDR_FAULT_NONE;
        fault_origin         = FETCH_ADDR_ORIGIN_NONE;
        effective_start_pc   = '0;
        fault_source_pc      = '0;
        fault_pc             = '0;
    endfunction

    // Returns 0 when the externally supplied task start PC is intentionally
    // invalid.  In that case no instruction image is emitted for this task.
    function bit get_task_start_pc(bit [63:0] normal_start_pc,
                                 output bit [63:0] selected_start_pc);
        selected_start_pc = normal_start_pc;
        effective_start_pc = normal_start_pc;
        if(!exception_enable || !random_hit(start_exception_pct))
            return 1'b1;

        fault_origin = FETCH_ADDR_ORIGIN_TASK_START;
        if($urandom_range(1, 0)) begin
            selected_start_pc = itcm_end;
            fault_type = FETCH_ADDR_FAULT_OUT_OF_ITCM;
        end
        else begin
            selected_start_pc = ((normal_start_pc >= itcm_end - 1) ?
                                 itcm_start : normal_start_pc) | 64'h1;
            fault_type = FETCH_ADDR_FAULT_MISALIGNED;
        end
        effective_start_pc = selected_start_pc;
        fault_pc = selected_start_pc;
        exception_injected = 1'b1;
        return 1'b0;
    endfunction

    // Called only when an existing indirect-jump path requests its target.
    // The returned address stays IALIGN aligned and isolates an ITCM-range fault.
    function bit get_control_fault_target(output bit [63:0] target_pc);
        target_pc = itcm_end;
        if(!exception_enable || exception_injected || control_fault_pending ||
           !random_hit(control_exception_pct))
            return 1'b0;
        control_fault_pending = 1'b1;
        return 1'b1;
    endfunction

    function void commit_control_fault(bit [63:0] source_pc,
                                       bit [63:0] target_pc);
        if(!control_fault_pending)
            return;
        control_fault_pending = 1'b0;
        exception_injected = 1'b1;
        fault_origin = FETCH_ADDR_ORIGIN_CONTROL_TARGET;
        fault_type = FETCH_ADDR_FAULT_OUT_OF_ITCM;
        fault_source_pc = source_pc;
        fault_pc = target_pc;
    endfunction

    // Randomized only when the normal four-byte TASK_DONE reserve is reached.
    // A short task never reaches this opportunity and therefore remains normal.
    function bit allow_end_overflow(bit [63:0] current_pc);
        if(end_fault_armed)
            return 1'b1;
        if(!exception_enable || exception_injected ||
           !random_hit(end_exception_pct))
            return 1'b0;
        end_fault_armed = 1'b1;
        return 1'b1;
    endfunction

    function void commit_end_fault(bit [63:0] source_pc,
                                   bit [63:0] target_pc);
        exception_injected = 1'b1;
        fault_origin = FETCH_ADDR_ORIGIN_TASK_END;
        fault_type = FETCH_ADDR_FAULT_OUT_OF_ITCM;
        fault_source_pc = source_pc;
        fault_pc = target_pc;
    endfunction
endclass
