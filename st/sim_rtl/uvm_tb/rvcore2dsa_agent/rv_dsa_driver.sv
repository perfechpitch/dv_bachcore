class rv_dsa_driver extends uvm_driver #(rv_dsa_item);
  `uvm_component_utils(rv_dsa_driver)
  rv_dsa_cfg cfg; virtual rv_dsa_if vif;
  rv_dsa_item pending[$], read_outstanding_queue[$];
  int unsigned max_outstanding_seen, write_bypass_count;
  function new(string name,uvm_component parent); super.new(name,parent); endfunction
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(rv_dsa_cfg)::get(this,"","cfg",cfg)) `uvm_fatal("RV_DSA_DRV","missing cfg")
    vif=cfg.vif;
  endfunction
  task reset_phase(uvm_phase phase);
    vif.drv_cb.req<=0; vif.drv_cb.rw<=0; vif.drv_cb.addr0<=0; vif.drv_cb.wdata0<=0;
    vif.drv_cb.stream_id<=0; vif.drv_cb.task_id<=0; vif.drv_cb.user_id<=0;
    vif.drv_cb.path_id<=0; vif.drv_cb.vc_id<=0;
  endtask
  function int select_pending();
    if(!pending.size()) return -1;
    if(!(pending[0].rw==0 && read_outstanding_queue.size()>=8)) return 0;
    for(int i=1;i<pending.size();i++) if(pending[i].rw) return i;
    return -1;
  endfunction
  function int unsigned next_gap();
    if(cfg.req_gap_mode==REQ_GAP_RANDOM) return $urandom_range(cfg.req_gap_max,cfg.req_gap_min);
    return cfg.req_gap;
  endfunction
  task collect_items();
    rv_dsa_item got, copy;
    forever begin
      seq_item_port.get_next_item(got);
      $cast(copy,got.clone()); pending.push_back(copy);
      seq_item_port.item_done();
    end
  endtask
  task issue_requests();
    int sel; int unsigned gap_left; rv_dsa_item cur;
    gap_left=0; vif.drv_cb.req<=0;
    forever begin
      @(vif.drv_cb);
      if(!vif.drv_cb.reset_n) begin vif.drv_cb.req<=0; gap_left=0; cur=null; end
      else if(cur!=null) begin
        if(vif.drv_cb.ready) begin
          if(!cur.rw) begin
            read_outstanding_queue.push_back(cur);
            if(read_outstanding_queue.size()>max_outstanding_seen) max_outstanding_seen=read_outstanding_queue.size();
            if(read_outstanding_queue.size()>8) `uvm_error("RV_DSA_DRV","read outstanding exceeded 8")
          end
          pending.delete(sel); vif.drv_cb.req<=0; cur=null; gap_left=next_gap();
        end
      end else if(gap_left) gap_left--;
      else begin
        sel=select_pending();
        if(sel>=0) begin
          if(sel>0) write_bypass_count++;
          cur=pending[sel];
          vif.drv_cb.req<=1; vif.drv_cb.rw<=cur.rw; vif.drv_cb.addr0<=cur.addr;
          vif.drv_cb.wdata0<=cur.wdata; vif.drv_cb.stream_id<=cur.stream_id;
          vif.drv_cb.task_id<=cur.task_id; vif.drv_cb.user_id<=cur.user_id;
          vif.drv_cb.path_id<=cur.path_id; vif.drv_cb.vc_id<=cur.vc_id;
        end
      end
    end
  endtask
  task handle_responses();
    forever begin
      @(vif.drv_cb);
      if(vif.drv_cb.reset_n && vif.drv_cb.resp) begin
        if(!read_outstanding_queue.size()) `uvm_error("RV_DSA_DRV","response without outstanding read")
        else begin read_outstanding_queue[0].rdata=vif.drv_cb.rdata; read_outstanding_queue.pop_front(); end
      end
    end
  endtask
  task main_phase(uvm_phase phase);
    fork collect_items(); issue_requests(); handle_responses(); join
  endtask
endclass
