// Per-core load/store state. Shared-memory geometry remains a single
// platform-level configuration in ls_addr_generator.
class ls_context extends uvm_object;
    tcm_hart_e hart;
    bit [63:0] dtcm_base;
    ls_addr_s  bound_base[$];
    bit        initialized;
    `uvm_object_utils(ls_context)
    function new(string name = "ls_context");
        super.new(name);
        hart        = HART_MU;
        // Platform geometry is applied by ls_addr_generator from env config.
        // Keep this context package independent of inst_gen_define.svh.
        dtcm_base   = '0;
        initialized = 1'b0;
    endfunction
endclass
