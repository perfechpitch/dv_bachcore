module rvcore_tb_top;
  import uvm_pkg::*;
  import rvcore_tc_pkg::*;
  logic clk = 0;
  always #5 clk = ~clk;
  rvcore_checker_if checker_if(clk);

  initial begin
    checker_if.reset_n = 0;
    checker_if.retire_num = 0;
    checker_if.retire_pc[0] = 0;
    checker_if.retire_pc[1] = 0;
    checker_if.wb_valid = 0;
    checker_if.wb_reg_idx = 0;
    checker_if.wb_data = 0;
    checker_if.reg_write_pending = 0;
    repeat (3) @(posedge clk);
    checker_if.reset_n = 1;
  end

  initial begin
    void'($system("mkdir -p log"));
    uvm_config_db#(virtual rvcore_checker_if)::set(null, "uvm_test_top*", "vif", checker_if);
    run_test("rvcore_observation_test");
  end
endmodule
