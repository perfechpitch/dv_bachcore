class ts_dispatch_test_base extends uvm_test;
  `uvm_component_utils(ts_dispatch_test_base)
  ts2rvcore_agent agent;
  ts_cfg cfg;
  virtual ts_if vif;
  uvm_analysis_imp_ts_mon #(ts_item,ts_dispatch_test_base) mon_imp;
  ts_item observed[$];

  function new(string name,uvm_component parent);
    super.new(name,parent);
    mon_imp=new("mon_imp",this);
  endfunction
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual ts_if)::get(this,"","ts_vif",vif))
      `uvm_fatal("TS_DISPATCH_TEST","missing vif")
    cfg=ts_cfg::type_id::create("cfg"); cfg.vif=vif;
    uvm_config_db#(ts_cfg)::set(this,"agent","cfg",cfg);
    agent=ts2rvcore_agent::type_id::create("agent",this);
  endfunction
  function void connect_phase(uvm_phase phase); agent.mon.ap.connect(mon_imp); endfunction
  function void write_ts_mon(ts_item t); observed.push_back(t); endfunction
  function ts_dispatch_sequence make_dispatch(string name,bit random_context,
      bit [15:0] uid=0,bit [3:0] stream_id=0);
    ts_dispatch_sequence seq=ts_dispatch_sequence::type_id::create(name);
    seq.task_id=6'd1; seq.start_pc=32'h1000; seq.execute_unit=TS_VU;
    seq.execution_mode=TS_RVCORE_ONLY; seq.pid=8'd4; seq.vcid=2'd2;
    seq.random_context=random_context; seq.directed_uid=uid;
    seq.directed_stream_id=stream_id;
    return seq;
  endfunction
  task wait_for_completions(int expected);
    int timeout=0;
    while(agent.drv.completion_count<expected && timeout<2000) begin
      @(posedge vif.clk); timeout++;
    end
    if(agent.drv.completion_count!=expected)
      `uvm_error("TS_DISPATCH_TEST",$sformatf("completion timeout actual=%0d expected=%0d",
        agent.drv.completion_count,expected))
  endtask
  function void check_task_fields(ts_item t,int index);
    if(t.tid!=6'd1 || t.pc!=32'h1000 || t.execute_unit!=TS_VU ||
       t.pid!=8'd4 || t.vcid!=2'd2)
      `uvm_error("TS_DISPATCH_TEST",$sformatf("task-owned field changed at dispatch %0d: %s",
        index,t.sprint()))
  endfunction
endclass

class ts_same_task_multi_dispatch_test extends ts_dispatch_test_base;
  `uvm_component_utils(ts_same_task_multi_dispatch_test)
  function new(string name,uvm_component parent); super.new(name,parent); endfunction
  task main_phase(uvm_phase phase);
    ts_dispatch_sequence seq;
    phase.raise_objection(this); wait(vif.reset_n);
    seq=make_dispatch("dispatch_stream_1",0,16'd0,4'd1); seq.start(agent.sqr);
    seq=make_dispatch("dispatch_stream_2",0,16'd0,4'd2); seq.start(agent.sqr);
    wait_for_completions(2);
    if(observed.size()!=2) `uvm_error("TS_MULTI_DISPATCH",$sformatf("observed=%0d expected=2",observed.size()))
    foreach(observed[i]) check_task_fields(observed[i],i);
    if(observed.size()==2 && (observed[0].uid!=0 || observed[0].stream_id!=1 ||
       observed[1].uid!=0 || observed[1].stream_id!=2))
      `uvm_error("TS_MULTI_DISPATCH","directed dispatch context mismatch")
    if(observed.size()==2)
      `uvm_info("TS_MULTI_DISPATCH","PASS same task preserved; contexts=(0,1),(0,2)",UVM_LOW)
    repeat(3) @(posedge vif.clk); phase.drop_objection(this);
  endtask
endclass

class ts_random_dispatch_context_test extends ts_dispatch_test_base;
  `uvm_component_utils(ts_random_dispatch_context_test)
  function new(string name,uvm_component parent); super.new(name,parent); endfunction
  task main_phase(uvm_phase phase);
    ts_dispatch_sequence seq;
    bit [15:0] generated_uid[$]; bit [3:0] generated_sid[$];
    phase.raise_objection(this); wait(vif.reset_n);
    repeat(8) begin
      seq=make_dispatch("random_dispatch",1); seq.start(agent.sqr);
      generated_uid.push_back(seq.dispatched_uid);
      generated_sid.push_back(seq.dispatched_stream_id);
    end
    wait_for_completions(8);
    if(observed.size()!=8) `uvm_error("TS_RANDOM_DISPATCH",$sformatf("observed=%0d expected=8",observed.size()))
    foreach(observed[i]) begin
      check_task_fields(observed[i],i);
      if(i<generated_uid.size() && (observed[i].uid!=generated_uid[i] || observed[i].stream_id!=generated_sid[i]))
        `uvm_error("TS_RANDOM_DISPATCH",$sformatf("context mismatch at dispatch %0d",i))
    end
    if(observed.size()==8)
      `uvm_info("TS_RANDOM_DISPATCH","PASS randomized uid/stream_id only; task fields preserved",UVM_LOW)
    repeat(3) @(posedge vif.clk); phase.drop_objection(this);
  endtask
endclass
