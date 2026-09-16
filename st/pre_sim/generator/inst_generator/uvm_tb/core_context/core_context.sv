// One fully typed state container per RV core. Resource generators share one
// algorithm instance and save/restore mutable state through these contexts.
class core_context extends uvm_object;
    int unsigned     core_index;
    fetch_context    fetch_ctx;
    register_context register_ctx;
    ls_context       ls_ctx;

    `uvm_object_utils(core_context)

    function new(string name = "core_context");
        super.new(name);
        fetch_ctx    = new({name, "_fetch"});
        register_ctx = new({name, "_register"});
        ls_ctx       = new({name, "_ls"});
    endfunction
endclass
