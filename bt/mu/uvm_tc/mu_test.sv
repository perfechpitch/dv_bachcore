// ============================================================================
// Filename             : mu_test.sv
// Author               : kippy
// Created On           : 2026-9-18 10:21
// Last Modified        :
// Update Count         :
// Description          :
// ============================================================================

`ifndef MU_TEST_SV
`define MU_TEST_SV 
class mu_test extends mu_base_test;
    `uvm_component_utils(mu_test)

    function new(string name="", uvm_component parent=null);
        super.new(name,parent);
    endfunction : new
    
    function void build_phase(uvm_phase phase);
        //`uvm_info("build_phase", "Entered...", UVM_LOW);
        set_config_params();

        // 
        // Set default sequence. 
        //
        uvm_config_db#(uvm_object_wrapper)::set(this,"mu_env.mu_vsqr.main_phase", "default_sequence",mu_vsequence::type_id::get());

        // Create the tb
        super.build_phase(phase);

        //`uvm_info("build_phase", "Exited...", UVM_LOW);
    endfunction : build_phase

    //extern function void set_config_special_random();
endclass : mu_test

//function void mu_test::set_config_params(); 
//    mu_case_cfg.xxx_case();
//endfunction
`endif