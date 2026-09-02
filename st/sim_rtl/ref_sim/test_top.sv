`include "../ref_sim/test.sv"
`define BYPASS_DUT
module test_top();
    import uvm_pkg::*;
initial begin
    void'($system("mkdir -p log"));
    run_test();
end

endmodule
