// ============================================================================
// Filename             : vu_test.sv
// Author               : kippy
// Created On           : 2026-9-1 11:53
// Last Modified        :
// Update Count         :
// Description          :
// ============================================================================

`ifndef VU_TEST_SV
`define VU_TEST_SV 
class vu_test extends vu_base_test;
    `uvm_component_utils(vu_test)

    function new(string name="", uvm_component parent=null);
        super.new(name,parent);
    endfunction : new
    
    function void build_phase(uvm_phase phase);
        //`uvm_info("build_phase", "Entered...", UVM_LOW);
        set_config_params();

        // 
        // Set default sequence. 
        //
        uvm_config_db#(uvm_object_wrapper)::set(this,"vu_env.vu_vsqr.main_phase", "default_sequence",vu_vsequence::type_id::get());

        // Create the tb
        super.build_phase(phase);

        //`uvm_info("build_phase", "Exited...", UVM_LOW);
    endfunction : build_phase

    //extern function void set_config_special_random();
endclass : vu_test

//function void vu_test::set_config_params(); 
//    vu_case_cfg.xxx_case();
//endfunction
`endif