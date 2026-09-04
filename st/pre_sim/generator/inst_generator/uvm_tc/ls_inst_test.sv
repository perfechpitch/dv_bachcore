class ls_inst_test extends rand_inst_test;
  `uvm_component_utils(ls_inst_test)
  function new(string name = "ls_inst_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction
  virtual function void configure_test_feature();
    inst_gen_case_cfg.test_feature.push_back(SAFE_SEQ_DISABLE);
    inst_gen_case_cfg.test_feature.push_back(BRANCH_SEQ_DISABLE);
  endfunction
endclass