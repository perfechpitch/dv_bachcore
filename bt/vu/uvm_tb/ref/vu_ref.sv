// ============================================================================
// Filename             : vu_reference.sv
// Author               : kippy
// Created On           : 2026-9-1 11:53
// Last Modified        :
// Update Count         :
// Description          :
// ============================================================================
`ifndef VU_REFERENCE_SV
`define VU_REFERENCE_SV


class vu_reference extends uvm_component;


    my_block    regs;
    
    covergroup cov_trans;
        option.per_instance = 1;
    endgroup : cov_trans

    `uvm_component_utils_begin(vu_reference)
    `uvm_component_utils_end
    
    function new (string name, uvm_component parent);
        super.new(name, parent);
        cov_trans = new();
        cov_trans.set_inst_name({get_full_name(), ".cov_trans"});

    endfunction : new
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);


    endfunction: build_phase
   

    extern virtual task     reset_phase(uvm_phase phase);
    extern virtual function ref_reset();
endclass : vu_reference

task vu_reference::reset_phase(uvm_phase phase);
    ref_reset();
endtask : reset_phase

function vu_reference::ref_reset();
    // User should reset all queues and internal variables.
endfunction :ref_reset 
`endif
