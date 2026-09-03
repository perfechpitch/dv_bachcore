class rv_dsa_agent extends uvm_agent;
  `uvm_component_utils(rv_dsa_agent)
  rv_dsa_cfg cfg; rv_dsa_driver drv; rv_dsa_sequencer sqr; rv_dsa_monitor mon;
  function new(string name,uvm_component parent); super.new(name,parent); endfunction
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(rv_dsa_cfg)::get(this,"","cfg",cfg)) `uvm_fatal("RV_DSA_AGENT","missing cfg")
    uvm_config_db#(rv_dsa_cfg)::set(this,"*","cfg",cfg);
    mon=rv_dsa_monitor::type_id::create("mon",this);
    if(cfg.is_active==UVM_ACTIVE) begin
      sqr=rv_dsa_sequencer::type_id::create("sqr",this);
      drv=rv_dsa_driver::type_id::create("drv",this);
    end
  endfunction
  function void connect_phase(uvm_phase phase);
    if(cfg.is_active==UVM_ACTIVE) drv.seq_item_port.connect(sqr.seq_item_export);
  endfunction
endclass
