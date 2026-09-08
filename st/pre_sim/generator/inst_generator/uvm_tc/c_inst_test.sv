class c_inst_test extends rand_inst_test;
    `uvm_component_utils(c_inst_test)

    function new(string name = "c_inst_test",
                 uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        uvm_config_db#(uvm_object_wrapper)::set(
            this,
            "env.inst_gen_vsqr.main_phase",
            "default_sequence",
            c_inst_vsequence::type_id::get()
        );
    endfunction
endclass
