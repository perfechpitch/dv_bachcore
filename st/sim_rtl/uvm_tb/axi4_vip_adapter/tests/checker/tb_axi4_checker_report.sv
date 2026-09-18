`timescale 1ns/1ps
// Deliberately fatal smoke: proves diagnostics reach the simulator, separately
// from the expected-error counter regression. The runner expects the precise
// fatal diagnostic; VCS may still return a zero process exit status.
module tb_axi4_checker_report;
  bit clk = 0;
  bit resetn = 0;
  always #0.5 clk = ~clk;
  axi4_if #(.ADDR_WIDTH(32), .DATA_WIDTH(256), .ID_WIDTH(8), .LEN_WIDTH(4)) bus(clk, resetn);
  axi4_protocol_monitor #(.REPORT_ERRORS(1), .FATAL_ON_ERROR(1)) dut(bus);
  initial begin
    bus.awvalid = 0; bus.awready = 0;
    bus.wvalid = 0; bus.wready = 0;
    bus.arvalid = 0; bus.arready = 0;
    bus.rvalid = 0; bus.rready = 0;
    bus.bvalid = 0; bus.bready = 0;
    bus.bid = 7; bus.bresp = 0; bus.buser = 0;
    repeat (3) @(negedge clk);
    resetn = 1;
    @(negedge clk);
    // BID has no corresponding request. READY remains low: VALID suffices.
    bus.bvalid = 1;
    repeat (3) @(negedge clk);
    $fatal(1, "CHECKER_REPORT_SMOKE_MISSING_EXPECTED_ERROR");
  end
endmodule
