class ts_scene_test extends uvm_test;
  `uvm_component_utils(ts_scene_test)
  ts_agent agent; ts_cfg cfg; virtual ts_if vif; uvm_analysis_imp_ts_mon #(ts_item,ts_scene_test) mon_imp;
  int observed;
  function new(string n,uvm_component p); super.new(n,p); mon_imp=new("mon_imp",this); endfunction
  function void build_phase(uvm_phase phase);
    string f; super.build_phase(phase);
    if(!uvm_config_db#(virtual ts_if)::get(this,"","ts_vif",vif)) `uvm_fatal("TS_TEST","missing vif")
    if(!$value$plusargs("TS_SEQ_FILE=%s",f)) `uvm_fatal("TS_TEST","TS_SEQ_FILE missing")
    cfg=ts_cfg::type_id::create("cfg"); cfg.vif=vif; cfg.sequence_file=f;
    uvm_config_db#(ts_cfg)::set(this,"agent","cfg",cfg); agent=ts_agent::type_id::create("agent",this);
  endfunction
  function void connect_phase(uvm_phase phase); agent.mon.ap.connect(mon_imp); endfunction
  function void write_ts_mon(ts_item t);
    if(t.execute_unit!=TS_VU||t.uid!=0||t.tid!=1||t.stream_id!=0||t.pc!=32'h1000)
      `uvm_error("TS_TEST",$sformatf("bad monitored task %s",t.sprint()))
    observed++;
  endfunction
  task main_phase(uvm_phase phase);
    ts_sequence seq; int timeout;
    phase.raise_objection(this); wait(vif.reset_n);
    repeat(2) begin seq=ts_sequence::type_id::create("seq"); seq.cfg=cfg; seq.start(agent.sqr); end
    timeout=0; while(agent.drv.completion_count<2&&timeout<200) begin @(posedge vif.clk); timeout++; end
    if(observed!=2) `uvm_error("TS_TEST",$sformatf("observed=%0d expected=2",observed))
    if(agent.drv.completion_count!=2) `uvm_error("TS_TEST","task completion timeout")
    if(agent.drv.rvcore_done_first_count!=1||agent.drv.dsa_done_first_count!=1)
      `uvm_error("TS_TEST","both done return orders were not covered")
    if(observed==2&&agent.drv.completion_count==2)
      `uvm_info("TS_TEST","TS_BYPASS PASS: RV-first and DSA-first completed",UVM_LOW)
    repeat(3) @(posedge vif.clk); phase.drop_objection(this);
  endtask
endclass
