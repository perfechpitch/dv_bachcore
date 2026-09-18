`timescale 1ns/1ps

package outstanding_test_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class expected_diagnostic extends uvm_report_catcher;
    string expected_id;
    string expected_pattern = "*";
    int unsigned matched;
    function new(string name = "expected_diagnostic"); super.new(name); endfunction
    virtual function action_e catch();
      if (get_severity() == UVM_ERROR && expected_id != "" && get_id() == expected_id &&
          matched == 0 && uvm_is_match(expected_pattern, get_message())) begin
        matched++;
        $display("EXPECTED_DIAGNOSTIC id=%s message=%s", get_id(), get_message());
        return CAUGHT;
      end
      return THROW;
    endfunction
  endclass
endpackage

module outstanding_tb;
  import uvm_pkg::*;
  import axi4_vip_adapter_pkg::*;
  import simple_axi4_bfm_adapter_pkg::*;
  import outstanding_test_pkg::*;

  bit clk = 0, reset_n = 0;
  always #0.5 clk = ~clk;
  axi4_if #(.ADDR_WIDTH(AXI_ADDR_WIDTH), .DATA_WIDTH(AXI_DATA_WIDTH),
            .ID_WIDTH(AXI_ID_WIDTH), .LEN_WIDTH(AXI_LEN_WIDTH),
            .QOS_WIDTH(AXI_QOS_WIDTH), .REGION_WIDTH(AXI_REGION_WIDTH),
            .AWUSER_WIDTH(AXI_AWUSER_WIDTH), .ARUSER_WIDTH(AXI_ARUSER_WIDTH),
            .WUSER_WIDTH(AXI_WUSER_WIDTH), .RUSER_WIDTH(AXI_RUSER_WIDTH),
            .BUSER_WIDTH(AXI_BUSER_WIDTH)) axi(clk, reset_n);
  outstanding_controlled_slave #(.ADDR_WIDTH(AXI_ADDR_WIDTH),
    .DATA_WIDTH(AXI_DATA_WIDTH), .ID_WIDTH(AXI_ID_WIDTH)) slave(axi);
  simple_axi4_bfm_adapter adapter;
  expected_diagnostic diagnostic;
  axi4_completion reads[$], writes[$];
  axi4_burst_request read_requests[$], write_requests[$];
  bit completed_serial[longint unsigned];
  int unsigned completions;
  bit same_id_only;
  bit verify_b_completion_order;
  bit observed_b_completion[longint unsigned];
  string test_case;
  uvm_report_server report_server;

  task automatic tick(input int cycles);
    repeat (cycles) @(posedge clk);
    @(negedge clk); #1ps;
  endtask

  task automatic reset_bus();
    @(negedge clk); #1ps; reset_n = 0;
    tick(4); reset_n = 1;
    tick(4);
  endtask

  task automatic setup(input int rcap, input int wcap, input int tcap);
    slave.hold_b = 1; slave.hold_r = 1;
    slave.block_aw = 0; slave.block_w = 0; slave.block_ar = 0;
    slave.awready_requires_wvalid = 0;
    slave.independent_stalls = 1; slave.check_write_pattern = 1;
    slave.reverse_ids = 1; slave.interleave_reads = 1;
    slave.fault_mode = 0; slave.forced_bresp = 0; slave.forced_rresp = 0;
    slave.response_error_beat = -1;
    slave.address_bresp = 0; same_id_only = 0; verify_b_completion_order = 0;
    observed_b_completion.delete();
    slave.read_limit = rcap; slave.write_limit = wcap; slave.total_limit = tcap;
    reset_bus();
    adapter.configure_outstanding(rcap, wcap, tcap);
    adapter.configure_timeouts(10000, 10000, 10000);
    reads.delete(); writes.delete(); read_requests.delete(); write_requests.delete();
    completed_serial.delete(); completions = 0;
    diagnostic.expected_id = ""; diagnostic.matched = 0;
    diagnostic.expected_pattern = "*";
  endtask

  function automatic axi4_burst_request request_for(input int index, input bit is_write,
                                         input int fixed_beats = 0);
    axi4_burst_request req;
    req = new();
    req.id = same_id_only ? 7 : 1 + index % 13;
    req.addr = (is_write ? 'h100000 : 'h400000) + index * 512;
    req.beat_count = fixed_beats != 0 ? fixed_beats :
                     index % 3 == 0 ? 1 : index % 3 == 1 ? 4 : 16;
    req.size = $clog2(AXI_STRB_WIDTH); req.burst = 1; req.lock = 0;
    req.check_response = 0;
    if (is_write) begin
      req.data = new[req.beat_count]; req.strb = new[req.beat_count];
      foreach (req.data[i]) begin
        req.data[i] = slave.pattern(req.addr, i);
        req.strb[i] = slave.strobe_pattern(i);
      end
    end
    return req;
  endfunction

  task automatic submit_one(input bit is_write, input int index, input int beats = 0);
    axi4_burst_request req;
    axi4_completion handle;
    req = request_for(index, is_write, beats);
    if (is_write) begin
      adapter.submit_write(req, handle);
      writes.push_back(handle); write_requests.push_back(req);
    end else begin
      adapter.submit_read(req, handle);
      reads.push_back(handle); read_requests.push_back(req);
    end
    if (handle == null) $fatal(1, "Submit returned null completion");
  endtask

  task automatic check_completed(input axi4_completion handle, input axi4_burst_request req,
                       input bit is_write);
    axi4_burst_response response;
    logic [1:0] expected_resp;
    adapter.wait_completion(handle, response);
    if (!handle.done || handle.status != AXI_COMPLETION_OK || response == null)
      $fatal(1, "Completion failed serial=%0d status=%0d", handle.serial, handle.status);
    if (completed_serial.exists(handle.serial))
      $fatal(1, "Duplicate completion serial=%0d", handle.serial);
    completed_serial[handle.serial] = 1; completions++;
    if (is_write) begin
      expected_resp = slave.address_bresp ? slave.bresp_pattern(req.addr) : slave.forced_bresp;
      if (response.bid !== req.id || response.bresp !== expected_resp)
        $fatal(1, "B response mismatch serial=%0d id=%h/%h resp=%h/%h",
          handle.serial, response.bid, req.id, response.bresp, expected_resp);
    end else begin
      if (response.data.size() != req.beat_count || response.rid.size() != req.beat_count ||
          response.rresp.size() != req.beat_count || response.rlast.size() != req.beat_count)
        $fatal(1, "Read result array size mismatch serial=%0d", handle.serial);
      foreach (response.data[i]) begin
        expected_resp = slave.response_error_beat < 0 || i == slave.response_error_beat ?
                        slave.forced_rresp : 2'b00;
        if (response.data[i] !== slave.pattern(req.addr, i) || response.rid[i] !== req.id ||
            response.rresp[i] !== expected_resp || response.rlast[i] !== (i == req.beat_count - 1))
          $fatal(1, "Read payload/ID/RESP/LAST mismatch serial=%0d addr=%h beat=%0d",
            handle.serial, req.addr, i);
      end
    end
  endtask

  task automatic drain(input string label_text);
    int expected_w, expected_r;
    expected_w = 0; expected_r = 0;
    foreach (write_requests[i]) expected_w += write_requests[i].beat_count;
    foreach (read_requests[i]) expected_r += read_requests[i].beat_count;
    slave.hold_b = 0; slave.hold_r = 0;
    foreach (reads[i]) check_completed(reads[i], read_requests[i], 0);
    foreach (writes[i]) check_completed(writes[i], write_requests[i], 1);
    tick(3);
    if (slave.aw_count != writes.size() || slave.b_count != writes.size() ||
        slave.w_count != expected_w || slave.ar_count != reads.size() ||
        slave.rlast_count != reads.size() || slave.r_count != expected_r ||
        slave.live_reads != 0 || slave.live_writes != 0 ||
        adapter.get_outstanding_total() != 0 || adapter.get_queued_reads() != 0 ||
        adapter.get_queued_writes() != 0 || completions != reads.size() + writes.size())
      $fatal(1, "Drain/count mismatch %s", label_text);
    slave.report(label_text);
    $display("COMPLETION_EVIDENCE %s submitted=%0d unique_completed=%0d",
      label_text, reads.size() + writes.size(), completions);
  endtask

  task automatic reach_plateau(input int target, input string label_text);
    int watchdog;
    watchdog = 0;
    while (slave.live_reads + slave.live_writes != target && watchdog++ < 5000) tick(1);
    if (slave.live_reads + slave.live_writes != target)
      $fatal(1, "Failed to reach %s target=%0d R=%0d W=%0d", label_text, target,
        slave.live_reads, slave.live_writes);
    tick(30);
    if (slave.live_reads + slave.live_writes != target || slave.peak_total != target)
      $fatal(1, "Plateau exceeded %s", label_text);
    if (adapter.get_outstanding_reads() != slave.live_reads ||
        adapter.get_outstanding_writes() != slave.live_writes ||
        adapter.get_outstanding_total() != target)
      $fatal(1, "Driver counters disagree with physical bus %s", label_text);
    slave.report({label_text, "_HELD"});
  endtask

  task automatic depth_cases();
    setup(128, 128, 128);
    for (int i = 0; i < 160; i++) submit_one(0, i);
    reach_plateau(128, "READ128");
    if (slave.peak_reads != 128 || adapter.get_queued_reads() < 32)
      $fatal(1, "READ128 did not distinguish queue from bus outstanding");
    drain("READ128");
    if (slave.out_of_order_r == 0 || slave.interleaved_r == 0)
      $fatal(1, "Missing R reorder/interleave coverage");

    setup(128, 128, 128);
    for (int i = 0; i < 160; i++) submit_one(1, i);
    reach_plateau(128, "WRITE128");
    if (slave.peak_writes != 128 || adapter.get_queued_writes() < 32)
      $fatal(1, "WRITE128 did not distinguish queue from bus outstanding");
    // Let W drain under independent stalls while B remains held.
    tick(1800);
    drain("WRITE128");
    if (slave.out_of_order_b == 0) $fatal(1, "Missing B reorder coverage");

    setup(128, 128, 128);
    for (int i = 0; i < 96; i++) begin submit_one(0, i); submit_one(1, i); end
    reach_plateau(128, "MIXED128");
    if (slave.live_reads == 0 || slave.live_writes == 0)
      $fatal(1, "Mixed held traffic failed to exercise both directions");
    drain("MIXED128");

    setup(3, 5, 7);
    for (int i = 0; i < 12; i++) submit_one(0, i);
    reach_plateau(3, "ASYMMETRIC_READ3"); drain("ASYMMETRIC_READ3");
    setup(3, 5, 7);
    for (int i = 0; i < 12; i++) submit_one(1, i);
    reach_plateau(5, "ASYMMETRIC_WRITE5"); drain("ASYMMETRIC_WRITE5");
    setup(3, 5, 7);
    for (int i = 0; i < 20; i++) begin submit_one(0, i); submit_one(1, i); end
    reach_plateau(7, "ASYMMETRIC_TOTAL7"); drain("ASYMMETRIC_TOTAL7");
  endtask

  task automatic independent_aw_w_case();
    setup(3, 5, 7);
    slave.awready_requires_wvalid = 1;
    slave.block_aw = 1;
    submit_one(1, 0, 4);
    tick(20);
    if (slave.w_count == 0 || slave.aw_count != 0)
      $fatal(1, "WVALID incorrectly depends on AW handshake");
    slave.block_aw = 0;
    for (int i = 1; i < 8; i++) submit_one(1, i, 4);
    drain("AW_W_INDEPENDENT");
    if (slave.w_before_aw_count == 0) $fatal(1, "Missing early W coverage");
  endtask

  task automatic concurrent_callers_case();
    setup(8, 8, 12);
    slave.hold_b = 0; slave.hold_r = 0;
    fork
      begin for (int i = 0; i < 20; i++) submit_one(0, i, 4); end
      begin for (int i = 20; i < 40; i++) submit_one(0, i, 4); end
      begin for (int i = 0; i < 20; i++) submit_one(1, i, 4); end
      begin for (int i = 20; i < 40; i++) submit_one(1, i, 4); end
    join
    drain("CONCURRENT_CALLERS");
  endtask

  task automatic legacy_case();
    logic [1:0] bresp;
    bit [AXI_DATA_WIDTH-1:0] data, returned_data;
    setup(4, 4, 4);
    slave.hold_b = 0; slave.hold_r = 0; slave.check_write_pattern = 0;
    data = '1; data[31:0] = 32'h12345678;
    adapter.axi_write_resp('h800000, data, '1, bresp);
    tick(1);
    if (bresp !== 0 || slave.b_count != 1) $fatal(1, "Legacy write failed/returned early");
    adapter.axi_read('h800000, returned_data);
    tick(2);
    if (returned_data !== data || slave.rlast_count != 1) $fatal(1, "Legacy read failed");
    slave.report("LEGACY_API");
  endtask

  task automatic error_response_case();
    setup(8, 8, 12);
    slave.forced_bresp = AXI_RESP_SLVERR;
    slave.forced_rresp = AXI_RESP_DECERR; slave.response_error_beat = 2;
    for (int i = 0; i < 8; i++) begin submit_one(0, i, 4); submit_one(1, i, 4); end
    drain("ERROR_RESPONSE_COLLECTION");
  endtask

  task automatic same_id_case();
    setup(8, 8, 12);
    same_id_only = 1; slave.address_bresp = 1; verify_b_completion_order = 1;
    for (int i = 0; i < 24; i++) begin submit_one(0, i, 4); submit_one(1, i, 4); end
    reach_plateau(12, "SAME_ID_FIFO");
    drain("SAME_ID_FIFO");
    if (slave.out_of_order_b != 0 || slave.out_of_order_r != 0)
      $fatal(1, "Slave violated same-ID order");
    if (observed_b_completion.num() != 24)
      $fatal(1, "Missing same-ID per-B completion-order observations");
  endtask

  always @(posedge clk) begin : check_b_order
    int expected_index;
    bit [AXI_ID_WIDTH-1:0] sampled_bid;
    if (reset_n && verify_b_completion_order && axi.bvalid && axi.bready) begin
      sampled_bid = axi.bid;
      #1ps;
      expected_index = -1;
      foreach (writes[i])
        if (expected_index < 0 && write_requests[i].id == sampled_bid &&
            !observed_b_completion.exists(writes[i].serial)) expected_index = i;
      if (expected_index < 0 || !writes[expected_index].done ||
          writes[expected_index].status != AXI_COMPLETION_OK)
        $fatal(1, "Same-ID B failed to complete earliest pending handle");
      observed_b_completion[writes[expected_index].serial] = 1;
      for (int i = expected_index + 1; i < writes.size(); i++)
        if (write_requests[i].id == sampled_bid && writes[i].done)
          $fatal(1, "Same-ID B completed a later handle early");
    end
  end

  task automatic progressing_timeout_case();
    setup(16, 16, 24);
    same_id_only = 1;
    slave.independent_stalls = 0; slave.hold_b = 0; slave.hold_r = 0;
    adapter.configure_timeouts(4, 4, 16);
    for (int i = 0; i < 12; i++) begin submit_one(0, i, 16); submit_one(1, i, 16); end
    drain("PROGRESS_RESETS_TIMEOUT");
    if (slave.r_count != 192 || slave.w_count != 192)
      $fatal(1, "Low-timeout test failed to exercise long transaction lifetimes");
  endtask

  task automatic submit_snapshot_case();
    axi4_burst_request original, expected_req;
    axi4_completion handle;
    setup(4, 4, 4);
    for (int i = 0; i < 4; i++) begin
      original = request_for(i, 1, 4); expected_req = request_for(i, 1, 4);
      adapter.submit_write(original, handle);
      writes.push_back(handle); write_requests.push_back(expected_req);
      original.id = '1; original.addr = 'hffff0000; original.beat_count = 1;
      foreach (original.data[j]) begin original.data[j] = '0; original.strb[j] = '0; end
      original = request_for(i, 0, 4); expected_req = request_for(i, 0, 4);
      adapter.submit_read(original, handle);
      reads.push_back(handle); read_requests.push_back(expected_req);
      original.id = '1; original.addr = 'hffff0000; original.beat_count = 1;
    end
    drain("SUBMIT_DEEP_COPY");
  endtask

  task automatic reset_midburst_case();
    axi4_burst_response response;
    setup(4, 4, 4);
    slave.hold_b = 0; slave.hold_r = 0; slave.independent_stalls = 0;
    submit_one(0, 0, 16); submit_one(1, 0, 16);
    while (slave.w_count < 2 || slave.r_count < 2) tick(1);
    slave.block_w = 1; slave.block_aw = 1; slave.block_ar = 1; slave.hold_r = 1;
    submit_one(0, 1, 16); submit_one(1, 1, 16);
    tick(5);
    if (slave.w_count >= 16 || slave.r_count >= 16 || !axi.wvalid ||
        (!axi.awvalid && !axi.arvalid))
      $fatal(1, "Midburst reset test did not reach stalled partial transfers");
    slave.report("RESET_MIDBURST_BEFORE");
    reset_bus();
    foreach (reads[i]) begin
      adapter.wait_completion(reads[i], response);
      if (reads[i].status != AXI_COMPLETION_RESET) $fatal(1, "Partial read reset failed");
    end
    foreach (writes[i]) begin
      adapter.wait_completion(writes[i], response);
      if (writes[i].status != AXI_COMPLETION_RESET) $fatal(1, "Partial write reset failed");
    end
    $display("RESET_EVIDENCE partial_read_write_and_stalled_addresses=4 resolved_reset=4");
    setup(4, 4, 4);
    submit_one(0, 92, 4); submit_one(1, 92, 4); drain("RESET_MIDBURST_RECOVERY");
  endtask

  task automatic reset_case();
    axi4_burst_response response;
    int reset_completions;
    setup(2, 2, 3);
    for (int i = 0; i < 8; i++) begin submit_one(0, i, 4); submit_one(1, i, 4); end
    reach_plateau(3, "RESET_PENDING");
    reset_bus(); reset_completions = 0;
    foreach (reads[i]) begin
      adapter.wait_completion(reads[i], response);
      if (!reads[i].done || reads[i].status != AXI_COMPLETION_RESET)
        $fatal(1, "Reset failed to resolve read handle %0d", i);
      reset_completions++;
    end
    foreach (writes[i]) begin
      adapter.wait_completion(writes[i], response);
      if (!writes[i].done || writes[i].status != AXI_COMPLETION_RESET)
        $fatal(1, "Reset failed to resolve write handle %0d", i);
      reset_completions++;
    end
    if (adapter.get_outstanding_total() != 0 || adapter.get_queued_reads() != 0 ||
        adapter.get_queued_writes() != 0 || reset_completions != 16)
      $fatal(1, "Reset left queued/active work");
    $display("RESET_EVIDENCE interrupted_handles=%0d resolved_reset=%0d", 16, reset_completions);
    reads.delete(); writes.delete(); read_requests.delete(); write_requests.delete();
    submit_one(0, 99, 4); submit_one(1, 99, 4); drain("RESET_RECOVERY");
  endtask

  task automatic negative_case(input string mode);
    axi4_completion handle;
    axi4_burst_request req;
    axi4_burst_response response;
    bit is_write;
    axi_completion_status_e expected_status;
    setup(4, 4, 4);
    adapter.configure_timeouts(40, 40, 20);
    is_write = mode == "timeout_aw" || mode == "timeout_w" || mode == "timeout_b" ||
               mode == "bad_bid" || mode == "early_b";
    expected_status = mode.substr(0, 6) == "timeout" ? AXI_COMPLETION_TIMEOUT :
                                                             AXI_COMPLETION_PROTOCOL_ERROR;
    diagnostic.expected_id = expected_status == AXI_COMPLETION_TIMEOUT ?
                             "AXI_BFM_TIMEOUT" : "AXI_BFM_PROTOCOL";
    case (mode)
      "timeout_aw": begin slave.block_aw = 1; slave.hold_b = 0; end
      "timeout_w": begin slave.block_w = 1; slave.hold_b = 0; end
      "timeout_b": slave.hold_b = 1;
      "timeout_ar": begin slave.block_ar = 1; slave.hold_r = 0; end
      "timeout_r": slave.hold_r = 1;
      "bad_bid": begin slave.fault_mode = 1; slave.hold_b = 0; end
      "bad_rid": begin slave.fault_mode = 2; slave.hold_r = 0; end
      "early_rlast": begin slave.fault_mode = 3; slave.hold_r = 0; end
      "missing_rlast": begin slave.fault_mode = 4; slave.hold_r = 0; end
      "early_b": begin slave.fault_mode = 5; slave.hold_b = 0; slave.block_w = 1; end
      default: $fatal(1, "Unknown negative test %s", mode);
    endcase
    req = request_for(0, is_write, 4);
    if (is_write) adapter.submit_write(req, handle); else adapter.submit_read(req, handle);
    adapter.wait_completion(handle, response);
    if (!handle.done || handle.status != expected_status || diagnostic.matched != 1)
      $fatal(1, "Negative case mismatch %s status=%0d expected=%0d diagnostics=%0d",
        mode, handle.status, expected_status, diagnostic.matched);
    $display("NEGATIVE_EVIDENCE case=%s status=%0d expected_diagnostics=%0d",
      mode, handle.status, diagnostic.matched);
    // A fresh submission while poisoned must resolve, never silently restart.
    if (is_write) adapter.submit_write(req, handle); else adapter.submit_read(req, handle);
    if (!handle.done || handle.status == AXI_COMPLETION_OK)
      $fatal(1, "Poisoned adapter accepted new work %s", mode);
    if (mode == "timeout_aw" || mode == "timeout_w" || mode == "timeout_ar")
      check_late_ready(mode);
    setup(4, 4, 4);
    submit_one(0, 90, 4); submit_one(1, 90, 4); drain({mode, "_RECOVERY"});
  endtask

  task automatic check_late_ready(input string label_text);
    int aw_before, w_before, ar_before, live_before;
    bit declared_aw, declared_w, declared_ar;
    tick(1);
    aw_before = slave.aw_count; w_before = slave.w_count; ar_before = slave.ar_count;
    live_before = adapter.get_outstanding_total();
    declared_aw = axi.awvalid; declared_w = axi.wvalid; declared_ar = axi.arvalid;
    tick(4);
    if (axi.awvalid != declared_aw || axi.wvalid != declared_w || axi.arvalid != declared_ar)
      $fatal(1, "Poison dropped stalled VALID before handshake %s", label_text);
    slave.hold_b = 1; slave.hold_r = 1;
    slave.independent_stalls = 0;
    slave.block_aw = 0; slave.block_w = 0; slave.block_ar = 0;
    tick(12);
    if (slave.aw_count != aw_before + int'(declared_aw) ||
        slave.w_count != w_before + int'(declared_w) ||
        slave.ar_count != ar_before + int'(declared_ar))
      $fatal(1, "Poison repeated/lost declared handshake %s AW=%0d+%0d/%0d W=%0d+%0d/%0d AR=%0d+%0d/%0d",
        label_text, aw_before, declared_aw, slave.aw_count, w_before, declared_w, slave.w_count,
        ar_before, declared_ar, slave.ar_count);
    if (axi.awvalid || axi.wvalid || axi.arvalid || axi.bready || axi.rready)
      $fatal(1, "Poison issued new work or accepted response %s", label_text);
    if (adapter.get_outstanding_total() != live_before + int'(declared_aw) + int'(declared_ar) ||
        adapter.get_outstanding_reads() != slave.live_reads ||
        adapter.get_outstanding_writes() != slave.live_writes)
      $fatal(1, "Poison falsified actual outstanding %s driver=%0d slave=%0d",
        label_text, adapter.get_outstanding_total(), slave.live_reads + slave.live_writes);
    slave.report({label_text, "_LATE_READY"});
    $display("POISON_EVIDENCE %s declaredAW=%0d declaredW=%0d declaredAR=%0d late_transfers=%0d actual_after=%0d",
      label_text, declared_aw, declared_w, declared_ar,
      int'(declared_aw) + int'(declared_w) + int'(declared_ar), adapter.get_outstanding_total());
  endtask

  task automatic poison_cleanup_case();
    axi4_burst_response response;
    int terminated;
    setup(4, 4, 4);
    adapter.configure_timeouts(40, 40, 20);
    slave.block_aw = 1; slave.block_w = 1; slave.block_ar = 1;
    diagnostic.expected_id = "AXI_BFM_TIMEOUT";
    for (int i = 0; i < 8; i++) begin submit_one(0, i, 4); submit_one(1, i, 4); end
    terminated = 0;
    foreach (reads[i]) begin
      adapter.wait_completion(reads[i], response);
      if (!reads[i].done || reads[i].status != AXI_COMPLETION_TIMEOUT)
        $fatal(1, "Poison failed to terminate old read %0d", i);
      terminated++;
    end
    foreach (writes[i]) begin
      adapter.wait_completion(writes[i], response);
      if (!writes[i].done || writes[i].status != AXI_COMPLETION_TIMEOUT)
        $fatal(1, "Poison failed to terminate old write %0d", i);
      terminated++;
    end
    if (terminated != 16 || diagnostic.matched != 1)
      $fatal(1, "Poison termination/diagnostic count mismatch");
    check_late_ready("POISON_CLEANUP");
    $display("POISON_COMPLETION_EVIDENCE queued_and_declared=%0d resolved_timeout=%0d", 16, terminated);
    setup(4, 4, 4);
    submit_one(0, 91, 4); submit_one(1, 91, 4); drain("POISON_CLEANUP_RECOVERY");
  endtask

  // The timeout edge itself must retain every physical transfer. Schedule
  // READY from an observed address/final-W edge, without inspecting driver
  // internals; setting block controls before the preceding negedge is essential.
  task automatic timeout_same_edge_case(input bit b_timeout);
    localparam int RESPONSE_BUDGET = 8;
    int anchor_cycle, aw_before, w_before, ar_before, failed_handles;
    bit aw_at_fault, w_at_fault, ar_at_fault, nonfinal_w_at_fault;
    string label_text;
    axi4_burst_response response;
    setup(4, 4, 8);
    label_text = b_timeout ? "B_TIMEOUT_SAME_EDGE" : "R_TIMEOUT_SAME_EDGE";
    slave.independent_stalls = 0;
    adapter.configure_timeouts(b_timeout ? 0 : RESPONSE_BUDGET,
                               b_timeout ? RESPONSE_BUDGET : 0, 64);
    diagnostic.expected_id = "AXI_BFM_TIMEOUT";
    diagnostic.expected_pattern = b_timeout ? "B response timeout*" : "R response timeout*";
    submit_one(b_timeout, 0, 1);
    if (b_timeout) begin
      while (slave.aw_count != 1 || slave.w_count != 1) tick(1);
    end else begin
      while (slave.ar_count != 1) tick(1);
    end
    anchor_cycle = slave.cycle;
    // No follower can handshake before these controls take effect: its first
    // VALID is driven by the next posedge, after this submission returns.
    slave.block_aw = 1; slave.block_w = 1; slave.block_ar = 1;
    for (int i = 1; i <= 3; i++) begin
      submit_one(0, i, 4); submit_one(1, i, 4);
    end
    repeat (RESPONSE_BUDGET - 1) @(posedge clk);
    #1ps;
    if (slave.cycle != anchor_cycle + RESPONSE_BUDGET - 1 || diagnostic.matched != 0)
      $fatal(1, "Response timeout fired before its configured boundary %s", label_text);
    if (!axi.awvalid || !axi.wvalid || !axi.arvalid ||
        axi.awready || axi.wready || axi.arready || axi.wlast)
      $fatal(1, "Expected stalled AW/AR and nonfinal W before timeout %s", label_text);
    aw_before = slave.aw_count; w_before = slave.w_count; ar_before = slave.ar_count;
    slave.block_aw = 0; slave.block_w = 0; slave.block_ar = 0;
    @(posedge clk);
    // Capture pre-NBA handshakes at the physical transfer edge.
    aw_at_fault = axi.awvalid === 1'b1 && axi.awready === 1'b1;
    w_at_fault = axi.wvalid === 1'b1 && axi.wready === 1'b1;
    ar_at_fault = axi.arvalid === 1'b1 && axi.arready === 1'b1;
    nonfinal_w_at_fault = axi.wlast === 1'b0;
    #1ps;
    if (!aw_at_fault || !w_at_fault || !ar_at_fault || !nonfinal_w_at_fault ||
        slave.cycle != anchor_cycle + RESPONSE_BUDGET || diagnostic.matched != 1)
      $fatal(1, "Did not hit timeout and three simultaneous transfers %s", label_text);
    if (slave.aw_count != aw_before + 1 || slave.w_count != w_before + 1 ||
        slave.ar_count != ar_before + 1 || slave.b_count != 0 || slave.r_count != 0 ||
        adapter.get_outstanding_reads() != slave.live_reads ||
        adapter.get_outstanding_writes() != slave.live_writes ||
        adapter.get_outstanding_total() != 3)
      $fatal(1, "Fault edge lost/duplicated a transfer or falsified outstanding %s", label_text);
    if (axi.awvalid || axi.wvalid || axi.arvalid || axi.bready || axi.rready)
      $fatal(1, "Fault edge launched next W beat/address or kept response READY %s", label_text);
    failed_handles = 0;
    foreach (reads[i]) begin
      if (!reads[i].done || reads[i].status != AXI_COMPLETION_TIMEOUT)
        $fatal(1, "Read was not failed on fault edge %s index=%0d", label_text, i);
      failed_handles++;
    end
    foreach (writes[i]) begin
      if (!writes[i].done || writes[i].status != AXI_COMPLETION_TIMEOUT)
        $fatal(1, "Write was not failed on fault edge %s index=%0d", label_text, i);
      failed_handles++;
    end
    if (failed_handles != 7) $fatal(1, "Missing queued/active handles %s", label_text);
    slave.report({label_text, "_FAULT_EDGE"});
    // Let the slave present the timed-out response and the new read response.
    // They must remain unaccepted, with no successful rewrite of old handles.
    @(negedge clk); #1ps;
    slave.hold_b = 0; slave.hold_r = 0;
    tick(12);
    if ((b_timeout && axi.bvalid !== 1'b1) || (!b_timeout && axi.rvalid !== 1'b1))
      $fatal(1, "Slave did not present a late response %s", label_text);
    if (slave.aw_count != aw_before + 1 || slave.w_count != w_before + 1 ||
        slave.ar_count != ar_before + 1 || slave.b_count != 0 || slave.r_count != 0 ||
        adapter.get_outstanding_total() != 3 || diagnostic.matched != 1 ||
        axi.awvalid || axi.wvalid || axi.arvalid || axi.bready || axi.rready)
      $fatal(1, "Post-fault traffic repeated or late response retired %s", label_text);
    foreach (reads[i]) begin
      adapter.wait_completion(reads[i], response);
      if (reads[i].status != AXI_COMPLETION_TIMEOUT)
        $fatal(1, "Late R rewrote failed completion %s", label_text);
    end
    foreach (writes[i]) begin
      adapter.wait_completion(writes[i], response);
      if (writes[i].status != AXI_COMPLETION_TIMEOUT)
        $fatal(1, "Late B rewrote failed completion %s", label_text);
    end
    $display("TIMEOUT_EDGE_EVIDENCE %s budget=%0d elapsed_edges=%0d same_edge_AW=1 same_edge_W=1 same_edge_AR=1 live=3 failed_handles=%0d late_response_accepted=0 no_new_W_beats=1",
      label_text, RESPONSE_BUDGET, RESPONSE_BUDGET, failed_handles);
    setup(4, 4, 4);
    submit_one(0, 93, 4); submit_one(1, 93, 4); drain({label_text, "_RECOVERY"});
  endtask

  task automatic total_one_fairness_case();
    int previous_aw, previous_ar, accepted, watchdog;
    bit previous_write, current_write;
    setup(1, 1, 1);
    slave.independent_stalls = 0;
    for (int i = 0; i < 16; i++) begin
      submit_one(0, i, 1); submit_one(1, i, 1);
    end
    slave.hold_b = 0; slave.hold_r = 0;
    previous_aw = 0; previous_ar = 0; accepted = 0; watchdog = 0;
    while (accepted < 32 && watchdog++ < 1000) begin
      tick(1);
      if (slave.aw_count + slave.ar_count != accepted) begin
        if (slave.aw_count + slave.ar_count != accepted + 1)
          $fatal(1, "Total-one credit accepted multiple addresses");
        current_write = slave.aw_count != previous_aw;
        if (accepted != 0 && current_write == previous_write)
          $fatal(1, "Total-one arbitration starved the opposite queued direction");
        previous_write = current_write;
        previous_aw = slave.aw_count; previous_ar = slave.ar_count;
        accepted++;
      end
    end
    if (accepted != 32) $fatal(1, "Total-one fairness did not progress");
    drain("TOTAL_ONE_FAIRNESS");
    if (slave.peak_total != 1) $fatal(1, "Total-one limit was not enforced");
    $display("FAIRNESS_EVIDENCE accepted=32 strict_read_write_alternation=1 peakTotal=1");
  endtask

  initial begin
    adapter = new(); diagnostic = new();
    uvm_report_cb::add(null, diagnostic);
    uvm_config_db#(axi4_vif_t)::set(null, "*", "axi_vif", axi);
    tick(4); reset_n = 1; adapter.init();
    test_case = "positive"; void'($value$plusargs("CASE=%s", test_case));
    if (test_case == "positive") begin
      depth_cases(); independent_aw_w_case(); concurrent_callers_case();
      legacy_case(); error_response_case(); same_id_case(); progressing_timeout_case();
      submit_snapshot_case(); reset_case(); reset_midburst_case(); total_one_fairness_case();
    end else if (test_case == "poison_cleanup") poison_cleanup_case();
    else if (test_case == "timeout_edge_r") timeout_same_edge_case(0);
    else if (test_case == "timeout_edge_b") timeout_same_edge_case(1);
    else negative_case(test_case);
    report_server = uvm_report_server::get_server();
    if (report_server.get_severity_count(UVM_ERROR) != 0 ||
        report_server.get_severity_count(UVM_FATAL) != 0)
      $fatal(1, "Unexpected UVM errors in outstanding regression");
    $display("OUTSTANDING_REGRESSION_PASS CASE=%s", test_case);
    $finish;
  end
  initial begin #200000; $fatal(1, "Outstanding regression watchdog"); end
endmodule
