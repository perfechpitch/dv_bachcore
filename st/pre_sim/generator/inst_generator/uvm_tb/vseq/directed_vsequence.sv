// 定向 program：按 +directed_seq_name= 从仓库取场景再发。不改 seq_debug_vsequence。
class directed_vsequence extends scenario_base_vsequence;
    directed_scenario_registry registry;
    `uvm_object_utils(directed_vsequence)

    function new(string name = "directed_vsequence");
        super.new(name);
        registry = new();
    endfunction

    virtual function bit get_scenario_name(output string seq_name);
        return $value$plusargs("directed_seq_name=%s", seq_name);
    endfunction

    virtual function string scenario_arg_help();
        return "+directed_seq_name=<scenario>";
    endfunction

    virtual function scenario_base_seq create_scenario(string seq_name);
        return registry.get(seq_name);
    endfunction
endclass : directed_vsequence
