// Full-width INCR performance monitor. Requests never count as payload.
`timescale 1ns/1ps
module axi4_perf_monitor #(
  parameter int DATA_WIDTH = 256
) (
  axi4_if axi,
  input bit measure,
  input real expected_period_ns
);
  localparam int BYTES = DATA_WIDTH / 8;
  longint unsigned cycles, write_bytes, read_bytes;
  longint unsigned aw_count, ar_count, b_count, rlast_count;
  longint unsigned w_beats, r_beats, w_stalls, r_stalls;
  longint unsigned all_write_bytes, all_read_bytes;
  longint unsigned all_aw, all_ar, all_b, all_rlast;
  int signed inflight_w, inflight_r;
  int unsigned peak_w, peak_r, peak_total;
  realtime previous_edge, measured_period_ns;
  bit have_edge;

  initial begin
    cycles = 0; write_bytes = 0; read_bytes = 0;
    aw_count = 0; ar_count = 0; b_count = 0; rlast_count = 0;
    w_beats = 0; r_beats = 0; w_stalls = 0; r_stalls = 0;
    all_write_bytes = 0; all_read_bytes = 0;
    all_aw = 0; all_ar = 0; all_b = 0; all_rlast = 0;
    inflight_w = 0; inflight_r = 0;
    peak_w = 0; peak_r = 0; peak_total = 0;
    have_edge = 0;
  end

  always @(posedge axi.aclk) begin
    if (have_edge) begin
      measured_period_ns = $realtime - previous_edge;
      if ((measured_period_ns - expected_period_ns > 0.0001) ||
          (expected_period_ns - measured_period_ns > 0.0001))
        $fatal(1, "PERF_CLOCK expected=%0.6fns observed=%0.6fns",
               expected_period_ns, measured_period_ns);
    end
    previous_edge = $realtime;
    have_edge = 1;
    if (axi.aresetn === 1'b1) begin
      if (measure) cycles++;
      if (axi.awvalid && axi.awready) begin
        if (axi.awsize != $clog2(BYTES) || axi.awburst != 1)
          $fatal(1, "Performance monitor requires full-width INCR writes");
        all_aw++; inflight_w++;
        if (measure) aw_count++;
      end
      if (axi.arvalid && axi.arready) begin
        if (axi.arsize != $clog2(BYTES) || axi.arburst != 1)
          $fatal(1, "Performance monitor requires full-width INCR reads");
        all_ar++; inflight_r++;
        if (measure) ar_count++;
      end
      if (axi.wvalid && axi.wready) begin
        if ($isunknown(axi.wstrb)) $fatal(1, "Unknown WSTRB at handshake");
        all_write_bytes += $countones(axi.wstrb);
        if (measure) begin
          write_bytes += $countones(axi.wstrb);
          w_beats++;
        end
      end
      if (axi.rvalid && axi.rready) begin
        if (axi.rresp !== 2'b00) $fatal(1, "Non-OKAY response in performance run");
        all_read_bytes += BYTES;
        if (measure) begin read_bytes += BYTES; r_beats++; end
        if (axi.rlast) begin
          all_rlast++; inflight_r--;
          if (measure) rlast_count++;
        end
      end
      if (axi.bvalid && axi.bready) begin
        if (axi.bresp !== 2'b00) $fatal(1, "Non-OKAY write response in performance run");
        all_b++; inflight_w--;
        if (measure) b_count++;
      end
      if (inflight_w < 0 || inflight_r < 0)
        $fatal(1, "Completion without accepted address");
      if (inflight_w > peak_w) peak_w = inflight_w;
      if (inflight_r > peak_r) peak_r = inflight_r;
      if (inflight_w + inflight_r > peak_total) peak_total = inflight_w + inflight_r;
      if (measure && axi.wvalid && !axi.wready) w_stalls++;
      if (measure && axi.rvalid && !axi.rready) r_stalls++;
    end
  end
endmodule
