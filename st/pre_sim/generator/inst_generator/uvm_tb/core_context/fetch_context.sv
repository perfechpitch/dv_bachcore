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

// Per-core fetch configuration and runtime state.  Address generation policy
// lives in fetch_addr_generator; this object only preserves one core's state.
class fetch_context extends uvm_object;
    bit [63:0]                itcm_start;
    bit [63:0]                itcm_end;
    int unsigned              ialign_bytes;

    bit [63:0]                current_pc;
    bit [31:0]                current_paddr;
    bit [63:0]                task_start_pc;
    bit [63:0]                inst_pc_history[$];
    int unsigned              task_inst_history_start;
    bit                       stream_initialized;
    bit                       task_body_enable;

    bit                       exception_enable;
    bit                       exception_injected;
    bit                       control_fault_pending;
    bit                       end_fault_armed;
    fetch_addr_fault_e        fault_type;
    fetch_addr_fault_origin_e fault_origin;
    bit [63:0]                effective_start_pc;
    bit [63:0]                fault_source_pc;
    bit [63:0]                fault_pc;

    `uvm_object_utils(fetch_context)

    function new(string name = "fetch_context");
        super.new(name);
        itcm_start   = '0;
        // Platform limits are applied by fetch_addr_generator after env
        // configuration; keep the standalone context package macro-free.
        itcm_end     = '0;
        ialign_bytes = 4;
        reset_stream();
    endfunction

    function void reset_task();
        task_body_enable      = 1'b0;
        exception_enable      = 1'b0;
        exception_injected    = 1'b0;
        control_fault_pending = 1'b0;
        end_fault_armed       = 1'b0;
        fault_type            = FETCH_ADDR_FAULT_NONE;
        fault_origin          = FETCH_ADDR_ORIGIN_NONE;
        effective_start_pc    = '0;
        fault_source_pc       = '0;
        fault_pc              = '0;
    endfunction

    function void reset_stream();
        current_pc             = '0;
        current_paddr          = '0;
        task_start_pc          = '0;
        task_inst_history_start = 0;
        stream_initialized     = 1'b1;
        inst_pc_history.delete();
        reset_task();
    endfunction
endclass
