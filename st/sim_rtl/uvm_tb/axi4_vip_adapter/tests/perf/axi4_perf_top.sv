`timescale 1ns/1ps
`include "axi4_perf_sequence.svh"

module axi4_perf_top;
  import uvm_pkg::*;
  import axi4_vip_adapter_pkg::*;
  import simple_axi4_bfm_adapter_pkg::*;
  import axi4_perf_sequence_pkg::*;

  bit aclk = 0, aresetn = 0, measure = 0;
  real period_ns = 1.0;
  int unsigned throttle_period = 0, throttle_open = 0;
  int warmup = 1024, window_cycles = 4096, half_strb = 0;
  string mode = "mixed";
  realtime window_start, window_end;
  bit initialized = 0, stream_done = 0;
  simple_axi4_bfm_adapter adapter;
  axi4_adapter_sequencer sequencer;
  axi4_perf_sequence stream;
  uvm_report_server reports;

  axi4_if #(
    .ADDR_WIDTH(AXI_ADDR_WIDTH), .DATA_WIDTH(AXI_DATA_WIDTH), .ID_WIDTH(AXI_ID_WIDTH),
    .LEN_WIDTH(AXI_LEN_WIDTH), .QOS_WIDTH(AXI_QOS_WIDTH), .REGION_WIDTH(AXI_REGION_WIDTH),
    .AWUSER_WIDTH(AXI_AWUSER_WIDTH), .ARUSER_WIDTH(AXI_ARUSER_WIDTH),
    .WUSER_WIDTH(AXI_WUSER_WIDTH), .RUSER_WIDTH(AXI_RUSER_WIDTH), .BUSER_WIDTH(AXI_BUSER_WIDTH)
  ) axi_vif(aclk, aresetn);
  axi4_perf_slave #(.CHECK_WRITE_PATTERN(1))
    slave(axi_vif, throttle_period, throttle_open, , , , , );
  axi4_perf_monitor mon(axi_vif, measure, period_ns);

`ifdef AXI_PERF_CHECKER
  // Feature07 supplies feature05 sources in the combined regression filelist.
  axi4_protocol_monitor #(
    .ADDR_WIDTH(32), .DATA_WIDTH(256), .ID_WIDTH(8), .LEN_WIDTH(4),
    .MAX_BURST_BEATS(16), .MAX_OUTSTANDING_READS(128),
    .MAX_OUTSTANDING_WRITES(128), .MAX_OUTSTANDING_TOTAL(128),
    .READ_TIMEOUT_CYCLES(100000), .WRITE_TIMEOUT_CYCLES(100000),
    .READY_TIMEOUT_CYCLES(100000),
    .SUPPORT_NARROW_BURST(0), .ALLOW_UNALIGNED_ACCESS(0),
    .ENABLE_COVERAGE(1), .ENABLE_TRANSACTION_COVERAGE(1),
    .ENABLE_PROTOCOL_COVERAGE(1), .ENABLE_ERROR_COVERAGE(1)
  ) protocol_mon(axi_vif);
`endif

  initial begin : clock_and_config
    string period_arg, trailing_arg, wave;
    real half_period_ns, rounding_error;
    if ($test$plusargs("AXI_CLK_PERIOD_NS")) begin
      if (!$value$plusargs("AXI_CLK_PERIOD_NS=%s", period_arg) ||
          $sscanf(period_arg, "%f%s", period_ns, trailing_arg) != 1)
        $fatal(1, "AXI_CLK_PERIOD_NS must be a numeric period in ns");
    end
    if (!(period_ns > 0.0) || !(period_ns < real'(64'hffff_ffff_ffff_ffff) * 1ps))
      $fatal(1, "Invalid AXI_CLK_PERIOD_NS");
    half_period_ns = $floor(period_ns / (2.0 * 1ps) + 0.5) * 1ps;
    rounding_error = half_period_ns * 2.0 - period_ns;
    if (!(half_period_ns >= 1ps) ||
        !(rounding_error >= -1e-9 && rounding_error <= 1e-9))
      $fatal(1, "Clock period not representable at 1ps precision");
    void'($value$plusargs("PERF_MODE=%s", mode));
    void'($value$plusargs("PERF_WARMUP=%d", warmup));
    void'($value$plusargs("PERF_CYCLES=%d", window_cycles));
    void'($value$plusargs("PERF_THROTTLE_PERIOD=%d", throttle_period));
    void'($value$plusargs("PERF_THROTTLE_OPEN=%d", throttle_open));
    void'($value$plusargs("PERF_HALF_STRB=%d", half_strb));
    if (warmup < 512 || window_cycles < 1024 ||
        !(mode == "read" || mode == "write" || mode == "mixed") ||
        !(half_strb == 0 || half_strb == 1) ||
        (throttle_period != 0 && (throttle_open == 0 || throttle_open > throttle_period)))
      $fatal(1, "Invalid performance run arguments");
    if (AXI_DATA_WIDTH != 256 || AXI_ADDR_WIDTH != 32 || AXI_ID_WIDTH != 8 ||
        AXI_LEN_WIDTH != 4 || AXI_MAX_OUTSTANDING_TOTAL != 128)
      $fatal(1, "Compile performance top with tests/perf/perf_profile.json");
    if ($value$plusargs("PERF_VCD=%s", wave)) begin
      $dumpfile(wave);
      // VCS does not support selective interface VCD dumping.
      $dumpvars(0, axi4_perf_top);
    end
    forever #(half_period_ns) aclk = ~aclk;
  end

  initial begin
    repeat (8) @(negedge aclk);
    aresetn = 1;
  end

  initial begin
    uvm_config_db#(axi4_vif_t)::set(null, "*", "axi_vif", axi_vif);
    adapter = new("perf_adapter");
    sequencer = new("perf_sequencer", null);
    sequencer.adapter = adapter;
    adapter.init();
    wait (aresetn === 1'b1);
    @(negedge aclk);
    stream = new("perf_sequence");
    stream.mode = mode;
    stream.half_strb = half_strb;
    initialized = 1;
    stream.start(sequencer);
    stream_done = 1;
  end

  initial begin : measure_and_check
    real elapsed_ns, wr_gbps, rd_gbps;
    wait (initialized);
    repeat (warmup) @(negedge aclk);
    // Exactly N rising edges lie in this half-open, negedge-aligned interval.
    window_start = $realtime;
    measure = 1;
    repeat (window_cycles) @(negedge aclk);
    measure = 0;
    window_end = $realtime;
    stream.stop_requested = 1;
    wait (stream_done);
    repeat (2) @(negedge aclk);
    elapsed_ns = window_end - window_start;
    if (mon.cycles != window_cycles ||
        elapsed_ns - period_ns * window_cycles > 0.0001 ||
        period_ns * window_cycles - elapsed_ns > 0.0001)
      $fatal(1, "Measurement window/clock mismatch");
    if (mon.inflight_w || mon.inflight_r || mon.peak_total != 128 ||
        mon.all_aw != stream.submitted_writes || mon.all_ar != stream.submitted_reads ||
        mon.all_b != mon.all_aw || mon.all_rlast != mon.all_ar ||
        mon.all_write_bytes != stream.expected_write_bytes ||
        mon.all_read_bytes != stream.expected_read_bytes)
      $fatal(1, "Final payload/address/completion reconciliation failed");
    if ((mode == "write" && stream.submitted_reads != 0) ||
        (mode == "read" && stream.submitted_writes != 0))
      $fatal(1, "Unexpected traffic direction");
    reports = uvm_report_server::get_server();
    if (reports.get_severity_count(UVM_ERROR) || reports.get_severity_count(UVM_FATAL))
      $fatal(1, "VIP reported an error during performance test");
`ifdef AXI_PERF_CHECKER
    protocol_mon.check_quiescent();
    if (protocol_mon.error_count()) $fatal(1, "Protocol monitor reported errors");
`endif
    // Decimal GB/s: bytes / (ns * 1e-9) / 1e9 == bytes/ns.
    wr_gbps = real'(mon.write_bytes) / elapsed_ns;
    rd_gbps = real'(mon.read_bytes) / elapsed_ns;
    $display("PERF_PROFILE DATA=256 ADDR=32 ID=8 LEN=4 INCR beats=16 size=5 max_total=128 mode=%s half_strb=%0d throttle=%0d/%0d warmup=%0d",
             mode, half_strb, throttle_open, throttle_period, warmup);
    $display("PERF_RESULT {\"period_ns\":%0.6f,\"elapsed_ns\":%0.6f,\"cycles\":%0d,\"write_bytes\":%0d,\"read_bytes\":%0d,\"aw_count\":%0d,\"ar_count\":%0d,\"b_count\":%0d,\"rlast_count\":%0d,\"w_beats\":%0d,\"r_beats\":%0d,\"w_stalls\":%0d,\"r_stalls\":%0d,\"write_gbps\":%0.6f,\"read_gbps\":%0.6f,\"total_gbps\":%0.6f,\"peak_total\":%0d,\"peak_read\":%0d,\"peak_write\":%0d}",
             mon.measured_period_ns, elapsed_ns, mon.cycles, mon.write_bytes, mon.read_bytes,
             mon.aw_count, mon.ar_count, mon.b_count, mon.rlast_count,
             mon.w_beats, mon.r_beats, mon.w_stalls, mon.r_stalls,
             wr_gbps, rd_gbps, wr_gbps + rd_gbps, mon.peak_total, mon.peak_r, mon.peak_w);
    $display("PERF_DRAIN writes=%0d reads=%0d write_bytes=%0d read_bytes=%0d",
             mon.all_b, mon.all_rlast, mon.all_write_bytes, mon.all_read_bytes);
    $display("PERF_PASS controlled VIP endpoint only; actual NoC not tested");
    $finish;
  end

  initial begin
    #10ms;
    $fatal(1, "Performance test watchdog expired");
  end
endmodule
