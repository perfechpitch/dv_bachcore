`timescale 1ns/1ps

// Test controls and snapshots cross between the UVM test and the module model.
// Snapshots are updated at negedge + 1ps; the UVM test reads at + 2ps.
interface outstanding_lifecycle_control_if(input logic clk, input logic reset_n);
  bit release_responses;
  int unsigned aw_count, w_count, b_count, ar_count, r_count, completed_reads;
  int unsigned live_reads, live_writes, queued_reads, queued_writes, early_w;
endinterface

package outstanding_lifecycle_test_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import axi4_vip_adapter_pkg::*;
  import simple_axi4_bfm_adapter_pkg::*;

  class outstanding_lifecycle_sequence extends axi4_sequence_base;
    `uvm_object_utils(outstanding_lifecycle_sequence)
    axi4_burst_request request;
    axi4_completion completion;
    axi4_burst_response response;
    bit is_write;
    bit body_returned;

    function new(string name = "outstanding_lifecycle_sequence");
      super.new(name);
    endfunction

    task body();
      if (is_write) p_sequencer.adapter.submit_write(request, completion);
      else p_sequencer.adapter.submit_read(request, completion);
      p_sequencer.adapter.wait_completion(completion, response);
      body_returned = 1;
    endtask
  endclass

  class outstanding_lifecycle_test extends uvm_test;
    `uvm_component_utils(outstanding_lifecycle_test)
    simple_axi4_bfm_adapter adapter;
    axi4_adapter_sequencer seqr;
    virtual outstanding_lifecycle_control_if control;
    bit verified;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if (!uvm_config_db#(virtual outstanding_lifecycle_control_if)::get(
          this, "", "lifecycle_control", control))
        `uvm_fatal("LIFECYCLE", "Missing lifecycle_control interface")
      adapter = simple_axi4_bfm_adapter::type_id::create("adapter");
      uvm_config_db#(axi4_vip_adapter_base)::set(this, "seqr", "adapter", adapter);
      seqr = axi4_adapter_sequencer::type_id::create("seqr", this);
      // The sequencer build_phase must claim the runtime; its run_phase must
      // own adapter.service(). Do not pre-initialize from this test: doing so
      // could conceal a driver that incorrectly forks from a sequence's init.
    endfunction

    function outstanding_lifecycle_sequence make_sequence(input string name,
                                                          input bit is_write,
                                                          input int index);
      outstanding_lifecycle_sequence seq;
      seq = outstanding_lifecycle_sequence::type_id::create(name);
      seq.is_write = is_write;
      seq.request = new();
      seq.request.addr = (is_write ? 'h100000 : 'h400000) + index * 512;
      seq.request.id = index + 1;
      seq.request.beat_count = 4;
      seq.request.size = $clog2(AXI_STRB_WIDTH);
      seq.request.burst = 1;
      seq.request.lock = 0;
      seq.request.check_response = 0;
      if (is_write) begin
        seq.request.data = new[4]; seq.request.strb = new[4];
        foreach (seq.request.data[i]) begin
          seq.request.data[i] = '0;
          seq.request.data[i][31:0] = 32'hc0010000 | (index << 8) | i;
          seq.request.strb[i] = '1;
        end
      end
      return seq;
    endfunction

    task stable_cycle();
      @(negedge control.clk); #2ps;
    endtask

    task await_submitted(input outstanding_lifecycle_sequence seq);
      int watchdog;
      watchdog = 0;
      // Poll at a stable clock point rather than rely on simulator sensitivity
      // to changes of a class member used as a nested task's output argument.
      while (seq.completion == null && watchdog++ < 2000) stable_cycle();
      if (seq.completion == null)
        `uvm_fatal("LIFECYCLE", {seq.get_name(), " did not publish its completion"})
      $display("LIFECYCLE_STAGE submitted=%s serial=%0d", seq.get_name(), seq.completion.serial);
    endtask

    task await_body_returned(input outstanding_lifecycle_sequence seq);
      int watchdog;
      watchdog = 0;
      while (!seq.body_returned && watchdog++ < 2000) stable_cycle();
      if (!seq.body_returned)
        `uvm_fatal("LIFECYCLE", {seq.get_name(), " did not return after completion"})
    endtask

    task await_accepted(input int expected_aw, input int expected_ar,
                        input string label_text);
      int watchdog;
      watchdog = 0;
      while ((control.aw_count != expected_aw || control.ar_count != expected_ar) &&
             watchdog++ < 2000) stable_cycle();
      if (control.aw_count != expected_aw || control.ar_count != expected_ar)
        `uvm_fatal("LIFECYCLE", $sformatf(
          "%s requests not accepted: AW=%0d/%0d AR=%0d/%0d", label_text,
          control.aw_count, expected_aw, control.ar_count, expected_ar))
    endtask

    task check_completion(input outstanding_lifecycle_sequence seq);
      axi4_burst_response result;
      adapter.wait_completion(seq.completion, result);
      if (seq.completion == null || !seq.completion.done ||
          seq.completion.status != AXI_COMPLETION_OK || result == null)
        `uvm_fatal("LIFECYCLE", {seq.get_name(), " did not complete successfully"})
      if (seq.is_write) begin
        if (result.bid !== seq.request.id || result.bresp !== AXI_RESP_OKAY)
          `uvm_fatal("LIFECYCLE", {seq.get_name(), " write response mismatch"})
      end else begin
        if (result.data.size() != 4 || result.rid.size() != 4 ||
            result.rresp.size() != 4 || result.rlast.size() != 4)
          `uvm_fatal("LIFECYCLE", {seq.get_name(), " read response length mismatch"})
        foreach (result.rid[i])
          if (result.rid[i] !== seq.request.id || result.rresp[i] !== AXI_RESP_OKAY ||
              result.rlast[i] !== (i == 3))
            `uvm_fatal("LIFECYCLE", {seq.get_name(), " read response mismatch"})
      end
    endtask

    task assert_drained(input int expected_aw, input int expected_ar,
                        input string label_text);
      repeat (4) stable_cycle();
      if (control.aw_count != expected_aw || control.b_count != expected_aw ||
          control.w_count != 4 * expected_aw || control.ar_count != expected_ar ||
          control.r_count != 4 * expected_ar || control.completed_reads != expected_ar ||
          control.live_reads != 0 || control.live_writes != 0 ||
          control.queued_reads != 0 || control.queued_writes != 0 || control.early_w != 0 ||
          adapter.get_outstanding_total() != 0 || adapter.get_queued_reads() != 0 ||
          adapter.get_queued_writes() != 0)
        `uvm_fatal("LIFECYCLE", {label_text, " bus/queue drain mismatch"})
      $display("LIFECYCLE_BUS_EVIDENCE %s AW=%0d W=%0d B=%0d AR=%0d R=%0d completedR=%0d liveR=%0d liveW=%0d",
        label_text, control.aw_count, control.w_count, control.b_count,
        control.ar_count, control.r_count, control.completed_reads,
        control.live_reads, control.live_writes);
    endtask

    task run_phase(uvm_phase phase);
      outstanding_lifecycle_sequence killed, survivor, stopped_w, stopped_r;
      outstanding_lifecycle_sequence followup_w, followup_r;
      phase.raise_objection(this);
      wait (control.reset_n === 1'b1);
      stable_cycle();

      // Start the future victim first. A lazy engine owned by the first caller
      // is therefore guaranteed to be a descendant of the sequence we kill.
      killed = make_sequence("killed_waiter", 1, 0);
      survivor = make_sequence("surviving_waiter", 0, 1);
      fork killed.start(seqr); join_none
      await_submitted(killed);
      await_accepted(1, 0, "KILL_FIRST");
      fork survivor.start(seqr); join_none
      await_submitted(survivor);
      await_accepted(1, 1, "KILL_BOTH_PENDING");
      if (killed.completion.done || survivor.completion.done)
        `uvm_fatal("LIFECYCLE", "Responses were not held before sequence.kill")
      killed.kill();
      if (killed.get_sequence_state() != UVM_STOPPED || killed.body_returned)
        `uvm_fatal("LIFECYCLE", "Victim was not killed while waiting")
      control.release_responses = 1;
      check_completion(killed);
      check_completion(survivor);
      await_body_returned(survivor);
      if (killed.body_returned)
        `uvm_fatal("LIFECYCLE", "Killed sequence unexpectedly resumed")
      assert_drained(1, 1, "SEQUENCE_KILL");

      // Stop all sequence waiters while their requests remain owned by the
      // adapter. stop_sequences must not kill the sequencer's run_phase engine.
      control.release_responses = 0;
      repeat (3) stable_cycle();
      stopped_w = make_sequence("stopped_write", 1, 2);
      stopped_r = make_sequence("stopped_read", 0, 3);
      fork
        stopped_w.start(seqr);
        stopped_r.start(seqr);
      join_none
      await_submitted(stopped_w);
      await_submitted(stopped_r);
      await_accepted(2, 2, "STOP_BOTH_PENDING");
      if (stopped_w.completion.done || stopped_r.completion.done)
        `uvm_fatal("LIFECYCLE", "Responses were not held before stop_sequences")
      seqr.stop_sequences();
      if (stopped_w.get_sequence_state() != UVM_STOPPED ||
          stopped_r.get_sequence_state() != UVM_STOPPED ||
          stopped_w.body_returned || stopped_r.body_returned)
        `uvm_fatal("LIFECYCLE", "stop_sequences did not interrupt both waiters")
      control.release_responses = 1;
      check_completion(stopped_w);
      check_completion(stopped_r);
      assert_drained(2, 2, "STOP_SEQUENCES");
      if (stopped_w.body_returned || stopped_r.body_returned)
        `uvm_fatal("LIFECYCLE", "Stopped sequence unexpectedly resumed")

      followup_w = make_sequence("followup_write", 1, 4);
      followup_r = make_sequence("followup_read", 0, 5);
      fork
        followup_w.start(seqr);
        followup_r.start(seqr);
      join
      check_completion(followup_w);
      check_completion(followup_r);
      if (!followup_w.body_returned || !followup_r.body_returned)
        `uvm_fatal("LIFECYCLE", "Follow-up sequences did not return")
      assert_drained(3, 3, "POST_STOP_FOLLOWUP");
      verified = 1;
      phase.drop_objection(this);
    endtask

    function void report_phase(uvm_phase phase);
      uvm_report_server server;
      super.report_phase(phase);
      server = uvm_report_server::get_server();
      if (!verified || server.get_severity_count(UVM_ERROR) != 0 ||
          server.get_severity_count(UVM_FATAL) != 0)
        `uvm_fatal("LIFECYCLE", "Lifecycle test did not finish without errors")
      $display("LIFECYCLE_REGRESSION_PASS killed_waiters=3 completed_handles=6 AW=3 W=12 B=3 AR=3 R=12");
    endfunction
  endclass
endpackage

module lifecycle_tb;
  import uvm_pkg::*;
  import axi4_vip_adapter_pkg::*;
  import outstanding_lifecycle_test_pkg::*;
  bit clk = 0, reset_n = 0;
  always #0.5 clk = ~clk;
  outstanding_lifecycle_control_if control(clk, reset_n);
  axi4_if #(.ADDR_WIDTH(AXI_ADDR_WIDTH), .DATA_WIDTH(AXI_DATA_WIDTH),
            .ID_WIDTH(AXI_ID_WIDTH), .LEN_WIDTH(AXI_LEN_WIDTH),
            .QOS_WIDTH(AXI_QOS_WIDTH), .REGION_WIDTH(AXI_REGION_WIDTH),
            .AWUSER_WIDTH(AXI_AWUSER_WIDTH), .ARUSER_WIDTH(AXI_ARUSER_WIDTH),
            .WUSER_WIDTH(AXI_WUSER_WIDTH), .RUSER_WIDTH(AXI_RUSER_WIDTH),
            .BUSER_WIDTH(AXI_BUSER_WIDTH)) axi(clk, reset_n);
  outstanding_controlled_slave #(.ADDR_WIDTH(AXI_ADDR_WIDTH),
    .DATA_WIDTH(AXI_DATA_WIDTH), .ID_WIDTH(AXI_ID_WIDTH)) slave(axi);

  always @(negedge clk) begin
    #1ps;
    slave.hold_b = !control.release_responses;
    slave.hold_r = !control.release_responses;
    control.aw_count = slave.aw_count; control.w_count = slave.w_count;
    control.b_count = slave.b_count; control.ar_count = slave.ar_count;
    control.r_count = slave.r_count; control.completed_reads = slave.rlast_count;
    control.live_reads = slave.live_reads; control.live_writes = slave.live_writes;
    control.queued_reads = slave.reads.size(); control.queued_writes = slave.writes.size();
    control.early_w = slave.early_w.size();
  end

  initial begin
    slave.check_write_pattern = 0;
    slave.independent_stalls = 1;
    slave.read_limit = 8; slave.write_limit = 8; slave.total_limit = 8;
    uvm_config_db#(axi4_vif_t)::set(null, "*", "axi_vif", axi);
    uvm_config_db#(virtual outstanding_lifecycle_control_if)::set(
      null, "uvm_test_top", "lifecycle_control", control);
    run_test("outstanding_lifecycle_test");
  end
  initial begin repeat (4) @(negedge clk); #2ps; reset_n = 1; end
  initial begin #50000; $fatal(1, "Lifecycle regression watchdog"); end
endmodule
