// ============================================================================
// Filename             : vu_vsequencer.sv
// Author               : kippy
// Created On           : 2026-9-1 11:53
// Last Modified        :
// Update Count         :
// Description          :
// ============================================================================
`ifndef VU_VSEQUENCER_SV
`define VU_VSEQUENCER_SV

class vu_vsequencer extends uvm_sequencer;
    reset_sequencer         reset_sqr;
    inst_gen_sequencer      inst_gen_sqr;

    vu_case_config          vu_case_cfg;

    `uvm_component_utils_begin(vu_vsequencer)
    `uvm_component_utils_end
      
    function new (string name, uvm_component parent);
      super.new(name, parent);
    endfunction : new
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(vu_case_config)::get(this,"","vu_case_cfg",vu_case_cfg))
            `uvm_fatal("NOCFG",{"config must be set for: ",get_full_name(),".vu_case_cfg"});
    endfunction : build_phase
endclass : vu_vsequencer

`endif