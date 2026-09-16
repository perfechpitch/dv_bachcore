class ts_monitor extends uvm_monitor;
  `uvm_component_utils(ts_monitor)
  ts_cfg cfg; virtual ts_if vif; uvm_analysis_port #(ts_item) ap; int log_fd;
  function new(string n,uvm_component p); super.new(n,p); ap=new("ap",this); endfunction
  function void build_phase(uvm_phase phase);
    super.build_phase(phase); if(!uvm_config_db#(ts_cfg)::get(this,"","cfg",cfg)) `uvm_fatal("TS_MON","missing cfg")
    vif=cfg.vif; log_fd=$fopen("log/ts_monitor.log","w");
  endfunction
  task main_phase(uvm_phase phase);
    ts_item t;
    forever begin @(vif.mon_cb); if(vif.mon_cb.reset_n) begin
      if(vif.mon_cb.ts2dtecore_task_valid&&vif.mon_cb.dtecore2ts_task_ready) begin
        t=ts_item::type_id::create("dte"); t.execute_unit=TS_DTE; t.uid=vif.mon_cb.ts2dtecore_task_uid; t.tid=vif.mon_cb.ts2dtecore_task_tid;
        t.stream_id=vif.mon_cb.ts2dtecore_task_streamid; t.pc=vif.mon_cb.ts2dtecore_task_pc; t.pid=vif.mon_cb.ts2dtecore_task_pid; t.vcid=vif.mon_cb.ts2dtecore_task_vcid;
        ap.write(t); $fwrite(log_fd,"DTE %04h %02h %x %08h %02h %x\n",t.uid,t.tid,t.stream_id,t.pc,t.pid,t.vcid);
      end
      if(vif.mon_cb.ts2mucore_task_valid&&vif.mon_cb.mucore2ts_task_ready) begin
        t=ts_item::type_id::create("mu"); t.execute_unit=TS_MU; t.uid=vif.mon_cb.ts2mucore_task_uid; t.tid=vif.mon_cb.ts2mucore_task_tid;
        t.stream_id=vif.mon_cb.ts2mucore_task_streamid; t.pc=vif.mon_cb.ts2mucore_task_pc; ap.write(t); $fwrite(log_fd,"MU %04h %02h %x %08h\n",t.uid,t.tid,t.stream_id,t.pc);
      end
      if(vif.mon_cb.ts2vucore_task_valid&&vif.mon_cb.vucore2ts_task_ready) begin
        t=ts_item::type_id::create("vu"); t.execute_unit=TS_VU; t.uid=vif.mon_cb.ts2vucore_task_uid; t.tid=vif.mon_cb.ts2vucore_task_tid;
        t.stream_id=vif.mon_cb.ts2vucore_task_streamid; t.pc=vif.mon_cb.ts2vucore_task_pc; ap.write(t); $fwrite(log_fd,"VU %04h %02h %x %08h\n",t.uid,t.tid,t.stream_id,t.pc);
      end
    end end
  endtask
endclass
