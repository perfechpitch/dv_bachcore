class ts_driver extends uvm_driver #(ts_item);
  `uvm_component_utils(ts_driver)
  ts_cfg cfg; virtual ts_if vif; int unsigned completion_count,rvcore_done_first_count,dsa_done_first_count;
  function new(string name,uvm_component parent); super.new(name,parent); endfunction
  function void build_phase(uvm_phase phase);
    super.build_phase(phase); if(!uvm_config_db#(ts_cfg)::get(this,"","cfg",cfg)) `uvm_fatal("TS_DRV","missing cfg")
    vif=cfg.vif;
  endfunction
  task clear_valid();
    vif.drv_cb.ts2dtecore_task_valid<=0; vif.drv_cb.ts2mucore_task_valid<=0; vif.drv_cb.ts2vucore_task_valid<=0;
  endtask
  task reset_phase(uvm_phase phase);
    clear_valid(); vif.drv_cb.ts2dtecore_ready<=1; vif.drv_cb.ts2mucore_ready<=1; vif.drv_cb.ts2vucore_ready<=1;
    vif.drv_cb.ts2dte_ready<=1; vif.drv_cb.ts2mu_ready<=1; vif.drv_cb.ts2vu_ready<=1;
  endtask
  task drive_request(ts_item t);
    clear_valid();
    case(t.execute_unit)
      TS_DTE: begin
        vif.drv_cb.ts2dtecore_task_uid<=t.uid; vif.drv_cb.ts2dtecore_task_tid<=t.tid; vif.drv_cb.ts2dtecore_task_streamid<=t.stream_id;
        vif.drv_cb.ts2dtecore_task_pc<=t.pc; vif.drv_cb.ts2dtecore_task_pid<=t.pid; vif.drv_cb.ts2dtecore_task_vcid<=t.vcid;
        vif.drv_cb.ts2dtecore_task_valid<=1; do @(vif.drv_cb); while(!vif.drv_cb.dtecore2ts_task_ready);
      end
      TS_MU: begin
        vif.drv_cb.ts2mucore_task_uid<=t.uid; vif.drv_cb.ts2mucore_task_tid<=t.tid; vif.drv_cb.ts2mucore_task_streamid<=t.stream_id;
        vif.drv_cb.ts2mucore_task_pc<=t.pc; vif.drv_cb.ts2mucore_task_valid<=1; do @(vif.drv_cb); while(!vif.drv_cb.mucore2ts_task_ready);
      end
      TS_VU: begin
        vif.drv_cb.ts2vucore_task_uid<=t.uid; vif.drv_cb.ts2vucore_task_tid<=t.tid; vif.drv_cb.ts2vucore_task_streamid<=t.stream_id;
        vif.drv_cb.ts2vucore_task_pc<=t.pc; vif.drv_cb.ts2vucore_task_valid<=1; do @(vif.drv_cb); while(!vif.drv_cb.vucore2ts_task_ready);
      end
    endcase
    clear_valid();
  endtask
  task wait_completion(ts_item t);
    bit r=0,d=0,first=0;
    while(!(r && (t.execution_mode==TS_RVCORE_ONLY || d))) begin
      @(vif.drv_cb);
      case(t.execute_unit)
        TS_DTE: begin if(vif.drv_cb.dtecore2ts_done_valid) r=1; if(vif.drv_cb.dte2ts_done_valid) d=1; end
        TS_MU: begin if(vif.drv_cb.mucore2ts_done_valid) r=1; if(vif.drv_cb.mu2ts_done_valid) d=1; end
        TS_VU: begin if(vif.drv_cb.vucore2ts_done_valid) r=1; if(vif.drv_cb.vu2ts_done_valid) d=1; end
      endcase
      if(!first&&(r||d)) begin first=1; if(r) rvcore_done_first_count++; else dsa_done_first_count++; end
    end
    completion_count++;
  endtask
  task main_phase(uvm_phase phase);
    ts_item t; wait(vif.reset_n);
    forever begin seq_item_port.get_next_item(t); drive_request(t); wait_completion(t); seq_item_port.item_done(); end
  endtask
endclass
