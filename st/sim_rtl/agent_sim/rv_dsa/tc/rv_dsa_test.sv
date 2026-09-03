class rv_dsa_test extends uvm_test;
  `uvm_component_utils(rv_dsa_test)
  rv_dsa_agent agent; rv_dsa_cfg cfg; virtual rv_dsa_if vif;
  uvm_analysis_imp_rv_dsa_mon #(rv_dsa_item,rv_dsa_test) mon_imp;
  rv_dsa_item expected[$]; bit matched[]; int observed;
  int case_id, expected_count;
  function new(string name,uvm_component parent); super.new(name,parent); mon_imp=new("mon_imp",this); endfunction
  function void parse_expected(string file);
    int fd,rc,idx; string line,op; rv_dsa_item t;
    bit [31:0] a,w; bit [3:0] s; bit [5:0] ti,p; bit [15:0] u; bit [1:0] v;
    fd=$fopen(file,"r"); if(!fd) `uvm_fatal("RV_DSA_TEST",$sformatf("cannot open %s",file))
    idx=0;
    while($fgets(line,fd)) begin
      rc=$sscanf(line,"%s %h %h %h %h %h %h %h",op,a,w,s,ti,u,p,v);
      if(rc==0) continue; if(rc!=8) `uvm_fatal("RV_DSA_TEST","bad expected log")
      t=new(); t.rw=(op=="W"); t.addr=a; t.wdata=w; t.stream_id=s; t.task_id=ti;
      t.user_id=u; t.path_id=p; t.vc_id=v; t.seq_idx=idx++; expected.push_back(t);
    end
    $fclose(fd); expected_count=expected.size(); matched=new[expected_count];
  endfunction
  function void build_phase(uvm_phase phase);
    string req_file; int gap_mode;
    super.build_phase(phase);
    if(!uvm_config_db#(virtual rv_dsa_if)::get(this,"","vif",vif)) `uvm_fatal("RV_DSA_TEST","missing vif")
    if(!$value$plusargs("CASE_ID=%d",case_id)) case_id=0;
    if(!$value$plusargs("REQ_LOG_FILE=%s",req_file)) `uvm_fatal("RV_DSA_TEST","REQ_LOG_FILE missing")
    cfg=rv_dsa_cfg::type_id::create("cfg"); cfg.vif=vif; cfg.req_log_file=req_file;
    if(case_id==6) cfg.is_active=UVM_PASSIVE;
    if($value$plusargs("REQ_GAP=%d",cfg.req_gap)) cfg.req_gap_mode=REQ_GAP_FIXED;
    if($value$plusargs("REQ_GAP_MIN=%d",cfg.req_gap_min)) begin
      void'($value$plusargs("REQ_GAP_MAX=%d",cfg.req_gap_max)); cfg.req_gap_mode=REQ_GAP_RANDOM;
    end
    parse_expected(req_file);
    uvm_config_db#(rv_dsa_cfg)::set(this,"agent","cfg",cfg);
    agent=rv_dsa_agent::type_id::create("agent",this);
  endfunction
  function void connect_phase(uvm_phase phase); agent.mon.ap.connect(mon_imp); endfunction
  function void write_rv_dsa_mon(rv_dsa_item t);
    int hit=-1;
    for(int i=0;i<expected.size();i++)
      if(!matched[i] && t.rw==expected[i].rw && t.addr==expected[i].addr &&
         t.wdata==expected[i].wdata && t.stream_id==expected[i].stream_id &&
         t.task_id==expected[i].task_id && t.user_id==expected[i].user_id &&
         t.path_id==expected[i].path_id && t.vc_id==expected[i].vc_id) begin hit=i; break; end
    if(hit<0) `uvm_error("RV_DSA_TEST",$sformatf("unexpected transaction %s",t.sprint()))
    else begin
      matched[hit]=1;
      if(!t.rw && t.rdata!=(t.addr^32'hd5a00000)) `uvm_error("RV_DSA_TEST","bad read data")
    end
    observed++;
  endfunction
  task passive_drive();
    rv_dsa_item t;
    foreach(expected[i]) begin
      t=expected[i]; @(negedge vif.clk);
      vif.req<=1; vif.rw<=t.rw; vif.addr0<=t.addr; vif.wdata0<=t.wdata;
      vif.stream_id<=t.stream_id; vif.task_id<=t.task_id; vif.user_id<=t.user_id;
      vif.path_id<=t.path_id; vif.vc_id<=t.vc_id;
      do @(posedge vif.clk); while(!vif.ready);
      @(negedge vif.clk); vif.req<=0;
    end
  endtask
  task main_phase(uvm_phase phase);
    rv_dsa_sequence seq; int timeout;
    phase.raise_objection(this);
    wait(vif.reset_n);
    if(cfg.is_active==UVM_ACTIVE) begin seq=new(); seq.cfg=cfg; seq.start(agent.sqr); end
    else passive_drive();
    timeout=0; while(observed<expected_count && timeout<2000) begin @(posedge vif.clk); timeout++; end
    if(observed!=expected_count) `uvm_error("RV_DSA_TEST",$sformatf("observed %0d expected %0d",observed,expected_count))
    if(cfg.is_active==UVM_ACTIVE) begin
      if(agent.drv.max_outstanding_seen>8) `uvm_error("RV_DSA_TEST","outstanding > 8")
      if(case_id==3 && agent.drv.max_outstanding_seen!=8) `uvm_error("RV_DSA_TEST","did not reach 8 outstanding")
      if(case_id==4 && agent.drv.write_bypass_count==0) `uvm_error("RV_DSA_TEST","write bypass not observed")
      if(case_id==5) begin
        for(int i=1;i<agent.mon.handshake_cycles.size();i++) begin
          int unsigned idle_cycles;
          idle_cycles=agent.mon.handshake_cycles[i]-agent.mon.handshake_cycles[i-1]-1;
          if(cfg.req_gap_mode==REQ_GAP_FIXED && idle_cycles<cfg.req_gap)
            `uvm_error("RV_DSA_TEST",$sformatf("fixed gap too short: %0d",idle_cycles))
          if(cfg.req_gap_mode==REQ_GAP_RANDOM &&
             (idle_cycles<cfg.req_gap_min || idle_cycles>cfg.req_gap_max+1))
            `uvm_error("RV_DSA_TEST",$sformatf("random gap out of range: %0d",idle_cycles))
        end
      end
    end
    if(observed==expected_count)
      `uvm_info("RV_DSA_TEST",$sformatf("CASE%0d PASS observed=%0d",case_id,observed),UVM_LOW)
    repeat(5) @(posedge vif.clk); phase.drop_objection(this);
  endtask
endclass
