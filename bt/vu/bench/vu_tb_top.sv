// ============================================================================
// Created by           :  
// Filename             : VU
// Author               : kippy
// Created On           : 2026-9-1 11:53
// Last Modified        :
// Update Count         :
// Description          :

`include    "reset_if.sv"
`include    "inst_gen_if.sv"
`include    "vu_tc_pkg.sv"

module vu_tb_top;

    import uvm_pkg::*;
    import vu_tc_pkg::*;
   
    parameter clk_period = 50; 
   
    bit clk;

    reset_if    reset_if(clk);
    inst_gen_if inst_gen_if(clk, reset_if.reset);

    vu u_DUT();

    vu_wrapper u_vu_wrapper(
         reset_if
        ,inst_gen_if  
    );


    // Testbench 'clk' Clock Generator
    initial begin
        clk = 0 ;
        forever begin
            #(clk_period/2) clk = ~clk ;
        end
    end

    // Optionally dump the sim variable for waveform display
    initial begin
        if($test$plusargs("dump"))
        begin
            $fsdbDumpfile("tb.fsdb");
            $fsdbDumpvars(0,"+all");
        end
    end

    initial begin
        uvm_config_db#(virtual reset_if)::set(null,"uvm_test_top*","reset_vif",reset_if);
        uvm_config_db#(virtual inst_gen_if)::set(null,"uvm_test_top*","inst_gen_vif",inst_gen_if);
        run_test();
    end

endmodule
