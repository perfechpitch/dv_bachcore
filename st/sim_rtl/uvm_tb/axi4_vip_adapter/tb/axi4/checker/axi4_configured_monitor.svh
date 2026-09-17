// Include inside a normal-completion top importing cfg/adapter packages and
// containing axi_vif. Capability parameters intentionally do not map legacy
// support.fixed_burst=true: this implementation only produces normal INCR.
axi4_protocol_monitor #(
  .ADDR_WIDTH(AXI_ADDR_WIDTH), .DATA_WIDTH(AXI_DATA_WIDTH),
  .ID_WIDTH(AXI_ID_WIDTH), .LEN_WIDTH(AXI_LEN_WIDTH),
  .MAX_BURST_BEATS(AXI_MAX_BURST_LEN),
  .MAX_OUTSTANDING_READS(AXI_MAX_OUTSTANDING_READS),
  .MAX_OUTSTANDING_WRITES(AXI_MAX_OUTSTANDING_WRITES),
  .MAX_OUTSTANDING_TOTAL(AXI_MAX_OUTSTANDING_TOTAL),
  .READ_TIMEOUT_CYCLES(AXI_READ_TIMEOUT_CYCLES),
  .WRITE_TIMEOUT_CYCLES(AXI_WRITE_TIMEOUT_CYCLES),
  .READY_TIMEOUT_CYCLES(AXI_READY_TIMEOUT_CYCLES),
  .ENABLE_PROTOCOL_CHECKS(VIP_ENABLE_PROTOCOL_CHECKS),
  .ENABLE_X_CHECKS(VIP_ENABLE_X_CHECKS),
  .ENABLE_ALIGNMENT_CHECKS(VIP_ENABLE_ALIGNMENT_CHECKS),
  .ENABLE_STROBE_CHECKS(VIP_ENABLE_STROBE_CHECKS),
  .ENABLE_RESPONSE_CHECKS(VIP_ENABLE_RESPONSE_CHECKS),
  .ENABLE_TIMEOUT_CHECKS(VIP_ENABLE_TIMEOUT_CHECKS),
  .SUPPORT_INCREMENTING_BURST(VIP_SUPPORT_INCREMENTING_BURST),
  .SUPPORT_NARROW_BURST(VIP_SUPPORT_NARROW_BURST),
  .SUPPORT_UNALIGNED_ACCESS(VIP_SUPPORT_UNALIGNED_ACCESS),
  .SUPPORT_BYTE_STROBE(VIP_SUPPORT_BYTE_STROBE),
  .ENABLE_COVERAGE(VIP_ENABLE_COVERAGE),
  .ENABLE_TRANSACTION_COVERAGE(VIP_ENABLE_TRANSACTION_COVERAGE),
  .ENABLE_PROTOCOL_COVERAGE(VIP_ENABLE_PROTOCOL_COVERAGE),
  .ENABLE_ERROR_COVERAGE(VIP_ENABLE_ERROR_COVERAGE)
) protocol_mon(axi_vif);

final begin
  protocol_mon.check_quiescent();
  $display("AXI_CHECKER_SUMMARY errors=%0d AW=%0d W=%0d B=%0d AR=%0d R=%0d peak_rd=%0d peak_wr=%0d peak_total=%0d",
    protocol_mon.error_count(), protocol_mon.aw_count, protocol_mon.w_count,
    protocol_mon.b_count, protocol_mon.ar_count, protocol_mon.r_count,
    protocol_mon.max_reads_seen, protocol_mon.max_writes_seen, protocol_mon.max_total_seen);
  if (VIP_ENABLE_COVERAGE && VIP_ENABLE_TRANSACTION_COVERAGE)
    $display("AXI_COVERAGE_LENGTHS one=%0d two=%0d four=%0d sixteen=%0d",
      protocol_mon.length_hits[1], protocol_mon.length_hits[2],
      protocol_mon.length_hits[4], protocol_mon.length_hits[16]);
  if (protocol_mon.error_count()!=0) $error("AXI_CHECKER_FAILED");
  else $display("AXI_CHECKER_PASS");
end
