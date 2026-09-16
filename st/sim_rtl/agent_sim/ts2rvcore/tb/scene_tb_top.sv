`timescale 1ns/1ps
module scene_tb_top;
  import uvm_pkg::*; import rv_dsa_pkg::*; import rv_dsa_tc_pkg::*; import ts_pkg::*; import ts_tc_pkg::*;
  bit clk=0,reset_n=0; always #5 clk=~clk;
  rv_dsa_if rv_vif(clk,reset_n); ts_if ts_vif(clk,reset_n);
  dsa_responder rv_responder(rv_vif); ts_fake_responder ts_responder(ts_vif);
  initial begin
    uvm_config_db#(virtual rv_dsa_if)::set(null,"*","vif",rv_vif);
    uvm_config_db#(virtual ts_if)::set(null,"*","ts_vif",ts_vif);
    run_test();
  end
  initial begin repeat(5) @(posedge clk); reset_n<=1; end
endmodule
