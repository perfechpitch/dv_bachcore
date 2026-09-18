class ts_stimulus_replay_test extends uvm_test;
  `uvm_component_utils(ts_stimulus_replay_test)
  ts2rvcore_agent agent;
  ts_cfg cfg;
  virtual ts_if vif;
  uvm_analysis_imp_ts_mon #(ts_item,ts_stimulus_replay_test) mon_imp;
  ts_item expected[$];
  int observed;

  function new(string name,uvm_component parent);
    super.new(name,parent);
    mon_imp=new("mon_imp",this);
  endfunction

  function void parse_expected(string file);
    int fd,rc;
    string line,u,m;
    ts_item t;
    bit [15:0] uid;
    bit [5:0] tid;
    bit [7:0] pid;
    bit [3:0] sid;
    bit [31:0] pc;
    bit [1:0] vcid;
    fd=$fopen(file,"r");
    if(!fd) `uvm_fatal("TS_REPLAY",$sformatf("cannot open %s",file))
    while($fgets(line,fd)) begin
      rc=$sscanf(line,"%h %h %h %h %s %s %h %h",uid,tid,sid,pc,u,m,pid,vcid);
      if(rc==0) continue;
      if(rc!=8) `uvm_fatal("TS_REPLAY","bad sequence line")
      t=ts_item::type_id::create("expected_item");
      t.uid=uid; t.tid=tid; t.stream_id=sid; t.pc=pc; t.pid=pid; t.vcid=vcid;
      if(u=="DTE") t.execute_unit=TS_DTE;
      else if(u=="MU") t.execute_unit=TS_MU;
      else if(u=="VU") t.execute_unit=TS_VU;
      else `uvm_fatal("TS_REPLAY","invalid execute_unit")
      t.execution_mode=(m=="RVCORE_DSA")?TS_RVCORE_DSA:TS_RVCORE_ONLY;
      expected.push_back(t);
    end
    $fclose(fd);
    if(expected.size()==0) `uvm_fatal("TS_REPLAY","empty sequence file")
  endfunction

  function void build_phase(uvm_phase phase);
    string f;
    super.build_phase(phase);
    if(!uvm_config_db#(virtual ts_if)::get(this,"","ts_vif",vif))
      `uvm_fatal("TS_REPLAY","missing vif")
    if(!$value$plusargs("TS_SEQ_FILE=%s",f))
      `uvm_fatal("TS_REPLAY","TS_SEQ_FILE missing")
    parse_expected(f);
    cfg=ts_cfg::type_id::create("cfg"); cfg.vif=vif; cfg.sequence_file=f;
    uvm_config_db#(ts_cfg)::set(this,"agent","cfg",cfg);
    agent=ts2rvcore_agent::type_id::create("agent",this);
  endfunction

  function void connect_phase(uvm_phase phase);
    agent.mon.ap.connect(mon_imp);
  endfunction

  function void write_ts_mon(ts_item t);
    ts_item e;
    if(observed>=expected.size()) begin
      `uvm_error("TS_REPLAY",$sformatf("unexpected task %s",t.sprint()))
      observed++;
      return;
    end
    e=expected[observed];
    if(t.execute_unit!=e.execute_unit || t.uid!=e.uid || t.tid!=e.tid ||
       t.stream_id!=e.stream_id || t.pc!=e.pc ||
       t.pid!=e.pid || t.vcid!=e.vcid)
      `uvm_error("TS_REPLAY",$sformatf("task[%0d] mismatch\nexpected=%s\nactual=%s",
        observed,e.sprint(),t.sprint()))
    observed++;
  endfunction

  task main_phase(uvm_phase phase);
    ts_sequence seq;
    int timeout;
    phase.raise_objection(this);
    wait(vif.reset_n);
    seq=ts_sequence::type_id::create("seq"); seq.cfg=cfg; seq.start(agent.sqr);
    timeout=0;
    while(agent.drv.completion_count<expected.size() && timeout<2000) begin
      @(posedge vif.clk); timeout++;
    end
    if(observed!=expected.size())
      `uvm_error("TS_REPLAY",$sformatf("observed=%0d expected=%0d",observed,expected.size()))
    if(agent.drv.completion_count!=expected.size())
      `uvm_error("TS_REPLAY","task completion timeout")
    if(observed==expected.size() && agent.drv.completion_count==expected.size())
      `uvm_info("TS_REPLAY",$sformatf("PASS tasks=%0d",observed),UVM_LOW)
    repeat(3) @(posedge vif.clk);
    phase.drop_objection(this);
  endtask
endclass
