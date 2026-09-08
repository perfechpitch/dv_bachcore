class random_scenario_test extends rand_inst_test;
    `uvm_component_utils(random_scenario_test)

    function new(string name = "random_scenario_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        uvm_config_db#(uvm_object_wrapper)::set(
            this, "env.inst_gen_vsqr.main_phase", "default_sequence",
            random_scenario_vsequence::type_id::get());
    endfunction
endclass
