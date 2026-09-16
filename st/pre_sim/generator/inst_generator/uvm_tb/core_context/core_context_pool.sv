// Environment-owned context bank.  Generators are permanently connected to
// this object and use the context selected by scenario_base_vsequence.
class core_context_pool extends uvm_object;
    core_context contexts[3];
    protected core_context active_context;

    `uvm_object_utils(core_context_pool)

    function new(string name = "core_context_pool");
        super.new(name);
        for(int i = 0; i < 3; i++) begin
            contexts[i] = new($sformatf("core_context_%0d", i));
            contexts[i].core_index = i;
        end
        // Keep legacy non-scenario tests usable; env selects the configured
        // default core again after applying inst_gen_case_cfg.
        active_context = contexts[0];
    endfunction

    function void select_core(int unsigned core);
        int index;
        index = core;
        if(index < 0 || index >= 3)
            `uvm_fatal("CORE_CONTEXT", $sformatf("invalid rv_core index %0d", index))
        active_context = contexts[index];
    endfunction

    function core_context get_active_context();
        if(active_context == null)
            `uvm_fatal("CORE_CONTEXT", "active core context has not been selected")
        return active_context;
    endfunction

    function fetch_context get_fetch_context();
        return get_active_context().fetch_ctx;
    endfunction

    function register_context get_register_context();
        return get_active_context().register_ctx;
    endfunction

    function ls_context get_ls_context();
        return get_active_context().ls_ctx;
    endfunction
endclass
