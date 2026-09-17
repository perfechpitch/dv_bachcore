`timescale 1ns/1ps

// Short shared budgets: READ/WRITE time only eligible response heads; READY
// also bounds accepted W awaiting AW. All stimulus changes at falling edges.
module tb_axi4_checker_progress;
  bit clk = 0, reset_n = 0;
  always #0.5 clk = ~clk;
  axi4_if #(.ADDR_WIDTH(32), .DATA_WIDTH(256), .ID_WIDTH(8), .LEN_WIDTH(4)) bus(clk, reset_n);
  axi4_protocol_monitor #(.READ_TIMEOUT_CYCLES(4), .WRITE_TIMEOUT_CYCLES(4),
    .READY_TIMEOUT_CYCLES(16), .REPORT_ERRORS(0)) dut(bus);
  axi4_protocol_monitor #(.READ_TIMEOUT_CYCLES(4), .WRITE_TIMEOUT_CYCLES(4),
    .READY_TIMEOUT_CYCLES(16), .ENABLE_TIMEOUT_CHECKS(0), .REPORT_ERRORS(0)) timeout_off(bus);
  int before_errors, before_timeouts;
  longint unsigned before_aw, before_w, before_b, before_ar, before_r;
  int scenarios = 0, assertions = 0;

  task automatic check(input bit condition, input string message);
    assertions++;
    if (!condition) $fatal(1, "CHECKER_PROGRESS_FAIL: %s", message);
  endtask

  task automatic idle();
    bus.awid = 0; bus.awaddr = 0; bus.awlen = 0; bus.awsize = 5; bus.awburst = 1;
    bus.awlock = 0; bus.awcache = 0; bus.awprot = 0; bus.awqos = 0; bus.awregion = 0; bus.awuser = 0;
    bus.awvalid = 0; bus.awready = 0;
    bus.wdata = 0; bus.wstrb = '1; bus.wlast = 0; bus.wuser = 0; bus.wvalid = 0; bus.wready = 0;
    bus.bid = 0; bus.bresp = 0; bus.buser = 0; bus.bvalid = 0; bus.bready = 0;
    bus.arid = 0; bus.araddr = 0; bus.arlen = 0; bus.arsize = 5; bus.arburst = 1;
    bus.arlock = 0; bus.arcache = 0; bus.arprot = 0; bus.arqos = 0; bus.arregion = 0; bus.aruser = 0;
    bus.arvalid = 0; bus.arready = 0;
    bus.rid = 0; bus.rdata = 0; bus.rresp = 0; bus.rlast = 0; bus.ruser = 0; bus.rvalid = 0; bus.rready = 0;
  endtask

  task automatic reset_case();
    @(negedge clk); reset_n = 0; idle();
    repeat (3) @(negedge clk);
    reset_n = 1;
    @(negedge clk);
    before_errors = dut.error_count(); before_timeouts = dut.timeout_errors;
    before_aw = dut.aw_count; before_w = dut.w_count; before_b = dut.b_count;
    before_ar = dut.ar_count; before_r = dut.r_count;
  endtask

  task automatic ar(input int id, input int addr, input int beats);
    bus.arid = id; bus.araddr = addr; bus.arlen = beats - 1;
    bus.arvalid = 1; bus.arready = 1;
    @(negedge clk); bus.arvalid = 0; bus.arready = 0;
  endtask

  task automatic aw(input int id, input int addr, input int beats);
    bus.awid = id; bus.awaddr = addr; bus.awlen = beats - 1;
    bus.awvalid = 1; bus.awready = 1;
    @(negedge clk); bus.awvalid = 0; bus.awready = 0;
  endtask

  task automatic read_stream(input int id, input int bursts, input int beats);
    for (int beat = 0; beat < bursts * beats; beat++) begin
      bus.rid = id; bus.rdata = beat; bus.rlast = beat % beats == beats - 1;
      bus.rvalid = 1; bus.rready = 1;
      @(negedge clk);
    end
    bus.rvalid = 0; bus.rready = 0;
  endtask

  task automatic write_stream(input int bursts, input int beats);
    for (int beat = 0; beat < bursts * beats; beat++) begin
      bus.wdata = beat; bus.wlast = beat % beats == beats - 1;
      bus.wvalid = 1; bus.wready = 1;
      @(negedge clk);
    end
    bus.wvalid = 0; bus.wready = 0;
  endtask

  task automatic b(input int id);
    bus.bid = id; bus.bvalid = 1; bus.bready = 1;
    @(negedge clk); bus.bvalid = 0; bus.bready = 0;
  endtask

  task automatic verify(input string name, input int expected_timeouts);
    check(dut.timeout_errors - before_timeouts == expected_timeouts,
      $sformatf("%s: expected %0d timeouts, got %0d", name, expected_timeouts,
        dut.timeout_errors - before_timeouts));
    check(dut.error_count() - before_errors == expected_timeouts,
      {name, ": diagnostic outside expected timeout category"});
    check(timeout_off.error_count() == 0, {name, ": disabling timeout changed another checker"});
    scenarios++;
    $display("CHECKER_PROGRESS_CASE_PASS %s expected_timeouts=%0d", name, expected_timeouts);
  endtask

  initial begin
    idle();
    reset_case();
    ar(7, 'h1000, 16); ar(7, 'h1400, 16);
    read_stream(7, 2, 16);
    dut.check_quiescent();
    check(dut.ar_count-before_ar == 2 && dut.r_count-before_r == 32,
      "same-ID read stream exact handshake counts");
    verify("same_id_16_plus_16_read_progress", 0);

    reset_case();
    aw(7, 'h2000, 16); aw(7, 'h2400, 16);
    fork
      write_stream(2, 16);
      begin
        // Each B follows its own WLAST; the later AW spends 16 cycles in the
        // global W queue, which is longer than the WRITE response budget.
        repeat (16) @(negedge clk); b(7);
        repeat (15) @(negedge clk); b(7);
      end
    join
    dut.check_quiescent();
    check(dut.aw_count-before_aw == 2 && dut.w_count-before_w == 32 && dut.b_count-before_b == 2,
      "queued AW continuous W/B exact handshake counts");
    verify("later_aw_waits_for_predecessor_w_progress", 0);

    reset_case();
    ar(7, 'h3000, 1); ar(7, 'h3400, 1);
    repeat (8) @(negedge clk);
    check(dut.timeout_errors-before_timeouts == 1, "only same-ID read head times out");
    read_stream(7, 1, 1);
    check(dut.timeout_errors-before_timeouts == 1, "new read head receives a fresh response budget");
    repeat (6) @(negedge clk);
    check(dut.timeout_errors-before_timeouts == 2, "promoted read head can independently time out");
    read_stream(7, 1, 1);
    dut.check_quiescent();
    verify("read_head_stall_and_successor_promotion", 2);

    reset_case();
    aw(7, 'h4000, 1); aw(7, 'h4400, 1);
    write_stream(2, 1);
    repeat (8) @(negedge clk);
    check(dut.timeout_errors-before_timeouts == 1, "only W-complete same-ID B head times out");
    b(7);
    check(dut.timeout_errors-before_timeouts == 1, "new B head receives a fresh response budget");
    repeat (6) @(negedge clk);
    check(dut.timeout_errors-before_timeouts == 2, "promoted B head can independently time out");
    b(7);
    dut.check_quiescent();
    verify("b_head_stall_and_successor_promotion", 2);

    reset_case();
    write_stream(1, 4);
    repeat (7) @(negedge clk);
    aw(7, 'h5000, 4); b(7);
    dut.check_quiescent();
    verify("w_before_aw_uses_ready_not_write_budget", 0);

    reset_case();
    write_stream(1, 1);
    repeat (6) @(negedge clk);
    check(dut.timeout_errors-before_timeouts == 0, "orphan W does not use 4-cycle WRITE response budget");
    repeat (12) @(negedge clk);
    verify("orphan_w_exceeds_16_cycle_ready_budget", 1);

    $display("CHECKER_PROGRESS_PASS scenarios=%0d assertions=%0d", scenarios, assertions);
    $finish;
  end
  initial begin #10000; $fatal(1, "CHECKER_PROGRESS_FAIL: watchdog"); end
endmodule
