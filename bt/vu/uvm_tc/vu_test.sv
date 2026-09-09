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
        set_config_params();

        // Set default sequence.
        uvm_config_db#(uvm_object_wrapper)::set(this,"vu_env.vu_vsqr.main_phase", "default_sequence",vu_vsequence::type_id::get());

        super.build_phase(phase);

    endfunction : build_phase

endclass : vu_test

`endif