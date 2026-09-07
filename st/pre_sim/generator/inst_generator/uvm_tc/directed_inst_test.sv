class directed_inst_test extends rand_inst_test;

  `uvm_component_utils(directed_inst_test)

  function new(string name = "directed_inst_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Replace only the top-level program flow; case configuration remains
    // inherited from rand_inst_test.
    uvm_config_db#(uvm_object_wrapper)::set(
      this,
      "env.inst_gen_vsqr.main_phase",
      "default_sequence",
      directed_vsequence::type_id::get()
    );
  endfunction

endclass
