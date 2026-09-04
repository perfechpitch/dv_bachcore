class branch_inst_test extends rand_inst_test;
  `uvm_component_utils(branch_inst_test)
  function new(string name = "branch_inst_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction
  virtual function void configure_test_feature();
    inst_gen_case_cfg.test_feature.push_back(SAFE_SEQ_DISABLE);
    inst_gen_case_cfg.test_feature.push_back(LS_SEQ_DISABLE);
    inst_gen_case_cfg.global_disable_ls = 1;
  endfunction
endclass