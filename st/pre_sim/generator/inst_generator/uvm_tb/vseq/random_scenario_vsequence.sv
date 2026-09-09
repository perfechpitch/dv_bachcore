class random_scenario_vsequence extends scenario_base_vsequence;
    random_scenario_registry registry;
    `uvm_object_utils(random_scenario_vsequence)

    function new(string name = "random_scenario_vsequence");
        super.new(name);
        registry = new();
    endfunction

    virtual function bit get_scenario_name(output string seq_name);
        return $value$plusargs("random_scenario_name=%s", seq_name);
    endfunction

    virtual function string scenario_arg_help();
        return "+random_scenario_name=<scenario>";
    endfunction

    virtual function scenario_base_seq create_scenario(string seq_name);
        return registry.get(seq_name);
    endfunction
endclass
