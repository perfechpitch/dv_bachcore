`timescale 1ns/1ps
// Unsupported advertised capability must fail during initialization.
module tb_axi4_checker_capability;
  bit clk = 0;
  bit resetn = 0;
  always #0.5 clk = ~clk;
  axi4_if #(.ADDR_WIDTH(32), .DATA_WIDTH(256), .ID_WIDTH(8), .LEN_WIDTH(4)) bus(clk, resetn);
  axi4_protocol_monitor #(.SUPPORT_FIXED_BURST(1)) dut(bus);
  initial begin
    #2;
    $fatal(1, "CHECKER_CAPABILITY_SMOKE_MISSING_EXPECTED_ERROR");
  end
endmodule
