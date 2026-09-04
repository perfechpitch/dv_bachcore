class rand_flush_except_test extends rand_inst_test;
  `uvm_component_utils(rand_flush_except_test)
  function new(string name = "rand_flush_except_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction
  virtual function void configure_test_feature();
    inst_gen_case_cfg.test_feature.push_back(FLUSH_INST_ENABLE);
    inst_gen_case_cfg.test_feature.push_back(EXCEPT_INST_ENABLE);
  endfunction
endclass