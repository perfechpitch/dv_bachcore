`timescale 1ns/1ps
// Independent measurement semantics test, not a VIP performance result.
module monitor_unit_top;
  bit aclk = 0, resetn = 0, measure = 0;
  real period_ns = 1.0;
  always #0.5 aclk = ~aclk;
  axi4_if #(32, 256, 8) bus(aclk, resetn);
  axi4_perf_monitor mon(bus, measure, period_ns);
  initial begin
    $dumpfile("monitor_unit.vcd");
    $dumpvars(0, monitor_unit_top);
    bus.awvalid = 0; bus.awready = 1; bus.awsize = 5; bus.awburst = 1;
    bus.arvalid = 0; bus.arready = 1; bus.arsize = 5; bus.arburst = 1;
    bus.wvalid = 0; bus.wready = 0; bus.wstrb = '1;
    bus.rvalid = 0; bus.rready = 1; bus.rresp = 0; bus.rlast = 0;
    bus.bvalid = 0; bus.bready = 1; bus.bresp = 0;
    @(negedge aclk); resetn = 1;
    @(negedge aclk); measure = 1; bus.awvalid = 1; bus.arvalid = 1;
    @(negedge aclk); bus.awvalid = 0; bus.arvalid = 0; bus.wvalid = 1;
    repeat (2) @(negedge aclk); // VALID without READY must contribute zero bytes.
    bus.wready = 1; bus.rvalid = 1;
    @(negedge aclk); bus.wstrb = 32'h0000ffff; bus.rlast = 1;
    @(negedge aclk); bus.wvalid = 0; bus.rvalid = 0; bus.bvalid = 1;
    @(negedge aclk); bus.bvalid = 0;
    repeat (4) @(negedge aclk);
    measure = 0;
    if (mon.cycles != 10 || mon.write_bytes != 48 || mon.read_bytes != 64 ||
        mon.aw_count != 1 || mon.ar_count != 1 || mon.b_count != 1 ||
        mon.rlast_count != 1 || mon.w_stalls != 2 || mon.inflight_w != 0 ||
        mon.inflight_r != 0 || mon.measured_period_ns != 1.0)
      $fatal(1, "MONITOR_UNIT mismatch cycles=%0d w=%0d r=%0d stalls=%0d",
             mon.cycles, mon.write_bytes, mon.read_bytes, mon.w_stalls);
    $display("MONITOR_UNIT_PASS cycles=10 elapsed_ns=10 write_bytes=48 read_bytes=64 write_GBps=4.8 read_GBps=6.4 total_GBps=11.2");
    $finish;
  end
endmodule
