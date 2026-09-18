`timescale 1ns/1ps

// Compile after controlled_slave.sv and select -top clock_reset_tb. Reset must
// release API waiters even when no further AXI clock edge can wake those tasks.
module clock_reset_tb;
  import uvm_pkg::*;
  import axi4_vip_adapter_pkg::*;
  import simple_axi4_bfm_adapter_pkg::*;
  bit clk = 0, reset_n = 0, clock_enabled = 1;
  always begin #0.5; if (clock_enabled) clk = ~clk; end
  axi4_if #(.ADDR_WIDTH(AXI_ADDR_WIDTH), .DATA_WIDTH(AXI_DATA_WIDTH),
            .ID_WIDTH(AXI_ID_WIDTH), .LEN_WIDTH(AXI_LEN_WIDTH),
            .QOS_WIDTH(AXI_QOS_WIDTH), .REGION_WIDTH(AXI_REGION_WIDTH),
            .AWUSER_WIDTH(AXI_AWUSER_WIDTH), .ARUSER_WIDTH(AXI_ARUSER_WIDTH),
            .WUSER_WIDTH(AXI_WUSER_WIDTH), .RUSER_WIDTH(AXI_RUSER_WIDTH),
            .BUSER_WIDTH(AXI_BUSER_WIDTH)) axi(clk, reset_n);
  outstanding_controlled_slave #(.ADDR_WIDTH(AXI_ADDR_WIDTH),
    .DATA_WIDTH(AXI_DATA_WIDTH), .ID_WIDTH(AXI_ID_WIDTH)) slave(axi);
  simple_axi4_bfm_adapter adapter;
  axi4_completion read_handle, write_handle;
  axi4_burst_response result;
  bit [3:0] returned;
  int unsigned paused_edges;
  uvm_report_server server;

  always @(posedge clk) if (!clock_enabled) paused_edges++;

  function automatic axi4_burst_request make_request(input bit is_write,
                                                     input int index);
    axi4_burst_request req;
    req = new(); req.id = is_write ? 2 : 1;
    req.addr = (is_write ? 'h100000 : 'h400000) + index * 512;
    req.beat_count = 4; req.size = $clog2(AXI_STRB_WIDTH);
    req.burst = 1; req.lock = 0; req.check_response = 0;
    if (is_write) begin
      req.data = new[4]; req.strb = new[4];
      foreach (req.data[i]) begin req.data[i] = i; req.strb[i] = '1; end
    end
    return req;
  endfunction

  task automatic stable_cycle();
    @(negedge clk); #1ps;
  endtask

  task automatic reset_waiter(input axi4_completion handle, input int index);
    axi4_burst_response response;
    adapter.wait_completion(handle, response);
    if (!handle.done || handle.status != AXI_COMPLETION_RESET || response == null)
      $fatal(1, "Paused-clock reset waiter %0d returned wrong result", index);
    returned[index] = 1;
  endtask

  initial begin
    int watchdog;
    int accepted_aw, accepted_ar;
    axi4_burst_request req;
    adapter = new();
    slave.check_write_pattern = 0;
    slave.independent_stalls = 1;
    slave.read_limit = 4; slave.write_limit = 4; slave.total_limit = 4;
    uvm_config_db#(axi4_vif_t)::set(null, "*", "axi_vif", axi);
    repeat (4) stable_cycle(); reset_n = 1;
    adapter.init(); adapter.configure_outstanding(4, 4, 4);
    adapter.configure_timeouts(10000, 10000, 10000);

    for (int epoch = 0; epoch < 8; epoch++) begin
      returned = 0;
      req = make_request(0, epoch); adapter.submit_read(req, read_handle);
      req = make_request(1, epoch); adapter.submit_write(req, write_handle);
      // Register waiters on both sides of intervening clock edges; all remain
      // blocked because the slave holds B/R until after the reset experiments.
      fork
        reset_waiter(read_handle, 0);
        reset_waiter(write_handle, 1);
      join_none
      watchdog = 0;
      while ((slave.live_reads != 1 || slave.live_writes != 1) && watchdog++ < 2000)
        stable_cycle();
      if (slave.live_reads != 1 || slave.live_writes != 1)
        $fatal(1, "Reset case failed to create accepted read and write");
      stable_cycle(); clock_enabled = 0;
      fork
        reset_waiter(read_handle, 2);
        reset_waiter(write_handle, 3);
      join_none
      #0.125;
      if (returned != 0) $fatal(1, "Reset waiter returned before reset");
      accepted_aw = slave.aw_count; accepted_ar = slave.ar_count;
      reset_n = 0;
      #1ns;
      if (returned !== 4'b1111 || !read_handle.done || !write_handle.done)
        $fatal(1, "Reset completion needs a stopped clock: returned=%b readDone=%b writeDone=%b",
          returned, read_handle.done, write_handle.done);
      if (paused_edges != 0 || clk !== 0 || adapter.get_outstanding_total() != 0 ||
          adapter.get_queued_reads() != 0 || adapter.get_queued_writes() != 0 ||
          axi.awvalid !== 0 || axi.wvalid !== 0 || axi.arvalid !== 0 ||
          axi.bready !== 0 || axi.rready !== 0)
        $fatal(1, "Paused-clock reset did not clear driver state/outputs");
      $display("CLOCK_RESET_EVIDENCE epoch=%0d acceptedAW=%0d acceptedAR=%0d reset_waiters=4 returned=4 paused_clock_edges=%0d",
        epoch, accepted_aw, accepted_ar, paused_edges);
      clock_enabled = 1;
      repeat (2) stable_cycle(); reset_n = 1;
      repeat (2) stable_cycle();
    end

    slave.hold_b = 0; slave.hold_r = 0;
    req = make_request(0, 20); adapter.submit_read(req, read_handle);
    req = make_request(1, 20); adapter.submit_write(req, write_handle);
    adapter.wait_completion(read_handle, result);
    if (read_handle.status != AXI_COMPLETION_OK) $fatal(1, "Read recovery failed");
    adapter.wait_completion(write_handle, result);
    if (write_handle.status != AXI_COMPLETION_OK) $fatal(1, "Write recovery failed");
    repeat (3) stable_cycle();
    if (slave.aw_count != 1 || slave.w_count != 4 || slave.b_count != 1 ||
        slave.ar_count != 1 || slave.r_count != 4 || slave.rlast_count != 1 ||
        adapter.get_outstanding_total() != 0)
      $fatal(1, "Paused-clock reset recovery handshake counts failed");
    server = uvm_report_server::get_server();
    if (server.get_severity_count(UVM_ERROR) != 0 || server.get_severity_count(UVM_FATAL) != 0)
      $fatal(1, "Unexpected report in paused-clock reset regression");
    $display("CLOCK_RESET_REGRESSION_PASS epochs=8 reset_waiter_returns=32 recoveryAW=1 recoveryW=4 recoveryB=1 recoveryAR=1 recoveryR=4");
    $finish;
  end
  initial begin #50000; $fatal(1, "Paused-clock reset regression watchdog"); end
endmodule
