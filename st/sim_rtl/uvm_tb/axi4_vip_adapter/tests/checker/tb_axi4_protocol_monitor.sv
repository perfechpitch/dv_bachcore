`timescale 1ns/1ps

// Raw-pin tests: intentionally independent of the BFM under test.
// Test assumptions: 16 beats maximum (LEN4 encoding), independent read/write
// limits 128, combined limit 128, and 1 GHz. These are a test profile, not a
// confirmation of the unspecified burst/128 definitions in the requirements.
module tb_axi4_protocol_monitor;
  localparam int TIMEOUT = 1024;
  bit clk = 0;
  always #0.5 clk = ~clk;
  bit resetn = 0;
  axi4_if #(.ADDR_WIDTH(32), .DATA_WIDTH(256), .ID_WIDTH(8), .LEN_WIDTH(4),
    .QOS_WIDTH(0), .REGION_WIDTH(0)) bus(clk, resetn);
  logic [255:0] lane_data;
  int assertions = 0;
  int scenarios = 0;
  longint unsigned counts[7];
  longint unsigned masked_counts[7][7];
  longint unsigned before_counts[7], before_masked[7][7];
  longint unsigned before_aw, before_ar, before_w, before_b, before_r;
  longint unsigned before_alignment, before_support, before_traffic;
  longint unsigned masked_tx_samples[7], masked_proto_samples[7], masked_error_samples[7];

`define COMMON_PARAMS \
    .ADDR_WIDTH(32), .DATA_WIDTH(256), .ID_WIDTH(8), .LEN_WIDTH(4), \
    .READ_TIMEOUT_CYCLES(TIMEOUT), .WRITE_TIMEOUT_CYCLES(TIMEOUT), \
    .READY_TIMEOUT_CYCLES(TIMEOUT), .REPORT_ERRORS(0)

  axi4_protocol_monitor #(`COMMON_PARAMS, .ENABLE_COVERAGE(1),
    .ENABLE_TRANSACTION_COVERAGE(1), .ENABLE_PROTOCOL_COVERAGE(1),
    .ENABLE_ERROR_COVERAGE(1)) dut(bus);
  axi4_protocol_monitor #(`COMMON_PARAMS,
    .ENABLE_PROTOCOL_CHECKS(0), .ENABLE_X_CHECKS(0),
    .ENABLE_ALIGNMENT_CHECKS(0), .ENABLE_STROBE_CHECKS(0),
    .ENABLE_RESPONSE_CHECKS(0), .ENABLE_TIMEOUT_CHECKS(0),
    .ENFORCE_TRAFFIC_POLICY(0), .ENABLE_COVERAGE(0)) all_off(bus);

  // A disabled checker must not suppress unrelated checker categories.
  for (genvar group = 0; group < 7; group++) begin : masks
    axi4_protocol_monitor #(`COMMON_PARAMS,
      .ENABLE_PROTOCOL_CHECKS(group != 0), .ENABLE_X_CHECKS(group != 1),
      .ENABLE_ALIGNMENT_CHECKS(group != 2), .ENABLE_STROBE_CHECKS(group != 3),
      .ENABLE_RESPONSE_CHECKS(group != 4), .ENABLE_TIMEOUT_CHECKS(group != 5),
      .ENFORCE_TRAFFIC_POLICY(group != 6), .ENABLE_COVERAGE(1),
      .ENABLE_TRANSACTION_COVERAGE(group != 0), .ENABLE_PROTOCOL_COVERAGE(group != 1),
      .ENABLE_ERROR_COVERAGE(group != 2)) mon(bus);
    assign masked_tx_samples[group] = mon.transaction_samples;
    assign masked_proto_samples[group] = mon.protocol_samples;
    assign masked_error_samples[group] = mon.error_samples;
    assign masked_counts[group][0] = mon.protocol_errors;
    assign masked_counts[group][1] = mon.x_errors;
    assign masked_counts[group][2] = mon.alignment_errors;
    assign masked_counts[group][3] = mon.strobe_errors;
    assign masked_counts[group][4] = mon.response_errors;
    assign masked_counts[group][5] = mon.timeout_errors;
    assign masked_counts[group][6] = mon.policy_errors;
  end
  assign counts[0] = dut.protocol_errors;
  assign counts[1] = dut.x_errors;
  assign counts[2] = dut.alignment_errors;
  assign counts[3] = dut.strobe_errors;
  assign counts[4] = dut.response_errors;
  assign counts[5] = dut.timeout_errors;
  assign counts[6] = dut.policy_errors;

  axi4_protocol_monitor #(`COMMON_PARAMS, .REQUIRE_ALIGNED_ACCESS(1)) require_align(bus);
  axi4_protocol_monitor #(`COMMON_PARAMS, .REQUIRE_ALIGNED_ACCESS(1),
    .ENABLE_ALIGNMENT_CHECKS(0)) align_off(bus);
  axi4_protocol_monitor #(`COMMON_PARAMS, .SUPPORT_NARROW_BURST(0),
    .SUPPORT_UNALIGNED_ACCESS(0), .SUPPORT_BYTE_STROBE(0)) support_limit(bus);
  axi4_protocol_monitor #(`COMMON_PARAMS, .ALLOW_NARROW_BURST(0),
    .ALLOW_NARROW_SINGLE(0), .ALLOW_UNALIGNED_ACCESS(0)) traffic_limit(bus);
  axi4_protocol_monitor #(`COMMON_PARAMS, .SUPPORT_NARROW_BURST(0),
    .SUPPORT_UNALIGNED_ACCESS(0), .SUPPORT_BYTE_STROBE(0),
    .ALLOW_NARROW_BURST(0), .ALLOW_NARROW_SINGLE(0),
    .ALLOW_UNALIGNED_ACCESS(0), .ENFORCE_TRAFFIC_POLICY(0)) policy_off(bus);
  axi4_protocol_monitor #(`COMMON_PARAMS, .MAX_BURST_BEATS(8)) burst_limit(bus);
`undef COMMON_PARAMS

  task automatic check(input bit condition, input string message);
    assertions++;
    if (!condition) $fatal(1, "CHECKER_TEST_FAIL: %s", message);
  endtask

  task automatic idle();
    bus.awlock = 0; bus.awcache = 0; bus.awprot = 0;
    bus.awqos = 0; bus.awregion = 0; bus.awuser = 0;
    bus.arlock = 0; bus.arcache = 0; bus.arprot = 0;
    bus.arqos = 0; bus.arregion = 0; bus.aruser = 0;
    bus.wuser = 0; bus.buser = 0; bus.ruser = 0;
    bus.awid = 0; bus.awaddr = 0; bus.awlen = 0;
    bus.awsize = 5; bus.awburst = 1; bus.awvalid = 0; bus.awready = 0;
    bus.wdata = 0; bus.wstrb = '1; bus.wlast = 0; bus.wvalid = 0; bus.wready = 0;
    bus.bid = 0; bus.bresp = 0; bus.bvalid = 0; bus.bready = 0;
    bus.arid = 0; bus.araddr = 0; bus.arlen = 0;
    bus.arsize = 5; bus.arburst = 1; bus.arvalid = 0; bus.arready = 0;
    bus.rid = 0; bus.rdata = 0; bus.rresp = 0;
    bus.rlast = 0; bus.rvalid = 0; bus.rready = 0;
  endtask

  task automatic reset_case();
    @(negedge clk);
    resetn = 0;
    idle();
    repeat (3) @(negedge clk);
    resetn = 1;
    @(negedge clk);
    for (int category = 0; category < 7; category++) begin
      before_counts[category] = counts[category];
      for (int group = 0; group < 7; group++)
        before_masked[group][category] = masked_counts[group][category];
    end
    before_aw = dut.aw_count; before_ar = dut.ar_count; before_w = dut.w_count;
    before_b = dut.b_count; before_r = dut.r_count;
    before_alignment = require_align.alignment_errors;
    before_support = support_limit.policy_errors; before_traffic = traffic_limit.policy_errors;
  endtask

  task automatic aw(input int id, input bit[31:0] addr, input int len = 0,
      input int size = 5, input int burst = 1, input int stalls = 0);
    @(negedge clk);
    bus.awid = id; bus.awaddr = addr; bus.awlen = len;
    bus.awsize = size; bus.awburst = burst; bus.awvalid = 1; bus.awready = 0;
    repeat (stalls) @(negedge clk);
    bus.awready = 1;
    @(negedge clk);
    bus.awvalid = 0; bus.awready = 0;
  endtask

  task automatic ar(input int id, input bit[31:0] addr, input int len = 0,
      input int size = 5, input int burst = 1, input int stalls = 0);
    @(negedge clk);
    bus.arid = id; bus.araddr = addr; bus.arlen = len;
    bus.arsize = size; bus.arburst = burst; bus.arvalid = 1; bus.arready = 0;
    repeat (stalls) @(negedge clk);
    bus.arready = 1;
    @(negedge clk);
    bus.arvalid = 0; bus.arready = 0;
  endtask

  task automatic w(input bit last, input bit[31:0] strb = '1,
      input logic[255:0] data = 'h1234, input int stalls = 0);
    @(negedge clk);
    bus.wdata = data; bus.wstrb = strb; bus.wlast = last;
    bus.wvalid = 1; bus.wready = 0;
    repeat (stalls) @(negedge clk);
    bus.wready = 1;
    @(negedge clk);
    bus.wvalid = 0; bus.wready = 0;
  endtask

  task automatic b(input int id, input int resp = 0, input int stalls = 0);
    @(negedge clk);
    bus.bid = id; bus.bresp = resp; bus.bvalid = 1; bus.bready = 0;
    repeat (stalls) @(negedge clk);
    bus.bready = 1;
    @(negedge clk);
    bus.bvalid = 0; bus.bready = 0;
  endtask

  task automatic r(input int id, input bit last, input int resp = 0,
      input logic[255:0] data = 'h5678, input int stalls = 0);
    @(negedge clk);
    bus.rid = id; bus.rdata = data; bus.rresp = resp; bus.rlast = last;
    bus.rvalid = 1; bus.rready = 0;
    repeat (stalls) @(negedge clk);
    bus.rready = 1;
    @(negedge clk);
    bus.rvalid = 0; bus.rready = 0;
  endtask

  task automatic verify(input string name, input int error_category = -1);
    @(negedge clk);
    if (error_category < 0) begin
      for (int category = 0; category < 7; category++)
        check(counts[category] == before_counts[category],
          $sformatf("%s: legal traffic category %0d errors=%0d", name, category,
            counts[category] - before_counts[category]));
    end else begin
      check(counts[error_category] > before_counts[error_category], $sformatf("%s: expected category %0d error", name, error_category));
    end
    check(all_off.error_count() == 0, {name, ": all-off monitor reported errors"});
    check(policy_off.policy_errors == 0, {name, ": disabled traffic policy reported errors"});
    for (int group = 0; group < 7; group++) begin
      for (int category = 0; category < 7; category++) begin
        if (group == category)
          check(masked_counts[group][category] == 0,
            $sformatf("%s: disabled checker %0d reported an error", name, group));
        else
          check(masked_counts[group][category] - before_masked[group][category] ==
            counts[category] - before_counts[category],
            $sformatf("%s: disabling %0d changed checker %0d (%0d vs %0d)",
              name, group, category, masked_counts[group][category], counts[category]));
      end
    end
    scenarios++;
    $display("CHECKER_CASE_PASS %s errors p/x/a/s/r/t/policy=%0d/%0d/%0d/%0d/%0d/%0d/%0d",
      name, counts[0]-before_counts[0], counts[1]-before_counts[1], counts[2]-before_counts[2],
      counts[3]-before_counts[3], counts[4]-before_counts[4], counts[5]-before_counts[5],
      counts[6]-before_counts[6]);
  endtask

  initial begin
    idle();
    reset_case();
    // Idle payload is allowed to be X when VALID is low.
    bus.awaddr = 'x; bus.araddr = 'x; bus.wdata = 'x; bus.rdata = 'x;
    repeat (4) @(negedge clk);
    verify("idle_x_is_ignored");

    reset_case();
    for (int id = 0; id < 128; id++) ar(id, 'h10000 + id * 32);
    check(dut.current_reads == 128 && dut.max_reads_seen == 128, "128 read outstanding reached");
    for (int id = 127; id >= 0; id--) r(id, 1);
    check(dut.current_reads == 0 && dut.ar_count-before_ar == 128 && dut.r_count-before_r == 128, "128 reads drained exactly");
    verify("read_128_cross_id_reverse_completion");

    reset_case();
    for (int id = 0; id < 128; id++) begin
      aw(id, 'h20000 + id * 32); w(1);
    end
    check(dut.current_writes == 128 && dut.max_writes_seen == 128, "128 write outstanding reached");
    for (int id = 127; id >= 0; id--) b(id);
    check(dut.current_writes == 0 && dut.aw_count-before_aw == 128 && dut.w_count-before_w == 128 && dut.b_count-before_b == 128,
      "128 writes drained exactly");
    verify("write_128_cross_id_reverse_completion");

    reset_case();
    for (int id = 0; id < 64; id++) begin
      aw(id, 'h30000 + id * 32); w(1); ar(id + 128, 'h40000 + id * 32);
    end
    check(dut.current_reads == 64 && dut.current_writes == 64 && dut.max_total_seen == 128,
      "64 read plus 64 write total 128 reached");
    for (int id = 63; id >= 0; id--) begin r(id + 128, 1); b(id); end
    verify("mixed_128_outstanding");

    reset_case();
    // Distinct lengths make same-ID FIFO selection externally observable.
    ar(255, 'h50000, 1); ar(255, 'h50100, 3); ar(7, 'h50200, 0);
    r(255, 0); r(7, 1); r(255, 1);
    for (int beat = 0; beat < 4; beat++) r(255, beat == 3);
    aw(255, 'h60000, 1); aw(255, 'h60100, 3);
    w(0); w(1); for (int beat = 0; beat < 4; beat++) w(beat == 3);
    b(255); b(255);
    verify("same_id_fifo_and_read_interleave");

    reset_case();
    // AXI permits W before AW; pairing still follows AW/W stream order.
    w(0); w(1); aw(9, 'h70000, 1); b(9);
    verify("w_before_aw");

    reset_case();
    aw(20, 'h80000, 15, 5, 1, 3);
    for (int beat = 0; beat < 16; beat++) w(beat == 15, (beat == 4) ? 0 : '1, beat, beat % 4);
    b(20, 0, 4);
    ar(21, 'h80100, 15, 5, 1, 3);
    for (int beat = 0; beat < 16; beat++) r(21, beat == 15, 0, beat, beat % 3);
    check(dut.aw_count-before_aw == 1 && dut.w_count-before_w == 16 && dut.b_count-before_b == 1 &&
      dut.ar_count-before_ar == 1 && dut.r_count-before_r == 16, "stable stalls create no duplicate handshakes");
    verify("full_len16_and_all_channel_stalls");
    check(burst_limit.policy_errors > 0, "configured 8 beat maximum rejects a 16 beat burst");
    check(support_limit.policy_errors > before_support, "partial/zero WSTRB capability enforced");

    reset_case();
    // Disabled optional field storage and unselected data bytes may remain X.
    // Payload is held unchanged across stalls, including unused data lanes.
    bus.awqos = 'x; bus.awregion = 'x; bus.awuser = 'x;
    bus.arqos = 'x; bus.arregion = 'x; bus.aruser = 'x;
    bus.wuser = 'x; bus.buser = 'x; bus.ruser = 'x;
    lane_data = 'x; lane_data[31:24] = 'ha5;
    aw(30, 'h90003, 0, 2, 1, 2); w(1, 'h8, lane_data, 3); b(30, 0, 2);
    ar(30, 'h91003, 0, 2, 1, 2); r(30, 1, 0, lane_data, 3);
    aw(30, 'h92000); w(1, 0, 'x, 2); b(30);
    verify("legal_unused_data_lanes_and_absent_sidebands_x");

    reset_case();
    // INCR first unaligned transfer uses only the bytes up to its aligned end.
    aw(31, 'h90003, 1, 2); w(0, 'h00000008); w(1, 'h000000f0); b(31);
    ar(31, 'h91003, 1, 2); r(31, 0); r(31, 1);
    verify("legal_unaligned_narrow_incr");
    check(require_align.alignment_errors > before_alignment, "explicit alignment requirement detects unaligned addresses");
    check(align_off.alignment_errors == 0, "disabled alignment checker suppresses explicit requirement");
    check(support_limit.policy_errors > before_support, "unsupported narrow/unaligned traffic detected");
    check(traffic_limit.policy_errors > before_traffic, "forbidden narrow/unaligned traffic detected independently");

    reset_case();
    aw(32, 'h92000, 0, 2); w(1, 'h0000000f); b(32);
    verify("legal_narrow_single");
    check(traffic_limit.policy_errors > before_traffic, "ALLOW_NARROW_SINGLE=0 enforced");

    reset_case();
    // A transfer ending exactly at 4KB is legal, including an unaligned start.
    aw(33, 'h00000fff, 0, 5); w(1, 'h80000000); b(33);
    ar(34, 'h00000fe0, 0, 5); r(34, 1);
    verify("legal_4kb_exact_end_unaligned");

    reset_case();
    aw(40, 'ha0000); w(1); b(40, 2);
    ar(41, 'ha1000); r(41, 1, 3);
    verify("slave_error_responses", 4);

    reset_case(); aw(1, 'hfe0, 1); verify("write_4kb_crossing", 0);
    reset_case(); ar(1, 'hfe0, 1); verify("read_4kb_crossing", 0);
    reset_case();
    @(negedge clk); bus.awaddr = 'hfe0; bus.awlen = 1; bus.awvalid = 1;
    repeat (2) @(negedge clk);
    verify("write_4kb_checked_before_ready", 0);
    reset_case();
    @(negedge clk); bus.araddr = 'hfe0; bus.arlen = 1; bus.arvalid = 1;
    repeat (2) @(negedge clk);
    verify("read_4kb_checked_before_ready", 0);
    reset_case();
    @(negedge clk); bus.awsize = 6; bus.awvalid = 1;
    repeat (2) @(negedge clk);
    verify("write_size_checked_before_ready", 0);
    reset_case();
    @(negedge clk); bus.arsize = 6; bus.arvalid = 1;
    repeat (2) @(negedge clk);
    verify("read_size_checked_before_ready", 0);
    reset_case(); aw(1, 'hb0000, 0, 6); verify("oversize_aw", 0);
    reset_case(); ar(1, 'hb0000, 0, 6); verify("oversize_ar", 0);
    reset_case(); aw(1, 'hb0000, 0, 5, 3); verify("reserved_awburst", 0);
    reset_case(); ar(1, 'hb0000, 0, 5, 3); verify("reserved_arburst", 0);

    reset_case(); aw(1, 'hb0000, 1); w(1); verify("early_wlast", 0);
    reset_case(); aw(1, 'hb0000); w(0); verify("missing_wlast", 0);
    reset_case(); ar(1, 'hb0000, 1); r(1, 1); verify("early_rlast", 0);
    reset_case(); ar(1, 'hb0000); r(1, 0); verify("missing_rlast", 0);

    reset_case();
    aw(1, 'hc0000, 1, 2); w(0, 'h0000000f); w(1, 'h0000000f);
    verify("second_beat_wrong_strobe_lane", 3);
    reset_case(); aw(1, 'hc0003, 0, 2); w(1, 'h0000000f);
    verify("unaligned_first_strobe_before_address", 3);
    reset_case(); aw(1, 'hc0000, 0, 2);
    @(negedge clk); bus.wstrb = 'hf0; bus.wlast = 1; bus.wvalid = 1;
    repeat (2) @(negedge clk);
    verify("strobe_checked_before_wready", 3);
    reset_case(); aw(1, 'hc0000, 1);
    @(negedge clk); bus.wlast = 1; bus.wvalid = 1;
    repeat (2) @(negedge clk);
    verify("wlast_checked_before_wready", 0);

    reset_case(); b(77); verify("bid_without_aw", 4);
    reset_case(); r(77, 1); verify("rid_without_ar", 4);
    reset_case(); aw(1, 'hd0000); b(1); verify("b_before_write_data", 4);
    reset_case(); aw(1, 'hd0000, 1); w(0); b(1); verify("b_before_final_write_beat", 4);
    reset_case(); aw(1, 'hd0000); w(1); b(2); verify("unknown_bid_with_write_pending", 4);
    reset_case(); ar(1, 'hd0000); r(2, 1); verify("unknown_rid_with_read_pending", 4);

    reset_case();
    ar(1, 'he0000, 1); ar(1, 'he0100, 0); r(1, 1);
    verify("same_id_second_read_cannot_bypass_first", 0);

    reset_case();
    @(negedge clk); bus.arid = 1; bus.araddr = 'he0000; bus.arvalid = 1; bus.arready = 1;
    bus.rid = 1; bus.rlast = 1; bus.rvalid = 1; bus.rready = 1;
    @(negedge clk); bus.arvalid = 0; bus.rvalid = 0;
    verify("r_cannot_depend_on_same_edge_ar", 4);

    reset_case(); aw(1, 'he0000);
    @(negedge clk); bus.wlast = 1; bus.wvalid = 1; bus.wready = 1;
    bus.bid = 1; bus.bvalid = 1; bus.bready = 1;
    @(negedge clk); bus.wvalid = 0; bus.bvalid = 0;
    verify("b_cannot_depend_on_same_edge_wlast", 4);

    // Stability requires the entire VALID payload to survive the handshake edge.
    for (int channel = 0; channel < 5; channel++) begin
      reset_case();
      if (channel == 3) begin aw(1, 'hf0000); w(1); end
      if (channel == 4) ar(1, 'hf0000);
      @(negedge clk);
      case (channel)
        0: begin bus.awvalid = 1; bus.awaddr = 'hf0000; end
        1: begin bus.arvalid = 1; bus.araddr = 'hf0000; end
        2: begin bus.wvalid = 1; bus.wdata = 1; end
        3: begin bus.bvalid = 1; bus.bid = 1; end
        4: begin bus.rvalid = 1; bus.rid = 1; bus.rlast = 1; bus.rdata = 1; end
      endcase
      @(negedge clk);
      case (channel)
        0: begin bus.awaddr = 'hf0020; bus.awready = 1; end
        1: begin bus.araddr = 'hf0020; bus.arready = 1; end
        2: begin bus.wdata = 2; bus.wready = 1; end
        3: begin bus.bresp = 2; bus.bready = 1; end
        4: begin bus.rdata = 2; bus.rready = 1; end
      endcase
      @(negedge clk); idle();
      verify($sformatf("payload_change_on_handshake_channel_%0d", channel), 0);
    end

    reset_case();
    @(negedge clk); bus.awvalid = 1;
    @(negedge clk); bus.awvalid = 0;
    verify("valid_withdrawn_under_backpressure", 0);

    reset_case();
    @(negedge clk); bus.awvalid = 1; bus.awaddr = 'x;
    @(negedge clk);
    verify("x_aw_payload_while_valid", 1);
    reset_case();
    @(negedge clk); bus.wvalid = 1; bus.wstrb = 'x;
    @(negedge clk);
    verify("x_wstrb_while_valid", 1);
    reset_case();
    @(negedge clk); bus.rvalid = 1; bus.rid = 'x;
    @(negedge clk);
    verify("x_rid_while_valid", 1);
    reset_case(); aw(1, 'hf0000); w(1, '1, 'x);
    verify("x_selected_wdata_lane", 1);
    reset_case(); ar(1, 'hf0000); r(1, 1, 0, 'x);
    verify("x_selected_rdata_lane", 1);
    reset_case();
    @(negedge clk); bus.awvalid = 'x;
    repeat (2) @(negedge clk);
    verify("x_valid_control", 1);

    reset_case();
    for (int id = 0; id < 129; id++) ar(id, 'h100000 + id * 32);
    verify("read_outstanding_129", 6);
    reset_case();
    for (int id = 0; id < 129; id++) aw(id, 'h110000 + id * 32);
    verify("write_outstanding_129", 6);
    reset_case();
    for (int id = 0; id < 64; id++) begin aw(id, 'h120000 + id * 32); ar(id, 'h130000 + id * 32); end
    ar(200, 'h140000);
    verify("total_outstanding_129", 6);

    reset_case(); ar(1, 'h150000);
    repeat (TIMEOUT + 4) @(negedge clk);
    verify("read_inactivity_timeout", 5);
    reset_case(); aw(1, 'h150000); w(1);
    repeat (TIMEOUT + 4) @(negedge clk);
    verify("write_inactivity_timeout", 5);
    reset_case();
    @(negedge clk); bus.awvalid = 1;
    repeat (TIMEOUT + 4) @(negedge clk);
    verify("ready_timeout", 5);
    reset_case(); w(1);
    repeat (TIMEOUT + 4) @(negedge clk);
    verify("w_without_eventual_aw_timeout", 5);
    reset_case(); w(1); w(1);
    repeat (TIMEOUT + 4) @(negedge clk);
    check(dut.timeout_errors-before_counts[5] == 1, "first unpaired W timeout reported once");
    // Pair only the first cached W. The queue never empties, so the second
    // pending W must become eligible for its own timeout report.
    aw(1, 'h150000); b(1);
    repeat (4) @(negedge clk);
    check(dut.timeout_errors-before_counts[5] == 2, "next unpaired W timeout rearmed after partial pairing");
    verify("unpaired_w_timeout_rearms_after_partial_pairing", 5);

    reset_case(); ar(1, 'h160000, 2);
    repeat (TIMEOUT / 2) @(negedge clk); r(1, 0);
    repeat (TIMEOUT / 2) @(negedge clk); r(1, 0);
    repeat (TIMEOUT / 2) @(negedge clk); r(1, 1);
    verify("read_progress_refreshes_timeout");

    reset_case(); aw(1, 'h170000, 2);
    repeat (TIMEOUT / 2) @(negedge clk); w(0);
    repeat (TIMEOUT / 2) @(negedge clk); w(0);
    repeat (TIMEOUT / 2) @(negedge clk); w(1); b(1);
    verify("write_progress_refreshes_timeout");

    reset_case(); aw(1, 'h180000); ar(1, 'h190000);
    reset_case();
    check(dut.current_reads == 0 && dut.current_writes == 0,
      "reset clears in-flight state while cumulative evidence survives");
    aw(1, 'h180000); w(1); b(1); ar(1, 'h190000); r(1, 1);
    verify("reset_flush_and_id_reuse");

    check(dut.transaction_samples > 0 && dut.protocol_samples > 0 && dut.error_samples > 0,
      "all enabled coverage groups sampled");
    check(all_off.transaction_samples == 0 && all_off.protocol_samples == 0 && all_off.error_samples == 0,
      "coverage global disable suppresses every group");
    check(masked_tx_samples[0] == 0 && masked_proto_samples[0] > 0 && masked_error_samples[0] > 0,
      "transaction coverage disable is independent");
    check(masked_proto_samples[1] == 0 && masked_tx_samples[1] > 0 && masked_error_samples[1] > 0,
      "protocol coverage disable is independent");
    check(masked_error_samples[2] == 0 && masked_tx_samples[2] > 0 && masked_proto_samples[2] > 0,
      "error coverage disable is independent");
    check(dut.length_hits[1] > 0 && dut.length_hits[2] > 0 && dut.length_hits[4] > 0 && dut.length_hits[16] > 0,
      "burst length coverage contains 1/2/4/16 beats");
    check(dut.id_hits[0] > 0 && dut.id_hits[255] > 0, "8 bit ID boundary coverage");
    for (int channel = 0; channel < 5; channel++)
      check(dut.stall_cycles[channel] > 0, $sformatf("channel %0d backpressure covered", channel));
    check(dut.response_hits[0] > 0 && dut.response_hits[2] > 0 && dut.response_hits[3] > 0,
      "OKAY/SLVERR/DECERR response coverage");
    for (int boundary = 0; boundary < 4; boundary++)
      check(dut.depth_hits[boundary] > 0, $sformatf("depth boundary index %0d covered", boundary));
    $display("CHECKER_REGRESSION_PASS scenarios=%0d assertions=%0d", scenarios, assertions);
    $finish;
  end

  // Integration may perform the nonblocking end-of-simulation check in final.
  final begin
    dut.check_quiescent();
    $display("CHECKER_FINAL_FUNCTION_PASS");
  end

  initial begin
    #100000;
    $fatal(1, "CHECKER_TEST_FAIL: testbench watchdog");
  end
endmodule
