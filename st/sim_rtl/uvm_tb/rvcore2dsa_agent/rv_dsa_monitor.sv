class rv_dsa_monitor extends uvm_monitor;
  `uvm_component_utils(rv_dsa_monitor)
  rv_dsa_cfg cfg; virtual rv_dsa_if vif;
  uvm_analysis_port #(rv_dsa_item) ap;
  rv_dsa_item pending_read_queue[$];
  int log_fd; int unsigned seq_idx, cycle_count;
  int unsigned handshake_cycles[$];
  function new(string name,uvm_component parent); super.new(name,parent); ap=new("ap",this); endfunction
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(rv_dsa_cfg)::get(this,"","cfg",cfg)) `uvm_fatal("RV_DSA_MON","missing cfg")
    vif=cfg.vif; log_fd=$fopen("log/rv_dsa_monitor.log","w"); seq_idx=0; cycle_count=0;
  endfunction
  function void log_item(rv_dsa_item t);
    if(t.rw) $fwrite(log_fd,"W %08h %08h %0d %02h %04h %02h %0d\n",t.addr,t.wdata,t.stream_id,t.task_id,t.user_id,t.path_id,t.vc_id);
    else $fwrite(log_fd,"R %08h %08h %0d %02h %04h %02h %0d %08h\n",t.addr,t.wdata,t.stream_id,t.task_id,t.user_id,t.path_id,t.vc_id,t.rdata);
  endfunction
  task main_phase(uvm_phase phase);
    rv_dsa_item t;
    forever begin
      @(vif.mon_cb);
      cycle_count++;
      if(!vif.mon_cb.reset_n) begin pending_read_queue.delete(); handshake_cycles.delete(); seq_idx=0; end
      else begin
        if(vif.mon_cb.req && vif.mon_cb.ready) begin
          handshake_cycles.push_back(cycle_count);
          t=rv_dsa_item::type_id::create("mon_item");
          t.rw=vif.mon_cb.rw; t.addr=vif.mon_cb.addr0; t.wdata=vif.mon_cb.wdata0;
          t.stream_id=vif.mon_cb.stream_id; t.task_id=vif.mon_cb.task_id;
          t.user_id=vif.mon_cb.user_id; t.path_id=vif.mon_cb.path_id; t.vc_id=vif.mon_cb.vc_id;
          t.seq_idx=seq_idx++;
          if(t.rw) begin log_item(t); ap.write(t); end else pending_read_queue.push_back(t);
        end
        if(vif.mon_cb.resp) begin
          if(!pending_read_queue.size()) `uvm_error("RV_DSA_MON","response without pending read")
          else begin
            t=pending_read_queue.pop_front(); t.rdata=vif.mon_cb.rdata; log_item(t); ap.write(t);
          end
        end
      end
    end
  endtask
endclass
