class ts_agent extends uvm_agent;
  `uvm_component_utils(ts_agent)
  ts_cfg cfg; ts_sequencer sqr; ts_driver drv; ts_monitor mon;
  function new(string n,uvm_component p); super.new(n,p); endfunction
  function void build_phase(uvm_phase phase);
    super.build_phase(phase); if(!uvm_config_db#(ts_cfg)::get(this,"","cfg",cfg)) `uvm_fatal("TS_AGENT","missing cfg")
    uvm_config_db#(ts_cfg)::set(this,"mon","cfg",cfg); mon=ts_monitor::type_id::create("mon",this);
    if(cfg.is_active==UVM_ACTIVE) begin uvm_config_db#(ts_cfg)::set(this,"drv","cfg",cfg);
      sqr=ts_sequencer::type_id::create("sqr",this); drv=ts_driver::type_id::create("drv",this); end
  endfunction
  function void connect_phase(uvm_phase phase); if(cfg.is_active==UVM_ACTIVE) drv.seq_item_port.connect(sqr.seq_item_export); endfunction
endclass
