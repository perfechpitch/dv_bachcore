`timescale 1ns/1ps
module rv_dsa_tb_top;
  import uvm_pkg::*; import rv_dsa_pkg::*; import rv_dsa_tc_pkg::*;
  bit clk=0, reset_n=0;
  always #5 clk=~clk;
  rv_dsa_if vif(clk,reset_n);
  dsa_responder responder(vif);
  initial begin
    uvm_config_db#(virtual rv_dsa_if)::set(null,"*","vif",vif);
    run_test();
  end
  initial begin
    repeat(5) @(posedge clk);
    reset_n<=1;
  end
endmodule
