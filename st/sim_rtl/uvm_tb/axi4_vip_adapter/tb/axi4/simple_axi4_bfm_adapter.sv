package simple_axi4_bfm_adapter_pkg;
  timeunit 1ns;
  timeprecision 1ps;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import axi4_vip_adapter_pkg::*;

  // The same descriptor is shared by channel slots and response queues. AXI4
  // has no WID, so the W queue follows AW *issue* order, not AWREADY timing.
  class axi4_pending_request;
    axi4_burst_request req;
    axi4_burst_response rsp;
    axi4_completion completion;
    bit write_access, address_done, w_done, response_timer_started;
    int unsigned w_beat, r_beat;
    longint unsigned last_response_cycle;
  endclass

  class simple_axi4_bfm_adapter extends axi4_vip_adapter_base;
    `uvm_object_utils(simple_axi4_bfm_adapter)
    axi4_vif_t vif;
    bit initialized;
    local semaphore init_lock;
    local process engine_process;
    local static longint unsigned next_owner = 1;
    local longint unsigned owner, next_serial = 1, cycle;
    local axi4_pending_request queued_reads[$], queued_writes[$], w_order[$];
    local axi4_pending_request live_reads[$], live_writes[$], all_requests[$];
    local axi4_pending_request aw_slot, ar_slot, w_slot;
    local longint unsigned aw_started, ar_started, w_started;
    local int unsigned read_cap = AXI_MAX_OUTSTANDING_READS;
    local int unsigned write_cap = AXI_MAX_OUTSTANDING_WRITES;
    local int unsigned total_cap = AXI_MAX_OUTSTANDING_TOTAL;
    local int unsigned read_timeout = AXI_READ_TIMEOUT_CYCLES;
    local int unsigned write_timeout = AXI_WRITE_TIMEOUT_CYCLES;
    local int unsigned ready_timeout = AXI_READY_TIMEOUT_CYCLES;
    local bit poisoned, prefer_write;

    function new(string name = "simple_axi4_bfm_adapter");
      super.new(name);
      init_lock = new(1);
      owner = next_owner++;
    endfunction

    local function void bind_interface();
      if (!uvm_config_db#(axi4_vif_t)::get(null, "*", "axi_vif", vif))
        `uvm_fatal("AXI_INIT", "Missing config_db entry: axi_vif")
      if (axi4_vip_cfg_pkg::VIP_SUPPORT_FIXED_BURST)
        `uvm_warning("AXI_CAPABILITY", "support.fixed_burst is legacy policy only; actual FIXED requests are rejected; use INCR")
    endfunction

    local function void idle_outputs();
      vif.awid <= AXI_DEFAULT_ID; vif.awaddr <= 0; vif.awlen <= 0;
      vif.awsize <= $clog2(AXI_STRB_WIDTH); vif.awburst <= 1;
      vif.awlock <= AXI_DEFAULT_LOCK; vif.awcache <= AXI_DEFAULT_CACHE;
      vif.awprot <= AXI_DEFAULT_PROT; vif.awqos <= AXI_DEFAULT_QOS;
      vif.awregion <= AXI_DEFAULT_REGION; vif.awuser <= AXI_DEFAULT_AWUSER;
      vif.awvalid <= 0;
      vif.wdata <= 0; vif.wstrb <= 0; vif.wlast <= 0; vif.wvalid <= 0;
      vif.wuser <= AXI_DEFAULT_WUSER; vif.bready <= 0;
      vif.arid <= AXI_DEFAULT_ID; vif.araddr <= 0; vif.arlen <= 0;
      vif.arsize <= $clog2(AXI_STRB_WIDTH); vif.arburst <= 1;
      vif.arlock <= AXI_DEFAULT_LOCK; vif.arcache <= AXI_DEFAULT_CACHE;
      vif.arprot <= AXI_DEFAULT_PROT; vif.arqos <= AXI_DEFAULT_QOS;
      vif.arregion <= AXI_DEFAULT_REGION; vif.aruser <= AXI_DEFAULT_ARUSER;
      vif.arvalid <= 0; vif.rready <= 0;
    endfunction

    // UVM sequencer owns this process; sequence.kill cannot terminate it.
    virtual task service();
      if (initialized)
        `uvm_fatal("AXI_SERVICE", "Service already started; initialize through its registered owner")
      bind_interface();
      idle_outputs();
      initialized = 1;
      engine_loop();
    endtask

    virtual task init();
      if (initialized) begin
        check_engine();
        wait (vif.aresetn === 1'b1);
        return;
      end
      if (service_owned) begin
        wait (initialized && engine_process != null);
      end else begin
        // Standalone callers must initialize from their long-lived test process.
        init_lock.get(1);
        if (!initialized) begin
          bind_interface(); idle_outputs(); initialized = 1;
          fork engine_loop(); join_none
          wait (engine_process != null);
        end
        init_lock.put(1);
      end
      wait (vif.aresetn === 1'b1);
      check_engine();
    endtask

    local function void check_engine();
      if (engine_process != null &&
          (engine_process.status() == process::KILLED || engine_process.status() == process::FINISHED)) begin
        fail_all(AXI_COMPLETION_PROTOCOL_ERROR, "AXI engine owner was terminated");
        `uvm_fatal("AXI_SERVICE", "AXI engine terminated; initialize from sequencer service or a long-lived standalone owner")
      end
    endfunction

    virtual function int unsigned get_outstanding_reads(); return live_reads.size(); endfunction
    virtual function int unsigned get_outstanding_writes(); return live_writes.size(); endfunction
    virtual function int unsigned get_outstanding_total(); return live_reads.size() + live_writes.size(); endfunction
    virtual function int unsigned get_queued_reads(); return queued_reads.size() + (ar_slot != null); endfunction
    virtual function int unsigned get_queued_writes(); return queued_writes.size() + (aw_slot != null); endfunction
    function bit is_poisoned(); return poisoned; endfunction

    local function bit completely_idle();
      return !poisoned && all_requests.size() == 0 &&
             aw_slot == null && ar_slot == null && w_slot == null;
    endfunction

    virtual function void configure_outstanding(input int unsigned read_limit,
      input int unsigned write_limit, input int unsigned total_limit);
      if (!completely_idle() || read_limit == 0 || write_limit == 0 || total_limit == 0 ||
          read_limit > 32'h7fffffff || write_limit > 32'h7fffffff || total_limit > 32'h7fffffff) begin
        `uvm_error("AXI_BFM_CONFIG", "Limits must be positive signed integers and may change only while completely idle")
        return;
      end
      read_cap = read_limit; write_cap = write_limit; total_cap = total_limit;
    endfunction

    function void configure_timeouts(input int unsigned read_cycles,
      input int unsigned write_cycles, input int unsigned ready_cycles);
      if (!completely_idle()) begin
        `uvm_error("AXI_BFM_CONFIG", "Timeouts may change only while completely idle")
        return;
      end
      read_timeout = read_cycles; write_timeout = write_cycles; ready_timeout = ready_cycles;
    endfunction

    local task submit(input axi4_burst_request req, input bit is_write,
                      output axi4_completion handle);
      axi4_pending_request item;
      string reason;
      // Explicit init/legacy APIs wait for startup reset; an already running
      // asynchronous service rejects submissions during a later reset.
      if (!initialized) init(); else check_engine();
      handle = new("completion");
      handle.serial = next_serial++; handle.owner_id = owner;
      handle.response = new("response");
      if (vif.aresetn !== 1'b1) begin
        handle.status = AXI_COMPLETION_RESET; handle.detail = "Submission during reset";
        handle.done = 1; return;
      end
      if (poisoned) begin
        handle.status = AXI_COMPLETION_REJECTED; handle.detail = "Reset required after AXI scheduler fault";
        handle.done = 1; return;
      end
      reason = req == null ? "Null transaction request" : req.validate(is_write);
      if (reason != "") begin
        handle.status = AXI_COMPLETION_REJECTED; handle.detail = reason;
        handle.done = 1;
        `uvm_error("AXI_ILLEGAL", reason)
        return;
      end
      item = new(); item.req = new("request_snapshot"); item.req.copy(req);
      item.rsp = handle.response; item.completion = handle; item.write_access = is_write;
      if (!is_write) begin
        item.rsp.rid = new[req.beat_count]; item.rsp.data = new[req.beat_count];
        item.rsp.rresp = new[req.beat_count]; item.rsp.rlast = new[req.beat_count];
        foreach (item.rsp.data[i]) begin
          item.rsp.rid[i] = 'x; item.rsp.data[i] = 'x;
          item.rsp.rresp[i] = 'x; item.rsp.rlast[i] = 'x;
        end
      end
      all_requests.push_back(item);
      if (is_write) queued_writes.push_back(item); else queued_reads.push_back(item);
    endtask

    virtual task submit_write(input axi4_burst_request req, output axi4_completion handle);
      submit(req, 1, handle);
    endtask
    virtual task submit_read(input axi4_burst_request req, output axi4_completion handle);
      submit(req, 0, handle);
    endtask
    virtual task wait_completion(input axi4_completion handle, output axi4_burst_response rsp);
      if (handle == null || handle.owner_id != owner) begin
        `uvm_fatal("AXI_COMPLETION", "Completion is null or belongs to a different adapter")
        return;
      end
      while (!handle.done) begin
        @(posedge vif.aclk or negedge vif.aresetn or posedge handle.done);
        check_engine();
      end
      rsp = handle.response;
    endtask

    local function void finish(input axi4_pending_request item);
      item.completion.status = AXI_COMPLETION_OK;
      item.completion.done = 1;
      foreach (all_requests[i]) if (all_requests[i] == item) begin
        all_requests.delete(i); break;
      end
    endfunction

    local function void fail_all(input axi_completion_status_e status, input string reason);
      foreach (all_requests[i]) if (!all_requests[i].completion.done) begin
        all_requests[i].completion.status = status;
        all_requests[i].completion.detail = reason;
        all_requests[i].completion.done = 1;
      end
      // Already-issued slots remain live until one handshake or reset. Removing
      // them now could repeat transfers or misrepresent physical outstanding.
      queued_reads.delete(); queued_writes.delete();
      poisoned = 1;
    endfunction

    local function void clear_epoch();
      foreach (all_requests[i]) if (!all_requests[i].completion.done) begin
        all_requests[i].completion.status = AXI_COMPLETION_RESET;
        all_requests[i].completion.detail = "Reset interrupted transaction";
        all_requests[i].completion.done = 1;
      end
      queued_reads.delete(); queued_writes.delete(); w_order.delete();
      live_reads.delete(); live_writes.delete(); all_requests.delete();
      aw_slot = null; ar_slot = null; w_slot = null;
      poisoned = 0; prefer_write = 0; cycle = 0;
      idle_outputs();
    endfunction

    local function int first_read(input logic [AXI_ID_WIDTH-1:0] id);
      if ($isunknown(id)) return -1;
      foreach (live_reads[i]) if (live_reads[i].req.id == id) return i;
      return -1;
    endfunction
    local function int first_write(input logic [AXI_ID_WIDTH-1:0] id);
      if ($isunknown(id)) return -1;
      foreach (live_writes[i]) if (live_writes[i].req.id == id) return i;
      return -1;
    endfunction

    local function void select_write();
      if (aw_slot == null && queued_writes.size() != 0 &&
          live_writes.size() < write_cap &&
          get_outstanding_total() + (ar_slot != null) < total_cap) begin
        aw_slot = queued_writes.pop_front(); aw_started = cycle;
        w_order.push_back(aw_slot); prefer_write = 0;
      end
    endfunction
    local function void select_read();
      if (ar_slot == null && queued_reads.size() != 0 &&
          live_reads.size() < read_cap &&
          get_outstanding_total() + (aw_slot != null) < total_cap) begin
        ar_slot = queued_reads.pop_front(); ar_started = cycle;
        prefer_write = 1;
      end
    endfunction

    local function void drive_channels();
      vif.awvalid <= (aw_slot != null);
      if (aw_slot != null) begin
        vif.awid <= aw_slot.req.id; vif.awaddr <= aw_slot.req.addr;
        vif.awlen <= aw_slot.req.beat_count - 1; vif.awsize <= aw_slot.req.size;
        vif.awburst <= aw_slot.req.burst; vif.awlock <= aw_slot.req.lock;
      end
      vif.arvalid <= (ar_slot != null);
      if (ar_slot != null) begin
        vif.arid <= ar_slot.req.id; vif.araddr <= ar_slot.req.addr;
        vif.arlen <= ar_slot.req.beat_count - 1; vif.arsize <= ar_slot.req.size;
        vif.arburst <= ar_slot.req.burst; vif.arlock <= ar_slot.req.lock;
      end
      vif.wvalid <= (w_slot != null);
      if (w_slot != null) begin
        vif.wdata <= w_slot.req.data[w_slot.w_beat];
        vif.wstrb <= w_slot.req.strb[w_slot.w_beat];
        vif.wlast <= (w_slot.w_beat == w_slot.req.beat_count - 1);
      end else vif.wlast <= 0;
      vif.bready <= !poisoned; vif.rready <= !poisoned;
    endfunction

    local function string check_timeouts();
      axi4_pending_request item;
      if (!AXI_ENABLE_TIMEOUT_CHECKS) return "";
      if (ready_timeout != 0) begin
        if (aw_slot != null && cycle - aw_started >= ready_timeout) return "AWREADY timeout";
        if (w_slot != null && cycle - w_started >= ready_timeout) return "WREADY timeout";
        if (ar_slot != null && cycle - ar_started >= ready_timeout) return "ARREADY timeout";
      end
      foreach (live_writes[i]) begin
        item = live_writes[i];
        if (first_write(item.req.id) != i || !item.w_done) continue;
        if (!item.response_timer_started) begin
          item.response_timer_started = 1; item.last_response_cycle = cycle;
        end else if (write_timeout != 0 && cycle - item.last_response_cycle >= write_timeout)
          return $sformatf("B response timeout BID=%0h serial=%0d", item.req.id, item.completion.serial);
      end
      foreach (live_reads[i]) begin
        item = live_reads[i];
        if (first_read(item.req.id) != i) continue;
        if (!item.response_timer_started) begin
          item.response_timer_started = 1; item.last_response_cycle = cycle;
        end else if (read_timeout != 0 && cycle - item.last_response_cycle >= read_timeout)
          return $sformatf("R response timeout RID=%0h serial=%0d", item.req.id, item.completion.serial);
      end
      return "";
    endfunction

    local task engine_loop();
      string fault, timeout_reason;
      int index;
      bit aw_fire, w_fire, ar_fire, b_fire, r_fire, was_poisoned;
      axi4_pending_request item;
      engine_process = process::self();
      forever begin
        @(posedge vif.aclk or negedge vif.aresetn);
        if (vif.aresetn !== 1'b1) begin
          clear_epoch();
          continue;
        end
        cycle++;
        aw_fire = vif.awvalid === 1'b1 && vif.awready === 1'b1;
        w_fire = vif.wvalid === 1'b1 && vif.wready === 1'b1;
        ar_fire = vif.arvalid === 1'b1 && vif.arready === 1'b1;
        b_fire = vif.bvalid === 1'b1 && vif.bready === 1'b1;
        r_fire = vif.rvalid === 1'b1 && vif.rready === 1'b1;
        was_poisoned = poisoned; fault = "";

        // Responses use pre-edge state: same-edge AW/WLAST cannot legitimize
        // an early B, and a new AR cannot legitimize an unsolicited R.
        if (!was_poisoned && b_fire) begin
          index = first_write(vif.bid);
          if (index < 0) fault = $sformatf("Unexpected/unknown BID=%0h", vif.bid);
          else if (!live_writes[index].w_done)
            fault = $sformatf("B early: BID=%0h before final W handshake", vif.bid);
          else begin
            item = live_writes[index]; item.rsp.bid = vif.bid; item.rsp.bresp = vif.bresp;
            item.rsp.completed_beats = item.req.beat_count;
            if (AXI_ENABLE_RESPONSE_CHECKS && item.req.check_response && vif.bresp !== AXI_RESP_OKAY)
              `uvm_error("AXI_RESPONSE", $sformatf("BRESP error BID=%0h: %s", vif.bid, axi_resp_name(vif.bresp)))
            live_writes.delete(index); finish(item);
          end
        end
        if (!was_poisoned && r_fire) begin
          index = first_read(vif.rid);
          if (index < 0) begin
            if (fault == "") fault = $sformatf("Unexpected/unknown RID=%0h", vif.rid);
          end else begin
            item = live_reads[index];
            item.rsp.rid[item.r_beat] = vif.rid; item.rsp.data[item.r_beat] = vif.rdata;
            item.rsp.rresp[item.r_beat] = vif.rresp; item.rsp.rlast[item.r_beat] = vif.rlast;
            item.rsp.completed_beats++; item.last_response_cycle = cycle;
            if (vif.rlast !== (item.r_beat == item.req.beat_count - 1)) begin
              if (fault == "") fault = $sformatf("RLAST mismatch RID=%0h beat=%0d of %0d", vif.rid, item.r_beat, item.req.beat_count);
            end else begin
              if (AXI_ENABLE_RESPONSE_CHECKS && item.req.check_response && vif.rresp !== AXI_RESP_OKAY)
                `uvm_error("AXI_RESPONSE", $sformatf("RRESP error RID=%0h beat=%0d: %s", vif.rid, item.r_beat, axi_resp_name(vif.rresp)))
              item.r_beat++;
              if (vif.rlast) begin live_reads.delete(index); finish(item); end
            end
          end
        end

        // Count all handshakes even on the edge that discovers a fault. In
        // quarantine, each already asserted VALID is withdrawn only after its
        // one handshake; no next W beat or new address is launched.
        if (aw_fire) begin
          aw_slot.address_done = 1; live_writes.push_back(aw_slot); aw_slot = null;
        end
        if (ar_fire) begin
          ar_slot.address_done = 1; live_reads.push_back(ar_slot); ar_slot = null;
        end
        if (w_fire) begin
          w_slot.w_beat++;
          if (w_slot.w_beat == w_slot.req.beat_count) begin
            w_slot.w_done = 1; w_slot = null;
          end else if (was_poisoned || fault != "") w_slot = null;
          else w_started = cycle;
        end
        if (!was_poisoned) begin
          if (fault != "") begin
            fail_all(AXI_COMPLETION_PROTOCOL_ERROR, fault);
            `uvm_error("AXI_BFM_PROTOCOL", {fault, "; scheduler quarantined until reset"})
          end else begin
            timeout_reason = check_timeouts();
            if (timeout_reason != "") begin
              fail_all(AXI_COMPLETION_TIMEOUT, timeout_reason);
              `uvm_error("AXI_BFM_TIMEOUT", {timeout_reason, "; scheduler quarantined until reset"})
              // A W handshake on this edge already consumed its old payload.
              if (w_fire) w_slot = null;
            end
          end
        end
        if (!poisoned) begin
          if (prefer_write) begin select_write(); select_read(); end
          else begin select_read(); select_write(); end
          if (w_slot == null && w_order.size() != 0) begin
            w_slot = w_order.pop_front(); w_started = cycle;
          end
        end
        drive_channels();
      end
    endtask

    virtual task axi_write_burst(input axi4_burst_request req, output axi4_burst_response rsp);
      axi4_completion handle;
      init();
      submit_write(req, handle); wait_completion(handle, rsp);
      if (handle.status != AXI_COMPLETION_OK)
        `uvm_fatal("AXI_BFM_ABORT", $sformatf("Blocking write aborted: %s", handle.detail))
    endtask
    virtual task axi_read_burst(input axi4_burst_request req, output axi4_burst_response rsp);
      axi4_completion handle;
      init();
      submit_read(req, handle); wait_completion(handle, rsp);
      if (handle.status != AXI_COMPLETION_OK)
        `uvm_fatal("AXI_BFM_ABORT", $sformatf("Blocking read aborted: %s", handle.detail))
    endtask
    virtual task axi_write_resp(
      input bit [AXI_ADDR_WIDTH-1:0] addr,
      input bit [AXI_DATA_WIDTH-1:0] data,
      input bit [AXI_STRB_WIDTH-1:0] strb = AXI_DEFAULT_STRB,
      output logic [1:0] bresp
    );
      axi4_burst_request req;
      axi4_burst_response rsp;
      req = new("legacy_write"); req.addr = addr;
      req.data = new[1]; req.strb = new[1];
      req.data[0] = data; req.strb[0] = strb;
      // Existing checked sequences compare the returned BRESP themselves.
      req.check_response = 0;
      axi_write_burst(req, rsp);
      bresp = rsp.bresp;
    endtask

    virtual task axi_read(input bit [AXI_ADDR_WIDTH-1:0] addr,
                          output bit [AXI_DATA_WIDTH-1:0] data);
      axi4_burst_request req;
      axi4_burst_response rsp;
      req = new("legacy_read"); req.addr = addr;
      axi_read_burst(req, rsp);
      data = rsp.data[0];
    endtask

    virtual task wait_cycles(input int unsigned cycles);
      init();
      repeat (cycles) @(posedge vif.aclk);
    endtask
  endclass
endpackage
