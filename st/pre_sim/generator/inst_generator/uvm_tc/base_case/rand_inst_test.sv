class rand_inst_test extends uvm_test;

  `uvm_component_utils(rand_inst_test)

  inst_gen_environment env;
  inst_gen_case_config inst_gen_case_cfg;
  
  function new(string name = "rand_inst_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction
  virtual function void configure_test_feature();
  endfunction
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    env = inst_gen_environment::type_id::create("env", this);
    inst_gen_case_cfg = inst_gen_case_config::type_id::create("inst_gen_case_cfg");
    
    inst_gen_case_cfg.random_sub_config();
    configure_test_feature();
    inst_gen_case_cfg.config_convert();
    inst_gen_case_cfg.test_feature_convert();

    uvm_config_db#(inst_gen_case_config)::set(this, "env", "inst_gen_case_cfg", inst_gen_case_cfg);

  endfunction

endclass
