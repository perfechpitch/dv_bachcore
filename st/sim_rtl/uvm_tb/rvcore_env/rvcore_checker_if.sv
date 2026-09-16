interface rvcore_checker_if(input logic clk);
  logic reset_n;
  logic [1:0] retire_num;
  logic [31:0] retire_pc[2];
  logic wb_valid;
  logic [4:0] wb_reg_idx;
  logic [31:0] wb_data;
  logic reg_write_pending;
endinterface
