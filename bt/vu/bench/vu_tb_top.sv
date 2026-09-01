// ============================================================================
// Created by           :  
// Filename             : VU
// Author               : kippy
// Created On           : 2026-9-1 11:53
// Last Modified        :
// Update Count         :
// Description          :
/**
* Top-level SystemVerilog testbench.
* It instantites the interface and interconnect wrapper.  Clock generation
* is also  done in the same file.  It includes each test file and initiates
* the UVM phase manager by calling run_test().
*/
// ============================================================================

/** Include the top level packages and all interfaces */
`include    "XXXX_if.sv"
`include    "reset_if.sv"
`include    "vu_tc_pkg.sv"

module vu_tb_top;

    /** Import the top level packages */
    import uvm_pkg::*;
    import vu_tc_pkg::*;
   
    /** Parameter defines the clock frequency */
    /** Timescale = 1ps/1ps **/
    parameter clk_period = XXXX; 
   
    /** Signals declarations */
    bit clk;

    /** Interface instance*/
    reset_if    reset_if(clk);
    XXXX_if     XXXX_if(clk,reset_if.reset);

    /** Top level module instance*/
    vu u_DUT();

    vu_wrapper u_vu_wrapper(
         reset_if
        ,XXXX_if  
    );


    /** Testbench 'clk' Clock Generator */
    initial begin
        clk = 0 ;
        forever begin
            #(clk_period/2) clk = ~clk ;
        end
    end

    /**
    * Optionally dump the sim variable for waveform display
    */
    initial begin
        if($test$plusargs("dump"))
        begin
            //$vcdpluson();
            $fsdbDumpfile("tb.fsdb");
            $fsdbDumpvars(0,"+all");
            //$fsdbDumplimit(256); 
            //$fsdbDumpon;
            //$fsdbDumpMDA();
        end
    end

    initial begin
        /** Set interface on the uvm_test_top */
        uvm_config_db#(virtual XXXX_if)::set(null,"uvm_test_top*","XXXX_vif",XXXX_if);
        uvm_config_db#(virtual reset_if)::set(null,"uvm_test_top*","reset_vif",reset_if);
        /** Start the UVM tests */
        run_test();
    end

endmodule